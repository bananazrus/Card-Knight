extends ProgressBar
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func _on_player_health_changed(current_value: int):
	value=current_value
