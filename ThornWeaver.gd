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

func _ready() -> void:
	animated_sprite.play("default")
	boss2_health_bar = get_tree().get_first_node_in_group("boss2_health_bar") as CanvasItem
	_find_player()

func _physics_process(delta: float) -> void:
	# Ensure player exists before attempting to read coordinates
	var enemy_pos = global_position
	var distance_to_player = enemy_pos.distance_to(player.global_position)
	# Attack Triggering (prevents overlapping attack routines)
	if cooldown_timer.is_stopped() and not is_attacking and distance_to_player<=2000:
		_execute_random_attack()

	# Damage Over Time (DOT)
	if bleed:
		take_damage(8.0 * delta)
	if burn:
		take_damage(10.0 * delta)

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
			position.x = randi_range(-1000, 1000)
			animated_sprite.play("default")
		2:
			shoot1(randi_range(-1000, 1000))
			shoot1(randi_range(-1000, 1000))
			shoot1(int(player.position.x))
			animated_sprite.play("teleport")
			await get_tree().create_timer(0.2).timeout
			position.x = randi_range(-1000, 1000)
			animated_sprite.play("default")
		3:
			animated_sprite.play("teleport")
			await get_tree().create_timer(0.2).timeout
			position = Vector2(0, -200)
			animated_sprite.play("default")
			shoot2()
			await get_tree().create_timer(3.0).timeout
			animated_sprite.play("teleport")
			await get_tree().create_timer(0.2).timeout
			position = Vector2(randi_range(-1000, 1000), 0)
			animated_sprite.play("default")
			
	is_attacking = false

# Centralized Health & Death System
func take_damage(amount: float) -> void:
	primordial_health = max(primordial_health - amount, 0.0)
	boss2_health_changed.emit(primordial_health)
	
	if primordial_health <= 0:
		die()

func die() -> void:
	if is_instance_valid(boss2_health_bar):
			boss2_health_bar.hide()
	queue_free()
	set_process(false)

func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

# Projectile Spawners
func shoot() -> void:
	var b = hand.instantiate()
	get_parent().add_child(b)
	b.global_position = Vector2(player.global_position.x, player.global_position.y - 800)

func shoot1(x_pos: int) -> void:
	if not down_laser: return
	var b = down_laser.instantiate()
	get_parent().add_child(b)
	b.position = Vector2(x_pos, 480)

func shoot2() -> void:
	if not sweep_laser or not is_instance_valid(player): return
	var b = sweep_laser.instantiate()
	
	# If boss is to the right of the player, boss is facing left
	var boss_is_facing_left: bool = global_position.x > player.global_position.x
	
	b.is_facing_left = not boss_is_facing_left
	get_parent().add_child(b)
	b.global_position = $Marker2D.global_position

func _on_thornweaver_area_2d_area_entered(area: Area2D) -> void:
	var damage: float = 0.0
	if area.is_in_group("Sword"):
		damage = 30 * Globals.damage_buff_5 * Globals.sword_increase * Globals.queen_buff + shocked
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

	if area.is_in_group("bleed"):
		bleed_timer.start()
		bleed = true
	elif area.is_in_group("burn"):
		burn = true
		burn_timer.start()
	elif area.is_in_group("shock"):
		shocked = 15
		shock_timer.start()
	elif area.is_in_group("slow"):
		slow = 1.5
		slow_timer.start()
