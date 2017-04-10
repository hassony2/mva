function res = sketch_backwardfrom(net, n, dzdy, res, varargin)

opts.res = [] ;
opts.sync = false ;
opts.disableDropout = false ;
opts.freezeDropout = false ;
opts = vl_argparse(opts, varargin);

gpuMode = isa(res(1).x, 'gpuArray') ;

res(n+1).dzdx = dzdy ;
for i=n:-1:1
l = net.layers{i} ;
res(i).backwardTime = tic ;
switch l.type
  case 'conv'
    [res(i).dzdx, res(i).dzdw{1}, res(i).dzdw{2}] = ...
        vl_nnconv(res(i).x, l.filters, l.biases, ...
                  res(i+1).dzdx, ...
                  'pad', l.pad, 'stride', l.stride) ;
  case 'pool'
    res(i).dzdx = vl_nnpool(res(i).x, l.pool, res(i+1).dzdx, ...
      'pad', l.pad, 'stride', l.stride, 'method', l.method) ;
  case 'normalize'
    res(i).dzdx = vl_nnnormalize(res(i).x, l.param, res(i+1).dzdx) ;
  case 'softmax'
    res(i).dzdx = vl_nnsoftmax(res(i).x, res(i+1).dzdx) ;
  case 'loss'
    res(i).dzdx = vl_nnloss(res(i).x, l.class, res(i+1).dzdx) ;
  case 'softmaxloss'
    res(i).dzdx = vl_nnsoftmaxloss(res(i).x, l.class, res(i+1).dzdx) ;
  case 'relu'
    res(i).dzdx = vl_nnrelu(res(i).x, res(i+1).dzdx) ;
  case 'noffset'
    res(i).dzdx = vl_nnnoffset(res(i).x, l.param, res(i+1).dzdx) ;
  case 'dropout'
    if opts.disableDropout
      res(i).dzdx = res(i+1).dzdx ;
    else
      res(i).dzdx = vl_nndropout(res(i).x, res(i+1).dzdx, 'mask', res(i+1).aux) ;
    end
  case 'custom'
    res(i) = l.backward(l, res(i), res(i+1)) ;
end
if gpuMode & opts.sync
  wait(gpuDevice) ;
end
res(i).backwardTime = toc(res(i).backwardTime) ;
end

