#  This runs analysis on the user performance error during the candle experiments.
#  
#  Author: Caitlyn McColeman
#  Date Created: March 15 2017 
#  Last Edit: May 30-June 8 2017 - major re-write to encompass multiple experiments and process additional variables of interest for DS2-3, GL3.
#  
#  Cognitive Science Lab, Simon Fraser University 
#  Originally Created For: 6ix
#  
#  Reviewed: Jordan B. 23/03/2017 (prior to major rewrite)
#  re-write reviewed: []
#
#  Verified: [] 
#
#  Note: dirNameRec presumably refers to individual subjects. JB. Confirmed - CM
#  
#  INPUT: NA
#  
#  OUTPUT: NA
#  
#  Additional Scripts Used:NA
#  
#  Additional Comments:
  
# load necessary libraries
require('lme4')
require('ggplot2')
library(lattice)
library(ggplot2)
require('data.table')
require('binr')
library(RMySQL)
library('multcomp')

#connect to experiments database
dbConn = dbConnect(MySQL(), user='data',  password='jyxfer8mvi',
                 dbname='experiments', host='cslab.psyc.sfu.ca')

# call data from SQL
SQLCall<- 'select * from candlestriallvl'
candleDatIn = dbGetQuery(dbConn, SQLCall)
candleExpLvl = dbGetQuery(dbConn, 'select * from candlesexplvl')

############################################################################
############################# Data processing  #############################
############################################################################

candleDatIn$candleCondition <- factor(candleDatIn$candleCondition)

# collapse different nomenclatures (psychtoolbox vs matlab difference from computer types)
corrRed = candleDatIn$CorrectColour == '[1 0 0]' | candleDatIn$CorrectColour == '[255 0 0]'
corrGreen = candleDatIn$CorrectColour == '[0 1 0]' | candleDatIn$CorrectColour == '[0 255 0]'
corrLightGrey = candleDatIn$CorrectColour == '[191.25 191.25 191.25]' | candleDatIn$CorrectColour == '[.75 .75 .75]'
corrDarkGrey = candleDatIn$CorrectColour == '[63.75 63.75 63.75]' | candleDatIn$CorrectColour == '[.25 .25 .25]'

collapsedCorrCol = rep(NA, length(corrRed)) 

collapsedCorrCol[corrRed==T] = 'Red'
collapsedCorrCol[corrGreen==T] = 'Green'
collapsedCorrCol[corrLightGrey==T] = 'LightGrey'
collapsedCorrCol[corrDarkGrey==T] = 'DarkGrey'

candleDatIn$TrialID = as.numeric(candleDatIn$TrialID)
candleDatIn$ErrorVal = as.numeric(candleDatIn$ErrorVal)

# append updated colour column to dataframe  
candleDatIn = cbind(candleDatIn, collapsedCorrCol)

# drop missing values
hasColInfo = candleDatIn[!is.na(collapsedCorrCol),] # missing candle colour information
hasColInfo = hasColInfo[!hasColInfo$candleCondition == 'NULL',] # missing candle condition information
hasColInfo = hasColInfo[!hasColInfo$candleCondition == '0',] # missing candle condition information

candleDatInDS = hasColInfo[hasColInfo$sExpName == 'drawSeries',] # limit to drawSeries1 only
candleDatInDS2 = hasColInfo[hasColInfo$sExpName == 'drawSeries2',] # limit to drawSeries2 only (all noise condition)
candleDatInDS3 = hasColInfo[hasColInfo$sExpName == 'drawSeries3',] # limit to drawSeries3 only (spread conditions)

candleDatInGL = hasColInfo[hasColInfo$sExpName == 'glyphLearning',] # limit to glyphLearning1 only
candleDatInGL2 = hasColInfo[hasColInfo$sExpName == 'glyphLearning2',] # limit to glyphLearning2 only (where everyone has grid lines)
candleDatInGL3 = hasColInfo[hasColInfo$sExpName == 'glyphLearning3',] # limit to glyphLearning2 only (all spread conditions)


############################# DrawSeries2
# intialize "noise dimension" vector for drawSeries2
noiseDimRec = vector(mode = "integer", length = nrow(candleDatInDS2))
noiseDimTemp = noiseDimRec
# repeat relevant experiment level information to trial lvl for analysis
for (i in candleExpLvl$timeIDDir) {
  
  # find instances of this timeIDDir at trial lvl
  iEdited=trimws(i) # lose trailing white space in expLvl timeIDDir recording
  matchCrossLvl=candleDatInDS2$dirNameRec == iEdited
  
  # if that time directory exists at trial lvl too, it's the same person.
  if (sum(matchCrossLvl==TRUE, na.rm = T)>0) { 
    
    print(i)
    
    # repeat the noise condition as a vector marker
    noiseDimTemp[matchCrossLvl==TRUE]=candleExpLvl$NoisyDimension[candleExpLvl$timeIDDir == i]
    
  }  # / if
} # / loop
candleDatInDS2$noisyDimension = factor(noiseDimTemp) # append to data frame for analysis

############################# DrawSeries3, GlyphLearning 3
# intialize spread factor marker for drawSeries3
spreadRec = vector(mode = "integer", length = nrow(candleDatInDS3))
spreadRecTemp = spreadRec

# intialize spread factor marker for glyphLearning3
spreadRecGL = vector(mode = "integer", length = nrow(candleDatInGL3))
spreadRecTempGL = spreadRecGL

# repeat relevant experiment level information to trial lvl for analysis
for (i in candleExpLvl$timeIDDir) {
  
  # find instances of this timeIDDir at trial lvl
  iEdited=trimws(i) # lose trailing white space in expLvl timeIDDir recording
  matchCrossLvlDS3=candleDatInDS3$dirNameRec == iEdited 
  matchCrossLvlGL3=candleDatInGL3$dirNameRec == iEdited
  
  # if that time directory exists at trial lvl too, it's the same person.
  if (sum(matchCrossLvlDS3==TRUE, na.rm = T)>0){ 
    
    print(i)
    
    # repeat the spread factor value as a vector marker
    spreadRecTemp[matchCrossLvlDS3==TRUE]=candleExpLvl$spreadFactor[candleExpLvl$timeIDDir == i]
    
  }  else if (sum(matchCrossLvlGL3==TRUE, na.rm = T)>0) {
    print(i)
    
    # repeat the spread factor value as a vector marker
    spreadRecTempGL[matchCrossLvlGL3==TRUE]=candleExpLvl$spreadFactor[candleExpLvl$timeIDDir == i]
    
    }# / if
} # / loop
candleDatInDS3$spreadFactor = factor(spreadRecTemp) # append to data frame for analysis
candleDatInGL3$spreadFactor = factor(spreadRecTempGL) # append to data frame for analysis

  
# format data and calculate by-subject means; keep a record of condition.
meansDS1 = aggregate(candleDatInDS$ErrorVal, by = list(candleDatInDS$dirNameRec, candleDatInDS$candleCondition), FUN=mean, na.rm=TRUE)
meansDS2 = aggregate(candleDatInDS2$ErrorVal, by = list(candleDatInDS2$dirNameRec, candleDatInDS2$candleCondition), FUN=mean, na.rm=TRUE)
meansDS3 = aggregate(candleDatInDS3$ErrorVal, by = list(candleDatInDS3$dirNameRec, candleDatInDS3$candleCondition), FUN=mean, na.rm=TRUE)

meansGL1 = aggregate(candleDatInGL$ErrorVal, by = list(candleDatInGL$dirNameRec, candleDatInGL$candleCondition), FUN=mean, na.rm=TRUE)
meansGL2 = aggregate(candleDatInGL2$ErrorVal, by = list(candleDatInGL2$dirNameRec, candleDatInGL2$candleCondition), FUN=mean, na.rm=TRUE)
meansGL3 = aggregate(candleDatInGL3$ErrorVal, by = list(candleDatInGL3$dirNameRec, candleDatInGL3$candleCondition), FUN=mean, na.rm=TRUE)


############################################################################
############################### LMER models  ###############################
############################################################################

# LMER model for condition (drawSeries)
conditionModDS <- lmer(log(ErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS, REML = FALSE)
coefsDS <- data.frame(coef(summary(conditionModDS))) # added after review
coefsDS$p.z <- 2* (1-pnorm(abs(coefsDS$t.value))) # normal approximation for p values (via Mirman: http://mindingthebrain.blogspot.ca/2014/02/three-ways-to-get-parameter-specific-p.html)
conditionTest = glht(conditionModDS,linfct=mcp(candleCondition="Tukey"))

# LMER model for condition (drawSeries2)
conditionModDS2 <- lmer(log(ErrorVal) ~ TrialID * candleCondition + noisyDimension + (TrialID | dirNameRec), candleDatInDS2, REML = FALSE)
coefsDS2 <- data.frame(coef(summary(conditionModDS2))) # added after review
coefsDS2$p.z <- 2* (1-pnorm(abs(coefsDS2$t.value))) # normal approximation for p values (via Mirman: http://mindingthebrain.blogspot.ca/2014/02/three-ways-to-get-parameter-specific-p.html)
noiseTest = glht(conditionModDS2,linfct=mcp(noisyDimension="Tukey"))

# LMER model for condition (drawSeries3)
conditionModDS3 <- lmer(log(ErrorVal) ~ TrialID * candleCondition * spreadFactor + (TrialID | dirNameRec), candleDatInDS3, REML = FALSE)
coefsDS3 <- data.frame(coef(summary(conditionModDS3))) # added after review
coefsDS3$p.z <- 2* (1-pnorm(abs(coefsDS3$t.value))) # normal approximation for p values (via Mirman: http://mindingthebrain.blogspot.ca/2014/02/three-ways-to-get-parameter-specific-p.html)
spreadTest = glht(conditionModDS3,linfct=mcp(spreadFactor="Tukey"))


# LMER model for condition (glyphLearning1)
conditionModGL <- lmer(log(ErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInGL, REML = FALSE)
coefsGL <- data.frame(coef(summary(conditionModGL)))
coefsGL$p.z <- 2* (1-pnorm(abs(coefsGL$t.value)))
conditionTestGL = glht(conditionModGL,linfct=mcp(candleCondition="Tukey"))

# LMER model for condition (glyphLearning2)
conditionModGL2 <- lmer(log(ErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInGL2, REML = FALSE)
coefsGL2 <- data.frame(coef(summary(conditionModGL2)))
coefsGL2$p.z <- 2* (1-pnorm(abs(coefsGL2$t.value)))
gridConditionTestGL = glht(conditionModGL2,linfct=mcp(candleCondition="Tukey"))

# LMER model for condition (glyphLearning3)
conditionModGL3 <- lmer(log(ErrorVal) ~ TrialID * candleCondition * spreadFactor + (TrialID | dirNameRec), candleDatInGL3, REML = FALSE)
coefsGL3 <- data.frame(coef(summary(conditionModGL3)))
coefsGL3$p.z <- 2* (1-pnorm(abs(coefsGL3$t.value)))
spreadTestGL = glht(conditionModGL3,linfct=mcp(spreadFactor="Tukey"))


############################################################################
############################### ANOVA tests  ###############################
############################################################################

# run anova, trial ID and condition to predict error value (drawSeries)
fitDS <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInDS)
drop1(fitDS,~.,test="F") #type 3 sum of squares

# run anova, trial ID and condition to predict error value (drawSeries2)
fitDS2 <- aov(ErrorVal ~ TrialID * candleCondition * noisyDimension, data = candleDatInDS2)
drop1(fitDS2,~.,test="F") #type 3 sum of squares
tukeyDS2Condition = glht(fitDS2, linfct = mcp(candleCondition = "Tukey"), abseps=.05)
tukeyDS2Noise = glht(fitDS2, linfct = mcp(noisyDimension = "Tukey"), abseps=.05)

# run anova, trial ID and condition to predict error value (drawSeries3)
fitDS3 <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInDS3)
drop1(fitDS3,~.,test="F") #type 3 sum of squares

# run anova, trial ID and condition to predict error value (glyphLearning)
fitGL <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInGL)
drop1(fitGL,~.,test="F") #type 3 sum of squares

# run anova, trial ID and condition to predict error value (glyphLearning2)
fitGL2 <- aov(ErrorVal ~ TrialID * candleCondition, data = candleDatInGL2)
drop1(fitGL2,~.,test="F") #type 3 sum of squares

############################################################################
############critical t-tests: error val of red/green vs. up/down############
############################################################################
# drawSeries1
ttest13DS = t.test(meansDS1$x[meansDS1$Group.2 == 1], meansDS1$x[meansDS1$Group.2 == 3])
ttest23DS = t.test(meansDS1$x[meansDS1$Group.2 == 2], meansDS1$x[meansDS1$Group.2 == 3])

# drawSeries2
ttest13DS2 = t.test(meansDS1$x[meansDS2$Group.2 == 1], meansDS1$x[meansDS2$Group.2 == 4])

# drawSeries3
ttest13DS3 = t.test(meansDS1$x[meansDS3$Group.2 == 1], meansDS1$x[meansDS3$Group.2 == 4])

# glyphLearning
ttest13GL = t.test(meansDS1$x[meansGL1$Group.2 == 1], meansDS1$x[meansGL1$Group.2 == 3])

# glyphLearning2
ttest13GL2 = t.test(meansDS1$x[meansGL2$Group.2 == 1], meansDS1$x[meansGL2$Group.2 == 3])

############################################################################
##################### visualize DV (performance error) #####################
############################################################################

# raw data vis for drawSeries
fullScatterDS = ggplot(candleDatInDS, aes(factor(candleCondition), log(ErrorVal))) 
fullScatterDS = fullScatterDS + geom_boxplot()
fullScatterDS <- fullScatterDS + geom_boxplot(outlier.colour = 'white') # outliers shown via jitter in a moment
fullScatterDS = fullScatterDS + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))
fullScatterDS = fullScatterDS  + theme_bw()+ theme(text = element_text(size=20))

# raw data vis for drawSeries2
fullScatterDS2 = ggplot(candleDatInDS2, aes(factor(candleCondition), log(ErrorVal))) 
fullScatterDS2 = fullScatterDS2 + geom_boxplot()
fullScatterDS2 <- fullScatterDS2 + geom_boxplot(outlier.colour = 'white') # outliers shown via jitter in a moment
fullScatterDS2 = fullScatterDS2 + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))
fullScatterDS2 = fullScatterDS2  + theme_bw()+ theme(text = element_text(size=20))

# raw data vis for drawSeries3 
fullScatterDS3 = ggplot(candleDatInDS3, aes(factor(candleCondition), ErrorVal))
fullScatterDS3 = fullScatterDS3 + geom_boxplot()
fullScatterDS3 <- fullScatterDS3 + geom_boxplot(outlier.colour = 'NA') # outliers shown via jitter in a moment
fullScatterDS3 = fullScatterDS3 + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))
fullScatterDS3 = fullScatterDS3  + theme_bw()+ theme(text = element_text(size=20))

# plot glyph learning 
fullScatterGL = ggplot(candleDatInGL, aes(factor(candleCondition), log(ErrorVal))) 
fullScatterGL = fullScatterGL + geom_boxplot()
fullScatterGL <- fullScatterGL + geom_boxplot(outlier.colour = NA) # outliers shown via jitter in a moment
fullScatterGL = fullScatterGL + geom_point(alpha = .075, size = 5, position = position_jitter(width = 0.1))

fullScatterGL2 = ggplot(candleDatInGL2, aes(factor(candleCondition), log(ErrorVal))) 
fullScatterGL2 = fullScatterGL2 + geom_boxplot()
fullScatterGL2 <- fullScatterGL2 + geom_boxplot(outlier.colour = NA) # outliers shown via jitter in a moment
fullScatterGL2 = fullScatterGL2 + geom_point(alpha = .075, size = 5, position = position_jitter(width = 0.1))

fullScatterGL3 = ggplot(candleDatInGL3, aes(factor(candleCondition), log(ErrorVal))) 
fullScatterGL3 = fullScatterGL3 + geom_boxplot()
fullScatterGL3 <- fullScatterGL3 + geom_boxplot(outlier.colour = NA) # outliers shown via jitter in a moment
fullScatterGL3 = fullScatterGL3 + geom_point(alpha = .075, size = 5, position = position_jitter(width = 0.1))

############################################################################
######################## between-experiment tests  #########################
############################################################################

# glyphLearning 2 differs from glyphLearning1 only in its inclusion of gridlines. Test overall.
alphaUsed = .05
gridLineTest = t.test(meansGL2$x, meansGL1$x)

# glyphLearning 2 differs from glyphLearning1 only in its inclusion of gridlines. Test conditions.
alphaUsed = .1/3

ttestGridLine1 = t.test(meansGL2$x[meansGL2$Group.2 == 1], meansGL1$x[meansGL1$Group.2 == 1])
ttestGridLine2 = t.test(meansGL2$x[meansGL2$Group.2 == 2], meansGL1$x[meansGL1$Group.2 == 2])
ttestGridLine3 = t.test(meansGL2$x[meansGL2$Group.2 == 3], meansGL1$x[meansGL1$Group.2 == 3])
# not enough data: ttestGridLine4 = t.test(meansGL2$x[meansGL2$Group.2 == 4], meansGL1$x[meansGL1$Group.2 == 4])

meansGL1Time = aggregate(candleDatInGL$ErrorVal, by = list(candleDatInGL$TrialID, candleDatInGL$candleCondition), FUN=mean, na.rm=TRUE)
meansGL2Time = aggregate(candleDatInGL2$ErrorVal, by = list(candleDatInGL2$TrialID, candleDatInGL2$candleCondition), FUN=mean, na.rm=TRUE)

lenGL1 = dim(meansGL1Time)
lenGL2 = dim(meansGL2Time)

expMarker = c(rep.int(1, lenGL1[1]), rep.int(2, lenGL2[1]))

plotDataIn = rbind(meansGL1Time, meansGL2Time)
plotDataIn2 = cbind(plotDataIn, expMarker)
plotDataIn2 = plotDataIn2[!plotDataIn2$Group.2 == 4,]

# create a scatter plot of mean scores on each trial by experiment 
p <- ggplot(plotDataIn2, aes(Group.1, x, expMarker, Group.2))
p = p + geom_point(col = plotDataIn2$expMarker)  
p = p + geom_line(data=as.data.frame(lowess(plotDataIn2$x[plotDataIn2$expMarker==1]~plotDataIn2$Group.1[plotDataIn2$expMarker==1])),aes(x,y),col=factor(plotDataIn2$expMarker[plotDataIn2$expMarker==1])) 
p = p + geom_line(data=as.data.frame(lowess(plotDataIn2$x[plotDataIn2$expMarker==2]~plotDataIn2$Group.1[plotDataIn2$expMarker==2])),aes(x,y),col=factor(plotDataIn2$expMarker[plotDataIn2$expMarker==2]))
