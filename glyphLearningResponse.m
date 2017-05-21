function glyphLearningResponse(windowPtr, nextRect, questionID, bkgnCol, textCol, xTent, allCoords)
%  called by glyphLearning.m. Asks the participant a question about the
%  value of the stimulus.
%  
%  Author: C. M. McColeman
%  Date Created: September 17 2016
%  Last Edit:  
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: 6ix - glyphLearning
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: windowPtr [int], points to screenID
%         nextRect [matrix of doubles], the "next" button rectangle coordinates; 
%         questionID [int], which of the four dimensions are queried?
%         bkgnCol [matrix of RGB vals], the background colour
%         textCol [matrix of RGB vals], the text colour
%  
%  OUTPUT: [Insert Outputs of this script] 
%  
%  Additional Scripts Used: [Insert all scripts called on] 
%  
%  Additional Comments: 

questionArray{1,1} = {'What is the opening price?'};
questionArray{2,1} = {'What is the closing price?'};
questionArray{3,1} = {'What is the highest price?'};
questionArray{4,1} = {'What is the lowest price?'};

DrawFormattedText(windowPtr, sprintf(questionArray{questionID,1}{1}), xTent-50, min(allCoords(2,:))-.25*min(allCoords(2,:)), textCol);


