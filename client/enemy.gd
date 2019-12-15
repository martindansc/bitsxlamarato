extends KinematicBody2D

const GRAVITY = 500.0
const DISTANCE_TO_PLAYER = 800
const WALK_SPEED = 80
var first_position
onready var player = get_node("../KinematicBody2D")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	first_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(player.reset):
		set_global_position(first_position)
	
	var velocity = Vector2()
	# Create forces
	var force = Vector2(0, GRAVITY)
	velocity += force * delta
	
	if(player.position.distance_to(position) < DISTANCE_TO_PLAYER):
		velocity.x = -WALK_SPEED
	
	move_and_slide(velocity)

	pass
