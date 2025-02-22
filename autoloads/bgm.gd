extends AudioStreamPlayer

var tracks: Dictionary = {
	"map": {"file": "res://assets/music/contemplative.ogg", "volume_db": -6.0},
	"menu": {"file": "res://assets/music/journey.ogg", "volume_db": -6.0},
}
var current_track: Dictionary
var current_track_name: String


func play_track(track: String = "map", fade_duration: float = 0) -> void:
	if playing:
		if track == current_track_name:
			return
		await fade_out(0.5)
	current_track = tracks[track]
	current_track_name = track
	set_stream(load(current_track["file"]))
	if fade_duration:
		print("Bgm fade in ", track, " for ", fade_duration)
		fade_in(fade_duration)
	else:
		volume_db = current_track["volume_db"]
	play()


func fade_method(x: float) -> void:
	volume_db = linear_to_db(x)


func fade_in(duration: float = 1.0) -> void:
	volume_db = linear_to_db(0.0)
	var target: float = 1.0
	if current_track:
		target = db_to_linear(current_track["volume_db"])
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(fade_method, db_to_linear(volume_db), target, duration)
	await tween.finished


func fade_out(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(fade_method, db_to_linear(volume_db), 0.0, duration)
	await tween.finished


func _ready() -> void:
	pass
