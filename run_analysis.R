#First, create the folder for downloading the dataset
if(!file.exists("./data")){dir.create("./data")}

#Download the dataset to the folder using the given URL
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

#Unzip the dataset
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#Read files from the path
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)

#Check the names of the files in the path
files

#For the purpose of this exercise, read only the data from test and train datasets
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

#check the structure of the data
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

#Combine the subject train data and subject test data
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)

#Combine the activity train data and test data
dataActivity<- rbind(dataActivityTrain, dataActivityTest)

#Combine the Features train data and test data
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#Mark the col headers for subject data and activity data
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")

#Extract the col headers for features data from features.txt
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)

#Apply col headers to the features data
names(dataFeatures)<- dataFeaturesNames$V2

#Now combine the entire data into one data frame called "Data"
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#Now subset the mean and standard deviation specific headers from the "dataFeaturesNames" helper file
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#Create a list of cols for the new required dataframe which is mean + tsd + subject + activity data
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )

#Subset the above mentioned cols from the "Data" dataframe
Data<-subset(Data,select=selectedNames)

#Check the data
str(Data)

#Read the activity labels from the helper file
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

#Map these activity labels to the "Data" dataframe as factors
Data$activity<-factor(Data$activity);
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))

#Check the data
head(Data$activity,30)


#prefix t is replaced by time
names(Data)<-gsub("^t", "time", names(Data))

#prefix f is replaced by frequency
names(Data)<-gsub("^f", "frequency", names(Data))

#Acc is replaced by Accelerometer
names(Data)<-gsub("Acc", "Accelerometer", names(Data))

#Gyro is replaced by Gyroscope
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))

#Mag is replaced by Magnitude
names(Data)<-gsub("Mag", "Magnitude", names(Data))

#BodyBody is replaced by Body
names(Data)<-gsub("BodyBody", "Body", names(Data))

#Check
names(Data)

#Creates a second,independent tidy data set and output it
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
