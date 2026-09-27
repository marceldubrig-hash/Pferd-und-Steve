extends Node2D

const FARM_DAY := "res://assets/backgrounds/farm_day_v01.png"
const FARM_NIGHT := "res://assets/backgrounds/farm_night_v01.png"
const HORSE_MASTER := "res://assets/horse/horse_master_standing_v01.png"

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
const HORSE_FOOT_ANCHOR_TEXTURE_RATIO := 1055.0 / 1086.0

@onready var background: Sprite2D = $Background
@onready var horse_root: Node2D = $HorseRoot
@onready var horse_master: Sprite2D = $HorseRoot/HorseMaster

var is_night := false
var mouse_dragging := false

# Persist movement in normalized screen/depth coordinates so resize/fold changes
# do not destroy the world position.
var horse_x_ratio := 0.5
var horse_depth_t := 0.28


func _ready() -> void:
	get_viewport().size_changed.connect(_layout_scene)
	_load_texture_if_available(background, FARM_DAY)
	_load_texture_if_available(horse_master, HORSE_MASTER)
	_configure_horse_foot_anchor()
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


func _configure_horse_foot_anchor() -> void:
	if horse_master.texture == null:
		return

	var texture_size := horse_master.texture.get_size()
	var foot_y := texture_size.y * HORSE_FOOT_ANCHOR_TEXTURE_RATIO

	# Keep the visual centered horizontally, but move its pivot vertically
	# from the image centre to the actual hoof/ground contact.
	horse_master.centered = true
	horse_master.position = Vector2.ZERO
	horse_master.offset = Vector2(
		0.0,
		texture_size.y * 0.5 - foot_y
	)


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
	horse_master.flip_h = not facing_right


func set_horse_position(new_position: Vector2) -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var min_y := size.y * GROUND_BACK_TOUCH_Y_RATIO
	var max_y := size.y * GROUND_FRONT_TOUCH_Y_RATIO
	var clamped_x := clampf(new_position.x, 0.0, size.x)
	var clamped_y := clampf(new_position.y, min_y, max_y)

	horse_x_ratio = clamped_x / size.x
	horse_depth_t = clampf(
		inverse_lerp(min_y, max_y, clamped_y),
		0.0,
		1.0
	)
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


func _apply_perspective() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

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

	var visible_source_height := 1.0
	if horse_master.texture != null:
		visible_source_height = maxf(
			horse_master.texture.get_height() * HORSE_VISIBLE_HEIGHT_TEXTURE_RATIO,
			1.0
		)

	var target_horse_height_px := size.y * projected_horse_height_ratio
	var visual_scale := target_horse_height_px / visible_source_height

	horse_root.position = Vector2(
		size.x * horse_x_ratio,
		size.y * projected_foot_y_ratio
	)
	horse_root.scale = Vector2.ONE * visual_scale
	horse_root.z_index = int(round(horse_depth_t * 100.0))
