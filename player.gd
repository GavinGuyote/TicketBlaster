extends CharacterBody2D

@export var speed: float = 200 # pixels per second
@export var player_id: int = 1 # Used in co-op stage

@onready var sprite = $AnimatedSprite2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3 # seconds between shots

var input_direction: Vector2 = Vector2.ZERO 
var was_moving: bool = false

var can_shoot: bool = true

func get_input():
	input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func update_animation():
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
	# If "shoot" is held AND can_shoot is true, call shoot()
	var shooting: bool = Input.is_action_pressed("shoot")
	if shooting and can_shoot:
		shoot()
	
func shoot() -> void:
	# make a new bullet from bullet_scene
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	#put it at ship's nose (not centered)
	bullet.global_position = global_position - Vector2(0, 20)
	# start the cooldown so you can't shot again until fire_rate passes.
	toggle_shoot()
	var tween = create_tween()
	tween.tween_interval(fire_rate)
	tween.tween_callback(toggle_shoot)
		
func toggle_shoot():
	if can_shoot:
		can_shoot = false;
	
	elif not can_shoot:
		can_shoot = true;
		
func _on_animated_sprite_2d_animation_finished():
	# if the animation that just ended was "startup", play "thrust"
	if sprite.animation == "startup":
		sprite.play("thrust")
	
