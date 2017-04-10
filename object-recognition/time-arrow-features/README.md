Predicting the arrow of time from generic image features
========================================================

We use the neural network models introduced by Zhou et al in [CVPR'16](http://arxiv.org/pdf/1512.04150.pdf) and their models provided on [their github](https://github.com/metalbubble/CAM) under the caffe framework to extract generic features corresponding to various frames from a given video.

We used the data set that was assembled for the purpose of training classifiers that could determine the arrow of time from videos provided by [Lyndsey C. Pickup](http://www.robots.ox.ac.uk/~vgg/data/arrow/)

We then try to combine and process those generic features and train a classifier on top of those combinations to try and train a classifier that determines weather a provided sample (generated from generic features) corresponds to generic features that are chronologically ordered, or on the contrary in the reversed order.

# Attempts

Two experimentations were made : 

- with concatenation of 3 ordered generic features and SVMs with polynomial kernels on top of them

The corresponding structure can be schematized as follows
![feature-extraction](https://cloud.githubusercontent.com/assets/10189060/21956083/db1b5640-da78-11e6-905b-95e44ede01e2.png)

 We tried to work with polynomial kernels to take advantage of the interaction terms present in the corresponding kernel's space. The corresponding code is stored in the master branch

The corresponding core is stored in the master branch

- with differences of features

The intuition behind it was that for instance if one of the 1024 values of the generic feature detected smoke patterns. As smoke would diffuse spatially over the image as time would increase, the characteristic patterns of smoke would be detected in larger areas of the image, and when averaging over the image the average activation should more often increase in time then decrease. Overall we hoped that the evolution of the neuron outputs after the GAP layer would be asymmetric in time and therefore characteristic of Time's Arrow

The corresponding more recent code is stored in the [difference-feature branch] https://github.com/hassony2/CAM/tree/difference-features

# Results

We did not manage to outperform a random classifier with this approach.

It therefore seems that the evolution of activation values is not significantly asymetric in time to be captured by simple classifiers.

For the concatenations, the SVM classifier with a polynomial kernel seems not to manage to extract the relevant time-related information from the raw activation values despite the presence of interaction terms that theoretically could be indecators correlated to time-ordering.

A more complex and adaptative classifier could be obtained by using a shallow neural network on top of our concatenated features. This would be equivalent to training a siamese network with 3 image inputs with the same fixed weights and then adding two or more full connected layers on top of the concatenated activations.

# Related work

A somwhat related approach was developped by Pierre with more success and is available at [time arrow](https://github.com/pierrestock/time-arrow), as he trained a triplet siamese network with linked weights (not frozen) and then a shallow full connected neural network on top.
