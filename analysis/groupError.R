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
# 
#  Last edited June 26 to improve formatting/readability

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
candleDatIn = dbGetQuery(dbConn, 'select * from candlestriallvl') 
candleExpLvl = dbGetQuery(dbConn, 'select * from candlesexplvl')

############################################################################
############################# Data processing  #############################
############################################################################

candleDatIn$candleCondition <- factor(candleDatIn$candleCondition)

# collapse different nomenclatures (psychtoolbox vs matlab difference from computer types)
corrRed       = candleDatIn$CorrectColour == '[255 0 0]' | candleDatIn$CorrectColour == '[1 0 0]' 
corrGreen     = candleDatIn$CorrectColour == '[0 255 0]' | candleDatIn$CorrectColour == '[0 1 0]' 
corrLightGrey = candleDatIn$CorrectColour == '[191.25 191.25 191.25]' | candleDatIn$CorrectColour == '[.75 .75 .75]' 
corrDarkGrey  = candleDatIn$CorrectColour == '[63.75 63.75 63.75]' | candleDatIn$CorrectColour == '[.25 .25 .25]'

collapsedCorrCol = rep(NA, length(corrRed))

collapsedCorrCol[corrRed==T]       = 'Red'
collapsedCorrCol[corrGreen==T]     = 'Green'
collapsedCorrCol[corrLightGrey==T] = 'LightGrey'
collapsedCorrCol[corrDarkGrey==T]  = 'DarkGrey'

candleDatIn$TrialID        = as.numeric(candleDatIn$TrialID) # Lief: was it not numeric in SQL, or does the SQL call only import as text? # it's saved as strings in SQL
candleDatIn$actualErrorVal = as.numeric(candleDatIn$actualErrorVal)

# append updated colour column to dataframe
candleDatIn = cbind(candleDatIn, collapsedCorrCol)

# drop missing values
hasColInfo = candleDatIn[!is.na(collapsedCorrCol),] # missing candle colour information
hasColInfo = hasColInfo[!hasColInfo$candleCondition == 'NULL',] # missing candle condition information
hasColInfo = hasColInfo[!hasColInfo$candleCondition == '0',] # missing candle condition information

# Lief: I think i need more info about what each experiment was about, because I don't know how these data relate.
candleDatInDS  = hasColInfo[hasColInfo$sExpName == 'drawSeries',] # limit to drawSeries1 only
candleDatInDS2 = hasColInfo[hasColInfo$sExpName == 'drawSeries2' & # Lief: what are candleCondition 1 and 4? variable names may be in order. # it'd be a lot of characters to capture them properly and "1" and "4" are meaningful throughout the whole project.  -CM
                (hasColInfo$candleCondition == 1 | 
                 hasColInfo$candleCondition == 4),] # limit to drawSeries2 only (all noise condition)
candleDatInDS3 = hasColInfo[hasColInfo$sExpName == 'drawSeries3',] # limit to drawSeries3 only (spread conditions)

candleDatInGL  = hasColInfo[hasColInfo$sExpName == 'glyphLearning',] # limit to glyphLearning1 only
candleDatInGL2 = hasColInfo[hasColInfo$sExpName == 'glyphLearning2',] # limit to glyphLearning2 only (where everyone has grid lines)
candleDatInGL3 = hasColInfo[hasColInfo$sExpName == 'glyphLearning3',] # limit to glyphLearning2 only (all spread conditions)


############################# DrawSeries2
# intialize "noise dimension" vector for drawSeries2
noiseDimTemp = vector(mode = "integer", length = nrow(candleDatInDS2))

colIDs = cbind(candleExpLvl$OpenColumn, candleExpLvl$CloseColumn, candleExpLvl$HighColumn, candleExpLvl$LowColumn)
# repeat relevant experiment level information to trial lvl for analysis
for (i in candleExpLvl$timeIDDir) {

  # find instances of this timeIDDir at trial lvl
  iEdited=trimws(i) # lose trailing white space in expLvl timeIDDir recording
  matchCrossLvl=trimws(candleDatInDS2$dirNameRec) == iEdited

  # if that time directory exists at trial lvl too, it's the same person. # Lief was this comment accidentally copied from later in the script?
  if (sum(matchCrossLvl==TRUE, na.rm = T)>0) { # Lief: why would any elements be NA? You are expecting more than one occurence? If not, then you can ommit ">0"

    print(i)

    # repeat the noise condition as a vector marker
    noiseDimTemp[matchCrossLvl==TRUE]=candleExpLvl$NoisyDimension[candleExpLvl$timeIDDir == i] # Lief: I don't know R well enough to know what you did here.

  }  # / if
} # / loop
candleDatInDS2$noisyDimension = factor(noiseDimTemp) # append to data frame for analysis
candleDatInDS2$noisyDimension <- relevel(candleDatInDS2$noisyDimension, ref="4") # high dimension error is reference category
############################# DrawSeries3, GlyphLearning 3
# intialize spread factor marker for drawSeries3
spreadRec = vector(mode = "integer", length = nrow(candleDatInDS3))
spreadRecTemp = spreadRec # Lief: copied, but original never used again

# intialize spread factor marker for glyphLearning3
spreadRecTempGL = vector(mode = "integer", length = nrow(candleDatInGL3))

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
    spreadRecTemp[matchCrossLvlDS3==TRUE]=candleExpLvl$spreadFactor[candleExpLvl$timeIDDir == i] # Lief: I don't know R well enough to know what you did here.

  }  else if (sum(matchCrossLvlGL3==TRUE, na.rm = T)>0) { 
    print(i)

    # repeat the spread factor value as a vector marker
    spreadRecTempGL[matchCrossLvlGL3==TRUE]=candleExpLvl$spreadFactor[candleExpLvl$timeIDDir == i] # Lief: I don't know R well enough to know what you did here.

    }# / if
} # / loop

candleDatInDS3$spreadFactor = factor(spreadRecTemp) # append to data frame for analysis
candleDatInDS3 = candleDatInDS3[!candleDatInDS3$spreadFactor == '0',] # missing candle condition information
candleDatInDS3$spreadFactor <- relevel(candleDatInDS3$spreadFactor, ref="1") # baseline is reference category

candleDatInGL3$spreadFactor = factor(spreadRecTempGL) # append to data frame for analysis
candleDatInGL3$spreadFactor <- relevel(candleDatInGL3$spreadFactor, ref="1") # baseline is reference category

# format data and calculate by-subject means; keep a record of condition.
meansDS1 = aggregate(candleDatInDS$actualErrorVal,  by = list(candleDatInDS$dirNameRec,  candleDatInDS$candleCondition),  FUN=mean, na.rm=TRUE) # Lief: I need the rundown on what is happening here
meansDS2 = aggregate(candleDatInDS2$actualErrorVal, by = list(candleDatInDS2$dirNameRec, candleDatInDS2$candleCondition), FUN=mean, na.rm=TRUE)
meansDS3 = aggregate(candleDatInDS3$actualErrorVal, by = list(candleDatInDS3$dirNameRec, candleDatInDS3$candleCondition), FUN=mean, na.rm=TRUE)

meansGL1 = aggregate(candleDatInGL$actualErrorVal,  by = list(candleDatInGL$dirNameRec,  candleDatInGL$candleCondition),  FUN=mean, na.rm=TRUE)
meansGL2 = aggregate(candleDatInGL2$actualErrorVal, by = list(candleDatInGL2$dirNameRec, candleDatInGL2$candleCondition), FUN=mean, na.rm=TRUE)
meansGL3 = aggregate(candleDatInGL3$actualErrorVal, by = list(candleDatInGL3$dirNameRec, candleDatInGL3$candleCondition), FUN=mean, na.rm=TRUE)

# edit names to be meaningful in aggregate data formats
aggregateColNames = c("dirName", "Condition", "actualError")

names(meansDS1)<-aggregateColNames
names(meansDS2)<-aggregateColNames
names(meansDS3)<-aggregateColNames
names(meansGL1)<-aggregateColNames
names(meansGL2)<-aggregateColNames
names(meansGL3)<-aggregateColNames
############################################################################
############################### LMER models  ###############################
############################################################################

# run models
conditionModDS  <- lmer(log(actualErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInDS, REML = FALSE) # drawSeries1
conditionModDS2 <- lmer(log(actualErrorVal) ~ TrialID * candleCondition + noisyDimension + (TrialID | dirNameRec), candleDatInDS2, REML = FALSE) # drawSeries2
conditionModDS3 <- lmer(log(actualErrorVal) ~ TrialID * candleCondition * spreadFactor + (TrialID | dirNameRec), candleDatInDS3, REML = FALSE) # drawSeries3

conditionModGL  <- lmer(log(actualErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInGL, REML = FALSE) # glyphLearning1
conditionModGL2 <- lmer(log(actualErrorVal) ~ TrialID * candleCondition + (TrialID | dirNameRec), candleDatInGL2, REML = FALSE) # glyphLearning2
conditionModGL3 <- lmer(log(actualErrorVal) ~ TrialID * candleCondition * spreadFactor + (TrialID | dirNameRec), candleDatInGL3, REML = FALSE) # glyphLearning3

# extract LMER model coefficiencts into data frames for each experiment
coefsDS  <- data.frame(coef(summary(conditionModDS))) 
coefsDS2 <- data.frame(coef(summary(conditionModDS2))) 
coefsDS3 <- data.frame(coef(summary(conditionModDS3))) 

coefsGL  <- data.frame(coef(summary(conditionModGL)))
coefsGL2 <- data.frame(coef(summary(conditionModGL2)))
coefsGL3 <- data.frame(coef(summary(conditionModGL3)))

# calculate p value approximation (via Mirman: http://mindingthebrain.blogspot.ca/2014/02/three-ways-to-get-parameter-specific-p.html)
coefsDS$p.z  <- 2* (1-pnorm(abs(coefsDS$t.value))) 
coefsDS2$p.z <- 2* (1-pnorm(abs(coefsDS2$t.value))) 
coefsDS3$p.z <- 2* (1-pnorm(abs(coefsDS3$t.value)))

coefsGL$p.z  <- 2* (1-pnorm(abs(coefsGL$t.value)))
coefsGL2$p.z <- 2* (1-pnorm(abs(coefsGL2$t.value)))
coefsGL3$p.z <- 2* (1-pnorm(abs(coefsGL3$t.value)))

# perform post-hoc tests per experiment
conditionTest = glht(conditionModDS,linfct=mcp(candleCondition="Tukey"))
noiseTest     = glht(conditionModDS2,linfct=mcp(noisyDimension="Tukey"))
spreadTest    = glht(conditionModDS3,linfct=mcp(spreadFactor="Tukey"))

conditionTestGL     = glht(conditionModGL,linfct=mcp(candleCondition="Tukey"))
gridConditionTestGL = glht(conditionModGL2,linfct=mcp(candleCondition="Tukey"))
spreadTestGL        = glht(conditionModGL3,linfct=mcp(spreadFactor="Tukey"))


############################################################################
############################### ANOVA tests  ###############################
############################################################################

# run anova: trial ID and condition factors
fitDS  <- aov(actualErrorVal ~ TrialID * candleCondition, data = candleDatInDS) # drawSeries
fitDS2 <- aov(actualErrorVal ~ TrialID * candleCondition * noisyDimension, data = candleDatInDS2) # drawSeries2
fitDS3 <- aov(actualErrorVal ~ TrialID * candleCondition * spreadFactor, data = candleDatInDS3) # drawSeries3

fitGL  <- aov(actualErrorVal ~ TrialID * candleCondition, data = candleDatInGL) # glyphLearning
fitGL2 <- aov(actualErrorVal ~ TrialID * candleCondition, data = candleDatInGL2) # glyphLearning2

# adjust sum of squares to increase robustness to violation of assumption of homogeity of variances
drop1(fitDS,~.,test="F")  # drawSeries
drop1(fitDS2,~.,test="F") # drawSeries2
drop1(fitDS3,~.,test="F") # drawSeries3
drop1(fitGL,~.,test="F")  # glyphLearning
drop1(fitGL2,~.,test="F") # glyphLearning2

# post-hoc
tukeyDS2Condition = glht(fitDS2, linfct = mcp(candleCondition = "Tukey"), abseps=.05) # Lief: why is this test different? you are gathering additional data from it. Are these data used?
tukeyDS2Noise = glht(fitDS2, linfct = mcp(noisyDimension = "Tukey"), abseps=.05) # these tests are post hocs on drawSeries2 to see if there are differences between particular pairs of factors - CM


############################################################################
##################### visualize DV (performance error) #####################
############################################################################
# Lief: could also restructure this area.
# Lief: hardcoded sizes, widths, and alpha

# raw data vis for drawSeries
fullScatterDS = ggplot(candleDatInDS, aes(factor(candleCondition), log(actualErrorVal)))
fullScatterDS = fullScatterDS + geom_boxplot()
fullScatterDS <- fullScatterDS + geom_boxplot(outlier.colour = 'white') # outliers shown via jitter in a moment
fullScatterDS = fullScatterDS + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))
fullScatterDS = fullScatterDS  + theme_bw()+ theme(text = element_text(size=20))

# raw data vis for drawSeries2
fullScatterDS2 = ggplot(candleDatInDS2, aes(factor(candleCondition), log(actualErrorVal)))
fullScatterDS2 = fullScatterDS2 + geom_boxplot()
fullScatterDS2 <- fullScatterDS2 + geom_boxplot(outlier.colour = 'white') # outliers shown via jitter in a moment
fullScatterDS2 = fullScatterDS2 + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))
fullScatterDS2 = fullScatterDS2  + theme_bw()+ theme(text = element_text(size=20))

# raw data vis for drawSeries3
fullScatterDS3 = ggplot(candleDatInDS3, aes(factor(candleCondition), log(actualErrorVal)))
fullScatterDS3 = fullScatterDS3 + geom_boxplot()
fullScatterDS3 <- fullScatterDS3 + geom_boxplot(outlier.colour = NA) # outliers shown via jitter in a moment 
fullScatterDS3 = fullScatterDS3 + geom_point(alpha = .025, size = 1, position = position_jitter(width = 0.1))
fullScatterDS3 = fullScatterDS3  + theme_bw()+ theme(text = element_text(size=20))

# plot glyph learning
fullScatterGL = ggplot(candleDatInGL, aes(factor(candleCondition), log(actualErrorVal)))
fullScatterGL = fullScatterGL + geom_boxplot()
fullScatterGL <- fullScatterGL + geom_boxplot(outlier.colour = NA) # outliers shown via jitter in a moment
fullScatterGL = fullScatterGL + geom_point(alpha = .075, size = 5, position = position_jitter(width = 0.1))

fullScatterGL2 = ggplot(candleDatInGL2, aes(factor(candleCondition), log(actualErrorVal)))
fullScatterGL2 = fullScatterGL2 + geom_boxplot()
fullScatterGL2 <- fullScatterGL2 + geom_boxplot(outlier.colour = NA) # outliers shown via jitter in a moment
fullScatterGL2 = fullScatterGL2 + geom_point(alpha = .075, size = 5, position = position_jitter(width = 0.1))

fullScatterGL3 = ggplot(candleDatInGL3, aes(factor(candleCondition), log(actualErrorVal)))
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

# Lief: hardcoded group numbers, what do they mean? These are condition labels. -CM
ttestGridLine1 = t.test(meansGL2$actualError[meansGL2$Condition == 1], meansGL1$actualError[meansGL1$Condition == 1])
ttestGridLine2 = t.test(meansGL2$actualError[meansGL2$Condition == 2], meansGL1$actualError[meansGL1$Condition == 2])
ttestGridLine3 = t.test(meansGL2$actualError[meansGL2$Condition == 3], meansGL1$actualError[meansGL1$Condition == 3])

meansGL1Time = aggregate(candleDatInGL$actualErrorVal, by = list(candleDatInGL$TrialID, candleDatInGL$candleCondition), FUN=mean, na.rm=TRUE)
meansGL2Time = aggregate(candleDatInGL2$actualErrorVal, by = list(candleDatInGL2$TrialID, candleDatInGL2$candleCondition), FUN=mean, na.rm=TRUE)

lenGL1 = dim(meansGL1Time)
lenGL2 = dim(meansGL2Time)

expMarker = c(rep.int(1, lenGL1[1]), rep.int(2, lenGL2[1])) # Lief: I might do the indexing during the assignment above, rather than mid function call, as the other dimension never gets used. It's specifically for this plot. I think I'd be confused if all of this was much earlier. CM

plotDataIn = rbind(meansGL1Time, meansGL2Time) # Lief: plotDataIn never used again, maybe plotDataIn2 could just be renamed?
plotDataIn2 = cbind(plotDataIn, expMarker)
plotDataIn2 = plotDataIn2[!plotDataIn2$Group.2 == 4,] # Lief: hardcoded

# create a scatter plot of mean scores on each trial by experiment
p <- ggplot(plotDataIn2, aes(Group.1, x, expMarker, Group.2))
p = p + geom_point(col = plotDataIn2$expMarker)
p = p + geom_line(data=as.data.frame(lowess(plotDataIn2$x[plotDataIn2$expMarker==1]~plotDataIn2$Group.1[plotDataIn2$expMarker==1])),aes(x,y),col=factor(plotDataIn2$expMarker[plotDataIn2$expMarker==1])) # Lief: code lost trying to follows these ones...
p = p + geom_line(data=as.data.frame(lowess(plotDataIn2$x[plotDataIn2$expMarker==2]~plotDataIn2$Group.1[plotDataIn2$expMarker==2])),aes(x,y),col=factor(plotDataIn2$expMarker[plotDataIn2$expMarker==2]))


