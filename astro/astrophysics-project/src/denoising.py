import numpy as np

from src.utils import mad


def hard_thresholding(value, threshold=1):
    return value * (abs(value) > threshold)


def multires_reconstruc(coeffs, final_image, noise_levels):
    nb_wavelet = coeffs.shape[0]
    reconstructed_image = final_image
    coeff_count = 0
    for idx in range(nb_wavelet):
        additional_image = hard_thresholding(
            coeffs[idx], threshold=noise_levels[idx])
        reconstructed_image = reconstructed_image + additional_image
        coeff_count = coeff_count + np.sum(additional_image > 0)
    return reconstructed_image, coeff_count


def compute_mad_at_scales(starlet_coeffs, starlet_fin):
    starlet_nb = starlet_coeffs.shape[0]
    mad_res = []
    for idx in range(starlet_nb):
        mad_res.append(mad(starlet_coeffs[idx, :, :]))
    mad_res.append(mad(starlet_fin))
    return mad_res
