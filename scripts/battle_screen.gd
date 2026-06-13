extends Control
class_name BattleScreen

var battle_manager: BattleManager = null
var attacker_is_human: bool = false
var defender_is_human: bool = false

var attacker_shield_allocation: int = 0
var attacker_weapon_allocation: int = 0
var defender_shield_allocation: int = 0
var defender_weapon_allocation: int = 0

signal battle_complete()

func _ready() -> void:
	visible = false
	
	# Connect attacker controls
	if has_node("Panel/AttackerPanel/ShieldSlider"):
		$Panel/AttackerPanel/ShieldSlider.value_changed.connect(_on_attacker_shield_changed)
	if has_node("Panel/AttackerPanel/WeaponSlider"):
		$Panel/AttackerPanel/WeaponSlider.value_changed.connect(_on_attacker_weapon_changed)
	if has_node("Panel/AttackerPanel/ConfirmButton"):
		$Panel/AttackerPanel/ConfirmButton.pressed.connect(_on_attacker_confirm)
	
	# Connect defender controls
	if has_node("Panel/DefenderPanel/ShieldSlider"):
		$Panel/DefenderPanel/ShieldSlider.value_changed.connect(_on_defender_shield_changed)
	if has_node("Panel/DefenderPanel/WeaponSlider"):
		$Panel/DefenderPanel/WeaponSlider.value_changed.connect(_on_defender_weapon_changed)
	if has_node("Panel/DefenderPanel/ConfirmButton"):
		$Panel/DefenderPanel/ConfirmButton.pressed.connect(_on_defender_confirm)
	
	# Connect continue button
	if has_node("Panel/ContinueButton"):
		$Panel/ContinueButton.pressed.connect(_on_continue_pressed)

func start_battle(manager: BattleManager) -> void:
	battle_manager = manager
	
	if not battle_manager:
		return
	
	# Determine if players are human
	attacker_is_human = not Faction.get_faction(battle_manager.attacker_faction_id).is_ai
	defender_is_human = not Faction.get_faction(battle_manager.defender_faction_id).is_ai
	
	# Setup UI
	_setup_ui()
	visible = true
	
	# Auto-allocate for AI
	if not attacker_is_human:
		_auto_allocate_attacker()
	if not defender_is_human:
		_auto_allocate_defender()
	
	# Check if we can proceed immediately (both AI)
	if not attacker_is_human and not defender_is_human:
		await get_tree().create_timer(1.5).timeout
		_resolve_battle()

func _setup_ui() -> void:
	if not battle_manager:
		return
	
	# Set planet background info
	if has_node("Panel/PlanetName") and battle_manager.battle_planet:
		$Panel/PlanetName.text = "Battle at " + battle_manager.battle_planet.planet_name
	
	# Setup attacker info
	var attacker_faction = Faction.get_faction(battle_manager.attacker_faction_id)
	if has_node("Panel/AttackerPanel/FactionLabel"):
		$Panel/AttackerPanel/FactionLabel.text = "ATTACKER: " + attacker_faction.name
	
	if has_node("Panel/AttackerPanel/ShipStats"):
		var attacker_stats = ""
		if battle_manager.attacker and battle_manager.attacker.ship_manager:
			var sm = battle_manager.attacker.ship_manager
			attacker_stats = "Attack: %d | Shield: %d\nEnergy: %d" % [sm.attack_power, sm.shield_strength, sm.current_energy]
		$Panel/AttackerPanel/ShipStats.text = attacker_stats
	
	# Setup defender info
	var defender_faction = Faction.get_faction(battle_manager.defender_faction_id)
	if has_node("Panel/DefenderPanel/FactionLabel"):
		$Panel/DefenderPanel/FactionLabel.text = "DEFENDER: " + defender_faction.name
	
	if has_node("Panel/DefenderPanel/ShipStats"):
		var defender_stats = ""
		if battle_manager.defender and battle_manager.defender.ship_manager:
			var sm = battle_manager.defender.ship_manager
			defender_stats = "Attack: %d | Shield: %d\nEnergy: %d" % [sm.attack_power, sm.shield_strength, sm.current_energy]
		$Panel/DefenderPanel/ShipStats.text = defender_stats
	
	# Setup sliders max values
	if has_node("Panel/AttackerPanel/ShieldSlider"):
		var max_energy = battle_manager.get_max_allocatable_energy(battle_manager.attacker)
		$Panel/AttackerPanel/ShieldSlider.max_value = max_energy
		$Panel/AttackerPanel/WeaponSlider.max_value = max_energy
	
	if has_node("Panel/DefenderPanel/ShieldSlider"):
		var max_energy = battle_manager.get_max_allocatable_energy(battle_manager.defender)
		$Panel/DefenderPanel/ShieldSlider.max_value = max_energy
		$Panel/DefenderPanel/WeaponSlider.max_value = max_energy
	
	# Show/hide panels based on human control
	if has_node("Panel/AttackerPanel"):
		$Panel/AttackerPanel.visible = attacker_is_human
	if has_node("Panel/DefenderPanel"):
		$Panel/DefenderPanel.visible = defender_is_human
	
	# Hide result elements
	if has_node("Panel/ResultLabel"):
		$Panel/ResultLabel.visible = false
	if has_node("Panel/ContinueButton"):
		$Panel/ContinueButton.visible = false

func _on_attacker_shield_changed(value: float) -> void:
	attacker_shield_allocation = int(value)
	_update_attacker_allocation_display()

func _on_attacker_weapon_changed(value: float) -> void:
	attacker_weapon_allocation = int(value)
	_update_attacker_allocation_display()

func _update_attacker_allocation_display() -> void:
	if not battle_manager:
		return
	
	var max_energy = battle_manager.get_max_allocatable_energy(battle_manager.attacker)
	var total = attacker_shield_allocation + attacker_weapon_allocation
	
	if has_node("Panel/AttackerPanel/AllocationLabel"):
		$Panel/AttackerPanel/AllocationLabel.text = "Shield: %d | Weapon: %d\nTotal: %d/%d" % [
			attacker_shield_allocation, attacker_weapon_allocation, total, max_energy
		]
	
	# Disable confirm if over budget
	if has_node("Panel/AttackerPanel/ConfirmButton"):
		$Panel/AttackerPanel/ConfirmButton.disabled = (total > max_energy)

func _on_defender_shield_changed(value: float) -> void:
	defender_shield_allocation = int(value)
	_update_defender_allocation_display()

func _on_defender_weapon_changed(value: float) -> void:
	defender_weapon_allocation = int(value)
	_update_defender_allocation_display()

func _update_defender_allocation_display() -> void:
	if not battle_manager:
		return
	
	var max_energy = battle_manager.get_max_allocatable_energy(battle_manager.defender)
	var total = defender_shield_allocation + defender_weapon_allocation
	
	if has_node("Panel/DefenderPanel/AllocationLabel"):
		$Panel/DefenderPanel/AllocationLabel.text = "Shield: %d | Weapon: %d\nTotal: %d/%d" % [
			defender_shield_allocation, defender_weapon_allocation, total, max_energy
		]
	
	# Disable confirm if over budget
	if has_node("Panel/DefenderPanel/ConfirmButton"):
		$Panel/DefenderPanel/ConfirmButton.disabled = (total > max_energy)

func _on_attacker_confirm() -> void:
	if battle_manager:
		battle_manager.allocate_attacker_energy(attacker_shield_allocation, attacker_weapon_allocation)
	
	# Hide attacker panel
	if has_node("Panel/AttackerPanel"):
		$Panel/AttackerPanel.visible = false
	
	# Check if we can resolve
	_check_ready_to_resolve()

func _on_defender_confirm() -> void:
	if battle_manager:
		battle_manager.allocate_defender_energy(defender_shield_allocation, defender_weapon_allocation)
	
	# Hide defender panel
	if has_node("Panel/DefenderPanel"):
		$Panel/DefenderPanel.visible = false
	
	# Check if we can resolve
	_check_ready_to_resolve()

func _auto_allocate_attacker() -> void:
	if not battle_manager:
		return
	
	var max_energy = battle_manager.get_max_allocatable_energy(battle_manager.attacker)
	# AI splits 60% weapon, 40% shield
	var weapon = int(max_energy * 0.6)
	var shield = max_energy - weapon
	
	battle_manager.allocate_attacker_energy(shield, weapon)

func _auto_allocate_defender() -> void:
	if not battle_manager:
		return
	
	var max_energy = battle_manager.get_max_allocatable_energy(battle_manager.defender)
	# AI splits 40% weapon, 60% shield (defender more defensive)
	var shield = int(max_energy * 0.6)
	var weapon = max_energy - shield
	
	battle_manager.allocate_defender_energy(shield, weapon)

func _check_ready_to_resolve() -> void:
	# Check if both panels are hidden (both confirmed)
	var attacker_ready = not attacker_is_human or (has_node("Panel/AttackerPanel") and not $Panel/AttackerPanel.visible)
	var defender_ready = not defender_is_human or (has_node("Panel/DefenderPanel") and not $Panel/DefenderPanel.visible)
	
	if attacker_ready and defender_ready:
		await get_tree().create_timer(0.5).timeout
		_resolve_battle()

func _resolve_battle() -> void:
	if not battle_manager:
		return
	
	battle_manager.resolve_battle()
	
	# Show results
	_display_results()

func _display_results() -> void:
	if not battle_manager:
		return
	
	var stats = battle_manager.calculate_combat_stats()
	
	var winner_faction = Faction.get_faction(battle_manager.winner_faction_id)
	var result_text = "BATTLE RESULTS\n\n"
	
	result_text += "Attacker Strength: %.1f\n" % stats.attacker_strength
	result_text += "(Attack: %.1f + Shield: %.1f)\n\n" % [stats.attacker_attack, stats.attacker_shield]
	
	result_text += "Defender Strength: %.1f\n" % stats.defender_strength
	result_text += "(Attack: %.1f + Shield: %.1f + Planet: %d)\n\n" % [stats.defender_attack, stats.defender_shield, stats.planet_bonus]
	
	result_text += "WINNER: %s" % winner_faction.name
	
	if has_node("Panel/ResultLabel"):
		$Panel/ResultLabel.text = result_text
		$Panel/ResultLabel.visible = true
	
	if has_node("Panel/ContinueButton"):
		$Panel/ContinueButton.visible = true

func _on_continue_pressed() -> void:
	if battle_manager:
		battle_manager.cleanup_battle()
	
	visible = false
	battle_complete.emit()

func close_battle() -> void:
	visible = false
	battle_manager = null
