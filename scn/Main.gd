extends Node2D

export(bool) var negative = false setget _set_negative

onready var animation = $AnimationPlayer
onready var animation2 = $AnimationPlayer2
onready var player = $Player
onready var levels = $Levels
onready var back_border = $BackBorder
onready var dont_disappear = $CanvasLayer/DontDisappear

const black_material = preload('res://asset/shader/Black.material')
const white_material = preload('res://asset/shader/White.material')
const safe_material = preload('res://asset/shader/Safe.material')

# Levels
const base_level = preload('res://scn/levels/BaseLevel.tscn');

var _level_index = 3
var _update_marker_x = 1024 + 1024 * .65
var _main_levels = [
	preload('res://scn/levels/Level1.tscn'),
	preload('res://scn/levels/Level2.tscn'),
	preload('res://scn/levels/Level3.tscn'),
	preload('res://scn/levels/Level4.tscn'),
	preload('res://scn/levels/Level5.tscn'),
	preload('res://scn/levels/Level6.tscn'),
	preload('res://scn/levels/Level7.tscn'),
	preload('res://scn/levels/Level8.tscn'),
	preload('res://scn/levels/Level9.tscn'),
	preload('res://scn/levels/Level10.tscn'),
]

func _get_new_level():
	var i = randi() % 9
	return _main_levels[i].instance()

func _set_base_levels():
	# Set up levels
	var level = _get_new_level()
	level.position.x = 1024
	levels.add_child(level)
	
	level = _get_new_level()
	level.position.x = 1024 * 2
	levels.add_child(level)

func _ready():
	set_process_input(true)
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	_set_negative(negative)
	animation.play("Color Flip")
	animation2.play("Count Effect")
	
	player.connect('submerged', self, '_on_player_submerged')
	
	_set_base_levels()
		
func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		GameRules.close_game()

func _set_negative(x):
	negative = x
	if is_inside_tree():
		GameRules.negative = negative
		black_material.set_shader_param('negative', negative)
		white_material.set_shader_param('negative', negative)
		safe_material.set_shader_param('negative', negative)
		
func _wait(time):
	$Timer.wait_time = time
	$Timer.start()
	return $Timer
		
func _on_player_submerged():
	animation.stop()
	animation.stop()
	player.visible = false
	player.set_physics_process(false)
	
	dont_disappear.visible = true
	
	yield(_wait(1.4), 'timeout')
	
	dont_disappear.visible = false
	
	back_border.position.x = 0
	_set_negative(false)
	
	for level in levels.get_children():
		level.queue_free()
	
	var level = base_level.instance()
	level.position.x = 0
	levels.add_child(level)
	
	_set_base_levels()
	
	player.position.x = 250
	player.position.y = 400
	player.visible = true
	player.set_physics_process(true)
	
	_level_index = 3
	_update_marker_x = 1024 + 1024 * .65
	
	GameRules.score = 0
	animation.play("Color Flip")
	animation2.play("Count Effect")

func _physics_process(delta):
	if player.global_position.x >= _update_marker_x:
		_update_marker_x += 1024
		
		levels.get_child(0).queue_free()
		back_border.position.x += 1024
		
		var level = _get_new_level()
		level.position.x = 1024 * _level_index
		levels.add_child(level)
		_level_index += 1