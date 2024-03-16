// c 2024-03-15
// m 2024-03-16

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show window"]
bool S_Window = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;


[Setting category="Position/Style" name="Starting X position" min=-1.0f max=1.0f]
float S_X_Offset = 0.154f;

[Setting category="Position/Style" name="Starting Y position" min=0.0f max=3.0f]
float S_Y_Offset = 0.841f;

[Setting category="Position/Style" name="Radius" min=0.0f max=0.5f]
float S_Radius = 0.15f;

[Setting category="Position/Style" name="Number of steps" min=3 max=15]
int S_Steps = 12;

[Setting category="Position/Style" name="Stroke width" min=5.0f max=50.0f]
float S_Stroke = 20.0f;

[Setting category="Position/Style" name="Color" color]
vec4 S_Color = vec4(1.0f, 1.0f, 1.0f, 0.3f);