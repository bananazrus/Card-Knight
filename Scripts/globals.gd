extends Node

var bow: bool = false
var sword: bool = false
var arrow: bool = false
var damage_buff_5 = 1.0
var seven: bool = false
var damage_reduction = 1.0
var queen_buff = 1
var all_cards = [["7H", "5C"],["3H", "6D", "9C"],["2D", "4S"],["10D", "AC", "8S"]]
var card_pool = [["7C", "7D", "7S", "5D", "4S", "5H"],["3C", "3D", "3S", "6C", "6H", "6S", "9D", "9H", "9S"],["2C", "2H", "2S", "4C", "4D", "4H"],["10C", "10S", "10H", "8C", "8D", "8H"]]
var phase_card_pool = [["QS", "KC", "JS"],["QH"],["AH"],["JH"]]
var deck: Array = []
var hand: Array = ["empty", "empty", "empty", "empty"]
var discard: String = "empty"
var random_index = 0
var jump_changes: int = 0
var no_discard: bool = false
var sword_increase: float = 1.0
var bow_increase: float = 1.0
var card_increase: float = 1.0
var max_health_bonus: float = 0.0
var speed_buffs: int = 0
var regen_cooldown_multiplier: float = 1.0
var regen_rate_multiplier: float = 1.0
var stop_death: bool = false
var level = 1

const SAVE_FILE_PATH = "user://card_data.dat"


func _ready() -> void:
	reset_game_state()
	load_card_data()


func reset_game_state() -> void:
	queen_buff = 1
	damage_buff_5 = 1
	damage_reduction = 1
	jump_changes = 0
	no_discard = false
	sword_increase = 1.0
	bow_increase = 1.0
	card_increase = 1.0
	max_health_bonus = 0.0
	speed_buffs = 0
	regen_cooldown_multiplier = 1.0
	regen_rate_multiplier = 1.0
	stop_death = false
	level = 1
	discard = "empty"
	deck = all_cards.duplicate(true)
	hand = ["empty", "empty", "empty", "empty"]
	for i in range(4):
		deck[i].shuffle()
		if deck[i].size() > 0:
			hand[i] = deck[i].pop_back()

func save_card_data() -> void:
	var save_dict = {
		"deck": deck,
		"all_cards": all_cards,
		"card_pool": card_pool,
		"phase_card_pool": phase_card_pool,
		"hand": hand  # <-- ADDED HAND HERE
	}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_dict)
		file.close()
	else:
		print("Failed to save data. Error code: ", FileAccess.get_open_error())


func load_card_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found. Keeping default values.")
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var save_dict = file.get_var()
		file.close()
		if typeof(save_dict) == TYPE_DICTIONARY:
			deck = save_dict.get("deck", deck)
			all_cards = save_dict.get("all_cards", all_cards)
			card_pool = save_dict.get("card_pool", card_pool)
			phase_card_pool = save_dict.get("phase_card_pool", phase_card_pool)
			hand = save_dict.get("hand", hand)  # <-- ADDED HAND HERE
