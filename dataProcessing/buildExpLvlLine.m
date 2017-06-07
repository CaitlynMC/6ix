%  Sometimes the candle experiments finished before the experiment level
%  data is written. This fixes that by taking the demographics responses and scanning the trial level
%  to get the info necessary to populate the condition and other explvl information.
%
%  Author: C. M. McColeman
%  Date Created: Jan 14 2017
%  Last Edit: May 29 2017 - a more robust extraction strategy for
%       information about candle cols
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: The directory containing the participants' data
%
%  OUTPUT: thisDudeOverview; a line (string) that can be appended to the candleExpLvl
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments: This assumes you have the directory containing the
%  raw data saved to your path. The data are on the 27" iMac powerhouse (by the door) and
%  the Caitlyn's laptop.
%

function buildExpLvlLine(participantDataDir, boothNum, rawExpLvl)

% use the demoBK & trial info to create a line for experiment level
load([participantDataDir '/demoBK/demoResps']) % gets the "survey" info
load(['~/documents/data/candles/allData/' num2str(boothNum) 'expLvlPresentation']); % contains a record of subject info; used for noise source
load(['~/documents/data/candles/allData/' num2str(boothNum) 'expLvlSetup'])


fileID = fopen([participantDataDir '/trialLvl.csv']);

trialLvlDat = textscan(fileID, ['%s %s %d %d %d %s ' ...
    '%s %s %f %f %f %f '... % candle colours, correct dimension answers
    '%f %f %f %f ' ... % participant dimension answers
    '%f %f %f %f %f ' ... % error value, trial phase onsets
    '%f %f %f %f '... % trial phase RTs
    '%d %d %s %f %s %s %s ' ...
    '%f %f %f %s'... %  cumulative time, candleX, open-close diff, end time as clock
    '%d %d %d %s %f\r\n'], 'Delimiter',';','HeaderLines', 1); % gets the trial info; 'EndOfLine', '\r\n',


% new variables won't be in the old expLvlPresentation.mat file. We'll hard
% code them to the middle value if they don't exist. If they do exist, then
% we'll use that value.
exist spreadFactor
if ~ans
    spreadFactor=1;
end
%   The format of experiment level data is:
%{
(1) ExpName;SubjectNumber;OpenColumn;CloseColumn;HighColumn;LowColumn;CloseLowColour;CloseHighColour;
 (9)  StartTimeClock;EndTimeClock;timeIDDir;Booth;ComputerType;Gender;ColourBlindStatus;EconExperience;MathExperience;ScreenXPixels;ScreenYPixels;NoisyDimension;TrialsCompleted;TotalPoints;ShadowColour
%}


% columns 1-6
ExpName = trialLvlDat{1,1}{1};
SubjectNumber = [trialLvlDat{1,2}{1} '_' num2str(boothNum)] ;
OpenColumn = trialLvlDat{1,28}{1}(2); % first number, second character
CloseColumn = trialLvlDat{1,28}{1}(4); % second number, fourth character
HighColumn = trialLvlDat{1,28}{1}(6); % second number, sixth character
LowColumn = trialLvlDat{1,28}{1}(8); % second number, eighth character

% strip strings to get the candle colours
potentialLowCols = strrep(trialLvlDat{1,8}, '[', ''); % correct colour
potentialLowCols = strrep(potentialLowCols, ']', '');
colOpts = unique(potentialLowCols);

% open-close
OCDiff = trialLvlDat{1,9}-trialLvlDat{1,10};

negIdx = OCDiff<0;
closeHigh = unique(potentialLowCols(negIdx));
closeLow = unique(potentialLowCols(~negIdx));

% go into the expLvlRec.mat file to pull out information for this participant
% the time-based identifier out of expLvlRec
arrayIn = expLvlRec(:,14);
% the time-based identifier out of participantDataDir
if numel(findstr(participantDataDir, '/'))>0
    [timeDir, nonMatching]=regexp(participantDataDir, '(?<=\/)(.*?)(?=\/)', 'match');
    timeDir = timeDir(2:end); % get rid of leading slash
else
    timeDir = participantDataDir;
end
findSubIdx = strcmpi(arrayIn, {timeDir}); % find subject number in exp lvl matching subject number in trial lvl

if sum(findSubIdx)==0; display(['No data for ' participantDataDir]);
    CloseLowColour = ''; CloseHighColour = ''; ShadowColour = '';
elseif sum(strcmpi(trialLvlDat{1,1}{1}, {'glyphLearning3', 'drawSeries2', 'drawSeries3'}))>0
    rowAdapter = mod(runThisRow,2)+1;
    display([ participantDataDir ': experiment level data updating.'])
    % These experiments had reduced conditions to A and D. Use adaptive
    % coding as per expLvlOrganizer
    
    if rowAdapter == 1
        CloseLowColour = ['[' mat2str([255 0 0]) ']'];
        CloseHighColour = ['[' mat2str([0 255 0]) ']'];
        
        bgGray = bkgCol{1}; % 44% black grey background
        ShadowColour = mat2str(shadowCondition{1}); % black shadows
    elseif rowAdapter == 2
        CloseLowColour = mat2str([191.25 191.25 191.25]);
        CloseHighColour = CloseLowColour;
        bgGray = bkgCol{4}; % 50% black grey background
        ShadowColour = mat2str(shadowCondition{4}); % yellow shadows
    end
else
    display([ participantDataDir 'experiment level data updating.'])
    % glyphLearning 1,2 and drawSeries1 had four conditions
    
    runThisRow = expLvlRec{findSubIdx, 10};
    j = 5; % the fifth row is "CandleColour" used by expLvlOrganizer to trigger this condition:
    
    % using information from experimentLvlPresentation.mat
    candleCol=candleCondition{expParameters(runThisRow,j)};
    CloseLowColour = mat2str(candleCol{1});
    CloseHighColour = mat2str(candleCol{2});
    bgGray = bkgCol{expParameters(runThisRow,j)};
    ShadowColour = mat2str(shadowCondition{expParameters(runThisRow,j)});
end
if ~(isempty(closeHigh)||isempty(closeLow))
    % column 7-19
    CloseLowColour = mat2str(closeLow{1});
    CloseHighColour = mat2str(closeHigh{1});
end


StartTimeClock = trialLvlDat{1,36}{1};
EndTimeClock = trialLvlDat{1,36}{length(trialLvlDat{1,36})};
timeIDDir = participantDataDir;
Booth = demoResp{1}; % from candleDemographics.m
ComputerType = demoResp{2};
Gender = demoResp{3};
ColourBlindStatus = demoResp{4};
EconExperience = demoResp{5};
MathExperience = demoResp{6};
screenXPixels = NaN;
screenYPixels = NaN;


% find noise source via expLvlPresentation.mat
for i=1:length(expLvlRec)
    subIdx(i) = strcmpi(expLvlRec{i,9}, trialLvlDat{1,2}{1});
    if subIdx(i) == 1
        thisSubRowID=i;
    end
end
if sum(subIdx)>0
    if strcmpi(expLvlRec{thisSubRowID,12}, 'drawSeries2') % noise only matters for drawSeries2
        % column 22
        NoisyDimension = expLvlRec{thisSubRowID,6}; %noise source is the sixth column
    else
        NoisyDimension = NaN;
    end
    runThisRow = expLvlRec{thisSubRowID, 10};
    shadColRow = expParameters(runThisRow,5);
    
    % establish the shadow colour via expParameters.mat and expLvlRec. Same
    % logic as in candleSaveTrialLvl.m
    ShadowColour = mat2str(shadowCondition{shadColRow,1});
else
    % column 22
    NoisyDimension = NaN;
    
end

TrialsCompleted = length(trialLvlDat{1,36});
TotalPoints = trialLvlDat{1,41}(length(trialLvlDat{1,41}));

fileID = fopen(rawExpLvl{1}, 'at'); % open file to append data

% add a row the explvl table
fprintf(fileID,['%s; %s; %s; %s; %s; %s; %s; %s; ' ...
    '%s; %s; %s; %d; %d; %d; %d; ' ...
    ' %d; %d; %d; %d; %d; %d; %f; %s\r\n'], ...
    ExpName, SubjectNumber, OpenColumn, CloseColumn, HighColumn, LowColumn, CloseLowColour, CloseHighColour,...
    StartTimeClock, EndTimeClock, timeIDDir, Booth, ComputerType, Gender, ColourBlindStatus, ...
    EconExperience, MathExperience, screenXPixels, screenYPixels, NoisyDimension, TrialsCompleted, TotalPoints, ShadowColour);

fclose(fileID)


