# Panorama

## Usage

- build and run

- click on at least 5 matching points on each picture :
	
	- the order of the clicks on the first image should be the same as the order of the clicks on the second image

	- right click to launch panorama reconstruction 

	- look at the result !

- some result images are showcased in the project folder

## Problems 

4 clicks should be enough to solve the probleme, nevertheless, when using only 4 points I often (but not always) got a "cannot solve" error from the linSolve function. 

I tried two times to solve the erroring system using another solver (solve in R), which was both times able to invert the A matrix and thus solve the system and provide a solution for the homography matrix.

I wasn't able to figure out what caused the error.

As the linsolve part was out of the "TODO" part, I continued but indicated in the code that when possible, 5 matching points should be clicked.