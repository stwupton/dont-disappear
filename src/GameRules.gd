extends Node

var negative = false
var high_score = 0
var score = 0 setget _set_score

func _init():
	var save_file = File.new()
	if !save_file.file_exists('user://hs.txt'):
		return
		
	save_file.open('user://hs.txt', File.READ)
	high_score = int(save_file.get_line())
	save_file.close()

func _ready():
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		close_game()
	
func close_game():
	var save_file = File.new()
	save_file.open('user://hs.txt', File.WRITE)
	save_file.store_line(str(high_score))
	save_file.close()
	
	get_tree().quit()
	
func _set_score(x):
	score = x
	if score > high_score:
		high_score = score