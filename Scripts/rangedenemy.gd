extends StaticBody2D
@export var projectile : PackedScene
@onready var shot_timer: Timer = $ShotTimer
@onready var burn_timer: Timer = $BurnTimer
@onready var slow_timer: Timer = $SlowTimer
@onready var shock_timer: Timer = $ShockTimer
@onready var bleed_timer: Timer = $BleedTimer
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
		queue_free()
	if bleed:
		$rangedenemyhealth.health_changed(ranged_health-max(ranged_health - (4 * delta), 0))
		ranged_health = max(ranged_health - (4 * delta), 0)
		bleed_timer.start()
	if burn:
		$rangedenemyhealth.health_changed(ranged_health-max(ranged_health - (5 * delta), 0))
		ranged_health = max(ranged_health - (5 * delta), 0)
		burn_timer.start()
	if slow != 1:
		slow_timer.start()
	if slow_timer.is_stopped():
		slow = 1
	if shocked != 0:
		shock_timer.start()
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
		$rangedenemyhealth.rangedenemy_health_changed(30*Globals.damage_buff_5+shocked)
		ranged_health-=30*Globals.damage_buff_5+shocked
	elif area.is_in_group("Arrow"):
		$rangedenemyhealth.rangedenemy_health_changed(40*Globals.damage_buff_5+shocked)
		ranged_health-=40*Globals.damage_buff_5+shocked
	elif area.is_in_group("2D"):
		$rangedenemyhealth.rangedenemy_health_changed(10*Globals.damage_buff_5+shocked)
		ranged_health-=10*Globals.damage_buff_5+shocked
	elif area.is_in_group("downslash"):
		$rangedenemyhealth.rangedenemy_health_changed(200*Globals.damage_buff_5+shocked)
		ranged_health-=200*Globals.damage_buff_5+shocked
	elif area.is_in_group("elemental_projectile"):
		$rangedenemyhealth.rangedenemy_health_changed(150*Globals.damage_buff_5+shocked)
		ranged_health-=100*Globals.damage_buff_5+shocked
	elif area.is_in_group("pierceproje"):
		$rangedenemyhealth.rangedenemy_health_changed(100*Globals.damage_buff_5+shocked)
		ranged_health-=100*Globals.damage_buff_5+shocked
	elif area.is_in_group("lightning"):
		$rangedenemyhealth.rangedenemy_health_changed(300*Globals.damage_buff_5+shocked)
		ranged_health-=300*Globals.damage_buff_5+shocked
	if area.is_in_group("bleed"):
		bleed=true
	elif area.is_in_group("burn"):
		burn = true
	elif area.is_in_group("shock"):
		shocked = 15
	elif area.is_in_group("slow"):
		slow = 1.3
