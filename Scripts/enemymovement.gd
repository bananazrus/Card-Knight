extends CharacterBody2D
var bleed=false
const SPEED = 200.0
const JUMP_VELOCITY = -1000.0
var player: CharacterBody2D
var direction=0
var health=100
var slow =1
var shocked = 0
var burn=false
@onready var burn_timer: Timer = $BurnTimer
@onready var slow_timer: Timer = $SlowTimer
@onready var shock_timer: Timer = $ShockTimer
@onready var bleed_timer: Timer = $BleedTimer
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
	velocity.x = direction * SPEED * slow
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
	if bleed:
		$enemyhealth.health_changed(health-max(health - (8 * delta), 0))
		health = max(health - (8 * delta), 0)
	if burn:
		$enemyhealth.health_changed(health-max(health - (10 * delta), 0))
		health = max(health - (10 * delta), 0)
	if slow_timer.is_stopped():
		slow = 1
	if shock_timer.is_stopped():
		shocked = 0
	if bleed_timer.is_stopped():
		bleed = false
	if burn_timer.is_stopped():
		burn = false
func _on_enemy_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		$enemyhealth.health_changed((30*Globals.damage_buff_5*Globals.sword_increase)+shocked)
		health-=30*Globals.damage_buff_5*Globals.sword_increase+shocked
	elif area.is_in_group("Arrow"):
		$enemyhealth.health_changed(40*Globals.damage_buff_5*Globals.bow_increase+shocked)
		health-=40*Globals.damage_buff_5*Globals.bow_increase+shocked
	elif area.is_in_group("2D"):
		health-=25*Globals.damage_buff_5*Globals.card_increase+shocked
		$enemyhealth.health_changed(25*Globals.damage_buff_5*Globals.card_increase+shocked)
	elif area.is_in_group("downslash"):
		$enemyhealth.health_changed(200*Globals.damage_buff_5*Globals.card_increase+shocked)
		health-=200*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("elemental_projectile"):
		$enemyhealth.health_changed(150*Globals.damage_buff_5*Globals.card_increase+shocked)
		health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("pierceproj"):
		$enemyhealth.health_changed(100*Globals.damage_buff_5*Globals.card_increase+shocked)
		health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("lightning"):
		$enemyhealth.health_changed(300*Globals.damage_buff_5*Globals.card_increase+shocked)
		health-=300*Globals.damage_buff_5*Globals.card_increase+shocked
	if area.is_in_group("bleed"):
		bleed_timer.start()
		bleed=true
	elif area.is_in_group("burn"):
		burn = true
		burn_timer.start()
	elif area.is_in_group("shock"):
		shocked = 15
		shock_timer.start()
	elif area.is_in_group("slow"):
		slow = 1.5
		slow_timer.start()
