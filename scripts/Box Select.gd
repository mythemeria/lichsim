extends Control

var is_visible = true
var start_pos = Vector2()
var m_pos = Vector2()	

const border_colour = Color(0, 0, 1, 0.5)
const fill_colour = Color(0, 0, 1, 0.1)
const border_width = 2

func _draw():
	if is_visible and start_pos != m_pos:
		var rect = Rect2(start_pos.x, start_pos.y, m_pos.x-start_pos.x, m_pos.y - start_pos.y)
		draw_rect(rect, fill_colour)
		draw_rect(rect, border_colour, false, border_width)
		
func _process(_delta) -> void:
	queue_redraw()

func clear_vecs():
	start_pos = Vector2()
	m_pos = Vector2()
