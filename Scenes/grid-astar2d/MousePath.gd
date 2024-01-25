extends Node2D

@export var playerPointer: Player 
var dotScene: PackedScene = preload("res://Scenes/grid-astar2d/Dot.tscn")
var createdDots: Array = []

func _ready():
	playerPointer.redrawNewPointPath.connect(clearDots)

func _process(_delta):
	queue_redraw()

func _draw():
	if playerPointer.currentPointPath.is_empty():
		clearDots()
		return

	for i in range(playerPointer.currentPointPath.size()):
		var dotPosition: Vector2 = playerPointer.currentPointPath[i]

		var dotExists = false
		for dot in createdDots:
			if dot.position == dotPosition:
				dotExists = true
				break
		
		if !dotExists:
			var dot = dotScene.instantiate() as Node2D
			dot.position = dotPosition
			self.add_child(dot)
			
			createdDots.append(dot)
		
func clearDots():
	for dot in createdDots:
		dot.queue_free()
	createdDots.clear()
		
