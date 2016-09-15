function [ xS , xE , yS , yE ] = Untitled2( centroids )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

numCens = size(centroids,1);

for ni = 1:length(numCens)
    
    if centroi(1) < 150;
        xStrt = 1;
    else
        xStrt = round(centroi(1)) - 150;
        if xStrt == 0
            xStrt = 1;
        end
    end
    xEnd = round(centroi(1)) + 150;
    
    if centroi(2) < 150;
        yStrt = 1;
    else
        yStrt = round(centroi(2)) - 150;
        if yStrt == 0
            yStrt = 1;
        end
    end
    yEnd = round(centroi(2)) + 150;
    
    xS(ni) = xStrt;
    xE(ni) = xEnd;
    yS(ni) = yStrt;
    yE(ni) = yEnd;
    
end

end

