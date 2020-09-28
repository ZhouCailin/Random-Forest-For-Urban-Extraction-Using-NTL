clc;
clear all;
close all;

Patch_file='H:\FILE\luojia\2nd\lj_patch.tif';%��һ���ָ���
light_file='H:\FILE\luojia\LJUR_gz.tif';%ҹ��ƹ�Ӱ��
[patch,ref]=geotiffread(Patch_file); 
[light2,ref1]=geotiffread(light_file); 
light=light2(:,:,1);
info=geotiffinfo(Patch_file);
nrows = size(patch,1);ncols = size(patch,2);  %��ȡ����������
light_rs = reshape(light,nrows*ncols,1);
patch_rs = reshape(patch,nrows*ncols,1);

patchAdjust=patch; %�м����ͼ
for i=1:nrows
   for j=1:ncols
     if(patch(i,j)==0 && light(i,j)>0)%����Ǳ߽��ҵƹ����ȴ���0����Ѱ�ҹ���
         templight = 63;
         for wi = i-1:i+1
             if(wi>=1 && wi<=nrows)
                for wj = j-1:j+1
                  if(wj>=1 && wj<=ncols)
                      if(patch(wi,wj)>=2) %����߽��Ա���������Ѱ������������߽���Ԫ��ӽ��İ߿���Ϊ����
                          if abs(light(i,j)-light(wi,wj))<=templight
                             patchAdjust(i,j)=patchAdjust(wi,wj);
                             templight = abs(light(i,j)-light(wi,wj));
                          end
                      end
                  end
                end
             end
         end
     end
   end
end     
class_file='H:\FILE\luojia\2nd\luojia_repatch.tif';%ͼ���ļ�·��
geotiffwrite(class_file,patchAdjust,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);