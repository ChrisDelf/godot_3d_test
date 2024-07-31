extends Node3D

@export var group_name : String

var positions : Array
var temp_positions: Array

func _ready():
	# this will look for any nodes in the group of patrols
	positions = get_tree().get_nodes_in_group("Patrols")
	print(positions)
	

