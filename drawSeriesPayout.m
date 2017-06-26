function [payOut, closeErrorBtwnDay]= drawSeriesPayout(endOfDayDiff, allRects, simulatedOCDiff, simulated100, bet)

%  While most 6ix experiments use candleErrorCalculator.m to determine the
%  points awarded on each trial, drawSeries4 requires a specific payoff
%  calculation based on the closing price. This function does exactly that:
%  calculate the points awarded based on closing price and the wager.
%  
%  Author: C. M. McColeman
%  Date Created: June 16 2017
%  Last Edit: 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: 6ix - drawSeries4
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: endOfDayDiff, double vector; the difference between open and close
%         bet, integer; the wager participants made on the close price
%                       being higher at time t
%         placementRects, double matrix; the information required to draw
%                       the candle. 
%  OUTPUT: [Insert Outputs of this script] 
%  
%  Additional Scripts Used: The input to this script a subset of the output
%                           for drawSeriesAsCandle.m.
%  
%  Additional Comments: Time "t0" is the last time point in the SERIES. 
%                       Time "t1" is the last time point in the STIMULUS.


if endOfDayDiff(99)>=0 % open-close, t0
    % close price is on the bottom
    ct1 = allRects(4,99);
else % close price is on the top
    ct1 = allRects(2,99);
end
    

if simulatedOCDiff>=0 % open-close, t1
    ct0 = simulated100(4);
else
    ct0 = simulated100(2);
end

closeErrorBtwnDay = ct1 - ct0;

payOut = (0.1*(bet)) * closeErrorBtwnDay;

if isnan(payOut); 
    payOut = 0; 
else
    payOut = round(payOut);
end