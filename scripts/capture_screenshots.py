#!/usr/bin/env python3
"""
AetherDrive Screenshot Generator
Renders QML views offscreen and exports crisp high-res screenshots for documentation.
"""

import os
import sys
import time
from pathlib import Path

os.environ["QT_QPA_PLATFORM"] = "offscreen"

from PySide6.QtGui import QGuiApplication, QFontDatabase, QFont
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtCore import QUrl, QObject, Signal, Property, Slot

class ThemeController(QObject):
    nightModeChanged = Signal()
    themeColorsChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._isNightMode = True

    @Property(bool, notify=nightModeChanged)
    def isNightMode(self): return self._isNightMode

    @Slot(bool)
    def setNightMode(self, night):
        if self._isNightMode != night:
            self._isNightMode = night
            self.nightModeChanged.emit()
            self.themeColorsChanged.emit()

def generate_screenshots():
    QQuickStyle.setStyle("Basic")
    app = QGuiApplication(sys.argv)

    # Register Segoe UI fonts
    for font_file in ["segoeui.ttf", "segoeuib.ttf", "segoeuil.ttf", "seguisb.ttf", "arial.ttf"]:
        p = f"C:/Windows/Fonts/{font_file}"
        if os.path.exists(p):
            QFontDatabase.addApplicationFont(p)
    app.setFont(QFont("Segoe UI", 10))

    engine = QQmlApplicationEngine()
    theme_controller = ThemeController()
    engine.rootContext().setContextProperty("themeController", theme_controller)

    base_dir = Path(__file__).resolve().parent.parent
    qml_dir = base_dir / "hmi" / "qml"
    shots_dir = base_dir / "docs" / "screenshots"
    shots_dir.mkdir(parents=True, exist_ok=True)

    engine.addImportPath(str(qml_dir))
    engine.load(QUrl.fromLocalFile(str(qml_dir / "Main.qml")))

    if not engine.rootObjects():
        print("Failed to load QML root object!")
        sys.exit(1)

    window = engine.rootObjects()[0]
    window.setWidth(1600)
    window.setHeight(860)
    window.show()

    def settle(frames=10):
        for _ in range(frames):
            app.processEvents()
            time.sleep(0.02)

    # 1: Panoramic Cockpit (Night Mode)
    theme_controller.setNightMode(True)
    window.setProperty("cockpitViewMode", 0)
    settle()
    window.grabWindow().save(str(shots_dir / "panoramic_cockpit_night.png"))
    print(f"Captured: {shots_dir / 'panoramic_cockpit_night.png'}")

    # 2: Instrument Cluster Only (Night Mode)
    theme_controller.setNightMode(True)
    window.setProperty("cockpitViewMode", 1)
    settle()
    window.grabWindow().save(str(shots_dir / "cluster_night_mode.png"))
    print(f"Captured: {shots_dir / 'cluster_night_mode.png'}")

    # 3: Instrument Cluster Only (Day Mode)
    theme_controller.setNightMode(False)
    window.setProperty("cockpitViewMode", 1)
    settle()
    window.grabWindow().save(str(shots_dir / "cluster_day_mode.png"))
    print(f"Captured: {shots_dir / 'cluster_day_mode.png'}")

    # Restore night mode for infotainment captures
    theme_controller.setNightMode(True)
    window.setProperty("cockpitViewMode", 2)
    settle()

    # Infotainment Screens
    window.setProperty("cockpitViewMode", 2)
    settle()

    # Find InfotainmentView item to change currentTabIndex
    info_views = [obj for obj in window.findChildren(QObject, "infotainmentView")]
    info_view = info_views[-1] if info_views else None

    # 4: Home Screen
    if info_view: info_view.setProperty("currentTabIndex", 0)
    settle()
    window.grabWindow().save(str(shots_dir / "infotainment_home.png"))
    print(f"Captured: {shots_dir / 'infotainment_home.png'}")

    # 5: Navigation Screen
    if info_view: info_view.setProperty("currentTabIndex", 1)
    settle()
    window.grabWindow().save(str(shots_dir / "infotainment_navigation.png"))
    print(f"Captured: {shots_dir / 'infotainment_navigation.png'}")

    # 6: Media Screen
    if info_view: info_view.setProperty("currentTabIndex", 2)
    settle()
    window.grabWindow().save(str(shots_dir / "infotainment_media.png"))
    print(f"Captured: {shots_dir / 'infotainment_media.png'}")

    # 7: Climate Screen
    if info_view: info_view.setProperty("currentTabIndex", 3)
    settle()
    window.grabWindow().save(str(shots_dir / "infotainment_climate.png"))
    print(f"Captured: {shots_dir / 'infotainment_climate.png'}")

    # 8: OTA Updates Screen
    if info_view: info_view.setProperty("currentTabIndex", 4)
    settle()
    window.grabWindow().save(str(shots_dir / "infotainment_ota.png"))
    print(f"Captured: {shots_dir / 'infotainment_ota.png'}")

    print("All screenshots successfully captured!")

if __name__ == "__main__":
    generate_screenshots()
