%  For the first few participants, I hadn't constrained the possible error
%  value. I will leave the original column in case the experience of
%  receiving a woefully bad score in response to a typo is interesting,
%  but right now it's at risk of providing erroneous influential datapoints
%  in the error value data analysis. This column replaces any crazy
%  instances of errorVal with the contrained values that later
%  participants saw. The new column will be used for analyses moving
%  forward. 
%  
%  Author: Caitlyn McColeman
%  Date Created: June 8 2017
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
%  OUTPUT: actualErrorVal: a column that can be uploaded to SQL and used in
%       place of errorVal.
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: Sign into SQL as superprivilged user to upload
%  data.


MaybeOpenMySQL('experiments')

[errorVal, rowID, experimentName] = mysql('select errorVal, rowID, sExpName from candlesTrialLvl');

mysql('closeall')

glyphIdx=~cellfun(@isempty,regexp(experimentName,'gly'));
drawSeriesIdx=~cellfun(@isempty,regexp(experimentName,'drawS'));

errorValAsNum = cellfun(@str2num, errorVal);

over2000 = errorValAsNum>2000;
over625 = errorValAsNum>625;

updateErrorVal = errorValAsNum; % initialize to observed value
updateErrorVal(rowID(glyphIdx&over625)) = 625;
updateErrorVal(rowID(drawSeriesIdx&over2000))=2000;

% for the superprivileged user. This should only be run once.
%{

mysql(['alter table candlesTrialLvl add actualErrorVal DOUBLE NOT NULL']);

for i=1:length(updateErrorVal)
    mysql(['update candlesTrialLvl set actualErrorVal = ' num2str(updateErrorVal(i)) ' where RowID = ' num2str(rowID(i))]);
end


%}

