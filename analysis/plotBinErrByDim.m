%  
%  
%  Author: Caitlyn McColeman
%  Date Created: March 26 2017
%  Last Edit: [March 27 2017] 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: 6ix
%  
%  Reviewed: [Judi Azmand] 
%  Verified: [Robin C. A. Barrett] 
%  
%  INPUT: [Insert Function Inputs here (if any)] 
%  
%  OUTPUT: [Insert Outputs of this script] 
%  
%  Additional Scripts Used: errorOverTime
%  
%  Additional Comments: This is a wrapper function for errorOverTime

% call data

[openBinnedA, closeBinnedA, highBinnedA, lowBinnedA]=errorOverTime('drawSeries', '1');
[openBinnedB, closeBinnedB, highBinnedB, lowBinnedB]=errorOverTime('drawSeries', '2');
[openBinnedC, closeBinnedC, highBinnedC, lowBinnedC]=errorOverTime('drawSeries', '3');


[openBinnedGA, closeBinnedGA, highBinnedGA, lowBinnedGA]=errorOverTime('glyphLearning', '1');


% aggregate data - by dimension
m_openBinA = nanmean(openBinnedA);
m_openBinB = nanmean(openBinnedB);
m_openBinC = nanmean(openBinnedC); 
m_openBinGA = nanmean(openBinnedGA);
%m_openBinGB = nanmean(openBinnedGB);
%m_openBinGC = nanmean(openBinnedGC); 

m_closeBinA = nanmean(closeBinnedA);
m_closeBinB = nanmean(closeBinnedB);
m_closeBinC = nanmean(closeBinnedC); 
m_closeBinGA = nanmean(closeBinnedGA);

m_highBinA = nanmean(highBinnedA);
m_highBinB = nanmean(highBinnedB);
m_highBinC = nanmean(highBinnedC); 
m_highBinGA = nanmean(highBinnedGA);

m_lowBinA = nanmean(lowBinnedA);
m_lowBinB = nanmean(lowBinnedB);
m_lowBinC = nanmean(lowBinnedC); 
m_lowBinGA = nanmean(lowBinnedGA);



s_openBinA = sem(openBinnedA); 
s_openBinB = sem(openBinnedB); 
s_openBinC = sem(openBinnedC);
s_openBinGA = sem(openBinnedGA);

s_closeBinA = sem(closeBinnedA); 
s_closeBinB = sem(closeBinnedB); 
s_closeBinC = sem(closeBinnedC);
s_closeBinGA = sem(closeBinnedGA);

s_highBinA = sem(highBinnedA); 
s_highBinB = sem(highBinnedB); 
s_highBinC = sem(highBinnedC);
s_highBinGA = sem(highBinnedGA);

s_lowBinA = sem(lowBinnedA); 
s_lowBinB = sem(lowBinnedB); 
s_lowBinC = sem(lowBinnedC);
s_lowBinGA = sem(lowBinnedGA);

% aggregate data - over all
m_overallBinA = nanmean([openBinnedA; closeBinnedA; highBinnedA; lowBinnedA]);
m_overallBinB = nanmean([openBinnedB; closeBinnedB; highBinnedB; lowBinnedB]);
m_overallBinC = nanmean([openBinnedC; closeBinnedC; highBinnedC; lowBinnedC]);
m_overallBinGA = nanmean([openBinnedGA; closeBinnedGA; highBinnedGA; lowBinnedGA]);

s_overallBinA = sem([openBinnedA; closeBinnedA; highBinnedA; lowBinnedA]);
s_overallBinB = sem([openBinnedB; closeBinnedB; highBinnedB; lowBinnedB]);
s_overallBinC = sem([openBinnedC; closeBinnedC; highBinnedC; lowBinnedC]);
s_overallBinGA = sem([openBinnedGA; closeBinnedGA; highBinnedGA; lowBinnedGA]);


%% create graphs
figure;
% open price
errorbar(m_openBinA, s_openBinA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
errorbar(m_openBinB, s_openBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 2)
errorbar(m_openBinC, s_openBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 2)
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-openOverTime', 'epsc')

figure;
% close price
errorbar(m_closeBinA, s_closeBinA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
errorbar(m_closeBinB, s_closeBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 2)
errorbar(m_closeBinC, s_closeBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 2)
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-closeOverTime', 'epsc')

figure;
% high price
errorbar(m_highBinA, s_highBinA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
errorbar(m_highBinB, s_highBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 2)
errorbar(m_highBinC, s_highBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 2)
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-highOverTime', 'epsc')

figure;
% low price
errorbar(m_lowBinA, s_lowBinA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
errorbar(m_lowBinB, s_lowBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 2)
errorbar(m_lowBinC, s_lowBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 2)
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-lowOverTime', 'epsc')


figure; 
% error associated with high, low, open and close all together.
errorbar(m_overallBinA, s_overallBinA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 4); hold on;
errorbar(m_overallBinB, s_overallBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 4); 
errorbar(m_overallBinC, s_overallBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 4); 

xlabel('Bin (1 Bin = 25 Trials)')

ylim([25 75]); ylabel('User Performance Error')
legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-overallOverTime', 'epsc')


%% glyph learning graphs
figure;
% open price
errorbar(m_openBinGA, s_openBinGA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-openOverTime_gl', 'epsc')

figure;
% close price
errorbar(m_closeBinGA, s_closeBinGA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
%errorbar(m_closeBinB, s_closeBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 2)
%errorbar(m_closeBinC, s_closeBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 2)
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
%legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-closeOverTime_gl', 'epsc')

figure;
% high price
errorbar(m_highBinGA, s_highBinGA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
%errorbar(m_highBinB, s_highBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 2)
%errorbar(m_highBinC, s_highBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 2)
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
%legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-highOverTime_gl', 'epsc')

figure;
% low price
errorbar(m_lowBinGA, s_lowBinGA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 2); hold on;
%errorbar(m_lowBinB, s_lowBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 2)
%errorbar(m_lowBinC, s_lowBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 2)
xlabel('Bin (1 Bin = 25 Trials)')
ylim([25 75]); ylabel('User Performance Error')
%legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-lowOverTime', 'epsc')


figure; 
% error associated with high, low, open and close all together.
errorbar(m_overallBinGA, s_overallBinGA, 'red', 'marker','o', 'markersize', 10, 'markerfacecolor', 'green', 'linewidth', 4); hold on;
%errorbar(m_overallBinB, s_overallBinB,'color', [.5 .5 .5], 'marker', 's', 'markersize', 10, 'markerfacecolor', 'yellow', 'linewidth', 4); 
%errorbar(m_overallBinC, s_overallBinC,'black', 'marker', 'v', 'markersize', 15, 'markerfacecolor', [.5 .5 .5], 'linewidth', 4); 

xlabel('Bin (1 Bin = 25 Trials)')

ylim([25 75]); ylabel('User Performance Error')
%legend({'Condition A', 'Condition B', 'Condition C'})
set(gca, 'FontSize', 20)
set(gca, 'GridAlpha', .15)
set(gca, 'YGrid', 'on')
saveas(gcf, '~/pictures/6ixtures-overallOverTime_gl', 'epsc')