extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var overshield_bar: ProgressBar = $CanvasLayer/ProgressBar/ProgressBar
@export_file("*.scn") var start_level_path: String = "res://level2.scn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(health_bar._on_player_health_changed)
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	player.overshield_changed.connect(health_bar._on_player_overshield_changed)
	overshield_bar.max_value = 240
	overshield_bar.value = player.overshield
