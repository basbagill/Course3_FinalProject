## Create data directory if it doesn't exist
if(!file.exists("./data")) {
  dir.create("./data")
}

install.packages("dplyr")
library(dplyr)

## Download zip package
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/UCIDataset/wearable.zip", method = "curl")

## Read features from X_test.txt and X_train.txt files
features_train <- read.table("~/Desktop/Coursera/Course3/data/UCIDataset/train/X_train.txt")
features_test <- read.table("~/Desktop/Coursera/Course3/data/UCIDataset/test/X_test.txt")

## Read activities from y_train.txt and y_test.txt files
activities_train <- read.table("~/Desktop/Coursera/Course3/data/UCIDataset/train/y_train.txt")
activities_test <- read.table("~/Desktop/Coursera/Course3/data/UCIDataset/test/y_test.txt")

## Read subjects from subject_train.txt and subject_test.txt files
subjects_train <- read.table("~/Desktop/Coursera/Course3/data/UCIDataset/train/subject_train.txt")
subjects_test <- read.table("~/Desktop/Coursera/Course3/data/UCIDataset/test/subject_test.txt")

## Rename activity numeric codes with descriptive names from y_train.txt and y_test.txt files
activities_train[activities_train == 1] = "walking"
activities_train[activities_train == 2] = "walking_upstairs"
activities_train[activities_train == 3] = "walking_downstairs"
activities_train[activities_train == 4] = "sitting"
activities_train[activities_train == 5] = "standing"
activities_train[activities_train == 6] = "laying"

activities_test[activities_test == 1] = "walking"
activities_test[activities_test == 2] = "walking_upstairs"
activities_test[activities_test == 3] = "walking_downstairs"
activities_test[activities_test == 4] = "sitting"
activities_test[activities_test == 5] = "standing"
activities_test[activities_test == 6] = "laying"

## Name subject column for test and train data
names(subjects_train) <- "subject"
names(subjects_test) <- "subject"

## Name activities column for test and train data
names(activities_train) <- "activity"
names(activities_test) <- "activity"

## Name features columns for test and train data
features_col_names <- read.table("~/Desktop/Coursera/Course3/data/UCIDataset/features.txt")
names(features_train) <- features_col_names[, 2]
names(features_test) <- features_col_names[, 2]

## Merge features with activities data
features_activities_train <- cbind(activities_train, features_train)
features_activities_test <- cbind(activities_test, features_test)

## Merge subjects with features and activities data
subjects_features_activities_train <- cbind(subjects_train, features_activities_train)
subjects_features_activities_test <- cbind(subjects_test, features_activities_test)

## Merge test and train data
data_train_test <- rbind(subjects_features_activities_train, subjects_features_activities_test)

## Remove duplicate column names
duplicated(colnames(data_train_test))
uniquecols_data_train_test <- data_train_test[, !duplicated(colnames(data_train_test))]

## Extract only mean and standard deviation measurements
mean_std_data <- select(uniquecols_data_train_test, contains("subject"), contains("activity"), 
        contains("mean"), contains("std"))

## Create a tidy data set with the average of each variable for each activity and each subject
grouped_mean_std_data <- group_by(mean_std_data, subject, activity) # group by subject and activity
# calculate mean of each variable
mean_grouped_mean_std_data <- aggregate(grouped_mean_std_data[, 3:88], 
        list(grouped_mean_std_data$subject, grouped_mean_std_data$activity), mean)

## Rename first two columns as "subject" and "activity"
colnames(mean_grouped_mean_std_data)[colnames(mean_grouped_mean_std_data)=="Group.1"] <- "subject"
colnames(mean_grouped_mean_std_data)[colnames(mean_grouped_mean_std_data)=="Group.2"] <- "activity"

## Output the data set
mean_grouped_mean_std_data

## Write output file
write.table(mean_grouped_mean_std_data, file = "tidy_data_output.txt", row.names = FALSE)
