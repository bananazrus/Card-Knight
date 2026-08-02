extends ColorRect

var tween: Tween

## Call this method whenever the player takes damage!
func flash_damage(start_intensity: float = 0.8, duration: float = 0.4) -> void:
	if tween:
		tween.kill()
	
	# Set the shader's intensity immediately
	material.set_shader_parameter("intensity", start_intensity)
	tween = create_tween()
	tween.tween_property(material, "shader_parameter/intensity", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
