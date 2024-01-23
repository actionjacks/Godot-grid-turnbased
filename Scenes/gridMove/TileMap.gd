extends TileMap

var labelScene: PackedScene = preload("res://Scenes/gridMove/Label.tscn")

func _draw():
	for x in range(self.get_used_rect().size.x):
		for y in range(self.get_used_rect().size.y):
			
			var tilePosition = Vector2(x, y)
			var label = labelScene.instantiate()

			label.text = str(tilePosition)
			label.set("theme_override_font_sizes/font_size", 5)
			label.position = self.map_to_local(tilePosition)
			
			self.add_child(label)
