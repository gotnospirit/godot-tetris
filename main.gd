extends Node2D

const ArialFont = preload("res://fonts/arial.tres")

onready var model:Game = Game.new()


func _enter_tree():
	if UtilsMobile.IsMobile():
		# because every text shares the same font instance reference,
		# we can resize it once for all here
		ArialFont.size *= UtilsMobile.GetScale()


func _ready():
	model.connect("status_updated", self, "_on_status_updated")
	_on_status_updated(model.status)


func _exit_tree():
	model.disconnect("status_updated", self, "_on_status_updated")


func _on_status_updated(new_status:int) -> void:
	match new_status:
		Game.Status.INIT:
			$FiniteStateMachine.change_state("MainMenu")

		Game.Status.PLAYING:
			model.reset()
			$FiniteStateMachine.change_state("Playing")

		Game.Status.GAME_OVER:
			$FiniteStateMachine.change_state("GameOver")
