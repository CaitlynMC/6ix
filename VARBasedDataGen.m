function modelOut = VARBasedDataGen
%  This generates models by explicitly providing model parameters
%
%  Author: Caitlyn McColeman
%  Date Created: Sept 1 2016
%  Last Edit: [Last Time of Edit]
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix
%
%  Reviewed: Yue Chen [Oct 3 2016]
%  Verified: Yue Chen [Oct 3 2016], Judi Azmand [Oct 10 2016]
%
%  INPUT: [Insert Function Inputs here (if any)]
%
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments:

% there will be numel(nMat) x numel(AR) "stocks" in the dataset to
% investigate the influence of the Q and the autoregression matrices.

% ensure the Q matrix is a positive semi-definite
semDefReRun = 1;
nMat = 0;
while semDefReRun || (nMat < 10)
   
    Q = rand(4);
    Q = Q*Q'; % symmetry
    Q = Q - min(Q(:)); % scale: 0 to 1
    Q = Q./(max(Q(:))); % scale: 0 to 1
    if sum((eig(Q))<0)==0 && issymmetric(Q) % if there's negative values in the eigenvector, go again
        semDefReRun=0;
        nMat = nMat + 1;
        QRec{nMat}=Q;
    else
        display('searching for positive semi-definite')
    end
end

nARMod = 4;

for i = 1:nARMod
    % rng(5); 
    AR = rand(4);
    AR = AR - min(AR(:)); % scale: 0 to 1
    ARIn{i} = AR./(max(AR(:))); % scale: 0 to 1
end 

buildMods = fullfact([nMat nARMod]);

for i = 1:length(buildMods)
    modelOut{i} = vgxset('a',[0;0;0;0],'AR', ARIn{buildMods(i,2)}./2,'Q',QRec{buildMods(i,1)});
    dataSample= vgxsim(modelOut{i}, 100);
    %vgxplot(modelOut{i}, dataSample); % for inspection only
    %pause(1.5)
end


%% exploration and test cases for later reference. No need to review or verify.
%{
% Autoregression coefficients.
% An nAR-element cell array of n-by-n matrices of AR coefficients.
A1 = [.5 0 0;.1 .1 .3;0 .2 .3];
A2 = [0.5000    0.1000         0;
    0    0.1000    0.2000;
    0    0.3000    0.3000];
A3=[    0.5000         0         0;
    0.1000    0.9000    0.3000;
    0    0.2000    0.3000]
A4=[    0.5000         0         0;
    0.1000    0.9000    0.1000;
    0    0.2000    0.3000]
A5 =[0.5000         0         0         0;
    0.1000    0.1000    0.3000    0.1000;
         0    0.2000    0.3000    0.2000;
         0    0.1000    0.2000    0.5000];
A6 = [.5 0 0;.1 .1 .3;0 .2 .3];

fourD_A1 = [NaN]



Q = eye(3);

Q2 = rand(3,3)
Q2 = Q2*Q2
Q2./max(Q2(:))

Q2=rand(3)
Q3=Q2*Q2'
Q3 = Q3./(max(Q3(:)))
eig(Q3)

% ensure the Q matrix is a positive semi-definite
semDefReRun = 1
while semDefReRun
    Q4 = rand(4);
    Q4 = Q4*Q4';
    Q4 = Q4 - min(Q4(:));
    Q4 = Q4./(max(Q4(:))); % scale: 0 to 1, i dont' think this is necessary
    if sum((eig(Q4))<0)==0 && issymmetric(Q4)% if there's negative values in the eigen vector, go again
        semDefReRun=0;
    end
end

Mdl = vgxset('a',[.05;0;-.05],'AR',{A1},'Q',Q)
Mdl2 = vgxset('a',[.05;0;-.05],'AR',{A2},'Q',Q)
Mdl3 = vgxset('AR',{A2},'Q',Q)
Mdl4 = vgxset('AR',{A3},'Q',Q)
Mdl5 = vgxset('AR',{A4},'Q',Q)
Mdl6 = vgxset('AR',{A4},'Q',Q, 'n', 3)
Mdl7 = vgxset('AR',{A4},'Q',Q3, 'n', 3)
Mdl8 = vgxset('AR',{A5},'Q',Q4, 'n', 4)
Mdl9 = vgxset('a',[.05;0;-.05; -.02],'AR',{A5},'Q',Q4)
Mdl10 = vgxset('a',[0;0;0;0],'AR',{A5},'Q',Q4)


Y = vgxsim(Mdl,100)
Y2 = vgxsim(Mdl2,100)
Y3 = vgxsim(Mdl3,100)
Y4 = vgxsim(Mdl4,100)
Y5 = vgxsim(Mdl5,100)
Y6 = vgxsim(Mdl6, 100)
Y7 = vgxsim(Mdl7, 100)
Y8 = vgxsim(Mdl8, 100)
Y9 = vgxsim(Mdl9, 100)
Y10 = vgxsim(Mdl10, 100)

figure;vgxplot(Mdl,Y)
figure;vgxplot(Mdl2, Y2)
figure;vgxplot(Mdl3, Y3)
figure;vgxplot(Mdl4, Y4)
figure;vgxplot(Mdl5, Y5)
figure; vgxplot(Mdl6, Y6)
figure; vgxplot(Mdl7, Y7)
figure; vgxplot(Mdl8, Y8)
figure; vgxplot(Mdl9, Y9); title('Mdl9')
figure; vgxplot(Mdl10, Y10); title('Mdl10')
%}