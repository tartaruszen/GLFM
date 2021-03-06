clear
addpath(genpath('../Ccode/'));

missing=-1;

%f_1=@(x,w) log(exp(w*x)-1);
%df_1=@(x,w) w./(1-exp(-w*x));
%logN=@(x) max(log(x),-30); %To avoid -Inf

%% Selecting missing data
randn('seed',round(sum(1e5*clock)));
rand('seed',round(sum(1e5*clock)));

load ../databases/dataExploration/mat/prostate.mat %../databases/Wine.mat

drug_identifier = data.X(:,2) > 0.5;

% remove drug levels
data.X(:,2) = [];
data.C(2) = [];
data.cat_labels(2) = [];
data.ylabel(2) = [];

N = size(data.X,1);
D = size(data.X,2);

%Nmiss=round(N*D*p);
%miss=randperm(N*D);
%miss=miss(1:Nmiss);
Xmiss=data.X;        % Observation matrix
%Xmiss(miss)= missing; % Missing data are coded as missing
[N, D]= size(data.X);
s2Y=.5;    % Variance of the Gaussian prior on the auxiliary variables (pseudoo-observations) Y
s2u=.5;
s2B=1;      % Variance of the Gaussian prior of the weigting matrices B
alpha=1;    % Concentration parameter of the IBP
Nsim=100; % Number of iterations for the gibbs sampler
bias = 1;
maxK= D;

Xmiss(isnan(Xmiss)) = missing;
W = zeros(1,D); % vector of weights for transformation
for d=1:D
    if (data.C(d) == 'n') && (min(data.X(:,d)) == 0)
        Xmiss(Xmiss(:,d) ~= missing,d) = Xmiss(Xmiss(:,d) ~= missing,d) + 1;
    elseif (data.C(d) == 'p') && (min(data.X(:,d)) == 0)
        Xmiss(Xmiss(:,d) ~= missing,d) = Xmiss(Xmiss(:,d) ~= missing,d) + 10^-6;
    end
    
    % normalize data (such that it occupies interval (0,max(X(d))]
    if ((data.C(d) == 'n') || (data.C(d) == 'c'))   && (min(data.X(:,d)) > 1)
        idx = min(data.X(:,d));
        Xmiss(Xmiss(:,d) ~= missing,d) = Xmiss(Xmiss(:,d) ~= missing,d) - idx + 1;
    end
    if (data.C(d) == 'p') && (min(data.X(:,d)) > 1)
        idx = min(data.X(:,d));
        Xmiss(Xmiss(:,d) ~= missing,d) = Xmiss(Xmiss(:,d) ~= missing,d) - idx + 10^-6;
    end
    W(d) = 2/max( Xmiss(Xmiss(:,d) ~= missing,d) );
end


%% Inference
tic;
Zini= [drug_identifier, not(drug_identifier), double(rand(N,2)>0.8)];
bias = 2;
Zest = Zini';
for it=1:1
    [Zest B Theta]= IBPsampler(Xmiss,data.C,Zest',W,bias,s2Y,s2u,s2B,alpha,Nsim,maxK,missing);
    sum(Zest')
    toc;
end
save('../results/tmp_prostate_drug_noDrug_it10000_noDrugLevel_bis.mat');

%% %% Compute test log-likelihood
% XT=Xmiss;
% ii=0;
% TLK=zeros(1,sum(XT(:)==missing));
% for i=miss
%     ii=ii+1;
%     if (XT(i)~=missing) 
%         d=ceil(i/N);
%         n=mod(i,N);
%         if (n==0)
%             n=N;
%         end
%         j=j+1;
%         Br=squeeze(B(d,:,1));
%         if (C(d)=='g')
%             % Question_ISA: TLK not initialized before loop?
%             TLK(ii) = logN(normpdf(XT(i),Zest(:,n)'*Br',1));
%         elseif (C(d)=='p' )
%             TLK(ii) = logN(normpdf(f_1(XT(i),W(d)),Zest(:,n)'*Br',2))+logN(abs(df_1(XT(i),W(d))));
%         elseif (C(d)=='c')
%            Br=squeeze(B(d,:,:));
%            prob=zeros(1,R(d));
%            for r=1:R(d)-1
%                for r2=1:R(d)
%                     if r2~=r
%                         prob(r) =prob(r)+ logN(normcdf(Zest(:,n)'*(Br(:,r)-Br(:,r2)),0,1));
%                     end
%                end
%            end 
%            if 1-sum(exp(prob(1:R(d)-1)))<0
%                 prob(end)=-30;
%                 prob=logN(exp(prob)/sum(exp(prob)));
%            else
%                 prob(end)=logN(1-sum(exp(prob(1:(R(d)-1)))));
%            end
%            TLK(ii) =prob(XT(i));
% 
%         elseif (C(d)=='o' )
%             Br=squeeze(B(d,:,1));
%             if XT(i)==1
%                 TLK(ii) = logN(normcdf(Theta(d,XT(i))-Zest(:,n)'*Br',0,1));
%             elseif XT(i)==R(d)
%                 TLK(ii) = logN(1- normcdf(Theta(d,XT(i)-1)-Zest(:,n)'*Br',0,1));
%             else
%                 TLK(ii) = logN(normcdf(Theta(d,XT(i))-Zest(:,n)'*Br',0,1)-normcdf(Theta(d,XT(i)-1)-Zest(:,n)'*Br',0,1));
%             end
%         elseif (C(d)=='n')
%              Br=squeeze(B(d,:,1));
%             if XT(i)==0
%                 TLK(ii) = logN(normcdf(f_1(XT(i)+1,W(d))-Zest(:,n)'*Br',0,1));
%             else
%                 TLK(ii) = logN(normcdf(f_1(XT(i)+1,W(d))-Zest(:,n)'*Br',0,1)-normcdf(f_1(XT(i),W(d))-Zest(:,n)'*Br',0,1));
%             end
%         end
%     end
% end
