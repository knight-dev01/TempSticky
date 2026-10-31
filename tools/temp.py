#!/usr/bin/env python3
"""
TempSticky reader — prints the live CPU temperature feed written by the
elevated sensor task.

Examples:
    python tools/temp.py            # one snapshot
    python tools/temp.py --watch    # refresh every 2s (Ctrl+C to stop)
    python tools/temp.py --json     # raw JSON
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
from pathlib import Path

SENSOR_FILE = Path(os.environ.get("LOCALAPPDATA", Path.home())) / "TempSticky" / "sensor.json"

try:  # make the degree sign survive legacy Windows consoles
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

THRESHOLDS = {"cool": 50.0, "warm": 75.0, "high": 88.0}
STALE_SECONDS = 12


def load_sensor() -> dict | None:
    try:
        with SENSOR_FILE.open("r", encoding="utf-8-sig") as handle:
            return json.load(handle)
    except FileNotFoundError:
        return None
    except (OSError, json.JSONDecodeError):
        return None


def classify(cpu: float) -> str:
    if cpu < THRESHOLDS["cool"]:
        return "COOL"
    if cpu < THRESHOLDS["warm"]:
        return "OPTIMAL"
    if cpu < THRESHOLDS["high"]:
        return "WARM"
    return "HIGH"


def describe(data: dict | None) -> str:
    if not data:
        return "sensor file not found — run scripts/setup-sensor.ps1 as admin"

    age = (time.time() * 1000 - float(data.get("ts", 0))) / 1000
    if age > STALE_SECONDS:
        return f"sensor is stale ({age:.0f}s old) — is the 'TempSticky Sensor' task running?"

    cpu = data.get("cpu")
    if cpu is None:
        return f"no temperature reading ({data.get('error') or 'driver not ready'})"

    parts = [f"CPU {cpu:5.1f}°C  {classify(float(cpu)):<7}"]
    if data.get("gpu") is not None:
        parts.append(f"GPU {data['gpu']:.0f}°C")
    if data.get("load") is not None:
        parts.append(f"load {data['load']:.0f}%")
    parts.append(f"({data.get('cpuName') or 'unknown sensor'})")
    return "  ".join(parts)


def main() -> int:
    parser = argparse.ArgumentParser(description="Show the live TempSticky temperature reading.")
    parser.add_argument("--watch", action="store_true", help="refresh every 2 seconds")
    parser.add_argument("--json", action="store_true", help="print raw JSON")
    args = parser.parse_args()

    if args.json:
        data = load_sensor()
        print(json.dumps(data, indent=2) if data else "null")
        return 0 if data else 1

    if not args.watch:
        data = load_sensor()
        print(describe(data))
        return 0 if data and data.get("cpu") is not None else 1

    try:
        while True:
            line = describe(load_sensor())
            sys.stdout.write("\r\033[K" + line)
            sys.stdout.flush()
            time.sleep(2)
    except KeyboardInterrupt:
        print()
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
