%  A quick look at histograms, condition properties
%
%  Author: C. M. McColeman
%  Date Created: Mar 6 2017
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix; drawSeries and glyphLearning.m
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
%  Additional Comments:


%% drawSeries

[nTrials, cumulPoints, candCond, expSubNum]=mysql(['select trialsCompleted, TotalPoints, candleCondition, subjectNumber from candlesExpLvl where ExpName = ''' sExpName '''']);

% data to calculate error associated with each dimension
[corrOpen, corrClose, corrHigh, corrLow, ...
    respOpen, respClose, respHigh, respLow, subID, trID, errorVal, correctColour] = mysql(['select ' ...
    'CorrectAnswerOpen, CorrectAnswerClose, CorrectAnswerHigh, CorrectAnswerLow, ' ...
    'ParticipantAnswerOpen, ParticipantAnswerClose, ParticipantAnswerHigh, ParticipantAnswerLow, ' ...
    'fullSubID, trialId, errorVal, correctColour FROM candlesTrialLvl where sExpName = ''' sExpName '''' ]);

if strcmpi('glyphLearning', sExpName)
    yLimErr = 50;
elseif strcmpi('drawSeries', sExpName)
    yLimErr = 200;
    
end

% convert cell strings to numbers
%{
corrOpen = cellfun(@str2num, corrOpen);
corrClose = cellfun(@str2num, corrClose);
corrHigh = cellfun(@str2num, corrHigh);
corrLow = cellfun(@str2num, corrLow);

respOpen = cellfun(@str2num, respOpen);
respClose = cellfun(@str2num, respClose);
respHigh = cellfun(@str2num, respHigh);
respLow = cellfun(@str2num, respLow);

errOpen = abs(corrOpen-respOpen);
errClose = abs(corrClose-respClose);
errHigh = abs(corrHigh-respHigh);
errLow = abs(corrLow-respLow);

% no overall difference in points per trial via visual inspection
ppT = cumulPoints./nTrials;

A_ppT = ppT(strcmpi(candCond, '1'));
B_ppT = ppT(strcmpi(candCond, '2'));
C_ppT = ppT(strcmpi(candCond, '3'));
D_ppT = ppT(strcmpi(candCond, '4'));


subplot(2,2,1)
hist(A_ppT)
xlim([-100 500])
title('mean points per trial')
subplot(2,2,2)
hist(B_ppT)
xlim([-100 500])

subplot(2,2,3)
hist(C_ppT)
xlim([-100 500])

subplot(2,2,4)
hist(D_ppT)
xlim([-100 500])
%}
% trial index
nEarlyTr = 50;
under50Idx = trID <= nEarlyTr;

figure;

% prepping vis.
condAIdx = strcmpi(candCond, '1');
condBIdx = strcmpi(candCond, '2');
condCIdx = strcmpi(candCond, '3');
condDIdx = strcmpi(candCond, '4');

% some visualization details
colIn = {[1 0 0], [0 0 0], [0 .5 1], [.85 .85 .85]};

% intialize storage matrices (nans for the first nEarlyTr, for each subject
% in the study)
open_epT = nan(length(expSubNum), nEarlyTr, 1);
close_epT=open_epT;
high_epT=open_epT;
low_epT=open_epT;




meansInA = nanmedian(open_epT(condAIdx,:));
meansInB = nanmedian(open_epT(condBIdx,:));
meansInC = nanmedian(open_epT(condCIdx,:));
meansInD = nanmedian(open_epT(condDIdx,:));

scatter(1:nEarlyTr,meansInA, 50, colIn{1}, 'filled');
scatter(1:nEarlyTr,meansInB, 50, colIn{2}, 'filled');
scatter(1:nEarlyTr,meansInC, 50, colIn{3}, 'filled');
scatter(1:nEarlyTr,meansInD, 50, colIn{4}, 'filled');

%title('error associated with opening price')
%ylim([0 yLimErr])
figure

for i = 1:length(expSubNum)
    thisSubIdx = strcmpi(subID,expSubNum{i});
    if sum(thisSubIdx & under50Idx)>0 && sum(thisSubIdx & under50Idx) < (nEarlyTr + 1)
        
        nTrialsThisSub = sum(thisSubIdx & under50Idx);
        
        % early error per trial (trial < 50) associated with each dimension
        close_epT(i,1:nTrialsThisSub) = errClose(thisSubIdx & under50Idx)';
        
        hs=scatter(1:nTrialsThisSub, close_epT(i,1:nTrialsThisSub), 4);
        hold on;
        set(hs,'MarkerFaceColor',colIn{str2num(candCond{1})+1});
        
        close_epT(i,1:nTrialsThisSub) = errClose(thisSubIdx & under50Idx)';
        
    end
    
end


meansInA = nanmedian(close_epT(condAIdx,:));
meansInB = nanmedian(close_epT(condBIdx,:));
meansInC = nanmedian(close_epT(condCIdx,:));
meansInD = nanmedian(close_epT(condDIdx,:));

scatter(1:nEarlyTr,meansInA, 50, colIn{1}, 'filled');
scatter(1:nEarlyTr,meansInB, 50, colIn{2}, 'filled');
scatter(1:nEarlyTr,meansInC, 50, colIn{3}, 'filled');
%scatter(1:nEarlyTr,meansInD, 50, colIn{4}, 'filled');

title('error associated with closing price')
ylim([0 yLimErr])
figure;

for i = 1:length(expSubNum)
    thisSubIdx = strcmpi(subID,expSubNum{i});
    if sum(thisSubIdx & under50Idx)>0 && sum(thisSubIdx & under50Idx) < (nEarlyTr + 1)
        
        nTrialsThisSub = sum(thisSubIdx & under50Idx);
        
        % early error per trial (trial < 50) associated with each dimension
        high_epT(i,1:nTrialsThisSub) = errHigh(thisSubIdx & under50Idx)';
        
        hs=scatter(1:nTrialsThisSub, high_epT(i,1:nTrialsThisSub), 4);
        hold on;
        set(hs,'MarkerFaceColor',colIn{str2num(candCond{1})+1});
        
    end
    
end


meansInA = nanmedian(high_epT(condAIdx,:));
meansInB = nanmedian(high_epT(condBIdx,:));
meansInC = nanmedian(high_epT(condCIdx,:));
meansInD = nanmedian(high_epT(condDIdx,:));

scatter(1:nEarlyTr,meansInA, 50, colIn{1}, 'filled');
scatter(1:nEarlyTr,meansInB, 50, colIn{2}, 'filled');
scatter(1:nEarlyTr,meansInC, 50, colIn{3}, 'filled');
%scatter(1:nEarlyTr,meansInD, 50, colIn{4}, 'filled');

title('error associated with high price')
ylim([0 yLimErr])

figure;

for i = 1:length(expSubNum)
    thisSubIdx = strcmpi(subID,expSubNum{i});
    if sum(thisSubIdx & under50Idx)>0 && sum(thisSubIdx & under50Idx) < (nEarlyTr + 1)
        
        nTrialsThisSub = sum(thisSubIdx & under50Idx);
        
        % early error per trial (trial < 50) associated with each dimension
        low_epT(i,1:nTrialsThisSub) = errLow(thisSubIdx & under50Idx)';
        
        hs=scatter(1:nTrialsThisSub, low_epT(i,1:nTrialsThisSub), 4);
        hold on;
        set(hs,'MarkerFaceColor',colIn{str2num(candCond{1})+1});
        
    end
    
end

meansInA = nanmedian(low_epT(condAIdx,:));
meansInB = nanmedian(low_epT(condBIdx,:));
meansInC = nanmedian(low_epT(condCIdx,:));
meansInD = nanmedian(low_epT(condDIdx,:));

scatter(1:nEarlyTr,meansInA, 50, colIn{1}, 'filled');
scatter(1:nEarlyTr,meansInB, 50, colIn{2}, 'filled');
scatter(1:nEarlyTr,meansInC, 50, colIn{3}, 'filled');
%scatter(1:nEarlyTr,meansInD, 50, colIn{4}, 'filled');

title('error associated with low price')
ylim([0 yLimErr])


% 1) opening price
open_epTA = open_epT(strcmpi(candCond, '1'),:);
open_epTB = open_epT(strcmpi(candCond, '2'),:);
open_epTC = open_epT(strcmpi(candCond, '3'),:);
open_epTD = open_epT(strcmpi(candCond, '4'),:);

% 2) closing price
close_epTA = close_epT(strcmpi(candCond, '1'),:);
close_epTB = close_epT(strcmpi(candCond, '2'),:);
close_epTC = close_epT(strcmpi(candCond, '3'),:);
close_epTD = close_epT(strcmpi(candCond, '4'),:);

% 3) high price
high_epTA = high_epT(strcmpi(candCond, '1'),:);
high_epTB = high_epT(strcmpi(candCond, '2'),:);
high_epTC = high_epT(strcmpi(candCond, '3'),:);
high_epTD = high_epT(strcmpi(candCond, '4'),:);

% 4) low  price
low_epTA = low_epT(strcmpi(candCond, '1'),:);
low_epTB = low_epT(strcmpi(candCond, '2'),:);
low_epTC = low_epT(strcmpi(candCond, '3'),:);
low_epTD = low_epT(strcmpi(candCond, '4'),:);


% visualize dimensions in isolation, and then collapse

figure1 = figure;
axes1 = axes('Parent', figure1);
axes2=subplot(1,9,[1 8],axes1); % put the data on the majority of the subplot
axes3=subplot(1,9,9); %save one subplot as a legend
markerBreadth = .25;
hold all;

cols = distinguishable_colors(4,'w');
%
% for j = 1:length(expSubNum)
%
%     currCol = cols(candCond(j),:);
%
%     % draw a patch for each of the nEarlyTr for this subject where the data
%     % is available
%     for i = 1:nEarlyTr
%
%         plotVal = open_epTA(j,i);
%
%         if ~isnan(open_epTA(j,i))
%             fillHandle1 = fill([i-markerBreadth i-markerBreadth i+markerBreadth i+markerBreadth], ...
%                 [plotVal-markerBreadth plotVal+markerBreadth plotVal+markerBreadth plotVal-markerBreadth], ...
%                 currCol, 'edgecolor', 'none');
%             ptc=patch('Faces', fillHandle1.Faces, 'Vertices', fillHandle1.Vertices, ...
%                 'FaceColor', currCol, 'lineWidth', 0.1, 'lineStyle',...
%                 'none', 'EdgeColor', 'none'); hold on;
%             set(ptc,'edgealpha',.5)
%         end
%     end
%
% end
%
