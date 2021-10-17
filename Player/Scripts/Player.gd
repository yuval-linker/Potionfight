extends KinematicBody2D

# constants
var GRAVITY = 500
var SPEED = 500
var ACCELERATION = 200
var JUMPFORCE = 300
var THROWFORCE = 600
var MAXHEALTH = 100
var BASICATTACK = 5
const HIT_SPEED = 250

# classes
var Potion = preload("res://Items/Potions/Scenes/Potion.tscn")

# onready vars
onready var direction_timer = $DirecitonTimer
onready var spawner = $DirectionNode/PotionSpawn
onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
onready var directionNode = $DirectionNode
onready var nameNode = $DirectionNode/NameNode

# puppet vars
puppet var puppet_vel: Vector2 = Vector2.ZERO
puppet var _facing_right: bool = true
puppet var on_floor: bool = true
puppet var puppet_pos: Vector2
puppet var puppet_crouching: bool = false
puppet var _equipped
export(bool) puppet var throwing = false

var linear_vel: Vector2 = Vector2.ZERO
var crouching: bool = false
var punching: bool = false
var health = MAXHEALTH
var player: KinematicBody2D
var _second_jump = true
var potion_index = 0

signal continue_throwing

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
		
		crouching = Input.is_action_pressed("crouch")
		punching = Input.is_action_pressed("punch")
		
		if Input.is_action_just_pressed("punch"):
			rpc("_on_Punch_body_entered", player)
		
		# Throw a potion
		if Input.is_action_just_pressed("throw") and not throwing:
			var potion_name = get_name() + str(potion_index)
			potion_index += 1
			potion_index = potion_index % 50 # rare to throw more than 50 potions at a time
			rpc("throw", potion_name, get_global_mouse_position(), get_tree().get_network_unique_id())
		
		rset_unreliable("puppet_pos", position)
		rset_unreliable("puppet_vel", linear_vel)
		rset_unreliable("_facing_right", _facing_right)
		rset_unreliable("on_floor", on_floor)
		rset_unreliable("puppet_crouching", crouching)
	else:
		position = puppet_pos
		linear_vel = puppet_vel
		crouching = puppet_crouching
	
	directionNode.scale.x = 1 if _facing_right else -1
	nameNode.scale.x = directionNode.scale.x
	
	# Dont go into any animation if throwing
	if throwing:
		return
	
	if on_floor:
		if abs(linear_vel.x) > 10:
			if crouching:
				playback.travel("crouch_walk")
			if punching:
				playback.travel("basic_attack")
			else:
				playback.travel("run")
		else:
			if crouching:
				playback.travel("crouch_idle")
			if punching:
				playback.travel("basic_attack")
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
remotesync func throw(potion_name: String, cursor_pos: Vector2, by_who: int):
	throwing = true
	if on_floor:
		playback.travel("throw")
	else:
		playback.travel("air_throw")
	var potion = _equipped.instance()
	potion.set_name(potion_name)
	potion.player = get_node("../" + str(by_who))
	yield(self, "continue_throwing")
	var spawn_pos = spawner.global_position
	if cursor_pos.x < global_position.x and _facing_right:
		_facing_right = false
		spawn_pos.x -= 2*spawner.position.x
		direction_timer.start()
	if cursor_pos.x > global_position.x and not _facing_right:
		_facing_right = true
		spawn_pos.x += 2*spawner.position.x
		direction_timer.start()
	potion.position = spawn_pos
	var force = (cursor_pos - spawn_pos).normalized() * THROWFORCE
	potion.throw(force)
	get_node("../..").add_child(potion)

# the master of the player is the one in charge to tell everyone
# that he was hit
master func damaged(_by_who, dmg:int, dmg_pos: float) -> void:
	var dir = sign(global_position.x - dmg_pos)
	linear_vel.x = dir*HIT_SPEED
	rpc("get_hurt", dmg)

# func that gets executed on every client
# it updates the health and plays the animation
remotesync func get_hurt(dmg: int) -> void:
	if health > 0:
		health -= dmg
		# here we can emit a signal that health has changed
		$HPBar.set_hp_value(health - dmg)
		if on_floor:
			playback.travel("hit")
		else:
			playback.travel("air_hit")
	else:
		pass
		#insert death animation
	
	
	

func set_player_name(new_name: String) -> void:
	$DirectionNode/NameNode/NameLabel.set_text(new_name)

master func on_direction_timeout() -> void:
	if Input.is_action_pressed("right") and not _facing_right:
		_facing_right = true
	if Input.is_action_pressed("left") and _facing_right:
		_facing_right = false



func _on_Punch_body_entered(body):
	if body.is_in_group("player"):
		if body != self:
			body.damaged(self, self.BASICATTACK, global_position.x)
		else:
			print("cant hurt itself")
