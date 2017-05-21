%  Here's a function that searches recursively through all subdirectories of a given directory, collecting a list of all file names it finds 
%  
%  Author: [gnovice] 
%  Date Created: [Date of Creation] 
%  Last Edit: 	edited Apr 17 '10 at 1:56
%  
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
%  Additional Comments: http://stackoverflow.com/questions/2652630/how-to-get-all-files-under-a-specific-directory-in-matlab

function fileList = getAllFiles(dirName)

  dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
  end

end