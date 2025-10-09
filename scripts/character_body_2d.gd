extends CharacterBody2D

# constants
const SPEED = 200.0
const JUMP_VELOCITY = -300.0

# variables
var gravity = 0
var gravChanged = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Add gravity depending on current state (And rotate/flip sprite).
	if gravity == 0 or gravity == 2:
		animated_sprite_2d.rotation_degrees = 0
		velocity.y += -get_gravity().y * delta * (gravity-1)
		if gravity == 2:
			animated_sprite_2d.flip_v = true
		else:
			animated_sprite_2d.flip_v = false
	if gravity == 1 or gravity == 3:
		animated_sprite_2d.flip_v = false
		velocity.x += -get_gravity().y * delta * (gravity-2)
		if gravity == 1:
			animated_sprite_2d.rotation_degrees = 270
		else:
			animated_sprite_2d.rotation_degrees = 90
		
	
	# Reset gravChanged when landing
	# Vertical gravity
	if gravity == 0 and is_on_floor():
		gravChanged = false
	if gravity == 2 and is_on_ceiling():
		gravChanged = false
	# Horizontal gravity
	if (gravity == 1 or gravity == 3) and is_on_wall():
		gravChanged = false

	# Handle jump.
	if Input.is_action_just_pressed("Jump"):
		if (is_on_floor() or is_on_ceiling()) and (gravity == 0 or gravity == 2):
			velocity.y = -JUMP_VELOCITY * (gravity-1)
		elif is_on_wall() and (gravity == 1 or gravity == 3):
			velocity.x = -JUMP_VELOCITY * (gravity-2)

	# Get Movement (And animation I guess).
	var directionX := Input.get_axis("Left", "Right")
	var directionY := Input.get_axis("Up", "Down")
	if gravity == 0 or gravity == 2:
		if directionX:
			velocity.x = directionX * SPEED
			if directionX > 0:
				animated_sprite_2d.flip_h = false
			else:
				animated_sprite_2d.flip_h = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED*0.3)
	else:
		if directionY:
			velocity.y = directionY * SPEED
			# Goofy ass direction animation on walls
			if directionY > 0:
				if gravity == 3:
					animated_sprite_2d.flip_h = false
				else:
					animated_sprite_2d.flip_h = true
			else:
				if gravity == 3:
					animated_sprite_2d.flip_h = true
				else:
					animated_sprite_2d.flip_h = false
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED*0.3)
		
	# Change Gravity
	if Input.is_action_just_pressed("GravDown") and gravChanged == false:
		gravity = 0
		gravChanged = true
	if Input.is_action_just_pressed("GravRight") and gravChanged == false:
		gravity = 1
		gravChanged = true
	if Input.is_action_just_pressed("GravUp") and gravChanged == false:
		gravity = 2
		gravChanged = true
	if Input.is_action_just_pressed("GravLeft") and gravChanged == false:
		gravity = 3
		gravChanged = true
	

	move_and_slide()
