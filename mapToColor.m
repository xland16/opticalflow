function [r g b] = mapToColor(p)

colM = zeros(1,1,3);

colM(1,1,1) = p*.75;
colM(1,1,2) = 1;
colM(1,1,3) = 1;

colM = hsv2rgb(colM);

r = colM(1,1,1);
g = colM(1,1,2);
b = colM(1,1,3);
end