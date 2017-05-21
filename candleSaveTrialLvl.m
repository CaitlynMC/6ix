function candleSaveTrialLvl(timeIDDir, sExpName, subjectNumber, trialNumber, madeResponse, errorVal, defaultPlaceOrder, ...
    responseCandleCol, correctCandleCol, correctCandleBody, simulatedShadow, placementRects,...
    FixationOnset, StimulusOnset, ResponseOnset, FeedbackOnset, TrialOffset, trialOrder, whichMod, ...
    columnOrder,xTent, CumulativeParticipationTime, leftMost, endOfDayDiff, ...
    candleBodCol, upperShadCol, lowerShadCol, dataSample, clockEnd, responseBuffer, cumulativePoints)

%  Saves critical trial level information in a SQL-friendly format
%  candleSaveExpLvl(subjectID, columnOrder, candleCol, startTime, endTime, timeIDDir, demoResp, screenXpixels, screenYpixels, noiseSource, sExpName)
%  
%  Author: C. McC 
%  Date Created: [19/10/16] 
%  Last Edit: [23/10/16] last minute additions
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: 6ix - glyphLearning.m & drawSeries.m
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

arec=''; qrec='';
if ~isempty(dataSample{trialOrder(trialNumber),11}) % old matlab can't handle model info
    arec = mat2str(dataSample{trialOrder(trialNumber), 11}.AR{1}(:));
    arec=strrep(arec, ';', ','); % to allow for semi-colon separated data structures to parse correctly during upload
    qrec = mat2str(dataSample{trialOrder(trialNumber), 11}.Q(:));
    qrec=strrep(qrec, ';', ','); % to allow for semi-colon separated data structures to parse correctly during upload

end
    StockTitle = dataSample{trialOrder(trialNumber), 12};
    clockEndTime = mat2str(clockEnd);
% Trial columns for reference: 
%{
sExpName	Subject	TrialID	MadeResponse	WhichCandle	DefaultPlaceOrder	ResponseColour	CorrectColour	CorrectAnswerOpen	CorrectAnswerClose	CorrectAnswerHigh	CorrectAnswerLow	ParticipantAnswerOpen	ParticipantAnswerClose	ParticipantAnswerHigh	ParticipantAnswerLow	ErrorVal	FixationOnset	StimulusOnset	ResponseOnset	FeedbackOnset	Phase1RT	Phase2RT	Phase3RT	Phase4RT	TrialOrderIdx	whichMod	columnOrder	xTent	StockTitle	qrec	arrec	CumulativeParticipationTime
%}

whichCandle = defaultPlaceOrder(leftMost);
%% 1. Establish open and close price for response and for "correct" answer

% use the correct colour to index into the possible colours. First is open
% high. Second is close high. This matches candleBuildExpConds.
% participant response
if whichCandle % opened higher; "red" candle
    ParticipantAnswerOpen = placementRects(2, candleBodCol);
    ParticipantAnswerClose = placementRects(4, candleBodCol);
else  % closed higher; "green" candle
    ParticipantAnswerOpen = placementRects(4, candleBodCol);
    ParticipantAnswerClose = placementRects(2, candleBodCol);
end

% correct response 
if endOfDayDiff(end)>=0; % via drawSeriesAsCandle: endOfDayDiff = openPrices-closePrices.
    CorrectAnswerOpen = correctCandleBody(2);
    CorrectAnswerClose = correctCandleBody(4);
else endOfDayDiff(end)<0; % closes higher
    CorrectAnswerOpen = correctCandleBody(4);
    CorrectAnswerClose = correctCandleBody(2);
end

%% 2. Record high and low prices for response and for the "correct" answer
ParticipantAnswerHigh = placementRects(2, upperShadCol);
ParticipantAnswerLow = placementRects(4, lowerShadCol);

CorrectAnswerHigh = simulatedShadow(2);
CorrectAnswerLow = simulatedShadow(8);

correctCandleXPos = correctCandleBody(1);

%% 3. Check if the file exists
% if the file exists, open it
fileID = fopen([timeIDDir '/trialLvl.csv']);
if fileID == -1 % if the file doesn't exist, make a new one and add a header
    fileID = fopen([timeIDDir '/trialLvl.csv'], 'w+');
    fprintf(fileID, ...
        ['%s; %s; %s; %s; %s; %s; '... % sExpName	Subject	TrialID	MadeResponse	WhichCandle	DefaultPlaceOrder
        '%s; %s; %s; %s; %s; %s; ' ... %ResponseColour	CorrectColour	CorrectAnswerOpen	CorrectAnswerClose	CorrectAnswerHigh	CorrectAnswerLow
        '%s; %s; %s; %s; ' ... %ParticipantAnswerOpen	ParticipantAnswerClose	ParticipantAnswerHigh	ParticipantAnswerLow
        '%s; %s; %s; %s; %s;' ...%ErrorVal	FixationOnset	StimulusOnset	ResponseOnset	FeedbackOnset
        '%s; %s; %s; %s; ' ...%Phase1RT	Phase2RT	Phase3RT	Phase4RT
        '%s; %s; %s; %s; %s; %s; %s;' ...
        '%s; %s; %s; %s;' ... % cumulative time, candleX, open-close diff, end time as clock
        '%s; %s; %s; %s; %s\r\n'] ... % column records to recreate placementRects drawing
        , ... 
        'sExpName', 'Subject', 'TrialID', 'MadeResponse', 'WhichCandle', 'DefaultPlaceOrder', ...
        'ResponseColour', 'CorrectColour', 'CorrectAnswerOpen', 'CorrectAnswerClose', 'CorrectAnswerHigh', 'CorrectAnswerLow', ...
        'ParticipantAnswerOpen', 'ParticipantAnswerClose', 'ParticipantAnswerHigh', 'ParticipantAnswerLow',...
        'ErrorVal','FixationOnset','StimulusOnset','ResponseOnset','FeedbackOnset',...
        'Phase1RT', 'Phase2RT', 'Phase3RT', 'Phase4RT',...
        'TrialOrderIdx', 'whichMod', 'columnOrder', 'xTent','StockTitle','qrec','arrec',...
        'CumulativeParticipationTime', 'CandleXPosition', 'CorrectAnswerOCDiff', 'clockEndTime', ...
        'candleBodCol', 'upperShadCol', 'lowerShadCol', 'TypedResponse', 'CumulativePoints')
end
fclose(fileID)
fileID = fopen([timeIDDir '/trialLvl.csv'], 'at'); % open with append permission
%% 4. Save data
fprintf(fileID,['%s; %s; %d; %d; %d; %s; ' ... 
    '%s; %s; %f; %f; %f; %f; '... % candle colours, correct dimension answers
    '%f; %f; %f; %f; ' ... % participant dimension answers
    '%f; %f; %f; %f; %f; ' ... % error value, trial phase onsets
    '%f; %f; %f; %f; '... % trial phase RTs
    '%d; %d; %s; %f; %s; %s; %s; ' ...
    '%f; %f; %f; %s;'... %  cumulative time, candleX, open-close diff, end time as clock
    '%d; %d; %d; %s; %f\r\n'], ...' % column records to recreate placementRects drawing
    sExpName, subjectNumber, trialNumber, madeResponse, whichCandle, mat2str(defaultPlaceOrder), ...
    mat2str(responseCandleCol), mat2str(correctCandleCol), CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ...
    ParticipantAnswerOpen, ParticipantAnswerClose, ParticipantAnswerHigh, ParticipantAnswerLow, ...
    errorVal, FixationOnset, StimulusOnset, ResponseOnset, FeedbackOnset, ...
    StimulusOnset-FixationOnset, ResponseOnset-StimulusOnset, FeedbackOnset-ResponseOnset, TrialOffset-FeedbackOnset, ...
    trialOrder(trialNumber), whichMod(1), mat2str(columnOrder), xTent, StockTitle, qrec, arec, ...
    CumulativeParticipationTime, correctCandleXPos, endOfDayDiff(end), clockEndTime,...
    candleBodCol, upperShadCol, lowerShadCol, responseBuffer, cumulativePoints)
fclose(fileID)


