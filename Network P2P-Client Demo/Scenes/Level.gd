extends Node2D

var count = 0

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3
	timer.connect("timeout",self,"_on_timer_timeout") 
	Networking.spawn1 = $Spawns/Spawn1.position
	Networking.spawn2 = $Spawns/Spawn2.position
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	if get_tree().is_network_server():
		Networking.self_data.position = Networking.setSpawns(Networking.EmptyArray)
		Networking._create_player(Networking.my_id, Networking.self_data)
		timer.start()
		get_tree().paused = true
		$Label.visible = true
	else:
		timer.start()
		get_tree().paused = true
		$Label.visible = true

func _on_timer_timeout():
	if get_tree().get_network_peer().get_connection_status() == 1:
		Networking._connection_failed()
		get_tree().paused = true;
		get_tree().change_scene('res://GUI/Lobby.tscn')
	else:
		$Label.visible = false
		get_tree().paused = false
		
func _on_player_disconnected(id):
	get_node(str(id)).queue_free()
	

func _on_server_disconnected():
	get_tree().network_peer = null #close_connection
	get_tree().change_scene('res://GUI/Lobby.tscn')
