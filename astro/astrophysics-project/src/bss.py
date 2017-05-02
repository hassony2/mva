import numpy as np
import scipy.linalg as lng

import src.utils as utils


def perform_gmca_planck(mixed_data, source_nb, nmax=100,
                        mints=3, colcmb=None, colsz=None, maxts=7,
                        rescale=True, display=True):
    observation_nb, channel_nb = np.shape(mixed_data)
    mixing_matrix = np.random.randn(observation_nb, source_nb)
    for r in range(0, source_nb):
        mixing_matrix[:, r] = mixing_matrix[
            :, r] / lng.norm(mixing_matrix[:, r])

    # initialize known coeffs of mixing matrix
    if colcmb != None:
        cmb_mixing_coeffs = np.reshape(colcmb, (len(colcmb)))
        mixing_matrix[:, 0] = cmb_mixing_coeffs
    if colsz != None:
        sz_mixing_coeffs = np.reshape(colsz, (len(colsz)))
        mixing_matrix[:, 1] = sz_mixing_coeffs

    sources = np.dot(mixing_matrix.T, mixed_data)

    ts = maxts
    dts = (ts - mints) / float(nmax - 1.)

    for nit in range(0, nmax):
        # Estimate the sources for fixed mixing_matrix
        Ra = np.dot(mixing_matrix.T, mixing_matrix)
        p_inv_mix_matrix = np.dot(lng.inv(Ra), mixing_matrix.T)
        sources = np.dot(p_inv_mix_matrix, mixed_data)
        threshold_factor = [0.1, 0.5, 0.1]
        for ns in range(0, source_nb):
            temp = sources[ns, :]
            thrd = ts * utils.mad(temp)
            if(rescale):
                thrd = thrd * threshold_factor[ns]
            sources[ns, (abs(temp) < thrd)] = 0

        # Estimate the mixing matrix for fixed sources sources
        vs = np.sqrt(np.sum(sources * sources, axis=1))
        if colcmb != None:  # --- Do not update the first column
            vs[0] = 0
        if colsz != None:
            vs[1] = 0

        indmixing_matrix = np.where(vs > 1e-6)
        indmixing_matrix = indmixing_matrix[0]
        has_active_src = len(indmixing_matrix) >= 1

        if has_active_src:
            temp = sources[indmixing_matrix, :]
            Rp = np.dot(temp, temp.T)
            p_inv_sources = np.dot(temp.T, lng.inv(Rp))
            mixing_matrix[:, indmixing_matrix] = np.dot(
                mixed_data, p_inv_sources)
            for ns in indmixing_matrix:
                mixing_matrix[:, ns] = mixing_matrix[:, ns] / \
                    float(lng.norm(mixing_matrix[:, ns] + 1e-6))
                if lng.norm(mixing_matrix[:, ns]) < 1e-6:
                    print('reinitialized mixing matrix row!')
                    mixing_matrix[:, ns] = np.random.randn(m)

        # Update the threshold

        ts = ts - dts

    return mixing_matrix, sources, p_inv_mix_matrix


def perform_gmca(mixed_data, source_nb, nmax=250, mints=1, maxts=0):
    """
    :param n: number of sources
    :param mixed_data: mixed_data
    """
    observation_nb, channel_nb = np.shape(mixed_data)

    mixing_matrix = np.random.randn(observation_nb, source_nb)
    for r in range(0, source_nb):
        mixing_matrix[:, r] = mixing_matrix[
            :, r] / lng.norm(mixing_matrix[:, r])

    Ra = np.dot(mixing_matrix.T, mixing_matrix)
    sources = np.dot(np.diag(1. / np.diag(Ra)),
                     np.dot(mixing_matrix.T, mixed_data))

    ts = 0
    if maxts == 0:
        for r in range(1, source_nb):
            maxts = np.max(
                [np.max(abs(sources[r, :])) / utils.mad(sources[r, :]), ts])

    vts = np.exp((np.log(maxts) - np.log(mints)) *
                 np.linspace(0, 1, nmax)[::-1] + np.log(mints))
    vepsilon = np.power(10, 4 * np.linspace(0, 1, nmax)[::-1] - 5)

    for nit in range(0, nmax):

        # Estimate the sources for fixed mixing_matrix

        epsilon = vepsilon[nit]
        ts = vts[nit]

        Ra = np.dot(mixing_matrix.T, mixing_matrix)
        mRa = lng.norm(Ra, 2)

        Ra = Ra + epsilon * mRa * np.identity(source_nb)
        p_inv_mix_matrix = np.dot(lng.inv(Ra), mixing_matrix.T)
        sources = np.dot(p_inv_mix_matrix, mixed_data)

        for ns in range(0, source_nb):
            temp = sources[ns, :]
            thrd = ts * utils.mad(temp)
            sources[ns, (abs(temp) < thrd)] = 0

        # Estimate the mixing matrix for fixed sources sources
        vs = np.sqrt(np.sum(sources * sources, axis=1))

        indmixing_matrix = np.where(vs > 1e-6)
        indmixing_matrix = indmixing_matrix[0]

        nactive = len(indmixing_matrix)

        if nactive > 1:

            temp = sources[indmixing_matrix, :]
            Rp = np.dot(temp, temp.T)
            mRp = lng.norm(Rp, 2)
            Rp = Rp + epsilon * mRp * np.identity(nactive)
            p_inv_sources = np.dot(temp.T, lng.inv(Rp))
            mixing_matrix[:, indmixing_matrix] = np.dot(
                mixed_data, p_inv_sources)

            for ns in indmixing_matrix:
                mixing_matrix[:, ns] = mixing_matrix[:, ns] / \
                    float(lng.norm(mixing_matrix[:, ns] + 1e-6))
                if lng.norm(mixing_matrix[:, ns]) < 1e-6:
                    mixing_matrix[:, ns] = np.random.randn(m)

    sources = np.dot(p_inv_mix_matrix, mixed_data)

    return mixing_matrix, sources
