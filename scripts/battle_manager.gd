extends Node
class_name BattleManager

signal battle_started()
signal battle_phase_changed(phase: String)
signal battle_resolved(winner_faction_id: int)

enum BattlePhase {
	SETUP,
	ALLOCATION,
	COMBAT,
	RESOLUTION
}

var attacker: Ship = null
var defender: Ship = null
var battle_planet: Planet = null

var attacker_faction_id: int = 0
var defender_faction_id: int = 0

# Energy allocation
var attacker_shield_energy: int = 0
var attacker_weapon_energy: int = 0
var defender_shield_energy: int = 0
var defender_weapon_energy: int = 0

var current_phase: BattlePhase = BattlePhase.SETUP

# Battle results
var winner_faction_id: int = 0
var attacker_wins: bool = false

func setup_battle(attacking_ship: Ship, defending_ship: Ship, planet: Planet) -> void:
	attacker = attacking_ship
	defender = defending_ship
	battle_planet = planet
	
	attacker_faction_id = attacking_ship.faction_id
	defender_faction_id = defending_ship.faction_id
	
	# Reset allocations
	attacker_shield_energy = 0
	attacker_weapon_energy = 0
	defender_shield_energy = 0
	defender_weapon_energy = 0
	
	current_phase = BattlePhase.SETUP
	battle_started.emit()

func get_max_allocatable_energy(ship: Ship) -> int:
	if ship and ship.ship_manager:
		return ship.ship_manager.current_energy
	return 0

func allocate_attacker_energy(shield: int, weapon: int) -> bool:
	var max_energy = get_max_allocatable_energy(attacker)
	if shield + weapon <= max_energy and shield >= 0 and weapon >= 0:
		attacker_shield_energy = shield
		attacker_weapon_energy = weapon
		return true
	return false

func allocate_defender_energy(shield: int, weapon: int) -> bool:
	var max_energy = get_max_allocatable_energy(defender)
	if shield + weapon <= max_energy and shield >= 0 and weapon >= 0:
		defender_shield_energy = shield
		defender_weapon_energy = weapon
		return true
	return false

func start_combat_phase() -> void:
	current_phase = BattlePhase.COMBAT
	battle_phase_changed.emit("COMBAT")

func calculate_combat_stats() -> Dictionary:
	var attacker_base_attack = 10
	var attacker_base_shield = 0
	var defender_base_attack = 10
	var defender_base_shield = 0
	
	# Get base stats from ship managers
	if attacker and attacker.ship_manager:
		attacker_base_attack = attacker.ship_manager.attack_power
		attacker_base_shield = attacker.ship_manager.shield_strength
	
	if defender and defender.ship_manager:
		defender_base_attack = defender.ship_manager.attack_power
		defender_base_shield = defender.ship_manager.shield_strength
	
	# Add planet defence bonus to defender
	var planet_defence_bonus = 0
	if battle_planet and battle_planet.planet_manager:
		planet_defence_bonus = battle_planet.planet_manager.get_defence_strength()
	
	# Calculate total combat values with energy allocations
	# Energy allocation: 10 energy = +5 to that stat
	var attacker_total_attack = attacker_base_attack + (attacker_weapon_energy / 10.0) * 5
	var attacker_total_shield = attacker_base_shield + (attacker_shield_energy / 10.0) * 5
	
	var defender_total_attack = defender_base_attack + (defender_weapon_energy / 10.0) * 5
	var defender_total_shield = defender_base_shield + planet_defence_bonus + (defender_shield_energy / 10.0) * 5
	
	# Combat strength = attack + (shield / 2)
	var attacker_strength = attacker_total_attack + (attacker_total_shield / 2.0)
	var defender_strength = defender_total_attack + (defender_total_shield / 2.0)
	
	return {
		"attacker_attack": attacker_total_attack,
		"attacker_shield": attacker_total_shield,
		"attacker_strength": attacker_strength,
		"defender_attack": defender_total_attack,
		"defender_shield": defender_total_shield,
		"defender_strength": defender_strength,
		"planet_bonus": planet_defence_bonus
	}

func resolve_battle() -> void:
	current_phase = BattlePhase.RESOLUTION
	
	var stats = calculate_combat_stats()
	
	var attacker_strength = stats.attacker_strength
	var defender_strength = stats.defender_strength
	
	# Determine winner based on strength comparison
	var total_strength = attacker_strength + defender_strength
	var attacker_chance = attacker_strength / total_strength if total_strength > 0 else 0.5
	
	attacker_wins = randf() < attacker_chance
	winner_faction_id = attacker_faction_id if attacker_wins else defender_faction_id
	
	# Consume the allocated energy from ships
	if attacker and attacker.ship_manager:
		attacker.ship_manager.consume_energy(attacker_shield_energy + attacker_weapon_energy)
	
	if defender and defender.ship_manager:
		defender.ship_manager.consume_energy(defender_shield_energy + defender_weapon_energy)
	
	battle_resolved.emit(winner_faction_id)

func get_winner() -> Ship:
	return attacker if attacker_wins else defender

func get_loser() -> Ship:
	return defender if attacker_wins else attacker

func cleanup_battle() -> void:
	var winner = get_winner()
	var loser = get_loser()
	
	# Destroy the losing ship
	if loser:
		loser.queue_free()
	
	# Ensure winner is stationary at the planet and claims it
	if winner and battle_planet:
		winner.is_moving = false
		winner.current_planet = battle_planet
		winner.position = battle_planet.position
		winner.target_planet = null
		winner.current_lane = null
		winner.travel_progress = 0.0
		
		# Winner claims the planet
		if battle_planet.faction_id != winner.faction_id:
			battle_planet.set_faction(winner.faction_id)
	
	# Redraw planet to reflect new occupying faction
	if battle_planet:
		battle_planet.queue_redraw()
