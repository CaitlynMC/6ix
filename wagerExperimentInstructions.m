function instructionTroubles = candleExperimentInstructions(screenXpixels, screenYpixels, windowPtr, bkgnCol, foreGrndL, foreGrndD, xTent, upKey, downKey, leftKey, rightKey, plusKey, minusKey, enterKey, fKey, rKey, vKey, aKey, candleCol, shadowCol,allCoords);

%  Here are instructions for the candle experiment where participants are asked to bet. 
%
%  Author: C. M. McColeman
%  Date Created: May 21 2017
%  Last Edit: 
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix wager "experiment 7" for dissertation.
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: [Insert Function Inputs here (if any)]
%
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: candleInstructionSupport 
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
instructionTextCell{2,1} = {'You will see a lot of graphs, and your job is to decide whether you want to buy a stock.'};
instructionTextCell{2,2} = {'The graphs represent the open, close, high and low prices from pretend financial information.'};
instructionTextCell{2,3} = {'Over time, you will get a bit better at making bets.'};
instructionTextCell{2,4} = {'Please be patient, and gather information through trial and error to improve your responses.'};
instructionTextCell{2,5} = {'It''s possible to earn points on every trial. Try each time to get as many points as you can!'};
instructionTextCell{3,1} = {'So, how does this work? You will see an image, and you''ll have time to study it. \n When you are ready to decide whether to buy, use the mouse to click "next".'}; % sample image
instructionTextCell{4,1} = {'The first image will go away and you will be able to decide whether to bet \n and how much you are willing to wager.'}; % sample adjustable features
instructionTextCell{10,2} = {'Your goal is to earn as many points as you can.'}; %
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
                
                
            elseif i == 4 % The first image will go away and you will be able to decide whether to bet and how much you are willing to wager.
            
            
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