
#---------------------------------------------------------------------------------
# step 1: aggregate behavioral trial level data
#---------------------------------------------------------------------------------

# This R script aggregates the trial level behavioral data and calculates hit rate
# per Stimulus class for sham run

# First version written by Basil Preisig 02-06-2021

# dependencies
#install.packages("psyphy")
#install.packages("effsize")
#install.packages("tidyr")
library(psyphy)
library(effsize)
library(tidyr)

# get trial level data
#---------------------------------------------------------------------------------

DataDir="//p01-hdd//dsa//baprei-srv//Documents//DSC_3011204.02_679//analyses"
data<-read.table(file.path(DataDir, "behavioral_trial_data.txt", fsep = "//"),header=T, sep = ",")

data<-data[data$TACS=="Sham",]

# code new variables # exclude missing responses #exclude no_stimulus trials
#---------------------------------------------------------------------------------

data$Stimulus_class[data$Stimulus_name == "LE_highF3_RE_amb"] = "amb" # binaural integration trials
data$Stimulus_class[data$Stimulus_name == "LE_lowF3_RE_amb"] = "amb"
data$Stimulus_class[data$Stimulus_name == "LE_highF3_RE_da"] = "unamb" # unambiguous control trials
data$Stimulus_class[data$Stimulus_name == "LE_lowF3_RE_ga"] = "unamb"

# code hits
data$hit=0
data$hit[data$Stimulus_name == "LE_highF3_RE_amb" & data$Response=="da"] = 1
data$hit[data$Stimulus_name == "LE_lowF3_RE_amb" & data$Response=="ga"] = 1
data$hit[data$Stimulus_name == "LE_highF3_RE_da" & data$Response=="da"] = 1
data$hit[data$Stimulus_name == "LE_lowF3_RE_ga" & data$Response=="ga"] = 1

# code false alarms
data$fa=0
data$fa[data$Stimulus_name == "LE_highF3_RE_amb" & data$Response=="ga"] = 1
data$fa[data$Stimulus_name == "LE_lowF3_RE_amb" & data$Response=="da"] = 1
data$fa[data$Stimulus_name == "LE_highF3_RE_da" & data$Response=="ga"] = 1
data$fa[data$Stimulus_name == "LE_lowF3_RE_ga" & data$Response=="da"] = 1

# code missings
data$miss=0
data$miss[data$Response == "NaN"] = 1

# response
data$da_resp<-0
data$da_resp[data$Response=="da"] = 1

data$ga_resp<-0
data$ga_resp[data$Response=="ga"] = 1

#remove no stimlulus trials
data<-data[data$Stimulus_name!="no_stimulus",]

# average hits, fa, and miss per Stimlus class (amb vs unamb)
#---------------------------------------------------------------------------------

participant_id<-unique(data$participant_id)
Stimulus_class<-(unique(data$Stimulus_class))
Stimulus_name<-(unique(data$Stimulus_name))
Response<-cbind("da","ga")

df1<- data.frame(matrix(ncol = 4, nrow = 0))
x <- c("participant_id","Stimulus_name","numel","ratio")
colnames(df1) <- x

count<-1
for(iparticipant_id in participant_id) {
  for(iStimulus_name in Stimulus_name) {
    for(iResponse in Response) {
      subset1<-data[data$participant_id==iparticipant_id & data$Response==iResponse
                    & data$Stimulus_name==iStimulus_name,]
      
      subset2<-data[data$participant_id==iparticipant_id
                    & data$Stimulus_name==iStimulus_name,]
      
      df1[count,1]<-iparticipant_id
      df1[count,2]<-paste(iStimulus_name,toupper(iResponse),sep = "_")
      
      df1[count,3]<-nrow(subset1)
      df1[count,4]<-nrow(subset1)/nrow(subset2)
      
      count = count+1
    }
  }
}

# long to wide format 
#-------------------------------------------------------------------
data_wide <-spread(cbind(df1[,1:2],df1$ratio),"Stimulus_name", "df1$ratio")

# save data file to disk for analyses in JASP
write.table(data_wide, file = paste(DataDir,"behavioral_data_mean.txt",sep = "//"), sep = "\t",
            row.names = FALSE)