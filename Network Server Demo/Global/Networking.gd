extends Node

const DEFAULT_PORT = 31400
const MAX_PLAYERS = 3

var my_id
var players = { }
var self_data = { name = '', position = Vector2(640,320), colour = Color(0, 0, 0) }
var connection_failed = false
var colour = Color(1, 1, 1)
var spawn1   
var spawn2  
var EmptyArray = {}
var dedicated_Server = false

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_player_connected')
	get_tree().connect('connection_failed', self, '_connection_failed')

func setSpawns(player_count):  #this method decides the spawn point of a peer
	if player_count.size() == 1:
		return spawn1
	if player_count.size() == 2:
		return spawn2

func create_server(player_nickname):
	dedicated_Server = true
	self_data.name = player_nickname
	self_data.colour = colour
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	my_id = 1
	print("Created Server")

remote func _getPlayer_count(sender_ID):
	rpc_id(sender_ID,'_saveInfo',get_tree().get_network_connected_peers())

remote func _saveInfo(player_count):
	self_data.position = setSpawns(player_count)
	players[my_id] = self_data
	_create_player(my_id, self_data)
	rpc('_create_player', my_id, self_data)

func _player_connected(id):   #Emites on all peers when new client is connected
	rset('slave_dedicated_Server',dedicated_Server)
	print("Player ", str(id)," connected")

func _player_disconnected(id):
	print("Player disconnected: ", str(id))
	players.erase(id)

remote func _create_player(id, info):
	if get_tree().is_network_server():
		if id != 1:
			for peer_id in players:
				rpc_id(id, '_create_player', peer_id, players[peer_id])
	players[id] = info
	var new_player = load('res://Scenes/Player.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	$'/root/Level/Players'.add_child(new_player)
	new_player.init(info.name, info.position, info.colour)

func update_position(id, position):
	players[id].position = position 
