extends Node
class_name StatsComponent
## Flexible stat system for upgrades and character progression
## Supports multiplicative and additive modifiers with overflow protection

signal stat_changed(stat_name: String, old_value: float, new_value: float)

# Base stats dictionary
var base_stats: Dictionary = {
	"max_health": 100.0,
	"damage": 10.0,
	"speed": 200.0,
	"attack_speed": 1.0,
	"crit_chance": 0.05,  # 5%
	"crit_damage": 1.5,   # 150%
	"dash_cooldown": 1.0,
	"experience_multiplier": 1.0,
	"damage_reduction": 0.0,
	"pickup_range": 50.0
}

# Modifier storage - separate additive and multiplicative for clear upgrade stacking
var additive_modifiers: Dictionary = {}
var multiplicative_modifiers: Dictionary = {}

# Cached final values for performance
var cached_stats: Dictionary = {}
var cache_dirty: bool = true

# Overflow protection limits
const MAX_STAT_VALUE: float = 999999.0
const MIN_STAT_VALUE: float = 0.0

func _ready():
	_initialize_modifiers()
	_update_cache()

func _initialize_modifiers():
	# Initialize modifier dictionaries with empty arrays
	for stat_name in base_stats:
		additive_modifiers[stat_name] = []
		multiplicative_modifiers[stat_name] = []

func get_stat(stat_name: String) -> float:
	if not stat_name in base_stats:
		push_warning("StatsComponent: Unknown stat requested: %s" % stat_name)
		return 0.0
	
	if cache_dirty:
		_update_cache()
	
	return cached_stats.get(stat_name, base_stats[stat_name])

func set_base_stat(stat_name: String, value: float):
	if not stat_name in base_stats:
		push_warning("StatsComponent: Cannot set unknown stat: %s" % stat_name)
		return
	
	var old_value = get_stat(stat_name)
	base_stats[stat_name] = _clamp_stat_value(value)
	cache_dirty = true
	
	var new_value = get_stat(stat_name)
	if abs(new_value - old_value) > 0.001:  # Float comparison with epsilon
		stat_changed.emit(stat_name, old_value, new_value)

func add_modifier(stat_name: String, value: float, is_multiplicative: bool = false) -> int:
	if not stat_name in base_stats:
		push_warning("StatsComponent: Cannot add modifier to unknown stat: %s" % stat_name)
		return -1
	
	var old_stat_value = get_stat(stat_name)
	
	if is_multiplicative:
		# Store as multiplier (1.0 = no change, 1.1 = +10%, 0.9 = -10%)
		multiplicative_modifiers[stat_name].append(value)
	else:
		# Store as additive value
		additive_modifiers[stat_name].append(value)
	
	cache_dirty = true
	
	var new_stat_value = get_stat(stat_name)
	if abs(new_stat_value - old_stat_value) > 0.001:
		stat_changed.emit(stat_name, old_stat_value, new_stat_value)
	
	# Return modifier ID (index) for potential removal
	if is_multiplicative:
		return multiplicative_modifiers[stat_name].size() - 1
	else:
		return additive_modifiers[stat_name].size() - 1

func remove_modifier(stat_name: String, modifier_id: int, is_multiplicative: bool = false) -> bool:
	if not stat_name in base_stats:
		return false
	
	var modifier_array = multiplicative_modifiers[stat_name] if is_multiplicative else additive_modifiers[stat_name]
	
	if modifier_id < 0 or modifier_id >= modifier_array.size():
		return false
	
	var old_stat_value = get_stat(stat_name)
	modifier_array.remove_at(modifier_id)
	cache_dirty = true
	
	var new_stat_value = get_stat(stat_name)
	if abs(new_stat_value - old_stat_value) > 0.001:
		stat_changed.emit(stat_name, old_stat_value, new_stat_value)
	
	return true

func _update_cache():
	for stat_name in base_stats:
		var final_value = base_stats[stat_name]
		
		# Apply additive modifiers first
		for modifier in additive_modifiers[stat_name]:
			final_value += modifier
		
		# Apply multiplicative modifiers
		for multiplier in multiplicative_modifiers[stat_name]:
			final_value *= multiplier
		
		# Clamp to prevent overflow/underflow
		cached_stats[stat_name] = _clamp_stat_value(final_value)
	
	cache_dirty = false

func _clamp_stat_value(value: float) -> float:
	# Special handling for percentage-based stats
	if value >= 0.0 and value <= 1.0:
		# Likely a percentage stat like crit_chance or damage_reduction
		return clampf(value, 0.0, 1.0)
	else:
		# Regular stat with overflow protection
		return clampf(value, MIN_STAT_VALUE, MAX_STAT_VALUE)

# Convenience methods for common upgrade patterns
func add_percentage_bonus(stat_name: String, percentage: float) -> int:
	# Adds a percentage bonus (e.g., 0.15 for +15%)
	var multiplier = 1.0 + clampf(percentage, -0.9, 10.0)  # Cap bonuses
	return add_modifier(stat_name, multiplier, true)

func add_flat_bonus(stat_name: String, amount: float) -> int:
	# Adds a flat amount
	return add_modifier(stat_name, amount, false)

# Batch stat operations for upgrades
func apply_upgrade(upgrade_data: Dictionary):
	if "stat_changes" in upgrade_data:
		var changes = upgrade_data["stat_changes"]
		for stat_name in changes:
			var change_data = changes[stat_name]
			
			if "flat" in change_data:
				add_flat_bonus(stat_name, change_data["flat"])
			
			if "percentage" in change_data:
				add_percentage_bonus(stat_name, change_data["percentage"])

# Reset system for object pooling
func reset_to_defaults():
	for stat_name in base_stats:
		additive_modifiers[stat_name].clear()
		multiplicative_modifiers[stat_name].clear()
	
	cache_dirty = true

# Getters for common stats with overflow protection
func get_max_health() -> int:
	return int(get_stat("max_health"))

func get_damage() -> int:
	return maxi(1, int(get_stat("damage")))

func get_speed() -> float:
	return get_stat("speed")

func get_attack_speed() -> float:
	return maxf(0.1, get_stat("attack_speed"))  # Prevent zero/negative attack speed

func get_crit_chance() -> float:
	return clampf(get_stat("crit_chance"), 0.0, 1.0)

func get_crit_damage() -> float:
	return maxf(1.0, get_stat("crit_damage"))

func get_experience_multiplier() -> float:
	return maxf(0.1, get_stat("experience_multiplier"))

func get_damage_reduction() -> float:
	return clampf(get_stat("damage_reduction"), 0.0, 0.9)  # Cap at 90%

# Debug and inspection
func get_all_stats() -> Dictionary:
	if cache_dirty:
		_update_cache()
	return cached_stats.duplicate()

func get_stat_breakdown(stat_name: String) -> Dictionary:
	if not stat_name in base_stats:
		return {}
	
	return {
		"base_value": base_stats[stat_name],
		"additive_modifiers": additive_modifiers[stat_name].duplicate(),
		"multiplicative_modifiers": multiplicative_modifiers[stat_name].duplicate(),
		"final_value": get_stat(stat_name)
	}

func get_debug_info() -> Dictionary:
	return {
		"base_stats": base_stats.duplicate(),
		"final_stats": get_all_stats(),
		"total_modifiers": _count_total_modifiers(),
		"cache_dirty": cache_dirty
	}

func _count_total_modifiers() -> int:
	var total = 0
	for stat_name in base_stats:
		total += additive_modifiers[stat_name].size()
		total += multiplicative_modifiers[stat_name].size()
	return total