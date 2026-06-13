extends Node2D
class_name GalaxyMap

@export var num_planets: int = 15
@export var map_size: Vector2 = Vector2(1200, 800)
@export var min_planet_distance: float = 150.0
@export var max_connections_per_planet: int = 4

var planets: Array[Planet] = []
var lanes: Array[TravelLane] = []
var selected_planet: Planet = null
var faction_home_planets: Dictionary = {}  # faction_id -> Planet

var planet_scene: PackedScene
var lane_scene: PackedScene

signal planet_selected(planet: Planet)

func _ready() -> void:
	planet_scene = load("res://scenes/Planet.tscn")
	lane_scene = load("res://scenes/TravelLane.tscn")
	generate_galaxy()

func generate_galaxy() -> void:
	if not planet_scene or not lane_scene:
		push_error("Failed to load Planet or TravelLane scenes")
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var planet_names = [
		"Altair", "Proxima", "Sirius", "Vega", "Arcturus",
		"Rigel", "Betelgeuse", "Antares", "Aldebaran", "Spica",
		"Pollux", "Fomalhaut", "Deneb", "Regulus", "Adhara",
		"Castor", "Bellatrix", "Alnilam", "Alnitak", "Mintaka"
	]
	
	# Generate planet positions
	var positions: Array[Vector2] = []
	var attempts = 0
	while positions.size() < num_planets and attempts < 1000:
		attempts += 1
		var pos = Vector2(
			rng.randf_range(-map_size.x/2, map_size.x/2),
			rng.randf_range(-map_size.y/2, map_size.y/2)
		)
		
		var valid = true
		for existing in positions:
			if pos.distance_to(existing) < min_planet_distance:
				valid = false
				break
		
		if valid:
			positions.append(pos)
	
	# Create planets
	faction_home_planets.clear()
	var faction_ids_to_assign = [1, 2, 3, 4, 5]  # Playable factions
	
	# First, create all planets as neutral
	for i in range(positions.size()):
		var planet = planet_scene.instantiate()
		planet.position = positions[i]
		planet.planet_name = planet_names[i % planet_names.size()]
		planet.faction_id = 0  # All neutral initially
		
		$Planets.add_child(planet)
		planets.append(planet)
	
	# Create travel lanes first (so we know which planets are connected)
	create_lanes(rng)
	
	# Select home planets ensuring they are not directly connected
	var available_indices = range(planets.size())
	available_indices.shuffle()
	var selected_home_planets: Array[Planet] = []
	var used_indices: Array[int] = []
	
	# First pass: try to select planets that are not directly connected to each other
	for planet_idx in available_indices:
		if selected_home_planets.size() >= faction_ids_to_assign.size():
			break
		
		var candidate = planets[planet_idx]
		var is_connected_to_home = false
		
		# Check if this candidate is directly connected to any existing home planet
		for home_planet in selected_home_planets:
			if home_planet in candidate.connected_planets:
				is_connected_to_home = true
				break
		
		# If not directly connected to any home planet, use it
		if not is_connected_to_home:
			selected_home_planets.append(candidate)
			used_indices.append(planet_idx)
	
	# Fallback: if we don't have enough home planets, add remaining ones anyway
	if selected_home_planets.size() < faction_ids_to_assign.size():
		push_warning("Could not find %d planets without direct connections, adding remaining planets" % faction_ids_to_assign.size())
		for planet_idx in available_indices:
			if selected_home_planets.size() >= faction_ids_to_assign.size():
				break
			if planet_idx not in used_indices:
				selected_home_planets.append(planets[planet_idx])
	
	# Assign factions to selected home planets
	for i in range(min(selected_home_planets.size(), faction_ids_to_assign.size())):
		var planet = selected_home_planets[i]
		var faction_id = faction_ids_to_assign[i]
		planet.faction_id = faction_id
		faction_home_planets[faction_id] = planet
		planet.queue_redraw()  # Update visual

func create_lanes(rng: RandomNumberGenerator) -> void:
	# Simple approach: connect each planet to nearest 2-3 planets
	for planet in planets:
		var distances: Array = []
		for other in planets:
			if other != planet:
				distances.append({
					"planet": other,
					"distance": planet.position.distance_to(other.position)
				})
		
		distances.sort_custom(func(a, b): return a.distance < b.distance)
		
		var num_connections = min(rng.randi_range(2, max_connections_per_planet), distances.size())
		
		for i in range(num_connections):
			var other = distances[i].planet
			
			# Check if lane already exists
			var lane_exists = false
			for lane in lanes:
				if (lane.planet_a == planet and lane.planet_b == other) or \
				   (lane.planet_a == other and lane.planet_b == planet):
					lane_exists = true
					break
			
			if not lane_exists:
				var lane = lane_scene.instantiate()
				$Lanes.add_child(lane)
				lane.setup(planet, other)
				lanes.append(lane)

func select_planet(planet: Planet) -> void:
	if selected_planet:
		selected_planet.get_node("SelectionRing").visible = false
	
	selected_planet = planet
	selected_planet.get_node("SelectionRing").visible = true
	planet_selected.emit(planet)

func get_selected_planet() -> Planet:
	return selected_planet

func get_ships_by_faction(faction_id: int) -> Array[Ship]:
	var result: Array[Ship] = []
	for child in $Ships.get_children():
		if child is Ship and child.faction_id == faction_id:
			result.append(child)
	return result

func get_all_ships() -> Array[Ship]:
	var result: Array[Ship] = []
	for child in $Ships.get_children():
		if child is Ship:
			result.append(child)
	return result

func get_faction_home_planet(faction_id: int) -> Planet:
	return faction_home_planets.get(faction_id, null)

func get_ship_at_planet(planet: Planet) -> Ship:
	# Check if any ship is currently at this planet
	for ship in get_all_ships():
		if not ship.is_moving and ship.current_planet == planet:
			return ship
	return null

func can_ship_move_to_planet(ship: Ship, target_planet: Planet) -> Dictionary:
	# Returns {"can_move": bool, "reason": String, "will_battle": bool}
	var result = {"can_move": false, "reason": "", "will_battle": false}
	
	if not ship.current_planet:
		result.reason = "Ship has no current planet"
		return result
	
	if target_planet not in ship.current_planet.connected_planets:
		result.reason = "Planet not connected"
		return result
	
	var occupying_ship = get_ship_at_planet(target_planet)
	if occupying_ship:
		if occupying_ship.faction_id == ship.faction_id:
			result.reason = "Planet occupied by allied ship"
			return result
		else:
			# Enemy ship - can move to initiate battle
			result.can_move = true
			result.will_battle = true
			result.reason = "Will initiate battle"
			return result
	else:
		# Planet is free
		result.can_move = true
		result.reason = "OK"
		return result

func highlight_valid_lanes_for_ship(ship: Ship) -> void:
	# Clear any existing highlights first
	unhighlight_all_lanes()
	
	if not ship or not ship.current_planet:
		return
	
	# Highlight lanes to valid destinations
	for lane in ship.current_planet.connected_lanes:
		var target_planet = lane.get_other_planet(ship.current_planet)
		var move_check = can_ship_move_to_planet(ship, target_planet)
		if move_check.can_move:
			lane.highlight(move_check.will_battle)

func unhighlight_all_lanes() -> void:
	for lane in lanes:
		lane.unhighlight()
