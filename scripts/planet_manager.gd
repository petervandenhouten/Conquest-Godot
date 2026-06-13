extends Node
class_name PlanetManager

# Planet resources and facilities
var energy_level: int = 0
var max_energy: int = 100
var defence_level: int = 0
var research_level: int = 0
var construction_level: int = 0

# Building costs
const DEFENCE_COST: int = 50
const RESEARCH_COST: int = 60
const ENERGY_COST: int = 40
const CONSTRUCTION_COST: int = 50

# Production per turn
var energy_per_turn: int = 10
var research_per_turn: int = 0
var defence_strength: int = 0

signal facilities_changed()

func _init() -> void:
	pass

func setup(planet_faction_id: int) -> void:
	# Initialize with basic values
	if planet_faction_id != 0:  # Not neutral
		energy_level = 50
		energy_per_turn = 10
	else:
		energy_level = 0
		energy_per_turn = 5

func process_turn() -> void:
	# Generate energy
	energy_level = min(energy_level + energy_per_turn, max_energy)
	
	# Update production rates based on facilities
	energy_per_turn = 10 + (construction_level * 5)
	research_per_turn = research_level * 3
	defence_strength = defence_level * 10

func can_afford(cost: int) -> bool:
	return energy_level >= cost

func build_defence_system() -> bool:
	if can_afford(DEFENCE_COST):
		energy_level -= DEFENCE_COST
		defence_level += 1
		facilities_changed.emit()
		return true
	return false

func build_research_system() -> bool:
	if can_afford(RESEARCH_COST):
		energy_level -= RESEARCH_COST
		research_level += 1
		facilities_changed.emit()
		return true
	return false

func build_energy_system() -> bool:
	if can_afford(ENERGY_COST):
		energy_level -= ENERGY_COST
		construction_level += 1
		facilities_changed.emit()
		return true
	return false

func get_defence_strength() -> int:
	return defence_strength

func get_research_output() -> int:
	return research_per_turn

func get_energy_production() -> int:
	return energy_per_turn

func get_status_text() -> String:
	return "Energy: %d/%d (+%d/turn)\nDefence: %d (Strength: %d)\nResearch: %d (Output: %d/turn)\nConstruction: %d" % [
		energy_level, max_energy, energy_per_turn,
		defence_level, defence_strength,
		research_level, research_per_turn,
		construction_level
	]
