extends KinematicBody2D

signal submerged

export(float) var movement_speed = 400
export(float) var jump_force = 600
export(float) var gravity = 30

onready var sprite = $AnimatedSprite
onready var submerge_check = $SubmergeCheck

var coyote_time = 5

var _motion = Vector2()
var _gravity_scalar = 1
var _areas = []
var _coyote_count = 0
var _was_on_floor = false

func _ready():
	set_physics_process(true)
	
func _physics_process(delta):
	_check_submersion()
	
	# Check if player can coyote jump
	var can_coyote_jump = false
	if _motion.y > 0 && _was_on_floor && _coyote_count <= coyote_time:
		can_coyote_jump = true
		_coyote_count += 1
	else:
		_was_on_floor = is_on_floor()
		_coyote_count = 0
	
	# Handle horizontal motion
	var direction = Vector2()
	if Input.is_action_pressed('ui_right'):
		direction.x += 1
	if Input.is_action_pressed('ui_left'):
		direction.x -= 1
	direction = direction.normalized()
	_motion.x += direction.x * movement_speed

	# Show run animation
	var animation
	if is_on_floor():
		if direction.x > 0:
			animation = 'run'
		elif direction.x < 0:
			animation = 'run'
		else:
			animation = 'idle'
	
	# Handle jump
	var jumped = false
	if Input.is_action_just_pressed('ui_up') && (is_on_floor() || can_coyote_jump):
		_motion.y = 0
		_motion.y -= jump_force
		jumped = true
	if Input.is_action_pressed('ui_up') && _motion.y < 0:
		_gravity_scalar = .6
		
	# Apply gravity
	_motion.y += gravity * _gravity_scalar
	
	# Show jump/fall animation
	if jumped:
		animation = 'jump_up'
	elif !is_on_floor() && _motion.y > 0:
		animation = 'fall_down'
	
	# Change animation if it's different
	if animation != null && animation != sprite.animation:
		sprite.animation = animation
		
	# Change facing direction
	if _motion.x < 0:
		sprite.flip_h = true
	elif _motion.x > 0:
		sprite.flip_h = false
	
	_motion = move_and_slide(_motion, Vector2(0, -1));
	
	# Reset properties for next frame
	_motion.x = 0
	_gravity_scalar = 1
	
func _check_submersion():
	var areas = submerge_check.get_overlapping_areas()
	if GameRules.negative && areas.size() == 0:
		emit_signal('submerged')
	else:
		for area in areas:
			if area.name == 'WhiteArea':
				var dx = abs(submerge_check.global_position.x - area.global_position.x)
				var dy = abs(submerge_check.global_position.y - area.global_position.y)
				if dx < 60 && dy < 40:
					emit_signal('submerged')