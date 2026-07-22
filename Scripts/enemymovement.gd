extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -1000.0
var player: CharacterBody2D
var direction=0
var health=100
@onready var sprite = $Node2D/AnimatedSprite2D
func _ready():
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
func _physics_process(delta: float) -> void:
	var player_pos = player.global_position
	var enemy_pos = global_position
	var distance_to_player = enemy_pos.distance_to(player_pos)
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
	if distance_to_player <=1000:
		if velocity.x==0 and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if abs(player_pos.x-enemy_pos.x)<2:
			direction=0
		elif player_pos.x<enemy_pos.x:
			direction=-1
		elif player_pos.x>enemy_pos.x:
			direction=1
	velocity.x = direction * SPEED
	move_and_slide()
	if direction < 0:
		$Node2D.scale.x = 1
	elif direction > 0:
		$Node2D.scale.x = -1
	if not is_on_floor():
		sprite.animation = "jump"
	elif direction != 0:
		sprite.animation = "walk"
	else:
		sprite.animation = "neutral"
	sprite.play()
	if health<=0:
		queue_free()

func _on_enemy_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		$enemyhealth.health_changed(20*Globals.damage_buff_5)
		health-=30*Globals.damage_buff_5
	elif area.is_in_group("Arrow"):
		$enemyhealth.health_changed(40*Globals.damage_buff_5)
		health-=40*Globals.damage_buff_5
