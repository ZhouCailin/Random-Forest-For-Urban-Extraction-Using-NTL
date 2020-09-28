clc;
clear all;
close all;

Patch_file='H:\FILE\luojia\2nd\lj_patch.tif';%第一步分割结果
light_file='H:\FILE\luojia\LJUR_gz.tif';%夜间灯光影像
[patch,ref]=geotiffread(Patch_file); 
[light2,ref1]=geotiffread(light_file); 
light=light2(:,:,1);
info=geotiffinfo(Patch_file);
nrows = size(patch,1);ncols = size(patch,2);  %获取行数和列数
light_rs = reshape(light,nrows*ncols,1);
patch_rs = reshape(patch,nrows*ncols,1);

patchAdjust=patch; %中间过渡图
for i=1:nrows
   for j=1:ncols
     if(patch(i,j)==0 && light(i,j)>0)%如果是边界且灯光亮度大于0，则寻找归宿
         templight = 63;
         for wi = i-1:i+1
             if(wi>=1 && wi<=nrows)
                for wj = j-1:j+1
                  if(wj>=1 && wj<=ncols)
                      if(patch(wi,wj)>=2) %如果边界旁边有宿主，寻找亮度特征与边界像元最接近的斑块作为宿主
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
class_file='H:\FILE\luojia\2nd\luojia_repatch.tif';%图像文件路径
geotiffwrite(class_file,patchAdjust,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);