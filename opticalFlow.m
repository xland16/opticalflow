function [] = opticalFlow(dir,fStart,fNum,sigma,nSize,spSize,tau,magTau,viewOpt,record)

home = cd(['./' dir]);

if record == 1
    vidObj = VideoWriter([dir '-' num2str(viewOpt) '.avi']);
    open(vidObj);
end

%Load first image (designated by number fStart
Img = imread(sprintf('%08d.jpg',fStart));
gImg = rgb2gray(Img);
nextFrame = im2double(gImg);

%Get size of the frame, store in m and n
[m n] = size(nextFrame);

myDir = cd(home);

for i = fStart:fNum-1
    
    %Stability and Vector Matrix
    stabMat = zeros(m,n);
    errMat = zeros(m,n);
    vectMat = zeros(m,n,2);

    %Show current frame
    imshow(Img); hold
    
    cd(myDir);
    
    %Update current frame working on
    currFrame = nextFrame;
    
    %Read the next frame if not the last frame
    Img = imread(sprintf('%08d.jpg',i+1));
    gImg = rgb2gray(Img);
    nextFrame = im2double(gImg);
    
    cd(home);
    
    %Find the spatial gradient
    dIdT = nextFrame - currFrame;
    
    %Create the filter size based on sigma, make sure its size is odd
    fsize = round(sigma*6);
    if mod(fsize, 2) == 0
        fsize = fsize + 1;

    half = floor(fsize / 2);    

    %Centralize the Gaussian filter so point 0,0 is at center of filter
    for x = -1*half:half
        for y = -1*half:half
            Gx(x+half+1,y+half+1) = dGaussian(x,sigma)*Gaussian(y,sigma);
            Gy(x+half+1,y+half+1) = dGaussian(y,sigma)*Gaussian(x,sigma);
        end
    end

    %Perform convolution
    %Ix = conv2(nextFrame,Gx);
    %Iy = conv2(nextFrame,Gy);
    Ix = getConv(nextFrame,Gx);
    Iy = getConv(nextFrame,Gy);
    
    %Iterate through certain pixels spaced a certain amount apart
    for x = spSize:spSize:m
        for y = spSize:spSize:n                      
            %If there is a full neighborhood, find vector
            [x_l x_h y_l y_h] = getNDim(x,y,m,n,nSize);

            Ix2 = 0; Iy2 = 0; Ixy = 0;

            %Compute the covariance matrix over neighborhood
            for Cx = x_l:x_h
                for Cy = y_l:y_h
                    Ix2 = Ix2 + (Ix(Cx,Cy)^2);
                    Iy2 = Iy2 + (Iy(Cx,Cy)^2);
                    Ixy = Ixy + (Ix(Cx,Cy)*Iy(Cx,Cy));
                end
            end

            %Get the covariance matrix
            C = [Ix2 Ixy; Ixy Iy2];

            %If covariance matrix is not singular, draw arrows
            if det(C) > tau
                Axsq = Ix(x_l:x_h,y_l:y_h);
                Aysq = Iy(x_l:x_h,y_l:y_h);
                Bsq = dIdT(x_l:x_h,y_l:y_h);

                [Am An] = size(Axsq);
                len = Am * An;
                
                A = zeros(len,2);
                E = zeros(len,2);
                A(:,1) = reshape(Axsq,len,1);
                A(:,2) = reshape(Aysq,len,1);

                b = reshape(Bsq,len,1);

                vectMat(x,y,:) = -inv(C)*A'*b;
                vX = vectMat(x,y,1);
                vY = vectMat(x,y,2);

                E(:,1) = A(:,1)*vectMat(x,y,1) - b;                
                E(:,2) = A(:,2)*vectMat(x,y,2) - b;
                
                errM = E.*E;
                [Ex Ey] = size(errM);

                for xk = 1:Ex
                    for yk = 1:Ey
                        errMat(x,y) = errMat(x,y) + errM(xk,yk);
                    end    
                end

                eVal = eig(C);
                mEig = min(eVal);
                stabMat(x,y) = min(eVal);
            end
        end
    end

    maxValE = max(max(errMat));
    errMat = errMat/maxValE;    
    
    maxValS = max(max(stabMat));
    stabMat = stabMat/maxValS;
    
    %Normalize vector matrix
    maxValV = max(max(max(vectMat)));
    %vectMat = vectMat/maxValV*10;
    
    for x = spSize:spSize:m
        for y = spSize:spSize:n
            Vx = vectMat(x,y,1);
            Vy = vectMat(x,y,2);
            
            col = zeros(1,3);
            if sqrt(Vx + Vy)^2 > magTau
                Vx = Vx/maxValV*10;
                Vy = Vy/maxValV*10;
                if viewOpt == 1
                    r = 0;
                    g = 1;
                    b = 0;
                elseif viewOpt == 2
                    [r g b] = mapToColor(errMat(x,y));
                elseif viewOpt == 3
                    [r g b] = mapToColor(stabMat(x,y));
                end
                
                col(1,1) = r;
                col(1,2) = g;
                col(1,3) = b;
                
                arrow([y x],[y+Vy x+Vx],'EdgeColor',col,'FaceColor',col,'length',4);
                hold on;
            end
        end
    end

    cd(['./' dir '/output']);
    if viewOpt == 1
        nfile = sprintf('normal-%08d.png',i);
    elseif viewOpt == 2
        nfile = sprintf('err-%08d.png',i);
    elseif viewOpt == 3
        nfile = sprintf('stab-%08d.png',i);
    end

    saveas(gcf,nfile);
    
    if (record == 1)
        thisFrame = imread(nfile);
        writeVideo(vidObj,thisFrame);
    end
    clf;
    cd(home);            
    end
end

if record == 1
    close(vidObj);
end
end