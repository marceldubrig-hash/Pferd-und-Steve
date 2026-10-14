extends Node

# Prüft alle 10 Sekunden die Systemzeit, um Ressourcen zu sparen
const CHECK_INTERVAL: float = 10.0
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= CHECK_INTERVAL:
		timer = 0.0
		_check_local_time()

func _check_local_time() -> void:
	var time_dict = Time.get_datetime_dict_from_system()
	var hour = time_dict["hour"]
	
	# Tag von 06:00 bis 20:00 Uhr, ab 20:00 Uhr schaltet die Farm auf Nacht um
	var should_be_night = (hour < 6 or hour >= 20)
	
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("show_day") and main_scene.has_method("show_night"):
		if should_be_night and not main_scene.is_night:
			main_scene.show_night()
		elif not should_be_night and main_scene.is_night:
			main_scene.show_day()
