extends Node

func lobby_connect():
    # The `fetch` object will be used to get a list of all the lobbies.
    var fetch = GotmLobbyFetch.new()
    # All of the lobbies that are currently available for your game.
    var lobbies = yield(fetch.first(), "completed")
    # The `peer` object will contain the network interface that other games
    #  will use to contact yours.
    var peer
    # For this sample, we'll only be using one lobby. If there are any lobbies
    #  in the list, then there is already a host.
    if lobbies:
        # So we'll take the first (and only) lobby in the list.
        var lobby = lobbies[0]
        # and join it.
        var success = yield(lobby.join(), "completed")
        # By creating `NetworkedMultiplayerENet` we give our game access to high
        #  level networking functions like `rpc`
        peer = NetworkedMultiplayerENet.new()
        # Since the lobby already existed, we know there is a `Gotm.lobby.host`, and
        #  we can connect to it as a client to the host's ipAddress/port.
        peer.create_client(Gotm.lobby.host.address, 8070)        
    else:
        # Since there are no lobbies, we'll create a new one.  By setting the first
        #  parameter to `false` you tell Gotm to not create a share link. This value
        #  would be true by default.
        Gotm.host_lobby(false)
        # Notice that we can treat the `Gotm.lobby` just like any other node in our game,
        #  so we can set it's properties and call methods like normal.
        Gotm.lobby.name = "Color Changer"
        # If the `Gotm.lobby.hidden` is set to true, then it won't show up when another
        #  player won't see it when they fetch the lobbies.
        Gotm.lobby.hidden = false
        # Like above, the host needs to create a `NetworkedMultiplayerENet`
        peer = NetworkedMultiplayerENet.new()
        # Then create a new server for clients to connect to the servers port. 
        peer.create_server(8070)
    # For both client & server, then add the `peer` to the node tree, and then
    #  other systems will be able to connect and send RPC calls to it.
    get_tree().set_network_peer(peer)

