extends Area2D

var Velosity = 500
var damage = 25

enum Direction {LEFT = 0, RIGHT = 1}

func getDirection(direction):
	if direction == true:
		Velosity = -Velosity

func _process(delta):
	global_position.x += Velosity * delta

func _on_Bullet_body_entered(body):
	queue_free()
	
