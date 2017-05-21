% a wrapper for candleTrialViewer to create a couple samples of one of each
% kind of stimulus for each of the six existing experiments (as of Apr 28)
%  
%  Author: C. M. McColeman
%  Date Created: Apr 28 2017
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
%  OUTPUT:
%  
%  Additional Scripts Used: [Insert all scripts called on] 
%  
%  Additional Comments: 
nTrialID = 10;
sTopLvlDataDir = '~/documents/data/candles/spring2017'; 

% [experiment 1] glyphLearning1 
fullSubID_GL1_1 = '9_0_5'

candleTrialViewer(fullSubID_GL1_1, nTrialID, sTopLvlDataDir)
set(gcf,'PaperPositionMode','auto')
fig = gcf;
fig.InvertHardcopy = 'off';
saveas(fig, ['~/pictures' fullSubID_GL1_1 ], 'jpg')

% [experiment 2] glyphLearning2 
fullSubID_GL2_1 = '78_0_7';

candleTrialViewer(fullSubID_GL2_1, nTrialID, sTopLvlDataDir)
set(gcf,'PaperPositionMode','auto')
fig = gcf;
fig.InvertHardcopy = 'off';
saveas(fig, ['~/pictures' fullSubID_GL2_1 ], 'jpg')

% [experiment 3] drawSeries1 (three conditions to date)
fullSubID_DS1_1 = '89_0_7';

candleTrialViewer(fullSubID_DS1_1, nTrialID, sTopLvlDataDir)
set(gcf,'PaperPositionMode','auto')
fig = gcf;
fig.InvertHardcopy = 'off';
saveas(fig, ['~/pictures' fullSubID_DS1_1 ], 'jpg')


fullSubID_DS1_2 = '11_0_8';
fullSubID_DS1_3 = '84_0_8';
