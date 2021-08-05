extends Node2D

var nickname 
var colours = Color(1, 1, 1)


func _ready():
	pass

func _on_Host_pressed():
	_load_game()
	Networking.create_server("Host")

func _load_game():
	get_tree().change_scene('res://Scenes/Level.tscn')


func _process(delta):
	pass
