%% Set matcaffe
addpath('D:\Packages\caffe\Build\x64\Release\matcaffe');
caffe.set_mode_cpu();
%% Retrieve network
net_weights = ['models/c3d_arrow_iter_500.caffemodel'];
%%
net_model = ['models/c3d_arrow_test.prototxt'];
%%
net = caffe.Net(net_model, net_weights, 'test'); 
