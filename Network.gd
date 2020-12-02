extends Node

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

