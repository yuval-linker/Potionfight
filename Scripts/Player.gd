extends KinematicBody2D

# constants
var GRAVITY = 500
var SPEED = 500
var ACCELERATION = 200
var JUMPFORCE = 300
var THROWFORCE = 600

# classes
var Potion = preload("res://Scenes/Potions/Potion.tscn")

# onready vars
onready var direction_timer = $DirecitonTimer
onready var spawner = $DirectionNode/PotionSpawn
onready var playback = $AnimationTree["parameters/playback"]
onready var directionNode = $DirectionNode
onready var nameNode = $DirectionNode/NameNode

# puppet vars
puppet var linear_vel: Vector2 = Vector2.ZERO
puppet var _facing_right: bool = true
puppet var on_floor: bool = true
puppet var puppet_pos: Vector2
puppet var _equipped

var _second_jump = true
var potion_index = 0

func _ready() -> void:
	$AnimationTree.active = true
	direction_timer.connect("timeout", self, "on_direction_timeout")
	puppet_pos = position
	_equipped = Potion

func _physics_process(delta: float) -> void:
	if is_network_master():
		linear_vel = move_and_slide(linear_vel, Vector2.UP)
		on_floor = is_on_floor()
		
		var target_vel = Input.get_action_strength("right") - Input.get_action_strength("left")
		
		# Movement
		linear_vel.x = move_toward(linear_vel.x, target_vel * SPEED, ACCELERATION)
		linear_vel.y += GRAVITY * delta
		
		_second_jump = _second_jump or on_floor
		# Jump
		if Input.is_action_just_pressed("jump"):
			if on_floor:
				linear_vel.y = -JUMPFORCE
			elif _second_jump:
				linear_vel.y = -JUMPFORCE
				_second_jump = false
		
		if Input.is_action_pressed("left") and not Input.is_action_pressed("right") and _facing_right and direction_timer.is_stopped():
			_facing_right = false
		if Input.is_action_pressed("right") and not Input.is_action_pressed("left") and not _facing_right and direction_timer.is_stopped():
			_facing_right = true
		
		# Throw a potion
		if Input.is_action_just_pressed("throw"):
			var potion_name = get_name() + str(potion_index)
			potion_index += 1 % 50 # rare to throw more than 50 potions at a time
			var cursor_pos = get_global_mouse_position()
			var spawn_pos = spawner.global_position
			if cursor_pos.x < global_position.x and _facing_right:
				_facing_right = false
				spawn_pos.x -= 2*spawner.position.x
				direction_timer.start()
			elif cursor_pos.x > global_position.x and not _facing_right:
				_facing_right = true
				spawn_pos.x += 2*spawner.position.x
				direction_timer.start()
			rpc("throw", potion_name, spawn_pos, cursor_pos, get_tree().get_network_unique_id())
		
		rset("puppet_pos", position)
		rset("lineal_vel", linear_vel)
		rset("_facing_right", _facing_right)
		rset("on_floor", on_floor)
	else:
		position = puppet_pos
	
	directionNode.scale.x = 1 if _facing_right else -1
	nameNode.scale.x = directionNode.scale.x
	
	if on_floor:
		if abs(linear_vel.x) > 10:
			playback.travel("run")
		else:
			playback.travel("idle")
	else:
		if linear_vel.y <= 0:
			playback.travel("jumping")
		else:
			playback.travel("falling")


# throws a potion
# potion_name is a unique potion name (nodes need unique names)
# spawn_pos is the spawn position
# cursor_pos is the cursor position at the moment of the throw
# by_who is the unique identifier of the player thar throwed the potion
remotesync func throw(potion_name: String, spawn_pos: Vector2, cursor_pos: Vector2, by_who: int):
	var potion = _equipped.instance()
	potion.set_name(potion_name)
	potion.player = get_node("../" + str(by_who))
	potion.position = spawn_pos
# warning-ignore:unused_variable
	var force = (cursor_pos - spawn_pos).normalized() * THROWFORCE
	potion.throw(force)
	$"../..".add_child(potion)


func set_player_name(new_name: String) -> void:
	$DirectionNode/NameNode/NameLabel.set_text(new_name)

master func on_direction_timeout() -> void:
	if Input.is_action_pressed("right") and not _facing_right:
		_facing_right = true
	if Input.is_action_pressed("left") and _facing_right:
		_facing_right = false
