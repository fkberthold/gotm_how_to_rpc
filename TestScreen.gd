extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    Gotm.connect("lobby_changed", self, "_on_lobby_changed")
    Network.lobby_connect()

    
remote func set_color(color):
    $Background.color = Color(color)
    
func on_gotm():
    if Gotm.is_live():
        $Fields/IsOnGotM.text = "On GotM: true"
    else:
        $Fields/IsOnGotM.text = "On GotM: false"

func logged_in():
    if Gotm.user.is_logged_in():
        $Fields/LoggedIn.text = "Logged In: true"
    else:
        $Fields/LoggedIn.text = "Logged In: false"
        
func usernamed():
    if Gotm.user.is_logged_in():
        $Fields/Username.text = "Username: " + Gotm.user.display_name
    else:
        $Fields/Username.text = "Username: ?"
        
func in_lobby():
    if Gotm.lobby:
        $Fields/InLobby.text = "In Lobby: " + Gotm.lobby.name
    else:
        $Fields/InLobby.text = "In Lobby: ?"
        
func host_is():
    if Gotm.lobby:
        $Fields/IsHost.text = "Host Is: " + Gotm.lobby.host.display_name
    else:
        $Fields/IsHost.text = "Host Is: ?"
        
func number_in_lobby():
    if Gotm.lobby:
        $Fields/NumberInLobby.text = "Players In Lobby: " + str(len(Gotm.lobby.peers) + 1)
    else:
        $Fields/NumberInLobby.text = "Players In Lobby: 0"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    on_gotm()
    logged_in()
    usernamed()
    in_lobby()
    host_is()
    number_in_lobby()


func _on_SendColor_pressed():
    print("Sending Color: " + str($ColorPickerButton.color))
    rpc("set_color", $ColorPickerButton.color)
#    set_color($ColorPickerButton.color)

func _on_lobby_changed():
    $Events.text = $Events.text + "Lobby changed.\n"
    if Gotm.lobby:
        Gotm.lobby.connect("peer_joined", self, "_on_peer_joined")
        Gotm.lobby.connect("peer_left", self, "_on_peer_left")

func _on_peer_joined(peer):
    if peer:
        $Events.text = $Events.text + "Peer joined: " + str(peer) + "\n"
    else:
        $Events.text = $Events.text + "Unknown Peer joined.\n"     

func _on_peer_left(peer):
    if peer:
        $Events.text = $Events.text + "Peer left: " + str(peer) + "\n"
    else:
        $Events.text = $Events.text + "Unknown Peer left.\n"
