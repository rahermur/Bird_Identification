function area = areaUnderCurve(x_,y_)
% To compute the area under curve (AUC), by summing all vertical segments
% (rectangle plus triangle). 
% useful for ROC analysis 
% area = areaUnderCurve(x_,y_)
%
% 
% Examples:
% x = cos(0:0.001:pi);
% y = sin(0:0.001:pi);
% area = areaUnderCurve(x,y);
% plot(x,y);
% title(['AUC=' num2str(area)])
%

area = 0;
[x,sortedXInd] = sort(x_);
y = y_(sortedXInd);

for i= 1:length(x)-1
    deltaX = (x(i+1)-x(i));
    deltaY = (y(i+1)-y(i));
    minY = min(y(i),y(i+1));
    area = area + deltaX*minY+ 0.5*deltaX*deltaY;
end
end