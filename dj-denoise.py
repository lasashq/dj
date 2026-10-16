#!/usr/bin/env python3
"""DPDFNet noise removal for dj: reads mono float32 (f32le) from stdin, writes to stdout.

Usage: dj-denoise.py MODEL [LIMIT_DB]

Audio must come at the model's native sample rate (dj takes care of that).
Processing is streamed, so memory doesn't grow with the recording length.
"""
import sys

import numpy as np
from dpdfnet import StreamEnhancer

CHUNK = 1 << 16  # samples per read


def main():
    model = sys.argv[1]
    limit = float(sys.argv[2]) if len(sys.argv) > 2 else None
    # Share of the original signal mixed into the cleaned one,
    # so noise is reduced by at most `limit` dB.
    alpha = 10 ** (-limit / 20) if limit is not None else 0.0

    enhancer = StreamEnhancer(model=model)
    # The stream lags the input by two model windows (dpdfnet's offline mode
    # trims the same delay). Without compensation audio drifts from the video.
    delay = 2 * enhancer._win_len

    src, dst = sys.stdin.buffer, sys.stdout.buffer
    noisy = np.zeros(0, np.float32)  # input not yet matched with output (for alpha)
    skip, left = delay, 0  # left — how many samples may still be emitted

    def emit(y):
        nonlocal noisy, skip, left
        k = min(skip, len(y))
        y, skip = y[k:], skip - k
        y = y[:left]
        if not len(y):
            return
        if alpha:
            y = alpha * noisy[:len(y)] + (1 - alpha) * y
            noisy = noisy[len(y):]
        left -= len(y)
        dst.write(y.astype("<f4").tobytes())

    tail = b""
    while block := src.read(CHUNK * 4):
        block = tail + block
        n = len(block) // 4 * 4
        tail = block[n:]
        x = np.frombuffer(block[:n], "<f4")
        left += len(x)
        if alpha:
            noisy = np.concatenate([noisy, x])
        emit(enhancer.process(x))

    # Feed silence to push out the delayed tail.
    emit(enhancer.process(np.zeros(delay + enhancer._win_len, np.float32)))
    emit(enhancer.flush())
    dst.flush()


if __name__ == "__main__":
    try:
        main()
    except (BrokenPipeError, KeyboardInterrupt):
        sys.exit(1)
