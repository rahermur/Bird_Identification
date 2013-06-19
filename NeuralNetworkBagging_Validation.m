clc;clear;close all;

load ./processed_data/DataProcessed
Ensemble = 25;
M = 20;
%
perm = randperm(size(X_train_p,1));
X_train_p = X_train_p(perm,:);
Y = Y_tr(perm);
p = 0.20;

X_test_p = X_train_p(1:round(length(Y)*p),:);
Y_test = Y(1:round(length(Y)*p));
X_train_p = X_train_p(round(length(Y)*p)+1:end,:);
Y = Y(round(length(Y)*p)+1:end);

Y = Y.';
NN_bag = cell(Ensemble,1);
for s = 1:Ensemble
    index = randsample(1:size(X_train_p,1),size(X_train_p,1),'true',1/size(X_train_p,1)*ones(size(X_train_p,1),1));
    X_train_pain = X_train_p(index,:)';
    Yain = Y(index,:)';
    Yain = full(ind2vec(Yain));
    net = patternnet(M);
    net.trainParam.epochs= 450;
    % Setup Division of Data for Training, Validation, Testing
    net.divideParam.trainRatio = 65/100;
    net.divideParam.valRatio = 35/100;
    net.divideParam.testRatio = 5/100;

    [net,TR] = train(net,X_train_pain,Yain);
    NN_bag{s} = net;
    s
end
%% Train
for s = 1:Ensemble
   out_NN = NN_bag{s}(X_train_p'); 
   [ii,jj] = max(out_NN.',[],2);
   [~, ~, ~, auc ] = perfcurve(Y, jj, 35);
   disp(['Accuracy Train: ',num2str(auc) , ' NN: ', num2str(s)])
end
%% VAL
Total_out = zeros(35,length(Y_test),1);
for s = 1:Ensemble
   out_tst_NN = NN_bag{s}(X_test_p'); 
   [ii,jj] = max(out_tst_NN.',[],2);
   [~, ~, ~, auc ] = perfcurve(Y_test, jj, 35);
   disp(['Accuracy Test: ',num2str(auc) , ' NN: ', num2str(s)])
   Total_out = Total_out + out_tst_NN;
end
%
Salida = Total_out./Ensemble;
[ii,jj] = max(Salida.',[],2);
[~, ~, ~, auc ] = perfcurve(Y_test, jj, 35);
disp(['Accuracy Test: ',num2str(auc) , ' NN: ', num2str(s)])

%% 
load ./processed_data/DataProcessed

Total_out = zeros(35,size(X_test_p,1),1);
for s = 1:Ensemble
   out_tst_NN = NN_bag{s}(X_test_p'); 
   Total_out = Total_out + out_tst_NN;
end
%
Salida_Test = Total_out./Ensemble;
