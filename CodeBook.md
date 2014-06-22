Getting and Cleaning Data - Course Project Codebook
---------------------------------------------------
---------------------------------------------------

This document modifies the "features_info.txt" file that was included with the UCI HAR Dataset zip file. 

The only data that was modified, were the activity IDs. The integers, which related to certain activities (walking upstairs, laying, standing, etc.) were replaced with friendly labels describing the activities as follows:

1 --> "Walking"
2 --> "Walking Upstairs"
3 --> "Walking Downstairs"
4 --> "Sitting"
5 --> "Standing"
6 --> "Laying"

Although no other data was modified, large swathes of data were removed, as they are not necessary for our purposes. A regular expression pattern match was applied to all of the feature names, to extract only the feature names we desired. The patterns matched were:
 - std
 - mean
 - Mean

This returned a set of 86 features. Additionally, we included the subject ID and activity ID in our dataset, creating a total of 88 columns. I opted to retain the names with capital- and lowercase-M, in order to gather all names with any reference to mean.

The feature names were cleaned up to create more user-friendly names. Feature names beginning with "t" or "f" were replaced with "time" and "freq", respectively, as time and frequency were the orinally-intended meanings of the measurements. All punctuation marks were removed, and standard camel-case was implemented (first letter of second-and-beyond words are capitalized). Also, "std" was replaced with "StdDev" to make it more readable. Also, all references to the dimension of a measurement (X, Y, Z) were moved to the end of feature name in order to standardize the location of the reference, and I believe it's easier to read.

The final dataset contains 180 rows, made up by an observation for each of the 30 subjects, for each of the 6 activities. The end-user wants to be able to look up the mean for a given measurement, for a subject and activity combination. Since there's only one row for each of these combinations, I feel like this is the most logical, and easy-to-use form of the data.
