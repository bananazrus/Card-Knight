extends CharacterBody2D
@onready var length_timer: Timer = $DashLength
@onready var cooldown_timer: Timer = $DashCooldown
@onready var health_regen_timer: Timer = $HealthRegen
@onready var hazard_timer: Timer = $HazardTimer
@onready var five_timer: Timer = $Five_Timer
@onready var nine_timer: Timer = $Nine_Timer
@onready var seven_timer: Timer = $Seven_Timer
@onready var six_timer: Timer = $Six_Timer
@onready var two_timer: Timer = $Two_Timer
@export var downslash: PackedScene
@export var el_projectile: PackedScene
@export var pierce_projectile: PackedScene
const LIGHTNING_SCENE = preload("res://Lightning.tscn")
var charging = false
var invulnerable= true
var active_hazards: Array[Area2D] = []
var SPEED = 500.0
var JUMP_VELOCITY = -1000.0
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
signal overshield_changed
var weapon="sword"
var regen_rate = 5
var ability=""
var overshield = 0
func _ready() -> void:
	equip_weapon(SwordScene)
	weapon_offset=weapon_slot.position
	$Buff_Aura.play("empty")
func _physics_process(delta: float) -> void:
	if position.x < get_global_mouse_position().x:
		facing_direction = 1
		pivot.scale.x = 1
	elif position.x > get_global_mouse_position().x:
		facing_direction = -1
		pivot.scale.x = -1
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
		if Input.is_action_just_pressed("dash") and cooldown_timer.is_stopped() and six_timer.is_stopped():
			if direction != 0:
				current_direction = sign(direction)
			else:
				current_direction = pivot.scale.x
			velocity.x = 19000.0 * current_direction
			length_timer.start()
			cooldown_timer.start()
		if not length_timer.is_stopped():
			velocity.x=2000 * current_direction
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if not length_timer.is_stopped() and (direction ==pivot.scale.x or direction == 0):
		sprite.animation = "dash"
		sprite.offset.y = -40
	elif not length_timer.is_stopped() and direction !=pivot.scale.x and direction !=0:
		sprite.animation = "backdash"
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
		velocity.y=-3000
		bounce = false
	if health_regen_timer.is_stopped() and health < max_health:
		health = min(health + (regen_rate * delta), max_health)
		health_changed.emit(health)
	if six_timer.is_stopped():
		$StaticBody2D.hide()
		$StaticBody2D/CollisionShape2D.set_deferred("disabled",true)
		SPEED=500
		JUMP_VELOCITY = -1000
		invulnerable = false
	if two_timer.is_stopped():
		$Area2D1.hide()
		$Area2D1.set_deferred("monitoring",false)
		$Area2D1.set_deferred("monitorable",false)
		$Area2D1.remove_from_group("bleed")
		$Area2D1.remove_from_group("slow")
		$Area2D1.remove_from_group("shock")
		$Area2D1.remove_from_group("burn")
	$Marker2D.look_at(get_global_mouse_position())
	move_and_slide()

func _on_area_2d_player_body_entered(body) -> void:
	if body.is_in_group("Enemies") or body.get_parent().is_in_group("Enemies"):
		take_damage(20*Globals.damage_reduction)
func take_damage(amount: int) -> void:
	if not invulnerable:
		if overshield>0:
			overshield-=amount
			if overshield<0:
				health +=overshield
				overshield = 0
				health_changed.emit(health)
				health_regen_timer.start()
			overshield_changed.emit(overshield)
		else:
			health -=amount
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
		take_damage(25*Globals.damage_reduction)
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
		take_damage(25*Globals.damage_reduction)
	else:
		hazard_timer.stop()
func card(num):
	if Globals.hand.size()>=(num+1):
		ability=Globals.hand[num]
	if Globals.seven==false:
		if Globals.deck.size()!=0:
			Globals.discard = Globals.hand[num]
			Globals.hand[num]=Globals.deck[0]
			Globals.deck.remove_at(0)
		elif Globals.hand.size()>=(num+1):
			Globals.discard = Globals.hand[num]
			Globals.hand.remove_at(num)
		else:
			pass
	elif is_mouse_inside_object(get_global_mouse_position()):
		pass
	else:
		Globals.seven=false
		$Buff_Aura.play("empty")
	if ability == "5C":
		Globals.damage_buff_5 = 2
		five_timer.start()
		$Buff_Aura.play("5C")
	if ability == "9C":
		Globals.damage_reduction = 0.1
		nine_timer.start()
		$Buff_Aura.play("9C")
	if ability == "7H":
		$Buff_Aura.play("7H")
		Globals.seven=true
	if ability =="6D":
		$StaticBody2D.show()
		$StaticBody2D/CollisionShape2D.set_deferred("disabled",false)
		SPEED=0
		JUMP_VELOCITY = 0
		invulnerable = true
		six_timer.start()
	if ability == "10D":
		slash()
	if ability == "2D":
		$Area2D1.show()
		$Area2D1.set_deferred("monitoring",true)
		$Area2D1.set_deferred("monitorable",true)
		$Area2D1.add_to_group("slow")
		two_timer.start()
	if ability == "3H":
		overshield+=30
		overshield_changed.emit(overshield)
	if ability == "4S":
		shoot_el_proj("bleed")
	if ability == "8S":
		pierce_proj("bleed")
	if ability == "AC":
		spawn_lightning_at(get_global_mouse_position())
func slash():
	var instance = downslash.instantiate()
	get_parent().add_child(instance)
	instance.global_position = get_global_mouse_position()
func _on_five_timer_timeout() -> void:
	Globals.damage_buff_5 = 1
	$Buff_Aura.play("empty")
func shoot_el_proj(element):
	var b = el_projectile.instantiate()
	get_parent().add_child(b)
	b.global_transform = $Marker2D.global_transform
	b.add_to_group(element)
func pierce_proj(element):
	var b = pierce_projectile.instantiate()
	get_parent().add_child(b)
	b.global_transform = $Marker2D.global_transform
	b.add_to_group(element)
func _on_nine_timer_timeout() -> void:
	Globals.damage_reduction = 1
	$Buff_Aura.play("empty")
func is_mouse_inside_object(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 3
	query.collide_with_bodies = true 
	query.collide_with_areas = false
	var hits = space_state.intersect_point(query)
	return not hits.is_empty()
func spawn_lightning_at(target_pos: Vector2) -> void:
	if is_mouse_inside_object(target_pos):
		return
	var space_state = get_world_2d().direct_space_state
	var ray_start = Vector2(target_pos.x, target_pos.y)
	var ray_end = Vector2(target_pos.x, target_pos.y + 10000)
	
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var ground_impact_point: Vector2 = result.position
		
		var lightning = LIGHTNING_SCENE.instantiate()
		lightning.global_position = ground_impact_point - Vector2(0, 2)
		get_parent().add_child(lightning)
		lightning.add_to_group("shock")
