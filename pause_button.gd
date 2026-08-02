extends Control

@onready var pause_button: Button = $PauseButton
func _on_pause_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		pause_button.text = "RESUME"
	else:
		pause_button.text = "PAUSE"
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_pause_button_pressed()
		get_viewport().set_input_as_handled()
