setwd("./R/C4W4/Proj") # Change this path to any work directory of yours
url1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Required packages for the program and may be more
library(readr)
library(tidyr)
library(data.table)
library(dplyr)

temp <- tempfile() # creating a temporary NUL file for storing the zip file
download.file(url1, temp) # Down load the zip file and store it as an R object

#Unzipped the required files with fron the zip file Paths of the files to read
p3 <- unz(temp, "UCI HAR Dataset/train/X_train.txt")
p4 <- unz(temp, "UCI HAR Dataset/train/subject_train.txt")
p5 <- unz(temp, "UCI HAR Dataset/test/subject_test.txt")

#Data clean up step below is needed for accomplishing the step #3.
# Read the coloumn labes from the feature.txt file and store them in a character vector

tab1 <- unz(temp, "UCI HAR Dataset/features.txt")
h1 <- read.table(tab1, header = FALSE, stringsAsFactors = FALSE)
rm(tab1)

h1$V2 <- gsub(",1$", "-WALKING",  h1$V2 ) # ADDING THE PROPER LABELS FOR ACTIVITY CODES
h1$V2 <- gsub(",2$", "-WALKING_UPSTAIRS",  h1$V2 )
h1$V2 <- gsub(",3$", "-WALKING_DOWNSTAIRS",  h1$V2 )
h1$V2 <- gsub(",4$", "-SITTING",  h1$V2 )
h1$V2 <- gsub(",5$", "-STANDING",  h1$V2 )
h1$V2 <- gsub(",6$", "-LAYING",  h1$V2 )
# Read the test file and header file simultaneously with reading the header files as well..

tab1 <- unz(temp, "UCI HAR Dataset/test/X_test.txt")
Test <- read_table(tab1, col_names = h1$V2 )
sub_test <- read.table(p5, col.names = c("Subject"), stringsAsFactors = FALSE)
Test <- dplyr::bind_cols(sub_test, Test)

sub_train <- read.table(p4, col.names = c("Subject"), stringsAsFactors = FALSE) 
Train <- read_table(p3, col_names = h1$V2 )
Train <- dplyr::bind_cols(sub_train, Train) 
#Step 1 : merging or adding the two data tables.
TT <- dplyr::bind_rows(Test, Train) # added rows of Train at the bottom of Test

sub <- dplyr::bind_rows(sub_test, sub_train)
sub <- tbl_df(sub) # Creating the new data fame with one coloumn with subjects only

#Step 2 : Extracts only the measurements 
# on the mean and standard deviation for each measurement.
TT1 <- select(TT, contains("mean")) # Selecting only coloumns where word mean appears
TT2 <- select(TT, contains("std")) # Selecting coloumns where std word appears.

TT3 <- dplyr::bind_cols(TT1, TT2) 
TT3 <- dplyr::bind_cols(sub, TT3) # adding subject column to filtered data.

# This will accomplish the step 5. grouped by subject and summarised by means
TT4 <- TT3 %>% group_by(Subject) %>% summarise_all(mean)

#Getting the tidy set from the program it will write this file in wd.
write.table(TT4, file = "TidySet.txt", row.names = FALSE)
unlink(temp) 
#Clearning cache
rm(temp, TT1, TT2, TT, Train, sub_test, TT3, sub_train, Test, h1, sub)
