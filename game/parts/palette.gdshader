shader_type canvas_item;

// Recolorea por luminancia a una rampa de 4 colores (de oscuro a claro), respetando alpha.
// Soporta modo split (fusión de dos materiales: izquierda c0..c3, derecha r0..r3)
uniform vec4 c0 : source_color;
uniform vec4 c1 : source_color;
uniform vec4 c2 : source_color;
uniform vec4 c3 : source_color;

uniform bool split = false;
uniform float frame_count = 1.0;
uniform vec4 r0 : source_color;
uniform vec4 r1 : source_color;
uniform vec4 r2 : source_color;
uniform vec4 r3 : source_color;

varying vec4 tint;

void vertex() {
	tint = COLOR; // modulate del nodo (parpadeo, flash)
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	float l = dot(t.rgb, vec3(0.299, 0.587, 0.114));
	
	// Determinar si en este fragmento usamos la rampa izquierda o derecha.
	// UV.x va de 0 a 1 en toda la textura. Multiplicando por frame_count y tomando fract,
	// obtenemos la posición horizontal local (0.0 a 1.0) dentro del frame actual.
	float local_x = fract(UV.x * max(frame_count, 1.0));
	bool use_right = split && (local_x >= 0.5);
	
	vec4 col0 = use_right ? r0 : c0;
	vec4 col1 = use_right ? r1 : c1;
	vec4 col2 = use_right ? r2 : c2;
	vec4 col3 = use_right ? r3 : c3;

	vec4 c = l < 0.2 ? col0 : l < 0.42 ? col1 : l < 0.68 ? col2 : col3;
	COLOR = vec4(c.rgb, t.a) * tint;
}
