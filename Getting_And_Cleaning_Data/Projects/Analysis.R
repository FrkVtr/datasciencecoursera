
# Charger des packages et obtenir les données
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Charger les étiquettes d'activité + caractéristiques
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                       , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# Ensembles de données train de charge
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# Charger les jeux de données de test
test  <- fread (file.path ( chemin , " Ensemble de données UCI HAR / test / X_test.txt " )) [, featuresWanted , avec  =  FALSE ]
data.table :: setnames ( test , noms de colonnes ( test ), mesures )
testActivities  <- fread (file.path ( chemin , " Ensemble de données UCI HAR / test / Y_test.txt " )
                        , col.names  = c ( " Activité " ))
testSubjects  <- fread (file.path ( chemin , " Ensemble de données HAR UCI / test / subject_test.txt " )
                      , col.names  = c ( " SubjectNum " ))
test  <- cbind ( testSubjects , testActivities , test )

# fusionner des jeux de données
combined <- rbind(train, test)

# Convertir classLabels to activityName fondamentalement. Plus explicite.
combined[["Activity"]] <- factor(combined[, Activity]
                              , levels = activityLabels[["classLabels"]]
                              , labels = activityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
