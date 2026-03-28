extends Node3D

@export var bullet_scene: PackedScene

@onready var muzzle = $Muzzle
@onready var camera = get_parent()

@warning_ignore("unused_parameter")
func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()

var direction = Vector3.ZERO
var speed = 20.0



func shoot():
	var bullet = bullet_scene.instantiate()

	bullet.global_position = muzzle.global_position

	@warning_ignore("shadowed_variable")
	var direction = -camera.global_transform.basis.z
	bullet.direction = direction

	get_tree().current_scene.add_child(bullet)
	
