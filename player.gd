extends CharacterBody2D

@export var speed: float = 200 # pixels per second
@export var player_id: int = 1 # Used in co-op stage

@onready var sprite = $AnimatedSprite2D

var input_direction: Vector2 = Vector2.ZERO 
var was_moving: bool = false

func get_input():
	input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func update_animation():
	print(sprite.animation)
	# Is the player pressing anything? Compare input-direction to Vector2.ZERO
	var is_moving: bool = input_direction != Vector2.ZERO
	
	if is_moving and not was_moving:
		# Just started moving so play startup animation
		sprite.play("startup")
	elif not is_moving and was_moving:
		# Just stopped moving, play idle
		sprite.play("idle")
		
	was_moving = is_moving
	
func _physics_process(_delta: float):
	get_input()
	update_animation()
	move_and_slide()
	
func _on_animated_sprite_2d_animation_finished():
	# if the animation that just ended was "startup", play "thrust"
	if sprite.animation == "startup":
		sprite.play("thrust")
	
