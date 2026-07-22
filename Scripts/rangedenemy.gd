extends StaticBody2D
@export var projectile : PackedScene
@onready var shot_timer: Timer = $ShotTimer
var ranged_health=100
var player: CharacterBody2D
var bleed = false
var shocked = 0
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
			shot_timer.start()
	$Muzzle.look_at(player.global_position)
	if player.global_position.x < enemy_pos.x:
		$Sprite2D.flip_h=true
	elif player.global_position.x>enemy_pos.x:
		$Sprite2D.flip_h=false
	if ranged_health<=0:
		queue_free()
	if bleed:
		$rangedenemyhealth.health_changed(ranged_health-max(ranged_health - (2 * delta), 0))
		ranged_health = max(ranged_health - (2 * delta), 0)
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
