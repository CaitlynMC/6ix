#  This runs analysis on the first two candle experiments (drawSeries1 and glyphLearning1)
#  
#  Author: Caitlyn McColeman
#  Date Created:  May 30 2017
#  Last Edit: 
#  
#  Cognitive Science Lab, Simon Fraser University 
#  Originally Created For: 6ix
#  
#  Reviewed: []
#  Verified: [] 
#
#  Note: Extended from groupError.R.
#  
#  INPUT: NA
#  
#  OUTPUT: NA
#  
#  Additional Scripts Used:NA
#  
#  Additional Comments: Requires CandlesTrialLvl to be exported from SQL as CandlesTrialLvl_view.csv and saved in the ~/Documents directory 

# load necessary libraries
require('lme4')
require('ggplot2')
library(lattice)
library(ggplot2)

############################################################################
############################# Data processing  #############################
############################################################################

candleDatIn <- read.table('~/Documents/CandlesTrialLvl_view.csv', sep = ',', header = T)
candleDatIn$candleCondition <- factor(candleDatIn$candleCondition)

# collapse different nomenclatures (psychtoolbox vs matlab difference from computer types)
corrRed = candleDatIn$CorrectColour == '[1 0 0]' | candleDatIn$CorrectColour == '[255 0 0]'
corrGreen = candleDatIn$CorrectColour == '[0 1 0]' | candleDatIn$CorrectColour == '[0 255 0]'
corrLightGrey = candleDatIn$CorrectColour == '[191.25 191.25 191.25]' | candleDatIn$CorrectColour == '[.75 .75 .75]'
corrDarkGrey = candleDatIn$CorrectColour == '[63.75 63.75 63.75]' | candleDatIn$CorrectColour == '[63.75 63.75 63.75]'

collapsedCorrCol = rep(NA, length(corrRed)) 

collapsedCorrCol[corrRed==T] = 'Red'
collapsedCorrCol[corrGreen==T] = 'Green'
collapsedCorrCol[corrLightGrey==T] = 'LightGrey'
collapsedCorrCol[corrDarkGrey==T] = 'DarkGrey'

# append updated colour column to dataframe  
candleDatIn = cbind(candleDatIn, collapsedCorrCol)

# drop missing values
hasColInfo = candleDatIn[!is.na(collapsedCorrCol),] # missing candle colour information
hasColInfo = hasColInfo[!hasColInfo$candleCondition == 'NULL',] # missing candle condition information
hasColInfo = hasColInfo[!hasColInfo$candleCondition == '0',] # missing candle condition information

candleDatInDS = hasColInfo[hasColInfo$sExpName == 'drawSeries',] # limit to drawSeries1 only
candleDatInDS2 = hasColInfo[hasColInfo$sExpName == 'drawSeries2',] # limit to drawSeries2 only (all noise condition)
candleDatInDS3 = hasColInfo[hasColInfo$sExpName == 'drawSeries3',] # limit to drawSeries3 only (spread conditions)

###################### by-dimension analysis

candleDatInDS$OpenErr = abs(candleDatInDS$ParticipantAnswerOpen - candleDatInDS$CorrectAnswerOpen)
candleDatInDS$CloseErr = abs(candleDatInDS$ParticipantAnswerClose - candleDatInDS$CorrectAnswerClose)
candleDatInDS$HighErr = abs(candleDatInDS$ParticipantAnswerHigh - candleDatInDS$CorrectAnswerHigh)
candleDatInDS$LowErr = abs(candleDatInDS$ParticipantAnswerLow - candleDatInDS$CorrectAnswerLow)

dimModDSOpen <- lmer(log(candleDatInDS$OpenErr) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS, REML = FALSE)
coefsDSdimOpen <- data.frame(coef(summary(dimModDSOpen)))
coefsDSdimOpen$p.z <- 2* (1-pnorm(abs(coefsDSdimOpen$t.value))) # normal approximation for p values 

dimModDSClose <- lmer(log(candleDatInDS$CloseErr) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS, REML = FALSE)
coefsDSdimClose <- data.frame(coef(summary(dimModDSClose)))
coefsDSdimClose$p.z <- 2* (1-pnorm(abs(coefsDSdimClose$t.value))) # normal approximation for p values 

dimModDSHigh <- lmer(log(candleDatInDS$HighErr) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS, REML = FALSE)
coefsDSdimHigh <- data.frame(coef(summary(dimModDSHigh)))
coefsDSdimHigh$p.z <- 2* (1-pnorm(abs(coefsDSdimHigh$t.value))) # normal approximation for p values 

dimModDSLow <- lmer(log(candleDatInDS$LowErr) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS, REML = FALSE)
coefsDSdimLow <- data.frame(coef(summary(dimModDSLow)))
coefsDSdimLow$p.z <- 2* (1-pnorm(abs(coefsDSdimLow$t.value))) # normal approximation for p values 

condition1ErrOC = ((candleDatInDS$CloseErr[candleDatInDS$candleCondition == 1]- candleDatInDS$OpenErr[candleDatInDS$candleCondition == 1]))
condition3ErrOC = ((candleDatInDS$CloseErr[candleDatInDS$candleCondition == 3]-candleDatInDS$OpenErr[candleDatInDS$candleCondition == 3]))

diffInErrOC = t.test(condition1ErrOC, condition3ErrOC) 

condition1ErrHL = ((candleDatInDS$LowErr[candleDatInDS$candleCondition == 1]- candleDatInDS$HighErr[candleDatInDS$candleCondition == 1]))
condition3ErrHL = ((candleDatInDS$LowErr[candleDatInDS$candleCondition == 3]-candleDatInDS$HighErr[candleDatInDS$candleCondition == 3]))

diffInErrHL = t.test(condition1ErrHL, condition3ErrHL) 
