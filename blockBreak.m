function blockBreak(windowPtr, cumulativePts, textCol, bkgnCol, screenXpixels, screenYpixels, pointGoal, xTent, minElapsed, totalTime)
%  This communicates to the participant how they're doing an encourages
%  them to take a break from the task.
%
%  Author: C. M. McColeman
%  Date Created: October 9 2016
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: David McIntyre, November 22 2016
%  Verified: []
%
%  INPUT:
% windowPtr - int; the screen to write to
% cumulativePts - int; the score so far
% textCol - double; the font colour used in the experiment
% bkgnCol - double; the background colour used in the experiment
% screenXpixels - double; the number of pixels across the screen
% screenYpixels - double; the number of pixels vertically on the screen
% xTent - double; this helps determine where to draw the next button via
%          candleFrameStimuli
%
%  OUTPUT:
%
%  Additional Scripts Used:
%
%  Additional Comments: Adapted from http://peterscarfe.com/countdowndemo.html
blockBreakTxt = ['So far you have ' num2str(cumulativePts) ' points. \n Do you think you could get ' num2str(pointGoal) ' more in the next 20 tries? ' ];

isInNext=0;

while isInNext==0;
    
    % draw the next button
    [nextRect, YLabVals]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, 0, 0, 0, 0, windowPtr, 0, 0, textCol);
    display('caught candle frame stimuli')
    % get mouse coordinates, button selection
    [mx, my, buttons] = GetMouse(windowPtr);
    
    % draw mouse cursor
    Screen('DrawDots', windowPtr, [mx my], 5, textCol, [], 2);
    
    % Draw our number to the screen
    DrawFormattedText(windowPtr, sprintf(blockBreakTxt), 'center', 'center', textCol);
    
    % Flip to the screen
    Screen('Flip', windowPtr);
    
    % identify location relative to next button
    isInNext = (IsInRect(mx, my, nextRect)&&sum(buttons(1)>0));
    pause(.1) % hold on 100 ms to avoid multi-next click advancement error
end

% Here is our count-down loop
for i = 5:-1:1
    
    % Draw our number to the screen
    DrawFormattedText(windowPtr, num2str(i), 'center', 'center', textCol);
    DrawFormattedText(windowPtr, 'Try to get as many points as you can by being more accurate. Every one counts!', 'center', screenYpixels*.35, textCol);
    
    
    DrawFormattedText(windowPtr, ['There are about ' num2str(round((60*totalTime-minElapsed)/60)) ' minutes left.'], 'center', screenYpixels*.8, textCol);
    
    % Flip to the screen
    Screen('Flip', windowPtr);
    
    
    % Wait a second before closing the screen
    WaitSecs(1);
end
