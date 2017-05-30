%  At the start of the running day, I'd load the experiments to make sure
%  they were running properly and this sometimes made a nonsense entry at experiment
%  level. Other times, some dudebro would change the computer type after
%  being asked not to, and so I'd quickly jump into the experiment by
%  by-passing the demographic quesitons after restarting the program. That means
%  that person's demo info isn't entered. This script helps with that sort
%  of thing.
%
%  This follows three steps to flag questionable entries at experiment and
%  trial level for the candle series studies.
%{
0) update trial level so it has the booth number as part of the subject ID
to align with experiment level
1) does the timeIdDir folder exist?
- if no; kill row
- if yes; proceed to ..
2) does the time timeIDDir folder contain >5 trials' worth of data?
- if no; kill row
- if yes; proceed to ..
3) do all of the demoResp values correspond to "prefer not to answer"?
- if no; retain as probably usable explvl entry.
- if yes; this might correspond to a more meaningful response that yielded an error upon loading.
This happened about three times. Match to the closest data directory from that computer
if we need that high level demographic information.
%}
%
%  Author: C. M. McColeman
%  Date Created: November 11 2016
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: []
%  Verified: []
%
function fileCongruenceChk(rawExpLvl)

%  INPUT:
%   rawExpLvl: a string; the title of .csv file constructed by concatenating the
%  experiment level files from the running room computers.
%   rawTrialLvl: a string; the title of .csv file constructed by concatenting the trial level
%   files from the running room computers. (e.g. in terminal: cat **/*.csv > collapsedTrials.csv)
%
%  OUTPUT:
%   expLvlToLoad: a .csv experiment level file ready for SQL
%   trialLvlToLoad: a .csv experiment level file ready for SQL
%
%  Additional Scripts Used:
%
%  Additional Comments: This function assumes that you're on a machine with
%  all of the data in a single directory (C.M. 13" MacBook or the Powerhouse
%  computer) and that you've navigated to said directory (~/documents/caitlyn/data/... )

expLvlIn = readtable(rawExpLvl,'Delimiter',';','ReadVariableNames',true);
expLvlDims = size(expLvlIn);

timeIDDirCongruence = nan(expLvlDims(1), 1); % intialize record of whether the timeIDDir is at trial lvl
%trLvlIn = readtable(rawTrialLvl,'Delimiter',';','ReadVariableNames',true);

% get the list of files in the current directory
fileList = getAllFiles(pwd);

% filter for files that are triallvl.csv
charTrLvl = strfind(fileList, 'trialLvl.csv');

currDir = pwd;
additionalLinesExp= 0;

% 0)
% update trial level so it has the booth number as part of the subject ID
% to align with experiment level

% loop through string comparison output, manipulate files that are
% trialLvl.csv
appendToExpLvl = table();
for i = 1:length(charTrLvl)
    
    if ~isempty(charTrLvl{i})
        
        % record booth #
        pathToFileCell = strsplit(fileList{i},'/');
        boothNum = pathToFileCell{8}; % this may differ on machines. Hard coded but user should confirm.
        
        % record directory name
        dirName = pathToFileCell{end-1};
        if numel(findstr(dirName, '_'))<2; dirName='notRawSubjectData'; continue; end
        % are we in a sub-directory (e.g. 3/properlvl)?
        if ~(strcmpi(boothNum, pathToFileCell{end-2}))
            appendDir = ['/' pathToFileCell{end-2}];
        else
            appendDir = '/'; %no subdirectory
        end
        
        % 1) does the directory name exist as timeIDDir in experiment
        % level?
        dirSucessRec = strfind(expLvlIn.timeIDDir,dirName);
        dirSucessRec=cellfun(@numel, dirSucessRec);
        dirSucessRecIdx = max(find(dirSucessRec));
        
        timeIDDirCongruence(dirSucessRecIdx)=1;
        % load trial level .csv file
        orgTabIn = readtable(fileList{i}, 'delimiter', ';', 'headerlines', 0, 'readvariablenames', true);
        orgTabDims = size(orgTabIn);
        
        if ~(orgTabDims(1)<6) ...  % 2) fewer than five trials is nonsense data/false starts
                && sum(dirSucessRec)==1 % 1) does the directory name uniquely exist as timeIDDir
            % && (expLvlIn.Gender(dirSucessRec{i}))
            
            % create columns to append to table
            boothNumRec = repmat(boothNum, orgTabDims(1), 1);
            dirNameRec = repmat(dirName, orgTabDims(1), 1);
            fullSubID = [cell2mat(orgTabIn.Subject) repmat('_', orgTabDims(1), 1) boothNumRec];
            if sum(cell2mat(strfind(orgTabIn.sExpName, 'glyph')))>0
                k = 0;
                clear includeIdx isMat filesAsCells filesInDir upperDir
                
                % get the question ID from the triallvl .mat file
                upperDir = strrep(fileList{i}, 'trialLvl.csv', '');
                filesInDir = ls(upperDir);
                filesAsCells = strsplit(filesInDir);
                isMat = strfind(filesAsCells, '.mat');
                includeIdx = ~(cellfun(@isempty, isMat));
                
                for k = 1:sum(includeIdx)

                    load([upperDir ['trial' num2str(k) '.mat']])
                    questionIDRec(k,1)= questionID;
                    
                end
                
            else
                questionIDRec = nan(length(fullSubID),1, 1);
            end
            tabAppend = table(boothNumRec, dirNameRec, fullSubID, questionIDRec);
            tableOut = [orgTabIn tabAppend];
            clear questionIDRec
            % save to file
            writetable(tableOut,[currDir '/' boothNumRec(1) '/' cell2mat(orgTabIn.Subject(1)) '_' num2str(boothNum) 'edited_trialLvl.csv'],'Delimiter',';')
        elseif sum(dirSucessRec)==0
            
            additionalLinesExp = additionalLinesExp+1;
            display(['missing ' dirName ' in experiment level'])
            display(['gathering info in a separate process via buildExpLvlLine.m'])
            
            % add experiment level data to the raw exp lvl file.
            buildExpLvlLine(dirName, [boothNum appendDir], {rawExpLvl});
            
        elseif (expLvlIn.Gender(dirSucessRecIdx)==5 && (expLvlIn.EconExperience(dirSucessRecIdx)==5 && expLvlIn.MathExperience(dirSucessRecIdx)==7 && expLvlIn.ColourBlindStatus(dirSucessRecIdx)==7))
            display(['all survey responses are "prefer not to answer": ' dirName])
        else
            display(['not captured, but not cuz of exclusion criteria? check ' dirName])
        end
        
    end
    
end

 expTabUpdate = table(timeIDDirCongruence);

 expTableOut = [expLvlIn expTabUpdate];
 writetable(expTableOut,[currDir '/edited/CandleExpLvl.csv'],'Delimiter',';')

end
