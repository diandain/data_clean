#amalgamate all of the crime data from each csv file into one dataset. Save this dataset into a csv file called AllNICrimeData.
filelist <- list.files(path = "C:/Users/Public/Documents/NICrimeData/datasets", pattern = ".csv", full.names = TRUE)
name = function(x) {
    read.csv(x, header = T)
}
temp <- lapply(filelist, name)
allfile <- do.call("rbind", temp)
write.table(allfile, file = "Z:/gongxiang/ALLNICrimeData.csv", sep = ",", row.names = F)
names(allfile)

#modify new file, remove the following attributes: CrimeID, Reported by, Falls within, LSOA code, LSOA name
newfile <- read.csv("Z:/gongxiang/ALLNICrimeData.csv", sep = ",", header = T)
removecol = newfile[, - c(1, 3, 4, 8, 9)]
write.table(removecol, file = "Z:/gongxiang/ALLNICrimeData.csv", sep = ",", row.names = F)

#tidy the NIPostcodes dataset. Remove or replace missing entries with a suitable identifier
postcode <- read.csv("C:/Users/Public/Documents/NIPostcodes.csv", sep = ",", header = FALSE, na.strings = c("", " ", "NA"))


#modify the County attribute to a suitable categorising factor
names(postcode) <- c("Organisation Name", "Sub-building Name", "Building Name", "Number", "Primary Thorfare", "Alt Thorfare", "Secondary Thorfare", "Locality", "Townland", "Town", "County", "Postcode", "x-coordinates", "y-coordinates", "Primary Key")
names(postcode)[11] <- c("City")
head(postcode)
str(postcode)

#Align all attributes and relevant data
newpost <- postcode[order(postcode$`Primary Thorfare`),]
write.table(newpost, file = "Z:/gongxiang/postcode1.csv", sep = ",", row.names = F)

#Move the primary key identifier to the start of the dataset
postcode1 = postcode[, c(15, 1:14)]
write.table(postcode1, file = "Z:/gongxiang/postcode1.csv", sep = ",", row.names = F)

#Modify the AllNICrimeData dataset so that the Location attribute contains only the street name. 
modifydata <- read.csv("Z:/gongxiang/ALLNICrimeData.csv", sep = ",", header = T)
modifydata$Location <- gsub("^.*On or near", " ", (modifydata$Location))
write.table(modifydata, file = "Z:/gongxiang/ALLNICrimeData.csv", sep = ",", row.names = F)

#modify the AllNICrimeData csv file so that it contains an attribute for each crime type. Modify each crime type attribute to contain summary information for crime per location. Delete duplicate Location records. Save the dataset as AllNICrimeDataSummary.
mydata <- read.csv("Z:/gongxiang/ALLNICrimeData.csv", sep = ",")
summaryda <- aggregate(mydata[5], mydata[4], summary)
head(summaryda)
str(summaryda)
write.table(summaryda, file = "Z:/gongxiang/ALLNICrimeDataSummary.csv", sep = ",", row.names = F)

#Amalgamate the NIPostcode csv file with the AllNICrimeDataSummary file so the AllNICrimeDataSummary csv file contains new attributes Town, County, Postcode. You can use the Location attribute to perform the join between both datasets.
postcodef <- read.csv("Z:/gongxiang/postcode1.csv", sep = ",")
allcrimef <- read.csv("Z:/gongxiang/ALLNICrimeDataSummary.csv", sep = ",")
allcrimef <- mutate_each(allcrimef, funs(toupper))
postcodef <- mutate_each(postcodef, funs(toupper))
allcrimef$Location <- trimws(allcrimef$Location, "l")
finaldata <- merge(postcodef, allcrimef, by.x = "Primary.Thorfare", by.y = "Location", all = TRUE, sort = FALSE)
head(finaldata)
str(finaldata)

#Save the modified dataset the the csv file called FinalNICrimeData.
write.table(finaldata, file = "Z:/gongxiang/FinalNICrimeData.csv", sep = ",", row.names = F)