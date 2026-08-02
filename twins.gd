extends CharacterBody2D 

const SPEED = 300.0
const JUMP_VELOCITY = -1000.0
var player
var shocked: float = 0.0
var slow: float = 1.0
var burn: bool = false
var bleed: bool = false
var twins_health=5500

signal summon_portal
@onready var burn_timer: Timer = $BurnTimer
@onready var slow_timer: Timer = $SlowTimer
@onready var shock_timer: Timer = $ShockTimer
@onready var bleed_timer: Timer = $BleedTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var split_timer: Timer = $SplitTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var rotation_timer: Timer = $RotationTimer
@onready var hand_cooldown_timer: Timer = $HandCooldownTimer
@export var homing_hands: PackedScene
@export var speed: float = 900.0
@export var turn_speed: float = 2
var slam = false
var slam_recovery_timer: float = 0.0
signal twins_health_changed
var no_hands=""
var active_hand: Node2D = null
var is_active: bool = false
var twins_health_bar
var is_split=false
var area2d2_start_pos: Vector2
var area2d2_start_rot: float
var split_delay: float = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	$pivot/AnimatedSprite2D.play("default")
	twins_health_bar = get_tree().get_first_node_in_group("boss3_health_bar") as CanvasItem
	hand_cooldown_timer.start()
	area2d2_start_pos = $Area2D2.position
	area2d2_start_rot = $Area2D2.rotation

func _physics_process(delta: float) -> void:
	cooldown_timer.wait_time=3*slow
	var enemy_pos = global_position
	var distance_to_player = enemy_pos.distance_to(player.global_position)
	if distance_to_player <= 1000:
		is_active=true
		$pivot/Area2D.set_deferred("monitorable", true)
		$pivot/Area2D.set_deferred("monitoring", true)
	if not is_active:
		return
	if randi_range(1,3)==2 and no_hands=="" and not is_split and cooldown_timer.is_stopped() and is_on_floor():
		velocity.x=0
		split_timer.start()
		is_split=true
		split_delay = 1.0
		$pivot/AnimatedSprite2D.play("split")
		await get_tree().create_timer(0.5).timeout
		$pivot/Area2D.set_deferred("monitorable",false)
		$pivot/Area2D.set_deferred("monitoring",false)
		if player.global_position.x < enemy_pos.x:
			$Area2D.scale.x=-1
		elif player.global_position.x>enemy_pos.x:
			$Area2D.scale.x=1
		$Area2D2.show()
		$Area2D.show()
		$Area2D2.set_deferred("monitorable",true)
		$Area2D2.set_deferred("monitoring",true)
		$Area2D.set_deferred("monitorable",true)
		$Area2D.set_deferred("monitoring",true)
		$pivot/AnimatedSprite2D.hide()
		await get_tree().create_timer(1).timeout
		$Area2D/Area2D.show()
		$Area2D/Area2D.set_deferred("monitorable",true)
		$Area2D/Area2D.set_deferred("monitoring",true)
		await get_tree().create_timer(0.7).timeout
		$Area2D/Area2D.hide()
		$Area2D/Area2D.set_deferred("monitorable",false)
		$Area2D/Area2D.set_deferred("monitoring",false)
	if split_timer.is_stopped():
		is_split=false
		if hand_cooldown_timer.is_stopped():
			hand_cooldown_timer.start()
			shoot_hands()
		if is_instance_valid(active_hand):
			no_hands="no_hands_"
		else:
			no_hands=""
		if player.global_position.x < enemy_pos.x:
			$pivot.scale.x=1
		elif player.global_position.x>enemy_pos.x:
			$pivot.scale.x=-1
		if cooldown_timer.is_stopped() and is_on_floor():
			velocity.y=JUMP_VELOCITY
			cooldown_timer.start()
			jump_timer.start()
		if is_on_floor():
			velocity.x = 0
			if slam:
				slam = false
				slam_recovery_timer = 0.7
				$pivot/AnimatedSprite2D.play(no_hands+"slam")
				_set_spikes_enabled(true)
			if slam_recovery_timer > 0:
				slam_recovery_timer -= delta
				if slam_recovery_timer <= 0:
					_set_spikes_enabled(false)
					$pivot/AnimatedSprite2D.play(no_hands + "default")
					if cooldown_timer.is_stopped():
						velocity.y = JUMP_VELOCITY
						cooldown_timer.start()
						jump_timer.start()
		else:
			velocity.x = $pivot.scale.x * 500 * -1
			
			if ((abs(enemy_pos.x - player.global_position.x) < 300 or jump_timer.is_stopped()) and enemy_pos.y < player.global_position.y-400) or slam:
				velocity += get_gravity() * delta * 10
				$pivot/AnimatedSprite2D.play(no_hands+"slam")
				slam = true
			else:
				velocity += get_gravity() * delta * 1/2
				$pivot/AnimatedSprite2D.play(no_hands+"jump")
	else:
		var target_angle: float = (player.global_position - $Area2D2.global_position).angle()
		$Area2D2.rotation = rotate_toward($Area2D2.rotation, target_angle, turn_speed * delta)
		if split_delay > 0:
			split_delay -= delta
		else:
			$Area2D2.position += Vector2.RIGHT.rotated($Area2D2.rotation) * speed * delta

	if bleed:
		twins_health = max(twins_health - (13 * delta), 0)
		twins_health_changed.emit(twins_health)
	if burn:
		twins_health = max(twins_health - (15 * delta), 0)
		twins_health_changed.emit(twins_health)
	if slow_timer.is_stopped():
		slow = 1
	if shock_timer.is_stopped():
		shocked = 0
	if bleed_timer.is_stopped():
		bleed = false
	if burn_timer.is_stopped():
		burn = false
	if twins_health<=0:
		summon_portal.emit()
		if is_instance_valid(twins_health_bar):
			twins_health_bar.hide()
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
	move_and_slide()
	
func _on_twins_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		twins_health-=35*Globals.damage_buff_5*Globals.sword_increase*Globals.queen_buff+shocked
	elif area.is_in_group("Arrow"):
		twins_health-=40*Globals.damage_buff_5*Globals.bow_increase*Globals.queen_buff+shocked
	elif area.is_in_group("2D"):
		twins_health-=25*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("downslash"):
		twins_health-=200*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("elemental_projectile"):
		twins_health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("pierceproj"):
		twins_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("lightning"):
		twins_health-=300*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("laser"):
		twins_health-=350*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("dash"):
		twins_health-=75*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosion"):
		twins_health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosive_proj"):
		twins_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
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
	if not area.is_in_group("player"):
		flash1_red()
	twins_health_changed.emit(twins_health)
	
func shoot_hands():
	if not is_instance_valid(active_hand) and homing_hands:
		active_hand = homing_hands.instantiate()
		get_parent().add_child(active_hand)
		active_hand.global_position = global_position
		if is_instance_valid(player):
			active_hand.look_at(player.global_position)
func _set_spikes_enabled(enabled: bool) -> void:
	$Spikes.visible = enabled
	$Spikes2.visible = enabled
	$Spikes.monitoring = enabled
	$Spikes.monitorable = enabled
	$Spikes2.monitoring = enabled
	$Spikes2.monitorable = enabled
	if enabled:
		await get_tree().physics_frame
		_check_instant_spike_damage($Spikes)
		_check_instant_spike_damage($Spikes2)

func _check_instant_spike_damage(spike_area: Area2D) -> void:
	for body in spike_area.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(25 * Globals.damage_reduction)
	for area in spike_area.get_overlapping_areas():
		if area.get_parent().is_in_group("player") and area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(25 * Globals.damage_reduction)
func _on_super_man_body_entered(body: Node2D) -> void:
	var player1 = body if body.is_in_group("player") else body.get_parent()
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		player1.take_damage(15)


func _on_split_timer_timeout() -> void:
	$pivot/AnimatedSprite2D.show()
	$Area2D2.hide()
	$Area2D.hide()
	$pivot/Area2D.set_deferred("monitorable",true)
	$pivot/Area2D.set_deferred("monitoring",true)
	$Area2D2.set_deferred("monitorable",false)
	$Area2D2.set_deferred("monitoring",false)
	$Area2D.set_deferred("monitorable",false)
	$Area2D.set_deferred("monitoring",false)
	$Area2D2.position = area2d2_start_pos
	$Area2D2.rotation = area2d2_start_rot


func _on_area_2d_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		twins_health-=35*2*Globals.damage_buff_5*Globals.sword_increase*Globals.queen_buff+shocked
	elif area.is_in_group("Arrow"):
		twins_health-=40*2*Globals.damage_buff_5*Globals.bow_increase*Globals.queen_buff+shocked
	elif area.is_in_group("2D"):
		twins_health-=25*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("downslash"):
		twins_health-=200*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("elemental_projectile"):
		twins_health-=150*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("pierceproj"):
		twins_health-=100*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("lightning"):
		twins_health-=300*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("laser"):
		twins_health-=350*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("dash"):
		twins_health-=75*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosion"):
		twins_health-=150*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosive_proj"):
		twins_health-=100*2*Globals.damage_buff_5*Globals.card_increase+shocked
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
	if not area.is_in_group("player"):
		flash3_red()
	twins_health_changed.emit(twins_health)


func _on_laser_firer_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		twins_health-=35*2*Globals.damage_buff_5*Globals.sword_increase*Globals.queen_buff+shocked
	elif area.is_in_group("Arrow"):
		twins_health-=40*2*Globals.damage_buff_5*Globals.bow_increase*Globals.queen_buff+shocked
	elif area.is_in_group("2D"):
		twins_health-=25*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("downslash"):
		twins_health-=200*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("elemental_projectile"):
		twins_health-=150*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("pierceproj"):
		twins_health-=100*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("lightning"):
		twins_health-=300*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("laser"):
		twins_health-=350*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("dash"):
		twins_health-=75*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosion"):
		twins_health-=150*2*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosive_proj"):
		twins_health-=100*2*Globals.damage_buff_5*Globals.card_increase+shocked
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
	twins_health_changed.emit(twins_health)
	if not area.is_in_group("player"):
		flash2_red()
func flash1_red() -> void:
	var mat = $pivot/AnimatedSprite2D.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
func flash2_red() -> void:
	var mat = $Area2D/Sprite2D.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
func flash3_red() -> void:
	var mat = $Area2D2/Sprite2D.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
