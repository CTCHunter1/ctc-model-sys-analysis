% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License.

% Description: Gets and ROI subimage from the full image. index is of
% roiArr

function [xArr, yArr, ROIImg, ROImask] = getROIframe(fullImg, roiArr, dx, dy, index)
    bounds = struct(roiArr(index).getBounds());
    poly = struct(roiArr(index).getPolygon());
    
    x = poly.xpoints - bounds.x;
    y = poly.ypoints - bounds.y;
    
    ROImask = poly2mask(double(x),  double(y), bounds.height, bounds.width);
    
    xClip = [bounds.x:bounds.x+bounds.width-1];
    yClip = [bounds.y:bounds.y+bounds.height-1];    
    xArr = xClip*dx;
    yArr = yClip*dy;
    
    ROIImg = fullImg(yClip, xClip);    
end
