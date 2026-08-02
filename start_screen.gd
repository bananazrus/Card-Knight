extends Control
@export_file("*.tscn", "*.scn") var start_level_path: String = "res://loading_screen.tscn"
@export_file("*.scn") var target_level_path: String = "res://node_2d.scn"
func _on_start_button_pressed() -> void:
	LoadingScreen.next_scene = target_level_path
	get_tree().change_scene_to_file(start_level_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
