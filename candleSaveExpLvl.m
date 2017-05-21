function candleSaveExpLvl(subjectID, columnOrder, candleCol, startTime, endTime, timeIDDir, demoResp, screenXpixels, screenYpixels, noiseSource, sExpName, trialNumber, cumulativePoints, shadowCol, spreadFactor)
%  Saves critical experiment level information in a SQL-friendly format
%  
%  Author: C. M. McColeman
%  Date Created: Oct 13 2016
%  Last Edit: 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: 6ix
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
%  Additional Comments: 

%sExpName self set
SubjectNumber = subjectID;
OpenColumn = num2str(columnOrder(1));
CloseColumn = num2str(columnOrder(2));
HighColumn = num2str(columnOrder(3));
LowColumn = num2str(columnOrder(4));
CloseLowColour = num2str(candleCol{1});
CloseHighColour = num2str(candleCol{2});
ShadowColour = mat2str(shadowCol);
StartTimeClock = mat2str(startTime);
EndTimeClock = mat2str(endTime);
%TIMEIDDIRself set
Booth = num2str(demoResp{1});
ComputerType = num2str(demoResp{2});
Gender = num2str(demoResp{3});
ColourBlindStatus = num2str(demoResp{4});
EconExperience = num2str(demoResp{5});
MathExperience = num2str(demoResp{6});
%ScreenXPixels self set
%ScreenYPixels self set
if isempty(noiseSource); noiseSource = 0; end
% spreadFactor self set

fileID = fopen('candleLearningExpLvl.csv', 'at'); % open file to append data

% add a row the explvl table
fprintf(fileID,'%s ; %s ; %s ; %s ; %s ; %s ; %s; %s ; %s; %s; %s ; %s; %s; %s; %s; %s; %s; %d; %d; %d; %d; %f; %s\r\n', ...
    sExpName, SubjectNumber, OpenColumn, CloseColumn, HighColumn, LowColumn, CloseLowColour, CloseHighColour,...
    StartTimeClock, EndTimeClock, timeIDDir, Booth, ComputerType, Gender, ColourBlindStatus, ...
    EconExperience, MathExperience, screenXpixels, screenYpixels, noiseSource, trialNumber, cumulativePoints, ShadowColour, spreadFactor);

fclose(fileID)

display('experiment level data successfully saved..')

display('.. and committed. ')