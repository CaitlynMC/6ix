function instructionTroubles = candleExperimentInstructions(screenXpixels, screenYpixels, windowPtr, bkgnCol, foreGrndL, foreGrndD, xTent, upKey, downKey, leftKey, rightKey, plusKey, minusKey, enterKey, fKey, rKey, vKey, aKey, candleCol, shadowCol,allCoords);

%  Here are instructions for the candle experiment. They're in a seperate
%  function to keep the code from getting to unwieldy, but some of it can
%  be reused for the glyph experiment.
%
%  Author: C. M. McColeman
%  Date Created: September 14 2016
%  Last Edit: October 3 2016
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix candle learning
%
%  Reviewed: [Cal cwoodruf@sfu.ca 2016-09-26 some comments fixed issue with the try out screen being stuck]
% Totally re-written in response to UI changes that we need to train people to use. Requires re-review.
%  Re-reviewed: []
%  Verified: []
%
%  INPUT: [Insert Function Inputs here (if any)]
%
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: candleInstructionSupport (still unreviewed)
%
%  Additional Comments:

% coerce input option to the external keyboad if there are multiple
% options (if you're on the macbook)
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
kbPointer = keyboardIndices(end);

instructionTextCell{1,1} = {'Welcome to the experiment! Thank you for helping us understand human cognition.'};
instructionTextCell{1,2} = {'Today, you will learn how to see patterns in a graph.'};
instructionTextCell{1,3} = {'It''s okay if you are not a math person. \n You do not need to know any math or much about graphs.'};
instructionTextCell{1,4} = {'We are interested to see how people learn how to use them.'};
instructionTextCell{2,1} = {'You will see a lot of graphs, and your job is to fill in the blanks at the end of each.'};
instructionTextCell{2,2} = {'The graphs represent the open, close, high and low prices from pretend financial information.'};
instructionTextCell{2,3} = {'Over time, you will get a bit better at filling in the blanks.'};
instructionTextCell{2,4} = {'Please be patient, and gather information through trial and error to improve your responses.'};
instructionTextCell{2,5} = {'It''s possible to get up to 500 points per trial. Try each time to get as many points as you can!'};
instructionTextCell{3,1} = {'So, how does this work? You will see an image, and you''ll have time to study it. \n When you are ready to guess what comes next, use the mouse to click "next".'}; % sample image
instructionTextCell{4,1} = {'The first image will go away and you will be shown some items \n you can select to complete the pattern from the first image.'}; % sample adjustable features
instructionTextCell{5,1} = {'If you want to move the item up or down to complete the pattern, press "up" or "down".'}; % highlight
instructionTextCell{6,1} = {'If you want to make just the middle bit bigger or smaller, hold "f" and press "up" or "down".'}; % highlight
instructionTextCell{7,1} = {'If you want to make just the top bit bigger or smaller, hold "r" and press "up" or "down".'}; % highlight
instructionTextCell{8,1} = {'If you want to make just the bottom bit bigger or smaller, hold "v" and press "up" or "down".'}; % highlight
instructionTextCell{9,1} = {'Good work! This will get easier as you get more practice.'}; %
instructionTextCell{10,1} = {'If you want to start over again, click the other object or right click your selection.'}; %
instructionTextCell{10,2} = {'Your goal is to select an item and adjust it to complete the pattern to the best of your ability.'}; %
instructionTextCell{11,1} = {'If you have any questions right now, please open the door behind you so the experimenter can help.'}; %
instructionTextCell{12,2} = {'Otherwise, we will get started. Thank you again for helping with this study.'}; %
instructionTextCell{13,3} = {'It is okay to make mistakes -- that is part of learning. \n Please continue to try your best and improve over time.'}; %

instructionTroubles= 0;

footerText = 'Click "next" to continue.';

standardKeyboard=imread('macKeyboard.jpeg', 'jpg');
expandObject=imread('macAddSubtract.jpeg', 'jpg');
moveObject=imread('macUpDown.jpeg', 'jpg');
useKeyboardIm =  imread('unMarkedKB.jpeg', 'jpg');
moveWholeIm =  imread('moveWholeUnit.jpeg', 'jpg');
adjWholeIm = imread('adjustWholeUnit.jpeg', 'jpg');
adjCandleBod = imread('adjustCandleBody.jpeg', 'jpg');
adjUpperShad = imread('adjustTopShadow.jpeg', 'jpg');
adjLowerShad = imread('adjustBottomShadow.jpeg', 'jpg');

tex(1) = Screen('MakeTexture', windowPtr, standardKeyboard);
tex(2) = Screen('MakeTexture', windowPtr, moveObject);
tex(3) = Screen('MakeTexture', windowPtr, expandObject);
tex(4) = Screen('MakeTexture', windowPtr, useKeyboardIm);
tex(5) = Screen('MakeTexture', windowPtr, moveWholeIm);
tex(6) = Screen('MakeTexture', windowPtr, adjWholeIm);
tex(7) = Screen('MakeTexture', windowPtr, adjCandleBod);
tex(8) = Screen('MakeTexture', windowPtr, adjUpperShad);
tex(9) = Screen('MakeTexture', windowPtr, adjLowerShad);

SetMouse(screenXpixels/2, screenYpixels/2, windowPtr);
yLoc = .2*screenYpixels;

sampleData= ones(100, 4)+(rand(100,4)-.5);
% sampleData(:,2) = randi([0 2],1,100); doesn't work on old imac
for i=1:length(sampleData)
    sampleData(i,2) = 1+round(rand);
end
updateXVal=0; glyphSelect = [0 0];
% if the candle colours are the same, then we're in the up/down triangle
% condition.
if sum(candleCol{1}==candleCol{2})==3
    triCandleFlag = 1;
else
    triCandleFlag = 0;
end

% show sample stimulus
[allRects, shadowRects, colourOut, placementRects, placeHolder, simulated100, simulatedCol, simulatedShadow, endOfDayDiff, simulatedOCDiff]=...
    drawSeriesAsCandle(screenXpixels, screenYpixels, sampleData, 1:4, [], candleCol, xTent, [], allCoords, 1);
placementRectsOriginal = placementRects;

for i = 1:length(instructionTextCell)
    
    for j = find(~cellfun(@isempty,instructionTextCell(i,:)))
        isInNext = 0;
        while isInNext==0;
            
            % listen for click on "next" button
            [ keyIsDown, timeSecs, keyCode ] = KbCheck(kbPointer);
            
            display(find(keyCode))
            
            % get mouse coordinates, button selection
            [mx, my, buttons] = GetMouse(windowPtr);
            % draw mouse cursor
            Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
            
            % draw the next button
            [nextRect, YLabVals]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, 0, 0, 0, 0, windowPtr, 0, 0, foreGrndL);
            
            % identify location relative to next button
            nextSelected = IsInRect(mx, my, nextRect);
            
            % if the button's pressed, trigger the escape for the while loop
            if  nextSelected && sum(buttons(1))>0;
                isInNext = 1;
                % big button to show selection
                pause(.25)
                Screen('DrawDots', windowPtr, [mx my], 10, foreGrndL, [], 2);
            else
                isInNext = 0;
            end
            
            % special instructions that require images
            if i == 3 % So, how does this work? You will see an image, and you ll have time to study it
                
                DrawFormattedText(windowPtr, instructionTextCell{i,j}{1}, 'center', yLoc, foreGrndL);
                
                candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 2, 0, foreGrndL);
                % draw stimulus
                if triCandleFlag
                    % convert placement rectangles to triangles
                    rect2TriCandle(allRects, placementRects, endOfDayDiff, candleCol, [], windowPtr,0);
                else
                    % update the candle locations
                    Screen('FillRect', windowPtr, colourOut', allRects); % body
                end
                Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
                
                Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
                Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                % Flip to the screen
                Screen('Flip', windowPtr); % avoid flicker by flipping based on condition
                
                
            elseif i == 4 % 'You will be shown some items you can select to complete the picture click to select one
                DrawFormattedText(windowPtr, sprintf(instructionTextCell{i,j}{1}), 'center', yLoc, foreGrndL);
                
                allowPlacement = 1;
                placementRects = placementRectsOriginal; % reset rectangles
                while allowPlacement == 1; % require click to select an item
                    
                    % show sample playground + placement rects
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 3, 0, foreGrndL);
                    % update the candle locations
                    Screen('FillRect', windowPtr, [candleCol{1};candleCol{2}]', placementRects(:,[1 2]));
                    
                    % draw stimulus shadows
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
                    
                    % Get the current position of the mouse
                    [mx, my, buttons] = GetMouse(windowPtr);
                    
                    % Is the participant pressing a button?
                    [ keyIsDown, timeSecs, keyCode ] = KbCheck(kbPointer);
                    
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % See if the mouse cursor is inside the to-be-placed candles
                    inside1 = IsInRect(mx, my, placementRects(:,1));
                    inside2 = IsInRect(mx, my, placementRects(:,2));
                    
                    % See if the mouse cursor is functionally on top of the to-be-placed
                    % shadows
                    insideSU1 = IsInRect(mx, my, placementRects(:,3)+25); % upper shadow for body #1
                    insideSL1 = IsInRect(mx, my, placementRects(:,4)+25);
                    insideSU2 = IsInRect(mx, my, placementRects(:,5)+25);
                    insideSL2 = IsInRect(mx, my, placementRects(:,6)+25); % lower shadow for body #2
                    
                    % Highest level selection option: click on any element of one
                    % of the two candles and you got yourself a manipulable glyph
                    % in position on the x axis.
                    if (sum(buttons(1)) > 0 && (inside1||insideSU1||insideSL1)) %|| keyCode(leftKey));
                        glyphSelect(1,1)=1;
                        candleBodCol = 1;
                        upperShadCol = 3;
                        lowerShadCol = 4;
                        updateXVal = 1;
                    elseif (sum(buttons(1)) > 0 && (inside2||insideSU2||insideSL2))% || keyCode(rightKey);
                        glyphSelect(1,2)=1;
                        candleBodCol = 2;
                        upperShadCol = 5;
                        lowerShadCol = 6;
                        updateXVal = 1;
                    elseif (sum(buttons(1)) > 0 && (sum(glyphSelect)>1))||(sum(buttons(2))>0);
                        glyphSelect = zeros(1,2); %allow the selection of one at at time.
                        %%%%%% TO-DO: FB RE: TOO MANY SELECTION
                        placementRects = placementRectsOriginal; % reset rectangles
                    end
                    
                    if updateXVal % snap to placeHolder position
                        sx = mean([placeHolder(1,1), placeHolder(1,3)]); % get mean of x values for candle body
                        sy = mean([placeHolder(1,2), placeHolder(1,4)]); % catch up to mouse position on the y dimension
                        
                        % update values for the placement candle ..
                        placementRects(1,candleBodCol) = placeHolder(1);
                        placementRects(3,candleBodCol) = placeHolder(3);
                        
                        % .. bring the upper shadow with it ..
                        placementRects([1,3],upperShadCol) = [mean(placementRects([1,3],candleBodCol))-5, mean(placementRects([1,3],candleBodCol))+5]; % x dimension
                        
                        % .. and the lower shadow.
                        placementRects([1,3],lowerShadCol) = placementRects([1,3],upperShadCol); % x dimensions match upper shadow
                        
                        % are the values viable?
                        impossibleRects = find(placementRects(4,:)-placementRects(2,:)<1);
                        if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,impossibleRects)+.5; placementRects(4,impossibleRects)=placementRects(4,impossibleRects)-.5; end
                        
                        % vis. feedback about selection. Light 'er up.
                        Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                        Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                        Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    end
                    updateXVal =0;
                    
                    % are the values viable?
                    impossibleRects = find(placementRects(4,:)-placementRects(2,:)<.5);
                    if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,impossibleRects)+.5; placementRects(4,impossibleRects)=placementRects(4,impossibleRects)-.5; end
                    
                    % draw stimulus
                    if triCandleFlag
                        % convert placement rectangles to triangles
                        rect2TriCandle([], placementRects, endOfDayDiff, candleCol, [1 2], windowPtr,0); % "tri-candle" bodies
                    else
                        % update the candle rlocations
                        Screen('FillRect', windowPtr, [candleCol{1};candleCol{2}]', placementRects(:,[1 2]));
                    end
                    
                    % draw stimulus shadows
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
                    
                    % draw the outline of the stimuli; axis lines, labels, title...
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 3, 0, foreGrndL);
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    
                    % which candle is selected?
                    leftMost = find([placementRects(3,1),placementRects(3,2)]==min([placementRects(3,1),placementRects(3,2)])); % error: can't select two candles
                    if length(leftMost)>1
                        %Screen('DrawText', windowPtr, 'Error! Select only box. Right click on your selection to start again', (screenXpixels-xTent)/2, yCenter, foreGrndL, bkgnCol(1));
                        DrawFormattedText(windowPtr, 'Error! Select only box. Right click on your selection to start again', 150, screenYpixels/2, foreGrndL);
                    end
                    
                    if sum(glyphSelect)==1
                        Screen('DrawText', windowPtr, 'Good work! You have selected one item to complete the series. Next we will adjust it.', (screenXpixels-xTent)/2, screenYpixels/2, foreGrndL, bkgnCol(1));
                        % "hit next to continue"
                        candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 0, 0, foreGrndL);
                        DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                        % Flip to the screen
                        %vbl  = Screen('Flip', windowPtr);
                        if nextSelected && buttons(1)>0;
                            isInNext = 1;
                            allowPlacement = 0;
                        end
                    elseif nextSelected && buttons(1)>0;
                        DrawFormattedText(windowPtr, instructionTextCell{i,j}{1}, 'center', yLoc, foreGrndL);
                    elseif sum(glyphSelect)~=1 && nextSelected && buttons(1)>0
                        DrawFormattedText(windowPtr, 'Before you move on, use the mouse to select an object that completes the pattern. Click one of them, or press the left or the right arrow to select.', 'center', yLoc, foreGrndL);
                        
                    end
                    % Flip to the screen
                    Screen('Flip', windowPtr);
                end
                adjustAllowed = 0;
            elseif i ==5 % If you want to move the item up or down to complete the pattern press "up" or "down"
                
                while ~adjustAllowed
                    % "hit next to continue"
                    DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    DrawFormattedText(windowPtr, instructionTextCell{i}{1}, 'center', yLoc, foreGrndL); % instruction text
                    % print mac keyboard with highlighted "a" and up/down arrows
                    Screen('DrawTexture', windowPtr, tex(5))
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 0, 0, foreGrndL);
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    Screen('Flip', windowPtr); % show screen
                    if nextSelected && buttons(1)>0
                        adjustAllowed = 1;
                    end
                end
                
                adjustSet= 0;
                
                while adjustAllowed
                    
                    [ keyIsDown, timeSecs, keyCode ] = KbCheck(kbPointer);
                    
                    % text feedback
                    if (keyCode(upKey)||keyCode(downKey))
                        adjustSet = 1;
                    end
                    if adjustSet
                        Screen('DrawText', windowPtr, 'Good work! You have adjusted the position of the item you selected by using the up and down arrow keys.', (screenXpixels-xTent)/2, screenYpixels/2, foreGrndL, bkgnCol(1));
                    end
                    
                    % move in keeping with the button press
                    if sum(glyphSelect)==1 && keyCode(upKey) && candleBodCol>0; % candle one's selected, user presses UP ARROW
                        % 3) move whole unit up
                        placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])=placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])-5;
                        
                    elseif sum(glyphSelect)==1 && keyCode(downKey) && candleBodCol>0; % candle one's selected, user presses DOWN ARROW
                        % 4) move whole unit down
                        placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])=placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])+5;
                    end
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 3, 0, foreGrndL);
                    
                    % are the values viable?
                    impossibleRects = find(placementRects(4,:)-placementRects(2,:)<.5);
                    if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,impossibleRects)+.5; placementRects(4,impossibleRects)=placementRects(4,impossibleRects)-.5; end
                    
                    % draw stimulus
                    if triCandleFlag;
                        % convert placement rectangles to triangles
                        rect2TriCandle([], placementRects, endOfDayDiff, candleCol, [1 2], windowPtr,0); % "tri-candle" bodies
                    else
                        % update the candle rlocations
                        Screen('FillRect', windowPtr, [candleCol{1};candleCol{2}]', placementRects(:,[1 2]));
                    end
                    
                    % draw stimulus shadows
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
                    
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    if nextSelected && buttons(1)>0 && adjustSet;
                        adjustAllowed = 0; % escape criteria
                    elseif nextSelected && ~adjustSet;
                        DrawFormattedText(windowPtr, 'Hold "a" and use the arrow keys to adjust the position of the object (up or down).', 'center', yLoc+25, foreGrndL);
                    elseif adjustSet
                        % "hit next to continue"
                        DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    end
                    % present image
                    Screen('Flip', windowPtr);
                end
                
                adjustSet = 0;

            elseif i == 6 %If you want to make just the middle bit bigger or smaller, hold "f" and press "up" or "down".
                
                while ~adjustAllowed
                    % "hit next to continue"
                    DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    DrawFormattedText(windowPtr, instructionTextCell{i}{1}, 'center', yLoc, foreGrndL); % instruction text
                    % print mac keyboard with highlighted "f" and +/- arrows
                    Screen('DrawTexture', windowPtr, tex(7))
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 0, 0, foreGrndL);
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    Screen('Flip', windowPtr); % show screen
                    if nextSelected && buttons(1)>0
                        adjustAllowed = 1;
                    end
                end
                
                adjustSet= 0;
                
                while adjustAllowed %If you want to make just the middle bit bigger or smaller, hold "f" and press "up" or "down".
                    
                    [ keyIsDown, timeSecs, keyCode ] = KbCheck(kbPointer);
                    
                    % text feedback
                    if keyCode(fKey) && (keyCode(upKey)||keyCode(downKey))
                        adjustSet = 1;
                    end
                    if adjustSet
                        Screen('DrawText', windowPtr, 'Good work! You have adjusted the height of the middle section by using the "f" and the "up" or "down" keys.', (screenXpixels-xTent)/2, screenYpixels/2, foreGrndL, bkgnCol(1));
                    end
                    
                    % move in keeping with the button press
                    if sum(glyphSelect)==1 && keyCode(upKey) && keyCode(fKey) && candleBodCol>0; % increase body size
                        % 1) bigger candle body
                        % candle body
                        placementRects(2,candleBodCol) = placementRects(2,candleBodCol)-5; % extend top
                        placementRects(4,candleBodCol) = placementRects(4,candleBodCol)+5; % extend bottom
                        
                        % scoot the shadows (same size, but update position)
                        % upper shadow
                        placementRects([2,4],upperShadCol) = placementRects([2,4],upperShadCol)-5; % move up
                        
                        % lower shadow
                        placementRects([2,4],lowerShadCol) = placementRects([2,4],lowerShadCol)+5; % move down
                    elseif sum(glyphSelect)==1 && keyCode(downKey) && keyCode(fKey) && candleBodCol>0; % decrease body size
                        %2) smaller candle body
                        
                        % condition to avoid the funky flip
                        if placementRects(4,candleBodCol)-5 < placementRects(2,candleBodCol)+5
                            placementRects(4,candleBodCol)=placementRects(2,candleBodCol)+2; % minimum height of 2 px
                        else
                            % candle body
                            placementRects(2,candleBodCol) = placementRects(2,candleBodCol)+5; % retract top
                            placementRects(4,candleBodCol) = placementRects(4,candleBodCol)-5; % retract bottom
                            
                            % upper shadow
                            placementRects([2,4],upperShadCol) = placementRects([2,4],upperShadCol)+5; % move down
                            
                            % lower shadow
                            placementRects([2,4],lowerShadCol) = placementRects([2,4],lowerShadCol)-5; % move up
                        end
                    end
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 3, 0, foreGrndL);
                    
                    % are the values viable?
                    impossibleRects = find(placementRects(4,:)-placementRects(2,:)<.5);
                    if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,impossibleRects)+.5; placementRects(4,impossibleRects)=placementRects(4,impossibleRects)-.5; end
                   
                    % draw stimulus
                    if triCandleFlag
                        % convert placement rectangles to triangles
                        rect2TriCandle([], placementRects, endOfDayDiff, candleCol, [1 2], windowPtr,0); % "tri-candle" bodies
                    else
                        % update the candle locations
                        Screen('FillRect', windowPtr, [candleCol{1};candleCol{2}]', placementRects(:,[1 2]));
                    end
                    
                    % draw stimulus shadows
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
                    
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    if nextSelected && buttons(1)>0 && adjustSet
                        adjustAllowed = 0; % escape criteria
                    elseif nextSelected && ~adjustSet
                        DrawFormattedText(windowPtr, 'Hold "f" and use the "up" or "down" keys to adjust the height of the whole object.', 'center', yLoc+25, foreGrndL);
                    elseif adjustSet
                        % "hit next to continue"
                        DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    end
                    % present image
                    Screen('Flip', windowPtr);
                end
                
                adjustSet = 0;
                % adjust the size of the whole unit
                
            elseif i == 7 % If you want to make just the top bit bigger or smaller, hold "r" and press "up" or "down".'
                
                while ~adjustAllowed
                    % "hit next to continue"
                    DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    DrawFormattedText(windowPtr, instructionTextCell{i}{1}, 'center', yLoc, foreGrndL); % instruction text
                    % print mac keyboard with highlighted r and +/- arrows
                    Screen('DrawTexture', windowPtr, tex(8))
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 0, 0, foreGrndL);
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    Screen('Flip', windowPtr); % show screen
                    if nextSelected && buttons(1)>0
                        adjustAllowed = 1;
                    end
                end
                
                adjustSet= 0;
                
                while adjustAllowed % If you want to make just the top bit bigger or smaller, hold "r" and press "+" or "-".'
                    
                    [ keyIsDown, timeSecs, keyCode ] = KbCheck(kbPointer);
                    
                    % text feedback
                    if keyCode(rKey) && (keyCode(upKey)||keyCode(downKey))
                        adjustSet = 1;
                    end
                    if adjustSet
                        Screen('DrawText', windowPtr, 'Good work! You have adjusted the height of the top section by using the "r" and the "up" or "down" keys.', (screenXpixels-xTent)/2, screenYpixels/2, foreGrndL, bkgnCol(1));
                    end
                    
                    % move in keeping with the button press
                    if sum(glyphSelect)==1 && keyCode(upKey) && keyCode(rKey) && candleBodCol>0; % candle one's selected, user presses UP ARROW
                        
                        % 3) larger upper shadow
                        placementRects(2,upperShadCol) = placementRects(2,upperShadCol)-5; % move top bit up
                        
                    elseif sum(glyphSelect)==1 && keyCode(downKey) && keyCode(rKey) && candleBodCol>0;
                        % 4) smaller upper shadow
                        placementRects(2,upperShadCol) = placementRects(2,upperShadCol)+5; % move top bit down
                    end
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 3, 0, foreGrndL);
                    
                    % are the values viable? assuming upper shadow of the
                    % selected candle is the problem...
                    impossibleRects = find(placementRects(4,:)-placementRects(2,:)<.5); ... set the problematic rectangle to rest atop the candle body
                    if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,candleBodCol); placementRects(2,impossibleRects)=placementRects(2,candleBodCol)-.5; end
                    
                    % draw stimulus
                    if triCandleFlag
                        % convert placement rectangles to triangles
                        rect2TriCandle([], placementRects, endOfDayDiff, candleCol, [1 2], windowPtr,0); % "tri-candle" bodies
                    else
                        % update the candle rlocations
                        Screen('FillRect', windowPtr, [candleCol{1};candleCol{2}]', placementRects(:,[1 2]));
                    end
                    
                    % draw stimulus shadows
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
                    
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    if nextSelected && buttons(1)>0 && adjustSet
                        adjustAllowed = 0; % escape criteria
                    elseif nextSelected && ~adjustSet
                        DrawFormattedText(windowPtr, 'Hold "r" and use the "up" or "down" keys to adjust the height of the top section.', 'center', yLoc+25, foreGrndL);
                    elseif adjustSet
                        % "hit next to continue"
                        DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    end
                    % present image
                    Screen('Flip', windowPtr);
                end
                
                adjustSet = 0;
                
            elseif i == 8 %If you want to make just the bottom bit bigger or smaller, hold "v" and press "up" or "down".
                
                while ~adjustAllowed
                    % "hit next to continue"
                    DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    DrawFormattedText(windowPtr, instructionTextCell{i}{1}, 'center', yLoc, foreGrndL); % instruction text
                    % print mac keyboard with highlighted "v" and +/- arrows
                    Screen('DrawTexture', windowPtr, tex(9))
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 0, 0, foreGrndL);
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    Screen('Flip', windowPtr); % show screen
                    if nextSelected && buttons(1)>0
                        adjustAllowed = 1;
                    end
                end
                
                adjustSet= 0;
                
                while adjustAllowed
                    
                    [ keyIsDown, timeSecs, keyCode ] = KbCheck(kbPointer);
                    
                    % text feedback
                    if keyCode(vKey) && (keyCode(upKey)||keyCode(downKey))
                        adjustSet = 1;
                    end
                    if adjustSet
                        Screen('DrawText', windowPtr, 'Good work! You have adjusted the height of the bottom bit by using the "v" and the "up" or "down" keys.', (screenXpixels-xTent)/2, screenYpixels/2, foreGrndL, bkgnCol(1));
                    end
                    
                    if sum(glyphSelect)==1 && keyCode(downKey) && keyCode(vKey) && candleBodCol>0;
                        % 5) larger lower shadow
                        placementRects(4,lowerShadCol) = placementRects(4,lowerShadCol)+5; % move bottom bit down
                    elseif sum(glyphSelect)==1 && keyCode(upKey) && keyCode(vKey) && candleBodCol>0;
                        % 6) smaller lower shadow
                        placementRects(4,lowerShadCol) = placementRects(4,lowerShadCol)-5; % move bottom bit up
                    end
                    
                    % get mouse coordinates, button selection
                    [mx, my, buttons] = GetMouse(windowPtr);
                    % draw mouse cursor
                    Screen('DrawDots', windowPtr, [mx my], 5, foreGrndL, [], 2);
                    
                    candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, 1, {sampleData}, placeHolder, windowPtr, 3, 0, foreGrndL);
                    
                    % are the values viable?
                    impossibleRects = find(placementRects(4,:)-placementRects(2,:)<.5);
                    if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,impossibleRects)+.5; placementRects(4,impossibleRects)=placementRects(4,impossibleRects)-.5; end
                    
                    % draw stimulus
                    if triCandleFlag
                        % convert placement rectangles to triangles
                        rect2TriCandle([], placementRects, endOfDayDiff, candleCol, [1 2], windowPtr,0); % "tri-candle" bodies
                    else
                        % update the candle rlocations
                        Screen('FillRect', windowPtr, [candleCol{1};candleCol{2}]', placementRects(:,[1 2]));
                    end
                    
                    % draw stimulus shadows
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
                    Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
                    
                    % See if the mouse cursor is inside the next button
                    nextSelected = IsInRect(mx, my, nextRect);
                    
                    % vis. feedback about selection. Light 'er up.
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                    Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
                    
                    if nextSelected && buttons(1)>0 && adjustSet
                        adjustAllowed = 0; % escape criteria
                    elseif nextSelected && ~adjustSet
                        DrawFormattedText(windowPtr, 'Hold "v" and use the "up" or "down" keys to adjust the height of the bottom portion.', 'center', yLoc+25, foreGrndL);
                    elseif adjustSet
                        % "hit next to continue"
                        DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                    end
                    % present image
                    Screen('Flip', windowPtr);
                end
                
            else
                
                DrawFormattedText(windowPtr, sprintf(instructionTextCell{i,j}{1}), 'center', yLoc, foreGrndL);
                
                % "hit next to continue"
                DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
                % show cursor, button, and instruction text
                Screen('Flip', windowPtr);
                
            end
        end
    end
    
    instructionTroubles = NaN;
end