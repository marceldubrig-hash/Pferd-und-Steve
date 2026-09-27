extends Node2D

const FARM_DAY := "res://assets/backgrounds/farm_day_v01.png"
const FARM_NIGHT := "res://assets/backgrounds/farm_night_v01.png"
const HORSE_MASTER := "res://assets/horse/horse_master_standing_v01.png"

const HORSE_BASE_SCALE := 0.28
const PLAYFIELD_Y_MIN_RATIO := 0.43
const PLAYFIELD_Y_MAX_RATIO := 0.92

@onready var background: Sprite2D = $Background
@onready var horse_root: Node2D = $HorseRoot
@onready var horse_master: Sprite2D = $HorseRoot/HorseMaster

var is_night := false
var mouse_dragging := false


func _ready() -> void:
	get_viewport().size_changed.connect(_layout_scene)
	_load_texture_if_available(background, FARM_DAY)
	_load_texture_if_available(horse_master, HORSE_MASTER)
	_layout_scene()
	_place_horse_initially()
	_apply_depth_scale()


func _process(_delta: float) -> void:
	_apply_depth_scale()


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
	horse_master.flip_h = not facing_right


func set_horse_position(new_position: Vector2) -> void:
	var size := get_viewport_rect().size
	var min_y := size.y * PLAYFIELD_Y_MIN_RATIO
	var max_y := size.y * PLAYFIELD_Y_MAX_RATIO

	horse_root.position = Vector2(
		clampf(new_position.x, 0.0, size.x),
		clampf(new_position.y, min_y, max_y)
	)
	_apply_depth_scale()


func _move_horse_to(target_position: Vector2) -> void:
	if absf(target_position.x - horse_root.position.x) > 1.0:
		set_horse_facing_right(target_position.x > horse_root.position.x)
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

	if horse_root.position != Vector2.ZERO:
		set_horse_position(horse_root.position)


func _place_horse_initially() -> void:
	var size := get_viewport_rect().size
	if horse_root.position == Vector2.ZERO:
		set_horse_position(Vector2(size.x * 0.5, size.y * 0.68))


func _apply_depth_scale() -> void:
	var size := get_viewport_rect().size
	var min_y := size.y * PLAYFIELD_Y_MIN_RATIO
	var max_y := maxf(size.y * PLAYFIELD_Y_MAX_RATIO, min_y + 1.0)
	var depth_t := clampf(inverse_lerp(min_y, max_y, horse_root.position.y), 0.0, 1.0)
	var depth_scale := lerpf(0.75, 1.25, depth_t)

	horse_root.scale = Vector2.ONE * HORSE_BASE_SCALE * depth_scale
	horse_root.z_index = int(round(horse_root.position.y))
