class_name TestGame
extends GdUnitTestSuite


func test_game():
	var runner: GdUnitSceneRunner = scene_runner("res://game/game.tscn")
	assert_str(runner.scene().name).is_equal("Game")

	# Needed for any scene where UI is instantiated
	GUIDEInputFormatter.cleanup()
