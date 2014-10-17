function [] = testColor(file)

home = cd(['./TestColor']);
img = imread(file);
myDir = cd(home);

gray = rgb2gray(img);
d = im2double(gray);
[n m] = size(d);

for i=1:n
    for j=1:m
        [r g b] = mapToColor(d(i,j));
        img(i,j,1) = r*255;
        img(i,j,2) = g*255;
        img(i,j,3) = b*255;
    end
end

cd(myDir);
nfile = strrep(file, '.jpg', '');
imwrite(img,[nfile '-falsecolor.jpg']);
imshow(img)
cd(home);
end