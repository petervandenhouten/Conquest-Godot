extends Line2D
class_name TravelLane

var planet_a: Planet
var planet_b: Planet
var normal_width: float = 2.0
var normal_color: Color = Color(0.4, 0.4, 0.4, 0.6)
var highlight_width: float = 4.0
var highlight_color: Color = Color(1.0, 1.0, 0.0, 0.9)  # Yellow
var battle_color: Color = Color(1.0, 0.3, 0.0, 0.9)  # Orange/Red for battle moves

func setup(p1: Planet, p2: Planet) -> void:
	planet_a = p1
	planet_b = p2
	width = normal_width
	default_color = normal_color
	update_positions()
	
	planet_a.add_lane(self, planet_b)
	planet_b.add_lane(self, planet_a)

func update_positions() -> void:
	if planet_a and planet_b:
		clear_points()
		add_point(planet_a.position)
		add_point(planet_b.position)

func get_other_planet(from: Planet) -> Planet:
	if from == planet_a:
		return planet_b
	return planet_a

func get_length() -> float:
	if planet_a and planet_b:
		return planet_a.position.distance_to(planet_b.position)
	return 0.0

func get_point_at_distance(from: Planet, distance: float) -> Vector2:
	if not planet_a or not planet_b:
		return Vector2.ZERO
	
	var start = from.position
	var end = get_other_planet(from).position
	var direction = (end - start).normalized()
	return start + direction * distance

func highlight(is_battle: bool = false) -> void:
	width = highlight_width
	default_color = battle_color if is_battle else highlight_color
	z_index = 1  # Draw on top

func unhighlight() -> void:
	width = normal_width
	default_color = normal_color
	z_index = 0
