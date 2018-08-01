% Returning the weight for normalizing distance histogram
% It recieve (x1,y1) (x2,y2) the position of the upperleft and the bottom right corner of the arena
% (xc,yc) is the position of center of object
% r is the diatance to the object
% returns a weight w,  it is acctually the part of perimeter of a circle which has r as radius and (xc,yc) as radius intersected by the arena
% 
% this function does not gernally apply, only applys to those object is placed near one corner of the arena and near the diagonal line  (len(3)<len(4))
function w=area_weight(r,x1,y1,x2,y2,xc,yc)
    len=[abs(xc-x1);
         abs(yc-y1);
         abs(xc-x2);
         abs(yc-y2);
         sqrt((xc-x1).^2+(yc-y1).^2);
         sqrt((xc-x2).^2+(yc-y2).^2);
         sqrt((xc-x1).^2+(yc-y2).^2);
         sqrt((xc-x2).^2+(yc-y1).^2);];
    len=sort(len);
    if r<0
        error('r<0 invalid input');
    elseif r>=0 && r<len(1)
        w = 2.*pi.*r;
    elseif r>=len(1) && r<len(2)
        w = 2.*pi.*r.*((2.*pi-2.*acos(len(1)./r))./(2.*pi));
    elseif r>=len(2) && r<len(3)
        w = 2.*pi.*r.*((2.*pi-2.*acos(len(1)./r)-2.*acos(len(2)./r))./(2.*pi));
    elseif r>=len(3) && r<len(4)
        w = 2.*pi.*r.*((2.*pi-acos(len(1)./r)-acos(len(2)./r)-0.5.*pi)./(2.*pi));
    elseif r>=len(4) && r<len(5)
        w = 2.*pi.*r.*((2.*pi-acos(len(1)./r)-acos(len(2)./r)-0.5.*pi-2.*acos(len(4)./r))./(2.*pi));
    elseif r>=len(5) && r<len(6)
        w = 2.*pi.*r.*((2.*pi-acos(len(1)./r)-acos(len(2)./r)-0.5.*pi-2.*acos(len(4)./r)-2.*acos(len(5)./r))./(2.*pi));
    elseif r>=len(6) && r<len(7)
        w = 2.*pi.*r.*((2.*pi-acos(len(2)./r)-pi-acos(len(4)./r)-2.*acos(len(5)./r))./(2.*pi));
    elseif r>=len(7) && r<len(8)
        w = 2.*pi.*r.*((2.*pi-1.5.*pi-acos(len(4)./r)-acos(len(5)./r))./(2.*pi));
    else 
        w=+Inf;
    end
end