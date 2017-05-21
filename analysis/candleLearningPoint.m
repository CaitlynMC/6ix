%  In the 6ix candle experiments, we rely on learning points to inform
%  analyses. This script will identify learning points.
%
%  Author: Caitlyn McColeman
%  Date Created: February 7 2017
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: sExperimentName; string - the name of the experimetn
%
%  OUTPUT: LP; int - the learning point
%
%  Additional Scripts Used:
%
%  Additional Comments:
%   context via the early draft of C.M. proposal
%{
The value for the learning criterion is data driven.
The median value of all responses, from all participants, across all dimensions for the last 15
trials of the experiment is the value that must be met or exceeded for six consecutive trials
to meet the learning criterion.

The learning point is the first of those six consecutive trials that achieve the criterion.
The four learning points represent four dimensions, but there are two qualitatively different
representations: the high/low shadows and the open/close candle body.
The analysis will be conducted instead on the average of the high/low learning points and the
average of the open/close learning points.
%}

sExpName= 'drawSeries'

% 1. Pull error value of overall trial from participants in this
% experiment (used to inform learning point)
[subjectID, errorVal, corrColour]=mysql(['select fullSubID, errorVal, correctColour from ' ...
    'CandlesTrialLvl where sExpName = ''' sExpName '''']);

uniqSub = unique(subjectID);
errorValDec = cellfun(@str2num, errorVal);


figure;
for i = 1:length(uniqSub)
    thisSubErr = errorValDec(strcmpi(uniqSub{i}, subjectID));
    thisSubCols = unique(corrColour(strcmpi(uniqSub{i}, subjectID)));
      
    nCols = size(thisSubCols);
    
    if nCols(1)==1
        conditionCol=[.5 .5 .5];
    else
        conditionCol=[0 1 0];
    end

    p1 = loglog(smooth(thisSubErr), 'linewidth', 1, 'color', conditionCol); hold on;
    p1.Color(4)=.2; %alpha for line
    
   % allErr = [allErr]
end


% 2. Pull error value from all participants associated with high/low and
% open/close dimensions.

switch sExpName
    case {'drawSeries', 'drawSeries2', 'drawSeries3'}
        
        % data to calculate error associated with each dimension
        [corrOpen, corrClose, corrHigh, corrLow, ...
         respOpen, respClose, respHigh, respLow, subID, trID, errorVal] = mysql(['select ' ...
         'CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ' ...
         'ParticipantAnswerOpen, ParticipantAnswerClose, ParticipantAnswerHigh, ParticipantAnswerLow, ' ...
         'fullSubID, trialId, errorVal FROM candlesTrialLvl where sExpName = ''' sExpName '''' ]);   
     
        % identify the maximum trial number (note: i'm already feeling like it's more appropriate to identify asymptote rather than always look at the last few trials ... 
        
        
        
    case {'glyphLearning', 'glyphLearning2', 'glyphLearning3'}
    otherwise
        display(['Error!' sExpName ' is not recognized. Check case in candleLearningPoint.m.'])
        return
end

uniqSub = unique(subID);

% initalize storage matrix 
errStore = nan(length(uniqSub), max(trialId), 4); % 4D matrix: one plane for each dimension

figure;
for i = 1:length(uniqSub)
    
    thisSubIdx = strcmpi(uniqSub,subID);
    
    % reformatting for participant-based analysis; correct responses
    corrOpenRec{i} = corrOpen(thisSubIdx);
    corrCloseRec{i} = corrClose(thisSubIdx);
    corrHighRec{i} = corrHigh(thisSubIdx);
    corrLowRec{i} = corrLow(thisSubIdx);
    
    % reformatting for participant-based analysis; ith participant's responses
    partOpenRec{i} = respOpen(thisSubIdx);
    partCloseRec{i} = respClose(thisSubIdx);
    partHighRec{i} = respHigh(thisSubIdx);
    partLowRec{i} = respLow(thisSubIdx);
    
    
end


errStore = 1;


