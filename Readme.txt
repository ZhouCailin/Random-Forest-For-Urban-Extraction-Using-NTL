
1 input Nighttime Light Image, run waterSegementation.m, get pre-class image
2 input result of previous step, run reclasspatch.m, get classpatch image 
3 input result of previous step and rough urban 0-1 image, run calulateBestThresold, get a feature sheet of each patch
4 input feature sheet, run machinelearning2, get exact threshold value of each patch
5 input threshold value sheet, run estimateThreshold.m, get exact threshold value image 
6 compare exact threshold value image and NTL image, get final result of Urban Extraction

