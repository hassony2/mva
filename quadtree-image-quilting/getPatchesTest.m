function tests = getPatchesTest
tests = functiontests(localfunctions);
end

function testFullPatch(testCase) % should start or end with test
                                 % testCase object should be passed even if not used
    im2 = imread('resized-jpg/furr-2.jpg');
    patches = getPatches(im2,size(im2,1)/2,3);
    patches1 = getPatches(im2, 256, 0);
    assert(isequal(patches1, im2));
end

function testFullPatchOverlap(testCase) % should start or end with test
                                 % testCase object should be passed even if not used
    im2 = imread('resized-jpg/furr-2.jpg');
    patches = getPatches(im2,size(im2,1)/2,3);
    patches1 = getPatches(im2, 256,0, 10);
    assert(isequal(patches1, im2));
end

function testSmallPatch(testCase) % should start or end with test
                                 % testCase object should be passed even if not used
    im2 = imread('resized-jpg/furr-2.jpg');
    patches = getPatches(im2,10,0,5);
    assert(size(patches,4)==(50)^2, 'Should return 50^2 patches');
end
