function im2 = removeNoise(ima)
%    ima,输入图像
%    im2,滤波后的图像
ima = double(ima);
[r c]=size(ima);
m =5;
n = 5;
rs = r + m -1;
cs = c + n -1;
f   =   zeros(rs,cs);
f2  =   f;
% 填充边界
f((m-1)/2+1:(rs-(m-1)/2),(n-1)/2+1:(cs-(n-1)/2)) = ima;
for i = 1:(rs-m+1)
for j = 1:(cs-n+1)
temp = f(i:(i+m-1),j:(j+n-1));
%矩形领域中心坐标
indr  = i + (m-1)/2;
indc  = j + (n-1)/2;
%定义一个
w = [1 2 3 2 1 ,2 5 6 5 2, 3 6 8 6 3 ,2 5 6 5 2, 1 2 3 2 1];
f2(indr,indc) = (w*temp(:))/sum(w);
end
end
im2 = f2((m-1)/2+ 1:(rs-(m-1)/2),(n-1)/2+1:(cs-(n-1)/2));
im2 = uint8(im2);
