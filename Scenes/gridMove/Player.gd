extends CharacterBody2D

@export var tileMap: TileMap
@export var pointerSprite: Sprite2D
@export var animationPlayer: AnimationPlayer
@export var rayCastPointer: RayCast2D

var cellTileSize: int = 32
var isMoving = false
var movingSpeed = 0.5

func _process(_delta):
	if isMoving:
		return

	if Input.is_action_just_pressed("move_up"):
		move(Vector2.UP)
	elif Input.is_action_just_pressed("move_down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("move_left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("move_right"):
		move(Vector2.RIGHT)
	
func _physics_process(_delta):
	if !isMoving:
		animationPlayer.play('idle')
	else:
		animationPlayer.play('walking')
	
func move(direction: Vector2):
	# przechowuje informacje o aktualnej komórce TileMap, w której znajduje się postać.
	var currentTile: Vector2i = tileMap.local_to_map(global_position)
	# nastepna lokalizacja wzgledem kierunku
	var targetTile: Vector2i = Vector2i(currentTile.x + direction.x, currentTile.y + direction.y)

	print(currentTile, 'curreent', targetTile, 'target')

	var tileData: TileData = tileMap.get_cell_tile_data(0, targetTile)

	if !tileData || !tileData.get_custom_data("walkable"):
		return
		
	# global_position = tileMap.map_to_local(targetTile)

	pointerSprite.global_position = tileMap.map_to_local(targetTile)

	if checkRaycastCollision(direction):
		return

	var tween = create_tween()
	isMoving = true
	tween.tween_property(self, "global_position", tileMap.map_to_local(targetTile), movingSpeed).set_trans(Tween.TRANS_SINE)
	await tween.finished
	isMoving = false

func checkRaycastCollision(direction: Vector2) -> bool:
	rayCastPointer.target_position = direction * cellTileSize
	rayCastPointer.force_raycast_update()
	return rayCastPointer.is_colliding()
