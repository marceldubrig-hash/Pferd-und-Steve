extends Node

signal stats_changed

# Basis-Parameter (0.0 bis 100.0)
var hunger: float = 80.0
var hygiene: float = 90.0
var fatigue: float = 10.0
var health: float = 100.0
var money: int = 50 # Huf-Taler für den späteren Shop

enum Mood { HAPPY, NEUTRAL, SAD, ANGRY, SCARED, CONFUSED, EXISTENTIAL_DREAD }
var current_mood: Mood = Mood.HAPPY

const TICK_RATE: float = 1.0 
var time_accumulator: float = 0.0

func _process(delta: float) -> void:
	time_accumulator += delta
	if time_accumulator >= TICK_RATE:
		time_accumulator = 0.0
		_update_stats(TICK_RATE)

func _update_stats(dt: float) -> void:
	# Hunger sinkt kontinuierlich über den Tag
	hunger = maxf(0.0, hunger - (2.0 / 60.0) * dt)
	
	# Hygiene sinkt langsam durch den Alltag auf der Farm
	hygiene = maxf(0.0, hygiene - (1.0 / 60.0) * dt)
	
	# Müdigkeit baut sich im Laufe des Tages auf
	fatigue = minf(100.0, fatigue + (1.5 / 60.0) * dt)

	# Gesundheit leidet massiv, wenn Werte in den Keller rasseln
	var base_avg = (hunger + hygiene + (100.0 - fatigue)) / 3.0
	if hunger < 20.0 or hygiene < 20.0:
		base_avg -= 25.0
	health = clampf(base_avg, 0.0, 100.0)

	_evaluate_mood()
	emit_signal("stats_changed")

func _evaluate_mood() -> void:
	if health < 25.0 or hunger < 10.0:
		current_mood = Mood.EXISTENTIAL_DREAD
	elif fatigue > 85.0 and hygiene < 25.0:
		current_mood = Mood.ANGRY
	elif fatigue > 70.0:
		current_mood = Mood.SAD
	elif hunger < 40.0:
		current_mood = Mood.CONFUSED
	elif hygiene < 40.0:
		current_mood = Mood.SCARED
	elif health > 80.0 and hunger > 75.0:
		current_mood = Mood.HAPPY
	else:
		current_mood = Mood.NEUTRAL

func feed(amount: float) -> void:
	hunger = minf(100.0, hunger + amount)
	emit_signal("stats_changed")

func clean(amount: float) -> void:
	hygiene = minf(100.0, hygiene + amount)
	emit_signal("stats_changed")
