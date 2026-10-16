#!/usr/bin/env python3
"""Шумоподавление DPDFNet для dj: читает моно float32 (f32le) из stdin, пишет в stdout.

Использование: dj-denoise.py МОДЕЛЬ [ПРЕДЕЛ_ДБ]

Звук должен идти с родной частотой модели (её подставляет dj). Обработка
потоковая, так что память не растёт с длиной записи.
"""
import sys

import numpy as np
from dpdfnet import StreamEnhancer

CHUNK = 1 << 16  # сэмплов за одно чтение


def main():
    model = sys.argv[1]
    limit = float(sys.argv[2]) if len(sys.argv) > 2 else None
    # Доля исходного сигнала, которая подмешивается к очищенному:
    # шум ослабляется не больше чем на limit дБ.
    alpha = 10 ** (-limit / 20) if limit is not None else 0.0

    enhancer = StreamEnhancer(model=model)
    # Поток отстаёт от входа на два окна модели (как и обычный режим dpdfnet,
    # который эту задержку срезает). Без компенсации звук уедет от видео.
    delay = 2 * enhancer._win_len

    src, dst = sys.stdin.buffer, sys.stdout.buffer
    noisy = np.zeros(0, np.float32)  # вход, ещё не сведённый с выходом (для alpha)
    skip, left = delay, 0  # left — сколько сэмплов ещё можно выдать

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

    # Досылаем тишину, чтобы вытолкнуть задержанный хвост.
    emit(enhancer.process(np.zeros(delay + enhancer._win_len, np.float32)))
    emit(enhancer.flush())
    dst.flush()


if __name__ == "__main__":
    try:
        main()
    except (BrokenPipeError, KeyboardInterrupt):
        sys.exit(1)
