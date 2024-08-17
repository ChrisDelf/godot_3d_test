extends Resource

class_name weapon_resource

@export var weapon_name: String
@export var activate_anim: String
@export var hip_fire: String
@export var reload_anim: String
@export var deactivate_anim: String
@export var out_of_ammo_anim: String
@export var run_animation: String
@export var walk_animation: String
@export var melee_anim: String


@export var current_ammo: int
@export var reserve_ammo: int
@export var magazine: int
@export var max_ammo: int

@export var is_droppable: bool
@export var auto_fire: bool
@export var can_fire: bool = true
@export_flags("HitScan", "Projectile") var Type
@export var weapon_range: int
@export var damage: int
@export var projectile_to_load: PackedScene
@export var projectile_velocity:int
@export var melee_damage: int
@export var melee_range: float = 1.5
@export var is_melee: bool

@export var weapon_drop: PackedScene

enum {NULL,HITSCAN, PROJECTILE}
