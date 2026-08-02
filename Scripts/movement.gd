extends CharacterBody2D

@onready var length_timer: Timer = $DashLength
@onready var cooldown_timer: Timer = $DashCooldown
@onready var health_regen_timer: Timer = $HealthRegen
@onready var hazard_timer: Timer = $HazardTimer
@onready var five_timer: Timer = $Five_Timer
@onready var nine_timer: Timer = $Nine_Timer
@onready var six_timer: Timer = $Six_Timer
@onready var two_timer: Timer = $Two_Timer
@onready var label_timer: Timer = $LabelTimer
@onready var invulnerable_timer: Timer = $InvulnerableTimer
@onready var queen_timer: Timer = $QueenTimer
@onready var stun_timer: Timer = $StunTimer
@onready var kingc_timer: Timer = $KingCTimer
@onready var other_invulnerable_timer: Timer = $OtherInvulnerableTimer
@onready var iframes_timer: Timer = $iFrames
@onready var card_cooldown: Timer = $CardCooldown
@onready var shrine_buff = $"../CanvasLayer2/Label"

@export var downslash: PackedScene
@export var el_projectile: PackedScene
@export var pierce_projectile: PackedScene
@export var expl_projectile: PackedScene
@export_file("*.scn") var start_level_path: String = "res://node_2d.scn"

var current_shrine: Area2D = null
const LIGHTNING_SCENE = preload("res://Lightning.tscn")
var charging = false
var invulnerable = false
var active_hazards: Array[Area2D] = []
var SPEED = 500.0
var JUMP_VELOCITY = -1000.0
const BowScene = preload("res://BowAttack.tscn")
const SwordScene = preload("res://SwordAttack.tscn")
var weapon_offset := Vector2.ZERO
var current_weapon_node: Node2D
var facing_direction := 1

@onready var weapon_pivot = $pivot/WeaponPivot
@onready var weapon_slot = $pivot/WeaponPivot/Marker2D

var can_dash = true
var current_direction
var jump = false
var stop_death = false

@export var max_health: float = 100
var health: float = max_health

@onready var pivot: Node2D = $pivot
@onready var sprite = $pivot/AnimatedSprite2D

var bounce = false
signal health_changed
signal overshield_changed

var weapon = "sword"
var regen_rate = 5
var ability = ""
var overshield = 0
var jumps = 2
var speed_buffs = 0
var shrine = false
var shrine_number
var jump_changes = 0
var no_discard = false
var stun = false

var buffs = [
	[1, "Gain an extra jump."],
	[2, "Cards have a chance not to be discarded upon use."],
	[3, "Increases damage of card attacks."],
	[4, "Increases damage of sword attacks."],
	[5, "Increases damage of bow attacks."],
	[6, "Increases player health."],
	[7, "Increases base walking speed."],
	[8, "Decreases regen cooldown."],
	[9, "Increases the regen rate."],
	[10, "Turn invulnerable for 3 second when an attack would kill you."]
]

@onready var dash_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func apply_shrine_buffs() -> void:
	max_health = 100.0 + Globals.max_health_bonus
	SPEED = 500.0 * (1.3 ** Globals.speed_buffs)
	speed_buffs = Globals.speed_buffs
	regen_rate = 5.0 * Globals.regen_rate_multiplier
	health_regen_timer.wait_time = 10.0 * Globals.regen_cooldown_multiplier
	no_discard = Globals.no_discard
	stop_death = Globals.stop_death
	jump_changes = Globals.jump_changes
	$HealthRegen.one_shot = true

func _ready() -> void:
	equip_weapon(SwordScene)
	weapon_offset = weapon_slot.position
	$pivot/Buff_Aura.play("empty")
	apply_shrine_buffs()
	health = max_health 
	$CanvasLayer/ColorRect.flash_damage(0, 0)

func _physics_process(delta: float) -> void:
	if invulnerable:
		if fmod(Engine.get_physics_frames(), 12) < 6:
			sprite.modulate = Color(10, 10, 10, 0.9)
		else:
			sprite.modulate = Color(1, 1, 1, 1)
	else:
		sprite.modulate = Color.WHITE

	if not is_inside_tree():
		return

	if not kingc_timer.is_stopped() and not length_timer.is_stopped():
		$pivot/Area2D/CollisionShape2D.disabled = true
		$pivot/Area2D3/CollisionShape2D.disabled = false
	else:
		$pivot/Area2D/CollisionShape2D.disabled = false
		$pivot/Area2D3/CollisionShape2D.disabled = true

	# Aim facing direction (Allowed during stun)
	if position.x < get_global_mouse_position().x:
		facing_direction = 1
		pivot.scale.x = 1
	elif position.x > get_global_mouse_position().x:
		facing_direction = -1
		pivot.scale.x = -1

	# Weapon Switching (Allowed during stun)
	if Input.is_action_just_pressed("switch") and not shrine:
		if weapon == "sword":
			equip_weapon(BowScene)
			weapon = "bow"
		elif weapon == "bow":
			equip_weapon(SwordScene)
			weapon = "sword"

	if label_timer.is_stopped():
		shrine_buff.hide()

	if Input.is_action_just_pressed("switch") and shrine:
		shrine_number = randi_range(0, 9)
		shrine_buff.text = buffs[shrine_number][1]
		shrine_buff.show()
		label_timer.start()

		if current_shrine and "is_active" in current_shrine:
			current_shrine.is_active = false
		shrine = false

		match buffs[shrine_number][0]:
			1:
				Globals.jump_changes += 1
				jump_changes = Globals.jump_changes
			2:
				Globals.no_discard = true
				no_discard = true
			3:
				Globals.card_increase *= 1.2
			4:
				Globals.sword_increase *= 1.3
			5:
				Globals.bow_increase *= 1.2
			6:
				Globals.max_health_bonus += 20.0
				max_health = 100.0 + Globals.max_health_bonus
				health += 20.0
				health_changed.emit(health, max_health)
				health_regen_timer.start()
			7:
				Globals.speed_buffs += 1
				speed_buffs = Globals.speed_buffs
				SPEED = 500.0 * (1.3 ** speed_buffs)
			8:
				Globals.regen_cooldown_multiplier *= 0.7
				health_regen_timer.wait_time *= 0.7
			9:
				Globals.regen_rate_multiplier *= 1.5
				regen_rate *= 1.5
			10:
				Globals.stop_death = true
				stop_death = true
		apply_shrine_buffs()

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * 2

	if is_on_floor():
		jumps = 2 + jump_changes

	# Jump Logic (Disabled when stunned)
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("wkey")) and jumps > 0 and not stun:
		velocity.y = JUMP_VELOCITY
		jumps -= 1
		if not is_on_floor():
			_handle_air_jump_animation()
	var direction := Input.get_axis("akey", "dkey")

	# Cards (Allowed during stun)
	if card_cooldown.is_stopped():
		if Input.is_action_just_pressed("card1"):
			card(0)
		if Input.is_action_just_pressed("card2"):
			card(1)
		if Input.is_action_just_pressed("card3"):
			card(2)
		if Input.is_action_just_pressed("card4"):
			card(3)

	if not card_cooldown.is_stopped():
		$Label.text = str(ceil(card_cooldown.time_left))
		$Label.show()
	else:
		$Label.hide()

	# Horizontal Movement & Dash
	if stun:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if Input.is_action_just_pressed("dash") and cooldown_timer.is_stopped() and six_timer.is_stopped():
			dash_sound.play()
			if direction != 0:
				current_direction = sign(direction)
			else:
				current_direction = pivot.scale.x
			velocity.x = 19000.0 * current_direction
			length_timer.start()
			cooldown_timer.start()

		if not length_timer.is_stopped():
			velocity.x = 2000 * current_direction
		elif direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Sprite Animations
	if not length_timer.is_stopped() and (direction == pivot.scale.x or direction == 0):
		sprite.animation = "dash"
		sprite.offset.y = -40
	elif not length_timer.is_stopped() and direction != pivot.scale.x and direction != 0:
		sprite.animation = "backdash"
		sprite.offset.y = -40
	elif not is_on_floor():
		if sprite.animation != "doublejump" or not sprite.is_playing():
			sprite.animation = "jump"
		sprite.offset.y = 0
	elif direction != 0 and not stun:
		sprite.animation = "walk"
		sprite.offset.y = -20
	else:
		sprite.animation = "neutral"
		sprite.offset.y = 0
	sprite.play()

	if not length_timer.is_stopped():
		velocity.y = 0
	if not length_timer.is_stopped() and velocity.x == 0:
		length_timer.stop()

	if health <= 0:
		if stop_death and other_invulnerable_timer.is_stopped():
			health = 1
			invulnerable = true
			invulnerable_timer.start()
			other_invulnerable_timer.start()
			Globals.save_card_data()
		else:
			$CollisionShape2D.set_deferred("disabled", true)
			Globals.reset_game_state()
			get_tree().change_scene_to_file(start_level_path)
			return

	if bounce:
		velocity.y = -3000
		bounce = false

	if health_regen_timer.is_stopped() and health < max_health:
		health = min(health + (regen_rate * delta), max_health)
		health_changed.emit(health, max_health)

	if two_timer.is_stopped():
		$Area2D1/Sprite2D.hide()
		$Area2D1.set_deferred("monitoring", false)
		$Area2D1.set_deferred("monitorable", false)
		$Area2D1.remove_from_group("bleed")
		$Area2D1.remove_from_group("slow")
		$Area2D1.remove_from_group("shock")
		$Area2D1.remove_from_group("burn")

	$Marker2D.look_at(get_global_mouse_position())
	$StaticBody2D/Label.text = str(ceil(six_timer.time_left))

	move_and_slide()

# Sample stun trigger on enemy hit:
func _on_area_2d_player_body_entered(body) -> void:
	if body.is_in_group("Enemies") or body.get_parent().is_in_group("Enemies"):
		take_damage(20 * Globals.damage_reduction)

func take_damage(amount: int) -> void:
	if not invulnerable:
		$Camera2D.add_trauma(0.6)
		$CanvasLayer/ColorRect.flash_damage(0.5, 0.4)
		invulnerable = true
		if overshield > 0:
			overshield -= amount
			if overshield < 0:
				health += overshield
				overshield = 0
				health_changed.emit(health, max_health)
				health_regen_timer.start()
			overshield_changed.emit(overshield)
		else:
			health -= amount
			health_changed.emit(health, max_health)
			health_regen_timer.start()
		if health>0:
			iframes_timer.start()

func equip_weapon(weapon_scene: PackedScene):
	if current_weapon_node != null:
		current_weapon_node.queue_free()
	current_weapon_node = weapon_scene.instantiate()
	weapon_slot.add_child(current_weapon_node)

func _on_character_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hazards") or area.get_parent().is_in_group("Hazards"):
		active_hazards.append(area)
		take_damage(25 * Globals.damage_reduction)
		if hazard_timer.is_stopped():
			hazard_timer.start()
	if area.is_in_group("bouncepads") or area.get_parent().is_in_group("bouncepads"):
		bounce = true
	if area.is_in_group("shrine") and "is_active" in area and area.is_active:
		shrine = true
		current_shrine = area
	if area.is_in_group("downlaser"):
		take_damage(15 * Globals.damage_reduction)
	if area.is_in_group("twins_laser"):
		take_damage(40 * Globals.damage_reduction)

func _on_character_area_2d_area_exited(area: Area2D) -> void:
	if area in active_hazards:
		active_hazards.erase(area)
	if active_hazards.is_empty():
		hazard_timer.stop()
	if area.is_in_group("shrine"):
		shrine = false
		current_shrine = null

func _on_hazard_timer_timeout() -> void:
	active_hazards = active_hazards.filter(func(a): 
		return is_instance_valid(a) and a.is_visible_in_tree() and (a.monitoring or a.monitorable)
	)
	if not active_hazards.is_empty():
		take_damage(25 * Globals.damage_reduction)
	else:
		hazard_timer.stop()

func card(num: int) -> void:
	if num >= Globals.hand.size() or Globals.hand[num] == "empty":
		return
	card_cooldown.start()
	ability = Globals.hand[num]
	var should_discard: bool = true
	
	if no_discard and randi_range(1, 10) == 6:
		should_discard = false
	elif Globals.seven:
		should_discard = false
		Globals.seven = false
		$pivot/Buff_Aura.play("empty")
		
	if should_discard:
		Globals.discard = Globals.hand[num]
		
		# Check if THIS specific slot deck has cards left
		if num < Globals.deck.size() and not Globals.deck[num].is_empty():
			Globals.hand[num] = Globals.deck[num].pop_front() # Safely draws and removes index 0
		else:
			Globals.hand[num] = "empty" # Sets slot to empty instead of removing the array index

	match ability:
		"5C", "5D", "5H", "5S":
			Globals.damage_buff_5 = 1.75
			five_timer.start()
			$pivot/Buff_Aura.play(ability)
		"9C", "9D", "9H", "9S":
			Globals.damage_reduction = 0.1
			nine_timer.start()
			$pivot/Buff_Aura.play(ability)
		"7H", "7C", "7D", "7S":
			$pivot/Buff_Aura.play(ability)
			Globals.seven = true 
		"6D", "6C", "6H", "6S":
			$StaticBody2D.show()
			$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
			SPEED = 0
			JUMP_VELOCITY = 0
			invulnerable = true
			six_timer.start()
			$StaticBody2D/Label.show()
		"10D", "10C", "10H", "10S":
			slash()
		"2D":
			$Area2D1/Sprite2D.show()
			$Area2D1.set_deferred("monitoring", true)
			$Area2D1.set_deferred("monitorable", true)
			$Area2D1/Sprite2D.play("2D")
			$Area2D1.add_to_group("slow")
			two_timer.start()
		"2C":
			$Area2D1/Sprite2D.show()
			$Area2D1.set_deferred("monitoring", true)
			$Area2D1.set_deferred("monitorable", true)
			$Area2D1/Sprite2D.play("2C")
			$Area2D1.add_to_group("shock")
			two_timer.start()
		"2S":
			$Area2D1/Sprite2D.show()
			$Area2D1.set_deferred("monitoring", true)
			$Area2D1.set_deferred("monitorable", true)
			$Area2D1/Sprite2D.play("2S")
			$Area2D1.add_to_group("bleed")
			two_timer.start()
		"2H":
			$Area2D1/Sprite2D.show()
			$Area2D1.set_deferred("monitoring", true)
			$Area2D1.set_deferred("monitorable", true)
			$Area2D1/Sprite2D.play("2H")
			$Area2D1.add_to_group("burn")
			two_timer.start()
		"3H", "3S", "3C", "3D":
			overshield += 30
			overshield_changed.emit(overshield)
		"4S":
			shoot_el_proj("bleed")
		"4C":
			shoot_el_proj("shock")
		"4D":
			shoot_el_proj("slow")
		"4H":
			shoot_el_proj("burn")
		"8S":
			pierce_proj("bleed")
		"8C":
			pierce_proj("shock")
		"8D":
			pierce_proj("slow")
		"8H":
			pierce_proj("burn")
		"AC":
			spawn_lightning_at(get_global_mouse_position())
		"AH":
			shoot_laser()
		"JH":
			shoot_expl_proj()
		"JS":
			for i in range(Globals.hand.size() - 1, -1, -1):
				card(i)
		"QS":
			queen_timer.start()
			Globals.queen_buff = 3
			$pivot/Buff_Aura.play("QS")
		"KC":
			kingc_timer.start()
			cooldown_timer.wait_time = 0.3
			$pivot/Buff_Aura.play("KC")
		"QH":
			overshield += 30
			overshield_changed.emit(overshield)
			health = max_health
			health_changed.emit(health, max_health)
			
func shoot_laser():
	$pivot/Area2D2/AnimatedSprite2D.show()
	$pivot/Area2D2/AnimatedSprite2D.play("shoot")

func spawn_lightning_at(target_pos: Vector2) -> void:
	var space_state = get_world_2d().direct_space_state
	var ray_start = target_pos
	var ray_end = Vector2(target_pos.x, target_pos.y + 10000)
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.collision_mask = 3
	
	var result = space_state.intersect_ray(query)
	if result:
		var ground_impact_point: Vector2 = result.position
		var lightning = LIGHTNING_SCENE.instantiate()
		lightning.global_position = ground_impact_point - Vector2(0, 2)
		get_parent().add_child(lightning)
		lightning.add_to_group("shock")

func slash():
	var instance = downslash.instantiate()
	get_parent().add_child(instance)
	instance.global_position = get_global_mouse_position()

func _on_five_timer_timeout() -> void:
	Globals.damage_buff_5 = 1
	$pivot/Buff_Aura.play("empty")

func shoot_el_proj(element):
	var b = el_projectile.instantiate()
	get_parent().add_child(b)
	b.global_transform = $Marker2D.global_transform
	b.setup(element)
	b.add_to_group(element)

func shoot_expl_proj():
	var b = expl_projectile.instantiate()
	get_parent().add_child(b)
	b.global_transform = $Marker2D.global_transform

func pierce_proj(element):
	var b = pierce_projectile.instantiate()
	get_parent().add_child(b)
	b.global_transform = $Marker2D.global_transform
	b.setup(element)
	b.add_to_group(element)

func _on_nine_timer_timeout() -> void:
	Globals.damage_reduction = 1
	$pivot/Buff_Aura.play("empty")

func _on_six_timer_timeout() -> void:
	$StaticBody2D.hide()
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	SPEED = 500 * (1.3 ** speed_buffs)
	JUMP_VELOCITY = -1000
	$StaticBody2D/Label.hide()
	invulnerable = false

func _on_invulnerable_timer_timeout() -> void:
	if six_timer.is_stopped():
		invulnerable = false

func is_mouse_inside_object(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 3
	query.collide_with_bodies = true 
	query.collide_with_areas = false
	var hits = space_state.intersect_point(query)
	return not hits.is_empty()

func _on_laser_animation_finished() -> void:
	$pivot/Area2D2/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(1.0).timeout 
	$pivot/Area2D2/CollisionShape2D.set_deferred("disabled", true)
	$pivot/Area2D2/AnimatedSprite2D.hide()

func _on_queen_timer_timeout() -> void:
	Globals.queen_buff = 1
	$pivot/Buff_Aura.play("empty")

func _on_king_c_timer_timeout() -> void:
	cooldown_timer.wait_time = 1.0
	$pivot/Buff_Aura.play("empty")

func _on_i_frames_timeout() -> void:
	invulnerable = false

func apply_stun(duration: float) -> void:
	stun = true
	stun_timer.start(duration)

func _on_stun_timer_timeout() -> void:
	stun = false
	
func _handle_air_jump_animation() -> void:
	sprite.play("doublejump")
	await get_tree().create_timer(0.2).timeout
	# Only switch back to "jump" if still in the air
	if not is_on_floor():
		sprite.play("jump")
