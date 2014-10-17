function [flag] = overflow(x,y,x_max,y_max,nSize)
    %Returns the point locations defining a point's neighborhood
    x_l = x - nSize;
	x_h = x + nSize;
	y_l = y - nSize;
	y_h = y + nSize;
    
    flag = 0;
        
    if x_l < 1 || y_l < 1 || x_h > x_max || y_h > y_max
        flag = 1;
    end
end