extends CharacterBody3D


const COD = 0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
const MOUSE_SENSITIVITY = 0.003
var pitch = 0.0
var yaw = 0.0
var walk_cycle = 0.0
var hands_origin : Vector3
var click_bob = 0.0


@onready var stat = $CanvasLayer/Stat
@onready var camera = $Camera3D
@onready var hands = $Camera3D/Hands
@onready var sword = $Camera3D/Sword  # Adjust path if needed
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # hides and locks mouse to window
	hands_origin = hands.position  # saves wherever you placed the hands in the editor

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY  # left/right look
		rotation.y = yaw                              # apply to whole body (so movement follows)
		pitch -= event.relative.y * MOUSE_SENSITIVITY # up/down look
		pitch = clamp(pitch, -1.2, 1.2)              # prevent flipping upside down
		camera.rotation.x = pitch 
	
			
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_bob = -7.0  
			sword.rotate_object_local(Vector3(1,0,0), deg_to_rad(20))    
			await get_tree().create_timer(0.2).timeout 
			sword.rotate_object_local(Vector3(1,0,0), deg_to_rad(-20))   
		else:
			pass
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # ESC to free mouse

func _physics_process(delta):
	
		
	# Gravity — only applied when in the air
	if not is_on_floor():
		velocity.y -= GRAVITY * delta	
	# runs every frame shift is held
	# Jump
	var current_jump_velocity = JUMP_VELOCITY
	var current_speed = SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		@warning_ignore("unused_variable", "shadowed_variable")
		current_speed = SPEED *3
		current_jump_velocity = JUMP_VELOCITY*1.3
		
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = current_jump_velocity
		
	

	# Movement direction — built from yaw only, ignores pitch so looking up doesn't tilt movement
	var forward = Vector3(-sin(rotation.y), 0, -cos(rotation.y))
	var right   = Vector3( cos(rotation.y), 0, -sin(rotation.y))

	var direction = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): direction += forward
	if Input.is_key_pressed(KEY_S): direction -= forward
	if Input.is_key_pressed(KEY_A): direction -= right
	if Input.is_key_pressed(KEY_D): direction += right

	if direction.length() > 0:
		direction = direction.normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = 0  # stop immediately when no key pressed
		velocity.z = 0

	move_and_slide()  # applies velocity and handles collisions

	# Hand bob — only bobs when moving and on the ground
	var is_moving = direction.length() > 0 and is_on_floor()
	if is_moving:
		walk_cycle += delta * 12.0  # 8.0 = bob speed, increase for faster bob
	else:
		walk_cycle = lerp(walk_cycle, 0.0, delta * 10.0)  # smoothly return to rest

	# adds bob on top of original position you set in editor
	hands.position.y = hands_origin.y + sin(walk_cycle) * 0.04        # 0.04 = bob height
	hands.position.x = hands_origin.x + sin(walk_cycle * 0.5) * 0.02  # 0.02 = side sway
	
	click_bob = lerp(click_bob, 0.0, delta * 12.0)  # smoothly fades back to 0
	hands.position.y = hands_origin.y + sin(walk_cycle) * -0.04 + click_bob * 0.06
	
