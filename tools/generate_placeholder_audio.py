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


def make_footstep() -> list[float]:
    duration = 0.19
    count = int(SAMPLE_RATE * duration)
    rng = random.Random(41)
    result: list[float] = []
    noise = 0.0
    for frame in range(count):
        time = frame / SAMPLE_RATE
        noise = noise * 0.72 + rng.uniform(-1.0, 1.0) * 0.28
        envelope = math.exp(-time * 25.0) * min(1.0, time * 180.0)
        thump = 0.55 * math.sin(2 * math.pi * (82.0 - 18.0 * time) * time)
        grit = 0.32 * noise * math.exp(-time * 38.0)
        result.append((thump + grit) * envelope * 0.62)
    return result


def make_pickup() -> list[float]:
    duration = 0.48
    count = int(SAMPLE_RATE * duration)
    result: list[float] = []
    for frame in range(count):
        time = frame / SAMPLE_RATE
        envelope = math.exp(-time * 8.5) * min(1.0, time * 140.0)
        tone = math.sin(2 * math.pi * 740.0 * time)
        tone += 0.42 * math.sin(2 * math.pi * 1110.0 * time + 0.2)
        result.append(0.2 * envelope * tone)
    return result


def make_power() -> list[float]:
    duration = 0.78
    count = int(SAMPLE_RATE * duration)
    rng = random.Random(88)
    result: list[float] = []
    noise = 0.0
    for frame in range(count):
        time = frame / SAMPLE_RATE
        noise = noise * 0.76 + rng.uniform(-1.0, 1.0) * 0.24
        click = 0.7 * noise * math.exp(-time * 42.0)
        relay = 0.22 * math.sin(2 * math.pi * (110.0 + 150.0 * time) * time)
        hum = 0.09 * math.sin(2 * math.pi * 55.0 * time)
        fade_in = min(1.0, time * 110.0)
        fade_out = min(1.0, max(0.0, (duration - time) * 5.0))
        result.append((click + relay * fade_in + hum * fade_in) * fade_out * 0.45)
    return result


def make_locker() -> list[float]:
    duration = 0.56
    count = int(SAMPLE_RATE * duration)
    rng = random.Random(14)
    result: list[float] = []
    noise = 0.0
    for frame in range(count):
        time = frame / SAMPLE_RATE
        noise = noise * 0.83 + rng.uniform(-1.0, 1.0) * 0.17
        latch = 0.72 * noise * math.exp(-time * 19.0)
        body = 0.32 * math.sin(2 * math.pi * 72.0 * time) * math.exp(-time * 7.0)
        resonance = 0.12 * math.sin(2 * math.pi * 310.0 * time) * math.exp(-time * 12.0)
        result.append((latch + body + resonance) * min(1.0, time * 220.0) * 0.52)
    return result


def make_exit() -> list[float]:
    duration = 1.25
    count = int(SAMPLE_RATE * duration)
    rng = random.Random(7)
    result: list[float] = []
    noise = 0.0
    for frame in range(count):
        time = frame / SAMPLE_RATE
        noise = noise * 0.88 + rng.uniform(-1.0, 1.0) * 0.12
        latch_env = math.exp(-max(0.0, time - 0.06) * 5.5) if time >= 0.06 else 0.0
        latch = (0.52 * noise + 0.28 * math.sin(2 * math.pi * 68.0 * time)) * latch_env
        release_env = math.exp(-max(0.0, time - 0.35) * 2.2) if time >= 0.35 else 0.0
        release = 0.12 * math.sin(2 * math.pi * 392.0 * time) * release_env
        result.append((latch + release) * 0.48)
    return result


if __name__ == "__main__":
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    write_mono_wav(OUTPUT_DIR / "school_ambience.wav", make_ambience())
    write_mono_wav(OUTPUT_DIR / "distant_bell.wav", make_bell())
    write_mono_wav(OUTPUT_DIR / "sfx_footstep.wav", make_footstep())
    write_mono_wav(OUTPUT_DIR / "sfx_pickup.wav", make_pickup())
    write_mono_wav(OUTPUT_DIR / "sfx_power.wav", make_power())
    write_mono_wav(OUTPUT_DIR / "sfx_locker.wav", make_locker())
    write_mono_wav(OUTPUT_DIR / "sfx_exit.wav", make_exit())
    print(f"Generated placeholder audio in {OUTPUT_DIR}")
