extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var overshield_bar: ProgressBar = $CanvasLayer/ProgressBar/ProgressBar
@onready var boss: CharacterBody2D = $thornweaver
@onready var boss2_health_bar: ProgressBar = $CanvasLayer/boss_health
@onready var portal: Area2D = $portal
@export var bgm_track: AudioStream
@export var boss_track: AudioStream
@export_file("*.tscn", "*.scn") var start_level_path: String = "res://loading_screen.tscn"
@export_file("*.scn") var target_level_path: String = "res://level3.scn"
func _ready() -> void:
	player.health_changed.connect(health_bar._on_player_health_changed)
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	player.overshield_changed.connect(health_bar._on_player_overshield_changed)
	overshield_bar.max_value = 240
	overshield_bar.value = player.overshield
	if is_instance_valid(boss):
		boss.boss2_health_changed.connect(func(new_hp: float): 
			boss2_health_bar.value = new_hp
		)
		boss2_health_bar.max_value = boss.primordial_health
		boss2_health_bar.value = boss.primordial_health
	if bgm_track:
		Music.play_music(bgm_track)
	Music.stop_boss_music()

# Trigger using BODY_ENTERED for CharacterBody2D player
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body == player:
		if is_instance_valid(boss):
			boss2_health_bar.show()
		Music.play_boss_music(boss_track)
		Music.stop_music()

func _on_thornweaver_summon_portal() -> void:
	portal.show()
	portal.set_deferred("monitorable", true)
	portal.set_deferred("monitoring", true)

func _on_portal_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(start_level_path)
		Globals.level+=1
