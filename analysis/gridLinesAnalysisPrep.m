%  Prepares data for analysis to compare gridlines vs. no grid lines in the
%  glyphLearning experiment; visualizes data
%  
%  Author: C. M. McColeman
%  Date Created: April 24 2017
%  Last Edit: 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: 6ix
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: None
%  
%  OUTPUT: [Insert Outputs of this script] 
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: 

MaybeOpenMySQL('experiments')

% gather data from SQL
[sExpName, corrOpen, corrClose, corrHigh, corrLow, ...
    respOpen, respClose, respHigh, respLow, subID, trID, errorVal, correctColour, candleCond, typedResponse] = mysql(['select ' ...
    'sExpName, CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ' ...
    'ParticipantAnswerOpen, ParticipantAnswerClose, ParticipantAnswerHigh, ParticipantAnswerLow, ' ...
    'fullSubID, trialId, errorVal, correctColour, candleCondition, typedResponse FROM candlesTrialLvl where sExpName LIKE ''glyphLearning%''']);


% collapse like-varibles into functional matrices
corrVals = [corrOpen, corrClose, corrHigh, corrLow];
responseVals = [respOpen, respClose, respHigh, respLow];

differenceRec = NaN(length(corrVals),4,1);
for i = 1:length(corrVals)
    
    responseErrorVec = abs(corrVals(i,:)-responseVals(i,:));
    % get the question ID (same order of presentation as glyphLearningResponse.m). 
    quIDRec(i)=find(max(responseErrorVec)==responseErrorVec);
    errorRec(i)=max(responseErrorVec);
    differenceRec(i,:) = responseErrorVec;
    
end