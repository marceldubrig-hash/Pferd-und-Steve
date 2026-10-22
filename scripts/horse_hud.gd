extends Control

@onready var hunger_label: Label = Label.new()
@onready var hygiene_label: Label = Label.new()
@onready var mood_label: Label = Label.new()
@onready var money_label: Label = Label.new()
@onready var feed_button: Button = Button.new()
@onready var clean_button: Button = Button.new()

func _ready() -> void:
	# Layout und minimalistischer South-Park / Interdimensional-Cable-Look
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(30, 30)
	vbox.add_child(hunger_label)
	vbox.add_child(hygiene_label)
	vbox.add_child(mood_label)
	vbox.add_child(money_label)
	add_child(vbox)
	
	# Stil für die Labels (gut lesbar auf der bunten Farm)
	for child in vbox.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", Color.WHITE)
			child.add_theme_color_override("font_outline_color", Color.BLACK)
			child.add_theme_constant_override("outline_size", 4)
	
	# Aktions-Buttons unten links als dicke Touch-Ziele
	var hbox = HBoxContainer.new()
	hbox.anchor_top = 1.0
	hbox.anchor_bottom = 1.0
	hbox.offset_left = 30
	hbox.offset_top = -120
	hbox.offset_bottom = -40
	hbox.add_theme_constant_override("separation", 20)
	add_child(hbox)
	
	feed_button.text = "🍏 Füttern"
	clean_button.text = "✨ Waschen"
	for button in [feed_button, clean_button]:
		button.custom_minimum_size = Vector2(220, 80)
		hbox.add_child(button)
	
	feed_button.pressed.connect(_on_feed_pressed)
	clean_button.pressed.connect(_on_clean_pressed)
	
	# Build-Version klein oben rechts: jeder Device-Screenshot beweist die Version
	var version_label := Label.new()
	version_label.text = "Build " + str(ProjectSettings.get_setting("application/config/version", "dev"))
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	version_label.anchor_left = 1.0
	version_label.anchor_right = 1.0
	version_label.offset_left = -400
	version_label.offset_right = -30
	version_label.offset_top = 30
	version_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	version_label.add_theme_color_override("font_outline_color", Color.BLACK)
	version_label.add_theme_constant_override("outline_size", 4)
	add_child(version_label)
	
	if HorseStats:
		HorseStats.connect("stats_changed", Callable(self, "_on_stats_changed"))
		_on_stats_changed()

func _on_feed_pressed() -> void:
	if HorseStats:
		HorseStats.feed(25.0)

func _on_clean_pressed() -> void:
	if HorseStats:
		HorseStats.clean(25.0)

func _on_stats_changed() -> void:
	if not HorseStats:
		return
		
	hunger_label.text = "🍏 Hunger: %d%%" % int(HorseStats.hunger)
	hygiene_label.text = "✨ Hygiene: %d%%" % int(HorseStats.hygiene)
	money_label.text = "🪙 Huf-Taler: %d" % HorseStats.money
	
	var mood_text = "Glücklich"
	match HorseStats.current_mood:
		HorseStats.Mood.NEUTRAL: mood_text = "Geht so"
		HorseStats.Mood.SAD: mood_text = "Deprimiert (Steve weint wieder)"
		HorseStats.Mood.ANGRY: mood_text = "Wütend"
		HorseStats.Mood.SCARED: mood_text = "Panisch (Waschbären-Sekte)"
		HorseStats.Mood.CONFUSED: mood_text = "Verwirrt"
		HorseStats.Mood.EXISTENTIAL_DREAD: mood_text = "Existenzielle Krise"
	
	mood_label.text = "🧠 Mood: %s" % mood_text
