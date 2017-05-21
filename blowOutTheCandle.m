function [subjectID, populateRowExpLvl] = blowOutTheCandle(windowPtr, populateRowExpLvl, screenXPixels, screenYPixels, textCol, bkgrndCol, xTent, demoResp, timeIDDir)
%  This presents information to close the experiment and updates the record
%  of ExpLvl information with the end time.
%
%  Author: C. M. McColeman
%  Date Created: September 20 2016
%  Last Edit: [November 24 2016]
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix - meant for use in drawSeries.m and
%  glyphLearning.m
%
%  Reviewed: [Judi Azmand]
%  Verified: []
%
%  INPUT: [Insert Function Inputs here (if any)]
%
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments:

debriefTextCell{1,1} = {'Thank you again for helping us to learn about human cognition.'};
debriefTextCell{2,1} = {'Today, you saw different patterns in graphs.'};
debriefTextCell{3,1} = {'They were the same kinds of patterns that everyone sees.'};
debriefTextCell{4,1} = {'What differs, though, is that some people see graphs that have different icons from what you saw.'};
debriefTextCell{5,1} = {'We want to know if any of these differences are helpful in making better guesses.'};
debriefTextCell{6,1} = {'Thank you for your great work!'};
debriefTextCell{7,1} = {'When you leave the room, please don''t tell people what the differences in the graphs are ...'};
debriefTextCell{8,1} = {'... because if people know what we expect they might behave differently.'}; % sample image
debriefTextCell{9,1} = {'So, please wait until you leave this section of the building before you talk about the experiment.'}; % point to next button
debriefTextCell{10,1} = {'You may now leave the room and tell the experimenter that you are finished.'}; % sample adjustable features

footerText = 'Use the mouse to click "next" to continue';

stimSample=imread('debriefSample.png', 'png');

tex(1) = Screen('MakeTexture', windowPtr, stimSample);
yLoc = .25*screenYPixels;

% update the experiment level record the end time of the experiment as a
% datetime object
load('expLvlPresentation.mat')

expLvlRec{populateRowExpLvl, 8} = clock;
expLvlRec{populateRowExpLvl, 13} = demoResp;
expLvlRec{populateRowExpLvl, 14} = timeIDDir;

subjectID = [expLvlRec{populateRowExpLvl,9} '_' num2str(demoResp{1})];

% save the variables that were loaded (even if they weren't updated)
save('expLvlPresentation.mat', 'expParameters', 'expLvlRec');
for i = 1:length(debriefTextCell)
    % intialize mouse location
    if i == 1 % center at start of debriefs
        SetMouse(screenXPixels/2, screenYPixels/2, windowPtr);
    end
    pause(1)
    
    isInNext = 0;
    % listen for click on "next" button
    while isInNext==0
        %Draw ith line of text horizontally centered and vertically 25% down
        % the screen
        DrawFormattedText(windowPtr, debriefTextCell{i,1}{1}, 'center', yLoc, textCol);
        % get mouse coordinates, button selection
        [mx, my, buttons] = GetMouse(windowPtr);
        % draw mouse cursor
        Screen('DrawDots', windowPtr, [mx my], 5, textCol, [], 2);
        
        if i < length(debriefTextCell)
            
            % draw the next button
            %% what is YLabVals used for? -JA % CM: it's not used in this section of the experiment, but old computers cannot handle placeholder vars.
            [nextRect, YLabVals]= candleFrameStimuli(xTent, screenXPixels, screenYPixels, bkgrndCol, 0, 0, 0, 0, windowPtr, 0, 0, textCol, 1); 
            
            % identify location relative to next button
            nextSelected = IsInRect(mx, my, nextRect);
            % if the button's pressed, trigger the escape for the while loop
            if nextSelected && sum(buttons)>0
                isInNext = 1;
                % big button to show selection
                Screen('DrawDots', windowPtr, [mx my], 10, textCol, [], 2);
            end
            
            % special debrief pages that require images
            if i == 4||i==5
                Screen('DrawTexture', windowPtr, tex(1))
            end
            
            % "hit next to continue"
            DrawFormattedText(windowPtr, footerText, 'center', .9*screenYPixels, textCol);
            
            % show cursor, button, and debrief text
            Screen('Flip', windowPtr);
            
        else % last line of debrief test
            isInNext = 1; % force advance (no mouse click on last line)
            
            % show cursor and debrief text
            Screen('Flip', windowPtr);
            
            pause(8) % no user action on last line; pause the screen 8 secs. to give them a chance to read and get out.
        end
    end
end




