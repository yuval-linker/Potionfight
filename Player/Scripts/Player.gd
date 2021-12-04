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
const JUMP_BUFF_CAP = 400
const UPPER_SPEED_CAP = 500
const LOWER_SPEED_CAP = 150

# classes
var Potion = preload("res://Items/Potions/Scenes/Potion.tscn")
var SpacePotion = preload("res://Items/Potions/Scenes/SpacePotion.tscn")
var BoxingPotion = load("res://Items/Potions/Scenes/BoxingPotion.tscn")
var GravityPotion = preload("res://Items/Potions/Scenes/GravityPotion.tscn")
var TimePotion = preload("res://Items/Potions/Scenes/TimePotion.tscn")
var YingYangPotion = preload("res://Items/Potions/Scenes/YingYangPotion.tscn")

var JumpParticles = preload("res://Particles/Scenes/JumpParticles.tscn")
var HeartParticles = preload("res://Particles/Scenes/LifeParticles.tscn")

# onready vars
onready var direction_timer = $DirecitonTimer
onready var spawner = $DirectionNode/PotionSpawn
onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
onready var directionNode = $DirectionNode
onready var nameNode = $DirectionNode/NameNode
onready var hpBar = $HPBar
onready var characterSprite: Sprite = $DirectionNode/Sprite
onready var upCast: RayCast2D = $UpCast
onready var downCast: RayCast2D = $DownCast
onready var stunParticles: Particles2D = $DirectionNode/StunParticles
onready var jumpSpawn: Position2D = $DirectionNode/JumpParticleSpawn
onready var heartsSpawn: Position2D = $DirectionNode/HeartSpawn

var potions_inventory: PotionsInventoryResource
var plants_inventory: PlantsInventoryResource

# puppet vars
puppet var puppet_vel: Vector2 = Vector2.ZERO
puppet var _facing_right: bool = true
puppet var on_floor: bool = true
puppet var puppet_pos: Vector2
puppet var puppet_crouching: bool = false
puppet var puppet_punching: bool = false
puppet var puppet_stunned: bool = false
puppet var puppet_jump_buffed: bool = false
puppet var puppet_just_jumped: bool = false
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
var modified_jump_force = JUMPFORCE
var modified_speed = SPEED
var jump_buffed = false
var just_jumped = false
var potion_index = 0
var particle_index = 0

signal continue_throwing

func _ready() -> void:
	if self.is_network_master():
		potions_inventory = PotionsInventoryResource.new()
		plants_inventory = PlantsInventoryResource.new()
	$AnimationTree.active = true
	$DirectionNode/Punch/CollisionShape2D.disabled = true
	direction_timer.connect("timeout", self, "on_direction_timeout")
	puppet_pos = position
	_equipped = GravityPotion

func _physics_process(delta: float) -> void:
	if is_network_master():
		linear_vel = move_and_slide(linear_vel, Vector2.UP)
		on_floor = is_on_floor()
		
		var can_action = not _stunned and _tangible
		var target_vel = Input.get_action_strength("right") - Input.get_action_strength("left")
		target_vel = target_vel if not _stunned else 0
		
		linear_vel.x = move_toward(linear_vel.x, target_vel * modified_speed, ACCELERATION)
		linear_vel.y += GRAVITY * delta
		if not _stunned:
			
			# Movement
		
			_second_jump = _second_jump or on_floor
			# Jump
			if Input.is_action_just_pressed("jump"):
				if on_floor:
					linear_vel.y = -modified_jump_force
					just_jumped = true
				elif _second_jump:
					linear_vel.y = -modified_jump_force
					_second_jump = false
					just_jumped = true
			else:
				just_jumped = false
			
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
		
		if Input.is_action_just_pressed("change"):
			_equipped = Potion if _equipped == GravityPotion else GravityPotion
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
		rset_unreliable("puppet_stunned", _stunned)
		rset_unreliable("puppet_jump_buffed", jump_buffed)
		rset_unreliable("puppet_just_jumped", just_jumped)
		rset("puppet_punching", punching)
		
	else:
		position = puppet_pos
		linear_vel = puppet_vel
		crouching = puppet_crouching
		punching = puppet_punching
		_stunned = puppet_stunned
		jump_buffed = puppet_jump_buffed
		just_jumped = puppet_just_jumped
	
	directionNode.scale.x = 1 if _facing_right else -1
	nameNode.scale.x = directionNode.scale.x
	
	
	# Dont go into any animation if throwing
	if throwing or invinsible:
		return
	
	if jump_buffed and just_jumped:
		spawn_jump_particles()
	
	if on_floor:
		if _stunned:
			playback.travel("stunned")
			return
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
		if _stunned:
			playback.travel("air_stunned")
			return
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
master func damaged(_by_who, dmg:int, dmg_pos: float, hit_speed: int = HIT_SPEED) -> void:
	if invinsible:
		return
	recover()
	var dir = sign(global_position.x - dmg_pos)
	linear_vel.x = dir*hit_speed
	rpc("get_hurt", dmg)

master func healed(amount: int)->void:
	rpc("get_healed", amount)

remotesync func get_healed(amount: int)->void:
	health = min(health + amount, MAXHEALTH)
	hpBar.set_hp_value(health)
	var hearts = HeartParticles.instance()
	hearts.position = heartsSpawn.position
	directionNode.add_child(hearts)

# func that gets executed on every client
# it updates the health and plays the animation
remote func get_hurt(dmg: int) -> void:
	invinsible = true
	if health > 0:
		health -= dmg
		# here we can emit a signal that health has changed
		hpBar.set_hp_value(health)
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
	rpc("enable_stun_particle")

master func recover()->void:
	_stunned = false
	rpc("disable_stun_particle")

master func light_body(modifier: int)->void:
	modified_jump_force = min(modified_jump_force + modifier, JUMP_BUFF_CAP)
	jump_buffed = true

master func heavy_body(modifier: int)->void:
	modified_jump_force = max(modified_jump_force - modifier, JUMPFORCE)
	jump_buffed = false

master func make_faster(amount: int)->void:
	var old_speed = modified_speed
	modified_speed = min(modified_speed + amount, UPPER_SPEED_CAP)
	print(modified_speed)
	if old_speed < SPEED and modified_speed >= SPEED:
		rpc("make_normal_color")

master func make_slower(amount: int)->void:
	modified_speed = max(modified_speed - amount, LOWER_SPEED_CAP)
	print(modified_speed)
	if modified_speed < SPEED:
		rpc("make_blue")

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

remotesync func enable_stun_particle()->void:
	stunParticles.emitting = true

remotesync func disable_stun_particle()->void:
	stunParticles.emitting = false

remotesync func make_blue()->void:
	characterSprite.modulate.r = 0.7
	characterSprite.modulate.g = 0.7
	characterSprite.modulate.b = 1

remotesync func make_normal_color()->void:
	characterSprite.modulate.r = 1
	characterSprite.modulate.g = 1
	characterSprite.modulate.b = 1

func spawn_jump_particles()->void:
	var particles = JumpParticles.instance()
	particles.position = jumpSpawn.global_position
	particles.set_name(get_name() + "_Jump" + str(particle_index))
	get_node("../..").add_child(particles)
	particle_index += 1
	particle_index = particle_index % 50

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

