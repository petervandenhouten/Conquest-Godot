extends RefCounted
class_name Faction

var id: int
var name: String
var primary_color: Color
var secondary_color: Color
var is_ai: bool

func _init(p_id: int, p_name: String, p_primary_color: Color, p_secondary_color: Color = Color.WHITE, p_is_ai: bool = true) -> void:
	id = p_id
	name = p_name
	primary_color = p_primary_color
	secondary_color = p_secondary_color
	is_ai = p_is_ai

# Global faction registry
static var factions: Dictionary = {}

static func initialize_factions() -> void:
	factions[0] = Faction.new(0, "Neutral", Color(0.5, 0.5, 0.5), Color(0.7, 0.7, 0.7), false)
	factions[1] = Faction.new(1, "Blue Empire", Color(0.3, 0.6, 1.0), Color(0.5, 0.8, 1.0), false)
	factions[2] = Faction.new(2, "Red Dominion", Color(1.0, 0.3, 0.3), Color(1.0, 0.5, 0.5), true)
	factions[3] = Faction.new(3, "Green Alliance", Color(0.3, 1.0, 0.3), Color(0.5, 1.0, 0.5), true)
	factions[4] = Faction.new(4, "Purple Coalition", Color(0.8, 0.3, 0.8), Color(1.0, 0.5, 1.0), true)
	factions[5] = Faction.new(5, "Yellow Consortium", Color(1.0, 0.8, 0.2), Color(1.0, 0.9, 0.5), true)

static func get_faction(faction_id: int) -> Faction:
	if factions.is_empty():
		initialize_factions()
	return factions.get(faction_id, factions[0])
