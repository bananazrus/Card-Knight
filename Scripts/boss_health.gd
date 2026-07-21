extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _on_boss_health_changed(current_value: int):
	value=current_value
