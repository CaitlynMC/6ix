# requires output of groupError.R

ggplot(candleDatInDS)  +
  aes(x = candleDatInDS$TrialID, y = log(candleDatInDS$actualErrorVal), color = candleCondition) +
  #facet_wrap(~candleCondition) + 
  geom_point(color = "grey", alpha = 0.2) +
  geom_smooth(method = "loess", span = .3) +
  coord_cartesian(ylim = c(2, 7))

ggplot(candleDatInDS2)  +
  aes(x = candleDatInDS2$TrialID, y = log(candleDatInDS2$actualErrorVal), color = candleDatInDS2$noisyDimension) +
  facet_wrap(~candleCondition) + 
  geom_point(color = "grey", alpha = 0.2) +
  geom_smooth(method = "lm") +
  coord_cartesian(ylim = c(2, 7)) 

ggplot(candleDatInDS3)  +
  aes(x = candleDatInDS3$TrialID, y = log(candleDatInDS3$actualErrorVal), color = candleDatInDS3$spreadFactor) +
  facet_wrap(~candleCondition) + 
  geom_point(color = "grey", alpha = 0.2) +
  geom_smooth(method = "loess", span = 1) +
  coord_cartesian(ylim = c(2, 7)) 


ggplot(candleDatInGL)  +
  aes(x = candleDatInGL$TrialID, y = log(candleDatInGL$actualErrorVal)) +
  facet_wrap(~candleCondition) + 
  geom_point(color = "grey", alpha = 0.2) +
  geom_smooth(method = "loess", span = .3) +
  coord_cartesian(ylim = c(0, 4)) 

ggplot(candleDatInGL2)  +
  aes(x = candleDatInGL2$TrialID, y = log(candleDatInGL2$actualErrorVal)) +
  facet_wrap(~candleCondition) + 
  geom_point(color = "grey", alpha = 0.2) +
  geom_smooth(method = "loess", span = .3) +
  coord_cartesian(ylim = c(0, 4)) 

ggplot(candleDatInGL3)  +
  aes(x = candleDatInGL3$TrialID, y = log(candleDatInGL3$actualErrorVal), color = candleDatInGL3$spreadFactor) +
  facet_wrap(~candleCondition) + 
  geom_point(color = "grey", alpha = 0.2) +
  geom_smooth(method = "loess", span = 1) +
  coord_cartesian(ylim = c(0, 4)) 