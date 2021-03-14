setwd("D:/Stuff/Personal_Projects/AMD_CPU_Datasbase")
library(dplyr)
#read in data
amd_data <- read.csv('official-amd-data.csv', header=T, stringsAsFactors = FALSE)
partpicker_data <- read.csv('pcpartpicker-data.csv', header=T, stringsAsFactors = FALSE)

head(partpicker_data)
head(amd_data)

#Rename the "Name" column of the partpicker data
colnames(partpicker_data)[1] = 'Model'

#Keep the columns of the AMD data that we want added to the partpicker data
amd_data <- select(amd_data, c(Model, Family, Line, Launch.Date, Total.L1.Cache, Total.L2.Cache,Total.L3.Cache))

#Remove the "Ratings" columns of the partpicker data
partpicker_data <- select(partpicker_data, -c(Rating))

#Fix the the strings in various columns so the two data sets will match each other
amd_data <- amd_data %>% mutate(Model = gsub('â„¢','', Model))
amd_data <- amd_data %>% mutate(Model = gsub(' with Radeon RX Vega 11 Graphics', '', Model))
amd_data <- amd_data %>% mutate(Model = gsub(' with Radeon Vega 8 Graphics', '', Model))
amd_data <- amd_data %>% mutate(Model = gsub(' Processor', '', Model))
amd_data <- amd_data %>% mutate(Family = gsub('â„¢', '', Family))
amd_data <- amd_data %>% mutate(Line = gsub('â„¢', '', Line))


partpicker_data <-partpicker_data %>% mutate(Model = gsub("AMD Threadripper","AMD Ryzen Threadripper", Model))
partpicker_data <-partpicker_data %>% mutate(Price = gsub("Add","", Price))
partpicker_data <- partpicker_data %>% mutate(Model = gsub("\\(12nm\\)", "", Model))
#the 14 nm model was phased oout early on so we only care about the 12nm model
partpicker_data <- dplyr::filter(partpicker_data, !grepl('(14nm)', Model))

#Remove any potential duplicates
partpicker_data <- subset(partpicker_data, !duplicated(subset(partpicker_data, select = c(Model))))
amd_data <- subset(amd_data, !duplicated(subset(amd_data, select = c(Model))))

#merge the two datasets
merged_data <- merge(partpicker_data, amd_data)

#We only want to look at the available-to-the-public Ryzen Destop Processors, so remove any non-ryzen processors (Athlon)
merged_data <- dplyr::filter(merged_data, !grepl('Athlon', Model))
