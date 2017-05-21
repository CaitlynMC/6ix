#  This runs analysis on the first two candle experiments (drawSeries1 and glyphLearning1)
#  
#  Author: Caitlyn McColeman
#  Date Created: March 15 2017 
#  Last Edit:
#  
#  Cognitive Science Lab, Simon Fraser University 
#  Originally Created For: 6ix
#  
#  Reviewed: Jordan B. 23/03/2017 
#  Verified: [] 
#
#  Note: dirNameRec presumably refers to individual subjects. JB
#  
#  INPUT: NA
#  
#  OUTPUT: NA
#  
#  Additional Scripts Used:NA
#  
#  Additional Comments: This is not a generalized script since it only needs to run once. It requires CandlesTrialLvl to be exported from Sequel Pro as CandlesTrialLvl_view.csv and saved in the ~/Documents folder on a mac 
  

require('lme4')
require('ggplot2')
library(lattice)
library(ggplot2)
require('visualizationTools')

# load data

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

candleDatInDS = hasColInfo[hasColInfo$sExpName == 'drawSeries',] # limit to drawSeries1 only
candleDatInGL = hasColInfo[hasColInfo$sExpName == 'glyphLearning',] # limit to glyphLearning1 only

# LMER model for condition (drawSeries)
conditionModDS <- lmer(log(ErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS, REML = FALSE)
coefsDS <- data.frame(coef(summary(conditionModDS))) # added after review
coefsDS$p.z <- 2* (1-pnorm(abs(coefsDS$t.value))) # normal approximation for p values (via Mirman: http://mindingthebrain.blogspot.ca/2014/02/three-ways-to-get-parameter-specific-p.html)

# LMER model for condition (glyphLearning1)
conditionMod <- lmer(log(ErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInGL, REML = FALSE)

# run anova, trial ID and condition to predict error value (drawSeries)
fitDS <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInDS)
drop1(fitDS,~.,test="F") #type 3 sum of squares
# run anova, trial ID and condition to predict error value (glyphLearning)
fitGL <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInGL)
drop1(fitGL,~.,test="F") #type 3 sum of squares

# critical t-test: error val of red/green vs. up/down
bpRGUD = boxplot(candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 1], candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 3]) 
# drawSeries1
t.test(candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 1], candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 3])
ttest23 = t.test(candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 2], candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 3]) 
# glyphLearning
t.test(candleDatInGL$ErrorVal[candleDatInGL$candleCondition == 1], candleDatInGL$ErrorVal[candleDatInGL$candleCondition == 3])

# holds up for violations of assumptions via non parametric test?
# drawSeries1
wilDS = wilcox.test(candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 1], candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 3]) 
wilDS23 = wilcox.test(candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 2], candleDatInDS$ErrorVal[candleDatInDS$candleCondition == 3]) 
# glyphLearning1
wilGL = wilcox.test(candleDatInGL$ErrorVal[candleDatInGL$candleCondition == 1], candleDatInGL$ErrorVal[candleDatInGL$candleCondition == 3]) 

# reviewed version is fullScatterGL
fullScatterGL = qplot(candleCondition, log(ErrorVal), data = candleDatInGL, geom = c("jitter", "boxplot")) 

# view drawSeries by correct colour (this is the reviewed version)
fullScatterDS = qplot(collapsedCorrCol, log(ErrorVal), data = candleDatInDS, geom = c("jitter", "boxplot"))


# plot glyph learning (included after review)
fullScatterGL2 = ggplot(candleDatInGL, aes(factor(candleCondition), log(ErrorVal))) # updated plots after review [C.M. Mar 24 2017]
fullScatterGL2 = fullScatterGL2 + geom_boxplot()
fullScatterGL2 <- fullScatterGL2 + geom_boxplot(outlier.colour = NA) # outliers shown via jitter in a moment
fullScatterGL2 = fullScatterGL2 + geom_point(alpha = .075, size = 5, position = position_jitter(width = 0.1))

# raw data vis for drawSeries (included after review)
fullScatterDS2 = ggplot(candleDatInDS, aes(factor(candleCondition), log(ErrorVal))) # updated plots after review [C.M. Mar 24 2017]
fullScatterDS2 = fullScatterDS2 + geom_boxplot()
fullScatterDS2 <- fullScatterDS2 + geom_boxplot(outlier.colour = 'white') # outliers shown via jitter in a moment
fullScatterDS2 = fullScatterDS2 + geom_point(alpha = .1, size = 3, position = position_jitter(width = .5))
fullScatterDS2 = fullScatterDS2  + theme_bw()+ theme(text = element_text(size=20))
# ------------------------------------
#   section below requires review: [Mar 26 2017]
# ------------------------------------


###################### additional drawSeries studies
candleDatInDS2 = hasColInfo[hasColInfo$sExpName == 'drawSeries2',] # limit to drawSeries2 only (all noise condition)
candleDatInDS3 = hasColInfo[hasColInfo$sExpName == 'drawSeries3',] # limit to drawSeries2 only (all noise condition)

# LMER model for condition (drawSeries)
conditionModDS2 <- lmer(log(ErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS2, REML = FALSE)
conditionModDS3 <- lmer(log(ErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS3, REML = FALSE)

coefsDS2 <- data.frame(coef(summary(conditionModDS2))) # added after review
coefsDS2$p.z <- 2* (1-pnorm(abs(coefsDS2$t.value))) # normal approximation for p values (via Mirman: http://mindingthebrain.blogspot.ca/2014/02/three-ways-to-get-parameter-specific-p.html)

coefsDS3 <- data.frame(coef(summary(conditionModDS3))) # added after review
coefsDS3$p.z <- 2* (1-pnorm(abs(coefsDS3$t.value))) # normal approximation for p values (via Mirman: http://mindingthebrain.blogspot.ca/2014/02/three-ways-to-get-parameter-specific-p.html)

# run anova, trial ID and condition to predict error value (drawSeries)
fitDS2 <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInDS2)
drop1(fitDS2,~.,test="F") #type 3 sum of squares

fitDS3 <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInDS3)
drop1(fitDS3,~.,test="F") #type 3 sum of squares

# critical t-test: error val of red/green vs. up/down
bpRGUDDS2 = boxplot(candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 1], candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 4]) 
bpRGUDDS3 = boxplot(candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 1], candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 4]) 
# drawSeries2
bpRGUDTDS2 = t.test(candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 1], candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 4])
bpRGUDTDS3 = t.test(candleDatInDS3$ErrorVal[candleDatInDS3$candleCondition == 1], candleDatInDS3$ErrorVal[candleDatInDS3$candleCondition == 4])

# holds up for violations of assumptions via non parametric test?
# drawSeries1
wilDS2_13 = wilcox.test(candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 1], candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 3]) 
wilDS2_14 = wilcox.test(candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 1], candleDatInDS2$ErrorVal[candleDatInDS2$candleCondition == 4]) 

#wilDS3_13 = wilcox.test(candleDatInDS3$ErrorVal[candleDatInDS3$candleCondition == 1], candleDatInDS3$ErrorVal[candleDatInDS3$candleCondition == 3]) 
wilDS3_14 = wilcox.test(candleDatInDS3$ErrorVal[candleDatInDS3$candleCondition == 1], candleDatInDS3$ErrorVal[candleDatInDS3$candleCondition == 4]) 


# raw data vis for drawSeries2 
fullScatterDS2 = ggplot(candleDatInDS2, aes(factor(candleCondition), ErrorVal))
fullScatterDS2 = fullScatterDS2 + geom_boxplot()
fullScatterDS2 <- fullScatterDS2 + geom_boxplot(outlier.colour = 'NA') # outliers shown via jitter in a moment
fullScatterDS2 = fullScatterDS2 + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))

# raw data vis for drawSeries3 
fullScatterDS3 = ggplot(candleDatInDS3, aes(factor(candleCondition), ErrorVal))
fullScatterDS3 = fullScatterDS3 + geom_boxplot()
fullScatterDS3 <- fullScatterDS3 + geom_boxplot(outlier.colour = 'NA') # outliers shown via jitter in a moment


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

fullScatterDS3 = fullScatterDS3 + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))