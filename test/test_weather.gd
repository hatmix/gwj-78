class_name TestWeatherTest
extends GdUnitTestSuite


func test_weather():
	var runner: GdUnitSceneRunner = scene_runner("res://game/weather/weather.tscn")
	var scene: Weather = runner.scene()
	assert_str(scene.name).is_equal("Weather")
	assert_bool(scene.is_snowing()).is_equal(true)
