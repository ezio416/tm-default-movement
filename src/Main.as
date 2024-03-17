// c 2024-03-15
// m 2024-03-16

bool         deadTurtle      = false;
int          deadTurtleStart = 0;
const float  halfPi          = Math::PI * 0.5f;
string       loginLocal;
const string title           = "\\$0FB" + Icons::ArrowRight + "\\$G Default Movement";
vec3[]       planarVelocityRollingValues;
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
        planarVelocityRollingValues.RemoveRange(0, planarVelocityRollingValues.Length);
    }

    deadTurtle = State.IsTopContact && ScriptPlayer.WheelsContactCount == 0;

    if (deadTurtle) {
        if (!wasDeadTurtle) {
            wasDeadTurtle = true;
            deadTurtleStart = raceTime;
        }
    } else {
        wasDeadTurtle = false;
        planarVelocityRollingValues.RemoveRange(0, planarVelocityRollingValues.Length);
    }

    if (
        (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (S_Debug)
        RenderUI(State, raceTime);

    if (
        !Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed
        && deadTurtle
        && raceTime - deadTurtleStart > S_RenderAfter * 1000
    )
        RenderNvg(State);
}

void RenderUI(CSceneVehicleVisState@ State, const int raceTime) {
    UI::Begin(title + " (Debug)", S_Debug, UI::WindowFlags::AlwaysAutoResize);
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
            UI::Text(FormatVec3(State.WorldVel));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("speed");
            UI::TableNextColumn();
            UI::Text(tostring(State.WorldVel.Length()));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("X speed");
            UI::TableNextColumn();
            UI::Text(Text::Format("%.3f", State.WorldVel.x));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("Z speed");
            UI::TableNextColumn();
            UI::Text(Text::Format("%.3f", State.WorldVel.z));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("X-Z speed");
            UI::TableNextColumn();
            UI::Text(Text::Format("%.3f", vec3(State.WorldVel.x, 0.0f, State.WorldVel.z).Length()));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("position");
            UI::TableNextColumn();
            UI::Text(FormatVec3(State.Position));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("dir");
            UI::TableNextColumn();
            UI::Text(FormatVec3(State.Dir));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("left");
            UI::TableNextColumn();
            UI::Text(FormatVec3(State.Left));

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("up");
            UI::TableNextColumn();
            UI::Text(FormatVec3(State.Up));

            UI::PopStyleColor();
            UI::EndTable();
        }

    UI::End();
}

void RenderNvg(CSceneVehicleVisState@ State) {
    if (Camera::IsBehind(State.Position))
        return;

    const vec3 startPoint = State.Position + (State.Dir * -S_X_Offset) + (State.Up * S_Y_Offset);
    const vec2 startPointScreen = Camera::ToScreenSpace(startPoint);

    // line
    //#########################################################################

    nvg::StrokeColor(S_Color);
    nvg::StrokeWidth(S_Stroke / (Camera::GetCurrentPosition() - State.Position).Length());
    nvg::BeginPath();

    const vec3 planerVelocity = vec3(State.WorldVel.x, 0.0f, State.WorldVel.z);

    planarVelocityRollingValues.InsertLast(planerVelocity);
    while (planarVelocityRollingValues.Length > S_RollingMax)
        planarVelocityRollingValues.RemoveAt(0);

    const vec3 planarVelocityAverage = AverageVec3(planarVelocityRollingValues);
    const vec3 planarVelocityNormal = planarVelocityAverage.Normalized();
    const float planarVelocityLength = planarVelocityAverage.Length();

    const vec3 endPoint = startPoint + (planarVelocityLength > 0.0f ? planarVelocityNormal * planarVelocityLength * 720.0f : vec3());
    const vec2 endPointScreen = Camera::ToScreenSpace(endPoint);

    if (InScreenBounds(startPointScreen))
        nvg::MoveTo(startPointScreen);

    if (InScreenBounds(endPointScreen))
        nvg::LineTo(endPointScreen);

    nvg::Stroke();

    // start ball
    //#########################################################################

    nvg::FillColor(S_StartColor);
    nvg::BeginPath();

    nvg::Circle(startPointScreen, S_BallRadius / (Camera::GetCurrentPosition() - startPoint).Length());

    nvg::Fill();

    // 10-minute ball
    //#########################################################################

    nvg::FillColor(S_10mColor);
    nvg::BeginPath();

    const vec3 midPoint = startPoint + (planarVelocityLength > 0.0f ? planarVelocityNormal * planarVelocityLength * 360.0f : vec3());
    nvg::Circle(Camera::ToScreenSpace(midPoint), S_BallRadius / (Camera::GetCurrentPosition() - midPoint).Length());

    nvg::Fill();

    // 20-minute ball
    //#########################################################################

    nvg::FillColor(S_20mColor);
    nvg::BeginPath();

    nvg::Circle(endPointScreen, S_BallRadius / (Camera::GetCurrentPosition() - endPoint).Length());

    nvg::Fill();
}