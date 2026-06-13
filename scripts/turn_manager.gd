extends Node
class_name TurnManager

signal turn_started(faction_id: int)
signal turn_ended(faction_id: int)
signal round_completed(round_number: int)
signal game_over(winner_faction_id: int)

var current_faction_id: int = 1
var current_round: int = 1
var active_factions: Array[int] = [1, 2, 3, 4, 5]  # Active faction IDs
var is_player_turn: bool = true

var ships_moved_this_turn: Array[Ship] = []
var max_moves_per_turn: int = 3  # Limit moves per faction per turn

var galaxy_map: GalaxyMap  # Reference to galaxy map

func _ready() -> void:
	start_turn()

func start_turn() -> void:
	ships_moved_this_turn.clear()
	
	# Process all ships for this faction
	if galaxy_map:
		var faction_ships = galaxy_map.get_ships_by_faction(current_faction_id)
		for ship in faction_ships:
			ship.process_turn()
	
	var faction = Faction.get_faction(current_faction_id)
	is_player_turn = not faction.is_ai
	turn_started.emit(current_faction_id)
	
	# If AI turn, process after delay
	if not is_player_turn:
		await get_tree().create_timer(1.0).timeout
		process_ai_turn()

func can_ship_move(ship: Ship) -> bool:
	if ship.faction_id != current_faction_id:
		return false
	if ship in ships_moved_this_turn:
		return false
	if ships_moved_this_turn.size() >= max_moves_per_turn:
		return false
	return true

func register_ship_move(ship: Ship) -> void:
	if ship not in ships_moved_this_turn:
		ships_moved_this_turn.append(ship)

func get_moves_remaining() -> int:
	return max(0, max_moves_per_turn - ships_moved_this_turn.size())

func end_turn() -> void:
	turn_ended.emit(current_faction_id)
	
	# Process all planets
	if galaxy_map:
		for planet in galaxy_map.planets:
			planet.process_turn()
	
	# Check for win condition
	var winner = check_win_condition()
	if winner >= 0:
		game_over.emit(winner)
		return  # Stop turn progression
	
	# Move to next faction
	var current_index = active_factions.find(current_faction_id)
	if current_index >= 0:
		current_index += 1
		if current_index >= active_factions.size():
			# New round
			current_round += 1
			current_faction_id = active_factions[0]
			round_completed.emit(current_round)
		else:
			current_faction_id = active_factions[current_index]
	
	start_turn()

func process_ai_turn() -> void:
	# Simple AI: move random ships to connected planets
	if not galaxy_map:
		end_turn()
		return
	
	var ai_ships = galaxy_map.get_ships_by_faction(current_faction_id)
	var moves_made = 0
	
	for ship in ai_ships:
		if moves_made >= max_moves_per_turn:
			break
		
		if ship.current_planet and ship.current_planet.connected_planets.size() > 0:
			# Pick random connected planet
			var target = ship.current_planet.connected_planets.pick_random()
			
			# Check if battle will occur
			var move_check = galaxy_map.can_ship_move_to_planet(ship, target)
			if move_check.can_move:
				# Store defender reference before moving (if battle will occur)
				var defender_ship: Ship = null
				if move_check.will_battle:
					defender_ship = galaxy_map.get_ship_at_planet(target)
				
				# Move the ship
				if ship.move_to_planet(target):
					register_ship_move(ship)
					moves_made += 1
					
					# Wait for arrival
					await get_tree().create_timer(ship.current_lane.get_length() / ship.speed).timeout
					
					# Trigger battle if needed
					if move_check.will_battle and defender_ship and is_instance_valid(defender_ship):
						if is_instance_valid(ship) and ship.current_planet == target:
							# Get main node to trigger battle
							var main = galaxy_map.get_parent()
							if main and main.has_method("initiate_battle"):
								main.initiate_battle(ship, defender_ship, target)
								# Wait for battle to complete
								# If it's a human battle, the GUI will handle it
								# If it's AI vs AI, it resolves instantly
								if main.has_method("is_battle_screen_visible"):
									# Wait for battle screen if it's open
									while main.is_battle_screen_visible():
										await get_tree().create_timer(0.5).timeout
								else:
									await get_tree().create_timer(0.5).timeout
					
					await get_tree().create_timer(0.5).timeout
	
	# End AI turn after moves
	await get_tree().create_timer(1.0).timeout
	end_turn()

func check_win_condition() -> int:
	# Check if all planets are owned by one faction
	if not galaxy_map or galaxy_map.planets.size() == 0:
		return -1
	
	# Count planets per faction (ignore neutral planets - faction_id 0)
	var faction_planet_count: Dictionary = {}
	var total_non_neutral_planets = 0
	
	for planet in galaxy_map.planets:
		if planet.faction_id != 0:  # Not neutral
			if not faction_planet_count.has(planet.faction_id):
				faction_planet_count[planet.faction_id] = 0
			faction_planet_count[planet.faction_id] += 1
			total_non_neutral_planets += 1
	
	# If no planets are owned, no winner yet
	if total_non_neutral_planets == 0:
		return -1
	
	# Check if one faction owns all non-neutral planets
	for faction_id in faction_planet_count:
		if faction_planet_count[faction_id] == total_non_neutral_planets:
			return faction_id
	
	return -1
