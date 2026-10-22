extends Node2D

const FARM_DAY := "res://assets/backgrounds/farm_day_v01.png"
const FARM_NIGHT := "res://assets/backgrounds/farm_night_v01.png"
const STEVE_STANDING := "res://assets/steve/steve_standing_v01.png"
const STEVE_CUTOUT_RIG := "res://scenes/steve_cutout_rig.tscn"

# Farmer Steve stands at a fixed yard spot for now (no movement, no collision).
# Calibration from the confirmed cutout steve_standing_v01.png (1024x1536):
# visible alpha bbox 988x1521, boots-bottom-center anchor at (494, 1521).
const STEVE_WORLD_HEIGHT_M := 1.80
const STEVE_VISIBLE_SOURCE_HEIGHT_PX := 1521.0
const STEVE_ANCHOR_X_PX := 494.0
const STEVE_ANCHOR_BOTTOM_PX := 1521.0
const STEVE_X_RATIO := 0.33
const STEVE_DEPTH_T := 0.40
# Steve never shares his ground spot with the horse: when the horse enters
# Steve's depth band near his x position, Steve sidesteps until it is clear.
const STEVE_DODGE_DEPTH_MARGIN := 0.10
const STEVE_DODGE_X_OFFSET := 0.16
const STEVE_DODGE_SPEED_RATIO_PER_SECOND := 0.25
const STEVE_X_MIN_RATIO := 0.08
const STEVE_X_MAX_RATIO := 0.92
const STEVE_VISIBLE_HALF_WIDTH_PX := 494.0

# Schlaf-Posen fuer die Nacht (20:00-06:00 Uhr, gesteuert vom DayNightManager).
# Die Pose wird situational gewaehlt: krank/erschoepft = flach, muede = liegend,
# sonst = stehendes Dösen. Alle drei Quellen schauen nach RECHTS (Kanon), das
# Spiegeln uebernimmt wie beim Rig der HorseVisual-Container.
const HORSE_SLEEP_FLAT := "res://assets/horse/sleep/horse_sleep_flat_v01.png"
const HORSE_SLEEP_LYING := "res://assets/horse/sleep/horse_sleep_lying_v01.png"
const HORSE_SLEEP_DOZING := "res://assets/horse/sleep/horse_sleep_dozing_v01.png"
const SLEEP_POSE_RECHECK_SECONDS := 5.0
# Layout pro Pose im RigSpace: Skala + Sprite-Mitte, so kalibriert, dass der
# Bodenkontakt der Textur exakt auf der Rig-Huflinie liegt und die Koerpermasse
# an der Koerpermitte des stehenden Pferds bleibt (gleiches Tier, gleicher Platz).
const SLEEP_FLAT_SCALE := 0.80
const SLEEP_FLAT_POS := Vector2(-62.0, -148.0)
const SLEEP_LYING_SCALE := 0.78
const SLEEP_LYING_POS := Vector2(-113.0, -249.0)
const SLEEP_DOZING_SCALE := 1.22
const SLEEP_DOZING_POS := Vector2(-41.0, -375.0)

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

# Side-fence positions measured directly in the canonical farm texture from the
# user's real 1536x658 Fold screenshot. They are only active when the corresponding
# fence is actually visible after Background cover-scaling/cropping.
const LEFT_SIDE_FENCE_SOURCE_X := 45.0
const RIGHT_SIDE_FENCE_SOURCE_X := 1416.0
# User-drawn final rear ground boundary for the 1536x658 wide Fold layout.
# Points were sampled from the blue line in reference 22978.jpg and normalized,
# so the same shape survives small viewport-size variations.
const WIDE_GROUND_BOUNDARY_POINTS := [
	Vector2(60.0 / 1536.0, 445.0 / 659.0),
	Vector2(80.0 / 1536.0, 435.0 / 659.0),
	Vector2(120.0 / 1536.0, 423.0 / 659.0),
	Vector2(160.0 / 1536.0, 413.0 / 659.0),
	Vector2(220.0 / 1536.0, 410.0 / 659.0),
	Vector2(300.0 / 1536.0, 411.0 / 659.0),
	Vector2(380.0 / 1536.0, 401.0 / 659.0),
	Vector2(430.0 / 1536.0, 400.0 / 659.0),
	Vector2(480.0 / 1536.0, 420.0 / 659.0),
	Vector2(530.0 / 1536.0, 428.0 / 659.0),
	Vector2(680.0 / 1536.0, 426.0 / 659.0),
	Vector2(720.0 / 1536.0, 413.0 / 659.0),
	Vector2(760.0 / 1536.0, 401.0 / 659.0),
	Vector2(820.0 / 1536.0, 395.0 / 659.0),
	Vector2(900.0 / 1536.0, 398.0 / 659.0),
	Vector2(1040.0 / 1536.0, 397.0 / 659.0),
	Vector2(1080.0 / 1536.0, 403.0 / 659.0),
	Vector2(1120.0 / 1536.0, 420.0 / 659.0),
	Vector2(1160.0 / 1536.0, 428.0 / 659.0),
	Vector2(1240.0 / 1536.0, 421.0 / 659.0),
	Vector2(1320.0 / 1536.0, 424.0 / 659.0),
	Vector2(1360.0 / 1536.0, 426.0 / 659.0),
	Vector2(1400.0 / 1536.0, 433.0 / 659.0),
]

# User-requested final micro-calibration: keep the exact cutout a few screen
# pixels inside the already calibrated rear and lateral ground boundaries.
const COLLISION_BOUNDARY_INSET_PX := 4.0
const WIDE_FOLD_EXTRA_COLLISION_BOUNDARY_INSET_PX := 4.0

# The collision solver has one circular dependency: moving the horse forward makes
# it larger, which changes its exact visual X-span. Iterate to convergence using the
# real Sprite2D bounds instead of estimating horse width.
const COLLISION_SOLVER_MAX_PASSES := 8
const COLLISION_SOLVER_EPSILON := 0.0001

# Autonomous horse wandering. These values control only target choice and travel
# timing; every requested position is still resolved by the frozen collision system.
const WANDER_X_MIN_RATIO := 0.12
const WANDER_X_MAX_RATIO := 0.88
const WANDER_DEPTH_MIN_T := 0.04
const WANDER_DEPTH_MAX_T := 0.55
const WANDER_X_SPEED_RATIO_PER_SECOND := 0.055
const WANDER_DEPTH_SPEED_T_PER_SECOND := 0.045
const WANDER_MIN_HORIZONTAL_TRAVEL_RATIO := 0.16
const WANDER_TARGET_EPSILON := 0.006
const WANDER_PAUSE_MIN_SECONDS := 1.5
const WANDER_PAUSE_MAX_SECONDS := 4.5
const WANDER_REROUTE_MIN_SECONDS := 6.0
const WANDER_REROUTE_MAX_SECONDS := 14.0

@onready var background: Sprite2D = $Background
@onready var horse_root: Node2D = $HorseRoot

var steve_root: Node2D = null
var steve_rig: Node2D = null
var steve_anim: AnimationPlayer = null
# +1 = schaut nach rechts (Kanon-Seitenansicht), -1 = nach links.
var steve_facing := 1.0
var steve_x_ratio := STEVE_X_RATIO
var steve_dodge_target_x_ratio := STEVE_X_RATIO
@onready var horse_visual: Node2D = $HorseRoot/HorseVisual
@onready var walk_animation_player: AnimationPlayer = (
	$HorseRoot/HorseVisual/RigSpace/HorseCutoutRig/WalkAnimationPlayer
)
@onready var rig_space: Node2D = $HorseRoot/HorseVisual/RigSpace
@onready var cutout_rig: Node2D = $HorseRoot/HorseVisual/RigSpace/HorseCutoutRig
# Autoload ueber Pfad statt globalem Namen, damit das Skript auch in
# Standalone-Harness-Umgebungen ohne Autoload-Globals kompiliert.
@onready var horse_stats: Node = get_node("/root/HorseStats")

var is_night := false

# Schlafzustand: Rig ausgeblendet, Schlaf-Sprite sichtbar, Wanderung eingefroren.
var is_sleeping := false
var sleep_sprite: Sprite2D = null
var sleep_pose_current := ""
var sleep_pose_recheck_remaining := 0.0

# Persist movement in normalized screen/depth coordinates so resize/fold changes
# do not destroy the world position.
var horse_x_ratio := 0.5
var horse_depth_t := 0.28

var wander_rng := RandomNumberGenerator.new()
var wander_position := Vector2(0.5, 0.28)
var wander_target := Vector2(0.5, 0.28)
var wander_pause_remaining := 0.0
var wander_reroute_remaining := 0.0
var horse_is_walking := false


func _ready() -> void:
	get_viewport().size_changed.connect(_layout_scene)
	_load_texture_if_available(background, FARM_DAY)
	_spawn_steve()
	_spawn_sleep_sprite()
	_layout_scene()
	_apply_perspective()

	wander_rng.randomize()
	wander_position = Vector2(horse_x_ratio, horse_depth_t)
	_choose_new_wander_target()


func _process(delta: float) -> void:
	_update_steve_dodge(delta)

	if is_sleeping:
		sleep_pose_recheck_remaining -= delta
		if sleep_pose_recheck_remaining <= 0.0:
			sleep_pose_recheck_remaining = SLEEP_POSE_RECHECK_SECONDS
			_update_sleep_pose()
		return

	if wander_pause_remaining > 0.0:
		wander_pause_remaining = maxf(wander_pause_remaining - delta, 0.0)
		if wander_pause_remaining <= 0.0:
			_choose_new_wander_target()
		return

	wander_reroute_remaining -= delta
	if wander_reroute_remaining <= 0.0:
		_choose_new_wander_target()

	var horizontal_delta := wander_target.x - wander_position.x
	if absf(horizontal_delta) > WANDER_TARGET_EPSILON:
		set_horse_facing_right(horizontal_delta > 0.0)

	wander_position.x = move_toward(
		wander_position.x,
		wander_target.x,
		WANDER_X_SPEED_RATIO_PER_SECOND * delta
	)
	wander_position.y = move_toward(
		wander_position.y,
		wander_target.y,
		WANDER_DEPTH_SPEED_T_PER_SECOND * delta
	)

	horse_x_ratio = wander_position.x
	horse_depth_t = wander_position.y
	_apply_perspective()

	if (
		absf(wander_target.x - wander_position.x) <= WANDER_TARGET_EPSILON
		and absf(wander_target.y - wander_position.y) <= WANDER_TARGET_EPSILON
	):
		_begin_wander_pause()


func _choose_new_wander_target() -> void:
	var next_x := wander_rng.randf_range(WANDER_X_MIN_RATIO, WANDER_X_MAX_RATIO)

	# Most choices cross the yard, which creates natural back-and-forth motion.
	if wander_rng.randf() < 0.65:
		if wander_position.x < 0.5:
			next_x = wander_rng.randf_range(0.55, WANDER_X_MAX_RATIO)
		else:
			next_x = wander_rng.randf_range(WANDER_X_MIN_RATIO, 0.45)

	for _attempt in range(8):
		if absf(next_x - wander_position.x) >= WANDER_MIN_HORIZONTAL_TRAVEL_RATIO:
			break
		next_x = wander_rng.randf_range(WANDER_X_MIN_RATIO, WANDER_X_MAX_RATIO)

	wander_target = Vector2(
		next_x,
		wander_rng.randf_range(WANDER_DEPTH_MIN_T, WANDER_DEPTH_MAX_T)
	)
	wander_reroute_remaining = wander_rng.randf_range(
		WANDER_REROUTE_MIN_SECONDS,
		WANDER_REROUTE_MAX_SECONDS
	)
	set_horse_facing_right(wander_target.x > wander_position.x)
	_set_horse_walking(true)


func _begin_wander_pause() -> void:
	wander_position = Vector2(horse_x_ratio, horse_depth_t)
	wander_pause_remaining = wander_rng.randf_range(
		WANDER_PAUSE_MIN_SECONDS,
		WANDER_PAUSE_MAX_SECONDS
	)
	_set_horse_walking(false)


func _set_horse_walking(walking: bool) -> void:
	if horse_is_walking == walking:
		return

	horse_is_walking = walking
	if walking:
		walk_animation_player.play("walk_test")
	else:
		walk_animation_player.play("RESET")


func _spawn_sleep_sprite() -> void:
	sleep_sprite = Sprite2D.new()
	sleep_sprite.name = "HorseSleepSprite"
	sleep_sprite.visible = false
	rig_space.add_child(sleep_sprite)


func _enter_sleep() -> void:
	if is_sleeping:
		return
	is_sleeping = true
	horse_stats.is_sleeping = true
	_set_horse_walking(false)
	cutout_rig.visible = false
	sleep_pose_current = ""
	_update_sleep_pose()
	sleep_sprite.visible = true


func _exit_sleep() -> void:
	if not is_sleeping:
		return
	is_sleeping = false
	horse_stats.is_sleeping = false
	sleep_sprite.visible = false
	cutout_rig.visible = true
	# Kurz stehen bleiben und dann das normale Hof-Leben fortsetzen.
	_begin_wander_pause()
	_apply_perspective()


func _update_sleep_pose() -> void:
	# Situationsbedingte Pose: krank oder komplett erschoepft -> flach auf der
	# Seite (Tiefschlaf), muede -> gestreckt liegend, sonst -> stehendes Dösen.
	var pose := "dozing"
	if horse_stats.health < 50.0 or horse_stats.fatigue >= 80.0:
		pose = "flat"
	elif horse_stats.fatigue >= 40.0:
		pose = "lying"
	if pose == sleep_pose_current:
		return
	sleep_pose_current = pose
	match pose:
		"flat":
			_apply_sleep_pose(HORSE_SLEEP_FLAT, SLEEP_FLAT_SCALE, SLEEP_FLAT_POS)
		"lying":
			_apply_sleep_pose(HORSE_SLEEP_LYING, SLEEP_LYING_SCALE, SLEEP_LYING_POS)
		_:
			_apply_sleep_pose(HORSE_SLEEP_DOZING, SLEEP_DOZING_SCALE, SLEEP_DOZING_POS)


func _apply_sleep_pose(texture_path: String, sprite_scale: float, sprite_pos: Vector2) -> void:
	if ResourceLoader.exists(texture_path):
		sleep_sprite.texture = load(texture_path)
	else:
		push_warning("Runtime-Asset fehlt: %s" % texture_path)
	sleep_sprite.scale = Vector2.ONE * sprite_scale
	sleep_sprite.position = sprite_pos


func _load_texture_if_available(target: Sprite2D, path: String) -> void:
	if ResourceLoader.exists(path):
		target.texture = load(path)
	else:
		push_warning("Runtime-Asset fehlt: %s" % path)



func show_day() -> void:
	is_night = false
	_load_texture_if_available(background, FARM_DAY)
	_exit_sleep()
	_layout_scene()


func show_night() -> void:
	is_night = true
	_load_texture_if_available(background, FARM_NIGHT)
	_enter_sleep()
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
	var requested_x := clampf(new_position.x, 0.0, size.x)
	var clamped_y := clampf(new_position.y, min_y, max_y)

	horse_x_ratio = requested_x / size.x
	horse_depth_t = clampf(
		inverse_lerp(min_y, max_y, clamped_y),
		0.0,
		1.0
	)

	# Collision resolution happens in _apply_perspective(). It uses the exact
	# current Cutout Sprite2D bounds, so a legal HorseRoot can no longer leave
	# the visible horse clipping through the calibrated farm boundaries.
	_apply_perspective()


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


func _minimum_projected_foot_y_ratio_for_x(x_ratio: float) -> float:
	var x := clampf(x_ratio, 0.0, 1.0)

	if x <= LEFT_OBSTACLE_X_RATIO:
		var outer_t := inverse_lerp(
			LEFT_OUTER_X_RATIO,
			LEFT_OBSTACLE_X_RATIO,
			x
		)
		return lerpf(
			LEFT_OUTER_GROUND_Y_RATIO,
			LEFT_OBSTACLE_GROUND_Y_RATIO,
			smoothstep(0.0, 1.0, outer_t)
		)

	if x < LEFT_OPEN_X_RATIO:
		var open_t := inverse_lerp(
			LEFT_OBSTACLE_X_RATIO,
			LEFT_OPEN_X_RATIO,
			x
		)
		return lerpf(
			LEFT_OBSTACLE_GROUND_Y_RATIO,
			GROUND_BACK_TOUCH_Y_RATIO,
			smoothstep(0.0, 1.0, open_t)
		)

	if x <= RIGHT_OPEN_X_RATIO:
		return GROUND_BACK_TOUCH_Y_RATIO

	if x < RIGHT_OBSTACLE_X_RATIO:
		var obstacle_t := inverse_lerp(
			RIGHT_OPEN_X_RATIO,
			RIGHT_OBSTACLE_X_RATIO,
			x
		)
		return lerpf(
			GROUND_BACK_TOUCH_Y_RATIO,
			RIGHT_OBSTACLE_GROUND_Y_RATIO,
			smoothstep(0.0, 1.0, obstacle_t)
		)

	var outer_t := inverse_lerp(
		RIGHT_OBSTACLE_X_RATIO,
		RIGHT_OUTER_X_RATIO,
		x
	)
	return lerpf(
		RIGHT_OBSTACLE_GROUND_Y_RATIO,
		RIGHT_OUTER_GROUND_Y_RATIO,
		smoothstep(0.0, 1.0, outer_t)
	)


func _minimum_depth_t_for_foot_y_ratio(minimum_foot_y_ratio: float) -> float:
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


func _minimum_depth_t_for_x(x_ratio: float) -> float:
	return _minimum_depth_t_for_foot_y_ratio(
		_minimum_projected_foot_y_ratio_for_x(x_ratio)
	)


func _collision_boundary_inset_px(size: Vector2) -> float:
	if size.x > size.y * 2.0:
		return COLLISION_BOUNDARY_INSET_PX + WIDE_FOLD_EXTRA_COLLISION_BOUNDARY_INSET_PX
	return COLLISION_BOUNDARY_INSET_PX


func _wide_ground_boundary_y_ratio_for_x(x_ratio: float) -> float:
	var x := clampf(x_ratio, 0.0, 1.0)
	var first_point: Vector2 = WIDE_GROUND_BOUNDARY_POINTS[0]
	if x <= first_point.x:
		return first_point.y

	for index in range(1, WIDE_GROUND_BOUNDARY_POINTS.size()):
		var left_point: Vector2 = WIDE_GROUND_BOUNDARY_POINTS[index - 1]
		var right_point: Vector2 = WIDE_GROUND_BOUNDARY_POINTS[index]
		if x <= right_point.x:
			var segment_t := inverse_lerp(left_point.x, right_point.x, x)
			return lerpf(
				left_point.y,
				right_point.y,
				smoothstep(0.0, 1.0, segment_t)
			)

	var last_point: Vector2 = WIDE_GROUND_BOUNDARY_POINTS[
		WIDE_GROUND_BOUNDARY_POINTS.size() - 1
	]
	return last_point.y


func _minimum_projected_foot_y_ratio_for_screen_span(
	left_screen_x: float,
	right_screen_x: float,
	size: Vector2
) -> float:
	var left_ratio := clampf(minf(left_screen_x, right_screen_x) / maxf(size.x, 1.0), 0.0, 1.0)
	var right_ratio := clampf(maxf(left_screen_x, right_screen_x) / maxf(size.x, 1.0), 0.0, 1.0)

	var minimum_ratio := maxf(
		_minimum_projected_foot_y_ratio_for_x(left_ratio),
		_minimum_projected_foot_y_ratio_for_x(right_ratio)
	)

	# The historical boundary is monotonic between these calibrated support
	# points. Testing every support point contained by the horse's real visual
	# span therefore gives the exact maximum boundary over that span.
	var support_points := [
		LEFT_OBSTACLE_X_RATIO,
		LEFT_OPEN_X_RATIO,
		RIGHT_OPEN_X_RATIO,
		RIGHT_OBSTACLE_X_RATIO,
	]
	for support_x in support_points:
		if support_x > left_ratio and support_x < right_ratio:
			minimum_ratio = maxf(
				minimum_ratio,
				_minimum_projected_foot_y_ratio_for_x(support_x)
			)

	if size.x > size.y * 2.0:
		minimum_ratio = maxf(
			minimum_ratio,
			maxf(
				_wide_ground_boundary_y_ratio_for_x(left_ratio),
				_wide_ground_boundary_y_ratio_for_x(right_ratio)
			)
		)
		for point_variant in WIDE_GROUND_BOUNDARY_POINTS:
			var point: Vector2 = point_variant
			if point.x > left_ratio and point.x < right_ratio:
				minimum_ratio = maxf(minimum_ratio, point.y)

		# The drawn blue line is already the requested final foot boundary.
		return clampf(minimum_ratio, 0.0, 1.0)

	return clampf(
		minimum_ratio + COLLISION_BOUNDARY_INSET_PX / maxf(size.y, 1.0),
		0.0,
		1.0
	)


func _minimum_depth_t_for_screen_span(
	left_screen_x: float,
	right_screen_x: float,
	size: Vector2
) -> float:
	return _minimum_depth_t_for_foot_y_ratio(
		_minimum_projected_foot_y_ratio_for_screen_span(
			left_screen_x,
			right_screen_x,
			size
		)
	)


func _horse_visual_x_bounds_in_root_space() -> Vector2:
	var root_inverse := horse_root.global_transform.affine_inverse()
	var minimum_x := INF
	var maximum_x := -INF
	var found_sprite := false

	for node in horse_visual.find_children("*", "Sprite2D", true, false):
		var sprite := node as Sprite2D
		if sprite == null or not sprite.visible or sprite.texture == null:
			continue

		var rect := sprite.get_rect()
		var sprite_to_root := root_inverse * sprite.global_transform
		var corners := [
			rect.position,
			Vector2(rect.end.x, rect.position.y),
			rect.end,
			Vector2(rect.position.x, rect.end.y),
		]

		for corner in corners:
			var root_point: Vector2 = sprite_to_root * corner
			minimum_x = minf(minimum_x, root_point.x)
			maximum_x = maxf(maximum_x, root_point.x)

		found_sprite = true

	if not found_sprite:
		return Vector2.ZERO

	return Vector2(minimum_x, maximum_x)


func _projected_horse_root_scale_for_depth(size: Vector2, depth_t: float) -> float:
	var distance_m := lerpf(FAR_DISTANCE_M, NEAR_DISTANCE_M, depth_t)
	var inverse_depth_gain := FAR_DISTANCE_M / maxf(distance_m, 0.01)
	var foot_delta_from_horizon := (
		FAR_PROJECTED_FOOT_Y_RATIO - PERSPECTIVE_HORIZON_Y_RATIO
	) * inverse_depth_gain
	var projected_horse_height_ratio := (
		HORSE_WORLD_HEIGHT_M / CAMERA_HEIGHT_M
	) * maxf(foot_delta_from_horizon, 0.001)
	var target_horse_height_px := size.y * projected_horse_height_ratio
	return target_horse_height_px / HORSE_VISIBLE_SOURCE_HEIGHT_PX


func _horse_screen_x_span(
	root_screen_x: float,
	size: Vector2,
	depth_t: float,
	local_x_bounds: Vector2
) -> Vector2:
	var root_scale := _projected_horse_root_scale_for_depth(size, depth_t)
	return Vector2(
		root_screen_x + local_x_bounds.x * root_scale,
		root_screen_x + local_x_bounds.y * root_scale
	)


func _background_source_x_to_screen(source_x: float) -> float:
	if background.texture == null:
		return source_x

	var source_width := background.texture.get_width()
	return (
		background.position.x
		+ (source_x - source_width * 0.5) * background.scale.x
	)


func _visible_horizontal_ground_limits(size: Vector2) -> Vector2:
	var left_limit := 0.0
	var right_limit := size.x

	var left_fence_x := _background_source_x_to_screen(LEFT_SIDE_FENCE_SOURCE_X)
	if left_fence_x >= 0.0 and left_fence_x <= size.x:
		left_limit = maxf(left_limit, left_fence_x)

	var right_fence_x := _background_source_x_to_screen(RIGHT_SIDE_FENCE_SOURCE_X)
	if right_fence_x >= 0.0 and right_fence_x <= size.x:
		right_limit = minf(right_limit, right_fence_x)

	var inset_px := _collision_boundary_inset_px(size)
	return Vector2(
		left_limit + inset_px,
		right_limit - inset_px
	)


func _clamp_root_x_for_visual_span(
	root_screen_x: float,
	size: Vector2,
	depth_t: float,
	local_x_bounds: Vector2
) -> float:
	var limits := _visible_horizontal_ground_limits(size)
	var root_scale := _projected_horse_root_scale_for_depth(size, depth_t)

	var minimum_root_x := limits.x - local_x_bounds.x * root_scale
	var maximum_root_x := limits.y - local_x_bounds.y * root_scale

	if minimum_root_x > maximum_root_x:
		return (limits.x + limits.y) * 0.5

	return clampf(root_screen_x, minimum_root_x, maximum_root_x)


func _resolve_horse_collision(
	requested_root_x: float,
	requested_depth_t: float,
	size: Vector2
) -> Vector2:
	var local_x_bounds := _horse_visual_x_bounds_in_root_space()
	var resolved_x := clampf(requested_root_x, 0.0, size.x)
	var resolved_depth_t := clampf(requested_depth_t, 0.0, 1.0)

	for _pass in range(COLLISION_SOLVER_MAX_PASSES):
		resolved_x = _clamp_root_x_for_visual_span(
			resolved_x,
			size,
			resolved_depth_t,
			local_x_bounds
		)

		var screen_span := _horse_screen_x_span(
			resolved_x,
			size,
			resolved_depth_t,
			local_x_bounds
		)
		var minimum_depth_t := _minimum_depth_t_for_screen_span(
			screen_span.x,
			screen_span.y,
			size
		)
		var next_depth_t := maxf(requested_depth_t, minimum_depth_t)

		if absf(next_depth_t - resolved_depth_t) <= COLLISION_SOLVER_EPSILON:
			resolved_depth_t = next_depth_t
			resolved_x = _clamp_root_x_for_visual_span(
				resolved_x,
				size,
				resolved_depth_t,
				local_x_bounds
			)
			break

		resolved_depth_t = next_depth_t

	return Vector2(resolved_x, resolved_depth_t)


func _apply_perspective() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Keep the entire current cutout legal after movement or a Fold resize.
	# HorseRoot remains the same physical ground anchor; only collision resolution
	# now evaluates the exact visible Sprite2D span around that anchor.
	var collision_result := _resolve_horse_collision(
		size.x * horse_x_ratio,
		horse_depth_t,
		size
	)
	horse_x_ratio = collision_result.x / size.x
	horse_depth_t = collision_result.y

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
		size.x * horse_x_ratio,
		size.y * projected_foot_y_ratio
	)
	horse_root.scale = Vector2.ONE * visual_scale
	horse_root.z_index = int(round(horse_depth_t * 100.0))
	_place_steve(size)


func _spawn_steve() -> void:
	steve_root = Node2D.new()
	steve_root.name = "SteveRoot"
	add_child(steve_root)

	# Articulated cutout rig (same 1024x1536 source space, boots-bottom-center
	# anchor (494, 1521) like the old static sprite).
	steve_rig = load(STEVE_CUTOUT_RIG).instantiate()
	steve_rig.name = "SteveVisual"
	steve_rig.position = Vector2(-STEVE_ANCHOR_X_PX, -STEVE_ANCHOR_BOTTOM_PX)
	steve_root.add_child(steve_rig)
	steve_anim = steve_rig.get_node("SteveAnimationPlayer")


func _update_steve_dodge(delta: float) -> void:
	if steve_root == null:
		return
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Same screen-space span math the horse collision solver uses.
	var horse_span := _horse_screen_x_span(
		horse_root.position.x,
		size,
		horse_depth_t,
		_horse_visual_x_bounds_in_root_space()
	)
	var steve_center_x := size.x * steve_x_ratio
	var steve_half_width := STEVE_VISIBLE_HALF_WIDTH_PX * absf(steve_root.scale.x)
	var margin_px := size.x * 0.02

	var depth_gap := absf(horse_depth_t - STEVE_DEPTH_T)
	var horse_blocks_steve := (
		depth_gap < STEVE_DODGE_DEPTH_MARGIN
		and horse_span.y > steve_center_x - steve_half_width - margin_px
		and horse_span.x < steve_center_x + steve_half_width + margin_px
	)

	if horse_blocks_steve:
		# Sidestep to the side away from the horse's body center.
		var horse_center_x := (horse_span.x + horse_span.y) * 0.5
		var dodge_direction := -1.0 if horse_center_x > steve_center_x else 1.0
		steve_dodge_target_x_ratio = clampf(
			steve_x_ratio + dodge_direction * STEVE_DODGE_X_OFFSET,
			STEVE_X_MIN_RATIO,
			STEVE_X_MAX_RATIO
		)
	else:
		# Return home only once the home spot itself is clear again.
		var home_center_x := size.x * STEVE_X_RATIO
		var home_clear := (
			depth_gap >= STEVE_DODGE_DEPTH_MARGIN
			or horse_span.y <= home_center_x - steve_half_width - margin_px
			or horse_span.x >= home_center_x + steve_half_width + margin_px
		)
		if home_clear:
			steve_dodge_target_x_ratio = STEVE_X_RATIO

	var next_x := move_toward(
		steve_x_ratio,
		steve_dodge_target_x_ratio,
		STEVE_DODGE_SPEED_RATIO_PER_SECOND * delta
	)
	if not is_equal_approx(next_x, steve_x_ratio):
		# Beim Ausweichen in Laufrichtung schauen, Walk-Animation an.
		steve_facing = 1.0 if next_x > steve_x_ratio else -1.0
		steve_x_ratio = next_x
		if steve_anim and steve_anim.current_animation != "walk":
			steve_anim.play("walk")
		_place_steve(size)
	else:
		# Im Stand dem Pferd zugewandt (er passt ja auf es auf).
		var horse_center_x := (horse_span.x + horse_span.y) * 0.5
		steve_facing = 1.0 if horse_center_x >= steve_center_x else -1.0
		if steve_anim and steve_anim.current_animation == "walk":
			steve_anim.play("RESET")
			steve_anim.advance(0.0)
		_place_steve(size)


func _place_steve(size: Vector2) -> void:
	if steve_root == null:
		return

	# Same 1/Z ground projection as the horse, with Steve's own real height.
	var distance_m := lerpf(FAR_DISTANCE_M, NEAR_DISTANCE_M, STEVE_DEPTH_T)
	var inverse_depth_gain := FAR_DISTANCE_M / maxf(distance_m, 0.01)
	var foot_delta_from_horizon := (
		FAR_PROJECTED_FOOT_Y_RATIO - PERSPECTIVE_HORIZON_Y_RATIO
	) * inverse_depth_gain
	var projected_foot_y_ratio := (
		PERSPECTIVE_HORIZON_Y_RATIO + foot_delta_from_horizon
	)
	var projected_steve_height_ratio := (
		STEVE_WORLD_HEIGHT_M / CAMERA_HEIGHT_M
	) * maxf(foot_delta_from_horizon, 0.001)
	var target_steve_height_px := size.y * projected_steve_height_ratio
	var visual_scale := target_steve_height_px / STEVE_VISIBLE_SOURCE_HEIGHT_PX

	steve_root.position = Vector2(
		size.x * steve_x_ratio,
		size.y * projected_foot_y_ratio
	)
	steve_root.scale = Vector2(visual_scale * steve_facing, visual_scale)
	steve_root.z_index = int(round(STEVE_DEPTH_T * 100.0))
