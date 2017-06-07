%  Using the information from candleExpLvl, identify the candle condition
%  properties
%  
%function conditionRecord = candleConditionIdentifier

%  Author: C. M. McColeman
%  Date Created: March 6 2017
%  Last Edit: June 6 2017 to pull in the spreadFactor variable
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: drawSeries, glyphLearning... 6ix experiment
%  series
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

MaybeOpenMySQL('experiments')

% 1. Pull candle colours, shadow colours from candlesExpLvl

[ShadowColour, CloseHighColour, CloseLowColour, subjId, timeIDDir, experimentName] = mysql(['select shadowColour, closeHighColour, closeLowColour, subjectnumber, timeIDDir, expName from candlesExpLvl']);
CloseHighColour2 = CloseHighColour;
% extra space at the end of CloseHighColour. Get rid of it for easier
% string comparison
CloseHighColour2 = regexprep(CloseHighColour2,'.$','');

arrowRec = strcmp(CloseHighColour2, CloseLowColour);
candleBodz(1:length(arrowRec),1) = arrowRec; % 1 means it's up/down candle bodies

% 2. loop to gather condition-necessary information

for i = 1:length(CloseHighColour)
   
    
    %% candle body condition
    % candle bodies 
    if numel(strfind(CloseHighColour{i},'1'))==1 || numel(strfind(CloseHighColour{i},'255'))==1
       candleBodyRec{i,1}='redGreen';
    elseif ((numel(strfind(CloseHighColour{i},'.75'))==3) & (numel(strfind(CloseLowColour{i},'.25')))==3)| ... % light/dark [0-1]
        ((numel(strfind(CloseHighColour{i},'191.25'))==3) & (numel(strfind(CloseLowColour{i},'63.75')))==3)| ... % light/dark [0-255]
        ((numel(strfind(CloseLowColour{i},'191.25'))==3) & (numel(strfind(CloseHighColour{i},'63.75')))==3)| ... % dark/light [0-1]
        ((numel(strfind(CloseLowColour{i},'191.25'))==3) & (numel(strfind(CloseHighColour{i},'63.75')))==3); % dark/light [0-255]
       candleBodyRec{i,1}='greyGrey';
    elseif arrowRec(i)==1
        candleBodyRec{i,1}='upDown';
    else
        candleBodyRec{i,1}='?';
    end
    
    
    % shadow colours
    if findstr('0.98', ShadowColour{i})
        shadowColRec{i,1} = 'yellow';
    elseif findstr('[0 0 0]', ShadowColour{i})
        shadowColRec{i,1} = 'black';
    else
        shadowColRec{i,1} = '?';
    end
    
    % crossing: candle bodies and shadow cols
    if strcmp(candleBodyRec{i,1}, 'redGreen') && strcmp(shadowColRec{i,1}, 'black')
        
        conditionRecord(i,1)='1'; % from proposal image where four conditions are shown up close
        
    elseif strcmp(candleBodyRec{i,1}, 'greyGrey') && strcmp(shadowColRec{i,1}, 'yellow')
        
        conditionRecord(i,1)='2'; 
        
    elseif strcmp(candleBodyRec{i,1}, 'upDown') && strcmp(shadowColRec{i,1}, 'black')
        
        conditionRecord(i,1)='3'; 
        
    elseif strcmp(candleBodyRec{i,1}, 'upDown') && strcmp(shadowColRec{i,1}, 'yellow')
        
        conditionRecord(i,1)='4'; 
    else
        
        conditionRecord(i,1)='0';
        
    end
    
    
    %% candle spread factor condition
    if strcmpi(strtrim(experimentName{i}), 'drawSeries3') | strcmpi(strtrim(experimentName{i}), 'glyphLearning3'); 
       
        % use the expLvlOrganizer.m strategy to reproduce the spreadFactor
        % assignment. 
        %1. everything before the first "_" in the subject number tells us
        %the run order. Extract run order that way. 
        splitOut = regexp(subjId{i}, '\_', 'split');
        rowIDRun = str2num(splitOut{1});
        
        % establish the spreadFactor
        possSpread = [.5, 1, 2];
        spreadFactIn = possSpread(mod(rowIDRun,3)+1);
        
        % assign to output vector
        spreadFactor(i,1)=spreadFactIn;
    else
        spreadFactor(i,1)=1;
        
    end
end
    

%requires superpriv access to upload data. Please do not delete this
%comment. 
%SQLAddColumn('candlesExpLvl', 'candleCondition', conditionRecord, 'VARCHAR(5)')
%SQLAddColumn('candlesExpLvl', 'spreadFactor', spreadFactor, 'VARCHAR(5)')

