function [ illumStd ] = illuminationStd( im )
    grIm = toGrey(im);
    flatGrIm = grIm(:);
    illumStd = std(single(flatGrIm));
end

