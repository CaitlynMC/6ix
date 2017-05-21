%  Create a column to mark condition at trial level
%  
%  Author: Caitlyn McColeman
%  Date Created: March 16 2017
%  Last Edit: 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: 6ix
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: 
%  
%  OUTPUT: 
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: 

[nTrials, cumulPoints, candCond, expSubNum, rowID]=mysql(['select trialsCompleted, TotalPoints, candleCondition, subjectNumber, rowID from candlesExpLvl']);

% data to calculate error associated with each dimension
[corrOpen, corrClose, corrHigh, corrLow, ...
    respOpen, respClose, respHigh, respLow, subID, trID, errorVal] = mysql(['select ' ...
    'CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ' ...
    'ParticipantAnswerOpen, ParticipantAnswerClose, ParticipantAnswerHigh, ParticipantAnswerLow, ' ...
    'fullSubID, trialId, errorVal FROM candlesTrialLvl ']);

% extra space at the end of CloseHighColour. Get rid of it for easier
% string comparison
expSubNum = regexprep(expSubNum, '\W', '');

condAIdx = strcmpi(candCond, '1');
condBIdx = strcmpi(candCond, '2');
condCIdx = strcmpi(candCond, '3');
condDIdx = strcmpi(candCond, '4');

conditionRec = nan(length(corrOpen),1,1);

for i = 1:length(expSubNum) 
    thisSubIdx = strcmpi(subID,expSubNum{i});
    if sum(thisSubIdx)==0
        display(['cannot find ' expSubNum{i} ' in triallvl'])
    end
    conditionRec(thisSubIdx)=str2num(candCond{i});
end

% for the superprivileged user. This should only be run once.
%SQLAddColumn('candlesTrialLvl', 'candleCondition', conditionRec, 'VARCHAR(5)')