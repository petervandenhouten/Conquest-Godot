extends Node2D

var camera: Camera2D
var galaxy_map: GalaxyMap
var turn_manager: TurnManager
var selected_ship: Ship = null
var ship_scene: PackedScene
var planet_screen: PlanetScreen = null
var planet_screen_scene: PackedScene
var ship_screen: ShipScreen = null
var ship_screen_scene: PackedScene
var battle_screen: BattleScreen = null
var battle_screen_scene: PackedScene
var battle_manager: BattleManager = null
var game_over_screen: GameOverScreen = null
var game_over_screen_scene: PackedScene

func _ready() -> void:
	camera = $Camera2D
	galaxy_map = $GalaxyMap
	ship_scene = load("res://scenes/Ship.tscn")
	planet_screen_scene = load("res://scenes/PlanetScreen.tscn")
	ship_screen_scene = load("res://scenes/ShipScreen.tscn")
	battle_screen_scene = load("res://scenes/BattleScreen.tscn")
	game_over_screen_scene = load("res://scenes/GameOverScreen.tscn")
	
	if not ship_scene:
		push_error("Failed to load Ship.tscn")
		return
	
	if not planet_screen_scene:
		push_error("Failed to load PlanetScreen.tscn")
		return
	
	if not ship_screen_scene:
		push_error("Failed to load ShipScreen.tscn")
		return
	
	if not battle_screen_scene:
		push_error("Failed to load BattleScreen.tscn")
		return
	
	if not game_over_screen_scene:
		push_error("Failed to load GameOverScreen.tscn")
		return
	
	# Initialize planet screen
	planet_screen = planet_screen_scene.instantiate()
	$UI.add_child(planet_screen)
	planet_screen.return_to_galaxy.connect(_on_planet_screen_return)
	
	# Initialize ship screen
	ship_screen = ship_screen_scene.instantiate()
	$UI.add_child(ship_screen)
	ship_screen.return_to_galaxy.connect(_on_ship_screen_return)
	
	# Initialize battle screen
	battle_screen = battle_screen_scene.instantiate()
	$UI.add_child(battle_screen)
	battle_screen.battle_complete.connect(_on_battle_complete)
	
	# Initialize game over screen
	game_over_screen = game_over_screen_scene.instantiate()
	$UI.add_child(game_over_screen)
	game_over_screen.return_to_menu.connect(_on_game_over_return)
	
	# Initialize battle manager
	battle_manager = BattleManager.new()
	add_child(battle_manager)
	
	if galaxy_map:
		galaxy_map.planet_selected.connect(_on_planet_selected)
	
	# Spawn some test ships
	await get_tree().create_timer(0.5).timeout
	spawn_test_ships()
	
	# Connect end turn button first
	if $UI/TopBar/EndTurnButton:
		$UI/TopBar/EndTurnButton.pressed.connect(_on_end_turn_pressed)
		$UI/TopBar/EndTurnButton.visible = true  # Start visible, will be managed by turn system
	
	# Initialize turn manager after UI is ready
	turn_manager = TurnManager.new()
	turn_manager.galaxy_map = galaxy_map
	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.turn_ended.connect(_on_turn_ended)
	turn_manager.game_over.connect(_on_game_over)
	add_child(turn_manager)  # This will trigger _ready() and emit turn_started signal

func spawn_test_ships() -> void:
	if not galaxy_map or galaxy_map.planets.size() == 0 or not ship_scene:
		return
	
	# Spawn ships for each faction at their home planet
	var factions_to_spawn = [
		{"id": 1, "count": 3},  # Player
		{"id": 2, "count": 2},  # Red
		{"id": 3, "count": 2},  # Green
		{"id": 4, "count": 2},  # Purple
		{"id": 5, "count": 2}   # Yellow
	]
	
	for faction_data in factions_to_spawn:
		var faction_id = faction_data.id
		var ship_count = faction_data.count
		var home_planet = galaxy_map.get_faction_home_planet(faction_id)
		
		if not home_planet:
			push_warning("No home planet found for faction %d" % faction_id)
			continue
		
		for i in range(ship_count):
			var ship = ship_scene.instantiate()
			ship.faction_id = faction_id
			galaxy_map.get_node("Ships").add_child(ship)
			ship.set_at_planet(home_planet)
			ship.position += Vector2(randf_range(-30, 30), randf_range(-30, 30))

func _unhandled_input(event: InputEvent) -> void:
	# Camera pan with right-click drag
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		camera.position -= event.relative

	# Camera zoom
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 0.9

func _on_planet_selected(planet: Planet) -> void:
	# Update UI
	$UI/InfoPanel.visible = true
	$UI/InfoPanel/PlanetName.text = "Planet: " + planet.planet_name
	
	var faction = Faction.get_faction(planet.faction_id)
	$UI/InfoPanel/FactionLabel.text = "Faction: " + faction.name
	$UI/InfoPanel/ConnectionsLabel.text = "Connections: " + str(planet.connected_planets.size())
	
	# Show if planet has a ship
	var ship_at_planet = galaxy_map.get_ship_at_planet(planet)
	if ship_at_planet:
		var ship_faction = Faction.get_faction(ship_at_planet.faction_id)
		$UI/InfoPanel/ConnectionsLabel.text += "\nOccupied by: " + ship_faction.name
	
	# If ship selected and it's player's turn, try to move
	if selected_ship and turn_manager:
		var ship_faction = Faction.get_faction(selected_ship.faction_id)
		if not ship_faction.is_ai:
			if turn_manager.can_ship_move(selected_ship):
				# Check if ship can move to this planet
				var move_check = galaxy_map.can_ship_move_to_planet(selected_ship, planet)
				if move_check.can_move:
					# Store defender reference BEFORE attacker moves (if battle will occur)
					var defender_ship: Ship = null
					if move_check.will_battle:
						defender_ship = galaxy_map.get_ship_at_planet(planet)
					
					# Clear highlights before moving
					galaxy_map.unhighlight_all_lanes()
					if selected_ship.move_to_planet(planet):
						turn_manager.register_ship_move(selected_ship)
						if move_check.will_battle and defender_ship:
							# Battle will occur when ship arrives
							$UI/TopBar/SystemLabel.text = "Moving to initiate battle!"
							# Wait for ship to arrive
							await get_tree().create_timer(selected_ship.current_lane.get_length() / selected_ship.speed).timeout
							# Check that both ships still exist and attacker arrived
							if selected_ship and is_instance_valid(selected_ship) and defender_ship and is_instance_valid(defender_ship):
								if selected_ship.current_planet == planet:
									initiate_battle(selected_ship, defender_ship, planet)
						else:
							$UI/TopBar/SystemLabel.text = "Ship moved"
						update_turn_ui()
				else:
					$UI/TopBar/SystemLabel.text = move_check.reason
			else:
				if turn_manager.get_moves_remaining() <= 0:
					$UI/TopBar/SystemLabel.text = "No moves remaining - End turn"
				else:
					$UI/TopBar/SystemLabel.text = "Ship already moved this turn"

func select_ship(ship: Ship) -> void:
	if selected_ship:
		selected_ship.get_node("SelectionIndicator").visible = false
	
	selected_ship = ship
	selected_ship.get_node("SelectionIndicator").visible = true
	
	# Highlight valid lanes for human players
	if galaxy_map:
		var ship_faction = Faction.get_faction(ship.faction_id)
		if not ship_faction.is_ai and turn_manager and turn_manager.can_ship_move(ship):
			galaxy_map.highlight_valid_lanes_for_ship(ship)
			$UI/TopBar/SystemLabel.text = "SHIP SELECTED - Click connected planet to move"
		else:
			galaxy_map.unhighlight_all_lanes()
			if turn_manager and not turn_manager.can_ship_move(ship):
				$UI/TopBar/SystemLabel.text = "SHIP SELECTED - Already moved this turn"
			else:
				$UI/TopBar/SystemLabel.text = "SHIP SELECTED"

func _on_turn_started(faction_id: int) -> void:
	# Reset all ships for this faction
	if galaxy_map:
		var ships = galaxy_map.get_ships_by_faction(faction_id)
		for ship in ships:
			ship.reset_turn_state()
	
	update_turn_ui()
	
	var faction = Faction.get_faction(faction_id)
	if not faction.is_ai:
		$UI/TopBar/EndTurnButton.visible = true
	else:
		$UI/TopBar/EndTurnButton.visible = false

func _on_turn_ended(faction_id: int) -> void:
	if selected_ship and selected_ship.faction_id == faction_id:
		selected_ship.get_node("SelectionIndicator").visible = false
		selected_ship = null
	
	# Clear lane highlights when turn ends
	if galaxy_map:
		galaxy_map.unhighlight_all_lanes()

func _on_end_turn_pressed() -> void:
	if turn_manager and turn_manager.is_player_turn:
		turn_manager.end_turn()

func update_turn_ui() -> void:
	if not turn_manager:
		return
	
	var faction = Faction.get_faction(turn_manager.current_faction_id)
	var moves_left = turn_manager.get_moves_remaining()
	$UI/TopBar/TurnLabel.text = "Turn: %s | Moves: %d/%d" % [faction.name, moves_left, turn_manager.max_moves_per_turn]

func initiate_battle(attacker: Ship, defender: Ship, planet: Planet) -> void:
	if not battle_manager:
		return
	
	# Check if any human players are involved
	var attacker_faction = Faction.get_faction(attacker.faction_id)
	var defender_faction = Faction.get_faction(defender.faction_id)
	var has_human_player = not attacker_faction.is_ai or not defender_faction.is_ai
	
	if has_human_player and battle_screen:
		# Open battle screen for human interaction
		battle_manager.setup_battle(attacker, defender, planet)
		battle_screen.start_battle(battle_manager)
	else:
		# Simulate AI vs AI battle without GUI
		simulate_ai_battle(attacker, defender, planet)

func is_battle_screen_visible() -> bool:
	return battle_screen and battle_screen.visible

func simulate_ai_battle(attacker: Ship, defender: Ship, planet: Planet) -> void:
	# Setup battle manager for AI simulation
	battle_manager.setup_battle(attacker, defender, planet)
	
	# Auto-allocate energy for both AI ships
	var attacker_max_energy = battle_manager.get_max_allocatable_energy(attacker)
	var attacker_weapon = int(attacker_max_energy * 0.6)
	var attacker_shield = attacker_max_energy - attacker_weapon
	battle_manager.allocate_attacker_energy(attacker_shield, attacker_weapon)
	
	var defender_max_energy = battle_manager.get_max_allocatable_energy(defender)
	var defender_shield = int(defender_max_energy * 0.6)
	var defender_weapon = defender_max_energy - defender_shield
	battle_manager.allocate_defender_energy(defender_shield, defender_weapon)
	
	# Resolve battle
	battle_manager.resolve_battle()
	
	# Clean up - destroy loser and transfer planet ownership
	battle_manager.cleanup_battle()

func _on_battle_complete() -> void:
	$UI/TopBar/SystemLabel.text = "Battle concluded"
	await get_tree().create_timer(1.0).timeout
	$UI/TopBar/SystemLabel.text = ""

func try_open_planet_screen(planet: Planet) -> void:
	# Only owner faction can open planet screen
	if not turn_manager:
		return
	
	var current_faction = Faction.get_faction(turn_manager.current_faction_id)
	if current_faction.is_ai:
		return  # AI doesn't use planet screen
	
	if planet.faction_id != turn_manager.current_faction_id:
		$UI/TopBar/SystemLabel.text = "You don't control this planet"
		return
	
	if planet_screen:
		planet_screen.open_planet(planet, planet.planet_manager)

func _on_planet_screen_return() -> void:
	if planet_screen:
		planet_screen.visible = false

func try_open_ship_screen(ship: Ship) -> void:
	# Only owner faction can open ship screen
	if not turn_manager:
		return
	
	var current_faction = Faction.get_faction(turn_manager.current_faction_id)
	if current_faction.is_ai:
		return  # AI doesn't use ship screen
	
	if ship.faction_id != turn_manager.current_faction_id:
		$UI/TopBar/SystemLabel.text = "You don't control this ship"
		return
	
	if ship_screen:
		ship_screen.open_ship(ship, ship.ship_manager)

func _on_ship_screen_return() -> void:
	if ship_screen:
		ship_screen.visible = false

func _on_game_over(winner_faction_id: int) -> void:
	if game_over_screen and turn_manager:
		game_over_screen.show_game_over(winner_faction_id, turn_manager.current_round)

func _on_game_over_return() -> void:
	# For now, just hide the screen. Could restart game or return to main menu
	if game_over_screen:
		game_over_screen.visible = false
