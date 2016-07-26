tic
i1=imread('lena.bmp');
i1=rgb2gray(i1);
i1=edge(i1,'roberts');
i2 = imread('moban1.bmp');
i2=rgb2gray(i2);
%i2=edge(i2,'roberts');

n1=0;n2=0;n3=0;n4=0;
[h w] = size(i2)
for i=1:256
    for j=1:256
        for m=1:68
            for n=1:68
                if i2(m,n)==i1(i+m-1,j+n-1)
                    n1=n1+1;
                end
            end
        end
        if n1>n2
            n2=n1;
            ii=i
            jj=j
        end
        n1=0;
    end
end
for z=ii:ii+68
    i1(z,jj+68)=1;
    i1(z,jj)=1;
end
for z=jj:jj+68
    i1(ii,z)=1;
    i1(ii+68,z)=1;
end
imshow(i1);
toc

