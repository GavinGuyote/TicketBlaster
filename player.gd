extends CharacterBody2D

@export var speed: float = 400 # pixels per second
@export var player_id: int = 1 # Used in co-op stage

@onready var sprite = $AnimatedSprite2D

# Base stats
@export var bullet_scene: PackedScene
@export var fire_delay: float = 0.3 # seconds between shots
@export var base_damage: int = 1

# Powerups
var has_wing_guns: bool = false
var spread_level: int = 1 # 1 = astraight, 3 = 3-way spread, 5 = 5-way spread
var has_rapid_fire: bool = false 

var input_direction: Vector2 = Vector2.ZERO 
var was_moving: bool = false

var can_shoot: bool = true

var center_gun: Vector2 = Vector2(0, -20)
var right_gun: Vector2 = Vector2(14, 2)
var left_gun: Vector2 = Vector2(-14, 2)

var angles: Array[int] = [-15, 0, 15]

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
	add_to_group("players", true)

	# If "shoot" is held AND can_shoot is true, call shoot()
	var shooting: bool = Input.is_action_pressed("shoot")
	if shooting and can_shoot:
		shoot()
	
func shoot() -> void:
	can_shoot = false

	if has_rapid_fire:
		fire_delay = 0.15
	# Determine which guns are firing
	var active_guns: Array[Vector2] = [center_gun]
	if has_wing_guns:
		active_guns.append(right_gun)
		active_guns.append(left_gun)
		
	# Determine the spread angles based on powerup level
	var active_angles: Array[float] = []
	if spread_level == 1:
		active_angles = [0.0]
	elif spread_level == 3: 
		active_angles = [0.0, -15.0, 15.0]
		
	# Nested Loop: For every active gun, shoot each active angle
	for gun_offset in active_guns:
		for angle in active_angles:
			var bullet = bullet_scene.instantiate()
			get_parent().add_child(bullet)
			
			bullet.global_position = global_position + gun_offset
			
			# To prevent player from shooting themselve from spread shot, add slight tilt
			var final_angle = angle
			if gun_offset == left_gun and spread_level > 1:
				final_angle -= 45.0 # Tilt slightly left
			if gun_offset == right_gun and spread_level > 1:
				final_angle += 45.0
			
			bullet.direction = Vector2.UP.rotated(deg_to_rad(final_angle))
			bullet.rotation = bullet.direction.angle() + PI / 2


	# start the cooldown so you can't shot again until fire_rate passes.
	var tween = create_tween()
	tween.tween_interval(fire_delay)
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
	
