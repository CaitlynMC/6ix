function matrixToCandle(saveIt)
%  This turns a 6-D matrix into a candle stick plot
%
%  Author: Caitlyn McColeman
%  Date Created: June 12 2016
%  Last Edit: Revised Sept 4 2016 to take in VAR based data as input
%  instead of the saveIt work via generate6Data.m
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: Multi-dimensional data vis - project 6ix
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: A 5dimensional matrix
%
%  OUTPUT:
%
%  Additional Scripts Used:
%
%  Additional Comments:

if exist('modelout.mat')>1
    
    load('modelout.mat')
else
    modelout  = VARBasedDataGen;
end

fiveDimsOut = saveIt(76).sample;

% things that need input variables
meanVal = 80; % the y-intercept
bullBearInd = {'r', 'g'};

% create table from input matrix and variable titles.
candleTab = table(fiveDimsOut(:,1),fiveDimsOut(:,2),fiveDimsOut(:,3), fiveDimsOut(:,4), fiveDimsOut(:,5));

% take cell array as input to rearrange these
candleTab.Properties.VariableNames = {'openPr', 'closePr', 'highPr', 'lowPr', 'dayChange'};
sampList = rand(1,100);
sampList = round(sampList * 100);


figure;

% model:
% yInt for all vars = meanVal (B_0)
% B_1 = coefficient for days
% B_2 = coefficient for open
% B_3 = coefficient for close
% B_4 = coefficient for high
% B_5 = coefficient for low

for dayNum = 1:10
    
    
    sampNum = sampList(dayNum)
    
    if sampNum < 1 | sampNum > 100
        return
    end
    thisDayVal = meanVal + candleTab.dayChange(sampNum)*dayNum;
    
    if candleTab.openPr(sampNum)>candleTab.closePr(sampNum)
        candleColour = bullBearInd{1};
        candleLow = candleTab.closePr(sampNum);
        candleHigh = candleTab.openPr(sampNum);
    else
        candleColour = bullBearInd{2};
        candleLow = candleTab.openPr(sampNum);
        candleHigh = candleTab.closePr(sampNum);
    end
    
    openCloseRange = abs(candleTab.openPr(sampNum)-candleTab.closePr(sampNum));
    xlim([0 max(dayNum)+1])
    ylim([meanVal-.2*meanVal meanVal+.2*meanVal]) % arbitrary and needs a more prinicipled alternative.
    
    
    % candle stick: a line from low (yInt - min(open, close)) to high (yInt + max(open, close))
    %line('XData',[dayNum dayNum],'YData',thisDayVal-[candleLow-candleTab.lowPr(sampNum)*thisDayVal, candleHigh+candleTab.highPr(sampNum)*thisDayVal])
    line('XData',[dayNum dayNum],'YData',thisDayVal-[candleLow-5-candleTab.lowPr(sampNum), candleHigh+5+candleTab.highPr(sampNum)])
    
    
    rectangle('Position', [dayNum-.25, thisDayVal+min([candleTab.openPr(sampNum), candleTab.closePr(sampNum)]), .5, openCloseRange], ...
        'FaceColor', candleColour)
    
end