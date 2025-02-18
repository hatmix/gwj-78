class_name TestPlayer
extends GdUnitTestSuite


func test_player_scene():
	var runner: GdUnitSceneRunner = scene_runner("res://game/player/player.tscn")
	assert_str(runner.scene().name).is_equal("Player")
