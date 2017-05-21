%  Draw a histogram to visually represent scenarios used in the
%  Kahneman & Tversky (1979) prospect theory paper
%  
%  Author: C. M. McColeman
%  Date Created: November 28 2016
%  Last Edit: 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: thesis introduction; illustrative example
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: 
%  
%  OUTPUT: 
%  
%  Additional Scripts Used: [Insert all scripts called on] 
%  
%  Additional Comments: Requires permission to save to ~/pictures

nSamples = 1000; 
dataSampleIdx = [1,2,3,4];


%% problem set 1

% 1) choose between 
% A: $2500, p=.33; $2400, p=.66; 0, p=0.01
labelVal{1,1} = {'$2500', '$2400', '$0'};
wm(1,1,1:3) = [.33, .66, .01];
xLoc{1,1} = [2500, 2400, 0]
% B: $2400, p=1.0;
labelVal{1,2} = {'$2400'};
wm(1,2,1:3) = [1];
xLoc{1,2} = [2400]

% 2) choose between
% C: $2500, p =.33; 0, p=.67
labelVal{2,1} = {'$2500', '$0'};
wm(2,1,1:3) = [.33, .67, 0];
xLoc{2,1} = [2500, 0];
% D: $2400, p =.34; 0, p=.66
labelVal{2,2} = {'$2400', '$0'};
wm(2,2,1:3) = [.34, .66, 0];
xLoc{2,2} = [2400, 0];
% Kahneman & Tversky observed that 82% chose B, 83 % chose C. 


%% problem set 2

% 3) choose between 
% A: $4000, p=.80; $0, p=.20
labelVal{3,1} = {'$4000', '$0'};
wm(3,1,1:3) = [.8, .2, 0];
xLoc{3,1} = [4000, 0];
% B: $3000, p=1.0;
labelVal{3,2} = {'$3000'};
wm(3,2,1:3) = [1, 0, 0];
xLoc{3,2} = [3000];

% 4) choose between
% C: $4000, p =.20;
labelVal{4,1} = {'$4000', '$0'};
wm(4,1,1:3) = [.2, .8, 0];
xLoc{4,1}=[4000, 0];
% D: $3000, p =.25;
labelVal{4,2} = {'$3000', '$0'};
wm(4,2,1:3) = [.25, 0, 0];
xLoc{4,2}=[3000, 0];
% Kahneman & Tversky observed that 80% chose B, 65% chose C. 

%% problem set 3

% Note: it's hard to represent this in time without choosing for the observer that
% one week in each of the three countries is equally valuable

% 5) choose between 
% A: 50% win a 3 week tour of 3 countries 
labelVal{5,1}={'3 week tour of ENG, FRA, & ITL', 'no tour of any country'}
wm(5,1,1:3) = [.5, .5, 0];
xLoc{5,1}=[1, 2];
% B: 100% win a 1 week tour of 1 country
labelVal{5,2}={'1 week tour of ENG'}
wm(5,2,1:3) = [1, 0, 0];
xLoc{5,2}=1;
% 6) choose between
% C: 5% win a 3 week tour of 3 countries
labelVal{6,1}={'3 week tour of ENG, FRA, & ITL', 'no tour of any country'}
wm(6,1,1:3) = [.05, .95, 0];
xLoc{6,1} = [1, 2];
% D: 10% win a 1 week tour of 1 country
labelVal{6,2}={'1 week tour of ENG', 'no tour of any country'}
wm(6,2,1:3) = [.1, .9, 0];
xLoc{6,2} = [1, 2];

%% problem set 4

% 7) choose between 
% A: $6000, p=.45; $0, p=.55
labelVal{7,1} = {'$6000', '$0'};
wm(7,1,1:3) = [.45, .55, 0];
xLoc{7,1} = [6000, 0]

% B: $3000, p=.9;
labelVal{7,2} = {'$3000' '$0'};
wm(7,2,1:3) = [.9, .1, 0];
xLoc{7,2} = [3000, 0];

% 8) choose between
% C: $6000, p =.001;
labelVal{8,1} = {'$6000', '$0'};
wm(8,1,1:3) = [.001, .999, 0];
xLoc{8,1} = [6000, 0];

% D: $3000, p =.002;
labelVal{8,2} = {'$3000', '$0'};
wm(8,2,1:3) = [.002, .998, 0];
xLoc{8,2} = [3000, 0];

for i = 1:8
    thisSetRange = [min([xLoc{i,1} xLoc{i,2}]) max([xLoc{i,1} xLoc{i,2}])];
    vizBuffer = .2*diff(thisSetRange);
    
    if mod(i,2)
       choiceTitle = {'A', 'B'};
    else
        choiceTitle = {'C', 'D'};
    end
    
    figure;
    subplot(1,2,1)
    data2D{i,1} = reshape(wm(i,1,1:numel(xLoc{i,1})),1,numel(xLoc{i,1}));
    bar(xLoc{i,1},data2D{i,1},.4,'hist');
    xlim([thisSetRange(1)-vizBuffer thisSetRange(2)+vizBuffer])
    ylim([0 1])
    xlabel('Possible Outcomes')
    ylabel('Probability of Obtaining Outcome')
    title(['Question ' num2str(i) ', Choice ' choiceTitle{1}])
    
    % edit axes
    axesEdit = gca;
    axesEdit.XTick = [thisSetRange(1) thisSetRange(1)+diff(thisSetRange)/2 thisSetRange(2)]
    
    subplot(1,2,2)
    data2D{i,2} = reshape(wm(i,2,1:numel(xLoc{i,2})),1,numel(xLoc{i,2}));
    bar(xLoc{i,2},data2D{i,2},.4,'hist');
    xlim([thisSetRange(1)-vizBuffer thisSetRange(2)+vizBuffer])
    ylim([0 1])
    xlabel('Possible Outcomes')
    ylabel('Probability of Obtaining Outcome')
    title(['Question ' num2str(i) ', Choice ' choiceTitle{2}])
    
    % edit axes
    axesEdit = gca;
    axesEdit.XTick = [thisSetRange(1) thisSetRange(2)/2 thisSetRange(2)]
    
    
end
