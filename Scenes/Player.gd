extends CharacterBody2D

class_name Player

# draw line
var currentPointPath: PackedVector2Array

@export var tileMap: TileMap
@export var tileMapQuadran: int
@export var speed: int = 100

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

var astarGrid: AStarGrid2D
var currentIdPath: Array[Vector2i]

var targetPosition: Vector2
var isMoving: bool

func tileMapInit() -> void:
	astarGrid = AStarGrid2D.new()
	astarGrid.region = tileMap.get_used_rect()
	astarGrid.cell_size = Vector2(tileMapQuadran, tileMapQuadran)
	astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astarGrid.update()
	
	# block paths that are not 'walkable'
	for x in tileMap.get_used_rect().size.x:
		for y in tileMap.get_used_rect().size.y:
			var tilePosition = Vector2(
				x + tileMap.get_used_rect().position.x,
				y + tileMap.get_used_rect().position.y)
			
			var tileData = tileMap.get_cell_tile_data(0, tilePosition)
			
			if !tileData || !tileData.get_custom_data("walkable"):
				astarGrid.set_point_solid(tilePosition)

func updateMousePath() -> void:
	currentPointPath = astarGrid.get_point_path(
		tileMap.local_to_map(global_position),
		tileMap.local_to_map(get_global_mouse_position())
	)

	for i in currentPointPath.size():
		currentPointPath[i] = currentPointPath[i] + Vector2(float(tileMapQuadran)/2.0, float(tileMapQuadran)/2.0)


func _ready():
	tileMapInit()
	
func _input(event):
	if !event.is_action_pressed("move"):
		return
	
	var idPath: Array[Vector2i]
	
	if isMoving:
		idPath = astarGrid.get_id_path(
			tileMap.local_to_map(global_position),
			tileMap.local_to_map(get_global_mouse_position())
		)
	else:
		idPath = astarGrid.get_id_path(
			tileMap.local_to_map(global_position),
			tileMap.local_to_map(get_global_mouse_position())
		).slice(1)
		
	if !idPath.is_empty():
		currentIdPath = idPath
		updateMousePath()

	
func _physics_process(delta):
	if !isMoving:
		animationPlayer.play('idle')
	else:
		animationPlayer.play('walking')
		
	if currentIdPath.is_empty():
		return

	if !isMoving:
		targetPosition = tileMap.map_to_local(currentIdPath.front())
		isMoving = true
		
	global_position = global_position.move_toward(targetPosition, speed * delta)
	
	if global_position == targetPosition:
		currentIdPath.pop_front()
		
		if !currentIdPath.is_empty():
			targetPosition = tileMap.map_to_local(currentIdPath.front())
		else:
			isMoving = false
		
