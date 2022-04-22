from __future__ import annotations
import numpy as np

def set_default_probas(M: int, m_L: float):
    nn = 0
    cum_nn_per_level = []
    level = 0
    probs = []

    while True:
        prob = np.exp(-level/m_L) * (1-np.exp(-1/m_L))
        if prob < 1e-9:
            break
        probs.append(prob)
        nn += M *2 if level == 0 else M
        cum_nn_per_level.append(nn)
        level += 1
    return probs, cum_nn_per_level