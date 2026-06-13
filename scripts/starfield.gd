extends Node2D

@export var star_count: int = 400
@export var area: float = 8000.0

var stars: Array = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    for i in range(star_count):
        var pos = Vector2(rng.randf_range(-area/2.0, area/2.0), rng.randf_range(-area/2.0, area/2.0))
        var r = rng.randf_range(0.5, 2.0)
        var a = rng.randf_range(0.2, 1.0)
        stars.append([pos, r, a])
    queue_redraw()

func _draw() -> void:
    for s in stars:
        draw_circle(s[0], s[1], Color(1,1,1,s[2]))
