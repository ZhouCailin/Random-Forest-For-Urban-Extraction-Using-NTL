clc;
clear all;
close all;
file = 'H:\FILE\luojia\LJUR_gz.tif';%ͼ���ļ�·��
[data,ref]=geotiffread(file);  %��ȡͼ��
info=geotiffinfo(file);
I=data(:,:,1);

nrows = size(I,1);ncols = size(I,2);  %��ȡ����������
I(I<0)=0;

%�����ݶȷ�ֵ,��Ϊ�ָ��
hy = fspecial('sobel');  
hx = hy';
Iy = imfilter(double(I),hy,'replicate'); %ʹ��Sobel��Ե���Ӷ�ͼ����д�ֱ������˲�
Ix = imfilter(double(I),hx,'replicate');%ʹ��Sobel��Ե���Ӷ�ͼ�����ˮƽ������˲�
gradmag = sqrt(Ix.^2+Iy.^2); %��ȡģֵ

% L = watershed(gradmag);
% Lrgb = label2rgb(L);
% figure('units', 'normalized', 'position', [0 0 1 1]);
% subplot(1, 2, 1); imshow(gradmag,[]), title('�ݶȷ�ֵͼ��')
% subplot(1, 2, 2); imshow(Lrgb); title('�ݶȷ�ֵ����ˮ��任')
% imshow(gradmag,[]),figure on;


%���ǰ������
%���ڿ����ؽ�
se = strel('square',3); %ָ������һ��3*3��������
Ie = imerode(I,se); %��ʴͼ��
Iobr =imreconstruct(Ie,I);%��ʴ���ؽ�ͼ��
%���ڱյ��ؽ�
Iobrd = imdilate(Iobr,se);%�ڻ����ؽ��Ŀ����������ϣ����и�ʴ
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));%�ؽ������ͼ��Ϊ��ʴ��ͼ��ȡ����ģ��Ϊ��ʴǰԭͼȡ��
Iobrcbr = imcomplement(Iobrcbr); %�ؽ������ȡ�����õ�ʵ�ʻ����ؽ��ıղ����Ľ��

%����Iobrcbr�����򼫴�ֵ���õ��õ�ǰ�����
%�õ���ǰ�����ͼfgm�Ƕ�ֵͼ����ɫ��Ӧǰ������
fgm = imregionalmax(Iobrcbr); 

%���㱳�����
bw=im2bw(double(Iobrcbr),graythresh(double(Iobrcbr)));
D = bwdist(bw);
DL = watershed(D);
bgm = DL ==0;

%����ָ���ķ�ˮ��任
%�޸��ݶȷ�ֵͼ��ʹ��ֻ��ǰ���ͺ󾰱�������оֲ���С
gradmag2 = imimposemin(gradmag,bgm| fgm);
L = watershed(gradmag2); %���ڷ�ˮ���ͼ��ָ����

 file_outpath='H:\FILE\luojia\2nd\lj_patch.tif';
 geotiffwrite(file_outpath,L,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
 fprintf('Finish!\n');