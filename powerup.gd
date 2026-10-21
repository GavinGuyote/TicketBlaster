extends Area2D

@export var speed: int = 100
@export var direction: Vector2 = Vector2.DOWN

enum SpriteState { POWERUP_RAPID, POWERUP_SPREAD, POWERUP_SHIELD } # Need to create a wing-guns powerup sprite.

@onready var powerup_sprite: Sprite2D = $Sprite2D
var random_state_name: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the keys of the enum to use as an array
	var states: Array = SpriteState.keys()
	
	#Pick a random index from the enum keys
	random_state_name = states[randi() % states.size()]
	
	# Map string name to texture path or sprite frame
	var texture_path = "res://art/" + random_state_name.to_lower() + ".png"
	
	powerup_sprite.texture = load(texture_path)
	
	print("Changed sprite to: ", random_state_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta


	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if random_state_name == "POWERUP_SPREAD":
			body.spread_level = 3
		elif random_state_name == "POWERUP_RAPID":
			body.has_rapid_fire = true
		else:
			body.has_wing_guns = true
		
		print("You have powered up")
		queue_free()
		
