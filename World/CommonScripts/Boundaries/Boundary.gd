class_name Boundary
extends Area2D

const EXPLOTION = preload("res://Particles/Scenes/DyingExplotion.tscn")

var rotation_radians = 0.0
var x_offset = 0
var y_offset = 0
var anim_offset = Vector2.ZERO

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")

func _on_area_entered(area)->void:
	if area.is_in_group("potion"):
		area._destroy()

func _on_body_entered(body)->void:
	if body.is_in_group("player"):
		# Matar al player
		# Para debuggear se vuelve al player a spawn
		var new_explotion = EXPLOTION.instance()
		new_explotion.connect("animation_finished", self, "_on_animation_finished", [new_explotion, body])
		get_node("../../").add_child(new_explotion)
		var x_pos = body.position.x if x_offset == 0 else x_offset 
		var y_pos = body.position.y if y_offset == 0 else y_offset
		new_explotion.position = Vector2(x_pos, y_pos)
		new_explotion.rotate(rotation_radians)
		new_explotion.offset = anim_offset
		new_explotion.play("explotion")
		body.out_of_bounds()
		body.set_physics_process(false)
		

func _on_animation_finished(animation, player)->void:
	# Mandar que murio el personaje y que hay que respawnear
	animation.queue_free()
	yield(get_tree().create_timer(2.0), "timeout")
	if player.lives == 0:
		player.dead = true
		Gamestate.end_screen()
		return
	player.set_physics_process(true)
	player.revive()
