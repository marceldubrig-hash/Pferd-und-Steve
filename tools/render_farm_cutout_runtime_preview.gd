extends SceneTree

const PREVIEW_SIZE := Vector2i(1536, 1384)
const HORSE_X_RATIO := 0.60
const OUT_DIR := "res://build/farm_preview"

var main: Node
var horse_root: Node2D
var horse_visual: Node2D
var rig: Node2D
var jaw_player: AnimationPlayer
var tail_player: AnimationPlayer
var walk_player: AnimationPlayer
var evidence: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _fail(message: String) -> void:
	push_error(message)
	evidence.append("FAIL: " + message)
	_write_evidence()
	quit(1)


func _write_evidence() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var f := FileAccess.open(OUT_DIR + "/runtime_preview.txt", FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(evidence) + "\n")


func _set_animation_frame(player: AnimationPlayer, animation: StringName, time: float) -> void:
	player.play(animation)
	player.seek(time, true)
	player.pause()


func _capture_case(label: String, depth: float, facing_right: bool, motion: bool) -> void:
	main.set("horse_x_ratio", HORSE_X_RATIO)
	main.set("horse_depth_t", depth)
	main.call("set_horse_facing_right", facing_right)
	main.call("_apply_perspective")

	if motion:
		_set_animation_frame(jaw_player, &"jaw_test", 0.15)
		_set_animation_frame(tail_player, &"tail_test", 0.30)
		_set_animation_frame(walk_player, &"walk_test", 0.28)
	else:
		_set_animation_frame(jaw_player, &"jaw_test", 0.0)
		_set_animation_frame(tail_player, &"tail_test", 0.0)
		_set_animation_frame(walk_player, &"walk_test", 0.0)

	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	var out_path := OUT_DIR + "/" + label + ".png"
	var result := image.save_png(ProjectSettings.globalize_path(out_path))
	if result != OK:
		_fail("Could not save " + out_path)
		return

	evidence.append(
		"%s depth=%.3f facing=%s motion=%s root=(%.3f,%.3f) scale=%.9f z=%d visual_x=%.1f" % [
			label,
			depth,
			"RIGHT" if facing_right else "LEFT",
			str(motion),
			horse_root.position.x,
			horse_root.position.y,
			horse_root.scale.x,
			horse_root.z_index,
			horse_visual.scale.x,
		]
	)


func _run() -> void:
	root.size = PREVIEW_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main.tscn did not load")
		return

	main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	horse_root = main.get_node_or_null("HorseRoot") as Node2D
	horse_visual = main.get_node_or_null("HorseRoot/HorseVisual") as Node2D
	rig = main.get_node_or_null("HorseRoot/HorseVisual/RigSpace/HorseCutoutRig") as Node2D
	if horse_root == null or horse_visual == null or rig == null:
		_fail("farm cutout hierarchy missing")
		return
	if main.has_node("HorseRoot/HorseMaster"):
		_fail("legacy HorseMaster unexpectedly present")
		return

	jaw_player = rig.get_node_or_null("AnimationPlayer") as AnimationPlayer
	tail_player = rig.get_node_or_null("TailAnimationPlayer") as AnimationPlayer
	walk_player = rig.get_node_or_null("WalkAnimationPlayer") as AnimationPlayer
	if jaw_player == null or tail_player == null or walk_player == null:
		_fail("one or more rig AnimationPlayers missing")
		return

	evidence.append("viewport=%dx%d" % [PREVIEW_SIZE.x, PREVIEW_SIZE.y])
	evidence.append("rig_players=AnimationPlayer,TailAnimationPlayer,WalkAnimationPlayer")
	evidence.append("mid_motion_times=jaw:0.15 tail:0.30 walk:0.28")

	await _capture_case("01_far_right", 0.0, true, false)
	await _capture_case("02_far_left", 0.0, false, false)
	await _capture_case("03_mid_right_motion", 0.5, true, true)
	await _capture_case("04_mid_left_motion", 0.5, false, true)
	await _capture_case("05_near_right", 1.0, true, false)
	await _capture_case("06_near_left", 1.0, false, false)

	evidence.append("RESULT: SUCCESS")
	_write_evidence()
	print("\n".join(evidence))
	quit(0)
