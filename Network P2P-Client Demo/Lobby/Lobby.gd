extends Node2D

var nickname 
var colours = {Red = Color(1, 0, 0),Green = Color(0, 1, 0),Blue = Color(0, 0, 1)}


func _ready():
	get_tree().paused = false;
	$Label/Pop_Hide_Timer.connect('timeout', self, '_timer_done')

func _on_Join_pressed():
	_load_game()
	Networking.connect_to_server(nickname)

func _on_Host_pressed():
	_load_game()
	Networking.create_server(nickname)

func _on_Name_text_changed(new_text):
	nickname = new_text

func _load_game():
	get_tree().change_scene('res://Scenes/Level.tscn')

func _on_Red_pressed():
	Networking.colour = colours.Red

func _on_Green_pressed():
	Networking.colour = colours.Green

func _on_Blue_pressed():
	Networking.colour = colours.Blue

func _on_IP_text_changed(new_text):
	Networking.Server_IP = $CenterContainer/HSplitContainer/GridContainer2/IP.text

func _process(delta):
	if $Label/Pop_Hide_Timer.is_stopped() and Networking.connection_failed == true:
		$Label/Pop_Hide_Timer.wait_time = 5
		$Label/Pop_Hide_Timer.start()
		$Label.visible = true
		Networking.connection_failed = false

func _timer_done():
	$Label.visible = false
