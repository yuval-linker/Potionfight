class_name Player
extends KinematicBody2D

# constants
const GRAVITY = 700
const SPEED = 270
const SPEED_PENALTY = 0.5
const ACCELERATION = 100
const JUMPFORCE = 300
const THROWFORCE = 500
const MAXHEALTH = 100
const BASICATTACK = 5
const HIT_SPEED = 250
const ATTACK_BUFF_CAP = 25

# classes
var Potion = preload("res://Items/Potions/Scenes/Potion.tscn")
var SpacePotion = preload("res://Items/Potions/Scenes/SpacePotion.tscn")
var BoxingPotion = load("res://Items/Potions/Scenes/BoxingPotion.tscn")

# onready vars
onready var direction_timer = $DirecitonTimer
onready var spawner = $DirectionNode/PotionSpawn
onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
onready var directionNode = $DirectionNode
onready var nameNode = $DirectionNode/NameNode
onready var hpBar = $HPBar
onready var upCast: RayCast2D = $UpCast
onready var downCast: RayCast2D = $DownCast

var potions_inventory: PotionsInventoryResource
var plants_inventory: PlantsInventoryResource

# puppet vars
puppet var puppet_vel: Vector2 = Vector2.ZERO
puppet var _facing_right: bool = true
puppet var on_floor: bool = true
puppet var puppet_pos: Vector2
puppet var puppet_crouching: bool = false
puppet var puppet_punching: bool = false
puppet var puppet_tangible: bool = true
puppet var _equipped
export(bool) puppet var throwing = false

var linear_vel: Vector2 = Vector2.ZERO
var crouching: bool = false
export(bool) var invinsible = false
export(bool) var punching = false
var health = MAXHEALTH
var player: KinematicBody2D
var _second_jump = true
var _tangible = true
var _stunned = false
var punch_attack = BASICATTACK
var potion_index = 0

signal continue_throwing

func _ready() -> void:
	if self.is_network_master():
		potions_inventory = PotionsInventoryResource.new()
		plants_inventory = PlantsInventoryResource.new()
	$AnimationTree.active = true
	direction_timer.connect("timeout", self, "on_direction_timeout")
	puppet_pos = position
	_equipped = BoxingPotion

func _physics_process(delta: float) -> void:
	if is_network_master():
		linear_vel = move_and_slide(linear_vel, Vector2.UP)
		on_floor = is_on_floor()
		
		var can_action = not _stunned and _tangible
		var target_vel = Input.get_action_strength("right") - Input.get_action_strength("left")
		target_vel = target_vel if not _stunned else 0
		
		linear_vel.x = move_toward(linear_vel.x, target_vel * SPEED, ACCELERATION)
		linear_vel.y += GRAVITY * delta
		if not _stunned:
			
			# Movement
		
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
		
		if upCast.enabled and upCast.is_colliding():
			var platform = upCast.get_collider() as TileMap
			print("Go Down")
			position.y += 1 if platform else 0
		elif downCast.enabled and downCast.is_colliding():
			var platform = downCast.get_collider() as TileMap
			print("Go Up")
			position.y -= 1 if platform else 0
		elif not upCast.is_colliding() and upCast.enabled and not downCast.is_colliding() and downCast.enabled:
			print("disable")
			disable_raycasts()
		
		if can_action and Input.is_action_just_pressed("punch"):
			punching = true
		
		crouching = Input.is_action_pressed("crouch") and not _stunned
		
#		if Input.is_action_just_pressed("punch"):
#			rpc("_on_Punch_body_entered", player)
		
		# Throw a potion
		if Input.is_action_just_pressed("throw") and not throwing and can_action:
			var potion_name = get_name() + str(potion_index)
			potion_index += 1
			potion_index = potion_index % 50 # rare to throw more than 50 potions at a time
			rpc("throw", potion_name, get_global_mouse_position(), get_tree().get_network_unique_id())
		
		if can_action and Input.is_action_just_pressed("drink"):
			var potion_name = get_name() + str(potion_index)
			potion_index += 1
			potion_index = potion_index % 50
			drink(potion_name)
		
		rset_unreliable("puppet_pos", position)
		rset_unreliable("puppet_vel", linear_vel)
		rset_unreliable("_facing_right", _facing_right)
		rset_unreliable("on_floor", on_floor)
		rset_unreliable("puppet_crouching", crouching)
		rset("puppet_punching", punching)
		
	else:
		position = puppet_pos
		linear_vel = puppet_vel
		crouching = puppet_crouching
		punching = puppet_punching
	
	directionNode.scale.x = 1 if _facing_right else -1
	nameNode.scale.x = directionNode.scale.x
	
	
	# Dont go into any animation if throwing
	if throwing or invinsible:
		return
	
	
	if on_floor:
		if punching:
			playback.travel("basic_attack")
			return
		if abs(linear_vel.x) > 10:
			if crouching:
				playback.travel("crouch_walk")
			else:
				playback.travel("run")
		else:
			if punching:
				playback.travel("basic_attack")
				return
			if crouching:
				playback.travel("crouch_idle")
			else:
				playback.travel("idle")
	else:
		if punching:
			playback.travel("air_punch")
			return
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
	get_node("../..").add_child(potion)
	potion.throw(force)

master func drink(potion_name):
	var potion = _equipped.instance()
	potion.player = self
	potion.set_name(potion_name)
	get_node("../..").add_child(potion)
	potion.drink()
	

remotesync func punch():
	playback.travel("punch")

# the master of the player is the one in charge to tell everyone
# that he was hit
master func damaged(_by_who, dmg:int, dmg_pos: float) -> void:
	if invinsible:
		return
	recover()
	var dir = sign(global_position.x - dmg_pos)
	linear_vel.x = dir*HIT_SPEED
	print(dmg)
	rpc("get_hurt", dmg)

# func that gets executed on every client
# it updates the health and plays the animation
remotesync func get_hurt(dmg: int) -> void:
	invinsible = true
	if health > 0:
		health -= dmg
		# here we can emit a signal that health has changed
		hpBar.set_hp_value(health - dmg)
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

master func enable_raycasts() -> void:
	upCast.enabled = true
	downCast.enabled = true

master func disable_raycasts() -> void:
	upCast.enabled = false
	downCast.enabled = false

master func make_intangible()->void:
	_tangible = false
	rpc("make_transparent")

master func make_tangible()->void:
	_tangible = true
	rpc("make_opaque")

master func empower_basics(amount: int)->void:
	punch_attack = min(punch_attack + amount, ATTACK_BUFF_CAP)

master func weaken_basics(amount: int)->void:
	punch_attack = max(BASICATTACK, punch_attack - amount)

master func stun()->void:
	_stunned = true

master func recover()->void:
	_stunned = false

remotesync func make_transparent()->void:
	modulate.a = 0.5
	set_collision_layer_bit(0, 0)
	set_collision_layer_bit(5, 1)
	set_collision_mask_bit(0, 0)
	set_collision_mask_bit(2, 0)
	set_collision_mask_bit(3, 0)

remotesync func make_opaque()->void:
	modulate.a = 1
	set_collision_layer_bit(0, 1)
	set_collision_layer_bit(5, 0)
	set_collision_mask_bit(0, 1)
	set_collision_mask_bit(2, 1)
	set_collision_mask_bit(3, 1)

master func pick_up_plant(params: Dictionary) -> void:
	var node_name = params.node_name

	var remaining_q = plants_inventory.add_item(
		params.plant_id,
		params.quantity
	)
	var plant_scene = get_node("/root/Level/Plants/%s" % node_name)
	plant_scene.rpc_id(1, "handle_pick_up", remaining_q)

remotesync func _on_Punch_body_entered(body):
	if body and body.is_in_group("player") and body != self:
		body.damaged(self, self.punch_attack, global_position.x)

