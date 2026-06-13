extends Control
class_name GameOverScreen

signal return_to_menu()

func _ready() -> void:
	visible = false
	
	# Connect return button
	if has_node("Panel/ReturnButton"):
		$Panel/ReturnButton.pressed.connect(_on_return_pressed)

func show_game_over(winner_faction_id: int, total_turns: int) -> void:
	var faction = Faction.get_faction(winner_faction_id)
	
	# Set winner name and apply color
	if has_node("Panel/WinnerLabel"):
		$Panel/WinnerLabel.text = faction.name + " Wins!"
		$Panel/WinnerLabel.add_theme_color_override("font_color", faction.primary_color)
	
	# Set total turns
	if has_node("Panel/TurnsLabel"):
		$Panel/TurnsLabel.text = "Total Turns: " + str(total_turns)
	
	# Set faction color to panel or background
	if has_node("Panel"):
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
		style.border_color = faction.primary_color
		style.border_width_left = 4
		style.border_width_right = 4
		style.border_width_top = 4
		style.border_width_bottom = 4
		$Panel.add_theme_stylebox_override("panel", style)
	
	visible = true

func _on_return_pressed() -> void:
	visible = false
	return_to_menu.emit()
