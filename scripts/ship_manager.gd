extends Node
class_name ShipManager

# Ship systems and capabilities
var energy_capacity: int = 100
var current_energy: int = 100
var defence_level: int = 0
var weapon_level: int = 0
var energy_systems: int = 0

# System costs
const DEFENCE_COST: int = 40
const WEAPON_COST: int = 50
const ENERGY_SYSTEM_COST: int = 35

# Combat stats
var shield_strength: int = 0
var attack_power: int = 10  # Base attack
var max_energy_bonus: int = 0

signal systems_changed()

func _init() -> void:
	pass

func setup(ship_faction_id: int) -> void:
	# Initialize with basic values
	if ship_faction_id != 0:
		current_energy = 100
		energy_capacity = 100
		attack_power = 10
	else:
		current_energy = 50
		energy_capacity = 50
		attack_power = 5

func can_afford(cost: int) -> bool:
	return current_energy >= cost

func add_defence_system() -> bool:
	if can_afford(DEFENCE_COST):
		current_energy -= DEFENCE_COST
		defence_level += 1
		update_stats()
		systems_changed.emit()
		return true
	return false

func add_weapon_system() -> bool:
	if can_afford(WEAPON_COST):
		current_energy -= WEAPON_COST
		weapon_level += 1
		update_stats()
		systems_changed.emit()
		return true
	return false

func add_energy_system() -> bool:
	if can_afford(ENERGY_SYSTEM_COST):
		current_energy -= ENERGY_SYSTEM_COST
		energy_systems += 1
		update_stats()
		systems_changed.emit()
		return true
	return false

func update_stats() -> void:
	# Calculate derived stats
	shield_strength = defence_level * 15
	attack_power = 10 + (weapon_level * 8)
	max_energy_bonus = energy_systems * 20
	energy_capacity = 100 + max_energy_bonus

func recharge_energy(amount: int) -> void:
	current_energy = min(current_energy + amount, energy_capacity)

func consume_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		return true
	return false

func get_combat_strength() -> int:
	return attack_power + (shield_strength / 2)

func get_status_text() -> String:
	return "Energy: %d/%d\nDefence: %d (Shield: %d)\nWeapons: %d (Attack: %d)\nEnergy Systems: %d" % [
		current_energy, energy_capacity,
		defence_level, shield_strength,
		weapon_level, attack_power,
		energy_systems
	]

func process_turn() -> void:
	# Recharge energy based on energy systems
	var recharge_amount = 5 + (energy_systems * 3)
	recharge_energy(recharge_amount)
