// c 2024-03-15
// m 2024-03-16

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Render after" description="After becoming a dead turtle, render after this many seconds." min=0 max=60]
int S_RenderAfter = 5;

[Setting category="General" name="Show debug window"]
bool S_Debug = false;


[Setting category="Position/Style" name="X offset" min=-1.0f max=1.0f]
float S_X_Offset = 0.0f;

[Setting category="Position/Style" name="Y offset" min=0.0f max=3.0f]
float S_Y_Offset = 1.014f;

[Setting category="Position/Style" name="Ball radius" min=0.0f max=300.0f]
float S_BallRadius = 100.0f;

[Setting category="Position/Style" name="Starting ball color" color]
vec4 S_StartColor = vec4(0.0f, 1.0f, 0.0f, 0.5f);

[Setting category="Position/Style" name="10-minute ball color" color]
vec4 S_10mColor = vec4(0.0f, 0.0f, 1.0f, 0.5f);

[Setting category="Position/Style" name="20-minute ball color" color]
vec4 S_20mColor = vec4(1.0f, 0.0f, 0.0f, 0.5f);

[Setting category="Position/Style" name="Line stroke width" min=0.0f max=50.0f]
float S_Stroke = 20.0f;

[Setting category="Position/Style" name="Line color" color]
vec4 S_Color = vec4(1.0f, 1.0f, 1.0f, 0.5f);

[Setting category="Position/Style" name="Smoothing" description="How large to keep the rolling average. Direct impact on framerate." min=1 max=2000]
uint S_RollingMax = 1000;