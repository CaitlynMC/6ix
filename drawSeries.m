%  This allows a user to drag and drop candlestick components into the
%  display
%
%  Author: C. M. McColeman
%  Date Created: September 3 2016
%  Last Edit: Oct 25 2016 - folded in feedback from alpha testers
%             spring 2017 - added in drawSeries2, drawSeries3 and required
%                           functions
%             summer 2017 - added in drawSeries4, "experiment7" for the
%                           dissertation
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: None
%
%  OUTPUT: Saves data to current directory for analysis
%
%  Additional Scripts Used: candleExperimentInstructions.m,
%  candleDemographics.m, blowOutTheCandle.m, candleSaveExpLvl.m,
%  candleSaveTrialLvl.m, drawSeriesAsCandle.m
%
%  Additional Comments: http://peterscarfe.com/mousesquaredemo.html;
%                       https://github.com/kleinerm/Psychtoolbox-3/blob/master/Psychtoolbox/PsychDemos/DrawFormattedTextDemo.m



% Clear the workspace and the screen
sca;  clear all;
close all;
clearvars;
Screen('Preference', 'SkipSyncTests', 1);
dbmode = 0;


nMinutes = 55;
allowableErrorToZero = 500;

diceRoll = rand

if diceRoll < 0
    sExpName='drawSeries';
elseif diceRoll < 0
    sExpName='drawSeries2'; % change to drawSeries2 to add noise channels
elseif diceRoll < 0
    sExpName='drawSeries3'; % change to drawSeries3 to manipulate spread factors
elseif diceRoll < 1
    sExpName='drawSeries4'; 
end


experimentOpenTime = tic;
% changed March 27 for end-of-semester run -- want to get data for
% drawSeries experiment 4 to compare subsequent experiments more easily.
sExpName='drawSeries';
% gather subject information via dialog box, ensure that the full path is
% added
if ~dbmode
    [demoResp, stopExperiment]= candleDemographics;
    
else
    subjectNumber = 21;
    demoResp{2}=2;
end

[upKey, downKey, plusKey, minusKey, enterKey, fKey, rKey, vKey, aKey, deleteKey, leftKey, rightKey]=keyMapping(demoResp{2});

% get experiment level information
[columnOrder, candleCol, noiseSource, bkgnCol, shadowCol, populateRow, subjectNumber,spreadFactor] = expLvlOrganizer(sExpName);

% if the canadle colours are the same, then we're in the up/down triangle
% condition.
if sum(candleCol{1}==candleCol{2})==3
    triCandleFlag = 1;
else
    triCandleFlag = 0;
end

% get trial level information
load('trialLvlPresentation.mat')

% Default settings for setting up Psychtoolbox
AssertOpenGL;

global psych_default_colormode;
psych_default_colormode = 1;

% Unify keycode to keyname mapping across operating systems:
KbName('UnifyKeyNames');

% a multiplier to add a little plump on the outside of a rectangle so it's easier to
% stay inside of the boundaries.
usabilityBuffer = [-1; -1; .1; .1];
buffReg = .1; % visual buffer so the plot doesn't approach the edges of the screen
cumulativePts = 0;
updateXVal = 0;
glyphSelect(1,1)=0;
candleBodCol = 0;
upperShadCol = 0;
lowerShadCol = 0;
updateXVal = 0;

if ~dbmode
    % if people hit cancel, kill the experiment before we save the data
    if stopExperiment; return; end
    
    % prepare data storage via subject directory
    timeIDDir = num2str(GetSecs);
    timeIDDir(strfind(timeIDDir, '.'))='_';
    timeIDDir = [timeIDDir '_' num2str(populateRow)];
    mkdir([timeIDDir '/demoBK/']);
    save([timeIDDir '/demoBK/demoResps.mat'], 'demoResp', 'populateRow')
else
    demoResp{2}=3; 
end

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% coerce input option to the external keyboad if there are multiple
% options (if you're on the macbook)
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
kbPointer = keyboardIndices(end);

try % the whole experiment is in a try/catch, so in the event of an error you're not stuck on the experiment screen
    
    % Open an on screen windowPtr
    if demoResp{2}==1 % running room computers, PCs
        screenDim = get(screenNumber,'screensize'); % note: 0,0 is the top left corner of the screen
        screenXpixels = screenDim(3); screenYpixels = screenDim(4); % max screen size (should be resolution of your computer)
        bgArea = screenDim; %This sets the coordinate space of the screen window, WHICH MAY HAVE A DIFFERENT SIZE
        
        [windowPtr, windowPtrRect] = Screen('OpenWindow', screenNumber, bkgnCol(1)*255); % open a screen
        Screen('TextFont', windowPtr, 'Courier New')
        foreGrndD = (bkgnCol./4)*255; % 4x as bright as background
        foreGrndL = (bkgnCol*2)*255; % twice as dark as background
        textSize=14;
        Screen('TextSize', windowPtr, textSize);
        
        candleCol{1}=candleCol{1}*255; candleCol{2}=candleCol{2}*255; % update to un-scaled RGB colourspace
        shadowCol = shadowCol*255;
        
    elseif demoResp{2}==2 % running room old iMacs
        screenDim = get(screenNumber,'screensize'); % note: 0,0 is the top left corner of the screen
        screenXpixels = screenDim(3); screenYpixels = screenDim(4); % max screen size (should be resolution of your computer)
        bgArea = screenDim; %This sets the coordinate space of the screen window, WHICH MAY HAVE A DIFFERENT SIZE
        
        [windowPtr, windowPtrRect] = Screen('OpenWindow', screenNumber, bkgnCol(1)*255); % open a screen
        Screen('TextFont', windowPtr, 'Courier New')
        foreGrndD = (bkgnCol./4)*255; % 4x as bright as background
        foreGrndL = (bkgnCol*2)*255; % twice as dark as background
        textSize=18;
        Screen('TextSize', windowPtr, textSize);
        Screen('TextStyle', windowPtr, 1); % bold to avoid rendering artifacts on old iMac
        candleCol{1}=candleCol{1}*255; candleCol{2}=candleCol{2}*255; % update to un-scaled RGB colourspace
        shadowCol = shadowCol*255;
    else % on a newer macbook. can do things via psychimaging
        foreGrndD = bkgnCol./4; % 4x as bright as background
        
        foreGrndL = bkgnCol*2; % twice as dark as background
        
        [windowPtr, windowPtrRect] = PsychImaging('OpenWindow', screenNumber, bkgnCol(1));
        
        Screen('TextFont', windowPtr, 'Courier New')
        % Get the size of the on screen windowPtr
        [screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);
        textSize=18;
        
        Screen('TextSize', windowPtr, textSize);
        Screen('TextStyle', windowPtr, 1); % bold to avoid rendering artifacts on scaled display resolution
    end
    
    % identify the primary stimulus space; x dimension
    xTent = .9*(1-buffReg)*screenXpixels;
    
    % axis line information
    xCoords = [150 xTent 150 150];
    yCoords = [900 900 300 900];
    allCoords = [xCoords; yCoords];
    
    % Fixation cross information
    fixCrossDimPix = .03*screenYpixels;
    
    % Fixation cross lines
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    fixCoords = [xCoords; yCoords];
    
    % Query the frame duration
    ifi = Screen('GetFlipInterval', windowPtr);
    
    % Maximum priority level
    topPriorityLevel = MaxPriority(windowPtr);
    Priority(topPriorityLevel);
    
    % Get the centre coordinate of the windowPtr
    [xCenter, yCenter] = RectCenter(windowPtrRect);
    
    % select the basic series
    trialOrder = randsample(40,200,1);
    
    % Call function to run particpants through instructions.
    candleExperimentInstructions(screenXpixels, screenYpixels, windowPtr, bkgnCol, foreGrndL, foreGrndD, xTent, upKey, downKey, leftKey, rightKey, plusKey, minusKey, enterKey, fKey, rKey, vKey, aKey, candleCol, shadowCol,allCoords);
    pause(2)
    trialNumber=0;
    testIfTimeUp=toc(experimentOpenTime);
    highestPossible = 60; % value is totally arbitrary, but structurally important for drawSeriesAsCandle.m; required for glyphLearning exps
    
    while ~(testIfTimeUp > 60*nMinutes) && (trialNumber+1)<length(trialOrder)
        
        trialNumber = trialNumber+1;
        madeResponse = 0;
        testIfTimeUp=toc(experimentOpenTime);
        
        if testIfTimeUp > 60*nMinutes % secs max. exp length; 60 seconds time 55 minutes
            break;
        end
        glyphSelect = zeros(1,2); % keep track of what's picked. Indexing is consistent with defaultPlaceOrder.
        if mod(trialNumber,2) == 0
            defaultPlaceOrder = [1,2]; % the green/hollow will be left on odd trials
        else
            defaultPlaceOrder = [2,1];
        end
        
        if trialNumber==1 || mod(trialNumber,20)==0 % first trial, and every 20th after that, provide a block break
            
            blockBreak(windowPtr, cumulativePts, foreGrndL, bkgnCol, screenXpixels, screenYpixels, 5*allowableErrorToZero, xTent, testIfTimeUp, nMinutes)

        end
        
        % trial onset in time of day
        startTime = clock;
        
        whichMod = randsample(size(dataSample,2)-2,size(dataSample,2)-2);
        
        
        %% Phase 1: fixation
        HideCursor()
        % FIXATION CROSS PHASE ONE
        gotToNextPhase = 1;
        Screen('DrawLines', windowPtr, fixCoords,...
            2, foreGrndD, [xCenter yCenter])
        
        % Sync us and get a time stamp
        [vblOn, phase1Onset] = Screen('Flip', windowPtr);
        vbl=vblOn;
        
        % prepare phase 2 before flipping window. Gather data necessary to
        % draw stimulus.
        [allRects, shadowRects, colourOut, placementRects, placeHolder, simulated100, simulatedCol, simulatedShadow, endOfDayDiff, simulatedOCDiff] = ....
            drawSeriesAsCandle(screenXpixels, screenYpixels, dataSample{trialOrder(trialNumber),whichMod(1)}, columnOrder, noiseSource, candleCol, xTent, [],allCoords, spreadFactor);
        
        placementRectsOriginal = placementRects;
        placementRectsRecord = {placementRectsOriginal};
        
        % draw the outline of the stimuli; axis lines, labels, title...
        [nextRect, YLabVals]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, gotToNextPhase, 0, foreGrndL, spreadFactor);
        
        % draw the stimuli
        if triCandleFlag
            % Draw the triangles to the screen
            [allRectsNowTriangle, placementRectsNowTriangle]= rect2TriCandle(allRects, placementRects, endOfDayDiff, candleCol, [], windowPtr,0);
            % prepare to draw in the answer a particular direction when the
            % time comes
            if simulatedOCDiff>0; coerceDir=2; else coerceDir = 1; end
        else
            % Draw the rect to the screen
            Screen('FillRect', windowPtr, colourOut', allRects);
        end
        Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
        Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
        pause(1) % fixation cross is on for one second (+ change, incl. buffer load and call to external functions to draw stimuli)
        
        %% Phase 2: stimulus
        [vblOn2, phase2Onset]=Screen('Flip', windowPtr);
        
        % stimulus presentation phase
        gotToNextPhase = 2;
        ShowCursor('CrossHair')
        % present stimulus
        while gotToNextPhase == 2
            % Get the current position of the mouse
            [mx, my, buttons] = GetMouse(windowPtr);
            Screen('DrawDots', windowPtr, [mx my], 5, foreGrndD, [], 2);
            % draw the outline of the stimuli; axis lines, labels, title...
            nextRect = candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, gotToNextPhase, highestPossible, foreGrndL);
            
            if triCandleFlag
                rect2TriCandle(allRects, placementRects, endOfDayDiff, candleCol, [], windowPtr,0);
            else
                Screen('FillRect', windowPtr, colourOut', allRects);
            end
            Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
            Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
            
            % if the mouse button is pressed while the mouse is inside the "NEXT"
            % box, advance to response phase.
            nextSelected = IsInRect(mx, my, nextRect);
            
            if nextSelected && sum(buttons)>0
                gotToNextPhase = 3;
                % get phase two reaction time here.
            end
            Screen('Flip', windowPtr);
        end
        
        %% Phase 3: response selection
        Screen('DrawText', windowPtr, 'Select and adjust the most appropriate marker.', xTent+125, 350, foreGrndL, bkgnCol(1));
        Screen('FrameRect', windowPtr, foreGrndL, [xTent+125, 400, screenXpixels-50, 700], 2);
        
        % draw the outline of the stimuli; axis lines, labels, title... (as
        % if it was phase 2 to intialize)
        [nextRect, YLabVals]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, 2, highestPossible, foreGrndL);
        
        % Reinitialize cursor to center of screen
        SetMouse(xCenter, yCenter, windowPtr);
        ShowCursor('CrossHair')
        
        % Sync us and get a time stamp
        [vblOn3, phase3Onset] = Screen('Flip', windowPtr);
        
        % Maximum priority level
        topPriorityLevel = MaxPriority(windowPtr);
        Priority(topPriorityLevel);
        
        % Where my mouse cursors at?!
        [mx, my, buttons] = GetMouse(windowPtr);
        
        % if the user clicks "next", proceed
        nextSelected = IsInRect(mx, my, nextRect);
        
        % Loop the animation until a key is pressed
        while gotToNextPhase==3
            
            % listen for manipulation buttons
            [keyIsDown, timeSecs, keyCode ] = KbCheck(kbPointer);
            
            % Get the current position of the mouse
            [mx, my, buttons] = GetMouse(windowPtr);
            Screen('DrawDots', windowPtr, [mx my], 5, foreGrndD, [], 2);
            % See if the mouse cursor is inside the next button
            nextSelected = IsInRect(mx, my, nextRect);
            
            % See if the mouse cursor is inside the to-be-placed candles
            inside1 = IsInRect(mx, my, placementRects(:,1));
            inside2 = IsInRect(mx, my, placementRects(:,2));
            
            % See if the mouse cursor is functionally on top of the to-be-placed
            % shadows
            insideSU1 = IsInRect(mx, my, placementRects(:,3)+5*usabilityBuffer); % upper shadow for body #1
            insideSL1 = IsInRect(mx, my, placementRects(:,4)+5*usabilityBuffer);
            insideSU2 = IsInRect(mx, my, placementRects(:,5)+5*usabilityBuffer);
            insideSL2 = IsInRect(mx, my, placementRects(:,6)+5*usabilityBuffer); % lower shadow for body #2
            
            % Highest level selection option: click on any element of one
            % of the two candles and you got yourself a manipulable glyph
            % in position on the x axis.
            if (sum(buttons(1)) > 0 && (inside1||insideSU1||insideSL1)) || keyCode(leftKey) % updated to allow left arrow selection too
                glyphSelect(1,1)=1;
                candleBodCol = 1;
                upperShadCol = 3;
                lowerShadCol = 4;
                updateXVal = 1;
            elseif (sum(buttons(1)) > 0 && (inside2||insideSU2||insideSL2)) || keyCode(rightKey) % updated to allow right arrow selection too
                glyphSelect(1,2)=1;
                candleBodCol = 2;
                upperShadCol = 5;
                lowerShadCol = 6;
                updateXVal = 1;
            elseif (sum(buttons(1)) > 0 && (sum(glyphSelect)>1))||(sum(buttons(2))>0)
                glyphSelect = zeros(1,2); %allow the selection of just one at at time.
                
                placementRects = placementRectsOriginal; % reset rectangles
            end 
            
            if updateXVal 
                % some reference dimensions for recording and coding
                candleHeight = placementRects(4,candleBodCol)-placementRects(2,candleBodCol);
                upperShadowHeight = placementRects(4,upperShadCol)-placementRects(2,upperShadCol);
                lowerShadowHeight = placementRects(4,lowerShadCol)-placementRects(2,lowerShadCol);
                
                % snap to placeHolder position
                placementRects(1,candleBodCol) = placeHolder(1);
                placementRects(3,candleBodCol) = placeHolder(3);
                
                % .. bring the upper shadow with it ..
                placementRects([1,3],upperShadCol) = [mean(placementRects([1,3],candleBodCol))-5, mean(placementRects([1,3],candleBodCol))+5]; % x dimension
                
                % .. and the lower shadow.
                placementRects([1,3],lowerShadCol) = placementRects([1,3],upperShadCol); % x dimensions match upper shadow
                
                % are the values viable?
                impossibleRects = find(placementRects(4,:)-placementRects(2,:)<1);
                if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,impossibleRects)+.5; placementRects(2,impossibleRects)=placementRects(2,impossibleRects)-.5; end
                
                % vis. feedback about selection. Light 'er up.
                Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,candleBodCol), 2); % candle body
                Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,upperShadCol), 2); % upper shadow
                Screen('FrameRect', windowPtr, foreGrndD, placementRects(:,lowerShadCol), 2); % lower shadow
            end
            updateXVal =0;
            
            if sum(glyphSelect)==1 && keyCode(upKey) && ~(keyCode(fKey)||keyCode(rKey)||keyCode(vKey)) && candleBodCol>0; %sum(glyphSelect)==1 && keyCode(upKey) && keyCode(aKey) && candleBodCol>0; % candle one's selected, user presses UP ARROW
                % 3) move whole unit up
                placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])=placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])-2;
                
                % candle1 selected, no sub-unit selected, down arrow is pressed
            elseif sum(glyphSelect)==1 && keyCode(downKey) && ~(keyCode(fKey)||keyCode(rKey)||keyCode(vKey)) && candleBodCol>0; %sum(glyphSelect)==1 && keyCode(downKey) && keyCode(aKey) && candleBodCol>0; % candle one's selected, user presses DOWN ARROW
                % 4) move whole unit down
                placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])=placementRects([2,4],[candleBodCol, upperShadCol, lowerShadCol])+2;
                
            elseif (keyCode(fKey)||keyCode(rKey)||keyCode(vKey))&&sum(glyphSelect)==0
                % Third level option: adjust the size of one of the candle
                % components in isolation from the unit that is selected
            elseif keyCode(fKey) && candleBodCol>0 ; % f key selected: adjust candle body. updated to work with with up/down arrows
                
                if keyCode(upKey) && glyphSelect(1,candleBodCol)==1;%keyCode(plusKey) && glyphSelect(1,candleBodCol)==1
                    % 1) bigger candle body
                    % candle body
                    placementRects(2,candleBodCol) = placementRects(2,candleBodCol)-2; % extend top
                    placementRects(4,candleBodCol) = placementRects(4,candleBodCol)+2; % extend bottom
                    
                    % scoot the shadows (same size, but update position)
                    % upper shadow
                    placementRects([2,4],upperShadCol) = placementRects([2,4],upperShadCol)-2; % move up
                    
                    % lower shadow
                    placementRects([2,4],lowerShadCol) = placementRects([2,4],lowerShadCol)+2; % move down
                    
                elseif keyCode(downKey) && glyphSelect(1,candleBodCol)==1; 
                    %2) smaller candle body
                    % condition to avoid the funky flip
                        if placementRects(4,candleBodCol)-2 < placementRects(2,candleBodCol)+2
                            placementRects(4,candleBodCol)=placementRects(2,candleBodCol)+1; % minimum height of 1 px
                        else
                            % candle body
                            placementRects(2,candleBodCol) = placementRects(2,candleBodCol)+2; % retract top
                            placementRects(4,candleBodCol) = placementRects(4,candleBodCol)-2; % retract bottom
                            
                            % upper shadow
                            placementRects([2,4],upperShadCol) = placementRects([2,4],upperShadCol)+2; % move down
                            
                            % lower shadow
                            placementRects([2,4],lowerShadCol) = placementRects([2,4],lowerShadCol)-2; % move up
                        end

                end
                
            elseif keyCode(rKey)  && candleBodCol>0  ; % r key selected: adjust upper shadow
                % move in keeping with the button press
                    if sum(glyphSelect)==1 && keyCode(upKey) && candleBodCol>0; % candle one's selected, user presses UP ARROW
                        
                        % 3) larger upper shadow
                        placementRects(2,upperShadCol) = placementRects(2,upperShadCol)-2; % move top bit up
                        
                    elseif sum(glyphSelect)==1 && keyCode(downKey) && candleBodCol>0;
                        % 4) smaller upper shadow
                        
                        if ~(placementRects(2,upperShadCol)+2 > placementRects(2,candleBodCol)) % as long as it doesn't go lower than the top of the candle..
                            placementRects(2,upperShadCol) = placementRects(2,upperShadCol)+2; % .. move top bit down
                        end
                    end
                    
            elseif keyCode(vKey)  && candleBodCol>0 ;
                
                if keyCode(downKey) && glyphSelect(1,candleBodCol)==1; 
                    % 5) larger lower shadow
                    placementRects(4,lowerShadCol) = placementRects(4,lowerShadCol)+2; % move bottom bit down
                elseif keyCode(upKey) && glyphSelect(1,candleBodCol)==1 ; 
                    % 6) smaller lower shadow
                    if ~(placementRects(4,lowerShadCol)-2 < placementRects(4,candleBodCol)) % as long as it doesn't go higher than the bottom of the candle..
                        placementRects(4,lowerShadCol) = placementRects(4,lowerShadCol)-2; % ..move bottom bit up.
                    end
                end
            end
            
            % are the values viable?
            impossibleRects = find(placementRects(4,:)-placementRects(2,:)<.5);
            if ~isempty(impossibleRects); placementRects(4,impossibleRects)=placementRects(2,impossibleRects)+.5; placementRects(2,impossibleRects)=placementRects(2,impossibleRects)-.5; end
            
            % draw stimulus
            if triCandleFlag
                % convert placement rectangles to triangles
                [allRectsNowTriangle, placementRectsNowTriangle]=rect2TriCandle([], placementRects, endOfDayDiff, candleCol, defaultPlaceOrder, windowPtr,0); % "tri-candle" bodies
            else
                % update the candle rlocations
                Screen('FillRect', windowPtr, [candleCol{defaultPlaceOrder(1,1),1};candleCol{defaultPlaceOrder(1,2),1}]', placementRects(:,[1 2]));
            end
            
            % draw stimulus shadows
            Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
            Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
            
            % draw the outline of the stimuli; axis lines, labels, title...
            [nextRect, YLabVals]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, gotToNextPhase, highestPossible, foreGrndL);
            
            % which candle is selected?
            leftMost = find([placementRects(3,1),placementRects(3,2)]==min([placementRects(3,1),placementRects(3,2)])); % error: can't select two candles
            if length(leftMost)>1
                Screen('DrawText', windowPtr, 'Error! Select only box. Right click on your selection to start again', (screenXpixels-xTent)/2, yCenter, foreGrndL, bkgnCol(1));
            end
            
            % Flip to the screen
            vbl  = Screen('Flip', windowPtr);
            
            if (sum(buttons)>0 || keyIsDown) && (sum(abs(placementRectsRecord{size(placementRectsRecord,1),1}(:)-placementRects(:)))>20) % if there's a sufficiently large change, record it
                placementRectsRecord{size(placementRectsRecord,1)+1,1}=placementRects; % keep track of movements in trial
                placementRectsRecord{size(placementRectsRecord,1),2}=GetSecs; % keep track of timing of movements in trial
            end
            
            if sum(buttons)>0 && nextSelected
                gotToNextPhase = gotToNextPhase+1; 
            end
            
        end
        
        if placementRects(1,leftMost)>placeHolder(1,3) % no response collected
            errorVal = allowableErrorToZero;
            errorRec = [0; 0; 0; 0];
            madeResponse = 0;
        else
            madeResponse = 1;
            
            placementRectsForError = placementRects(:,[upperShadCol,lowerShadCol]);
            
            [errorVal, errorRec] = candleErrorCalculator(candleCol, simulated100, simulatedCol, ...
                simulatedShadow(1:4,1), simulatedShadow(5:8,1), placementRects(:, leftMost), candleCol{defaultPlaceOrder(leftMost)}, placementRectsForError); % changed from placementRects(:,[3, 4]) to placementRects(:,[upperShadCol, lowerShadCol])
            
        end
        %% Phase 4: Feedback
        % draw in the stimuli
        
        if madeResponse==0; % don't draw candle if participant didn't pick one
            
            Screen('DrawText', windowPtr, 'No object selected.', xTent+textSize*2, mean([placementRects(2,1),placementRects(4,1)]), foreGrndL, bkgnCol(1));
            Screen('DrawText', windowPtr, 'Series not completed.', xTent+textSize*2, mean([placementRects(2,1),placementRects(4,1)])+20, foreGrndL, bkgnCol(1));
            candleBodCol=1;upperShadCol=1;lowerShadCol=1;
        elseif triCandleFlag
            [allRectsNowTriangle, placementRectsNowTriangle]=rect2TriCandle(allRects, placementRects, endOfDayDiff, candleCol, defaultPlaceOrder, windowPtr,0); % "tri-candle" bodies
            
            % response shadows
            Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
            Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
            
            % stimulus shadows
            Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
            Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
            
            [newX,newY]=Screen('DrawText', windowPtr, '<- Your answer', xTent+textSize*2, mean([placementRects(2,leftMost),placementRects(4,leftMost)]), foreGrndL, bkgnCol(1));
            
        else
            % stimulus bodies
            Screen('FillRect', windowPtr, colourOut', allRects); % candle bodies
            
            % draw in the response
            Screen('FillRect', windowPtr, [[candleCol{defaultPlaceOrder(1,1),1}];[candleCol{defaultPlaceOrder(1,2),1}]]', placementRects(:,[1 2])); % the response
            
            % response shadows
            Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[3 4]));
            Screen('FillRect', windowPtr, [shadowCol;shadowCol]', placementRects(:,[5 6]));
            
            % stimulus shadows
            Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
            Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
            
            [newX,newY]=Screen('DrawText', windowPtr, '<- Your answer', xTent+textSize*2, mean([placementRects(2,leftMost),placementRects(4,leftMost)]), foreGrndL, bkgnCol(1));
            
        end
        
        candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, gotToNextPhase, highestPossible, foreGrndL);
        
        [vblOn4, phase4Onset] = Screen('Flip', windowPtr);
        
        pause(2)
        
        [vblOn5, phase5Onset] = Screen('Flip', windowPtr);
        
        while gotToNextPhase == 4
            % Get the current position of the mouse
            [mx, my, buttons] = GetMouse(windowPtr);
            
            % draw the outline of the stimuli; axis lines, labels, title...
            candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, gotToNextPhase, highestPossible, foreGrndL);
            
            % remind participants of their response
            [newX,newY]=Screen('DrawText', windowPtr, '<- The correct answer', xTent+textSize*1.5, mean([simulated100(2),simulated100(4)]), foreGrndL, bkgnCol(1));
            
            if triCandleFlag
                
                % draw in the stimuli
                rect2TriCandle(allRects, placementRects, endOfDayDiff, candleCol, [], windowPtr, 0); % "tri-candle" bodies
                % draw in the simulated "answer"
                rect2TriCandle(simulated100, placementRects, endOfDayDiff, candleCol, [], windowPtr, coerceDir); % "tri-candle" body
            else
                % draw in the stimuli
                Screen('FillRect', windowPtr, colourOut', allRects); % candle bodies
                % draw in the simulated "answer"
                Screen('FillRect', windowPtr, simulatedCol', simulated100); % what the simulated candle dimensions were
            end
            
            % stimulus shadow
            Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
            Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
            
            % stimulated shadow (the "answer" shadow)
            Screen('FillRect', windowPtr, shadowCol', simulatedShadow(1:4,1)); % upper shadow
            Screen('FillRect', windowPtr, shadowCol', simulatedShadow(5:8,1)); % lower shadow
            
            % draw cursor
            Screen('DrawDots', windowPtr, [mx my], 5, foreGrndD, [], 2);
            
            % listen for hover over "next" button
            nextSelected = IsInRect(mx, my, nextRect);
            
            if nextSelected && sum(buttons)>0
                gotToNextPhase = 1;
                
                [trialEndVbl, phase5Offset]=Screen('Flip', windowPtr);
            end
            
            
            
            if errorVal < -allowableErrorToZero*4; errorVal=-allowableErrorToZero*4; end
            
            if (allowableErrorToZero-errorVal)<=0
                puncStart = '';
                puncEnd = '.';
            else
                puncStart = '+';
                puncEnd = '!';
            end
            
            [newX,newY]=Screen('DrawText', windowPtr, [puncStart num2str(round(allowableErrorToZero-errorVal)) ' points' puncEnd], xTent+10, mean([simulated100(2),simulated100(4)])+50, foreGrndL, bkgnCol(1));
            
            candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, gotToNextPhase, highestPossible, foreGrndL);
            
            % show 'em
            Screen('Flip', windowPtr);
            
        end
        cumulativePts = cumulativePts + round(allowableErrorToZero-errorVal);
        endTime = clock;
        display('trial end')
        % save trial data
        if ~dbmode
            [trialEndVbl, phase5Offset]=Screen('Flip', windowPtr);
            
            candleSaveTrialLvl(timeIDDir, sExpName, subjectNumber, trialNumber, madeResponse, errorVal, defaultPlaceOrder, ...
                candleCol{defaultPlaceOrder(1,leftMost)}, simulatedCol, simulated100, simulatedShadow, placementRects,...
                vblOn, vblOn2, vblOn3, vblOn4, trialEndVbl, trialOrder, whichMod, ...
                columnOrder,xTent, testIfTimeUp, leftMost, endOfDayDiff, ...
                candleBodCol, upperShadCol, lowerShadCol, dataSample, endTime, '', cumulativePts)
            
            save([timeIDDir '/trial' num2str(trialNumber) '.mat'], ...
                'vblOn', 'vblOn2', 'vblOn3', 'vblOn4', 'vblOn5', 'trialEndVbl', 'placementRectsRecord', 'placementRects', 'errorVal', 'errorRec', 'startTime', 'endTime', 'leftMost', 'defaultPlaceOrder', 'candleCol', 'simulatedShadow', 'simulated100', 'simulatedCol', 'shadowRects', 'allRects', 'colourOut', 'highestPossible', 'trialEndVbl', 'cumulativePts', 'whichMod', 'testIfTimeUp', 'madeResponse')
        end
        
        
    end % end trial
    
    %closing/debrief phase; set experiment end time.
    [subjectID, populateRowExpLvl] = blowOutTheCandle(windowPtr, populateRow, screenXpixels, screenYpixels, foreGrndL, bkgnCol, xTent, demoResp, timeIDDir);
    ShowCursor()
    
    % Clear the screen
    sca;
    dbstop if error
    
    % save the experiment level data
    candleSaveExpLvl(subjectID, columnOrder, candleCol, startTime, endTime, timeIDDir, demoResp, screenXpixels, screenYpixels, noiseSource, sExpName, trialNumber, cumulativePts, shadowCol, spreadFactor)
    
    
catch %#ok<*CTCH> In event of error
    % This "catch" section executes in case of an error in the "try"
    % section above.  Importantly, it closes the onscreen windowPtr if it's open.
    sca;
    ShowCursor()
    fclose('all');
    psychrethrow(psychlasterror);
end


