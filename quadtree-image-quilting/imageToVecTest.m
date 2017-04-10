function tests = imageToVecTest
tests = functiontests(localfunctions);
end

function imToVec(testCase) 
    imTest = zeros(2,2,3);
    imTest(:,:,1)=[1 51; 101 151];
    imTest(:,:,2)=[2 52; 102 152];
    imTest(:,:,3)=[3 53; 103 153];
    imshow(uint8(imTest));
    imVec = imageToVec(imTest, 'rgb');
    assert(isequal(imVec,[1 101 51 151 2 102 52 152 3 103 53 153]));
end

function testImToVecToIm(testCase) 
    imTest = zeros(2,2,3);
    imTest(:,:,1)=[1 51; 101 151];
    imTest(:,:,2)=[2 52; 102 152];
    imTest(:,:,3)=[3 53; 103 153];
    imshow(uint8(imTest));
    sameIm = vecToImage(imageToVec(imTest, 'rgb'), 'rgb');
    assert(isequal(imTest, sameIm));
end

