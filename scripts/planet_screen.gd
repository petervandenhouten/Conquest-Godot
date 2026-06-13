extends Control
class_name PlanetScreen

var current_planet: Planet = null
var planet_manager: PlanetManager = null

signal return_to_galaxy()

func _ready() -> void:
	visible = false
	
	# Connect buttons
	if has_node("Panel/ReturnButton"):
		$Panel/ReturnButton.pressed.connect(_on_return_pressed)
	
	if has_node("Panel/BuildingsPanel/DefenceButton"):
		$Panel/BuildingsPanel/DefenceButton.pressed.connect(_on_defence_button_pressed)
	
	if has_node("Panel/BuildingsPanel/ResearchButton"):
		$Panel/BuildingsPanel/ResearchButton.pressed.connect(_on_research_button_pressed)
	
	if has_node("Panel/BuildingsPanel/EnergyButton"):
		$Panel/BuildingsPanel/EnergyButton.pressed.connect(_on_energy_button_pressed)

func open_planet(planet: Planet, manager: PlanetManager) -> void:
	current_planet = planet
	planet_manager = manager
	
	if planet_manager:
		planet_manager.facilities_changed.connect(_update_display)
	
	_update_display()
	visible = true

func close_planet() -> void:
	if planet_manager and planet_manager.facilities_changed.is_connected(_update_display):
		planet_manager.facilities_changed.disconnect(_update_display)
	
	current_planet = null
	planet_manager = null
	visible = false

func _update_display() -> void:
	if not current_planet or not planet_manager:
		return
	
	# Update planet name and faction
	if has_node("Panel/PlanetName"):
		var faction = Faction.get_faction(current_planet.faction_id)
		$Panel/PlanetName.text = "%s (%s)" % [current_planet.planet_name, faction.name]
	
	# Update status display
	if has_node("Panel/StatusLabel"):
		$Panel/StatusLabel.text = planet_manager.get_status_text()
	
	# Update button states
	_update_button_states()

func _update_button_states() -> void:
	if not planet_manager:
		return
	
	# Defence button
	if has_node("Panel/BuildingsPanel/DefenceButton"):
		var can_build = planet_manager.can_afford(PlanetManager.DEFENCE_COST)
		$Panel/BuildingsPanel/DefenceButton.disabled = not can_build
		$Panel/BuildingsPanel/DefenceButton.text = "Build Defence System (Cost: %d)" % PlanetManager.DEFENCE_COST
	
	# Research button
	if has_node("Panel/BuildingsPanel/ResearchButton"):
		var can_build = planet_manager.can_afford(PlanetManager.RESEARCH_COST)
		$Panel/BuildingsPanel/ResearchButton.disabled = not can_build
		$Panel/BuildingsPanel/ResearchButton.text = "Build Research System (Cost: %d)" % PlanetManager.RESEARCH_COST
	
	# Energy button
	if has_node("Panel/BuildingsPanel/EnergyButton"):
		var can_build = planet_manager.can_afford(PlanetManager.ENERGY_COST)
		$Panel/BuildingsPanel/EnergyButton.disabled = not can_build
		$Panel/BuildingsPanel/EnergyButton.text = "Build Energy System (Cost: %d)" % PlanetManager.ENERGY_COST

func _on_return_pressed() -> void:
	close_planet()
	return_to_galaxy.emit()

func _on_defence_button_pressed() -> void:
	if planet_manager and planet_manager.build_defence_system():
		_update_display()

func _on_research_button_pressed() -> void:
	if planet_manager and planet_manager.build_research_system():
		_update_display()

func _on_energy_button_pressed() -> void:
	if planet_manager and planet_manager.build_energy_system():
		_update_display()
