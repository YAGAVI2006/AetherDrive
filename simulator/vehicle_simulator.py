#!/usr/bin/env python3
"""
AetherDrive - SDV Vehicle Telemetry Simulator (Python + MQTT)
Publishes realistic vehicle telemetry data via MQTT to topic 'aetherdrive/vehicle/data'.
"""

import argparse
import datetime
import json
import math
import sys
import time
import paho.mqtt.client as mqtt

DEFAULT_BROKER = "broker.emqx.io"
DEFAULT_PORT = 1883
TOPIC_VEHICLE_DATA = "aetherdrive/vehicle/data"
TOPIC_VEHICLE_ALERT = "aetherdrive/vehicle/alert"

class VehicleSimulator:
    def __init__(self, broker_host=DEFAULT_BROKER, broker_port=DEFAULT_PORT):
        self.broker_host = broker_host
        self.broker_port = broker_port

        # Vehicle state
        self.speed = 0.0          # km/h
        self.target_speed = 75.0  # cruising target
        self.rpm = 800            # RPM
        self.battery = 88.0       # %
        self.range_km = 360       # km
        self.gear = "P"           # P, R, N, D
        self.door_locked = True
        self.speed_limit = 100
        self.drive_mode = "NORMAL"
        self.lane_departure = False
        self.alert_msg = ""
        
        self.time_elapsed = 0.0
        self.client = None
        self.connected = False

    def on_connect(self, client, userdata, flags, rc, properties=None):
        if rc == 0:
            self.connected = True
            print(f"[SIMULATOR] Connected successfully to MQTT broker {self.broker_host}:{self.broker_port}")
        else:
            print(f"[SIMULATOR] MQTT Connection returned result code {rc}")

    def on_disconnect(self, client, userdata, disconnect_flags_or_rc, reason_code=None, properties=None):
        self.connected = False
        print("[SIMULATOR] Disconnected from MQTT broker. Retrying in background...")

    def connect_mqtt(self):
        try:
            if self.client:
                try:
                    self.client.loop_stop()
                    self.client.disconnect()
                except Exception:
                    pass

            try:
                self.client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, "AetherDrive-Simulator")
            except AttributeError:
                self.client = mqtt.Client("AetherDrive-Simulator")

            self.client.reconnect_delay_set(min_delay=1, max_delay=30)
            self.client.on_connect = self.on_connect
            self.client.on_disconnect = self.on_disconnect
            
            print(f"[SIMULATOR] Connecting to MQTT broker {self.broker_host}:{self.broker_port}...")
            self.client.connect_async(self.broker_host, self.broker_port, 60)
            self.client.loop_start()
        except Exception as e:
            print(f"[SIMULATOR] Warning: Could not connect to MQTT broker ({e}). Will retry automatically.")

    def update_physics(self, dt=0.1):
        self.time_elapsed += dt

        # Realistic dynamic driving cycle:
        # 0 - 3s: Parked
        # 3s+: Drive mode with harmonic acceleration/braking curves
        if self.time_elapsed < 3.0:
            self.gear = "P"
            desired_speed = 0.0
        else:
            self.gear = "D"
            # Sine wave speed fluctuation simulating city + highway transitions
            fluctuation = 22.0 * math.sin(self.time_elapsed * 0.12) + 10.0 * math.cos(self.time_elapsed * 0.3)
            desired_speed = max(0.0, self.target_speed + fluctuation)

        # Acceleration and deceleration curves
        if self.speed < desired_speed:
            self.speed = min(desired_speed, self.speed + (3.8 * dt * 3.5))
        elif self.speed > desired_speed:
            self.speed = max(desired_speed, self.speed - (2.5 * dt * 3.5))

        # Motor / Engine RPM calculation
        if self.speed < 1.0:
            self.rpm = 800
        else:
            base_rpm = 950 + (self.speed * 42.0)
            flutter = 30.0 * math.sin(self.time_elapsed * 2.0)
            self.rpm = int(base_rpm + flutter)

        # Battery drainage & Regenerative braking
        if self.speed > desired_speed:
            # Regenerative braking slightly recovers charge
            self.battery = min(100.0, self.battery + (0.003 * dt))
        else:
            # Power consumption
            self.battery = max(2.0, self.battery - ((0.01 + (self.speed / 120.0) * 0.018) * dt))

        self.range_km = int(self.battery * 4.1)
        self.door_locked = (self.speed > 15.0)

        # Periodic ADAS lane departure alert simulation every ~40 seconds for 4 seconds
        cycle = self.time_elapsed % 45.0
        self.lane_departure = (40.0 <= cycle <= 44.0)

        # Alerts
        if self.speed > self.speed_limit + 12:
            self.alert_msg = "OVERSPEED: Reduce speed below limit"
        elif self.battery < 20.0:
            self.alert_msg = "BATTERY LOW: Plan charging stop"
        elif self.lane_departure:
            self.alert_msg = "LANE DEPARTURE: Keep centered"
        else:
            self.alert_msg = ""

    def generate_packet(self):
        iso_timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        return {
            "speed": int(round(self.speed)),
            "rpm": int(self.rpm),
            "battery": int(round(self.battery)),
            "range": int(self.range_km),
            "gear": self.gear,
            "door_locked": self.door_locked,
            "speed_limit": self.speed_limit,
            "drive_mode": self.drive_mode,
            "lane_departure": self.lane_departure,
            "alert": self.alert_msg,
            "timestamp": iso_timestamp
        }

    def run(self, interval=0.1):
        self.connect_mqtt()
        print("\n[SIMULATOR] Vehicle Telemetry Generator started (10 Hz).")
        print(f"[SIMULATOR] Publishing to topic: '{TOPIC_VEHICLE_DATA}'")
        print("[SIMULATOR] Press Ctrl+C to stop.\n")

        counter = 0
        try:
            while True:
                self.update_physics(interval)
                packet = self.generate_packet()
                payload = json.dumps(packet)

                if self.client and self.connected:
                    self.client.publish(TOPIC_VEHICLE_DATA, payload, qos=0)
                    if packet["alert"]:
                        self.client.publish(TOPIC_VEHICLE_ALERT, json.dumps({
                            "type": "ALERT",
                            "message": packet["alert"],
                            "timestamp": packet["timestamp"]
                        }), qos=1)

                counter += 1
                if not self.connected and counter % 50 == 0:
                    self.connect_mqtt()

                if counter % 10 == 0:  # Log to console once per second
                    status = "CONNECTED" if self.connected else "BROADCASTING"
                    alert_tag = f" | [!] {packet['alert']}" if packet["alert"] else ""
                    print(f"[{status}] Speed: {packet['speed']:3d} km/h | RPM: {packet['rpm']:4d} | "
                          f"Battery: {packet['battery']:2d}% | Range: {packet['range']:3d} km | "
                          f"Gear: {packet['gear']}{alert_tag}", flush=True)

                time.sleep(interval)
        except KeyboardInterrupt:
            print("\n[SIMULATOR] Stopping vehicle simulator...", flush=True)
        finally:
            if self.client:
                self.client.loop_stop()
                self.client.disconnect()
            print("[SIMULATOR] Done.", flush=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AetherDrive SDV Vehicle Telemetry Simulator")
    parser.add_argument("--broker", default=DEFAULT_BROKER, help="MQTT Broker host (default: broker.emqx.io)")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT, help="MQTT Broker port (default: 1883)")
    args = parser.parse_args()

    sim = VehicleSimulator(args.broker, args.port)
    sim.run()
