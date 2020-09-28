library(randomForest)


#加载数据
data <-read.table('H:/FILE/int3/result/2013patchsts.csv',sep=',')
wholedata <-read.table('H:/FILE/int3/result/2013patchsts.csv',sep=',')

#使用sample函数抽取样本，将数据集中观测值分为两个子集
set.seed(1234)  #设置种子，使每次选取的随机样本都相同
ind  <- sample(2,nrow(data),replace=TRUE,prob=c(0.8,0.2))
trainData <- data[ind==1,]
testData <-data[ind==2,]
write.csv(trainData,'H:/FILE/int3/学生数据及程序/result/2013traindata.csv')
#随机森林模型训练
myFormula <- V8~V2+V3+V4+V5

rf <- randomForest(myFormula,data = trainData,importance=TRUE,ntree=400,proximity=TRUE,mtry=2)
plot(rf)
importance(rf)
print(rf)

#随机森林预测
dataPred<-predict(rf,newdata = testData)
testData$V9 = dataPred
write.csv(testData,'H:/FILE/int3/学生数据及程序/result/2013predictdata2.csv')

wholepred<-predict(rf,newdata = wholedata)
wholedata$V9=wholepred
write.csv(wholedata,'H:/FILE/int3/result/2013wholedatapredict2.csv')

