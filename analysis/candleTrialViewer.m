function candleTrialViewer(sFullSubject, nTrialID, sTopLvlDataDir)
%  This will draw the stimulus that the specified participant saw on the
%  specified trial in one of the glyphLearning.m or drawSeries.m
%  experiments
%
%  Author: C. McColeman
%  Date Created: April 27 2017
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: []
%  Verified: []
%
%  INPUT:
%   sFullSubject, string; the full subject identifier in the form of
%           expLvlPresentationRowID_iteration_boothNumber
%   nTrialID, integer or vector of integers; specifies the trial we want to
%           draw out.
%   sToplvlDataDir, string: the name of where the data are stored. The data
%           structure is 'sTopLvlDataDir/Booth/data/' so for Caitlyn's
%           Macbook sTopLvlDataDir is '~/documents/data/candles/spring2017'
%
%  OUTPUT:
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments: You'll need to be on a computer with all of the raw
%  data stored on it. The PowerHouse (as of Apr 2017) has candle data backups; and
%  Caitlyn's Macbook has all of it too. Navigate to the data directory
%  before you run this function.

% call necessary data from SQL to get most of the information we need to
% draw the stimulus and feedback images


[sExpName, fullSubID, candleCondition, typedResponse, whichMod, storageDir, lengthXAxis, ... % stimulus
    corrOpen, corrClose, corrHigh, corrLow, ...% feedback
    respOpen, respClose, respHigh, respLow, stockTitle] = mysql(['select sExpName, fullSubID, candleCondition, typedResponse, whichMod, dirNameRec, xTent, ' ...
    'CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ' ...
    'participantAnswerOpen, participantAnswerClose, participantAnswerHigh, participantAnswerLow, stockTitle' ...
    ' FROM candlesTrialLvl where fullSubId = ''' sFullSubject '''']);

booth = fullSubID{1}(end);
topOfY = 1050;
conditionAsInt = str2num(candleCondition{1});

% these are exact same values as candleFrameStimuli.m used to draw axes
xCoords = [150 lengthXAxis(1) 150 150];
yCoords = [900 900 300 900]; yCoords = topOfY - yCoords; % flip to draw in MATLAB

if conditionAsInt == 1
    shadowCol = [0 0 0];
    bgCol = [.443 .443 .443];
elseif conditionAsInt == 3
    shadowCol = [0 0 0];
    bgCol = [.5 .5 .5];
else
    shadowCol = [0 0 0];
    bgCol = [.5 .5 .5];
end

frameCol = (bgCol*2);

% each trial has its own .mat file. Go directly to the trial(s) indicated
% by nTrialID
for i = nTrialID
    
    % get the name of the .mat file that contains raw data for this trial
    matName = [sTopLvlDataDir '/' booth '/' storageDir{1} '/trial' num2str(i) '.mat' ];
    
    if exist(matName) == 2 % "2" is the code to indicate that .mat file exists
        f1= figure('rend','painters','pos',[0 0 1680 1050]); % intialize visual space
        
        % gather data from the specified trial
        load(matName)
        
        % in glyphLearning experiments, there's only one icon. Find it. In
        % drawSeries.m this will trivially return everything.
        drawnBody = find(~(isnan(allRects(1,:))));
        
        if length(drawnBody) == 1
            shadowRects =  datShadow;
            highestPossible = highestYVal;
        end
        
        % because MATLAB's origin in bottom left, and Psyctoolbox's is top
        % left, allRects is upside down. Requires flipping. This is the line that flips
        allRects([2,4],:) = topOfY-allRects([2,4],:);
        shadowRects([2,4,6,8],:) = topOfY-shadowRects([2,4,6,8],:);
        
        % find lower and upper edge of candle body
        minY = min(allRects(2,:), allRects(4,:));
        maxY = max(allRects(2,:), allRects(4,:));
        
        % = Draw Frame
        xFrame = line([xCoords(1), xCoords(2)], [yCoords(1), yCoords(1)], 'Color', frameCol);
        yFrame = line([xCoords(1), xCoords(1)], [yCoords(1), yCoords(3)], 'Color', frameCol);
        
        % glyph learning experiments had ticks and labels for the y axis
        if length(drawnBody) == 1 % only one icon, so it must be a glyphLearning.m experiment
            tickDist = .5; % how different is each tick on the graph relative to the highest value?
            labelTick=linspace(max(yCoords), min(yCoords), 25); % evenly split the length of the y axis into 25
            tickMarker=[];
            
            % set label marker, lines
            for k = 1:length(labelTick)
                if mod(highestPossible-tickDist*k,1)==0 % label whole numbers
                    % x label (location values come from candleFrameStimuli.m and adapted for the bottom-left origin)
                    yLabelTickTxt = num2str(highestPossible-tickDist*k, 4);
                    text(xCoords(1)-30, labelTick(k), yLabelTickTxt, 'Color', frameCol)
                end
                
                if strcmpi(sExpName, 'glyphLearning2')
                    tickK= line([xCoords(1)-5, lengthXAxis(1)], [labelTick(k), labelTick(k)], 'Color', (bgCol + .2*bgCol));
                else
                    tickK= line([xCoords(1)-5, xCoords(1)+10], [labelTick(k), labelTick(k)], 'Color', frameCol);
                end
            end
        end
        % = Draw Stimulus
        for j = drawnBody
            if length(drawnBody) == 1
                shadLoc = 1;
                
            else
                shadLoc = j;
            end
            if conditionAsInt<3 % rectangular candle bodies; 1= red/green; 2= dark grey/light grey
                % draw rectangles
                % left         %right          % right        % left
                x = [allRects(1,j), allRects(3,j), allRects(3,j), allRects(1,j)];
                %low,    %low     %high    %high
                y = [minY(j), minY(j), maxY(j), maxY(j)];
                
                p1 = patch(x,y,'black', 'LineStyle', 'none', 'FaceColor', (colourOut(j,:)/255)); hold on;
            else
                % convert to triangle
                v= [allRects(1,j) minY(j); allRects(3,j) minY(j); mean([allRects(3,j), allRects(1,j)]) maxY(j)];
                f = [1 2 3];
                patch('Vertices', v, 'Faces', f, 'FaceColor', (colourOut(j,:)/255), 'LineStyle', 'none')
                
            end
            
            % == Draw Shadows
            
            % left, right, right, left
            xShadow = [shadowRects(1,shadLoc), shadowRects(3,shadLoc), shadowRects(3,shadLoc), shadowRects(1,shadLoc)];
            
            %bottom, bottom, top, top
            yHigh = [shadowRects(4,shadLoc), shadowRects(4,shadLoc), shadowRects(2,shadLoc), shadowRects(2,shadLoc)];
            yLow = [shadowRects(8,shadLoc), shadowRects(8,shadLoc), shadowRects(6,shadLoc), shadowRects(6,shadLoc)];
            
            pHigh = patch(xShadow,yHigh, shadowCol, 'LineStyle', 'none'); hold on;
            pLow = patch(xShadow,yLow, shadowCol, 'LineStyle', 'none'); hold on;
            
            
        end
        
        % = Setup image dimensions to represent the screen
        xlim([0 1680]) % default settings; confirm for iMacs and Macbook
        ylim([0 topOfY])
        
        % stock title (location values come from candleFrameStimuli.m and adapted for the bottom-left origin)
        x2 = lengthXAxis(1)/2;
        y2 = topOfY - .2*topOfY;
        txt2 = stockTitle{i};
        text(x2,y2,txt2,'Color',frameCol)
        
        % y label (location values come from candleFrameStimuli.m and adapted for the bottom-left origin)
        yLabX = xCoords(1)/4;
        yLabTxt = 'Price($)';
        text(yLabX,1050-600,yLabTxt,'Color',frameCol)
        
        % x label (location values come from candleFrameStimuli.m and adapted for the bottom-left origin)
        xLabY = min(yCoords)-20;
        xLabTxt = 'Time';
        text(x2,xLabY,xLabTxt,'Color',frameCol)
        
        % modify axes so there are no nonsense pixel labels and so the
        % background is an accurate representation of the stimuli
        figureAxis = gca;
        set(figureAxis,'Color',bgCol);
        figureAxis.XTick = []; figureAxis.YTick = []; figureAxis.Box = 'on';
        figureAxis.FontName = 'Courier New'; figureAxis.FontSize = 17;
        
    else
        display(['Cannot find ' matName '. Moving on.'])
        continue
    end
end