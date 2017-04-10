function [ grIm ] = toGrey( image, display, figNum)
%IMVAR Illumination variation
    if(not(exist('display', 'var')))
        display = false;
    end
    grIm = uint8(mean(image,3));
    if (display)
        if(not(exist('figNum', 'var')))
            figNum = 101;
        end
        figure(figNum);
        imshow(grIm);
    end
end

