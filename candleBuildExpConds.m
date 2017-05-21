%  This is a record of all of the experiment level properties for the
%  candle completion series experiment. Run once per computer hosting this
%  experiment. Overwrite the trialLvlPresentation.mat file with a set one
%  if you want model-simulation consistency. 
%
%  Author: C. M. McColeman
%  Date Created: September 3 2016
%  Last Edit: October 12 2016
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix, extended to work for both drawSeries and
%  glyphLearning experiments. 
%
%  Reviewed: [Yue & Judi conditionally reviewed based on VAR is correct][September 25th 2016]
%  Verified: []
%
%  INPUT: NA
%
%  OUTPUT: NA
%
%  Additional Scripts Used: VARBasedDataGen.m
%
%  Additional Comments:
% assumes that you're running a recent (I'm guessing >2012 MATLAB?) with econ
% toolbox

%% experiment level

%1. which column maps to which candle component?
componentMapper = perms(1:4);

%2. red/green; light-grey/dark-grey candles? or light-grey triangles?
candleCondition = {{[1 0 0];[0 1 0]} {[.75 .75 .75];[.25 .25 .25];} {[.75 .75 .75];[.75 .75 .75]} {[.75 .75 .75];[.75 .75 .75]}} ;


% this has implications for the background colour because green and red are
% not equiluminant
lumnRed = rgb2gray([1 0 0]);
lumnGreen = rgb2gray([0 1 0]);

% adjusted gray for red/green; basic grey for black/white.
bkgCol = [{mean([lumnGreen; lumnRed])} {[.5 .5 .5]} {[.5 .5 .5]}  {[.5 .5 .5]} {[.5 .5 .5]}  {[.5 .5 .5]} {[.5 .5 .5]}];

%2b. grey or yellow shadows?
shadowCondition = {[0 0 0]; [.98 .98 .16]; [0 0 0]; [.98 .98 .16]};

%3. which channel is noised out (whisker or candle)?
noisyChannel = 1:4;

% subject row randomizer
runOrder = randsample(length(componentMapper)*4, length(componentMapper)*4);
runOrder = [runOrder zeros(length(runOrder),5)]; % where we record how often it's been run

save('expLvlSetup.mat', 'candleCondition', 'bkgCol', 'shadowCondition', 'noisyChannel', 'runOrder')

%% trial level
% There are models that will be used repeatedly for each subject in the
% experiment. We'll want them to feed through to the stimulus generator.

if exist('modelOut.mat')>0
    load('modelOut.mat')
else
    modelOut = VARBasedDataGen;
end

% nonsense stock names & simulated data from known model
possLetters = char(['A':'Z'])' ;
%rng(1) % set seed for reproducibility
%Y: This will output a 3 columns * 400 rows matrix within scale from 1 to 36
letterIdx = randi([1 36],[length(modelOut),3]); 
% random letters 
possibleName=[possLetters possLetters possLetters];
% Y: this will ouput (A:Z)*3 72 letters in a row BUT not some radom name 

% each stock name will act as a label for the model for each particular
% participant (the order of that's determined at experiment level)
for i = 1:length(letterIdx) % length of letterIdx is 4
    stockTitle{i,1} = possibleName(letterIdx(i,:)); % Y&J: this ouput 4 row of random name in form of 3 random letters "BZE" 
    
    % assuming the running computers don't have access to the VGX and econ
    % toolkit stuff, we'll generate the simulations in the stimulus presentation
    % phase on a machine that does. Prepare 10x each model.
    for j = 1:10
        dataSample{i, j}= vgxsim(modelOut{i}, 100);
    end
    % record the model from whence the data came
    dataSample{i, j+1}=modelOut{i};
    dataSample{i, j+2}=stockTitle{i,1}; % Y&J: this output a matrix in each row variable is matched to new name 
end

save('trialLvlPresentation.mat', 'dataSample')

% name:model pairing (random assignment)
stockNameIdx = randsample(length(modelOut),length(modelOut));
crossingList = fullfact([3 4]); % Y&J: this output a 3*6 matrix which represent all the conditions for this study

%% presented stims experiment lvl file
imgCondition = crossingList(:,1); %Y&J: crossingList = fullfact([3 2]); this line of code output the 1st column of crossingList
noiseCondition = crossingList(:,2); % this one output the 2nd

a=repmat(componentMapper,length(imgCondition),1); %open/close/high/low
b=repmat(imgCondition, length(a)/length(imgCondition), 1); % candle colours
c=repmat(noiseCondition, length(a)/length(imgCondition), 1); % noisy channel

% these are our critical six columns:
expParameters = [a b c];
% [1-4] map the output of VARBasedDataGen to open/close/high/low
% [5] is the image condition [green/red or black/white rectangles; or triangles]
% [6] is the noise condition [are we adding extra noise to a candle or a shadow?]

% this just a silly-big cell array to fill up as we run, which will be fine assuming we have <900 people on each computer.
expLvlRec = cell(900,10); 

% condition assignment; feature randomization
expLvlRec{1,1}='OpenColumn';
expLvlRec{1,2}='CloseColumn';
expLvlRec{1,3}='HighColumn';
expLvlRec{1,4}='LowColumn';
expLvlRec{1,5}='CandleColour';
expLvlRec{1,6}='NoiseSource'; 

% experiment level record keeping 
expLvlRec{1,7}='DateStart'; % filled in at the start of drawSeries.m or glyphLearning.m via expLvlOrganizer.m
expLvlRec{1,8}='DateEnd'; % filled in at the end of drawSeries.m or glyphLearning.m
expLvlRec{1,9}='Subject'; % filled in during expLvlOrganizer
expLvlRec{1,10}='ExpParametersRow'; % filled in during expLvlOrganizer
expLvlRec{1,11}='MachineInfo'; % filled in during expLvlOrganizer
expLvlRec{1,12}='ExperimentName'; % filled in during expLvlOrganizer - required because drawSeries.m and glyphLearning.m share this structure.

% update the expLvlPresentation .mat file as info necessary for the explvl
% file.
save('expLvlPresentation.mat', 'expParameters', 'expLvlRec', 'stockTitle')
