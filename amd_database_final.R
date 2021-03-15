setwd("D:/Stuff/Personal_Projects/AMD_CPU_Datasbase")
library(dplyr)
library(anytime)
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


partpicker_data <- partpicker_data %>% mutate(Model = gsub("AMD Threadripper","AMD Ryzen Threadripper", Model))
partpicker_data <- partpicker_data %>% mutate(Price = gsub("Add","", Price))
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

#Change the clock speed columns and cache columns to numeric
merged_data <- merged_data %>% mutate(Core.Clock = as.numeric(gsub('GHz','', Core.Clock)))
merged_data <- merged_data %>% mutate(Boost.Clock = as.numeric(gsub('GHz','', Boost.Clock)))
merged_data <- merged_data %>% mutate(Price = as.numeric(gsub("\\$",'', Price)))
merged_data <- merged_data %>% mutate(Total.L1.Cache = as.numeric(gsub('KB','', Total.L1.Cache)))
merged_data <- merged_data %>% mutate(Total.L2.Cache = as.numeric(gsub('MB','', Total.L2.Cache)))
merged_data <- merged_data %>% mutate(Total.L3.Cache = as.numeric(gsub('MB','', Total.L3.Cache)))
merged_data <- merged_data %>% mutate(TDP = as.numeric(gsub('W','', TDP)))

#Fix the release dates that are not in the format mm/dd/yyyy or m/d/yyy
merged_data[15,"Launch.Date"] = "7/7/2020"
merged_data[3,"Launch.Date"] = "5/12/2020"
merged_data[5,"Launch.Date"] = "5/12/2020"
merged_data[24,"Launch.Date"] = "7/7/2020"
merged_data[34,"Launch.Date"] = "10/28/2018"
merged_data[36,"Launch.Date"] = "10/28/2018"

#Change the Launch Date Column to a datetime object
merged_data$Launch.Date <- anytime::anydate(merged_data$Launch.Date)

#Rename Columns
names <- c("Model","Core_Count","Core.Clock(GHz)","Boost.Clock(Ghz)","TDP(Watts)","Integrated.Graphics","SMT","Price","Family","Line","Launch.Date","L1.Cache(KB)","L2.Cache(MB)","L3.Cache(MB)")
colnames(merged_data) <- names

write.csv(merged_data,"D:/Stuff/Personal_Projects/Shinyapp/AMD-Shiny/amd_table.csv", row.names=FALSE)

