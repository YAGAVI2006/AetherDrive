#include "ThemeController.h"

namespace AetherDrive {

ThemeController::ThemeController(QObject* parent)
    : QObject(parent)
{
}

void ThemeController::setNightMode(bool night) {
    if (m_isNightMode != night) {
        m_isNightMode = night;
        emit nightModeChanged();
        emit themeColorsChanged();
    }
}

} // namespace AetherDrive
