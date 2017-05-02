import numpy as np


def soft_thresholding(value, threshold=1):
    signs = np.sign(value)
    abs_thresholded = np.maximum(
        abs(value) - threshold, np.zeros(np.shape(value)))
    return signs * abs_thresholded


def whiten_data(data, epsilon=0.0000000001):
    """
    :param data: contains samples in rows
    :param epsilon: to avoid numerical explosion for small eigenvalues
    :return: matrix with whitened data, whitening matrix
    """

    # Remove mean to lines
    mean_matrix = np.dot(np.diag(np.mean(data, axis=1)),
                         np.ones(np.shape(data)))
    data = data - mean_matrix

    # compute covariance matrix
    data_cov = np.dot(data, data.T)

    # eigenvalue decomposition of the covariance matrix
    eigen_vals, eigen_vecs = np.linalg.eigh(data_cov)

    # Verify that all the eigen values are positive (sometimes not due to
    # approximations)
    assert(np.all(eigen_vals > 0))

    diag = np.diag(1. / (np.sqrt(eigen_vals) + epsilon))
    # whitening matrix
    whitening_matrix = np.dot(np.dot(eigen_vecs, diag), eigen_vecs.T)

    # multiply by the whitening matrix
    whitened_data = np.dot(whitening_matrix, data)

    return whitened_data, whitening_matrix


def best_rank_n_approx(data, rank):
    """
    Performs the best approximation of data as a matrix of rank rank

    :param data: original data
    :param rank: number of kept svd values for reconstruction, rank of final matrix
    """
    # Compute SVD
    U, s, Vt = np.linalg.svd(data, full_matrices=0)
    s[rank:] = 0
    S = np.diag(s)
    reconstruct = np.dot(U, np.dot(S, Vt))
    return reconstruct
