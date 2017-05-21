%  Working through sample VAR model via MATLAB
% http://www.mathworks.com/help/econ/var-model-case-study.html
%  
%  Author: CM
%  Date Created: Sept 1 2016
%  Last Edit: 
%  
%  Cognitive Science Lab, Simon Fraser University 
%  Originally Created For: Framework for 6ix project
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
%  Additional Comments: 
load Data_USEconModel
gdp = DataTable.GDP;
m1 = DataTable.M1SL;
tb3 = DataTable.TB3MS;
Y = [gdp,m1,tb3];

figure
subplot(3,1,1)
plot(dates,Y(:,1),'r');
title('GDP')
datetick('x')
grid on
subplot(3,1,2);
plot(dates,Y(:,2),'b');
title('M1')
datetick('x')
grid on
subplot(3,1,3);
plot(dates, Y(:,3), 'k')
title('3-mo T-bill')
datetick('x')
grid on
hold off

% log transform reduces trend up
Y = [diff(log(Y(:,1:2))), Y(2:end,3)]; % Transformed data
X = dates(2:end);

figure
subplot(3,1,1)
plot(X,Y(:,1),'r');
title('GDP')
datetick('x')
grid on
subplot(3,1,2);
plot(X,Y(:,2),'b');
title('M1')
datetick('x')
grid on
subplot(3,1,3);
plot(X, Y(:,3),'k'),
title('3-mo T-bill')
datetick('x')
grid on

% scale so orders of magnitude align better
Y(:,1:2) = 100*Y(:,1:2);
figure
plot(X,Y(:,1),'r');
hold on
plot(X,Y(:,2),'b');
datetick('x')
grid on
plot(X,Y(:,3),'k');
legend('GDP','M1','3-mo T-bill');
hold off

dGDP = 100*diff(log(gdp(49:end)));
dM1 = 100*diff(log(m1(49:end)));
dT3 = diff(tb3(49:end));
Y = [dGDP dM1 dT3];

%You can select many different models for the data. This example uses four models.

dt = logical(eye(3));
%VAR(2) with diagonal autoregressive and covariance matrices
VAR2diag = vgxset('ARsolve',repmat({dt},2,1),...
    'asolve',true(3,1),'Series',{'GDP','M1','3-mo T-bill'});
%VAR(2) with full autoregressive and covariance matrices
VAR2full = vgxset(VAR2diag,'ARsolve',[]);
%VAR(4) with diagonal autoregressive and covariance matrices
VAR4diag = vgxset(VAR2diag,'nAR',4,'ARsolve',repmat({dt},4,1));
%VAR(4) with full autoregressive and covariance matrices
VAR4full = vgxset(VAR2full,'nAR',4);


%For the two VAR(4) models, the presample period is the first four rows of Y.
%Use the same presample period for the VAR(2) models so that all the models are fit to the same data. 
%This is necessary for model fit comparisons. 
%For both models, the forecast period is the final 10% of the rows of Y. 
%The estimation period for the models goes from row 5 to the 90% row. 
%Define these data periods.

YPre = Y(1:4,:);
T = ceil(.9*size(Y,1));
YEst = Y(5:T,:);
YF = Y((T+1):end,:);
TF = size(YF,1);
[EstSpec1,EstStdErrors1,logL1,W1] = ...
    vgxvarx(VAR2diag,YEst,[],YPre,'CovarType','Diagonal');
[EstSpec2,EstStdErrors2,logL2,W2] = ...
    vgxvarx(VAR2full,YEst,[],YPre);
[EstSpec3,EstStdErrors3,logL3,W3] = ...
    vgxvarx(VAR4diag,YEst,[],YPre,'CovarType','Diagonal');
[EstSpec4,EstStdErrors4,logL4,W4] = ...
    vgxvarx(VAR4full,YEst,[],YPre);

[isStable1,isInvertible1] = vgxqual(EstSpec1);
[isStable2,isInvertible2] = vgxqual(EstSpec2);
[isStable3,isInvertible3] = vgxqual(EstSpec3);
[isStable4,isInvertible4] = vgxqual(EstSpec4);
[isStable1,isStable2,isStable3,isStable4]
[isInvertible1,isInvertible2,isInvertible3,isInvertible4]

%You can compare the restricted (diagonal) AR models to their unrestricted (full) counterparts using lratiotest. 
%The test rejects or fails to reject the hypothesis that the restricted models are adequate, with a default 5% tolerance.
[n1,n1p] = vgxcount(EstSpec1);
[n2,n2p] = vgxcount(EstSpec2);
[n3,n3p] = vgxcount(EstSpec3);
[n4,n4p] = vgxcount(EstSpec4);
reject1 = lratiotest(logL2,logL1,n2p - n1p)
reject3 = lratiotest(logL4,logL3,n4p - n3p)
reject4 = lratiotest(logL4,logL2,n4p - n2p)

%based on this test, the unrestricted AR(2) and AR(4) models are preferable. 
%However, the test does not reject the unrestricted AR(2) model in favor of the unrestricted AR(4) model. 


%To find the best model in a set, minimize the Akaike information criterion (AIC). 
%Use in-sample data to compute the AIC. Calculate the criterion for the four models

AIC = aicbic([logL1 logL2 logL3 logL4],[n1p n2p n3p n4p]);

%To compare the predictions of the four models against the forecast data YF, use vgxpred. 
%This function returns both a prediction of the mean time series, 
%and an error covariance matrix that gives confidence intervals about the means. This is an out-of-sample calculation.
[FY1,FYCov1] = vgxpred(EstSpec1,TF,[],YEst);
[FY2,FYCov2] = vgxpred(EstSpec2,TF,[],YEst);
[FY3,FYCov3] = vgxpred(EstSpec3,TF,[],YEst);
[FY4,FYCov4] = vgxpred(EstSpec4,TF,[],YEst);

figure
vgxplot(EstSpec2,YEst,FY2,FYCov2)

%It is now straightforward to calculate the sum-of-squares error between the predictions and the data, YF.
Error1 = YF - FY1;
Error2 = YF - FY2;
Error3 = YF - FY3;
Error4 = YF - FY4;

SSerror1 = Error1(:)' * Error1(:);
SSerror2 = Error2(:)' * Error2(:);
SSerror3 = Error3(:)' * Error3(:);
SSerror4 = Error4(:)' * Error4(:);
figure
bar([SSerror1 SSerror2 SSerror3 SSerror4],.5)
ylabel('Sum of squared errors')
set(gca,'XTickLabel',...
    {'AR2 diag' 'AR2 full' 'AR4 diag' 'AR4 full'})
title('Sum of Squared Forecast Errors')


%% forecasting
% You can make predictions or forecasts using the fitted model either by:
% 
% Running vgxpred based on the last few rows of YF
% Simulating several time series with vgxsim
% In both cases, transform the forecasts so they are directly comparable to the original time series.
% 
% Generate 10 predictions from the fitted model beginning at the latest times using vgxpred.
[YPred,YCov] = vgxpred(EstSpec2,10,[],YF);

%Transform the predictions by undoing the scaling and differencing applied to the original data. 
%Make sure to insert the last observation at the beginning of the time series before using cumsum to undo the differencing. 
%And, since differencing occurred after taking logarithms, insert the logarithm before using cumsum.
YFirst = [gdp,m1,tb3];
YFirst = YFirst(49:end,:);           % Remove NaNs
dates = dates(49:end);
EndPt = YFirst(end,:);
EndPt(1:2) = log(EndPt(1:2));
YPred(:,1:2) = YPred(:,1:2)/100;     % Rescale percentage
YPred = [EndPt; YPred];              % Prepare for cumsum
YPred(:,1:3) = cumsum(YPred(:,1:3));
YPred(:,1:2) = exp(YPred(:,1:2));
lastime = dates(end);
timess = lastime:91:lastime+910;     % Insert forecast horizon

figure
subplot(3,1,1)
plot(timess,YPred(:,1),':r')
hold on
plot(dates,YFirst(:,1),'k')
datetick('x')
grid on
title('GDP')
subplot(3,1,2);
plot(timess,YPred(:,2),':r')
hold on
plot(dates,YFirst(:,2),'k')
datetick('x')
grid on
title('M1')
subplot(3,1,3);
plot(timess,YPred(:,3),':r')
hold on
plot(dates,YFirst(:,3),'k')
datetick('x')
grid on
title('3-mo T-bill')
hold off

%Simulate a time series from the fitted model beginning at the latest times.
rng(1); % For reproducibility
YSim = vgxsim(EstSpec2,10,[],YF,[],2000);

%Transform the predictions by undoing the scaling and differencing applied to the original data. Make sure to insert the last observation at the beginning of the time series before using cumsum to undo the differencing. And, since differencing occurred after taking logarithms, insert the logarithm before using cumsum.
YFirst = [gdp,m1,tb3];
EndPt = YFirst(end,:);
EndPt(1:2) = log(EndPt(1:2));
YSim(:,1:2,:) = YSim(:,1:2,:)/100;
YSim = [repmat(EndPt,[1,1,2000]);YSim];
YSim(:,1:3,:) = cumsum(YSim(:,1:3,:));
YSim(:,1:2,:) = exp(YSim(:,1:2,:));

%Compute the mean and standard deviation of each series, and plot the results.
YMean = mean(YSim,3);
YSTD = std(YSim,0,3);

figure
subplot(3,1,1)
plot(timess,YMean(:,1),'k')
datetick('x')
grid on
hold on
plot(timess,YMean(:,1)+YSTD(:,1),'--r')
plot(timess,YMean(:,1)-YSTD(:,1),'--r')
title('GDP')
subplot(3,1,2);
plot(timess,YMean(:,2),'k')
hold on
datetick('x')
grid on
plot(timess,YMean(:,2)+YSTD(:,2),'--r')
plot(timess,YMean(:,2)-YSTD(:,2),'--r')
title('M1')
subplot(3,1,3);
plot(timess,YMean(:,3),'k')
hold on
datetick('x')
grid on
plot(timess,YMean(:,3)+YSTD(:,3),'--r')
plot(timess,YMean(:,3)-YSTD(:,3),'--r')
title('3-mo T-bill')
hold off
