clc;
clear all;
close all;

Light_file = 'H:\FILE\luojia\LJUR_gz.tif';%夜间灯光数据
%Urban_file = 'H:\FILE\int3\data\2013urban.tif';%建成区数据
PotentialUrban_file='H:\FILE\luojia\2nd\luojia_repatch.tif';%斑块分割结果
[Light2,ref]=geotiffread(Light_file); %读取图像与参考坐标信息
%[Urban,ref1]=geotiffread(Urban_file);  
[PotentialUrban,ref2]=geotiffread(PotentialUrban_file);  
info=geotiffinfo(Light_file);
Urban=Light2(:,:,2);
Light=double(Light2(:,:,1));

nrows = size(Light,1);ncols = size(Light,2);  %获取行数和列数
Light_rs = reshape(Light,nrows*ncols,1);%矩阵重排成一列
Urban_rs = reshape(Urban,nrows*ncols,1);
PotentialUrban_rs = reshape(PotentialUrban,nrows*ncols,1);
BackValue = Light_rs(1,1);   %背景值
%阈值图像
threshold = double(PotentialUrban_rs);    
threshold(PotentialUrban_rs == 0)=9999;  %斑块0为分割线     
threshold(PotentialUrban_rs == 1)=9999;  %斑块1为背景，故均无最佳阈值
num = max(PotentialUrban_rs);   %斑块数量
temp = double(zeros(num-1,8));  %存放随机森林模型输入自变量（斑块面积，平均亮度等）与因变量（最佳阈值）

for i =1 :num
    
   %计算斑块i的大小并输出
   position = PotentialUrban_rs(:,1) ==i;
   PatchSize = sum(position); 
   temp(i,1)=i; %记录斑块编号
   
   %计算斑块内的有效像元数量
   temp_urban = Urban_rs(position,1);
   
    %计算斑块城镇像元数量
    count = sum(temp_urban(:,1)==1);
    temp(i,7)= count;   %记录斑块中城镇像元数量
    if(count<1)
     continue;
    end
   
   EffectivePixelPositon = temp_urban(:,1)>=0;
   EffectivePixelNumber = sum(EffectivePixelPositon);
   if EffectivePixelNumber == PatchSize %如果有效像元数量与斑块大小一致，
       temp(i,2) = PatchSize;      %记录斑块大小
   else %如果不一致
       temp(i,2) = EffectivePixelNumber; %记录斑块大小
   end
    temp_light = Light_rs(position,1);
    
    %如果斑块最大灯光亮度超过0，则统计数据，否则该斑块属于背景值
    if max(temp_light)>0 
    temp(i,3) = sum(temp_light(temp_light>0))/temp(i,2); %记录平均灯光亮度
    temp(i,4) = max(temp_light(temp_light>0)); %记录灯光亮度最大值
    temp(i,5)= min(temp_light(temp_light>0)); %记录灯光亮度最小值
    temp(i,6)=std(temp_light(temp_light>0));%记录灯光亮度标准差
              
     
     %计算斑块的最佳阈值
      if count >= 1 %如果城区数量大于1，求该斑块的最佳阈值
         temp_minus = 1000000 ; %设置初始的差值阈值
         temp_thresold = max(temp_light(temp_light>0))+1;
         while true 
             PixelPosition = temp_light(:,1)>=temp_thresold;   %大于灯光亮度为temp_thresold的像元位置
             temp_count = sum(PixelPosition); %计算满足条件的像元数量
             if  temp_count == count
                 temp(i,8)=temp_thresold;
                 break;
             elseif temp_count<count
                 if count-temp_count<=temp_minus
                     temp_minus = count-temp_count;
                     temp(i,8)=temp_thresold;
                     temp_thresold = temp_thresold-100;
                 end
             else
                 if temp_count-count<temp_minus
                     temp_minus = temp_count-count;
                     temp(i,8)=temp_thresold;
                     temp_thresold = temp_thresold-100;
                     break;
                 else
                     break;
                 end
             end
             if temp_thresold < min(temp_light(temp_light>0)) %阈值小于等于斑块最小亮度值要跳出循环
                 temp(i,8) = min(temp_light(temp_light>0)); %更新灯光阈值
                 break;
             end
          end
       else  %如果城区数量为0，则灯光阈值设为最大值
           temp(i,8) = max(temp_light(temp_light>0))+1;
      end
    else
        temp(i,8)=9999;
    end
   threshold(PotentialUrban_rs==i)=temp(i,8);  %更新阈值图像     
end
%输出阈值图像
threshold = reshape(threshold,nrows,ncols);
Threshold_file='H:\FILE\luojia\2nd\bestThres.tif';%图像文件路径
geotiffwrite(Threshold_file,threshold,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%输出统计数据
csvwrite('H:\FILE\luojia\2nd\2013patchsts.csv',temp);
% temp2=temp(:,7);
% temp3=temp2~=0;
% temp4=temp(temp3,:);
% temp3=temp2==0;
% temp5=temp(temp3,:);
fprintf('finish');