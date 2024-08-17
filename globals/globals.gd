extends Node
signal stat_change

var player_health: = 100:
	set(value):
		player_health = value
		stat_change.emit()
var player_state: = "idle":
	set(value):
		player_state = value
		stat_change.emit()

		
		

		
	
