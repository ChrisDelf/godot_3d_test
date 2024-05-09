extends CenterContainer

@export var dot_radius: float = 1.0
@export var dot_color: Color = Color.WHITE

func _ready():
	queue_redraw()
	
func _process(delta):
	pass
	
func _draw():
		draw_circle(Vector2(0,0), dot_radius, dot_color)
