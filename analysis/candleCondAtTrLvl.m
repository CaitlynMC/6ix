%  Create a column to mark condition at trial level
%  
%  Author: Caitlyn McColeman
%  Date Created: March 16 2017
%  Last Edit: May 30 2017, including rowID as determining factor for upload
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
    respOpen, respClose, respHigh, respLow, subID, trID, errorVal, rowID] = mysql(['select ' ...
    'CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ' ...
    'ParticipantAnswerOpen, ParticipantAnswerClose, ParticipantAnswerHigh, ParticipantAnswerLow, ' ...
    'fullSubID, trialId, errorVal, rowID FROM candlesTrialLvl ']);

% extra space at the end of CloseHighColour. Get rid of it for easier
% string comparison
expSubNum = regexprep(expSubNum, '\W', '');

condAIdx = strcmpi(candCond, '1');
condBIdx = strcmpi(candCond, '2');
condCIdx = strcmpi(candCond, '3');
condDIdx = strcmpi(candCond, '4');

conditionRec = nan(length(corrOpen),1,1);
rowRec = nan(length(corrOpen),1,1);

for i = 1:length(expSubNum) 
    thisSubIdx = strcmpi(subID,expSubNum{i});
    if sum(thisSubIdx)==0
        display(['cannot find ' expSubNum{i} ' in triallvl'])
    end
    conditionRec(thisSubIdx)=str2num(candCond{i});
    rowRec(thisSubIdx) = rowID(thisSubIdx);
end

% for the superprivileged user. This should only be run once.
%{

mysql(['alter table candlesTrialLvl add candleCondition VARCHAR(5)']);

updatedRows = rowRec(~isnan(rowRec));
updatedCondition = conditionRec(~isnan(rowRec));

for i=1:length(updatedRows)
    mysql(['update candlesTrialLvl set candleCondition = ' num2str(updatedCondition(i)) ' where RowID = ' num2str(updatedRows(i))]);
end


%}
