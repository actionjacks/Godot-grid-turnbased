extends CharacterBody2D

@export var player: CharacterBody2D
@export var tileMap: TileMap
@export var animationPlayer: AnimationPlayer

var astarGrid: AStarGrid2D 
var cellTileSize: int = 32
var isMoving: bool = false

func _ready():
  astarGrid = AStarGrid2D.new()
  astarGrid.region = tileMap.get_used_rect()
  astarGrid.cell_size = Vector2(cellTileSize, cellTileSize)
  astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
  astarGrid.update()

  var regionSize = astarGrid.region.size
  var regionPosition = astarGrid.region.position

  for x in regionSize.x:
    for y in regionSize.y:
      var tilePosition = Vector2(x + regionSize.x, y + regionSize.y)
      var tileData = tileMap.get_cell_tile_data(0, tilePosition)

      if tileData == null or not tileData.get_custom_data("walkable"):
        astarGrid.set_point_solid(tilePosition)

func _process(delta):
  if isMoving:
    return
  
  move()

func _physics_process(_delta):
  if !isMoving:
    animationPlayer.play('idle')
  else:
    animationPlayer.play('walking')

func move():
  var enemies = get_tree().get_nodes_in_group('enemies')
  var occupied_positions = []

  for enemy in enemies:
    if enemy == self:
      continue

    occupied_positions.append(tileMap.local_to_map(enemy.global_position))

  for occupied_position in occupied_positions:
    astarGrid.set_point_solid(occupied_position)

  var path = astarGrid.get_id_path(
	tileMap.local_to_map(global_position),
	tileMap.local_to_map(player.global_position)
  )

  for occupied_position in occupied_positions:
    astarGrid.set_point_solid(occupied_position, false)

  path.pop_front()

  if path.size() == 1:
    print('got target!')
    return

  if path.is_empty():
    print('no path found')
    return

  var originalPosition = Vector2(global_position)
  # global_position = tileMap.map_to_local(path[0])
  
  var tween = create_tween()
  isMoving = true
  tween.tween_property(self, "global_position", tileMap.map_to_local(path[0]), 1).set_trans(Tween.TRANS_SINE)
  await tween.finished
  isMoving = false
