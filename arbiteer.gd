extends CharacterBody2D
@onready var burn_timer: Timer = $BurnTimer
@onready var slow_timer: Timer = $SlowTimer
@onready var shock_timer: Timer = $ShockTimer
@onready var bleed_timer: Timer = $BleedTimer
var player
const SPEED = 500.0
var shocked: float = 0.0
var slow: float = 1.0
var burn: bool = false
var bleed: bool = false
var direction = -1
var attack = false
var random_number
var arbiter_health=6500
signal arbiter_health_changed(new_health: float)
@onready var direction_timer: Timer = $DirectionTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@export var spike: PackedScene
@export var aoe: PackedScene
@export var wave: PackedScene
@export var stun_proj: PackedScene
var arbiter_health_bar
func _ready():
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	direction_timer.start()
	arbiter_health_bar = get_tree().get_first_node_in_group("boss4_health_bar") as CanvasItem

func _physics_process(delta: float) -> void:
	# Add the gravity.
	$Marker2D.look_at(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player<=1000:
		attack = true
		$Area2D.set_deferred("monitorable",true)
		$Area2D.set_deferred("monitoring",true)
	if attack:
		if cooldown_timer.is_stopped():
			random_number=randi_range(1,4)
			if random_number==1:
				spawn_spike(player.global_position.x)
				spawn_spike(player.global_position.x+randi_range(-1000,1000))
			elif random_number == 2:
				aoe_summon(player.global_position.x-323.0,player.global_position.y-298.0)
				aoe_summon(player.global_position.x-323.0+randi_range(-1000,1000),player.global_position.y-298.0+randi_range(0,1000))
				aoe_summon(player.global_position.x-323.0+randi_range(-1000,1000),player.global_position.y-298.0+randi_range(0,1000))
			elif random_number == 3:
				spawn_wave()
			elif random_number == 4:
				stun_projectile()
			cooldown_timer.start()
		if abs(player.global_position.y-global_position.y)<500:
			velocity.y -= SPEED * delta
		else:
			velocity.y += SPEED * delta
			
		if abs(player.global_position.x-global_position.x)>1000:
			if player.global_position.x < global_position.x:
				direction=-1
			elif player.global_position.x>global_position.x:
				direction=1
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	if bleed:
		arbiter_health = max(arbiter_health - (8 * delta), 0)
		arbiter_health_changed.emit(arbiter_health)
	if burn:
		arbiter_health = max(arbiter_health - (10 * delta), 0)
		arbiter_health_changed.emit(arbiter_health)
	if slow_timer.is_stopped():
		slow = 1
	if shock_timer.is_stopped():
		shocked = 0
	if bleed_timer.is_stopped():
		bleed = false
	if burn_timer.is_stopped():
		burn = false
	move_and_slide()
	
func _on_arbiter_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		arbiter_health-=35*Globals.damage_buff_5*Globals.sword_increase*Globals.queen_buff+shocked
	elif area.is_in_group("Arrow"):
		arbiter_health-=40*Globals.damage_buff_5*Globals.bow_increase*Globals.queen_buff+shocked
	elif area.is_in_group("2D"):
		arbiter_health-=25*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("downslash"):
		arbiter_health-=200*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("elemental_projectile"):
		arbiter_health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("pierceproj"):
		arbiter_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("lightning"):
		arbiter_health-=300*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("laser"):
		arbiter_health-=350*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("dash"):
		arbiter_health-=75*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosion"):
		arbiter_health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosive_proj"):
		arbiter_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
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
	arbiter_health_changed.emit(arbiter_health)
	if arbiter_health<=0:
		if is_instance_valid(arbiter_health_bar):
			arbiter_health_bar.hide()
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

func _on_direction_timer_timeout() -> void:
	if abs(player.global_position.x-global_position.x)<1000:
		direction*=-1
		direction_timer.start()
		
func spawn_spike(x):
	var instance = spike.instantiate()
	get_parent().add_child(instance)
	instance.global_position = Vector2(x,player.global_position.y-700)
	
func aoe_summon(x,y):
	var instance = aoe.instantiate()
	get_parent().add_child(instance)
	instance.global_position = Vector2(x,y)

func spawn_wave():
	var instance = wave.instantiate()
	get_parent().add_child(instance)
	if player.global_position.x < global_position.x:
		instance.direction=-1
	elif player.global_position.x>global_position.x:
		instance.direction=1
	instance.global_position = Vector2(global_position.x,global_position.y)

func stun_projectile():
	var instance = stun_proj.instantiate()
	get_parent().add_child(instance)
	instance.global_transform = $Marker2D.global_transform



func flash1_red() -> void:
	var mat = $Sprite2D.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
func flash2_red() -> void:
	var mat = $Sprite2D2.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
