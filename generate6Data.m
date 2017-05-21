%  This generates the data to draw the plots for the [6]ix project.
%
%  Author: C. M. McColeman
%  Date Created: June 12 2016
%  Last Edit: June 21 2016 
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
%  Additional Comments: [THIS IS NOT USED. ARCHIVAL PURPOSES ONLY]


%% 1. Strategy one - multivariate normal distribution

% this is a 5D data generation problem, since the bull/bear indicator is
% just a binary thing. We'll need five means (all equal) and a 5x5 sigma
% matrix.

nTrials = 100;

muMat = zeros(5,1); % means are zero

for i = 1:nTrials
    
    %https://en.wikipedia.org/wiki/Multivariate_normal_distribution
    % http://www.mathworks.com/help/stats/mvnrnd.html
    % 1. positive, semi-definite
    % 1a) http://www.math.utah.edu/~zwick/Classes/Fall2012_2270/Lectures/Lecture33_with_Examples.pdf
    %       A matrix is positive definite if it's symmetric and all its eigenvalues are positive.
    
    % 2. yields correlations between all five (continuous) variables
    
    % http://math.stackexchange.com/questions/357980/matlab-code-for-generating-random-symmetric-positive-definite-matrix
    startingMat = rand(5,5);
    
    posSemiDef = startingMat * startingMat';
    
    % check assumptions
    % symmetrical? positive, semi definite? 
    isPosSemiDef = issymmetric(posSemiDef) & sum(eig(posSemiDef)<0)==0;
    
    if isPosSemiDef
        fiveDimsOut = mvnrnd(muMat,posSemiDef, nTrials);
        
        % a visual to see the relationship between the variables
        [r, p]=corrplot(fiveDimsOut);
        
        % save a big struct to call in later functions with everything
        % required to retrace our steps
        saveIt(i).varCorrCoefs = r; % correlation coefficients
        saveIt(i).varCorrSig = p; % p-values for correlations
        saveIt(i).startMat = startingMat; % step one in sigma matrix
        saveIt(i).sample = fiveDimsOut; % sampled data x 100
        saveIt(i).mu = muMat; % means
        saveIt(i).sigma = posSemiDef; % sigma matrix
        saveIt(i).varSpread = diff(r(:,1)); % distinction between correlation magnitude
        
        % save the correlation visual
        saveas(gcf, ['dimCorr' num2str(i)], 'epsc')
        
        close all % clear open figures to avoid memory errors
    end
    
end

%% 2. Strategy two - independent variable selection from five normal distributions

% this is a 5D data generation problem, since the bull/bear indicator is
% just a binary thing. We'll need five means (all equal) and a 5x5 sigma
% matrix.

va1 = normrnd(0,1,nTrials,1);
va2 = normrnd(0,1.5,nTrials,1);
va3 = normrnd(0,2,nTrials,1);
va4 = normrnd(0,2.5,nTrials,1);
va5 = normrnd(0,3,nTrials,1);

%% 3. Strategy three - go full econ and set up a VARGEX model
% VARGEX: Vector Autoregressive Moving Average with eXogenous inputs

Spec = vgxset('a', [0.1; -0.1], ...
	'b', [1.1, 0.9], ...
	'AR', {[0.6, 0.3; -0.4, 0.7], [0.3, 0.1; 0.05, 0.2]}, ...
    'MA', [0.5, -0.1; 0.07, 0.2], ...
	'Q', [0.03, 0.004; 0.004, 0.006])
%convert to VARMA (lose the exogenous)
Spec = vgxset(Spec, 'nX', 0, 'b', [])

testDat = vgxsim(Spec, 100);

dbstop if error; vgxvarx(Spec, testDat, [], [], 'ignorema', 'yes')


