extends Control

signal connect_lobby(lobby)
var connecting = true

# Called when the node enters the scene tree for the first time.
func _ready():
    Gotm.connect("lobby_changed", self, "_on_lobby_changed")
    lobby_connect()

remote func set_color(color):
    $Background.color = Color(color)
    $Events.text += "Setting my color to: %s\n" % color

remote func join_lobby(new_lobby):
    print("Joining Lobby: " + str(new_lobby))
    var success = yield(new_lobby.join(), "completed")
    var peer = NetworkedMultiplayerENet.new()
    peer.create_client(Gotm.lobby.host.address, 8070)  
    get_tree().set_network_peer(peer)
    
func lobby_connect():
    print("Connecting lobby.")
    # The `fetch` object will be used to get a list of all the lobbies.
    var fetch = GotmLobbyFetch.new()
    print("Fetch made")
    # All of the lobbies that are currently available for your game.
    var lobbies = yield(fetch.next(10), "completed")
    print("lobbies set")
    # The `peer` object will contain the network interface that other games
    #  will use to contact yours.
    var peer
    # For this sample, we'll only be using one lobby. If there are any lobbies
    #  in the list, then there is already a host.
    if lobbies:
        print("Lobbies:")
        for lobby in lobbies:
            print("    %s: %s" % [str(lobby.name), lobby.get_property("created")])
        # So we'll take the first (and only) lobby in the list.
        var lobby = lobbies[0]
        print("lobby variabled")
        # and join it.
        var success = yield(lobby.join(), "completed")
        print("lobby joined")
        # By creating `NetworkedMultiplayerENet` we give our game access to high
        #  level networking functions like `rpc`
        peer = NetworkedMultiplayerENet.new()
        print("peer assigned")
        # Since the lobby already existed, we know there is a `Gotm.lobby.host`, and
        #  we can connect to it as a client to the host's ipAddress/port.
        peer.create_client(Gotm.lobby.host.address, 8070)  
        print("client created")
    else:
        print("No lobbies found.")
        # Since there are no lobbies, we'll create a new one.  By setting the first
        #  parameter to `false` you tell Gotm to not create a share link. This value
        #  would be true by default.
        Gotm.host_lobby(false)
        print("Created lobby")
        # Notice that we can treat the `Gotm.lobby` just like any other node in our game,
        #  so we can set it's properties and call methods like normal.
        Gotm.lobby.name = "Color Changer"
        print("Set lobby name")
        # If the `Gotm.lobby.hidden` is set to true, then it won't show up when another
        #  player won't see it when they fetch the lobbies.
        Gotm.lobby.hidden = false
        print("Set hidden.")
        # Like above, the host needs to create a `NetworkedMultiplayerENet`
        peer = NetworkedMultiplayerENet.new()
        print("peer assigned")
        # Then create a new server for clients to connect to the servers port. 
        peer.create_server(8070)
        print("server created")
    # For both client & server, then add the `peer` to the node tree, and then
    #  other systems will be able to connect and send RPC calls to it.
    get_tree().set_network_peer(peer)
    print("peer added to tree")


    
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

func _on_lobby_changed():
    $Events.text = $Events.text + "Lobby changed.\n"
    if Gotm.lobby:
        get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
        get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
        if Gotm.lobby.is_host():
            $Events.text += "I'm the Host: %s\n" % str(Gotm.lobby.id)
            Gotm.lobby.set_property("created", OS.get_system_time_msecs())
            $Events.text += "Lobby creation time: %s\n" % Gotm.lobby.get_property("created")
        $HostCheckTimer.start()
        connecting = false
    else:
        $Events.text += "Lobby Lost."
        $HostCheckTimer.stop()
        lobby_connect()
        emit_signal("connect_lobby", null)

func _on_network_peer_connected(peer_id):
    $Events.text += "Peer network connection: %s\n" % str(peer_id)

func _on_network_peer_disconnected(peer_id):
    $Events.text += "Peer network disconnection: %s\n" % str(peer_id)

func _on_HostCheckTimer_timeout():
    if connecting:
        return
    var fetch = GotmLobbyFetch.new()
    fetch.sort_property("created")
    fetch.sort_ascending()
    var lobbies = yield(fetch.first(), "completed")
    if lobbies:
        var other_lobby = lobbies[0]
        $Events.text += "Checking lobby pairing with: %s\n" % str(other_lobby.get_property("created"))
        if other_lobby.id != Gotm.lobby.id and other_lobby.get_property("created") < Gotm.lobby.get_property("created"):
            $Events.text += "Found earlier lobby.\n"
            if Gotm.lobby.peers and Gotm.lobby.is_host():
                rpc("join_lobby", other_lobby)
            emit_signal("connect_lobby", other_lobby)

func _on_TestScreen_connect_lobby(lobby):
    connecting = true
    if lobby:
        join_lobby(lobby)
    else:
        lobby_connect()
