function [expW1, expW2, expH1, expH2] = getBoxBounds(boundary,sizeN)

minX = min(boundary(:,2));
minY = min(boundary(:,1));
height = max(boundary(:,2)) - min(boundary(:,2));
width = max(boundary(:,1)) - min(boundary(:,1));

totalW = width*sizeN;
totalH = height*sizeN;

if sizeN == 1
    expW1 = minY;
    expW2 = width;
    expH1 = minX;
    expH2 = height;
else
    
    nw = round(totalW/2);
    expW1 = minY - nw;
    expW2 = width+(nw*2);
    
    nh = round(totalH/2);
    expH1 = minX - nh;
    expH2 = height+(nh*2);
    
end

end