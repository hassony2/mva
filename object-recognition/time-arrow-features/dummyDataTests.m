%% Test on dummy data 
rng(4)
exampleNb = 3;
variableNb = 4;
X = rand(exampleNb, variableNb);
Y = randi([0 1],exampleNb,1);

SVMModelTest = fitcsvm(X,Y, 'KernelFunction','polynomial','PolynomialOrder',2, 'BoxConstraint', 0.00001);
Xtest = rand(2,variableNb);
[labelsTest,scoreTest] = predict(SVMModelTest,Xtest);
