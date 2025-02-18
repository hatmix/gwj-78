class_name TestDrone
extends GdUnitTestSuite


func test_drone_scene():
	var runner: GdUnitSceneRunner = scene_runner("res://game/enemies/drone/drone.tscn")
	assert_str(runner.scene().name).is_equal("Drone")
