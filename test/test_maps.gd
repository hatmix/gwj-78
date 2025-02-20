class_name TestMaps
extends GdUnitTestSuite

# TODO: maybe get list of scenes dynamically
const MAP_SCENES: Array[String] = [
	"res://game/maps/map_1/map_1.tscn",
	"res://game/maps/map_2/map_2.tscn",
]


func test_maps():
	for scene_path: String in MAP_SCENES:
		var runner: GdUnitSceneRunner = scene_runner(scene_path)
		assert_str(runner.scene().name).contains("Map")

		# maps need a Player node
		# TODO: maybe use group instead
		var player: Node2D = runner.scene().find_child("Player")
		assert_that(player).is_not_null()

		# maps need at least one campfire
		# TODO: maybe use group instead
		var campfire: Node2D = runner.scene().find_child("Campfire")
		assert_that(campfire).is_not_null()

	# Needed for any scene where UI is instantiated
	GUIDEInputFormatter.cleanup()
