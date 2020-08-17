extends Control

func _ready():
	# Network is a singleton script that's Autoloaded in the project to initiate
	#  all the connections with GotM's lobby system, and then create newtork
	#  access through the VPN GotM creates.
	Network.lobby_connect()

################
## Networking ##
################
	
# The `remote` keyword tells Godot that other instances of the program
#  can call this method through `rpc`
remote func set_color(color):
	$Background.color = Color(color)
	
# When the user clicks the 'Send Color' button, then it will make
#  an `rpc` call which changes the background color on all of the
#  other screens using the `set_color` method.
func _on_SendColor_pressed():
	print("Sending Color: " + str($ColorPickerButton.color))
	rpc("set_color", $ColorPickerButton.color)

##########################
## Lobby Status Monitor ##
##########################
# The code below is to monitor the player's connection to
#  GotM and the lobby.
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

func _process(_delta):
	on_gotm()
	logged_in()
	usernamed()
	in_lobby()
	host_is()
	number_in_lobby()


