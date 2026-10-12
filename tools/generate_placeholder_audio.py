"""Generate original, loopable prototype ambience and announcement bell WAVs."""

from __future__ import annotations

import math
import random
import wave
from pathlib import Path


SAMPLE_RATE = 22050
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "assets" / "audio"


def write_mono_wav(path: Path, samples: list[float]) -> None:
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for sample in samples:
            value = max(-1.0, min(1.0, sample))
            frames.extend(int(value * 32767).to_bytes(2, "little", signed=True))
        output.writeframes(frames)


def make_ambience() -> list[float]:
    duration = 6.0
    count = int(SAMPLE_RATE * duration)
    rng = random.Random(1947)
    noise = 0.0
    result: list[float] = []
    fade_frames = int(SAMPLE_RATE * 0.025)
    for frame in range(count):
        time = frame / SAMPLE_RATE
        noise = noise * 0.94 + rng.uniform(-1.0, 1.0) * 0.06
        hum = 0.12 * math.sin(2 * math.pi * 55 * time)
        hum += 0.035 * math.sin(2 * math.pi * 110 * time + 0.2)
        room_air = 0.012 * noise
        electrical_waver = 0.88 + 0.12 * math.sin(2 * math.pi * 0.19 * time)
        fade = min(1.0, frame / fade_frames, (count - frame - 1) / fade_frames)
        result.append((hum + room_air) * electrical_waver * max(0.0, fade))
    return result


def make_bell() -> list[float]:
    duration = 4.2
    count = int(SAMPLE_RATE * duration)
    result: list[float] = []
    for frame in range(count):
        time = frame / SAMPLE_RATE
        envelope = math.exp(-1.35 * time) * min(1.0, time * 90.0)
        tone = math.sin(2 * math.pi * 659.25 * time)
        tone += 0.58 * math.sin(2 * math.pi * 987.77 * time + 0.12)
        tone += 0.22 * math.sin(2 * math.pi * 1318.5 * time + 0.3)
        result.append(0.32 * envelope * tone)
    return result


if __name__ == "__main__":
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    write_mono_wav(OUTPUT_DIR / "school_ambience.wav", make_ambience())
    write_mono_wav(OUTPUT_DIR / "distant_bell.wav", make_bell())
    print(f"Generated placeholder audio in {OUTPUT_DIR}")
