extends Control
class_name ShipScreen

var current_ship: Ship = null
var ship_manager: ShipManager = null

signal return_to_galaxy()

func _ready() -> void:
	visible = false
	
	# Connect buttons
	if has_node("Panel/ReturnButton"):
		$Panel/ReturnButton.pressed.connect(_on_return_pressed)
	
	if has_node("Panel/SystemsPanel/DefenceButton"):
		$Panel/SystemsPanel/DefenceButton.pressed.connect(_on_defence_button_pressed)
	
	if has_node("Panel/SystemsPanel/WeaponButton"):
		$Panel/SystemsPanel/WeaponButton.pressed.connect(_on_weapon_button_pressed)
	
	if has_node("Panel/SystemsPanel/EnergyButton"):
		$Panel/SystemsPanel/EnergyButton.pressed.connect(_on_energy_button_pressed)

func open_ship(ship: Ship, manager: ShipManager) -> void:
	current_ship = ship
	ship_manager = manager
	
	if ship_manager:
		ship_manager.systems_changed.connect(_update_display)
	
	_update_display()
	visible = true

func close_ship() -> void:
	if ship_manager and ship_manager.systems_changed.is_connected(_update_display):
		ship_manager.systems_changed.disconnect(_update_display)
	
	current_ship = null
	ship_manager = null
	visible = false

func _update_display() -> void:
	if not current_ship or not ship_manager:
		return
	
	# Update ship info
	if has_node("Panel/ShipName"):
		var faction = Faction.get_faction(current_ship.faction_id)
		var location = ""
		if current_ship.current_planet:
			location = " at " + current_ship.current_planet.planet_name
		$Panel/ShipName.text = "%s Ship%s" % [faction.name, location]
	
	# Update status display
	if has_node("Panel/StatusLabel"):
		$Panel/StatusLabel.text = ship_manager.get_status_text()
	
	# Update combat info
	if has_node("Panel/CombatLabel"):
		$Panel/CombatLabel.text = "Combat Strength: %d" % ship_manager.get_combat_strength()
	
	# Update button states
	_update_button_states()

func _update_button_states() -> void:
	if not ship_manager:
		return
	
	# Defence button
	if has_node("Panel/SystemsPanel/DefenceButton"):
		var can_build = ship_manager.can_afford(ShipManager.DEFENCE_COST)
		$Panel/SystemsPanel/DefenceButton.disabled = not can_build
		$Panel/SystemsPanel/DefenceButton.text = "Add Defence System (Cost: %d)" % ShipManager.DEFENCE_COST
	
	# Weapon button
	if has_node("Panel/SystemsPanel/WeaponButton"):
		var can_build = ship_manager.can_afford(ShipManager.WEAPON_COST)
		$Panel/SystemsPanel/WeaponButton.disabled = not can_build
		$Panel/SystemsPanel/WeaponButton.text = "Add Weapon System (Cost: %d)" % ShipManager.WEAPON_COST
	
	# Energy button
	if has_node("Panel/SystemsPanel/EnergyButton"):
		var can_build = ship_manager.can_afford(ShipManager.ENERGY_SYSTEM_COST)
		$Panel/SystemsPanel/EnergyButton.disabled = not can_build
		$Panel/SystemsPanel/EnergyButton.text = "Add Energy System (Cost: %d)" % ShipManager.ENERGY_SYSTEM_COST

func _on_return_pressed() -> void:
	close_ship()
	return_to_galaxy.emit()

func _on_defence_button_pressed() -> void:
	if ship_manager and ship_manager.add_defence_system():
		_update_display()

func _on_weapon_button_pressed() -> void:
	if ship_manager and ship_manager.add_weapon_system():
		_update_display()

func _on_energy_button_pressed() -> void:
	if ship_manager and ship_manager.add_energy_system():
		_update_display()
