clc;
clear all;
close all;

Light_file = 'H:\FILE\luojia\LJUR_gz.tif';%ҹ��ƹ�����
%Urban_file = 'H:\FILE\int3\data\2013urban.tif';%����������
PotentialUrban_file='H:\FILE\luojia\2nd\luojia_repatch.tif';%�߿�ָ���
[Light2,ref]=geotiffread(Light_file); %��ȡͼ����ο�������Ϣ
%[Urban,ref1]=geotiffread(Urban_file);  
[PotentialUrban,ref2]=geotiffread(PotentialUrban_file);  
info=geotiffinfo(Light_file);
Urban=Light2(:,:,2);
Light=double(Light2(:,:,1));

nrows = size(Light,1);ncols = size(Light,2);  %��ȡ����������
Light_rs = reshape(Light,nrows*ncols,1);%�������ų�һ��
Urban_rs = reshape(Urban,nrows*ncols,1);
PotentialUrban_rs = reshape(PotentialUrban,nrows*ncols,1);
BackValue = Light_rs(1,1);   %����ֵ
%��ֵͼ��
threshold = double(PotentialUrban_rs);    
threshold(PotentialUrban_rs == 0)=9999;  %�߿�0Ϊ�ָ���     
threshold(PotentialUrban_rs == 1)=9999;  %�߿�1Ϊ�������ʾ��������ֵ
num = max(PotentialUrban_rs);   %�߿�����
temp = double(zeros(num-1,8));  %������ɭ��ģ�������Ա������߿������ƽ�����ȵȣ���������������ֵ��

for i =1 :num
    
   %����߿�i�Ĵ�С�����
   position = PotentialUrban_rs(:,1) ==i;
   PatchSize = sum(position); 
   temp(i,1)=i; %��¼�߿���
   
   %����߿��ڵ���Ч��Ԫ����
   temp_urban = Urban_rs(position,1);
   
    %����߿������Ԫ����
    count = sum(temp_urban(:,1)==1);
    temp(i,7)= count;   %��¼�߿��г�����Ԫ����
    if(count<1)
     continue;
    end
   
   EffectivePixelPositon = temp_urban(:,1)>=0;
   EffectivePixelNumber = sum(EffectivePixelPositon);
   if EffectivePixelNumber == PatchSize %�����Ч��Ԫ������߿��Сһ�£�
       temp(i,2) = PatchSize;      %��¼�߿��С
   else %�����һ��
       temp(i,2) = EffectivePixelNumber; %��¼�߿��С
   end
    temp_light = Light_rs(position,1);
    
    %����߿����ƹ����ȳ���0����ͳ�����ݣ�����ð߿����ڱ���ֵ
    if max(temp_light)>0 
    temp(i,3) = sum(temp_light(temp_light>0))/temp(i,2); %��¼ƽ���ƹ�����
    temp(i,4) = max(temp_light(temp_light>0)); %��¼�ƹ��������ֵ
    temp(i,5)= min(temp_light(temp_light>0)); %��¼�ƹ�������Сֵ
    temp(i,6)=std(temp_light(temp_light>0));%��¼�ƹ����ȱ�׼��
              
     
     %����߿�������ֵ
      if count >= 1 %���������������1����ð߿�������ֵ
         temp_minus = 1000000 ; %���ó�ʼ�Ĳ�ֵ��ֵ
         temp_thresold = max(temp_light(temp_light>0))+1;
         while true 
             PixelPosition = temp_light(:,1)>=temp_thresold;   %���ڵƹ�����Ϊtemp_thresold����Ԫλ��
             temp_count = sum(PixelPosition); %����������������Ԫ����
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
             if temp_thresold < min(temp_light(temp_light>0)) %��ֵС�ڵ��ڰ߿���С����ֵҪ����ѭ��
                 temp(i,8) = min(temp_light(temp_light>0)); %���µƹ���ֵ
                 break;
             end
          end
       else  %�����������Ϊ0����ƹ���ֵ��Ϊ���ֵ
           temp(i,8) = max(temp_light(temp_light>0))+1;
      end
    else
        temp(i,8)=9999;
    end
   threshold(PotentialUrban_rs==i)=temp(i,8);  %������ֵͼ��     
end
%�����ֵͼ��
threshold = reshape(threshold,nrows,ncols);
Threshold_file='H:\FILE\luojia\2nd\bestThres.tif';%ͼ���ļ�·��
geotiffwrite(Threshold_file,threshold,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%���ͳ������
csvwrite('H:\FILE\luojia\2nd\2013patchsts.csv',temp);
% temp2=temp(:,7);
% temp3=temp2~=0;
% temp4=temp(temp3,:);
% temp3=temp2==0;
% temp5=temp(temp3,:);
fprintf('finish');