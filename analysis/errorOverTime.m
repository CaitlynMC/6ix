function [openBinned, closeBinned, highBinned, lowBinned]=errorOverTime(sExpName, candleCondition)
%  extracts binned error for each of open, close, high, low
%  
%  Author: Caitlyn McColeman
%  Date Created: May 26 2017
%  Last Edit: [March 27 2017] 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: [Insert Name of Project] 
%  
%  Reviewed: [Judi Azmand] 
%  Verified: [Robin C. A. Barrett] 
%  
%  INPUT: [Insert Function Inputs here (if any)] 
%  
%  OUTPUT: [Insert Outputs of this script] 
%  
%  Additional Scripts Used: [Insert all scripts called on] 
%  
%  Additional Comments: 


MaybeOpenMySQL('experiments')

[corrOpen, corrClose, corrHigh, corrLow, ...
    respOpen, respClose, respHigh, respLow, subID, trID, errorVal, correctColour, candleCond] = mysql(['select ' ...
    'CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ' ...
    'ParticipantAnswerOpen, ParticipantAnswerClose, ParticipantAnswerHigh, ParticipantAnswerLow, ' ...
    'fullSubID, trialId, errorVal, correctColour, candleCondition FROM candlesTrialLvl where sExpName = ''' sExpName '''' ' AND candleCondition = ' candleCondition]);

% error is the difference between the correct answer and the actual answer
openErr = abs(corrOpen-respOpen);
closeErr = abs(corrClose-respClose);
highErr = abs(corrHigh-respHigh);
lowErr = abs(corrLow-respLow);

if findstr('drawSeries', sExpName)
    edgeVals = 10:25:200; % bins of 25. (200 trials in drawSeries) %% There are only 199 trials -RCAB
elseif findstr('glyphLearning', sExpName)
    edgeVals = 5:5:40; % bins of 5 (40 trials in glyphLearning)
end

% intialize storage matrices as nans 
openBinned = nan(length(trID),length(edgeVals),1);
closeBinned = openBinned;
highBinned = openBinned;
lowBinned = openBinned;
% conditionRecord = cell(length(trID),length(edgeVals),1); %% Does not seem
% to be used l8r -RCAB

trialBinIdx = nan(length(trID),1,1);

% loop through each edge value to detect whether the trial ID is between it
% and the edge value before. This will return bins
for i = 1:length(edgeVals)
    % create a binned version
    trialBinIdx(isnan(trialBinIdx) & trID<edgeVals(i)) = i;
    
    % in the storage matrices, save the error value corresponding to the
    % ith 
    openBinned(1:sum(trialBinIdx==i),i)=openErr(trialBinIdx==i);
    closeBinned(1:sum(trialBinIdx==i),i)=closeErr(trialBinIdx==i);
    highBinned(1:sum(trialBinIdx==i),i)=highErr(trialBinIdx==i);
    lowBinned(1:sum(trialBinIdx==i),i)=lowErr(trialBinIdx==i);
   
   % 0 error values in response means that it wasn't the queried question. Remove.  
    if findstr('glyphLearning', sExpName)
        openBinned(openBinned(:,i)==0)=NaN;
        closeBinned(openBinned(:,i)==0)=NaN;
        highBinned(openBinned(:,i)==0)=NaN;
        lowBinned(openBinned(:,i)==0)=NaN;
    end
end

% added after review: visualizing error to justify log transformation
figure;
errFig = histogram(errorVal)

display(['mean error for ' candleCondition ' is ' num2str(mean(errorVal)) ' +/- ' num2str(sem(errorVal)) '. Median is ' num2str(median(errorVal))])
errFig.FaceColor = [0 0 0];
errFig.BinWidth = 25;

xlim([0 2500])
ylim([0 600])
xlabel('User Performance Error')
ylabel('Number of Trials')
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'XGrid', 'on')
title(['Error value for each trial in Condition ' candleCondition])

% saveas(gcf, ['~/pictures/6ixtures-eachTrialError_' candleCondition], 'epsc')
