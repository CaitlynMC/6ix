# following http://www.r-bloggers.com/linear-mixed-models-in-r/

library(MASS)
data(oats)
colnames(oats)= c('block', 'variety', 'nitrogen', 'yield') # modified; names -> colnames
oats$mainplot = oats$variety
oats$subplot = oats$nitrogen

print(summary(oats))
library(nlme)
m1.nlme = lme(yield ~ variety*nitrogen,
              random = ~ 1|block/mainplot,
              data = oats)

summary(m1.nlme)


anova(m1.nlme)