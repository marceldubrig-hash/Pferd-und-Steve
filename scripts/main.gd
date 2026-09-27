extends Node2D

const FARM_DAY := "res://assets/backgrounds/farm_day_v01.png"
const FARM_NIGHT := "res://assets/backgrounds/farm_night_v01.png"
const HORSE_MASTER := "res://assets/horse/horse_master_standing_v01.png"

@onready var background: Sprite2D = $Background
@onready var horse_root: Node2D = $HorseRoot
@onready var horse_master: Sprite2D = $HorseRoot/HorseMaster

var is_night := false

func _ready() -> void:
	_load_texture_if_available(background, FARM_DAY)
	_load_texture_if_available(horse_master, HORSE_MASTER)
	_place_horse_initially()
	_apply_depth_scale()


func _process(_delta: float) -> void:
	_apply_depth_scale()


func _load_texture_if_available(target: Sprite2D, path: String) -> void:
	if ResourceLoader.exists(path):
		target.texture = load(path)
	else:
		push_warning("Asset fehlt noch im entpackten Runtime-Pfad: %s" % path)


func show_day() -> void:
	is_night = false
	_load_texture_if_available(background, FARM_DAY)


func show_night() -> void:
	is_night = true
	_load_texture_if_available(background, FARM_NIGHT)


func set_horse_facing_right(facing_right: bool) -> void:
	# Canon: RIGHT = Original, LEFT = horizontal gespiegelt.
	horse_master.flip_h = not facing_right


func set_horse_position(new_position: Vector2) -> void:
	horse_root.position = new_position
	_apply_depth_scale()


func _place_horse_initially() -> void:
	var size := get_viewport_rect().size
	if horse_root.position == Vector2.ZERO:
		horse_root.position = Vector2(size.x * 0.5, size.y * 0.63)


func _apply_depth_scale() -> void:
	var viewport_height := maxf(get_viewport_rect().size.y, 1.0)
	var normalized_y := clampf(horse_root.position.y / viewport_height, 0.0, 1.0)
	var scale_factor := lerpf(0.70, 1.30, normalized_y)
	horse_root.scale = Vector2.ONE * scale_factor
