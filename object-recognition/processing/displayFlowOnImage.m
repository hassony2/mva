function frameRGB = displayFlowOnImage( frameRGB, flow )
%DISPLAYFLOWONIMAGE Summary of this function goes here
%   Detailed explanation goes here
    imshow(frameRGB)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2)
    hold off
end

