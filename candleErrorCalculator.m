function [errorVal, errorRec]= candleErrorCalculator(candleCol, correctCandle, correctColour, ...
    correctUpperShadow, correctLowerShadow, participantCandle, participantColour, participantShadows)

%  This will calculate the error associated with the final locations of the
%  candle and shadows.
%
%  Author: C. M. McColeman
%  Date Created: September 14 2016
%  Last Edit: Oct 11 2016
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix, glyph learning
%
%  Reviewed: [Judi Azmand]
%  Verified: []
%
%  INPUT: Requires rectangle coordinates of the right answer and the
%  observed answer
%  correctColour, participantColour, RGB triplets of the form [1 1 1]
%
%  OUTPUT: A single value reflecting the global mismatch between the
%  dimensions. Use this value to assign points during the experiment.
%
%  Additional Scripts Used:
%
%  Additional Comments:


% step one: determine the candle error
% recall that the lighter candle (hollow/green) indicates the closing price is
% HIGHER than the opening price.
if sum(correctColour == participantColour) == length(participantColour)
    candleError =  abs(correctCandle([2, 4],1) - participantCandle([2, 4],1));
else % flip the top and bottom Y values for comparison
    candleError = abs(correctCandle([2, 4],1) - participantCandle([4, 2],1));
end

% step two: figure out which shadow is the upper and which is the lower,
% relative to the candle body.
% a) upper
% upper shadow contains the lowest y value
%isUpper = find(participantShadows(2, :) == min(participantShadows(2, :)));

% b) lower
% lower shadow contains the highest y value
%isLower = find(participantShadows(2, :) == max(participantShadows(2, :)));


% step three: determine the shadow error.
% a) upper
upShadowError = abs(correctUpperShadow(2,1) - participantShadows(2,1)); % changed after review just to measure the error at the extreme of the shadow -CM
% b) lower
lowShadowError = abs(correctLowerShadow(4,1) - participantShadows(4,2));

errorVal = sum([candleError; upShadowError; lowShadowError]);
errorRec = [candleError; upShadowError; lowShadowError]; % added after review