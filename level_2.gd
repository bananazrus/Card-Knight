extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var overshield_bar: ProgressBar = $CanvasLayer/ProgressBar/ProgressBar
@onready var boss: CharacterBody2D = $thornweaver/CharacterBody2D2
@onready var boss2_health_bar: ProgressBar = $CanvasLayer/boss_health

func _ready() -> void:
	# Player UI Setup
	player.health_changed.connect(health_bar._on_player_health_changed)
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	
	player.overshield_changed.connect(health_bar._on_player_overshield_changed)
	overshield_bar.max_value = 240
	overshield_bar.value = player.overshield
	
	# Boss UI Setup
	if is_instance_valid(boss):
		# Direct update via inline function (no extra script needed on ProgressBar)
		boss.boss2_health_changed.connect(func(new_hp: float): 
			boss2_health_bar.value = new_hp
		)
		boss2_health_bar.max_value = boss.primordial_health
		boss2_health_bar.value = boss.primordial_health

# Trigger using BODY_ENTERED for CharacterBody2D player
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body == player:
		if is_instance_valid(boss):
			boss2_health_bar.show()

# Trigger fallback in case player's Area2D hitboxes enter instead
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.get_parent().is_in_group("player"):
		if is_instance_valid(boss):
			boss2_health_bar.show()
