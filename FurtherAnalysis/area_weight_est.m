% Returning the weight for normalizing distance histogram
% It recieve (x1,y1) (x2,y2) the position of the upperleft and the bottom right corner of the arena
% (xc,yc) is the position of center of object
% r is the diatance to the object
% returns a weight w,  it is acctually the part of perimeter of a circle which has r as radius and (xc,yc) as radius intersected by the arena
% 
% this function gernally apply, but it is not exact
% bin is the histogram diatance bin
function w=area_weight(r,x1,y1,x2,y2,xc,yc,bin,finescale)
    dim1=abs(x1-x2).*finescale;
    dim2=abs(y1-y2).*finescale;
    M = zeros(dim1,dim2);
    for i=1:dim1
        for j=1:dim1
            diatance=sqrt((i-xc.*finescale).^2+(j-yc.*finescale).^2);
            if diatance>(r-(0.5.*bin)).*finescale && diatance<(r+(0.5.*bin)).*finescale
                M(i,j)=1;
            end
        end
    end
    w=sum(sum(M));
end