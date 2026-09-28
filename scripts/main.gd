extends Node2D

const FARM_DAY := "res://assets/backgrounds/farm_day_v01.png"
const FARM_NIGHT := "res://assets/backgrounds/farm_night_v01.png"

# Perspective model:
# A pinhole camera projects apparent size proportional to 1 / distance.
# The background is treated as a flat ground plane with a calibrated horizon.
const GROUND_BACK_TOUCH_Y_RATIO := 0.565
const GROUND_FRONT_TOUCH_Y_RATIO := 0.985
const PERSPECTIVE_HORIZON_Y_RATIO := 0.405

# Approximate camera/horse dimensions used only for the projection ratio.
# 1.65 m is a plausible full-size horse height; 1.70 m approximates a human-height camera.
const HORSE_WORLD_HEIGHT_M := 1.65
const CAMERA_HEIGHT_M := 1.70

# The user's vertical drag is mapped to a real-ish depth interval.
# At the near limit the projected hoof point deliberately lies below the viewport,
# so only the upper part of the horse remains visible very close to the camera.
const FAR_DISTANCE_M := 12.0
const NEAR_DISTANCE_M := 1.40
const FAR_PROJECTED_FOOT_Y_RATIO := GROUND_BACK_TOUCH_Y_RATIO

# Canon master alpha calibration, expressed as fractions so it stays correct
# if the runtime source is resized. Original canonical source: 1448 x 1086.
const HORSE_VISIBLE_HEIGHT_TEXTURE_RATIO := 1039.0 / 1086.0
# Freeze the exact pre-integration runtime calibration denominator. The cutout
# is mapped into this height by RigSpace, so the 1/Z perspective itself is unchanged.
const HORSE_MASTER_RUNTIME_HEIGHT_PX := 768.0
const HORSE_VISIBLE_SOURCE_HEIGHT_PX := HORSE_MASTER_RUNTIME_HEIGHT_PX * HORSE_VISIBLE_HEIGHT_TEXTURE_RATIO

# Calibrated obstacle-aware rear ground edge.
# The user's selected 1536x1384 screenshots show:
# - open rear yard: hoof line about y=781px ~= 0.565h
# - hay-bale / right-shelter limits: hoof line about y=809px ~= 0.585h
# Near the extreme sides the boundary comes slightly farther forward so the
# horse walks in front of the barn/shelter instead of visually standing on them.
const LEFT_OUTER_GROUND_Y_RATIO := 0.600
const LEFT_OBSTACLE_GROUND_Y_RATIO := 0.585
const RIGHT_OBSTACLE_GROUND_Y_RATIO := 0.585
const RIGHT_OUTER_GROUND_Y_RATIO := 0.600

const LEFT_OUTER_X_RATIO := 0.00
const LEFT_OBSTACLE_X_RATIO := 0.36
const LEFT_OPEN_X_RATIO := 0.43
const RIGHT_OPEN_X_RATIO := 0.80
const RIGHT_OBSTACLE_X_RATIO := 0.87
const RIGHT_OUTER_X_RATIO := 1.00

# The old obstacle profile above was calibrated from a 1536x1384 screenshot.
# Using those values directly as viewport ratios breaks as soon as the Fold runs
# at a different aspect ratio because Background uses cover scaling/cropping.
# Keep the historical ratios for documentation, but resolve collisions in the
# canonical 1536x864 farm texture's coordinate space instead.
const FARM_SOURCE_SIZE := Vector2(1536.0, 864.0)
const LEFT_OUTER_SOURCE_X := 288.5549
const LEFT_OBSTACLE_SOURCE_X := 633.7554
const LEFT_OPEN_SOURCE_X := 700.8777
const RIGHT_OPEN_SOURCE_X := 1055.6671
const RIGHT_OBSTACLE_SOURCE_X := 1122.7894
const RIGHT_OUTER_SOURCE_X := 1247.4451

const OPEN_GROUND_SOURCE_Y := 488.16
const OBSTACLE_GROUND_SOURCE_Y := 505.44
const OUTER_GROUND_SOURCE_Y := 518.40

# Keep the visible horse inside the viewport and use its current projected width
# when testing obstacle overlap. This prevents the root from being legal while
# the body/head is already inside a barn/shelter or outside the screen.
const HORSE_HALF_WIDTH_TO_PROJECTED_HEIGHT := 0.62
const SCREEN_EDGE_PADDING_PX := 8.0

@onready var background: Sprite2D = $Background
@onready var horse_root: Node2D = $HorseRoot
@onready var horse_visual: Node2D = $HorseRoot/HorseVisual

var is_night := false
var mouse_dragging := false

# Persist movement in normalized screen/depth coordinates so resize/fold changes
# do not destroy the world position.
var horse_x_ratio := 0.5
var horse_depth_t := 0.28


func _ready() -> void:
	get_viewport().size_changed.connect(_layout_scene)
	_load_texture_if_available(background, FARM_DAY)
	_layout_scene()
	_apply_perspective()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_move_horse_to(touch.position)
		return

	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_move_horse_to(drag.position)
		return

	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			mouse_dragging = mouse_button.pressed
			if mouse_button.pressed:
				_move_horse_to(mouse_button.position)
		return

	if event is InputEventMouseMotion and mouse_dragging:
		var mouse_motion := event as InputEventMouseMotion
		_move_horse_to(mouse_motion.position)


func _load_texture_if_available(target: Sprite2D, path: String) -> void:
	if ResourceLoader.exists(path):
		target.texture = load(path)
	else:
		push_warning("Runtime-Asset fehlt: %s" % path)



func show_day() -> void:
	is_night = false
	_load_texture_if_available(background, FARM_DAY)
	_layout_scene()


func show_night() -> void:
	is_night = true
	_load_texture_if_available(background, FARM_NIGHT)
	_layout_scene()


func set_horse_facing_right(facing_right: bool) -> void:
	# Canon: RIGHT = Original, LEFT = horizontal gespiegelt.
	# Mirror the complete cutout once at its outer visual container.
	horse_visual.scale = Vector2(1.0 if facing_right else -1.0, 1.0)


func set_horse_position(new_position: Vector2) -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var min_y := size.y * GROUND_BACK_TOUCH_Y_RATIO
	var max_y := size.y * GROUND_FRONT_TOUCH_Y_RATIO
	var clamped_y := clampf(new_position.y, min_y, max_y)

	var requested_depth_t := clampf(
		inverse_lerp(min_y, max_y, clamped_y),
		0.0,
		1.0
	)

	var resolved_x := clampf(new_position.x, 0.0, size.x)
	var resolved_depth_t := requested_depth_t

	# Resolve horizontal screen containment and obstacle depth together.
	# Projected horse width grows with depth, so a few deterministic passes are
	# enough to converge without introducing physics or a new movement system.
	for _pass in range(4):
		resolved_x = _clamp_horse_screen_x(resolved_x, size, resolved_depth_t)
		var obstacle_min_depth_t := _minimum_depth_t_for_screen_x(
			resolved_x,
			size,
			resolved_depth_t
		)
		resolved_depth_t = maxf(requested_depth_t, obstacle_min_depth_t)

	horse_x_ratio = resolved_x / size.x
	horse_depth_t = resolved_depth_t
	_apply_perspective()


func _move_horse_to(target_position: Vector2) -> void:
	var current_x := horse_root.position.x
	if absf(target_position.x - current_x) > 1.0:
		set_horse_facing_right(target_position.x > current_x)
	set_horse_position(target_position)


func _layout_scene() -> void:
	var size := get_viewport_rect().size
	background.position = size * 0.5

	if background.texture != null:
		var texture_size := background.texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			var cover_scale := maxf(
				size.x / texture_size.x,
				size.y / texture_size.y
			)
			background.scale = Vector2.ONE * cover_scale

	_apply_perspective()


func _background_cover_scale(size: Vector2) -> float:
	return maxf(
		size.x / FARM_SOURCE_SIZE.x,
		size.y / FARM_SOURCE_SIZE.y
	)


func _background_source_to_screen(source_point: Vector2, size: Vector2) -> Vector2:
	var cover_scale := _background_cover_scale(size)
	var scaled_source_size := FARM_SOURCE_SIZE * cover_scale
	var offset := (size - scaled_source_size) * 0.5
	return offset + source_point * cover_scale


func _background_screen_x_to_source(screen_x: float, size: Vector2) -> float:
	var cover_scale := _background_cover_scale(size)
	var scaled_source_width := FARM_SOURCE_SIZE.x * cover_scale
	var offset_x := (size.x - scaled_source_width) * 0.5
	return (screen_x - offset_x) / maxf(cover_scale, 0.001)


func _minimum_ground_source_y_for_source_x(source_x: float) -> float:
	var x := source_x

	if x <= LEFT_OBSTACLE_SOURCE_X:
		var outer_t := clampf(
			inverse_lerp(LEFT_OUTER_SOURCE_X, LEFT_OBSTACLE_SOURCE_X, x),
			0.0,
			1.0
		)
		return lerpf(
			OUTER_GROUND_SOURCE_Y,
			OBSTACLE_GROUND_SOURCE_Y,
			smoothstep(0.0, 1.0, outer_t)
		)

	if x < LEFT_OPEN_SOURCE_X:
		var open_t := inverse_lerp(
			LEFT_OBSTACLE_SOURCE_X,
			LEFT_OPEN_SOURCE_X,
			x
		)
		return lerpf(
			OBSTACLE_GROUND_SOURCE_Y,
			OPEN_GROUND_SOURCE_Y,
			smoothstep(0.0, 1.0, open_t)
		)

	if x <= RIGHT_OPEN_SOURCE_X:
		return OPEN_GROUND_SOURCE_Y

	if x < RIGHT_OBSTACLE_SOURCE_X:
		var obstacle_t := inverse_lerp(
			RIGHT_OPEN_SOURCE_X,
			RIGHT_OBSTACLE_SOURCE_X,
			x
		)
		return lerpf(
			OPEN_GROUND_SOURCE_Y,
			OBSTACLE_GROUND_SOURCE_Y,
			smoothstep(0.0, 1.0, obstacle_t)
		)

	var outer_t := clampf(
		inverse_lerp(RIGHT_OBSTACLE_SOURCE_X, RIGHT_OUTER_SOURCE_X, x),
		0.0,
		1.0
	)
	return lerpf(
		OBSTACLE_GROUND_SOURCE_Y,
		OUTER_GROUND_SOURCE_Y,
		smoothstep(0.0, 1.0, outer_t)
	)


func _projected_horse_height_px_for_depth(size: Vector2, depth_t: float) -> float:
	var distance_m := lerpf(FAR_DISTANCE_M, NEAR_DISTANCE_M, depth_t)
	var inverse_depth_gain := FAR_DISTANCE_M / maxf(distance_m, 0.01)
	var foot_delta_from_horizon := (
		FAR_PROJECTED_FOOT_Y_RATIO - PERSPECTIVE_HORIZON_Y_RATIO
	) * inverse_depth_gain
	var projected_horse_height_ratio := (
		HORSE_WORLD_HEIGHT_M / CAMERA_HEIGHT_M
	) * maxf(foot_delta_from_horizon, 0.001)
	return size.y * projected_horse_height_ratio


func _horse_collision_half_width_px(size: Vector2, depth_t: float) -> float:
	return _projected_horse_height_px_for_depth(size, depth_t) * HORSE_HALF_WIDTH_TO_PROJECTED_HEIGHT


func _clamp_horse_screen_x(screen_x: float, size: Vector2, depth_t: float) -> float:
	var half_width := _horse_collision_half_width_px(size, depth_t)
	var margin := minf(
		half_width + SCREEN_EDGE_PADDING_PX,
		size.x * 0.45
	)
	return clampf(screen_x, margin, size.x - margin)


func _minimum_depth_t_for_screen_x(
	screen_x: float,
	size: Vector2,
	probe_depth_t: float
) -> float:
	var half_width := _horse_collision_half_width_px(size, probe_depth_t)
	var sample_screen_xs := [
		screen_x - half_width,
		screen_x,
		screen_x + half_width,
	]

	var minimum_source_y := OPEN_GROUND_SOURCE_Y
	for sample_screen_x in sample_screen_xs:
		var source_x := _background_screen_x_to_source(sample_screen_x, size)
		minimum_source_y = maxf(
			minimum_source_y,
			_minimum_ground_source_y_for_source_x(source_x)
		)

	var minimum_screen_y := _background_source_to_screen(
		Vector2(0.0, minimum_source_y),
		size
	).y
	var minimum_foot_y_ratio := minimum_screen_y / maxf(size.y, 1.0)

	var far_delta := FAR_PROJECTED_FOOT_Y_RATIO - PERSPECTIVE_HORIZON_Y_RATIO
	var requested_delta := minimum_foot_y_ratio - PERSPECTIVE_HORIZON_Y_RATIO

	if far_delta <= 0.0 or requested_delta <= far_delta:
		return 0.0

	var inverse_depth_gain := requested_delta / far_delta
	var distance_m := FAR_DISTANCE_M / inverse_depth_gain
	return clampf(
		(FAR_DISTANCE_M - distance_m) / (FAR_DISTANCE_M - NEAR_DISTANCE_M),
		0.0,
		1.0
	)


func _apply_perspective() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Keep an already-stored position legal after a resize/fold-state change too.
	var resolved_x := size.x * horse_x_ratio
	for _pass in range(4):
		resolved_x = _clamp_horse_screen_x(resolved_x, size, horse_depth_t)
		horse_depth_t = maxf(
			horse_depth_t,
			_minimum_depth_t_for_screen_x(resolved_x, size, horse_depth_t)
		)
	horse_x_ratio = resolved_x / size.x

	# Move linearly in world depth, not linearly in sprite scale.
	# Perspective itself then naturally grows non-linearly as Z approaches camera.
	var distance_m := lerpf(FAR_DISTANCE_M, NEAR_DISTANCE_M, horse_depth_t)
	var inverse_depth_gain := FAR_DISTANCE_M / maxf(distance_m, 0.01)

	# Ground-plane projection. At FAR_DISTANCE the hoof sits exactly on the
	# calibrated rear edge of the playable dirt. Closer distances push the
	# projected hoof point downward and eventually below the screen.
	var foot_delta_from_horizon := (
		FAR_PROJECTED_FOOT_Y_RATIO - PERSPECTIVE_HORIZON_Y_RATIO
	) * inverse_depth_gain
	var projected_foot_y_ratio := (
		PERSPECTIVE_HORIZON_Y_RATIO + foot_delta_from_horizon
	)

	# For a vertical object on a flat plane:
	# projected_height / (foot_y - horizon_y) ~= object_height / camera_height.
	var projected_horse_height_ratio := (
		HORSE_WORLD_HEIGHT_M / CAMERA_HEIGHT_M
	) * maxf(foot_delta_from_horizon, 0.001)

	var target_horse_height_px := size.y * projected_horse_height_ratio
	var visual_scale := target_horse_height_px / HORSE_VISIBLE_SOURCE_HEIGHT_PX

	horse_root.position = Vector2(
		resolved_x,
		size.y * projected_foot_y_ratio
	)
	horse_root.scale = Vector2.ONE * visual_scale
	horse_root.z_index = int(round(horse_depth_t * 100.0))
