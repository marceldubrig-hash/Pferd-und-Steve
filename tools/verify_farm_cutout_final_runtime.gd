extends SceneTree

const OUT := "res://build/farm_final_runtime.txt"
var lines: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _finish(code: int) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build"))
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(lines) + "\n")
	print("\n".join(lines))
	quit(code)


func _check(condition: bool, message: String) -> bool:
	if condition:
		lines.append("PASS: " + message)
		return true
	lines.append("FAIL: " + message)
	push_error(message)
	_finish(1)
	return false


func _run() -> void:
	root.size = Vector2i(1536, 1384)
	var packed := load("res://scenes/main.tscn") as PackedScene
	if not _check(packed != null, "main.tscn loads at runtime"):
		return
	var main := packed.instantiate()
	root.add_child(main)
	await process_frame

	if not _check(not main.has_node("HorseRoot/HorseMaster"), "legacy master absent at runtime"):
		return
	var horse_root := main.get_node_or_null("HorseRoot") as Node2D
	var horse_visual := main.get_node_or_null("HorseRoot/HorseVisual") as Node2D
	var rig_space := main.get_node_or_null("HorseRoot/HorseVisual/RigSpace") as Node2D
	var rig := main.get_node_or_null("HorseRoot/HorseVisual/RigSpace/HorseCutoutRig") as Node2D
	if not _check(horse_root != null and horse_visual != null and rig_space != null and rig != null, "farm cutout hierarchy instantiated"):
		return

	var jaw := rig.get_node_or_null("AnimationPlayer") as AnimationPlayer
	var tail := rig.get_node_or_null("TailAnimationPlayer") as AnimationPlayer
	var walk := rig.get_node_or_null("WalkAnimationPlayer") as AnimationPlayer
	if not _check(jaw != null and tail != null and walk != null, "all three AnimationPlayers instantiated"):
		return
	if not _check(jaw.has_animation(&"jaw_test") and tail.has_animation(&"tail_test") and walk.has_animation(&"walk_test"), "jaw/tail/walk animations available at runtime"):
		return

	main.call("set_horse_position", Vector2(921.6, 957.129))
	var depth: float = main.get("horse_depth_t")
	if not _check(horse_root.scale.x > 0.0 and horse_root.z_index == int(round(depth * 100.0)), "farm perspective and world-z applied to HorseRoot"):
		return

	main.call("set_horse_facing_right", false)
	if not _check(horse_visual.scale.x < 0.0, "LEFT flips complete HorseVisual at runtime"):
		return
	main.call("set_horse_facing_right", true)
	if not _check(horse_visual.scale.x > 0.0, "RIGHT restores original HorseVisual at runtime"):
		return

	if not _check(absf(rig_space.scale.x - 0.701686) < 0.000001, "RigSpace base scale intact at runtime"):
		return
	if not _check(absf(rig.position.y + 516.7995) < 0.0001, "ground-anchor offset intact at runtime"):
		return

	lines.append("RUNTIME_RESULT: SUCCESS")
	_finish(0)
