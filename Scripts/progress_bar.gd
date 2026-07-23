extends ProgressBar
func _on_player_health_changed(current_value: float, max_hp: float):
	value=current_value
	max_value = max_hp
func _on_player_overshield_changed(current_value: float):
	$ProgressBar.value=current_value
