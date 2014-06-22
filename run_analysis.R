# Function that takes a partial filepath and formats it appropriately for reading files.
location = function(path) {
  path = paste(xdir, path, sep="/")
  gsub("/+", "/", path)
}

### BEGIN MAIN SCRIPT ###

# Set up filepaths.
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile = paste(getwd(), "/dataset.zip", sep="")
xdir = paste(getwd(), "/UCI HAR Dataset", sep="")

# Create a two-column data frame that contains regular expression patterns and replacements.
# This will be used later to clean up the column names.
patterns = data.frame(c("^t", "^f", "[[:punct:]]", "mean", "std", "(.*)X(.+)$", "(.*)Y(.+)$", "(.*)Z(.+)$", "gravity", "anglet"), 
                      c("time", "freq", "", "Mean", "StdDev", "\\1\\2X", "\\1\\2Y", "\\1\\2Z", "Gravity", "timeAngle"), stringsAsFactors=F)
names(patterns) = c("pattern", "replace")

# Create a two-column data frame that maps variable names to partial file paths, for convenience.
# This will be used to programmatically create temporary data frames from the different files until they can be combined.
# Then it will be used to programmatically remove the temporary data frames from memory, to free up space.
vars = data.frame(c("xtrain", "ytrain", "subtrain", "xtest", "ytest", "subtest"), 
                  c("train/X_train.txt", "train/y_train.txt", "train/subject_train.txt", "test/X_test.txt", "test/y_test.txt", "test/subject_test.txt"), stringsAsFactors=F)
names(vars) = c("names", "filepath")

# Create a vector of activity labels.
activities = c("Walking", "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying")

# Download the zip file, if it doesn't exist in the working directory.
if(!file.exists(zipfile)) 
  download.file(url, zipfile)

# Unzip the zip file, if it hasn't been extracted yet.
if(!any(list.dirs(getwd(), recursive=F) == xdir)) 
  unzip(zipfile)

if(!(exists("featurenames") & exists("xnames"))) {
  # Read the features file to create column names for the data sets and insert names for the subject ID and the activity, if it hasn't been done yet.
  featurenames = c("subjectID", "activity", as.character(read.csv(location("features.txt"), header=F, sep="")[,2]))
  
  # Extract the feature names that relate to any kind of mean or standard deviation.
  xnames = featurenames[grep("std|mean|ID|Mean|activity", featurenames)]
  
  # Apply the regular expression replacements to the extracted feature names and the raw feature names.
  # The result of these operations will be character vectors containing the cleaned up (descriptive) feature names which will be applied to the datasets, later.
  for(i in 1:nrow(patterns)) {
    xnames       = sapply(X=patterns$pattern[i], FUN=gsub, patterns$replace[i], xnames)[,1]
    featurenames = sapply(X=patterns$pattern[i], FUN=gsub, patterns$replace[i], featurenames)[,1]
  } 
}

# Read the data files, if they're not in memory yet. Variable names are read from the "vars" matrix, created earlier.
for(i in 1:nrow(vars)) {
  if(!(exists(vars$names[i]) | exists("rawdata")))
    assign(vars$names[i], read.csv(location(vars$filepath[i]), header=F, sep=""))
}

# Combine training and test data into corresponding data frames, then combine those into a single data frame, if it hasn't been done yet.
if(!exists("rawdata")) {
  rawdata = rbind(cbind(subtrain, ytrain, xtrain), cbind(subtest, ytest, xtest))
  names(rawdata) = featurenames
}

# Remove old data frames from memory, freeing up space.
if(any(exists(vars$names)))
  rm(list=vars$names)

# Extract the measurements relating to means or standard deviations.
xdata = rawdata[, names(rawdata) %in% xnames]

# Create a data frame of the averages of each measurement in "xdata", if it doesn't exist.
# It does this by looping through all of the measurements for each subject-activity combination and returning the mean.
if(!exists("tidydata")) {
  tidydata = NULL
  for(k in 1:30) {                                 # Loop through subjects.
    temp2 = NULL
    for(j in 1:6) {                                # Loop through activities.
      temp1 = c(k, j)                              # Vector of values for one subject-activity combination
      
      for(i in 3:ncol(xdata)) {                    # Loop through observations and append mean to the vector.
        temp1 = c(temp1, mean(xdata[xdata$subjectID == k & xdata$activity == j, i]))
      } 
      
    temp2 = rbind(temp2, temp1)                    # Append vector to the next row, containing the values for all activities for one subject.
    }
  tidydata = as.data.frame(rbind(tidydata, temp2)) # Append subject's data to the others, eventually creating the data frame with the required values.
  }
}

# Assign row- and column-names to the tidy dataset.
names(tidydata) = xnames
rownames(tidydata) = 1:nrow(tidydata)

# Rename activity data to reflect the activity being performed.
tidydata$activity = sapply(tidydata$activity, function(x) {activities[tidydata[x,2]]})
 rawdata$activity = sapply( rawdata$activity, function(x) {activities[ rawdata[x,2]]})

# Create a simple text file with the data, space-separated.
write.table(tidydata, "tidydata.txt", sep=" ", row.names=F)