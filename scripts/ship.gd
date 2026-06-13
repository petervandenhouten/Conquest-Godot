extends Node2D
class_name Ship

@export var faction_id: int = 1
@export var speed: float = 100.0

var current_planet: Planet = null
var target_planet: Planet = null
var current_lane: TravelLane = null
var travel_progress: float = 0.0
var is_moving: bool = false
var has_moved_this_turn: bool = false
var ship_manager: ShipManager = null

func _ready() -> void:
	var circle = CircleShape2D.new()
	circle.radius = 10.0
	$Area2D/CollisionShape2D.shape = circle
	
	$Area2D.input_event.connect(_on_input_event)
	
	# Initialize ship manager
	ship_manager = ShipManager.new()
	ship_manager.setup(faction_id)
	add_child(ship_manager)
	
	# Set z-index to render ships above planets
	z_index = 10
	
	update_color()

func update_color() -> void:
	var faction = Faction.get_faction(faction_id)
	$Sprite.color = faction.primary_color

func update_visual_state() -> void:
	var faction = Faction.get_faction(faction_id)
	if has_moved_this_turn:
		$Sprite.color = faction.primary_color.darkened(0.5)
		$Sprite.modulate = Color(0.7, 0.7, 0.7)
	else:
		$Sprite.color = faction.primary_color
		$Sprite.modulate = Color(1, 1, 1)

func reset_turn_state() -> void:
	has_moved_this_turn = false
	update_visual_state()

func process_turn() -> void:
	if ship_manager:
		ship_manager.process_turn()

func get_combat_strength() -> int:
	if ship_manager:
		return ship_manager.get_combat_strength()
	return 10  # Base strength

func set_at_planet(planet: Planet) -> void:
	if current_planet:
		current_planet.queue_redraw()  # Redraw old planet
	current_planet = planet
	position = planet.position
	is_moving = false
	if current_planet:
		# Claim planet for this ship's faction when occupying
		if current_planet.faction_id != faction_id:
			current_planet.set_faction(faction_id)
		current_planet.queue_redraw()  # Redraw new planet

func move_to_planet(planet: Planet) -> bool:
	if not current_planet:
		return false
	
	if is_moving:
		return false
	
	# Check if planet is connected
	if planet not in current_planet.connected_planets:
		print("Cannot move: planet not connected")
		return false
	
	# Find the lane
	for lane in current_planet.connected_lanes:
		if lane.get_other_planet(current_planet) == planet:
			if current_planet:
				current_planet.queue_redraw()  # Redraw departure planet
			current_lane = lane
			target_planet = planet
			travel_progress = 0.0
			is_moving = true
			has_moved_this_turn = true
			update_visual_state()
			return true
	return false

func _process(delta: float) -> void:
	if is_moving and current_lane and target_planet:
		var lane_length = current_lane.get_length()
		travel_progress += speed * delta
		
		if travel_progress >= lane_length:
			# Arrived
			current_planet = target_planet
			position = current_planet.position
			is_moving = false
			if current_planet:
				# Claim planet for this ship's faction when arriving
				if current_planet.faction_id != faction_id:
					current_planet.set_faction(faction_id)
				current_planet.queue_redraw()  # Redraw arrival planet
			current_lane = null
			target_planet = null
			travel_progress = 0.0
		else:
			# Update position along lane
			position = current_lane.get_point_at_distance(current_planet, travel_progress)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var main = get_parent().get_parent().get_parent()
		if event.button_index == MOUSE_BUTTON_LEFT:
			if main and main.has_method("select_ship"):
				main.select_ship(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right-click to open ship screen (owner only)
			if main and main.has_method("try_open_ship_screen"):
				main.try_open_ship_screen(self)
