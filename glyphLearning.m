%  The experiment tests the speed at which people can learn the 5
%  dimensions represented by candle glyphs
%
%  Author: C. M. McColeman
%  Date Created: September 15 2016
%  Last Edit: October 10 2016
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix, conceptually experiment 1
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: [Insert Function Inputs here (if any)]
%
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: [Insert all scripts called on]

%
%  Additional Comments: Requires that candleBuildExpConds has been run and
%  expLvlPresentation.mat, expLvlSetup.mat, trialLvlPresentation.mat are in the path


% Clear the workspace and the screen
sca; clear all;
close all;
clearvars;
cumulativePts = 0;
dbstop if error

nMinutes = 25;

displayFeedbackInfo = 0; % a debug toggle that's called in phase 4. 
allowableErrorToZero = 125;
bet = 0; betErrorClose = 0;


condChooser = rand*10; 

if condChooser<(2/10)
    sExpName='glyphLearning'; % 1/6 of people don't get grid lines
%elseif condChooser<(2.5/10)
%    sExpName='glyphLearning2';  % most people from here on in get grid lines [change Nov 3]
else
    sExpName='glyphLearning3';  % the spacing study [change Feb 27 2017]
end

try
    
    experimentOpenTime = tic;
    
    % Load experiment level information
    [columnOrder, candleCol, noiseSource, bkgnCol, shadowCol, populateRow, subjectNumber, spreadFactor] = expLvlOrganizer(sExpName);
    
    % gather subject information via dialog box
    [demoResp, stopExperiment]= candleDemographics;
        
    [upKey, downKey, plusKey, minusKey, enterKey, fKey, rKey, vKey, aKey, deleteKey, leftKey, rightKey]=keyMapping(demoResp{2});
    
    % if the candle colours are the same, then we're in the up/down triangle
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

    buffReg = .1; % visual buffer so the plot doesn't approach the edges of the screen
    cumulativePts = 0;
    
    % if people hit cancel, kill the experiment before we save the data
    if stopExperiment; return; end
    
    % prepare data storage via subject directory
    timeIDDir = num2str(GetSecs);
    timeIDDir(strfind(timeIDDir, '.'))='_';
    timeIDDir = [timeIDDir '_' num2str(populateRow)];
    mkdir([timeIDDir '/demoBK/']);
    save([timeIDDir '/demoBK/demoResps.mat'], 'demoResp', 'populateRow')
       
    % Get the screen numbers
    screens = Screen('Screens');
    
    % Draw to the external screen if avaliable
    screenNumber = max(screens);
    
    % Open an on screen windowPtr
    if demoResp{2}==1 % running room computers, PCs 
        screenDim = get(screenNumber,'screensize'); % note: 0,0 is the top left corner of the screen
        screenXpixels = screenDim(3); screenYpixels = screenDim(4); % max screen size (should be resolution of your computer)
        bgArea = screenDim; %This sets the coordinate space of the screen window, WHICH MAY HAVE A DIFFERENT SIZE
        
        [windowPtr, windowPtrRect] = Screen('OpenWindow', screenNumber, bkgnCol(1)*255); % open a screen
        Screen('TextFont', windowPtr, 'Courier New')
        foreGrndD = (bkgnCol./4)*255; % 4x as bright as background
        foreGrndL = (bkgnCol*2)*255; % twice as dark as background
        gridLineCol = (bkgnCol + .2*bkgnCol)*255;
        textSize=14;
        Screen('TextSize', windowPtr, textSize);
        
        candleCol{1}=candleCol{1}*255; candleCol{2}=candleCol{2}*255; % update to un-scaled RGB colourspace
    elseif demoResp{2}==2 % running room old iMacs
        screenDim = get(screenNumber,'screensize'); % note: 0,0 is the top left corner of the screen
        screenXpixels = screenDim(3); screenYpixels = screenDim(4); % max screen size (should be resolution of your computer)
        bgArea = screenDim; %This sets the coordinate space of the screen window, WHICH MAY HAVE A DIFFERENT SIZE
       
        [windowPtr, windowPtrRect] = Screen('OpenWindow', screenNumber, bkgnCol(1)*255); % open a screen
        Screen('TextFont', windowPtr, 'Courier New')
        foreGrndD = (bkgnCol./4)*255; % 4x as bright as background
        foreGrndL = (bkgnCol*2)*255; % twice as dark as background
        gridLineCol = (bkgnCol + .2*bkgnCol)*255;
        textSize=18;
        Screen('TextSize', windowPtr, textSize);
        Screen('TextStyle', windowPtr, 1); % bold to avoid rending artifacts on old iMac
        candleCol{1}=candleCol{1}*255; candleCol{2}=candleCol{2}*255; % update to un-scaled RGB colourspace
        
    else % on a newer macbook. can do things via psychimaging
        foreGrndD = bkgnCol./4; % 4x as bright as background
        foreGrndL = bkgnCol*2; % twice as dark as background
        gridLineCol = (bkgnCol + .2*bkgnCol);
        [windowPtr, windowPtrRect] = PsychImaging('OpenWindow', screenNumber, bkgnCol(1));
        
        Screen('TextFont', windowPtr, 'Courier New')
        % Get the size of the on screen windowPtr
        [screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);
        textSize=20;
        
        Screen('TextSize', windowPtr, textSize);
    end
    
    % identify the primary stimulus space; x dimension
    xTent = .9*(1-buffReg)*screenXpixels;
    
    % axis line information
    xCoords = [(1.25*buffReg)*screenXpixels xTent (1.25*buffReg)*screenXpixels (1.25*buffReg)*screenXpixels];
    yCoords = [.8*screenYpixels .8*screenYpixels .2*screenYpixels .8*screenYpixels];
    allCoords = [xCoords; yCoords];
    
    % Fixation cross information
    fixCrossDimPix = .03*screenYpixels;
    
    % Fixation cross lines
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    fixCoords = [xCoords; yCoords];
    
    % Define "red"; or filled
    fillCol = candleCol{2,1};
    hollowCol = candleCol{1,1};
    
    % Query the frame duration
    ifi = Screen('GetFlipInterval', windowPtr);
    
    % Maximum priority level
    topPriorityLevel = MaxPriority(windowPtr);
    Priority(topPriorityLevel);
    
    % Get the centre coordinate of the windowPtr
    [xCenter, yCenter] = RectCenter(windowPtrRect);
    
    % select the basic series
    trialOrder = randsample(size(dataSample,1), size(dataSample,1));
    
    whichMod=randsample(10,1);
    
    % experiment instruction
    glyphLearningInstructions(screenXpixels, screenYpixels, windowPtr, bkgnCol, foreGrndL, foreGrndD, xTent)
    
    % if the candle colours are the same, then we're in the up/down triangle
    % condition.
    if sum(candleCol{1}==candleCol{2})==3
        triCandleFlag = 1;
    else
        triCandleFlag = 0;
    end
    
    % prepare conversion from entered response to pixed for errorVal
    % calculation
    axisHeightPx = diff(unique(allCoords(2,:)));
    axisToppx = min(allCoords(2,:));
    
    playGrndInstTxt = {' Enter your best guess \n with the keyboard  \n and then press enter.'};
    errorVal = 0;
    
    for trialNumber = 1:length(trialOrder)
        testIfTimeUp=toc(experimentOpenTime);
        if testIfTimeUp > 60*nMinutes % secs max. exp length; 60 seconds times max number of minutes (nMinutes)
            break;
        end
        if mod(trialNumber,20)==0 % give 'em a break at 20 trials and update their progress
             blockBreak(windowPtr, cumulativePts, foreGrndL, bkgnCol, screenXpixels, screenYpixels, 5*allowableErrorToZero, xTent, toc(experimentOpenTime), nMinutes) 
        end
        
        distFromTopResp = 0;
        % trial onset in time of day
        startTime = clock;
        
        %highestYVal = randi([30 100],1,1); % work with old matlab
        highestYVal = 30+round(rand*(100-30));
        %singleGlyphLoc = randi([1 100],1,1); % work with old matlab
        singleGlyphLoc = 1+round(rand*99);
        %questionID = randi([1 4],1,1);
        questionID = 1+round(rand*3);
        
        %% Phase 1: fixation
        HideCursor()
        
        gotToNextPhase = 1;
        Screen('DrawLines', windowPtr, fixCoords,...
            2, [0 0 0], [xCenter yCenter])
        % Sync us and get a time stamp
        [vblOn, phase1Onset] = Screen('Flip', windowPtr);
        vblOn1=vblOn;
        
        % prepare phase 2
        [allRects, shadowRects, colourOut, placementRects, placeHolder, simulated100, simulatedCol, simulatedShadow, endOfDayDiff] = ...
            drawSeriesAsCandle(screenXpixels, screenYpixels, dataSample{trialOrder(trialNumber),whichMod(1)}, columnOrder, noiseSource, candleCol, xTent, singleGlyphLoc, allCoords, spreadFactor);
        
        placementRectsOriginal = placementRects;
        placementRectsRecord = {placementRectsOriginal};
        
        % stimulus presentation phase
        gotToNextPhase = 2;
        
        % draw the outline of the stimuli; axis lines, labels, title...
        [nextRect, yAxisVal]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, gotToNextPhase, highestYVal, foreGrndL, spreadFactor);
        
        if triCandleFlag
            [allRectsNowTriangle, placementRectsNowTriangle]= rect2TriCandle(allRects, placementRects, endOfDayDiff, candleCol, [], windowPtr,0);
        else
            % Draw the rect to the screen
            Screen('FillRect', windowPtr, colourOut', allRects);
            Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
        end
        Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
        
        pause(1) % fixation cross is on for one second (+ change, incl. buffer load and call to external function)
        ShowCursor('CrossHair')
        %% Phase 2: stimulus
        [vblOn2, phase2Onset]=Screen('Flip', windowPtr);
        % present stimulus
        while gotToNextPhase == 2
            % Get the current position of the mouse
            [mx, my, buttons] = GetMouse(windowPtr);
            Screen('DrawDots', windowPtr, [mx my], 5, [0 0 0], [], 2);
            % draw the outline of the stimuli; axis lines, labels, title...
            [nextRect, yAxisVal]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, 101, highestYVal, foreGrndL, spreadFactor);
            
            % grid lines?
            if strcmpi(sExpName, 'glyphLearning2')
                gridLinesIn=[];
                for i = 1:length(yAxisVal)
                    gridLinesIn = [gridLinesIn [allCoords(1,1)-5 xTent; yAxisVal(i) yAxisVal(i)]];
                end
                Screen('DrawLines', windowPtr, gridLinesIn, 1, gridLineCol); % alpha of .2
            end
            
            if triCandleFlag
                [allRectsNowTriangle, placementRectsNowTriangle]= rect2TriCandle(allRects, placementRects, endOfDayDiff, candleCol, [], windowPtr,0);
            else
                % Draw the rect to the screen
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
        
        % one dollar on the y-axis corresponds to dollarHeightRatio pixels
        dollarHeightRatio = 2*nanmean(diff(yAxisVal));
        
        [vblOn3, phase3Onset] = Screen('Flip', windowPtr);
        SetMouse(xCenter, yCenter, windowPtr); % Avoid multiple 'next' selects. Reinitialize @ centre.
        
        enterpressed=0; %initializes loop flag
        respBuffer=[]; %initializes buffer
        
        % modified from https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/Cookbook:-response-example-3
        while ( enterpressed==0 )

            % draw the outline of the stimuli; axis lines, labels, title...
            [nextRect, yAxisVal]= candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, 101, highestYVal, foreGrndL, spreadFactor);
            
            % what is the [open, close, high, low] price?
            glyphLearningResponse(windowPtr, nextRect, questionID, bkgnCol, foreGrndL, xTent, allCoords)
            
            % Get the current position of the mouse
            [mx, my, buttons] = GetMouse(windowPtr);
            
            % draw mouse
            Screen('DrawDots', windowPtr, [mx my], 5, [0 0 0], [], 2);
            
            nextSelected = IsInRect(mx, my, nextRect);
            
            % listen for keyboard input
            [keyIsDown, secs, keyCode]=KbCheck;
            buttonPressed =find(keyCode);
            enterpressed=~isempty(intersect(buttonPressed,enterKey)); %press return key to terminate each response
            enterpressed = enterpressed||(nextSelected && buttons(1)>0); % also accept click in 'next' box to advance.
            if keyIsDown && ~enterpressed %keeps track of key-presses and draws text
                if ~isempty(intersect(buttonPressed,deleteKey)); %if delete key then erase last key-press
                    respBuffer=respBuffer(1:end-1); %erase last key-press
                    pause(.07) % avoid stacked responses from a single button press (70ms)
                else %otherwise add to buffer
                    respBuffer=[respBuffer KbName(buttonPressed(1))]; %adds key to buffer
                    respBuffer = cell2mat(regexp(respBuffer, '(\d|\.)', 'match')); % in case people use the top row of keys and get weird stuff like "9("
                    pause(.1) % pause 100ms to avoid key hold errors
                    
                end
            elseif enterpressed
                gotToNextPhase = 4;
            end
            
            DrawFormattedText(windowPtr, sprintf(playGrndInstTxt{1}), xTent, screenYpixels*.3, foreGrndL); %draws keys pressed
             
            %DrawFormattedText(windowPtr, respBuffer, xTent+buffReg*screenXpixels, screenYpixels*.5, foreGrndL); %draws keys pressed
            DrawFormattedText(windowPtr, respBuffer, nextRect(1)-1.5*textSize, screenYpixels*.5, foreGrndL); %draws keys pressed
            
            % response box
            Screen('FrameRect', windowPtr, foreGrndD, [nextRect(1)-2*textSize .5*screenYpixels-.5*textSize nextRect(3)+2*textSize .5*screenYpixels+1.5*textSize], 2);
                   
            
            % grid lines?
            if strcmpi(sExpName, 'glyphLearning2')
                gridLinesIn=[];
                for i = 1:length(yAxisVal)
                    gridLinesIn = [gridLinesIn [allCoords(1,1)-5 xTent; yAxisVal(i) yAxisVal(i)]];
                end
                Screen('DrawLines', windowPtr, gridLinesIn, 1, gridLineCol); % alpha of .2
            end
            
            Screen('Flip', windowPtr);
        end
        
        endOfDayDiff=endOfDayDiff(~isnan(allRects(1,:))); % end of day diff = open-close. find one for this candle.
        if endOfDayDiff>0; closedHigher=0; else closedHigher=1; end 
        
        datShadow=shadowRects(shadowRects>0);
        
        % set participant guess to right answer
        participantShadows = datShadow;
        participantColour = colourOut(~isnan(colourOut));
        participantCandle = allRects(~isnan(allRects));
        
        errorRec = 0; 
        dollarConvertedAns=0;
        madeResponse = 1;
        if isempty(respBuffer) || numel(regexp(respBuffer, '(\.)', 'match'))>1
            % max punishment
            errorVal = allowableErrorToZero; participantCandle=zeros(4,1);
            respBuffer='0';
            madeResponse = 0;
        elseif ((questionID == 2)&&closedHigher)||(questionID == 1 && ~closedHigher)  % asking about top of candle body
            dollarFromTop=highestYVal-.5-str2num(respBuffer);
            pixelConvertedResp = axisToppx+dollarFromTop*dollarHeightRatio;
            dollarConvertedAns = highestYVal-.5-(abs(axisToppx-participantCandle(2,1)))/dollarHeightRatio;
            % punishment is difference between converted response and
            % actual value candle value - top of candle body
            errorVal = abs(min(participantCandle([2,4],1))-pixelConvertedResp);
            participantCandle(2,1)=pixelConvertedResp;
        elseif ((questionID == 1)&&closedHigher)||(questionID == 2 && ~closedHigher)  % asking about bottom of candle body
           dollarFromTop=highestYVal-.5-str2num(respBuffer);
            pixelConvertedResp = axisToppx+dollarFromTop*dollarHeightRatio;
            % punishment is difference between converted response and
            % actual value candle value - bottom of candle body
            errorVal = abs(max(participantCandle([2,4],1))-pixelConvertedResp);
            dollarConvertedAns = highestYVal-.5-(abs(axisToppx-participantCandle(4,1)))/dollarHeightRatio;
            participantCandle(4,1)=pixelConvertedResp;
        elseif questionID ==3 % asking about highest point on the top shadow
            dollarFromTop=highestYVal-.5-str2num(respBuffer);
            pixelConvertedResp = axisToppx+dollarFromTop*dollarHeightRatio;
            % punishment is difference between converted response and
            % actual value of the shadow - top of top shadow
            errorVal = abs(participantShadows(2,1)-pixelConvertedResp); % smallest of all y values; highest on screen
            dollarConvertedAns = highestYVal-.5-(abs(axisToppx-participantShadows(2,1)))/dollarHeightRatio;
            participantShadows(2,1) = pixelConvertedResp;
        elseif questionID ==4 % asking about lowest point on the bottom shadow
            dollarFromTop=highestYVal-.5-str2num(respBuffer);
            pixelConvertedResp = axisToppx+dollarFromTop*dollarHeightRatio;
            % punishment is difference between converted response and
            % actual value of the shadow - top of top shadow
            errorVal = abs(participantShadows(8,1)-pixelConvertedResp); % largest of all y values; lowest on screen
            dollarConvertedAns = highestYVal-.5-(abs(axisToppx-participantShadows(8,1)))/dollarHeightRatio;
            participantShadows(8,1)=pixelConvertedResp;
        end
        
        if errorVal > allowableErrorToZero*4; errorVal=allowableErrorToZero*4; end
        
        [vblOn4, phase5Onset] = Screen('Flip', windowPtr);
        
        cumulativePts = cumulativePts + round(allowableErrorToZero-errorVal);
        if errorVal < -allowableErrorToZero*4; errorVal=-allowableErrorToZero*4; end
        simulated100 = allRects(~isnan(allRects));
        
        if (allowableErrorToZero-errorVal)<=0
            puncStart = '';
            puncEnd = '.';
        else
            puncStart = '+';
            puncEnd = '!';
        end
        
        %% Phase 4: Feedback
        while gotToNextPhase == 4
            
            [newX,newY]=Screen('DrawText', windowPtr, [puncStart num2str(round(allowableErrorToZero-errorVal)) ' points' puncEnd], xTent+10, mean([simulated100(2),simulated100(4)])+50, foreGrndL, bkgnCol(1));
             
            candleFrameStimuli(xTent, screenXpixels, screenYpixels, bkgnCol, allCoords, trialOrder(trialNumber), dataSample, placeHolder, windowPtr, 101, highestYVal, foreGrndL, spreadFactor);
            
            % Get the current position of the mouse
            [mx, my, buttons] = GetMouse(windowPtr);
            
            % draw mouse
            Screen('DrawDots', windowPtr, [mx my], 5, [0 0 0], [], 2);
            nextSelected = IsInRect(mx, my, nextRect);
            
            % grid lines?
            if strcmpi(sExpName, 'glyphLearning2')
                gridLinesIn=[];
                for i = 1:length(yAxisVal)
                    gridLinesIn = [gridLinesIn [allCoords(1,1)-5 xTent; yAxisVal(i) yAxisVal(i)]];
                end
                Screen('DrawLines', windowPtr, gridLinesIn, 1, gridLineCol); % alpha of .2
            end
            
            if triCandleFlag
                [allRectsNowTriangle, placementRectsNowTriangle]= rect2TriCandle(simulated100, [], endOfDayDiff, candleCol, [], windowPtr,0);
            else
                % Draw the rect to the screen
                Screen('FillRect', windowPtr, colourOut', allRects);
            end
            
            Screen('FillRect', windowPtr, shadowCol, shadowRects(1:4,:)); % upper shadow
            Screen('FillRect', windowPtr, shadowCol, shadowRects(5:8,:)); % lower shadow
            
            if madeResponse==0; 
                
                Screen('DrawText', windowPtr, 'No response collected. No points awarded. Please make your best guess next time. ', xTent-textSize*50, nextRect(2)-textSize*2, foreGrndL, bkgnCol(1));
                
            end
            
            if displayFeedbackInfo
                % to visualize the new participant rect that informs the error val
                [errorVal2, errorRec2]= candleErrorCalculator(candleCol, allRects(~isnan(allRects)), participantColour, ...
                    datShadow(1:4), datShadow(5:8), participantCandle, participantColour, [participantShadows(1:4) participantShadows(5:8)]);
                debugRec(trialNumber,1) = dollarConvertedAns;
                debugRec(trialNumber,2) = dollarFromTop;
                debugRec(trialNumber,3) = questionID;
                debugRec(trialNumber,4) = errorVal;
                debugRec(trialNumber,5) = str2num(respBuffer);
                debugRec(trialNumber,6) = highestYVal;
                debugRec(trialNumber,7) = closedHigher;
                debugRec(trialNumber,8) = participantColour(1);
                debugRec(trialNumber,9) = errorVal2;
                
                tickMarker=[]; dollarMarker=[];
                Screen('FrameRect', windowPtr, foreGrndL, [participantCandle(1,1) min(participantCandle([2 4],1)) participantCandle(3,1) max(participantCandle([2,4],1))], 2);
                Screen('FrameRect', windowPtr, foreGrndD, [participantShadows(1,1) min(participantShadows([2 4],1)) participantShadows(3,1) max(participantShadows([2,4],1))], 2);
                Screen('FrameRect', windowPtr, foreGrndD, [participantShadows(5,1) min(participantShadows([6 8],1)) participantShadows(7,1) max(participantShadows([6,8],1))], 2);
                [newX,newY]=Screen('DrawText', windowPtr, ['"expected": ' num2str(dollarConvertedAns)], xTent+10, mean([simulated100(2),simulated100(4)])+50, foreGrndL, bkgnCol(1));
                [newX,newY]=Screen('DrawText', windowPtr, ['highest Y should be : ' num2str(highestYVal)], xTent+10, mean([simulated100(2),simulated100(4)])+100, foreGrndL, bkgnCol(1));
                [newX,newY]=Screen('DrawText', windowPtr, ['participant candle : ' num2str([participantCandle(2,1) participantCandle(4,1)])], ...
                    50, 150, foreGrndL, 0);
                [newX,newY]=Screen('DrawText', windowPtr, ['stimulus candle : ' num2str([simulated100(2,1) simulated100(4,1)])], ...
                    50, mean([simulated100(2),simulated100(4)])+200, foreGrndL, bkgnCol(1));
                
                for i=1:length(yAxisVal)
                    tickMarker = [tickMarker [allCoords(1,1)-5 allCoords(1,1)+10; yAxisVal(i) yAxisVal(i)]];
                    dollarMarker = [dollarMarker [allCoords(1,1)-5 allCoords(1,1)+10; min(allCoords(2,:))+i*dollarHeightRatio min(allCoords(2,:))+i*dollarHeightRatio]];
                    Screen('DrawLines', windowPtr, tickMarker, 2, foreGrndL);
                    Screen('DrawLines', windowPtr, dollarMarker, 2, foreGrndD);
                end
            end
            
            [trialEndVbl, trEndOff]=Screen('Flip', windowPtr);
            endTime = clock;
            if nextSelected && buttons(1)>0
                % save trial data
                [trialEndVbl, phase5Offset]=Screen('Flip', windowPtr);
                
                candleSaveTrialLvl(timeIDDir, sExpName, subjectNumber, trialNumber, madeResponse, errorVal, [1 2], ...
                    [0 0 0], colourOut(~isnan(colourOut))', simulated100, datShadow, [[participantCandle(1,1) min(participantCandle([2 4],1)) participantCandle(3,1) max(participantCandle([2,4],1))]' [participantShadows(1,1) min(participantShadows([2 4],1)) participantShadows(3,1) max(participantShadows([2,4],1))]' [participantShadows(5,1) min(participantShadows([6 8],1)) participantShadows(7,1) max(participantShadows([6,8],1))]'],...
                    vblOn1, vblOn2, vblOn3, vblOn4, trialEndVbl, trialOrder, whichMod, ...
                    columnOrder,xTent, testIfTimeUp, 1, 0, ... % not recording diff, as we want to read the candle as standard orientation in interpreting open/close in this exp.
                    1, 2, 3, dataSample, endTime, respBuffer, cumulativePts, bet, betErrorClose)

                save([timeIDDir '/trial' num2str(trialNumber) '.mat'], ...
                    'vblOn1', 'vblOn2', 'vblOn3', 'vblOn4', 'errorVal', 'errorRec', 'startTime', 'endTime', 'candleCol', 'participantCandle', 'participantShadows', 'datShadow', 'allRects', 'colourOut', 'highestYVal', 'trialEndVbl', 'testIfTimeUp', 'questionID', 'screenXpixels', 'screenYpixels')
                
                gotToNextPhase = 1;
            end
        end
    end
    % closing/debrief phase; set experiment end time and save demo info.
    [subjectID, populateRowExpLvl] = blowOutTheCandle(windowPtr, populateRow, screenXpixels, screenYpixels, foreGrndL, bkgnCol, xTent, demoResp, timeIDDir);
    
    ShowCursor()
    
    
    % save the experiment level data
    candleSaveExpLvl(subjectID, columnOrder, candleCol, startTime, endTime, timeIDDir, demoResp, screenXpixels, screenYpixels, noiseSource, sExpName, trialNumber, cumulativePts, shadowCol, spreadFactor)
    
    % Clear the screen
    Screen('Close', windowPtr)
    sca;
    dbstop if error
    
catch
    dbstop if error
    ShowCursor()    
    display('')
    display('')
    display('')
    display('')
    display('')
    display('')
    display('')
    display('')
    display('Thank you for your time today! ')
    display('Please exit the booth and tell the experimenter that you have finished.')
    display('')
    display('')
    
    % Clear the screen
    sca;
    
   
    psychrethrow(psychlasterror);
end