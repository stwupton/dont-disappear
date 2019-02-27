extends Node2D

onready var animation = $AnimationPlayer
onready var area = $Sprite/Area2D
onready var label = $Label

var checked = false

func _ready():
	area.connect('area_entered', self, '_on_area_entered')
	
func _on_area_entered(area):
	if area.name == 'SubmergeCheck' && !checked:
		checked = true
		var score = GameRules.score + 1
		if score >= GameRules.high_score:
			label.text = str(score)
		else:
			label.text = str(score) + '/' + str(GameRules.high_score)
		GameRules.score += 1
		animation.play('Show Score')
