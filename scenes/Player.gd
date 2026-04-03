extends CharacterBody3D

@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var crouch_height: float = 0.5
@export var normal_height: float = 1.0
@export var transition_speed: float = 10.0

@onready var collision_shape = $CollisionShape3D
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D

var camera_x_rotation: float = 0.0
var inventory: Array = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		
		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation
	
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target.has_method("interact"):
				target.interact(self)

func _physics_process(delta):
	var current_speed = walk_speed
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		collision_shape.scale.y = lerp(collision_shape.scale.y, crouch_height, transition_speed * delta)
		head.position.y = lerp(head.position.y, 0.6, transition_speed * delta)
	else:
		collision_shape.scale.y = lerp(collision_shape.scale.y, normal_height, transition_speed * delta)
		head.position.y = lerp(head.position.y, 1.5, transition_speed * delta) # Asumsi tinggi mata normal
		
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed

	var movement_vector = Vector3.ZERO

	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head.basis.x

	movement_vector = movement_vector.normalized()

	velocity.x = lerp(velocity.x, movement_vector.x * current_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * current_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not Input.is_action_pressed("crouch"):
		velocity.y = jump_power

	move_and_slide()

func add_to_inventory(item_name: String):
	inventory.append(item_name)
	print("Item didapat: ", item_name)
	print("Isi tas: ", inventory)
