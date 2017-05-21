sExpName = 'drawSeries'
%  [Insert a description of the script's intended function here] 
%  
%  Author: [Author's Name] 
%  Date Created: [Date of Creation] 
%  Last Edit: [Last Time of Edit] 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: [Insert Name of Project] 
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

[startTime, endTime] = mysql(['select startTimeClock, endTimeClock from candlesExpLvl where ExpName = ''' sExpName '''']);

