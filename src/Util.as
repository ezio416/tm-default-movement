// c 2024-03-15
// m 2024-03-16

const vec3 AverageVec3(const vec3[] vecs) {
    vec3 total = vec3();

    for (uint i = 0; i < vecs.Length; i++)
        total += vecs[i];

    return total / (vecs.Length > 0 ? vecs.Length : 1.0f);
}

// courtesy of "Auto-hide Opponents" plugin - https://github.com/XertroV/tm-autohide-opponents
void CacheLocalLogin() {
    while (true) {
        sleep(100);

        loginLocal = GetLocalLogin();

        if (loginLocal.Length > 10)
            break;
    }
}

const string FormatVec2(const vec2 vec) {
    return Text::Format("%.3f, ", vec.x) + Text::Format("%.3f", vec.y);
}

const string FormatVec3(const vec3 vec) {
    return Text::Format("%.3f, ", vec.x) + Text::Format("%.3f, ", vec.y) + Text::Format("%.3f", vec.z);
}

const bool InScreenBounds(const vec2 point) {
    return point.x > 0.0f && int(Math::Abs(point.x)) < screenWidth && point.y > 0.0f && int(Math::Abs(point.y)) < screenHeight;
}