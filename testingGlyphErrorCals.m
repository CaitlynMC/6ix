% correlation between the dollar converted actual answer and the
% participant response
scatter(debugRec(:,1), debugRec(:,5))


% asking for close price when close higher
closeHigher = debugRec(:,7)==1;
questionId2 = debugRec(:,3)==2;
scatter(debugRec(closeHigher&questionId2,1), debugRec(closeHigher&questionId2,5))
debugRec(closeHigher&questionId2,1)-debugRec(closeHigher&questionId2,5)


% asking for close price when open higher
closeHigher = debugRec(:,7)==1;
questionId2 = debugRec(:,3)==2;
scatter(debugRec(~closeHigher&questionId2,1), debugRec(~closeHigher&questionId2,5))
biasedRespCheck = debugRec(~closeHigher&questionId2,1)-debugRec(~closeHigher&questionId2,5)

% ensure the "fill" or red colour corresponds to open higher.
closedHigherIdx=find(debugRec(:,7))
participantColourOut=debugRec(closedHigherIdx,8)