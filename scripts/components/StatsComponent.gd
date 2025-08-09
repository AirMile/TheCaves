extends Node
class_name StatsComponent

signal stat_changed(stat_name: String, old_value: float, new_value: float)
signal stat_modifier_added(stat_name: String, modifier_id: String, amount: float)
signal stat_modifier_removed(stat_name: String, modifier_id: String)

@export var base_stats: Dictionary = {
	"max_health": 100.0,
	"damage": 10.0,
	"speed": 200.0,
	"fire_rate": 1.0,
	"critical_chance": 0.05,
	"critical_multiplier": 2.0,
	"experience_multiplier": 1.0,
	"pickup_range": 100.0
}

var current_stats: Dictionary = {}
var stat_modifiers: Dictionary = {}

func _ready():
	_initialize_stats()
	
	if OS.is_debug_build():
		print("[StatsComponent] Initialized with base stats: %s" % str(base_stats))

func _initialize_stats():
	current_stats = base_stats.duplicate()
	for stat_name in base_stats:
		stat_modifiers[stat_name] = {}

func get_stat(stat_name: String) -> float:
	return current_stats.get(stat_name, 0.0)

func set_base_stat(stat_name: String, value: float):
	if not base_stats.has(stat_name):
		base_stats[stat_name] = value
		current_stats[stat_name] = value
		stat_modifiers[stat_name] = {}
	else:
		var old_value = current_stats[stat_name]
		base_stats[stat_name] = value
		_recalculate_stat(stat_name)
		
		if current_stats[stat_name] != old_value:
			stat_changed.emit(stat_name, old_value, current_stats[stat_name])

func add_stat_modifier(stat_name: String, modifier_id: String, amount: float, is_percentage: bool = false):
	if not stat_modifiers.has(stat_name):
		stat_modifiers[stat_name] = {}
	
	var modifier_data = {
		"amount": amount,
		"is_percentage": is_percentage
	}
	
	var old_value = current_stats.get(stat_name, 0.0)
	stat_modifiers[stat_name][modifier_id] = modifier_data
	
	_recalculate_stat(stat_name)
	
	stat_modifier_added.emit(stat_name, modifier_id, amount)
	
	if current_stats[stat_name] != old_value:
		stat_changed.emit(stat_name, old_value, current_stats[stat_name])

func remove_stat_modifier(stat_name: String, modifier_id: String):
	if not stat_modifiers.has(stat_name) or not stat_modifiers[stat_name].has(modifier_id):
		return
	
	var old_value = current_stats.get(stat_name, 0.0)
	stat_modifiers[stat_name].erase(modifier_id)
	
	_recalculate_stat(stat_name)
	
	stat_modifier_removed.emit(stat_name, modifier_id)
	
	if current_stats[stat_name] != old_value:
		stat_changed.emit(stat_name, old_value, current_stats[stat_name])

func _recalculate_stat(stat_name: String):
	if not base_stats.has(stat_name):
		return
	
	var base_value = base_stats[stat_name]
	var flat_modifiers = 0.0
	var percentage_modifiers = 0.0
	
	for modifier_data in stat_modifiers[stat_name].values():
		if modifier_data.is_percentage:
			percentage_modifiers += modifier_data.amount
		else:
			flat_modifiers += modifier_data.amount
	
	var final_value = (base_value + flat_modifiers) * (1.0 + percentage_modifiers)
	current_stats[stat_name] = max(0.0, final_value)

func has_stat_modifier(stat_name: String, modifier_id: String) -> bool:
	return stat_modifiers.has(stat_name) and stat_modifiers[stat_name].has(modifier_id)

func get_stat_modifiers(stat_name: String) -> Dictionary:
	return stat_modifiers.get(stat_name, {}).duplicate()

func clear_all_modifiers():
	var stats_to_update = []
	
	for stat_name in stat_modifiers:
		if stat_modifiers[stat_name].size() > 0:
			stats_to_update.append(stat_name)
			stat_modifiers[stat_name].clear()
	
	for stat_name in stats_to_update:
		var old_value = current_stats[stat_name]
		_recalculate_stat(stat_name)
		
		if current_stats[stat_name] != old_value:
			stat_changed.emit(stat_name, old_value, current_stats[stat_name])

func clear_stat_modifiers(stat_name: String):
	if not stat_modifiers.has(stat_name):
		return
	
	var old_value = current_stats.get(stat_name, 0.0)
	stat_modifiers[stat_name].clear()
	_recalculate_stat(stat_name)
	
	if current_stats[stat_name] != old_value:
		stat_changed.emit(stat_name, old_value, current_stats[stat_name])

func multiply_stat(stat_name: String, multiplier: float, modifier_id: String = ""):
	if modifier_id.is_empty():
		modifier_id = "temp_multiply_%d" % Time.get_ticks_msec()
	
	add_stat_modifier(stat_name, modifier_id, multiplier - 1.0, true)

func get_all_stats() -> Dictionary:
	return current_stats.duplicate()

func get_base_stats() -> Dictionary:
	return base_stats.duplicate()

func copy_stats_from(other_stats: StatsComponent):
	base_stats = other_stats.get_base_stats()
	_initialize_stats()

func get_stat_total_modifier(stat_name: String) -> Dictionary:
	var flat_total = 0.0
	var percentage_total = 0.0
	
	if stat_modifiers.has(stat_name):
		for modifier_data in stat_modifiers[stat_name].values():
			if modifier_data.is_percentage:
				percentage_total += modifier_data.amount
			else:
				flat_total += modifier_data.amount
	
	return {
		"flat": flat_total,
		"percentage": percentage_total
	}