extends StaticBody2D
@export var projectile : PackedScene
@onready var shot_timer: Timer = $ShotTimer
@onready var burn_timer: Timer = $BurnTimer
@onready var slow_timer: Timer = $SlowTimer
@onready var shock_timer: Timer = $ShockTimer
@onready var bleed_timer: Timer = $BleedTimer
@onready var sprite: Sprite2D = $Sprite2D
var ranged_health=100
var player: CharacterBody2D
var bleed = false
var shocked = 0
var slow = 1
var burn=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemy_pos = global_position
	var distance_to_player = enemy_pos.distance_to(player.global_position)
	if distance_to_player<=1700:
		if shot_timer.is_stopped():
			shoot()
			shot_timer.wait_time= 2*slow
			shot_timer.start()
	$Muzzle.look_at(player.global_position)
	if player.global_position.x < enemy_pos.x:
		$Sprite2D.flip_h=true
	elif player.global_position.x>enemy_pos.x:
		$Sprite2D.flip_h=false
	if ranged_health<=0:
		if randi_range(1, 7) == 6:
			var valid_slots: Array[int] = []
			for i in range(Globals.card_pool.size()):
				if not Globals.card_pool[i].is_empty():
					valid_slots.append(i)
			if not valid_slots.is_empty():
				var slot_idx: int = valid_slots.pick_random()
				Globals.card_pool[slot_idx].shuffle()
				var new_card: String = Globals.card_pool[slot_idx].pop_front()
				Globals.all_cards[slot_idx].append(new_card)
				if slot_idx < Globals.hand.size() and Globals.hand[slot_idx] == "empty":
					Globals.hand[slot_idx] = new_card
				else:
					Globals.deck[slot_idx].append(new_card)
				var label = get_tree().get_first_node_in_group("card_ui")
				if label and label.has_method("display_obtained_card"):
					label.display_obtained_card(new_card)
		
		queue_free()
	if bleed:
		$rangedenemyhealth.health_changed(ranged_health-max(ranged_health - (4 * delta), 0))
		ranged_health = max(ranged_health - (13 * delta), 0)
	if burn:
		$rangedenemyhealth.health_changed(ranged_health-max(ranged_health - (5 * delta), 0))
		ranged_health = max(ranged_health - (15 * delta), 0)
	if slow_timer.is_stopped():
		slow = 1
	if shock_timer.is_stopped():
		shocked = 0
	if bleed_timer.is_stopped():
		bleed = false
	if burn_timer.is_stopped():
		burn = false
func shoot():
	var b = projectile.instantiate()
	get_parent().add_child(b)
	b.global_transform = $Muzzle.global_transform
	b.add_to_group("Enemies")
	
func _on_rangedenemy_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		$rangedenemyhealth.rangedenemy_health_changed(35*Globals.damage_buff_5*Globals.sword_increase*Globals.queen_buff+shocked)
		ranged_health-=35*Globals.damage_buff_5*Globals.sword_increase*Globals.queen_buff+shocked
	elif area.is_in_group("Arrow"):
		$rangedenemyhealth.rangedenemy_health_changed(40*Globals.damage_buff_5*Globals.bow_increase*Globals.queen_buff+shocked)
		ranged_health-=40*Globals.damage_buff_5*Globals.bow_increase*Globals.queen_buff+shocked
	elif area.is_in_group("2D"):
		$rangedenemyhealth.rangedenemy_health_changed(25*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=25*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("downslash"):
		$rangedenemyhealth.rangedenemy_health_changed(200*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=200*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("elemental_projectile"):
		$rangedenemyhealth.rangedenemy_health_changed(150*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("pierceproj"):
		$rangedenemyhealth.rangedenemy_health_changed(100*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("lightning"):
		$rangedenemyhealth.rangedenemy_health_changed(300*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=300*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("laser"):
		$rangedenemyhealth.rangedenemy_health_changed(350*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=350*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("dash"):
		$rangedenemyhealth.rangedenemy_health_changed(75*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=75*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosion"):
		$rangedenemyhealth.rangedenemy_health_changed(150*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=150*Globals.damage_buff_5*Globals.card_increase+shocked
	elif area.is_in_group("explosive_proj"):
		$rangedenemyhealth.rangedenemy_health_changed(100*Globals.damage_buff_5*Globals.card_increase+shocked)
		ranged_health-=100*Globals.damage_buff_5*Globals.card_increase+shocked
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
func flash_red() -> void:
	var mat = sprite.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.15)
