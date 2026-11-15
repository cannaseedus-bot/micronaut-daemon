"""Record and validate readable JSONL tool replay events.

This is the audit stream companion to JROM. It intentionally does not execute
commands; execution remains the responsibility of the registered MCP/KUHUL
runtime after validation.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

REQUIRED = {
    "replay_id", "sequence", "timestamp", "tool_id", "verb", "target",
    "args", "phase", "lane", "status"
}
PAYLOAD_REQUIRED = REQUIRED - {"sequence"}
# Accept legacy Chen records when validating older streams. New writers use
# the canonical K'UHUL spelling, Ch'en.
PHASES = ["Pop", "Wo", "Yax", "Sek", "Ch'en", "Chen", "Xul"]


def canonical(value: object) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def event_hash(event: dict) -> str:
    body = dict(event)
    body.pop("event_hash", None)
    return hashlib.sha256(canonical(body)).hexdigest()


def read_events(path: Path) -> list[dict]:
    if not path.exists():
        return []
    events = []
    for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            value = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"{path}:{line_no}: invalid JSON: {exc}") from exc
        if not isinstance(value, dict):
            raise ValueError(f"{path}:{line_no}: event must be an object")
        events.append(value)
    return events


def validate(events: list[dict]) -> None:
    previous = ""
    for expected_sequence, event in enumerate(events):
        missing = REQUIRED - event.keys()
        if missing:
            raise ValueError(f"event {expected_sequence}: missing {sorted(missing)}")
        if event["sequence"] != expected_sequence:
            raise ValueError(f"event {expected_sequence}: sequence is {event['sequence']}")
        if event["phase"] not in PHASES:
            raise ValueError(f"event {expected_sequence}: invalid phase {event['phase']!r}")
        if event.get("previous_event_hash", "") != previous:
            raise ValueError(f"event {expected_sequence}: broken hash chain")
        if event.get("event_hash") != event_hash(event):
            raise ValueError(f"event {expected_sequence}: invalid event_hash")
        previous = event["event_hash"]


def append_event(path: Path, payload: dict) -> dict:
    events = read_events(path)
    validate(events)
    if PAYLOAD_REQUIRED - payload.keys():
        raise ValueError(f"new event missing {sorted(PAYLOAD_REQUIRED - payload.keys())}")
    event = dict(payload)
    event["sequence"] = len(events)
    event["previous_event_hash"] = events[-1]["event_hash"] if events else ""
    event["event_hash"] = event_hash(event)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8", newline="\n") as handle:
        handle.write(json.dumps(event, ensure_ascii=False, sort_keys=True) + "\n")
    return event


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate or append AtomicMCP JROM replay events")
    parser.add_argument("--stream", type=Path, required=True)
    parser.add_argument("--validate", action="store_true")
    parser.add_argument("--event", type=Path, help="JSON object containing one new event")
    args = parser.parse_args()
    if args.event:
        payload = json.loads(args.event.read_text(encoding="utf-8"))
        print(json.dumps(append_event(args.stream, payload), ensure_ascii=False, indent=2))
    else:
        events = read_events(args.stream)
        validate(events)
        print(json.dumps({"ok": True, "events": len(events), "last_hash": events[-1]["event_hash"] if events else ""}))


if __name__ == "__main__":
    main()
