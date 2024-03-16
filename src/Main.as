// c 2024-03-15
// m 2024-03-16

bool         deadTurtle      = false;
int          deadTurtleStart = 0;
const float  halfPi          = Math::PI * 0.5f;
string       loginLocal;
const string title           = "\\$0FB" + Icons::ArrowRight + "\\$G Default Movement";
bool         replay          = false;
const int    screenHeight    = Draw::GetHeight();
const int    screenWidth     = Draw::GetWidth();
bool         spectating      = false;
bool         wasDeadTurtle   = false;

void Main() {
    startnew(CacheLocalLogin);
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    if (
        App.RootMap is null
        || App.GameScene is null
    )
        return;

    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (
        Playground is null
        || Playground.Arena is null
        || Playground.Arena.Players.Length == 0
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
        || Playground.UIConfigs.Length == 0
        || Playground.UIConfigs[0] is null
    )
        return;

    CSceneVehicleVis@ Vis;

    CSmPlayer@ Player = cast<CSmPlayer@>(Playground.GameTerminals[0].GUIPlayer);

    if (Player !is null) {
        @Vis = VehicleState::GetVis(App.GameScene, Player);
        replay = false;
    } else {
        @Vis = VehicleState::GetSingularVis(App.GameScene);
        replay = true;
    }

    if (Vis is null)
        return;

    CGamePlaygroundUIConfig::EUISequence Sequence = Playground.UIConfigs[0].UISequence;
    if (
        Sequence != CGamePlaygroundUIConfig::EUISequence::Playing &&
        !(Sequence == CGamePlaygroundUIConfig::EUISequence::EndRound && replay)
    )
        return;

    CSmPlayer@ ViewingPlayer = VehicleState::GetViewingPlayer();
    spectating = ((ViewingPlayer is null ? "" : ViewingPlayer.ScriptAPI.Login) != loginLocal) && !replay;

    CSceneVehicleVisState@ State = Vis.AsyncState;
    if (State is null)
        return;

    CSmScriptPlayer@ ScriptPlayer = cast<CSmScriptPlayer@>(Player.ScriptAPI);
    if (ScriptPlayer is null)
        return;

    const int raceTime = Network.PlaygroundClientScriptAPI.GameTime - ScriptPlayer.StartTime;

    if (raceTime < 0) {
        deadTurtle = false;
        deadTurtleStart = 0;
        wasDeadTurtle = false;
    }

    deadTurtle = State.IsTopContact && ScriptPlayer.WheelsContactCount == 0;

    if (deadTurtle) {
        if (!wasDeadTurtle) {
            wasDeadTurtle = true;
            deadTurtleStart = raceTime;
        }
    } else
        wasDeadTurtle = false;

    if (
        (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (S_Window)
        RenderUI(State, raceTime);

    if (!Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        RenderNvg(State);
}

void RenderUI(CSceneVehicleVisState@ State, const int raceTime) {
    UI::Begin(title, S_Window, UI::WindowFlags::None);
        if (UI::BeginTable("##table", 2, UI::TableFlags::RowBg)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("dead turtle time");
            UI::TableNextColumn();
            UI::Text(Time::Format(deadTurtle ? raceTime - deadTurtleStart : 0));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("velocity");
            UI::TableNextColumn();
            UI::Text(Text::Format("%.3f, ", State.WorldVel.x) + Text::Format("%.3f, ", State.WorldVel.y) + Text::Format("%.3f", State.WorldVel.z));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("speed");
            UI::TableNextColumn();
            UI::Text(tostring(State.WorldVel.Length()));

            UI::PopStyleColor();
            UI::EndTable();
        }

    UI::End();
}

void RenderNvg(CSceneVehicleVisState@ State) {
    if (Camera::IsBehind(State.Position))
        return;

    vec3[] points;

    for (float theta = 0.0f; theta < 4.0f * halfPi; theta += halfPi / S_Steps) {
        points.InsertLast(
            State.Position
                + (State.Dir * Math::Sin(theta) * S_Radius)
                + (State.Left * Math::Cos(theta) * S_Radius)
                + (State.Dir * -S_X_Offset)
                + (State.Up * S_Y_Offset)
        );
    }

    nvg::BeginPath();

    const vec2 initPoint = Camera::ToScreenSpace(points[0]);
    nvg::MoveTo(initPoint);

    for (uint i = 1; i < points.Length; i++) {
        const vec2 point = Camera::ToScreenSpace(points[i]);
        if (InScreenBounds(point))
            nvg::LineTo(point);
    }

    if (InScreenBounds(initPoint))
        nvg::LineTo(initPoint);

    nvg::StrokeColor(S_Color);
    nvg::StrokeWidth(S_Stroke);
    nvg::Stroke();
}