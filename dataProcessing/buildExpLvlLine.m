%  Sometimes the candle experiments finished before the experiment level
%  data is written. This fixes that by taking the demographics responses and scanning the trial level
%  to get the info necessary to populate the condition and other explvl information.
%
%  Author: C. M. McColeman
%  Date Created: Jan 14 2017
%  Last Edit:
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

if ~(isempty(closeHigh)||isempty(closeLow))
    % column 7-19
    CloseLowColour = ['[' num2str(str2num(closeLow{1})*255) ']'];
    CloseHighColour = ['[' num2str(str2num(closeHigh{1})*255) ']'];
else
    CloseLowColour = ''; CloseHighColour = '';
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
    runThisRow = NaN;
    shadColRow = NaN;
    ShadowColour = '';
end




TrialsCompleted = length(trialLvlDat{1,36});
TotalPoints = trialLvlDat{1,41}(length(trialLvlDat{1,41}));


%{
thisDudeOverview = table(ExpName, SubjectNumber, OpenColumn, CloseColumn, HighColumn, ...
    LowColumn, CloseLowColour, CloseHighColour, StartTimeClock, EndTimeClock, ...
    timeIDDir, Booth, ComputerType, Gender, ColourBlindStatus, ...
    EconExperience, MathExperience, ScreenXPixels, ScreenYPixels, NoisyDimension,...
    ScreenXPixels, ScreenYPixels, NoisyDimension, TrialsCompleted, TotalPoints, ...
    ShadowColour, spreadFactor);
%}

fileID = fopen(rawExpLvl{1}, 'at'); % open file to append data

% add a row the explvl table
fprintf(fileID,['%s , %s , %s , %s , %s , %s , %s, %s , ' ...
    '%s, %s, %s , %d, %d, %d, %d, ' ...
    ' %d, %d, %d, %d, %d, %d, %f, %s\r\n'], ...
    ExpName, SubjectNumber, OpenColumn, CloseColumn, HighColumn, LowColumn, CloseLowColour, CloseHighColour,...
    StartTimeClock, EndTimeClock, timeIDDir, Booth, ComputerType, Gender, ColourBlindStatus, ...
    EconExperience, MathExperience, screenXPixels, screenYPixels, NoisyDimension, TrialsCompleted, TotalPoints, ShadowColour);

fclose(fileID)

display('experiment level data updated..')

