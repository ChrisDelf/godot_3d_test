extends RigidBody3D

@export var weapon_name: String
@export var current_ammo: int
@export var reserve_ammo: int


var is_pickup: bool = false

func _ready():
	await get_tree().create_timer(1).timeout
	is_pickup = true





