extends CharacterBody2D

# constants
const SPEED = 200.0
const JUMP_VELOCITY = -300.0

# variables
var gravity = 0
var gravChanged = false
var alive = true
var canJump = true
var frameActive = false


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var respawn: Timer = $Hitbox/respawn
@onready var jump_window: Timer = $jump_window


func _physics_process(delta: float) -> void:
	if alive:
		# Add gravity depending on current state (And rotate/flip sprite).
		if gravity == 0 or gravity == 2:
			animated_sprite_2d.rotation_degrees = 0
			collision_shape_2d.rotation_degrees = 0
			hitbox.rotation_degrees = 0
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
				collision_shape_2d.rotation_degrees = 270
				hitbox.rotation_degrees = 270
			else:
				animated_sprite_2d.rotation_degrees = 90
				collision_shape_2d.rotation_degrees = 90
				hitbox.rotation_degrees = 90
			
		
		# Reset gravChanged and canJump when landing / Handle canJump frames
		# Vertical gravity
		if gravity == 0:
			if is_on_floor():
				gravChanged = false
				canJump = true
				frameActive = false
			elif !is_on_floor() and !frameActive:
				frameActive = true
				jump_window.start()
		if gravity == 2:
			if is_on_ceiling():
				gravChanged = false
				canJump = true
				frameActive = false
			elif !is_on_ceiling() and !frameActive:
				frameActive = true
				jump_window.start()
		# Horizontal gravity
		if (gravity == 1 or gravity == 3):
			if is_on_wall():
				gravChanged = false
				canJump = true
				frameActive = false
			elif !is_on_wall() and !frameActive:
				frameActive = true
				jump_window.start()


		# Handle jump.
		if Input.is_action_just_pressed("Jump") and canJump == true:
			if gravity == 0 or gravity == 2:
				velocity.y = -JUMP_VELOCITY * (gravity-1)
			elif gravity == 1 or gravity == 3:
				velocity.x = -JUMP_VELOCITY * (gravity-2)
			canJump = false

		# Get Movement (And animation I guess).
		var directionX := Input.get_axis("Left", "Right")
		var directionY := Input.get_axis("Up", "Down")
		if gravity == 0 or gravity == 2:
			if directionX:
				velocity.x = directionX * SPEED
				animated_sprite_2d.play("walk")
				if directionX > 0:
					animated_sprite_2d.flip_h = false
				else:
					animated_sprite_2d.flip_h = true
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED*0.3)
				animated_sprite_2d.play("default")
		else:
			if directionY:
				velocity.y = directionY * SPEED
				animated_sprite_2d.play("walk")
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
				animated_sprite_2d.play("default")
			
		# Change Gravity and disable jump
		if Input.is_action_just_pressed("GravDown") and gravChanged == false:
			gravity = 0
			gravChanged = true
			canJump = false
		if Input.is_action_just_pressed("GravRight") and gravChanged == false:
			gravity = 1
			gravChanged = true
			canJump = false
		if Input.is_action_just_pressed("GravUp") and gravChanged == false:
			gravity = 2
			gravChanged = true
			canJump = false
		if Input.is_action_just_pressed("GravLeft") and gravChanged == false:
			gravity = 3
			gravChanged = true
			canJump = false
		

		move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	alive = false
	animated_sprite_2d.hide()
	respawn.start()


func _on_respawn_timeout() -> void:
	get_tree().reload_current_scene()
	

func _on_jump_window_timeout() -> void:
	canJump = false
