clc;
clear all;
close all;

data=dlmread('H:\FILE\luojia\2013wholedatapredict2.csv');%读取随机森林结果
patch_file='H:\FILE\luojia\2nd\luojia_repatch.tif';%图像分割结果

[patch,ref]=geotiffread(patch_file);  
info=geotiffinfo(patch_file);%投影等信息，用在最后影像输出中

nrows = size(patch,1);ncols = size(patch,2);  %获取行数和列数
patch_rs = reshape(patch,nrows*ncols,1);

threshold = double(patch_rs); 
threshold(:)=9999999;

% threshold(patch_rs == 0)=9999;  %斑块0为分割线     
% threshold(patch_rs == 1)=9999;  %斑块1为背景，故均无最佳阈值
% threshold(patch_rs == -32768)=9999; %%NoData=-32768

num = size(data,1);   %斑块数量
for i=1:num
%     if(data(i,10)<9999)   %不考虑背景
%         threshold(patch_rs==data(i,2))=data(i,10);%给斑块赋对应的灯光阈值
%     else
%         threshold(patch_rs==data(i,2))=9999; %第二列！
%     end
    index=data(i,2);
    threshold(patch_rs==index)=data(i,10);

end
%输出阈值图像
threshold = reshape(threshold,nrows,ncols);
Threshold_file='H:\FILE\luojia\2nd\2013RF对象估计阈值3.tif';%图像文件路径
geotiffwrite(Threshold_file,threshold,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
fprintf('finish');