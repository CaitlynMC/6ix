function [ ...
    nextRect, ...
    YLabVals ...
    ]= candleFrameStimuli( ...
    xTent,  ...
    screenXpixels,  ...
    screenYpixels,  ...
    bkgnCol,  ...
    allCoords,  ...
    trialNumber,  ...
    dataSample,  ...
    placeHolder,  ...
    windowPtr,  ...
    trialPhase,  ...
    highestPossible,  ...
    textCol, ...
    spreadFactor)
%  Draws the outline of the stimuli: the graph axes, playground, etc
%
%  Author: C. M. McColeman
%  Date Created: September 11 2016
%  Last Edit: September 22 2016
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: [Cal cwoodruf@sfu.ca 2016-09-25]
%  Verified: []
%
%  INPUT:
%           xTent,  maximum x for viewport
%           screenXpixels,  actual screen width
%           screenYpixels,  actual screen height
%           bkgnCol,  vector of background colors only bkgnCol(1) used
%           allCoords,  x and y coordinates for graph box
%           trialOrder,  which prices to present out of dataSample
%           dataSample, all prices for all trials
%           placeHolder,  data structure for participant response
%           windowPtr,  handle to window from psyctoolbox
%           trialPhase,  each trial involves multiple steps, this is the step we are on
%           highestPossible,  highest price on Y axis
%           textCol color of text
%
%  OUTPUT:
%          nextRect, the rectangle for the "Next" button on the screen
%          YLabVals, the values for the y axis labels (prices) for the glyph exp
%          The main effect of this function is to modify the screen by drawing the box
%          for the graph for a given trial
%
%  Additional Scripts Used:
%          psychtoolbox functions:
%               DrawFormattedText
%               Screen - actually render something: DrawText, DrawLines, FrameRect
%
%
%  Additional Comments: Requires most of the output from
%  drawSeriesAsCandle.m

YLabVals = NaN; % used in the glyph learning study to provide axis information

playGroundCentX = xTent+(screenXpixels-50-xTent+125)/2;

% added since review - calculating nextRect via bounding box for the text
[nx, ny, nextRect]=DrawFormattedText(windowPtr, 'Next', playGroundCentX, .75*screenYpixels, textCol, bkgnCol(1));
nextRect = nextRect + [-5 -5 5 5] ;% add a 5 px. visual buffer
% Cal: the "next" button to move between trialPhases
Screen('FrameRect', windowPtr, repmat(bkgnCol(1)*2,1,3), nextRect, 2);
instructionText = 'Select one item to \ncomplete the pattern.';

if trialPhase>1
    % chart axes
    Screen('DrawLines', windowPtr, allCoords, 2, textCol)
    % stock title
    if ~strcmpi('double',class(dataSample{1,size(dataSample,2)}))
        Screen('DrawText', windowPtr, dataSample{trialNumber,size(dataSample,2)}, xTent/2, .2*screenYpixels, textCol, bkgnCol(1));
    end
    % chart labels
    priceLab = sprintf('Price ($)');
    Screen('DrawText', windowPtr, priceLab, allCoords(1,1)/4, 600, textCol, bkgnCol(1));
    Screen('DrawText', windowPtr, 'Time', xTent/2, max(allCoords(2,:))+20, textCol, bkgnCol(1));
end

if trialPhase == 3
    % instruction label for playground
    DrawFormattedText(windowPtr, sprintf(instructionText), xTent+75, min(allCoords(2,:)), textCol);
    % playground
    Screen('FrameRect', windowPtr, textCol, [xTent+125, 400, screenXpixels-50, 700], 2);
    % response location indicator
    Screen('FrameRect', windowPtr, textCol, placeHolder, 2);
end

if trialPhase==4
    Screen('FrameRect', windowPtr, textCol, placeHolder, 2);
    
end

if trialPhase == 101 % this detailed condition is for the glyph learning experiment. "101" in the introductory sense. Marks and labels ticks on the Y axis.
    tickDist = .5; % how different is each tick on the graph relative to the highest value?
    labelTick=linspace(allCoords(2,3), allCoords(2,2), 25); % evenly split the length of the y axis into 25
    tickMarker=[];
    
    % set label marker, lines
    for i = 1:length(labelTick)
       % if mod(highestPossible*spreadFactor-spreadFactor*tickDist*i,1)==0 % label whole numbers
        if mod(highestPossible-tickDist*i,1)==0 % label whole numbers
            DrawFormattedText(windowPtr, num2str(highestPossible-tickDist*i, 4), allCoords(1,1)-30, labelTick(i)-5, textCol, bkgnCol(1));
        end
        tickMarker = [tickMarker [allCoords(1,1)-5 allCoords(1,1)+10; labelTick(i) labelTick(i)]];
    end
    
    Screen('DrawLines', windowPtr, tickMarker, 2, textCol);
    YLabVals= labelTick;
else
    
end
