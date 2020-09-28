clc;
clear all;
close all;
file = 'H:\FILE\luojia\LJUR_gz.tif';%图像文件路径
[data,ref]=geotiffread(file);  %读取图像
info=geotiffinfo(file);
I=data(:,:,1);

nrows = size(I,1);ncols = size(I,2);  %获取行数和列数
I(I<0)=0;

%计算梯度幅值,作为分割函数
hy = fspecial('sobel');  
hx = hy';
Iy = imfilter(double(I),hy,'replicate'); %使用Sobel边缘算子对图像进行垂直方向的滤波
Ix = imfilter(double(I),hx,'replicate');%使用Sobel边缘算子对图像进行水平方向的滤波
gradmag = sqrt(Ix.^2+Iy.^2); %求取模值

% L = watershed(gradmag);
% Lrgb = label2rgb(L);
% figure('units', 'normalized', 'position', [0 0 1 1]);
% subplot(1, 2, 1); imshow(gradmag,[]), title('梯度幅值图像')
% subplot(1, 2, 2); imshow(Lrgb); title('梯度幅值做分水岭变换')
% imshow(gradmag,[]),figure on;


%标记前景对象
%基于开的重建
se = strel('square',3); %指定构建一个3*3的正方形
Ie = imerode(I,se); %腐蚀图像
Iobr =imreconstruct(Ie,I);%腐蚀后重建图像
%基于闭的重建
Iobrd = imdilate(Iobr,se);%在基于重建的开操作基础上，进行腐蚀
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));%重建，标记图像为腐蚀后图像取补，模板为腐蚀前原图取补
Iobrcbr = imcomplement(Iobrcbr); %重建结果再取补，得到实际基于重建的闭操作的结果

%计算Iobrcbr的区域极大值来得到好的前景标记
%得到的前景标记图fgm是二值图，白色对应前景区域
fgm = imregionalmax(Iobrcbr); 

%计算背景标记
bw=im2bw(double(Iobrcbr),graythresh(double(Iobrcbr)));
D = bwdist(bw);
DL = watershed(D);
bgm = DL ==0;

%计算分割函数的分水岭变换
%修改梯度幅值图像，使其只在前景和后景标记像素有局部极小
gradmag2 = imimposemin(gradmag,bgm| fgm);
L = watershed(gradmag2); %基于分水岭的图像分割计算

 file_outpath='H:\FILE\luojia\2nd\lj_patch.tif';
 geotiffwrite(file_outpath,L,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
 fprintf('Finish!\n');