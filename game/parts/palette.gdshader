shader_type canvas_item;

// Recolorea por luminancia a una rampa de 4 colores (de oscuro a claro), respetando alpha.
uniform vec4 c0 : source_color;
uniform vec4 c1 : source_color;
uniform vec4 c2 : source_color;
uniform vec4 c3 : source_color;

varying vec4 tint;

void vertex() {
	tint = COLOR; // modulate del nodo (parpadeo, flash)
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	float l = dot(t.rgb, vec3(0.299, 0.587, 0.114));
	vec4 c = l < 0.2 ? c0 : l < 0.42 ? c1 : l < 0.68 ? c2 : c3;
	COLOR = vec4(c.rgb, t.a) * tint;
}
