extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var peer


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func lobby_connect():
    var fetch = GotmLobbyFetch.new()
    var lobbies = yield(fetch.first(), "completed")
    if lobbies:
        var lobby = lobbies[0]
        var success = yield(lobby.join(), "completed")
        peer = NetworkedMultiplayerENet.new()
        peer.create_client(Gotm.lobby.host.address, 8070)        
    else:
        Gotm.host_lobby(false)
        Gotm.lobby.name = "Color Changer"
        Gotm.lobby.hidden = false
        peer = NetworkedMultiplayerENet.new()
        peer.create_server(8070)
    get_tree().set_network_peer(peer)
    
remote func set_color(color):
    get_tree().get_root().get_node("TestScreen").set_color(color)
