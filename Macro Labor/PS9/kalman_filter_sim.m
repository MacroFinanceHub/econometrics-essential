function [K,P,Kss,Pss,Z]=kalman_filter_sim(A,C,D,R,periods)
%Simulates state space and computes Kalman filter for state space system
% 	X[t] = AX[t-1] + Cu[t]
% 
%   Z[t] = DX[t] + Ru[t]
%
% Outputs are the Kalman gain K in 
% X[t|t] = X[t|t-1]+ K(Z[t] - DX[t|t-1] )
%
% and P is the prior error covariance matrix
%
%  Pss = E(X[t]-X[t|t-1])(X[t]-X[t|t-1])'
%
% Kss and Pss are the corresponding steady state values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tol=1e-5;maxiter=1000;
diff=1;iter=1;
P0=dlyap(A,C*C');
% P0=C*C';
P1=A*P0*A'+C*C';
dimX=size(A,1);
dimZ=length(D(:,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Simulate State Space system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
U=randn(dimX,periods);
V=randn(dimZ,periods);
X=zeros(dimX,periods+1);
Z=zeros(dimZ,periods);
for t=1:periods;
    X(:,t+1)=A*X(:,t)+C*U(:,t);
    Z(:,t+1)=D*X(:,t+1)+R*V(:,t);
end
figure(1)
for j=1:dimX;
subplot(ceil((dimX+dimZ)^0.5),ceil((dimX+dimZ)^0.5),j);
plot(X(j,:));
legend('X')
end

for j=1:dimZ;
subplot(ceil((dimX+dimZ)^0.5),ceil((dimX+dimZ)^0.5),dimX+j);
plot(Z(j,:));
legend('Z')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute Kalman filter equations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P=zeros(dimX,dimX,periods+1);
K=zeros(dimX,dimZ,periods);
Xtt=X*0;
P(:,:,1)=C*C';
P(:,:,1)=C*C'/(1-A^2);
for t=1:periods;
    P(:,:,t+1)=A*(P(:,:,t)-(P(:,:,t)*D'/(D*P(:,:,t)*D'+R*R'))*D*P(:,:,t))*A'+C*C';    
    K(:,:,t)= P(:,:,t+1)*D'/(D*P(:,:,t+1)*D'+R*R');
    Xtt(:,t+1)=A*Xtt(:,t)+K(:,:,t)*(Z(:,t)-D*A*Xtt(:,t));
end

figure(2)
for j=1:dimX;
    if dimX>4
subplot(ceil((dimX)^0.5),ceil((dimX)^0.5),j);
plot(X(j,1:end-1));
hold on;
plot(Xtt(j,2:end),'linestyle','--');
legend('X','X_{t|t}')
    else
subplot(dimX,1,j);
plot(X(j,1:end-1));
hold on;
plot(Xtt(j,2:end),'linestyle','--');
legend('X','X_{t|t}') 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute steady state Kalman filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P1st=C*C';
while diff>= tol && iter <= maxiter
    P1=A*(P1st-(P1st*D'/(D*P1st*D'+R*R'))*D*P1st)*A'+C*C';    
    diff=max(max(abs(P1-P1st)));
    iter=iter+1;
    P1st=P1;
end
Kss=P1*D'/(D*P1*D'+R*R');
Pss=P1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute sample error covariance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sample_cov=cov(X(:,1:end-1)'-Xtt(:,2:end)');
pop_cov=P1st-(P1st*D'/(D*P1st*D'+R*R'))*D*P1st;

display ('Sample error covariance')
sample_cov

display ('Population error covariance')
pop_cov



 