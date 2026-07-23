extends Node2D
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var overshield_bar: ProgressBar = $CanvasLayer/ProgressBar/ProgressBar
@onready var boss: Node2D = $snuggles/Snuggles
@onready var boss_health_bar: ProgressBar = $CanvasLayer/boss_health
@onready var doors1: StaticBody2D = $StaticBody2D
signal spawn_door1
signal spawn_door2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(health_bar._on_player_health_changed)
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	player.overshield_changed.connect(health_bar._on_player_overshield_changed)
	overshield_bar.max_value = 240
	overshield_bar.value = player.overshield
	boss.boss_health_changed.connect(boss_health_bar._on_boss_health_changed)
	boss_health_bar.max_value = 2000
	boss_health_bar.value = boss.snuggles_health

func _on_door1_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		spawn_door1.emit()
		$StaticBody2D/Sprite2D.show()
		

func _on_door2_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		spawn_door2.emit()
		$StaticBody2D/Sprite2D2.show()
		if is_instance_valid(boss):
			boss_health_bar.show()
			$StaticBody2D/Sprite2D.show()
