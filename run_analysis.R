setwd("D:/Users/bunty/Documents/LearningR/C4W4")
#setwd("./R/C4W4/Proj") # Change this path to any work directory of yours
url1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Required packages for the program and may be more
library(readr)
library(tidyr)
library(data.table)
library(dplyr)

temp <- tempfile() # creating a temporary NUL file for storing the zip file
download.file(url1, temp) # Download the zip file and store it as an R object

#Unzipped the required files with fron the zip file Paths of the files to read
p3 <- unz(temp, "UCI HAR Dataset/train/X_train.txt")
p31 <- unz(teamp, "UCI HAR Dataset/train/y_train.txt")
p4 <- unz(temp, "UCI HAR Dataset/train/subject_train.txt")
p5 <- unz(temp, "UCI HAR Dataset/test/subject_test.txt")

#Data clean up step below is needed for accomplishing the step #3.
# Read the coloumn labes from the feature.txt file and store them in a character vector

link <- unz(temp,"UCI HAR Dataset/activity_labels.txt" )
act_label <- tbl_df(read.table(link, header = FALSE, stringsAsFactors = FALSE))
names(act_label) <- c("ActivityCode", "Activity")


tab1 <- unz(temp, "UCI HAR Dataset/features.txt")
h1 <- read.table(tab1, header = FALSE, stringsAsFactors = FALSE)
# Read the test file and header file simultaneously with reading the header files as well..

tab1 <- unz(temp, "UCI HAR Dataset/test/X_test.txt")
Test <- read_table(tab1, col_names = h1$V2 )
sub_test <- read.table(p5, col.names = c("Subject"), stringsAsFactors = FALSE)
#read lable of the test data
link <- unz(temp, "UCI HAR Dataset/test/y_test.txt")
lab_test <- tbl_df(read.table(link, col.names = c("ActivityCode"), stringsAsFactors = FALSE))
lab_test <- left_join(lab_test, act_label, by ="ActivityCode")
lab_test <- tbl_df(lab_test$Activity)
Test <- dplyr::bind_cols(lab_test, sub_test, Test) # This adds activity labels and subject labels to test data


sub_train <- read.table(p4, col.names = c("Subject"), stringsAsFactors = FALSE) 
Train <- read_table(p3, col_names = h1$V2 )
# Store activity lables in another table lab_train
link <- unz(temp, "UCI HAR Dataset/train/y_train.txt")
lab_train <- tbl_df(read.table(link, col.names = c("ActivityCode"), stringsAsFactors = FALSE))
lab_train <- left_join(lab_train, act_label, by ="ActivityCode")
lab_train <- tbl_df(lab_train$Activity)
Train <- dplyr::bind_cols(lab_train, sub_train, Train) # Assembling Train data

#Step 1 : merging or adding the two data tables.
TT <- dplyr::bind_rows(Test, Train) # added rows of Train at the bottom of Test
setnames(TT, c("value"), c("Activity")) 

TT_compact <- TT %>% # selecting data extracting data containing mean and std in their coloumns
      select(Activity, Subject, contains("mean"), contains("std")) %>% # This selects required coloumns
      group_by(Activity, Subject) %>% # grouping information by subects and activities
      summarize_all(mean) # Summarizig the means of all 

