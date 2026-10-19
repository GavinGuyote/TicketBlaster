extends Area2D

@export var speed: float = 400

func _physics_process(delta: float) -> void:
	# Move bullet in a straight upward line
	position += Vector2.UP * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Delete the bullet
	queue_free()
