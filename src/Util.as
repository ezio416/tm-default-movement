// c 2024-03-15
// m 2024-03-16

// courtesy of "Auto-hide Opponents" plugin - https://github.com/XertroV/tm-autohide-opponents
void CacheLocalLogin() {
    while (true) {
        sleep(100);

        loginLocal = GetLocalLogin();

        if (loginLocal.Length > 10)
            break;
    }
}

const bool InScreenBounds(const vec2 point) {
    return point.x > 0.0f && int(Math::Abs(point.x)) < screenWidth && point.y > 0.0f && int(Math::Abs(point.y)) < screenHeight;
}