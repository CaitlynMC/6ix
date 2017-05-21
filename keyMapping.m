function [upKey, downKey, plusKey, minusKey, enterKey, fKey, rKey, vKey, aKey, deleteKey, leftKey, rightKey]=keyMapping(whichOS)
%  This returns the number corresponding to the up/down and plus/minus keys
%
%  Author: C. M. McColeman
%  Date Created: September 24 2016
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: Whether the user is on a Mac or PC
%
%  OUTPUT: Key mappings
%
%  Additional Scripts Used:
%
%  Additional Comments:

keyList = KbName('KeyNames');

fKey = find(strcmpi('f', keyList));
rKey = find(strcmpi('r', keyList));
vKey = find(strcmpi('v', keyList));
aKey = find(strcmpi('a', keyList));
deleteKey = [find(strcmpi('backspace', keyList)) find(strcmpi('delete', keyList))];

if whichOS == 1 %PC
    
    upKey = find(strcmpi('up', keyList));
    downKey = find(strcmpi('down', keyList));
    plusKey = find(strcmpi('+', keyList));
    minusKey = find(strcmpi('-', keyList));
    enterKey = [find(strcmpi('return', keyList)) find(strcmpi('enter', keyList))];
    leftKey = find(strcmpi('left', keyList));
    rightKey = find(strcmpi('right', keyList));
    
elseif whichOS > 1 %Mac
    upKey = 82; % searching 'upArrow' rather than 'up' on new mac. Hardcoded cuz I don't trust it.
    downKey = 81;
    plusKey =87;
    minusKey= 86; 
    enterKey = 40;
    leftKey = find(strcmpi('LeftArrow', keyList));
    rightKey = find(strcmpi('RightArrow', keyList));
end

