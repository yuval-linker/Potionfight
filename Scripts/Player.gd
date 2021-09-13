extends KinematicBody2D

var GRAVITY = 500
var linear_vel = Vector2.ZERO
var SPEED = 500
var ACCELERATION = 200
var JUMPFORCE = 600

var _facing_right = true
var _second_jump = true

func _ready() -> void:
	$AnimationTree.active = true

func _physics_process(delta: float) -> void:
	linear_vel = move_and_slide(linear_vel, Vector2.UP)
	
	var on_floor = is_on_floor()
	
	var target_vel = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	# Horizontal Movement
	linear_vel.y += GRAVITY * delta
	linear_vel.x = move_toward(linear_vel.x, target_vel * SPEED, ACCELERATION)
	
	# Jump
	if Input.is_action_just_pressed("jump"):
		if on_floor:
			linear_vel.y = -JUMPFORCE
		elif _second_jump:
			linear_vel.y = -JUMPFORCE
			_second_jump = false


func set_player_name(new_name: String) -> void:
	$DirectionNode/Label.set_text(new_name)
