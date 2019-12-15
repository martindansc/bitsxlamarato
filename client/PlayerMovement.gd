extends KinematicBody2D

# This demo shows how to build a kinematic controller.

# Member variables
const GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_SPEED = 200
const JUMP_SPEED = 400
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false
var jump_signal = false

var first_position

var playing = false

onready var ANI = get_node("AnimatedSprite")

func _ready():
	first_position = position
	reset()
	
func reset():
	playing = true
	get_tree().reload_current_scene()

func continue():
	playing = true
	
func _physics_process(delta):
	if(!playing):
		return
	
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	#var walk_left = Input.is_action_pressed("ui_left")
	#var walk_right = Input.is_action_pressed("ui_right")
	#var jump = Input.is_action_pressed("ui_up")
	
	var walk_left = false
	var walk_right = true
	var jump = jump_signal
	jump_signal = false
	
	var stop = true
	
	if walk_left:
		velocity.x = -WALK_SPEED
	elif walk_right:
		velocity.x = WALK_SPEED
	else:
		velocity.x = 0
		
	velocity += force * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		ANI.play("run")
		on_air_time = 0
		
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		velocity.y = -JUMP_SPEED
		ANI.play("jump")
		jumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	var collisionCounter = get_slide_count()
	for i in collisionCounter:
		var collision = get_slide_collision(i)
		if(i == 0 and collision.collider is TileMap):
			check_pos(collision.collider.world_to_map(position), collision.collider)
		handle_collision(collision)
		
func handle_collision(collision):
	var collider = collision.collider
	if collider is TileMap:
		var col_cell = Vector2()
		var tile_pos = collider.world_to_map(position)
		tile_pos -= collision.normal
		check_pos(tile_pos, collider)
		
				
func check_pos(position, tilemap):
	if tilemap is TileMap:
		var tile = tilemap.get_cellv(position)
		if(tile != -1):
			var tile_name = tilemap.tile_set.tile_get_name(tile)
			if("Spike" in tile_name or "Acid" in tile_name):
				playing = false
				ANI.play("die")

func _on_Area2D_body_entered(body):
	playing = false
	ANI.play("win")


func _on_AnimatedSprite_animation_finished():
	if(playing == false):
		reset()
