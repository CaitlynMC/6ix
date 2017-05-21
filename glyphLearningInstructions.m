function glyphLearningInstructions(screenXpixels, screenYpixels, windowPtr, bkgnCol, foreGrndL, foreGrndD, xTent)
%  The instructions presented to participants at the start of the
%  glyphLearning task.
%
%  Author: C. M. McColeman
%  Date Created: Oct 10 2016
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
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
%  Additional Comments: I originally was trying to get this in teh same
%  spot as candleExperimentInstructions but it's too different. Pulling out
%  into its own function for ease of use.


instructionTextCell{1,1} = {'Welcome to the experiment! Thank you for helping us understand human cognition.'};
instructionTextCell{1,2} = {'Today, you will learn how to read icons in a graph.'};
instructionTextCell{1,3} = {'It''s okay if you are not a math person. \n You do not need to know any math or much about graphs.'};
instructionTextCell{1,4} = {'We are interested to see how people learn how to use them.'};
instructionTextCell{2,1} = {'You will see a lot of graphs, and your job is to report some information from each.'};
instructionTextCell{2,2} = {'We will ask about the open, close, high and low prices from pretend financial information \n that are represented by the graphs.'};
instructionTextCell{2,3} = {'Over time, you will get a bit better at reading the graphs to report the information.'};
instructionTextCell{2,4} = {'Please be patient, and gather information through trial and error to improve your responses.'};
instructionTextCell{2,5} = {'It''s possible to get up to 125 points per trial. Try each time to get as many points as you can!'};
instructionTextCell{3,1} = {'So, how does this work? You''ll see an image, and you''ll have time to study it. \n When you are ready to guess what comes next, use the mouse to click "next".'};
instructionTextCell{4,1} = {'You will be asked to type in your response to a question using the keyboard.'};
instructionTextCell{5,1} = {'Just type using the number keys and press enter when you''re done.'}; % highlight
instructionTextCell{6,1} = {'If you have any questions right now, please knock on the door behind you so the experimenter can help.'}; %
instructionTextCell{7,1} = {'Otherwise, we will get started. Thank you again for helping with this study.'}; %
instructionTextCell{8,1} = {'It is okay to make mistakes -- that is part of learning. \n Please continue to try your best to improve over time and get as many points as you can!'}; %

footerText = 'Click "next" to continue.';
SetMouse(screenXpixels/2, screenYpixels/2, windowPtr);
yLoc = .2*screenYpixels;
textSize = 14;

for i = 1:length(instructionTextCell)
    pause(.15)
    

    for j = find(~cellfun(@isempty,instructionTextCell(i,:)))
        nextSelected = 0;
        pause(.15)
        while nextSelected==0;

            
            
            % get mouse coordinates, button selection
            [mx, my, buttons] = GetMouse(windowPtr);
            
            % draw the next button
            [nextRect, YLabVals]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, 0, 0, 0, 0, windowPtr, 0, 0, foreGrndL);
                        
            if (i == 4)||(i==5)% % You will be asked to type in your response to a question using the keyboard
                DrawFormattedText(windowPtr, sprintf('Your typed answer will appear in this box:'), nextRect(1)-50*textSize, .5*screenYpixels-2.5*textSize, foreGrndL);
                % draw response box
                Screen('FrameRect', windowPtr, foreGrndD, [nextRect(1)-2*textSize .5*screenYpixels-.5*textSize nextRect(3)+2*textSize .5*screenYpixels+1.5*textSize], 2);
                
            end
            
            % identify location relative to next button
            isInNext = IsInRect(mx, my, nextRect);
            
            nextSelected = isInNext && buttons(1)>0;
            
            DrawFormattedText(windowPtr, sprintf(instructionTextCell{i,j}{1}), 'center', yLoc, foreGrndL);
            
            % "hit next to continue"
            DrawFormattedText(windowPtr, footerText, 'center', .9*screenYpixels, foreGrndL);
            % show cursor, button, and instruction text
           Screen('Flip', windowPtr);
            
        end
        
    end
    
end