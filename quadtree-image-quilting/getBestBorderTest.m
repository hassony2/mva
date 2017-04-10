function tests = getBestBorderTest
tests = functiontests(localfunctions);
end

function testVerticalDirection(testCase) % should start or end with test
                                 % testCase object should be passed even if not used
    im = imread('512/vangogh-nuit.jpg');
    tileSize = 100;
    borderSize = 10;
    decal = 20;
    overlap1 = im(1:borderSize,1:tileSize,:);
    overlap2 = im(decal:decal + borderSize - 1 ,1:tileSize,:);
    newBorder = getBestBorder( overlap1, overlap2);
    assert(isequal(size(overlap1), size(newBorder)), 'resulting overlap should have same size as initial one');
end

function testHorizonttalDirection(testCase) % should start or end with test
                                 % testCase object should be passed even if not used
    im = imread('512/vangogh-nuit.jpg');
    tileSize = 100;
    borderSize = 10;
    decal = 20;
    overlap1 = im(1:tileSize, 1:borderSize,:);
    overlap2 = im(1:tileSize, decal:decal + borderSize - 1 ,:);
    newBorder = getBestBorder( overlap1, overlap2);
    assert(isequal(size(overlap1), size(newBorder)), 'resulting overlap should have same size as initial one');
end

