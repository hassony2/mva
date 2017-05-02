import copy as cp
import scipy
import numpy as np
import matplotlib.pyplot as plt
import pyfits

h1d = np.array([1/16, 1/4, 3/8, 1/4, 1/16])

def convolve1D(values, filterName):
    return np.sum(values * filterName[::-1])


def convolve2DCol(initImage, filterName):
    # Convolve with mirror padding
    filterSize = filterName.shape[0]
    filterHalfSize = int((filterSize - 1) / 2)
    imageRowNb = initImage.shape[0]
    imageColNb = initImage.shape[1]
    newImage = np.zeros([imageRowNb, imageColNb])
    imageWithPadding = np.zeros(
        [imageRowNb, imageColNb + 2 * (filterSize - 1)])
    imageWithPadding[0:imageRowNb, filterSize -
                     1: imageColNb + filterSize - 1] = initImage
    imageWithPadding[0:imageRowNb, 0:filterSize -
                     1] = initImage[0:imageRowNb, filterSize - 2::-1]
    imageWithPadding[0:imageRowNb, imageColNb + filterSize -
                     1:] = initImage[0:imageRowNb, : -filterSize:-1]
    for rowIndex in range(imageRowNb):
        for colIndex in range(imageColNb):
            newImage[rowIndex, colIndex] = convolve1D(imageWithPadding[
                                                      rowIndex, colIndex + filterSize - 1 - filterHalfSize: colIndex + filterSize + filterHalfSize], filterName)
    return newImage


def convolve2DRow(initImage, filterName):
    # Convolve with mirror padding
    filterSize = filterName.shape[0]
    filterHalfSize = int((filterSize - 1) / 2)
    imageRowNb = initImage.shape[0]
    imageColNb = initImage.shape[1]
    newImage = np.zeros([imageRowNb, imageColNb])
    imageWithPadding = np.zeros(
        [imageRowNb + 2 * (filterSize - 1), imageColNb])
    imageWithPadding[filterSize - 1:  imageRowNb +
                     filterSize - 1, 0:imageColNb] = initImage
    imageWithPadding[0:filterSize - 1,
                     0:imageColNb] = initImage[filterSize - 2::-1, 0:imageColNb]
    imageWithPadding[imageColNb + filterSize - 1:,
                     0:imageColNb] = initImage[: -filterSize:-1, 0:imageColNb]
    for rowIndex in range(imageRowNb):
        for colIndex in range(imageColNb):
            newImage[rowIndex, colIndex] = convolve1D(imageWithPadding[
                                                      rowIndex + filterSize -
                                                      1 - filterHalfSize:
                                                      rowIndex + filterSize +
                                                      filterHalfSize,
                                                      colIndex], filterName)
    return newImage


def convolve2D(initialIm, filter):
    return convolve2DRow(convolve2DCol(initialIm, filter), filter)


def enlarge_filter(filterName, twoPow):
    if twoPow > 0:
        filterName = np.hstack([[value] + [0] * (pow(2, twoPow) - 1)
                                for value in filterName])[0:-pow(2, twoPow) + 1]
    return filterName


def starlet_transform(initialImage, twoPow, filterName=h1d, plot_it=False, cmap='jet'):
    coeffs = np.zeros([twoPow, initialImage.shape[0], initialImage.shape[1]])
    meanWav = np.zeros(twoPow)
    currentImage = cp.copy(initialImage)
    for iteration in range(twoPow):
        resizedFilter = enlarge_filter(filterName, iteration - 1)
        newIm = convolve2D(currentImage, enlarge_filter(filterName, iteration))
        coeffs[iteration] = currentImage - newIm
        meanWav[iteration] = np.mean(currentImage - newIm)
        currentImage = newIm
        if (plot_it):
            plt.imshow(coeffs[iteration], cmap)
            plt.title('Starlet coeffs at scale {scale}'.format(
                scale=iteration + 1))
            plt.show()
    return coeffs, currentImage, meanWav


def reconstruct_image(coeffs, finalImage):
    waveletNb = coeffs.shape[0]
    reconstructedImage = finalImage
    for idx in range(waveletNb):
        reconstructedImage = reconstructedImage + coeffs[idx]
    return reconstructedImage
