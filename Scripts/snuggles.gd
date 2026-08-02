extends StaticBody2D
var snuggles_health=2000
@export var laser: PackedScene
@export var enemy: PackedScene
@onready var attack_timer: Timer = $AttackTimer
@onready var length_timer: Timer = $LengthTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var spike_timer: Timer = $SpikeTimer
@onready var burn_timer: Timer = $BurnTimer
@onready var slow_timer: Timer = $SlowTimer
@onready var shock_timer: Timer = $ShockTimer
@onready var bleed_timer: Timer = $BleedTimer
var bleed=false
var random
var boss_health_bar
var gate
var player: CharacterBody2D
signal boss_health_changed
var is_spawning: bool = false
var is_active: bool = false
var shocked = 0
var slow = 1
var burn=false
@onready var laser_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	boss_health_bar = get_tree().get_first_node_in_group("boss_health_bar") as CanvasItem
	gate=get_tree().get_first_node_in_group("gate") as CollisionShape2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemy_pos = global_position
	var distance_to_player = enemy_pos.distance_to(player.global_position)
	if distance_to_player <= 1000 and not visible and not is_spawning:
		spawn_boss()
		$Area2D.set_deferred("monitorable", true)
		$Area2D.set_deferred("monitoring", true)
	if not is_active:
		return
	if distance_to_player<=3000 and visible:
		if cooldown_timer.is_stopped():
			random = randi_range(1,3)
			cooldown_timer.wait_time = 5.0*slow
			cooldown_timer.start()
			if random == 1:
				length_timer.start()
			elif random == 2:
				spike_timer.start()
				spike()
				length_timer.start()
			elif random == 3:
				spawn_enemy(Vector2(enemy_pos.x-300,enemy_pos.y))
				spawn_enemy(Vector2(enemy_pos.x,enemy_pos.y))
				length_timer.start()
		if not length_timer.is_stopped():
			if attack_timer.is_stopped():
				laser_fire()
				attack_timer.start()
		if spike_timer.is_stopped():
			$Spikes.set_deferred("monitoring", false)
			$Spikes.set_deferred("monitorable", false)
			$Spikes2.set_deferred("monitoring", false)
			$Spikes2.set_deferred("monitorable", false)
			$Spikes.hide()
			$Spikes2.hide()
	$pivot/Muzzle.look_at(player.global_position)
	if player.global_position.x < enemy_pos.x:
		$pivot.scale.x=1
	elif player.global_position.x>enemy_pos.x:
		$pivot.scale.x=-1
	if snuggles_health<=0:
		if is_instance_valid(boss_health_bar):
			boss_health_bar.hide()
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
		gate.queue_free()
		queue_free()
		set_process(false)
		return
	if not spike_timer.is_stopped():
		$Spikes.position.x+=10*delta
		$Spikes2.position.x-=10*delta
	if bleed:
		snuggles_health = max(snuggles_health - (13 * delta), 0)
		boss_health_changed.emit(snuggles_health)
	if burn:
		snuggles_health = max(snuggles_health - (15 * delta), 0)
		boss_health_changed.emit(snuggles_health)
	if slow_timer.is_stopped():
		slow = 1
	if shock_timer.is_stopped():
		shocked = 0
	if bleed_timer.is_stopped():
		bleed = false
	if burn_timer.is_stopped():
		burn = false
func laser_fire():
	var b = laser.instantiate()
	get_parent().add_child(b)
	b.global_transform = $pivot/Muzzle.global_transform
	laser_sound.play()
	b.add_to_group("Enemies")

func spike():
	$Spikes.set_deferred("monitoring", true)
	$Spikes.set_deferred("monitorable", true)
	$Spikes2.set_deferred("monitoring", true)
	$Spikes2.set_deferred("monitorable", true)
	$Spikes.show()
	$Spikes2.show()
	$Spikes.position.x=300
	$Spikes2.position.x=0
func spawn_boss() -> void:
	is_spawning = true
	visible = true
	await get_tree().create_timer(3.0).timeout
	is_active = true
func _on_snuggles_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		snuggles_health-=35*Globals.damage_buff_5*Globals.sword_increase*Globals.queen_buff+shocked
	elif area.is_in_group("Arrow"):
		snuggles_health-=40*Globals.damage_buff_5*Globals.bow_increase*Globals.queen_buff+shocked
	elif area.is_in_group("2D"):
		snuggles_health-=25*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("downslash"):
		snuggles_health-=200*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("elemental_projectile"):
		snuggles_health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("pierceproj"):
		snuggles_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("lightning"):
		snuggles_health-=300*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("laser"):
		snuggles_health-=350*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("dash"):
		snuggles_health-=75*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosion"):
		snuggles_health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosive_proj"):
		snuggles_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
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
	flash_red()
	boss_health_changed.emit(snuggles_health)
func spawn_enemy(enemy_position: Vector2):
	var new_enemy = enemy.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.global_position = enemy_position
	
func flash_red() -> void:
	var mat = $pivot/Sprite2D.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
	
