function [ ...
        allRectsNowTriangle, ...
        placementRectsNowTriangle ...
        ]= rect2TriCandle( ...
                allRects,  ...
                placementRects,  ...
                endOfDayDiff,  ...
                candleCol,  ...
                defaultPlaceOrder,  ...
                windowPtr,  ...
                coerceUpDown ...
        )
%  This function converts the rectangle output for a typical candle plot to
%  triangles pointing up/down, depending on whether the "stock" closed higher
%  or lower that "day".
%
%  Author: C. M. McColeman
%  Date Created: September 21 2016
%  Last Edit:
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix - drawSeries.m & glyphLearningResponse.m
%
%  Reviewed: [Cal cwoodruf@sfu.ca 2016-09-25]
%  Verified: []
%
%  INPUT: 
%       allRects,  graph rectangles to be converted to triangles
%       placementRects,  rectangles for participant response
%       endOfDayDiff,  vector of open - close differences
%       candleCol,  the column or logical x position for this candle
%       defaultPlaceOrder,  where to put placement candle for participant
%       windowPtr,  handle to our window for drawing on screen
%       coerceUpDown, 1 = force closedHigher to always be true (1), 2 = false (0) 
%
%  OUTPUT: 
%       allRectsNowTriangle, new set of triangular dimensions that replace allRects
%       placementRectsNowTriangle, triangular dimensions for participant placement shapes
%       Main effect of this cript is to draw the rectangles as triangles to the
%       screen handle windowPtr
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments:

% endOfDayDiff = open-close in drawSeriesAsCandle.m. It's *critical* that
% this is consistent between all scripts.

if ~isempty(allRects)
    closedHigher = endOfDayDiff < 0;

    % force an orientation if we are told to do so
    if coerceUpDown==1; closedHigher = 1; elseif coerceUpDown == 2; closedHigher =0; end

    for j = 1:size(allRects,2) % draw triangles to capture the same info as the rectangle candles
        
        x1(j) = allRects(1, j); 
        x2(j) = allRects(3, j); % x1 -left % x2 - right
        y1(j) = min(allRects([2 4], j)); % y1 - top
        y2(j) = max(allRects([2 4], j)); % y2 - bottom
        
        centreX = mean([x1(j), x2(j)]); % the triangle "points to" this x value
        
        if closedHigher(j)
            Screen('FillPoly', windowPtr, candleCol{1}, [x1(j) y2(j); centreX y1(j); x2(j) y2(j)]);
        else %opened higher
            Screen('FillPoly', windowPtr, candleCol{1}, [x1(j) y1(j); centreX y2(j); x2(j) y1(j)]);
        end
    end
    allRectsNowTriangle = [x1; y1; x2; y2]; % record converted values
else
    allRectsNowTriangle=[];
end
placementRectsNowTriangle = {};


if ~isempty(defaultPlaceOrder)  % we'll need placement candles too
    centreX=[]; % reuse
    
    % convert placement rectangles to triangles
    candleBit = placementRects(:,[1 2]);
    
    centreX(1,1) = mean(placementRects([1,3],1));
    centreX(1,2) = mean(placementRects([1,3],2));
    
    yVals(:,1) = placementRects([2,4],1);
    yVals(:,2) = placementRects([2,4],2);
    placementRectsNowTriangle{1} = [placementRects(1,1) yVals(1); centreX(1) yVals(2); placementRects(3,1) yVals(1)];
    placementRectsNowTriangle{2} = [placementRects(1,2) yVals(2); centreX(2) yVals(1); placementRects(3,2) yVals(2)];
    % REQUIRES RE-REVIEW
    if defaultPlaceOrder(1) == 2
        Screen('FillPoly', windowPtr, candleCol{1,1}, [placementRects(1,1) yVals(2,1); centreX(1) yVals(1,1); placementRects(3,1) yVals(2,1)]); % left up ("green")
        Screen('FillPoly', windowPtr, candleCol{2,1}, [placementRects(1,2) yVals(1,2); centreX(2) yVals(2,2); placementRects(3,2) yVals(1,2)]); % right down ("red")
    elseif defaultPlaceOrder(1)
        Screen('FillPoly', windowPtr, candleCol{1,1}, [placementRects(1,1) yVals(1,1); centreX(1) yVals(2,1); placementRects(3,1) yVals(1,1)]); % left down ("red")
        Screen('FillPoly', windowPtr, candleCol{2,1}, [placementRects(1,2) yVals(2,2); centreX(2) yVals(1,2); placementRects(3,2) yVals(2,2)]); % right up ("green")
    else
        display('error! cannot draw triangles without defaultPlaceOrder = [2, 1] or defaultPlaceOrder = [1, 2]')
    end
end
