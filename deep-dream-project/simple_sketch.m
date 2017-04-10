function [ sketch ] = simple_sketch( size )
%SIMPLE_SKETCH Draws simple cross

sketch = 2*(rand(size)-0.5);
sketch = single(sketch);
end

