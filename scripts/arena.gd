extends TileMapLayer

const COLS := 40
const ROWS := 23
const FLOOR_SEED := 6
const WEIGHTS := [30, 28, 8, 7, 6, 5, 4, 6, 6]

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = FLOOR_SEED
	var total := 0
	for w in WEIGHTS:
		total += w
	for y in ROWS:
		for x in COLS:
			var r := rng.randi_range(0, total - 1)
			var t := 0
			while r >= WEIGHTS[t]:
				r -= WEIGHTS[t]
				t += 1
			set_cell(Vector2i(x, y), 0, Vector2i(t, 0))
