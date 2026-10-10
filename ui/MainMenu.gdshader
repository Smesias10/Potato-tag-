shader_type canvas_item;

uniform vec2 velocidad = vec2(0.15, 0.0); 

void fragment() {
    vec2 uvs_movidas = UV + (TIME * velocidad);
    COLOR = texture(TEXTURE, uvs_movidas);
}