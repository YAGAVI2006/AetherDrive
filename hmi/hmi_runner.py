#!/usr/bin/env python3
"""
AetherDrive Cockpit HMI Runner (PySide6 + MQTT)
Launches the full Qt 6 QML Digital Cockpit (Instrument Cluster + Infotainment)
and connects in real-time to the MQTT broker.
"""

import os
import sys
import json
import argparse
from pathlib import Path

from PySide6.QtCore import QObject, Signal, Property, Slot, QUrl, QTimer
from PySide6.QtGui import QGuiApplication, QIcon, QFontDatabase, QFont
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

import paho.mqtt.client as mqtt

DEFAULT_BROKER = "broker.emqx.io"
DEFAULT_PORT = 1883
TOPIC_DATA = "aetherdrive/vehicle/data"
TOPIC_ALERT = "aetherdrive/vehicle/alert"

class VehicleTelemetryModel(QObject):
    speedChanged = Signal()
    rpmChanged = Signal()
    batteryChanged = Signal()
    rangeChanged = Signal()
    gearChanged = Signal()
    doorLockedChanged = Signal()
    speedLimitChanged = Signal()
    driveModeChanged = Signal()
    laneDepartureChanged = Signal()
    alertMessageChanged = Signal()
    connectionChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._speed = 0.0
        self._rpm = 800
        self._battery = 85
        self._range = 350
        self._gear = "P"
        self._doorLocked = True
        self._speedLimit = 100.0
        self._driveMode = "NORMAL"
        self._laneDeparture = False
        self._alertMessage = ""
        self._isConnected = False

    # Q_PROPERTY getters
    @Property(float, notify=speedChanged)
    def speed(self): return self._speed

    @Property(int, notify=rpmChanged)
    def rpm(self): return self._rpm

    @Property(int, notify=batteryChanged)
    def battery(self): return self._battery

    @Property(int, notify=rangeChanged)
    def range(self): return self._range

    @Property(str, notify=gearChanged)
    def gear(self): return self._gear

    @Property(bool, notify=doorLockedChanged)
    def doorLocked(self): return self._doorLocked

    @Property(float, notify=speedLimitChanged)
    def speedLimit(self): return self._speedLimit

    @Property(str, notify=driveModeChanged)
    def driveMode(self): return self._driveMode

    @Property(bool, notify=laneDepartureChanged)
    def laneDeparture(self): return self._laneDeparture

    @Property(str, notify=alertMessageChanged)
    def alertMessage(self): return self._alertMessage

    @Property(bool, notify=connectionChanged)
    def isConnected(self): return self._isConnected

    @Slot(str)
    def updateTelemetryFromJson(self, json_str):
        try:
            data = json.loads(json_str)
            if "speed" in data and abs(self._speed - float(data["speed"])) > 0.01:
                self._speed = float(data["speed"])
                self.speedChanged.emit()

            if "rpm" in data and self._rpm != int(data["rpm"]):
                self._rpm = int(data["rpm"])
                self.rpmChanged.emit()

            if "battery" in data and self._battery != int(data["battery"]):
                self._battery = int(data["battery"])
                self.batteryChanged.emit()

            if "range" in data and self._range != int(data["range"]):
                self._range = int(data["range"])
                self.rangeChanged.emit()

            if "gear" in data and self._gear != str(data["gear"]):
                self._gear = str(data["gear"])
                self.gearChanged.emit()

            if "door_locked" in data and self._doorLocked != bool(data["door_locked"]):
                self._doorLocked = bool(data["door_locked"])
                self.doorLockedChanged.emit()

            if "speed_limit" in data and abs(self._speedLimit - float(data["speed_limit"])) > 0.01:
                self._speedLimit = float(data["speed_limit"])
                self.speedLimitChanged.emit()

            if "drive_mode" in data and self._driveMode != str(data["drive_mode"]):
                self._driveMode = str(data["drive_mode"])
                self.driveModeChanged.emit()

            if "lane_departure" in data and self._laneDeparture != bool(data["lane_departure"]):
                self._laneDeparture = bool(data["lane_departure"])
                self.laneDepartureChanged.emit()

            if "alert" in data and self._alertMessage != str(data["alert"]):
                self._alertMessage = str(data["alert"])
                self.alertMessageChanged.emit()

        except Exception as e:
            print(f"[HMI Telemetry] JSON parse error: {e}", flush=True)

    @Slot(str)
    def updateAlert(self, alert_text):
        if self._alertMessage != alert_text:
            self._alertMessage = alert_text
            self.alertMessageChanged.emit()

    def setConnected(self, connected):
        if self._isConnected != connected:
            self._isConnected = connected
            self.connectionChanged.emit()

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

class MqttBridge(QObject):
    messageReceived = Signal(str, str)
    connectionStatus = Signal(bool)

    def __init__(self, host=DEFAULT_BROKER, port=DEFAULT_PORT, parent=None):
        super().__init__(parent)
        self.host = host
        self.port = port
        self.client = None
        self._is_connected = False
        self._retry_timer = QTimer(self)
        self._retry_timer.setInterval(6000)
        self._retry_timer.timeout.connect(self._check_connection)

    def start(self):
        self._init_client()
        self._retry_timer.start()

    def _init_client(self):
        if self._is_connected:
            return
        try:
            if self.client:
                try:
                    self.client.loop_stop()
                    self.client.disconnect()
                except Exception:
                    pass

            try:
                self.client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, "AetherDrive-HMI")
            except AttributeError:
                self.client = mqtt.Client("AetherDrive-HMI")

            # Set exponential backoff (1s to 30s)
            self.client.reconnect_delay_set(min_delay=1, max_delay=30)
            self.client.on_connect = self.on_connect
            self.client.on_disconnect = self.on_disconnect
            self.client.on_message = self.on_message

            print(f"[HMI-MQTT] Connecting to broker {self.host}:{self.port}...", flush=True)
            self.client.connect_async(self.host, self.port, 60)
            self.client.loop_start()
        except Exception as e:
            print(f"[HMI-MQTT] Connection attempt failed: {e}. Will retry in background.", flush=True)
            self._is_connected = False
            self.connectionStatus.emit(False)

    def _check_connection(self):
        if not self._is_connected:
            self._init_client()

    def on_connect(self, client, userdata, flags, rc, properties=None):
        if rc == 0:
            print(f"[HMI-MQTT] Connected to broker successfully.", flush=True)
            self._is_connected = True
            client.subscribe(TOPIC_DATA, qos=0)
            client.subscribe(TOPIC_ALERT, qos=1)
            self.connectionStatus.emit(True)
        else:
            print(f"[HMI-MQTT] Connection returned code {rc}", flush=True)
            self._is_connected = False
            self.connectionStatus.emit(False)

    def on_disconnect(self, client, userdata, disconnect_flags_or_rc, reason_code=None, properties=None):
        print(f"[HMI-MQTT] Disconnected from broker. Auto-reconnecting...", flush=True)
        self._is_connected = False
        self.connectionStatus.emit(False)

    def on_message(self, client, userdata, msg):
        try:
            payload = msg.payload.decode("utf-8")
            self.messageReceived.emit(msg.topic, payload)
        except Exception as e:
            print(f"[HMI-MQTT] Decode error: {e}", flush=True)

    def stop(self):
        self._retry_timer.stop()
        if self.client:
            self.client.loop_stop()
            self.client.disconnect()

def main():
    parser = argparse.ArgumentParser(description="AetherDrive SDV Digital Cockpit HMI")
    parser.add_argument("--broker", default=DEFAULT_BROKER, help="MQTT Broker host (default: broker.emqx.io)")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT, help="MQTT Broker port (default: 1883)")
    parser.add_argument("--sim", action="store_true", help="Start with internal simulation enabled")
    args = parser.parse_args()

    app = QGuiApplication(sys.argv)
    app.setApplicationName("AetherDrive")
    app.setOrganizationName("AetherAutomotive")

    # Ensure Segoe UI fonts are loaded for crisp automotive typography
    for font_file in ["segoeui.ttf", "segoeuib.ttf", "segoeuil.ttf", "seguisb.ttf", "arial.ttf"]:
        p = f"C:/Windows/Fonts/{font_file}"
        if os.path.exists(p):
            QFontDatabase.addApplicationFont(p)
    app.setFont(QFont("Segoe UI", 10))

    QQuickStyle.setStyle("Basic")

    engine = QQmlApplicationEngine()

    telemetry_model = VehicleTelemetryModel()
    theme_controller = ThemeController()
    mqtt_bridge = MqttBridge(args.broker, args.port)

    # Dispatch MQTT callbacks safely into Qt's event loop
    def on_mqtt_message(topic, payload):
        if topic == TOPIC_DATA:
            telemetry_model.updateTelemetryFromJson(payload)
        elif topic == TOPIC_ALERT:
            try:
                alert_data = json.loads(payload)
                msg = alert_data.get("message", "")
                telemetry_model.updateAlert(msg)
            except Exception:
                telemetry_model.updateAlert(payload)

    mqtt_bridge.messageReceived.connect(on_mqtt_message)
    mqtt_bridge.connectionStatus.connect(telemetry_model.setConnected)
    mqtt_bridge.start()

    # Register context properties in QML
    root_context = engine.rootContext()
    root_context.setContextProperty("telemetryModel", telemetry_model)
    root_context.setContextProperty("themeController", theme_controller)

    # QML import paths
    current_dir = Path(__file__).resolve().parent
    qml_path = current_dir / "qml" / "Main.qml"
    engine.addImportPath(str(current_dir / "qml"))

    print(f"[HMI] Loading cockpit QML from: {qml_path}", flush=True)
    engine.load(QUrl.fromLocalFile(str(qml_path)))

    if not engine.rootObjects():
        print("[HMI] Error: Failed to load QML interface.", flush=True)
        mqtt_bridge.stop()
        sys.exit(-1)

    # If --sim flag passed, enable internal sim
    if args.sim:
        root_obj = engine.rootObjects()[0]
        root_obj.setProperty("standaloneSim", True)

    ret = app.exec()
    mqtt_bridge.stop()
    sys.exit(ret)

if __name__ == "__main__":
    main()
