extends SceneTree

var lines: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _write() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://debug"))
	var file := FileAccess.open("res://debug/farm_cutout_movement_validation.txt", FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(lines) + "\n")


func _check(condition: bool, message: String) -> bool:
	if condition:
		lines.append("PASS: " + message)
		return true
	lines.append("FAIL: " + message)
	push_error(message)
	_write()
	quit(1)
	return false


func _run() -> void:
	root.size = Vector2i(1536, 1384)
	var packed := load("res://scenes/main.tscn") as PackedScene
	if not _check(packed != null, "main.tscn loads"):
		return
	var main := packed.instantiate()
	root.add_child(main)
	await process_frame

	var horse_root := main.get_node("HorseRoot") as Node2D
	var horse_visual := main.get_node("HorseRoot/HorseVisual") as Node2D
	var rig_space := main.get_node("HorseRoot/HorseVisual/RigSpace") as Node2D
	var rig := main.get_node("HorseRoot/HorseVisual/RigSpace/HorseCutoutRig") as Node2D

	if not _check(horse_root != null and horse_visual != null and rig_space != null and rig != null, "cutout hierarchy exists"):
		return
	if not _check(not main.has_node("HorseRoot/HorseMaster"), "legacy HorseMaster is absent"):
		return
	if not _check(absf(rig_space.scale.x - 0.701686) < 0.000001 and absf(rig_space.scale.y - 0.701686) < 0.000001, "RigSpace scale preserved"):
		return
	if not _check(absf(rig.position.y + 516.7995) < 0.0001, "ground-anchor offset preserved"):
		return

	var size := Vector2(root.size)
	main.call("set_horse_position", Vector2(size.x * 0.60, size.y * 0.565))
	var open_depth: float = main.get("horse_depth_t")
	if not _check(absf(open_depth) < 0.00001, "open rear yard still reaches depth_t 0"):
		return

	main.call("set_horse_position", Vector2(size.x * 0.20, size.y * 0.565))
	var left_obstacle_depth: float = main.get("horse_depth_t")
	if not _check(left_obstacle_depth > 0.0, "left obstacle boundary pushes horse forward"):
		return

	main.call("set_horse_position", Vector2(size.x * 0.95, size.y * 0.565))
	var right_obstacle_depth: float = main.get("horse_depth_t")
	if not _check(right_obstacle_depth > 0.0, "right shelter boundary pushes horse forward"):
		return

	main.call("set_horse_position", Vector2(-500.0, size.y * 2.0))
	if not _check(absf(float(main.get("horse_x_ratio"))) < 0.00001 and absf(float(main.get("horse_depth_t")) - 1.0) < 0.00001, "screen/depth clamps remain active"):
		return

	main.call("set_horse_position", Vector2(size.x * 0.50, size.y * 0.75))
	var depth: float = main.get("horse_depth_t")
	if not _check(horse_root.z_index == int(round(depth * 100.0)), "HorseRoot world z follows depth"):
		return
	if not _check(horse_root.scale.x > 0.0 and absf(horse_root.scale.x - horse_root.scale.y) < 0.000001, "perspective scale remains uniform on HorseRoot"):
		return

	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = Vector2(size.x * 0.68, size.y * 0.72)
	main.call("_unhandled_input", touch)
	if not _check(absf(float(main.get("horse_x_ratio")) - 0.68) < 0.001, "screen touch still retargets the horse"):
		return

	var drag_left := InputEventScreenDrag.new()
	drag_left.index = 0
	drag_left.position = Vector2(size.x * 0.30, size.y * 0.72)
	main.call("_unhandled_input", drag_left)
	if not _check(horse_visual.scale.x < 0.0 and absf(horse_visual.scale.y - 1.0) < 0.000001, "drag left flips the complete HorseVisual"):
		return

	var drag_right := InputEventScreenDrag.new()
	drag_right.index = 0
	drag_right.position = Vector2(size.x * 0.75, size.y * 0.72)
	main.call("_unhandled_input", drag_right)
	if not _check(horse_visual.scale.x > 0.0 and absf(horse_visual.scale.y - 1.0) < 0.000001, "drag right restores original HorseVisual direction"):
		return

	lines.append("open_depth=%.9f" % open_depth)
	lines.append("left_obstacle_depth=%.9f" % left_obstacle_depth)
	lines.append("right_obstacle_depth=%.9f" % right_obstacle_depth)
	lines.append("final_depth=%.9f" % float(main.get("horse_depth_t")))
	lines.append("final_z_index=%d" % horse_root.z_index)
	lines.append("RESULT: SUCCESS")
	_write()
	print("\n".join(lines))
	quit(0)
