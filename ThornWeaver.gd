extends CharacterBody2D

signal boss2_health_changed

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var hand: PackedScene
@export var down_laser: PackedScene
@export var sweep_laser: PackedScene

@onready var burn_timer: Timer = $BurnTimer
@onready var slow_timer: Timer = $SlowTimer
@onready var shock_timer: Timer = $ShockTimer
@onready var bleed_timer: Timer = $BleedTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var primordial_health: float = 4000.0
var shocked: float = 0.0
var slow: float = 1.0
var burn: bool = false
var bleed: bool = false
var is_attacking: bool = false
var boss2_health_bar
var player: CharacterBody2D
signal summon_portal
func _ready() -> void:
	animated_sprite.play("default")
	boss2_health_bar = get_tree().get_first_node_in_group("boss2_health_bar") as CanvasItem
	_find_player()

func _physics_process(delta: float) -> void:
	# Ensure player exists before attempting to read coordinates
	var enemy_pos = global_position
	var distance_to_player = enemy_pos.distance_to(player.global_position)
	# Attack Triggering (prevents overlapping attack routines)
	cooldown_timer.wait_time=3*slow
	
	if cooldown_timer.is_stopped() and not is_attacking and distance_to_player<=2000:
		$Area2D.set_deferred("monitorable",true)
		$Area2D.set_deferred("monitoring",true)
		_execute_random_attack()

	if bleed:
		take_damage(13.0 * delta)
	if burn:
		take_damage(15.0 * delta)

	# Reset Status Effect Values
	if slow_timer.is_stopped():
		slow = 1.0
	if shock_timer.is_stopped():
		shocked = 0.0
	if bleed_timer.is_stopped():
		bleed = false
	if burn_timer.is_stopped():
		burn = false

	# Sprite Flipping
	if player.global_position.x < global_position.x:
		animated_sprite.flip_h = false
	elif player.global_position.x > global_position.x:
		animated_sprite.flip_h = true

	move_and_slide()

# Core Attack Routine
func _execute_random_attack() -> void:
	is_attacking = true
	cooldown_timer.start()
	
	var random_choice = randi_range(1, 3)
	
	match random_choice:
		1:
			shoot()
			animated_sprite.play("teleport")
			await get_tree().create_timer(0.2).timeout
			position.x=get_random_teleport_position().x
			animated_sprite.play("default")
		2:
			shoot1(randi_range(-1500, 1500))
			shoot1(randi_range(-1500, 1500))
			shoot1(0)
			animated_sprite.play("teleport")
			await get_tree().create_timer(0.2).timeout
			position.x=get_random_teleport_position().x
			animated_sprite.play("default")
		3:
			animated_sprite.play("teleport")
			await get_tree().create_timer(0.2).timeout
			var spot = get_tree().get_first_node_in_group("laser_spot")
			position=spot.global_position
			animated_sprite.play("default")
			shoot2()
			await get_tree().create_timer(3.0).timeout
			animated_sprite.play("teleport")
			await get_tree().create_timer(0.2).timeout
			position=get_random_teleport_position()
			animated_sprite.play("default")
	is_attacking = false

func take_damage(amount: float) -> void:
	primordial_health = max(primordial_health - amount, 0.0)
	boss2_health_changed.emit(primordial_health)
	if primordial_health <= 0:
		die()
func get_random_teleport_position() -> Vector2:
	var spots = get_tree().get_nodes_in_group("boss_teleport_spots")
	if spots.size() > 0:
		var random_spot = spots.pick_random() as Node2D
		if abs(player.global_position.x-random_spot.global_position.x)<200:
			return spots.pick_random().global_position
		else:
			return random_spot.global_position
	return global_position
	
func die() -> void:
	summon_portal.emit()
	if is_instance_valid(boss2_health_bar):
			boss2_health_bar.hide()
	if not Globals.phase_card_pool.is_empty():
		var valid_slots: Array[int] = []
		for i in range(Globals.phase_card_pool.size()):
			if not Globals.phase_card_pool[i].is_empty():
				valid_slots.append(i)
		if not valid_slots.is_empty():
			var slot_idx: int = valid_slots.pick_random()
			Globals.phase_card_pool[slot_idx].shuffle()
			var new_card: String = Globals.phase_card_pool[slot_idx].pop_front()
			Globals.all_cards[slot_idx].append(new_card)
			if slot_idx < Globals.hand.size() and Globals.hand[slot_idx] == "empty":
				Globals.hand[slot_idx] = new_card
			else:
				Globals.deck[slot_idx].append(new_card)
			var label = get_tree().get_first_node_in_group("card_ui")
			if label and label.has_method("display_obtained_card"):
				label.display_obtained_card(new_card)
	queue_free()
	set_process(false)

func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

# Projectile Spawners
func shoot() -> void:
	var b = hand.instantiate()
	get_parent().add_child(b)
	b.global_position = Vector2(player.global_position.x, player.global_position.y - 800)

func shoot1(x_offset: int) -> void:
	if not down_laser: return
	var b = down_laser.instantiate()
	get_parent().add_child(b)
	var safe_x = get_safe_laser_x(x_offset)
	b.global_position = Vector2(safe_x, global_position.y+480)

func shoot2() -> void:
	if not sweep_laser or not is_instance_valid(player): return
	var b = sweep_laser.instantiate()
	var boss_is_facing_left: bool = global_position.x > player.global_position.x
	b.is_facing_left = not boss_is_facing_left
	get_parent().add_child(b)
	b.global_position = $Marker2D.global_position

func _on_thornweaver_area_2d_area_entered(area: Area2D) -> void:
	var damage: float = 0.0
	if area.is_in_group("Sword"):
		damage = 35 * Globals.damage_buff_5 * Globals.sword_increase * Globals.queen_buff + shocked
	elif area.is_in_group("Arrow"):
		damage = 40 * Globals.damage_buff_5 * Globals.bow_increase * Globals.queen_buff + shocked
	elif area.is_in_group("2D"):
		damage = 25 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("downslash"):
		damage = 200 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("elemental_projectile"):
		damage = 150 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("pierceproj"):
		damage = 100 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("lightning"):
		damage = 300 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("laser"):
		damage = 350 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("dash"):
		damage = 75 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("explosion"):
		damage = 150 * Globals.damage_buff_5 * Globals.card_increase + shocked
	elif area.is_in_group("explosive_proj"):
		damage = 100 * Globals.damage_buff_5 * Globals.card_increase + shocked

	if damage > 0:
		take_damage(damage)
		if not area.is_in_group("player"):
			flash_red()
	if area.is_in_group("bleed") or (area.get_parent() and area.get_parent().is_in_group("bleed")):
		bleed_timer.start()
		bleed = true
	if area.is_in_group("burn") or (area.get_parent() and area.get_parent().is_in_group("burn")):
		bleed_timer.start()
		bleed = true
	if area.is_in_group("shock") or (area.get_parent() and area.get_parent().is_in_group("shock")):
		bleed_timer.start()
		bleed = true
	if area.is_in_group("slow") or (area.get_parent() and area.get_parent().is_in_group("slow")):
		bleed_timer.start()
		bleed = true
func get_safe_laser_x(x_offset: float) -> float:
	if not is_instance_valid(player):
		return global_position.x
	var space_state = get_world_2d().direct_space_state
	var player_pos = player.global_position
	var target_pos = player_pos + Vector2(x_offset, 0)
	var query = PhysicsRayQueryParameters2D.create(player_pos, target_pos)
	query.exclude = [self, player]
	var hit = space_state.intersect_ray(query)
	if hit:
		var pushback_dir = sign(player_pos.x - hit.position.x)
		return hit.position.x + (pushback_dir * 40.0)
	return target_pos.x
	
func flash_red() -> void:
	var mat = animated_sprite.material as ShaderMaterial
	if mat and animated_sprite.animation=="default":
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
