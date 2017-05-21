function makeGlyphLearningTrialLvl(timeIDDir)
%  This is called at the end of experiment and creates a trial level .txt
%  file
%  
%  Author: C. M. McColeman
%  Date Created: October 11 2016
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

eval(['cd ' timeIDDir]) 

W = what(pwd);
filesInDir = W.mat;


subjectID = cell{1,length(filesInDir)};


for i = 1:length(filesInDir)
    load(filesInDir{i})
    
    subjectID = timeIDDir;
    
    
end