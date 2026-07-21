extends StaticBody2D
var snuggles_health=1000
@export var laser: PackedScene
@onready var attack_timer: Timer = $AttackTimer
@onready var length_timer: Timer = $LengthTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var spike_timer: Timer = $SpikeTimer
var random
var player: CharacterBody2D
signal boss_health_changed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print("Boss health: "+str(snuggles_health))	
	var enemy_pos = global_position
	var distance_to_player = enemy_pos.distance_to(player.global_position)
	if distance_to_player<= 1000:
		visible=true
	if distance_to_player<=1700 and visible:
		if cooldown_timer.is_stopped():
			random = randi_range(1,2)
			cooldown_timer.start()
			if random == 1:
				length_timer.start()
			elif random == 2:
				spike_timer.start()
				spike()
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
		queue_free()
	if not spike_timer.is_stopped():
		$Spikes.position.x+=10
		$Spikes2.position.x-=10
func laser_fire():
	var b = laser.instantiate()
	get_parent().add_child(b)
	b.global_transform = $pivot/Muzzle.global_transform
	b.add_to_group("Enemies")

func spike():
	$Spikes.set_deferred("monitoring", true)
	$Spikes.set_deferred("monitorable", true)
	$Spikes2.set_deferred("monitoring", true)
	$Spikes2.set_deferred("monitorable", true)
	$Spikes.show()
	$Spikes2.show()
	$Spikes.position.x=1209
	$Spikes2.position.x=-909
func _on_snuggles_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		snuggles_health-=30
	elif area.is_in_group("Arrow"):
		snuggles_health-=40
	boss_health_changed.emit(snuggles_health)
