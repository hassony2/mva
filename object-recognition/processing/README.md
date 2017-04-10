Predicting the arrow of time from spatio-temporal input using C3D
=================================================================

Our goal was to train a neural network that would be able to predict the direction of Time's Arrow for a given video.
For this, we decided to take as input a spatiotemporal tube composed of consecutive frames from a video and try for each tube to predict whether the frames are chronologically ordered or on the contrary in reverse order.

For this, we decided to take advantage of  3D (spatio-temporal) convolutions 3*3*3 as they were introduced in [facebook's C3D network](https://github.com/facebook/C3D/), but relied on the more recent implementation of [chuckcho](https://github.com/chuckcho/video-caffe)

We used the data set that was assembled for the purpose of training classifiers that could determine the arrow of time from videos provided by [Lyndsey C. Pickup](http://www.robots.ox.ac.uk/~vgg/data/arrow/)

# Data set analysis

Use the [optical flow script](https://github.com/hassony2/time-arrow-c3d-text-generation/blob/master/estimateOpticalFlows.m) to look at our analysis of the optical flow

# Network strucure

We used the structure similar to the one that was used to successfully perform action classification presented in the [c3d_ucf101 example](https://github.com/chuckcho/video-caffe/tree/master/examples/c3d_ucf101)

We  modified the top layer by replacing the 101 outputs to 2 outputs that would represent the choice the network made between the two classes : chronological or reversed.

The details of our choices be seen in the various files of [our c3d_arrow example in our other dedicated repo](https://github.com/hassony2/time-arrow-c3d/tree/master/examples/c3d_arrow). [c3d_arrow_train.prototxt file](https://github.com/hassony2/time-arrow-c3d/blob/master/examples/c3d_arrow/c3d_arrow_train.prototxt)  describes the network's structure and an example of training parameters  can be found in the [in solver file](https://github.com/hassony2/time-arrow-c3d/blob/master/examples/c3d_arrow/c3d_arrow_solver.prototxt)

# Toy experiments

With a learning rate of 0.001, it took 100 passes with back-propagation (20 iterations with batches of 5) for the network to be able to determine between two tubes of two different videos with a certainty of 99%.

With a learning rate of 0.001, it took 600 passes with back-propagation (120 iterations with batches of 5) for the network to be able to determine between two tubes of one video that only differ in the chronological ordering with a certainty of 99%.

# Results

We experimented with various learning rates (3*10-3, 3*10^-4, 3*10^-5)

We also tried adding/removing dropout

We did not yet manage to find a successfull combination of parameters that allowed our network to learn to perform the time classification task in 10 epochs. (no significant improvement of accuracy of the training set in 10 epochs)

During our latest experimentations, with a decreasing learning rate (start from 3*10^-3 and decrease of factor 10 every 4 epochs) the main shortcoming was that after 4 epochs all the tubes were classified into the same class.
After 10 epochs, we just started managing to have some features predicted into different classes. 

In the latest setup, all tubes are presented in both orders (chronological and reversed) to the network. Two reversed tubes are often much closer to each 
(if we consider pixel colors at each positions) then they are to any other tube present in the set. 
Managing to predict two such samples in reverse categories while being presented very different examples from various videos is therefore a challenging task
that requires precise tuning of the parameters.

# Usage

All information on the various commands to launch training and testing is available in the [wiki page Usage ](https://github.com/hassony2/time-arrow-c3d-text-generation/wiki/Usage)
while some obtained intermediary results are available (unformatted) in [results](https://github.com/hassony2/time-arrow-c3d-text-generation/wiki/Results)

