extends Camera2D

@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(30, 20)
@export var max_roll: float = 0.1
@export var noise: FastNoiseLite

var trauma: float = 0.0
var trauma_power: float = 2.0
var time: float = 0.0

func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.frequency = 0.2

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		shake()

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	time += get_process_delta_time() * 50.0
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * noise.get_noise_2d(0, time)
	offset.x = max_offset.x * amount * noise.get_noise_2d(100, time)
	offset.y = max_offset.y * amount * noise.get_noise_2d(200, time)
