%  For writing methods, it'll be helpful to have a possible range of values
%  given differnt random selections of model properties in
%  VARBasedDataGen.m. 
%  
%  Author: Caitlyn McColeman
%  Date Created: Mar 26 2017
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
%  Additional Scripts Used: VARBasedDataGen
%  
%  Additional Comments: 


 modelOut1 = VARBasedDataGen;
 modelOut2 = VARBasedDataGen;
 modelOut3 = VARBasedDataGen;
 
 modelOut = [modelOut1 modelOut2 modelOut3]
 
 dataSample=[];
 % the exact manner in which data values are constructed in
 % candleBuildExpConds. Simulate each model and record the output.
 % Structured as a big matrix for easier analysis
 for i = 1:length(modelOut)
     for j = 1:10
         dataSample= [dataSample; vgxsim(modelOut{i}, 100)];
     end
 end