extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var overshield_bar: ProgressBar = $CanvasLayer/ProgressBar/ProgressBar
@export var bgm_track: AudioStream
@export var boss_track: AudioStream
@onready var boss4: CharacterBody2D = $arbiter
@onready var boss4_health_bar: ProgressBar = $CanvasLayer/arbiter_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(health_bar._on_player_health_changed)
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	player.overshield_changed.connect(health_bar._on_player_overshield_changed)
	overshield_bar.max_value = 240
	overshield_bar.value = player.overshield
	if is_instance_valid(boss4):
		boss4.arbiter_health_changed.connect(func(new_hp: float):
			boss4_health_bar.value = new_hp
		)
		boss4_health_bar.max_value = boss4.arbiter_health
		boss4_health_bar.value = boss4.arbiter_health
	if bgm_track:
		Music.play_music(bgm_track)
	Music.stop_boss_music()
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$StaticBody2D.show()
		$StaticBody2D/CollisionShape2D.set_deferred("disabled",false)
		if is_instance_valid(boss4):
			boss4_health_bar.show()
			Music.play_boss_music(boss_track)
			Music.stop_music()
