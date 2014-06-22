run_analysis.R is the only script required for this assignment. It doesn't require any setup in order for it to perform its function (however an internet connection is required). The script will automatically download the necessary zip file from the internet and process it from there. It will store the zip file in the current working directory, and unzip the contents to a sub-folder, "UCI HAR Dataset". All filepaths are constructed dynamically, so it will work, no matter where the working directory is on the local hard drive.

There is one custom function, "location", at the top of this script. It simply allows you to give it a partial filepath and it will construct the entire filepath with the given portion appended to it. This helps prevent mistakes and is easier to read.

Almost every step is documented in the code, so please refer to the script for explanation on what individual sections of the code are doing. I will, however, give a general overview of how the entire script performs its role.

First, there is a lot of setup; URLs and filepaths are stored into memory, as well as a few two-column data frames which contain some necessary mappings for later in the script.

The first data frame, "patterns", contains regular expression patterns to be searched for in the dataset feature names. The second column contains the replacement strings for the patterns. Once the dataset is loaded into memory, the feature names will be compared and replaced, using these regex patterns to clean up the variable names.

The second data frame, "vars", is used in a very different way. The first column contains R variable names which will temporarily store data frames of each one of the individual data files. The second column contains the partial filepath (remember the "location" function?) where the script can find the data file. The script will load the data files into their corresponding variable names, merge the data frames into one huge data frame, "rawdata", then remove the smaller temporary data frames. This is to free up memory, since the data frames are so large.

Once the initial setup is done, the file is downloaded and unzipped, then the feature names are loaded, and the names containing any reference to means or standard deviations are saved. I opted to retain the names with capital- and lowercase-M, in order to gather all names with any reference to mean.

Next, the "vars" data frame is processed, and the data files are loaded into memory. Then, they are combined into "rawdata". After that, the temporary data frames are removed from memory.

Next, only the data required for output is extracted into a separate data frame, and the means are calculated. Then, the names are cleaned up, and the activity data is re-assigned an English label, as opposed to the integers they were before. Since there is no numerical relationship between the different activities performed, I felt it was better to give them a label instead of a number.

Finally, a text file is written to the hard drive containing the tidy dataset. It has been included in the repo, for reference.