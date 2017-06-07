function [columnOrder, candleCol, noiseSource, bgGray, shadowCol, populateRow, subjectNumber, spreadFactor] = expLvlOrganizer(sExperiment)

%  This helps keep track of what's been run, what's left and provides
%  organized output to drawSeries.m, glyphLearning.m
%
%  Author: C. M. McColeman
%  Date Created: September 4 2016
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: sExperiment, the name of the experiment as a string
%
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments:

% keep track of what condition crossings we've run
load('expLvlSetup.mat'); spreadFactor=1;

if strcmpi(sExperiment, 'drawSeries') % noise on one channel, no yellow shadows on triangles
    % take the first one we haven't run yet.
    runThisRow = find(runOrder(:,2)==min(runOrder(:,2)),1);
    runOrder(runThisRow,2)=runOrder(runThisRow,2)+1; % record that we're going with this run and save the changes
elseif strcmpi(sExperiment, 'drawSeries2') % noise on one channel, no yellow shadows on triangles
    % take the first one we haven't run yet.
    runThisRow = find(runOrder(:,2)==min(runOrder(:,4)),1);
    runOrder(runThisRow,2)=runOrder(runThisRow,2)+1; % record that we're going with this run and save the changes
elseif strcmpi(sExperiment, 'drawSeries3') % manipulate the spread of the glyphs
    % take the first one we haven't run yet.
    runThisRow = find(runOrder(:,2)==min(runOrder(:,5)),1);
    runOrder(runThisRow,2)=runOrder(runThisRow,2)+1; % record that we're going with this run and save the changes
    
    % establish the spreadFactor
    possSpread = [.5, 1, 2];
    spreadFactor = possSpread(mod(runThisRow,3)+1);
    
elseif strcmpi(sExperiment, 'glyphLearning')|strcmpi(sExperiment, 'glyphLearning2')
    runThisRow = find(runOrder(:,3)==min(runOrder(:,3)),1);
    runOrder(runThisRow,3)=runOrder(runThisRow,3)+1; % record that we're going with this run and save the changes
elseif strcmpi(sExperiment, 'glyphLearning3') % manipulate the spread of the glyphs
    % take the first one we haven't run yet.
    runThisRow = find(runOrder(:,2)==min(runOrder(:,2)),1);
    runOrder(runThisRow,2)=runOrder(runThisRow,2)+1; % record that we're going with this run and save the changes
    
    % establish the spreadFactor
    possSpread = [.5, 1, 2];
    spreadFactor = possSpread(mod(runThisRow,3)+1);
   
end
save('expLvlSetup.mat', 'candleCondition', 'bkgCol', 'shadowCondition', 'noisyChannel', 'runOrder','spreadFactor')

% gather stimulus presentation information
load('expLvlPresentation.mat')
noiseSource=[];
% save explvl
populateRow = find(cellfun(@isempty, expLvlRec),1);
for j = 1:size(expParameters,2)
    expLvlRec{populateRow,j}=expParameters(runThisRow,j);
    if strcmpi(expLvlRec{1,j}, 'CandleColour') && (strcmpi(sExperiment,'drawSeries') || strcmpi(sExperiment,'glyphLearning') || strcmpi(sExperiment,'glyphLearning2'))

        candleCol=candleCondition{expParameters(runThisRow,j)};
        bgGray = bkgCol{expParameters(runThisRow,j)};
        shadowCol = shadowCondition{expParameters(runThisRow,j)};

    elseif strcmpi(expLvlRec{1,j}, 'CandleColour') && (strcmpi(sExperiment,'drawSeries2') || strcmpi(sExperiment,'drawSeries3') || strcmpi(sExperiment,'glyphLearning3')) % added March 3 2017
        
        rowAdapter = mod(runThisRow,2)+1;
        
        % coerce into subset of conditions: red/green candles or up/down
        % arrows with yellow shadows
        if rowAdapter == 1
            candleCol=candleCondition{1}; % red/green bodies
            bgGray = bkgCol{1}; % 44% black grey background
            shadowCol = shadowCondition{1}; % black shadows
        elseif rowAdapter == 2
            candleCol=candleCondition{4}; % grey bodies
            bgGray = bkgCol{4}; % 50% black grey background
            shadowCol = shadowCondition{4}; % yellow shadows
        end

    elseif strcmpi(expLvlRec{1,j}, 'NoiseSource')&&strcmpi(sExperiment,'drawSeries2')
        %noiseSource = noisyChannel(expParameters(runThisRow,j));
        noiseSource = expParameters(runThisRow,j); % simplied from above Feb 1 2017. Leave comment for posterity please.    
    elseif strcmpi(expLvlRec{1,j}, 'NoiseSource') && ...
            (strcmpi(sExperiment, 'drawSeries2') || strcmpi(sExperiment, 'drawSeries3') || strcmpi(sExperiment, 'glyphLearning3')) % added March 2 to constrain analysis up/down arrows and red/green rectangles 
        
    end
end

% the first digits of the subject number correspond to the row in
% expParamters. The rest of the number says how many times it's been run 
% on this machine.
subjectNumber = [num2str(runOrder(runThisRow,1)) '_' num2str(runOrder(runThisRow,2))];

expLvlRec{populateRow,j+1}=clock;
expLvlRec{populateRow,j+3}=subjectNumber;
expLvlRec{populateRow,j+4}=runOrder(runThisRow,1);

% identify machine
hostname = char(getHostName(java.net.InetAddress.getLocalHost ) );
ip = char(getHostAddress(java.net.InetAddress.getLocalHost ) );
expLvlRec{populateRow,j+5}=[hostname ip];
expLvlRec{populateRow,j+6}=sExperiment; % record experiment name.
expLvlRec{populateRow,j+9}=mat2str(shadowCol); % record shadow colour

save('expLvlPresentation.mat', 'expParameters', 'expLvlRec');

% which columns at trial level map on to which representations in the
% candle?
columnOrder = expParameters(runThisRow, 1:4); % open, close, high, low. (established in drawSeriesAsCandle.m)