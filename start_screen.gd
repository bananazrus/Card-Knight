extends Control
@export_file("*.scn") var start_level_path: String = "res://node_2d.scn"
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(start_level_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
