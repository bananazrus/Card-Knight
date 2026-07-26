@tool
extends TileMapLayer

@export var find_my_missing_id: bool = false:
	set(value):
		if value:
			check_missing_ids()

func check_missing_ids() -> void:
	if not tile_set:
		print("Please attach a TileSet to this TileMapLayer first!")
		return
		
	var missing_ids: Array = []
	
	for coords in get_used_cells():
		var source_id = get_cell_source_id(coords)
		# Check if this cell points to an ID that doesn't exist in your TileSet
		if not tile_set.has_source(source_id) and not source_id in missing_ids:
			missing_ids.append(source_id)
			
	print("========================================")
	print(">>> YOUR GREEN DOTS ARE LOOKING FOR SOURCE ID: ", missing_ids)
	print("========================================")
