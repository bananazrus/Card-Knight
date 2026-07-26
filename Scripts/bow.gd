extends Node2D

@onready var shot_timer: Timer = $Timer
@onready var Projectile = preload("res://Arrow.tscn")

# Trajectory Settings
@export var trajectory_points_count: int = 10
@export var time_step: float = 0.05
@export var arrow_speed: float = 1500.0
@export var arrow_gravity_scale: float = 1.0

# Set this in the Inspector to match your Wall / Enemy collision layers
@export_flags_2d_physics var collision_mask: int = 1

# Dot Style Options
@export var dot_radius: float = 3.0
@export var dot_color: Color = Color(1.0, 1.0, 1.0, 0.8)

var calculated_points: Array[Vector2] = []

func _ready() -> void:
	$Marker2D.rotation = 0

func _process(_delta):
	aim_at_mouse()
	update_trajectory()
	queue_redraw()
	
	if shot_timer.is_stopped() and Input.is_action_just_pressed("BowAttack"):
		shoot()

func aim_at_mouse():
	var local_mouse = get_parent().get_local_mouse_position()
	var angle = local_mouse.angle()
	var max_angle = deg_to_rad(90)
	angle = clamp(angle, -max_angle, max_angle)
	rotation = angle

func get_launch_velocity() -> Vector2:
	return $Marker2D.global_transform.x.normalized() * arrow_speed

func update_trajectory():
	calculated_points.clear()
	
	var space_state = get_world_2d().direct_space_state
	var start_pos = $Marker2D.global_position
	var velocity = get_launch_velocity()
	
	var gravity_vec = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
	var gravity_mag = ProjectSettings.get_setting("physics/2d/default_gravity")
	var gravity = gravity_vec * gravity_mag * arrow_gravity_scale

	var prev_pos = start_pos

	for i in range(1, trajectory_points_count + 1):
		var t = i * time_step
		var curr_pos = start_pos + velocity * t + 0.5 * gravity * t * t
		
		# Raycast segment from previous point to current point
		var query = PhysicsRayQueryParameters2D.create(prev_pos, curr_pos)
		query.collision_mask = collision_mask
		
		var result = space_state.intersect_ray(query)
		
		if result:
			# Ray hit a surface: add the hit point and stop checking further
			calculated_points.append(to_local(result.position))
			break
		else:
			# Path is clear: keep drawing
			calculated_points.append(to_local(curr_pos))
			prev_pos = curr_pos

func _draw():
	for point in calculated_points:
		draw_circle(point, dot_radius, dot_color)

func shoot():
	shot_timer.start()
	var arrow = Projectile.instantiate()
	get_tree().root.add_child(arrow)
	
	arrow.global_position = $Marker2D.global_position
	arrow.launch(get_launch_velocity())
