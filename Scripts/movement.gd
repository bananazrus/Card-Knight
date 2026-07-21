extends CharacterBody2D
@onready var length_timer: Timer = $DashLength
@onready var cooldown_timer: Timer = $DashCooldown
@onready var health_regen_timer: Timer = $HealthRegen
@onready var hazard_timer: Timer = $HazardTimer
var active_hazards: Array[Area2D] = []
const SPEED = 500.0
const JUMP_VELOCITY = -1000.0
const BowScene=preload("res://BowAttack.tscn")
const SwordScene=preload("res://SwordAttack.tscn")
var weapon_offset := Vector2.ZERO
var current_weapon_node: Node2D
var facing_direction := 1
@onready var weapon_pivot = $pivot/WeaponPivot
@onready var weapon_slot = $pivot/WeaponPivot/Marker2D
var can_dash = true
var current_direction
var can_double_jump = true
var jump = false
@export var max_health: float = 100 # maximum possible health
var health: float = max_health
@onready var pivot: Node2D = $pivot
@onready var sprite = $pivot/AnimatedSprite2D
var bounce = false
signal health_changed
var weapon="sword"
var regen_rate = 5
func _ready() -> void:
	equip_weapon(SwordScene)
	weapon_offset=weapon_slot.position
func _physics_process(delta: float) -> void:
	print(health)
	if Input.is_action_just_pressed("switch"):
		if weapon == "sword":
			equip_weapon(BowScene)
			weapon="bow"
		elif weapon == "bow":
			equip_weapon(SwordScene)
			weapon="sword"
	if is_on_floor():
		can_double_jump=true
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
	# Handle jump.
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("wkey"))and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("wkey")) and not is_on_floor() and can_double_jump:
		velocity.y = JUMP_VELOCITY
		can_double_jump=false
		
	var direction := Input.get_axis("akey", "dkey")
	if Input.is_action_pressed("dash"):
		velocity.x = direction*1000
	if Input.is_action_just_pressed("card1"):
		card(0)
	if Input.is_action_just_pressed("card2"):
		card(1)
	if Input.is_action_just_pressed("card3"):
		card(2)
	if Input.is_action_just_pressed("card4"):
		card(3)
	if Input.is_action_just_pressed("card5"):
		card(4)
	if pivot.scale.x:
		if Input.is_action_just_pressed("dash") and cooldown_timer.is_stopped():
			velocity.x=19000.0 * pivot.scale.x
			current_direction = pivot.scale.x
			length_timer.start()
			cooldown_timer.start()
		if not length_timer.is_stopped():
			velocity.x=2000 * abs(current_direction)/current_direction
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction < 0:
		facing_direction = -1
		pivot.scale.x = -1
	elif direction > 0:
		facing_direction = 1
		pivot.scale.x = 1
	if not length_timer.is_stopped():
		sprite.animation = "dash"
		sprite.offset.y = -40
	elif not is_on_floor():
		sprite.animation = "jump"
	elif direction != 0:
		sprite.animation = "walk"
		sprite.offset.y = -20
	else:
		sprite.animation = "neutral"
		sprite.offset.y = 0
	sprite.play()
	if not length_timer.is_stopped():
		velocity.y = 0
	if not length_timer.is_stopped() and velocity.x==0:
		length_timer.stop()
	if health<=0:
		$CollisionShape2D.set_deferred("disabled", true)
		Globals.reset_game_state()
		get_tree().call_deferred("reload_current_scene")
	if bounce:
		velocity.y=-2500
		bounce = false
	if health_regen_timer.is_stopped() and health < max_health:
		health = min(health + (regen_rate * delta), max_health)
		health_changed.emit(health)
	move_and_slide()

func _on_area_2d_player_body_entered(body) -> void:
	if body.is_in_group("Enemies") or body.get_parent().is_in_group("Enemies"):
		take_damage(15)
func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health)
	health_regen_timer.start()

func equip_weapon(weapon_scene: PackedScene):
	if current_weapon_node != null:
		current_weapon_node.queue_free()
	current_weapon_node = weapon_scene.instantiate()
	weapon_slot.add_child(current_weapon_node)


func _on_character_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hazards") or area.get_parent().is_in_group("Hazards"):
		active_hazards.append(area)
		take_damage(15)
		if hazard_timer.is_stopped():
			hazard_timer.start()
	if area.is_in_group("bouncepads") or area.get_parent().is_in_group("bouncepads"):
		bounce=true


func _on_character_area_2d_area_exited(area: Area2D) -> void:
	if area in active_hazards:
		active_hazards.erase(area)
	if active_hazards.is_empty():
		hazard_timer.stop()
func _on_hazard_timer_timeout() -> void:
	active_hazards = active_hazards.filter(func(a): return is_instance_valid(a))
	if not active_hazards.is_empty():
		take_damage(15)
	else:
		hazard_timer.stop()
func card(num):
	if Globals.deck.size()!=0:
		Globals.discard = Globals.hand[num]
		Globals.hand[num]=Globals.deck[0]
		Globals.deck.remove_at(0)
	elif Globals.hand.size()>=(num+1):
		Globals.discard = Globals.hand[num]
		Globals.hand.remove_at(num)
	else:
		pass
