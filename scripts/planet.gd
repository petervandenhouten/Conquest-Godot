extends Node2D
class_name Planet

@export var planet_name: String = "Unknown"
@export var faction_id: int = 0  # 0=neutral, 1+=player factions
@export var radius: float = 20.0

var connected_lanes: Array[TravelLane] = []
var connected_planets: Array[Planet] = []
var planet_manager: PlanetManager = null

func _ready() -> void:
	$Label.text = planet_name
	_update_visuals()
	
	# Set z-index to render planets below ships
	z_index = 0
	
	# Setup collision
	var circle = CircleShape2D.new()
	circle.radius = radius
	$Area2D/CollisionShape2D.shape = circle
	
	$Area2D.input_event.connect(_on_input_event)
	
	# Initialize planet manager
	planet_manager = PlanetManager.new()
	planet_manager.setup(faction_id)
	add_child(planet_manager)

func _update_visuals() -> void:
	# Draw planet circle
	queue_redraw()

func _draw() -> void:
	# Use the planet's faction_id which represents current control
	# (Ships claim planets when they occupy them)
	var faction = Faction.get_faction(faction_id)
	var color = faction.primary_color
	
	# Outer glow
	draw_circle(Vector2.ZERO, radius + 3, Color(color.r, color.g, color.b, 0.3))
	# Main planet
	draw_circle(Vector2.ZERO, radius, color)
	# Inner highlight
	draw_circle(Vector2(-5, -5), radius * 0.3, Color(1, 1, 1, 0.4))

func add_lane(lane: TravelLane, other_planet: Planet) -> void:
	if lane not in connected_lanes:
		connected_lanes.append(lane)
	if other_planet not in connected_planets:
		connected_planets.append(other_planet)

func set_faction(new_faction_id: int) -> void:
	faction_id = new_faction_id
	if planet_manager:
		planet_manager.setup(faction_id)
	queue_redraw()

func process_turn() -> void:
	if planet_manager:
		planet_manager.process_turn()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var galaxy_map = get_parent().get_parent()
		if event.button_index == MOUSE_BUTTON_LEFT:
			if galaxy_map and galaxy_map.has_method("select_planet"):
				galaxy_map.select_planet(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right-click to open planet screen (owner only)
			var main = galaxy_map.get_parent() if galaxy_map else null
			if main and main.has_method("try_open_planet_screen"):
				main.try_open_planet_screen(self)
