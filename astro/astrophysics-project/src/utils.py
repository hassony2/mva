import numpy as np
from matplotlib import pyplot as plt
import copy

from src import starlets


def mad(z):
    normal_factor = 1 / 0.6735
    return np.median(abs(z - np.median(z))) * normal_factor


def soft_thresholding(value, threshold=1):
    signs = np.sign(value)
    abs_thresholded = np.maximum(
        abs(value) - threshold, np.zeros(np.shape(value)))
    return signs * abs_thresholded


def prox_inpainting(original_masked_im, mask, nmax=np.inf, wavelet_nb=2,
                    k_mad=3, tol=1e-4, step_size=1, verbose=True):

    x = copy.deepcopy(original_masked_im)
    y = copy.deepcopy(x)

    it = 0
    error = np.inf
    while (error > tol):
        if(it < nmax):
            it += 1
            # -- computation of the gradient
            grad_image = original_masked_im - mask * y

            # -- gradient descent
            x_half = y + step_size * grad_image

            # thresholding / or applying mask
            starlet_coeffs, starlet_fin = starlets.starlet_transform(
                x_half, wavelet_nb=wavelet_nb)
            for s in range(0, wavelet_nb):
                thrd = k_mad * mad(starlet_coeffs[s])
                starlet_coeffs[s] = (starlet_coeffs[s] - thrd * np.sign(starlet_coeffs[s])
                                     ) * (abs(starlet_coeffs[s]) > thrd)

            xp = starlets.starlet_reconstruct(starlet_coeffs, starlet_fin)
            y = xp
            error = np.linalg.norm(xp - x) / (1e-12 + np.linalg.norm(xp))

            x = copy.deepcopy(xp)
    if(verbose):
        print('final error : ', error)
        print('iteration number : ', it)
    return xp


def prox_deconvolution(blurred_noised_image, psf, nmax=100,
                       wavelet_nb=2, k_mad=3, tol=1e-3, verbose=True):
    x = copy.deepcopy(blurred_noised_image)
    y = copy.deepcopy(x)

    Fpsf = np.fft.fft2(psf)
    Fb = np.fft.fft2(blurred_noised_image)
    Fpsf2 = np.abs(Fpsf)**2
    FsF = np.real(np.fft.fftshift(np.fft.ifft2(np.conj(Fpsf) * Fb)))
    L = 0.9 * np.max(Fpsf2)

    error = np.inf
    it = 0
    while(error > tol):
        if(it < nmax):
            it += 1
            # -- computation of the gradient
            Fx = np.fft.fft2(y)
            g = np.real(np.fft.ifft2(Fpsf2 * Fx)) - FsF

            # -- gradient descent
            x_half = y - 1 / L * g

            # -- thresholding / or applying mask
            starlet_coeffs, starlet_fin = starlets.starlet_transform(x_half,
                                                                     wavelet_nb=wavelet_nb)
            thrd = k_mad * mad(starlet_coeffs[0])

            for s in range(0, wavelet_nb):
                # Soft thresholding
                starlet_coeffs[s] = (starlet_coeffs[s] - thrd * np.sign(starlet_coeffs[s])
                                     ) * (abs(starlet_coeffs[s]) > thrd)

            xp = starlets.starlet_reconstruct(starlet_coeffs, starlet_fin)
            y = xp
            error = np.linalg.norm(xp - x) / (1e-12 + np.linalg.norm(xp))
            x = copy.deepcopy(xp)
    if(verbose):
        print('final error : ', error)
        print('iteration number : ', it)
    return xp


def starlet_transform(x=0, h=[0.0625, 0.25, 0.375, 0.25, 0.0625], wavelet_nb=1,
                      boption=3, display=True, cmap='jet'):
    nx = np.shape(x)
    c = np.zeros((nx[0], nx[1]), dtype=complex)
    w = np.zeros((nx[0], nx[1], J))

    c = copy.copy(x)
    cnew = copy.copy(x)

    for scale in range(J):

        for r in range(nx[0]):

            cnew[r, :] = Apply_H1(c[r, :], h, scale, boption)

        for r in range(nx[1]):

            cnew[:, r] = Apply_H1(cnew[:, r], h, scale, boption)

        w[:, :, scale] = c - cnew

        if(display):
            plt.imshow(w[:, :, scale], cmap)
            plt.title('Starlet coeffs at scale {scale}'.format(
                scale=scale + 1))
            plt.show()

        c = copy.copy(cnew)

    return c, w


def starlet_inverse(starlet_fin, starlet_coeffs):
    return starlet_fin + np.sum(starlet_coeffs, axis=2)


def length(x=0):
    l = np.max(np.shape(x))
    return l


# def Apply_H1(x=0, h=0, scale=1, boption=3):

#     m = length(h)

#     if scale > 1:
#         p = (m - 1) * np.power(2, (scale - 1)) + 1
#         g = np.zeros(p)
#         z = np.linspace(0, m - 1, m) * np.power(2, (scale - 1))
#         g[z.astype(int)] = h

#     else:
#         g = h

#     y = filter_1d(x, g, boption)

#     return y


# def filter_1d(xin=0, h=0, boption=3):

#     import numpy as np
#     import scipy.linalg as lng
#     import copy as cp

#     x = np.squeeze(cp.copy(xin))
#     n = length(x)
#     m = length(h)
#     y = cp.copy(x)
#     z = np.zeros(1, m)

#     m2 = np.int(np.floor(m / 2))

#     for r in range(m2):

#         if boption == 1:  # --- zero padding
#             z = np.concatenate(
#                 [np.zeros(m - r - m2 - 1), x[0:r + m2 + 1]], axis=0)

#         if boption == 2:  # --- periodicity
#             z = np.concatenate(
#                 [x[n - (m - (r + m2)) + 1:n], x[0:r + m2 + 1]], axis=0)

#         if boption == 3:  # --- mirror
#             u = x[0:m - (r + m2) - 1]
#             u = u[::-1]
#             z = np.concatenate([u, x[0:r + m2 + 1]], axis=0)

#         y[r] = np.sum(z * h)
#     a = np.arange(np.int(m2), np.int(n - m + m2), 1)

#     for r in a:
#         y[r] = np.sum(h * x[r - m2:m + r - m2])

#     a = np.arange(np.int(n - m + m2 + 1) - 1, n, 1)
#     for r in a:
#         if boption == 1:  # --- zero padding
#             z = np.concatenate(
#                 [x[r - m2:n], np.zeros(m - (n - r) - m2)], axis=0)

#         if boption == 2:  # --- periodicity
#             z = np.concatenate([x[r - m2:n], x[0:m - (n - r) - m2]], axis=0)

#         if boption == 3:  # --- mirror
#             u = x[n - (m - (n - r) - m2 - 1) - 1:n]
#             u = u[::-1]
#             z = np.concatenate([x[r - m2:n], u], axis=0)

#         y[r] = np.sum(z * h)

#     return y
