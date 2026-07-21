extends Node2D
@onready var shot_timer: Timer = $Timer
@onready var Projectile = preload("res://Arrow.tscn")
var facing_direction: int = 1
var clamped_angle: float

func _ready() -> void:
	$Marker2D.rotation = 0
func _process(_delta):
	aim_at_mouse()
	if shot_timer.is_stopped() and Input.is_action_just_pressed("BowAttack"):
		shoot()
func shoot():
	shot_timer.start()
	var arrow = Projectile.instantiate()
	get_tree().root.add_child(arrow)
	arrow.global_transform = $Marker2D.global_transform
	var shoot_dir = $Marker2D.global_transform.x.normalized()
	var target_pos = $Marker2D.global_position + shoot_dir * 1000
	var cursor_position = Vector2($Marker2D.global_position.x,$Marker2D.global_position.y+250)
	arrow.shoot(target_pos,cursor_position)

func aim_at_mouse():
	var local_mouse = get_parent().get_local_mouse_position()
	var angle = local_mouse.angle()
	var max_angle = deg_to_rad(85)
	angle = clamp(angle, -max_angle, max_angle)
	rotation = angle
