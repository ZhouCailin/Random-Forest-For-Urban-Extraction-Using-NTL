clc;
clear all;
close all;

data=dlmread('H:\FILE\luojia\2013wholedatapredict2.csv');%��ȡ���ɭ�ֽ��
patch_file='H:\FILE\luojia\2nd\luojia_repatch.tif';%ͼ��ָ���

[patch,ref]=geotiffread(patch_file);  
info=geotiffinfo(patch_file);%ͶӰ����Ϣ���������Ӱ�������

nrows = size(patch,1);ncols = size(patch,2);  %��ȡ����������
patch_rs = reshape(patch,nrows*ncols,1);

threshold = double(patch_rs); 
threshold(:)=9999999;

% threshold(patch_rs == 0)=9999;  %�߿�0Ϊ�ָ���     
% threshold(patch_rs == 1)=9999;  %�߿�1Ϊ�������ʾ��������ֵ
% threshold(patch_rs == -32768)=9999; %%NoData=-32768

num = size(data,1);   %�߿�����
for i=1:num
%     if(data(i,10)<9999)   %�����Ǳ���
%         threshold(patch_rs==data(i,2))=data(i,10);%���߿鸳��Ӧ�ĵƹ���ֵ
%     else
%         threshold(patch_rs==data(i,2))=9999; %�ڶ��У�
%     end
    index=data(i,2);
    threshold(patch_rs==index)=data(i,10);

end
%�����ֵͼ��
threshold = reshape(threshold,nrows,ncols);
Threshold_file='H:\FILE\luojia\2nd\2013RF���������ֵ3.tif';%ͼ���ļ�·��
geotiffwrite(Threshold_file,threshold,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
fprintf('finish');