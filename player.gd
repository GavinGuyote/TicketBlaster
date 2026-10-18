extends CharacterBody2D

@export var speed: float = 400 # pixels per second
@export var player_id: int = 1 # Used in co-op stage

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func _physics_process(delta: float):
	get_input()
	move_and_slide()
	
