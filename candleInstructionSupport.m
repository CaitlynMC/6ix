function candleInstructionSupport(screenXpixels, screenYpixels, windowPtr, bkgrndCol, xTent, textCol, instructionTextCell, upKey, downKey, plusKey, minusKey, enterKey)
%  This is to train people on the interface
%
%  Author: C. M. McColeman
%  Date Created: September 24 2016
%  Last Edit: [Last Time of Edit]
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix - drawSeries.m
%
%  Reviewed: [Cal cwoodruf@sfu.ca 2016-09-26 some comments, not a full review]
%  Verified: []
%
%  INPUT: 
%
%  OUTPUT:
%
%  Additional Scripts Used: 
%
%  Additional Comments:

gradientImg=imread('puzzle.jpg', 'jpg');

tex(1) = Screen('MakeTexture', windowPtr, gradientImg);
rect1 = CenterRectOnPointd([0 0 .02*screenXpixels .05*screenYpixels],...
    .7*screenXpixels, 900);
rect2 = CenterRectOnPointd([0 0 .02*screenXpixels .06*screenYpixels],...
    .8*screenXpixels, 900);
rect3 = CenterRectOnPointd([0 0 .02*screenXpixels .03*screenYpixels],...
    .9*screenXpixels, 900);
holeRect = CenterRectOnPointd([0 0 .02*screenXpixels .05*screenYpixels],...
    .75*screenXpixels, .5*screenYpixels);

% initialize adjustment variables
dx1 = 0; dx2 = 0; dx3 = 0;
dy1 = 0; dy2 = 0; dy3 = 0;
rect1Select = 0; rect2Select = 0; rect3Select = 0;
offset1Set = 0; offset2Set = 0; offset3Set = 0;
rectanglePlaced = 0;
offsetSet = 0;
moveOn = 0;

while rectanglePlaced==0
    
    % Get the current position of the mouse
    [mx, my, buttons] = GetMouse(windowPtr);
    Screen('DrawDots', windowPtr, [mx my], 5, textCol, [], 2);
    
    inside1 = IsInRect(mx, my, rect1);
    inside2 = IsInRect(mx, my, rect2);
    inside3 = IsInRect(mx, my, rect3);
    
    Screen('DrawTexture', windowPtr, tex(1))
    
    Screen('FillRect', windowPtr, [.48 .48 .48], holeRect); % the "gap" to fill in. The grey is hardcoded bc this was generated externally.
    
    % Draw the rectangles to the screen
    Screen('FillRect', windowPtr, [0 1 0], rect1);
    Screen('FillRect', windowPtr, [1 0 0], rect2);
    Screen('FillRect', windowPtr, [0 0 1], rect3);
    
    
    % If the mouse cursor is inside a placement ROI and a mouse button is being
    % pressed and the offset has not been set, set the offset and signal
    % that it has been set
    if inside1 == 1 && sum(buttons(1)) > 0 && offsetSet == 0
        
        % get centre of rectangle pre-adjustment
        [cx, cy] = RectCenter(rect1);
        
        dx = mx - cx;
        dy = my - cy;
        offsetSet = 1;
        rect1Select = 1; rect2Select = 0; rect3Select = 0;
        
    elseif inside2 == 1 && sum(buttons(1)) > 0 && offsetSet == 0
        % get centre of rectangle pre-adjustment
        [cx, cy] = RectCenter(rect2);
        
        dx = mx - cx;
        dy = my - cy;
        offsetSet = 1;
        rect1Select = 0; rect2Select = 1; rect3Select = 0;
        
    elseif inside3 == 1 && sum(buttons(1)) > 0 && offsetSet == 0
        % get centre of rectangle pre-adjustment
        [cx, cy] = RectCenter(rect3);
        
        dx = mx - cx;
        dy = my - cy;
        offsetSet = 1;
        rect1Select = 0; rect2Select = 0; rect3Select = 1;
        
    end
    
    % If we are clicking on a placement ROI allow its position to be modified by
    % moving the mouse, correcting for the offset between the centre of the
    % square and the mouse position
    if inside1 == 1 && sum(buttons(1)) > 0
        sx = .75*screenXpixels; % snap selected candle into place on x-axis
        sy = my - dy;
        
        rect1Select = 1; rect2Select = 0; rect3Select = 0;
        % Center the rectangle on its new screen position
        rect1 = CenterRectOnPointd(rect1, sx, sy);
        % Draw the rect to the screen
    elseif inside2 == 1 && sum(buttons(1)) > 0
        sx = .75*screenXpixels; % snap selected candle into place on x-axis
        sy = my - dy;
        
        rect1Select = 0; rect2Select = 1; rect3Select = 0;
        % Center the rectangle on its new screen position
        rect2 = CenterRectOnPointd(rect2, sx, sy);
    elseif inside3 == 1 && sum(buttons(1))>0
        sx = .75*screenXpixels; % snap selected candle into place on x-axis
        sy = my - dy;
        
        rect1Select = 0; rect2Select = 0; rect3Select = 1;
        % Center the rectangle on its new screen position
        rect3 = CenterRectOnPointd(rect3, sx, sy);
    elseif (inside1 == 1 || inside2 == 1 || inside3 == 1) && sum(buttons(2)) > 0  % reset/deselect
        rect1 = CenterRectOnPointd([0 0 .02*screenXpixels .05*screenYpixels],...
            .7*screenXpixels, 900);
        rect2 = CenterRectOnPointd([0 0 .02*screenXpixels .05*screenYpixels],...
            .8*screenXpixels, 900);
        rect3 = CenterRectOnPointd([0 0 .02*screenXpixels .05*screenYpixels],...
            .9*screenXpixels, 900);
    elseif sum(buttons(1))>0
        rect1Select = 0; rect2Select = 0; rect3Select = 0;
    end
    
    % Indicate the cursor location, and what's selected
    if (inside1 == 1) && buttons(1)
        Screen('FrameRect', windowPtr, textCol, rect1, 2);
        rect1Select=1;
    elseif (inside2 == 1) && buttons(1)
        rect2Select=1;
        Screen('FrameRect', windowPtr, textCol, rect2, 2);
    elseif (inside3 == 1) && buttons(1)
        rect3Select=1;
        Screen('FrameRect', windowPtr, textCol, rect3, 2);
    end
    
    % Look for adjustments to placement objects via keyboard
    % arrows[v,^/+,-]
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    
    % Cal: abort by pressing enter - for the impatient
    if keyCode(enterKey);
        rectanglePlaced = 1;
        continue;
    end
    % A selected rectangles' height to be adjusted.
    if rect1Select && keyCode(plusKey);
        rect1(2)=rect1(2)-1;
        rect1(4)=rect1(4)+1;
    elseif rect2Select && keyCode(plusKey);
        rect2(2)=rect2(2)-1;
        rect2(4)=rect2(4)+1;
    elseif rect1Select && keyCode(minusKey);
        if abs(rect1(2)-rect1(4))<1; else % don't let it get too small that it can't be drawn
            rect1(2)=rect1(2)+1;
            rect1(4)=rect1(4)-1;
        end
    elseif rect2Select && keyCode(minusKey);
        if abs(rect2(2)-rect2(4))<1; else % don't let it get too small that it can't be drawn
            rect2(2)=rect2(2)+1;
            rect2(4)=rect2(4)-1;
        end
    elseif rect3Select && keyCode(plusKey);
        rect3(2)=rect3(2)-1;
        rect3(4)=rect3(4)+1;
    elseif rect3Select && keyCode(minusKey);
        if abs(rect2(2)-rect2(4))<1; else % don't let it get too small that it can't be drawn
            rect3(2)=rect3(2)+1;
            rect3(4)=rect3(4)-1;
        end
    end
    
    % If we have selected a rectangle, allow its position to be adjusted.
    if rect1Select && keyCode(upKey);% move up
        rect1(2)=rect1(2)-1;
        rect1(4)=rect1(4)-1;
    elseif rect2Select && keyCode(upKey);% move up
        rect2(2)=rect2(2)-1;
        rect2(4)=rect2(4)-1;
    elseif rect1Select && keyCode(downKey);% move down
        rect1(2)=rect1(2)+1;
        rect1(2)=rect1(2)+1;
    elseif rect2Select && keyCode(downKey);% move down
        rect2(2)=rect2(2)+1;
        rect2(4)=rect2(4)+1;
    elseif rect3Select && keyCode(upKey); % move up
        rect3(2)=rect3(2)-1;
        rect3(4)=rect2(4)-1;
    elseif rect3Select && keyCode(downKey); % move down
        rect3(2)=rect3(2)+1;
        rect3(4)=rect2(4)+1;
    end
    
    % how far off is the participant?
    [cx, cy] = RectCenter(rect3);
    [hx, hy] = RectCenter(holeRect);
    
    locationCheck = (abs(cx-hx)+abs(cy-hy))<20;
    heightCheck = (abs(rect3(1,[2,4])-holeRect(1,[2,4])))<10;
    
    display(locationCheck)
    display(heightCheck)
    
    % provide online feedback
    if locationCheck & heightCheck
        rectanglePlaced=1;
        DrawFormattedText(windowPtr, instructionTextCell{17,2}{1}, 'center', .2*screenYpixels, textCol);
        pause(1)
    elseif locationCheck
        DrawFormattedText(windowPtr, instructionTextCell{17,3}{1}, 'center', .2*screenYpixels, textCol);
    elseif heightCheck
        DrawFormattedText(windowPtr, instructionTextCell{17,4}{1}, 'center', .2*screenYpixels, textCol);
    else 
        DrawFormattedText(windowPtr, instructionTextCell{17,1}{1}, 'center', .2*screenYpixels, textCol);
    end
    
        % show updates
    Screen('Flip', windowPtr);
end

while moveOn==0
    % Get the current position of the mouse
    [mx, my, buttons] = GetMouse(windowPtr);
    
    Screen('DrawDots', windowPtr, [mx my], 5, textCol, [], 2);
    % draw the next button
    nextRect = candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgrndCol, 0, 0, 0, 0, windowPtr, 0, 0, textCol);
    Screen('Flip', windowPtr);

    % Cal: this did not work as next button never shows up on screen?
    %      added ability to use "enter" to get to next screen w/o getting
    %      the task right.
    nextSelected = IsInRect(mx, my, nextRect);
    if (nextSelected && sum(buttons)>0)
        moveOn = 1;
    end
    
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;    
    if keyCode(enterKey);
        moveOn = 1;
    end
end

 

