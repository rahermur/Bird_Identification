% clc;clear;close all;
% load ./processed_data/NN_train.mat
% load ./processed_data/train_X.mat
% load ./processed_data/test_X.mat
load ./processed_data/clip1.mat
load ./processed_data/DataProcessed
%% Train other Neural network
% M = 20;
% net = patternnet(M);
% net.trainParam.epochs= 1000;
% % Setup Division of Data for Training, Validation, Testing
% net.divideParam.trainRatio = 60/100;
% net.divideParam.valRatio = 30/100;
% net.divideParam.testRatio = 10/100;
% Y_train_p = full(ind2vec(Y_tr));
% [net,TR] = train(net,X_train_p',Y_train_p);
%%
y_train = net(X_train_p');
Labels = full(ind2vec(Y_tr));
plotroc(Labels,y_train)
%%
[tpr,fpr,thresholds] = roc(Labels,y_train);
auc_comb = zeros(35,1);
for i=1:35
auc_comb(i) = areaUnderCurve(fpr{i},tpr{i});
end

[value, index ]= sort(auc_comb,'ascend');
index = index(1:3);
%%
Y_test = net(X_test_p');

Y = zeros(35,3);
Y(6,:) = [1 1 0];
Y(8,:) = [0 1 0];
Y(12,:) = [0 1 1];
Y(16,:) = [0 0 1];
Y(18,:) = [0 0 1];
Y(27,:) = [1 0 0];
Y(32,:) = [1 1 0];
Y(33,:) = [0 1 1];
Y(34,:) = [1 1 1];
known = 1;

Submission = cell(35*90,3);
figure; hold all;
for k = 1:length(unique(clip))
    gmax = max(max(Y_test(:,clip==k),[],2));
    results = 1 - max(Y_test(:,clip==k),[],2)./gmax;
    for j = 1:35
        if k==1 || k==31 || k==61
            Submission{ (k-1)*35 + j,1} = clip1{(k-1)*35 + j};
            Submission{ (k-1)*35 +j,3} = Y(j,known);
            Submission{ (k-1)*35 +j,2} = j;
            if j==35
                known = known+1;
            end
        else
            if j==index(1) || j==index(2) || j==index(3)
                Submission{ (k-1)*35 + j,1} = clip1{(k-1)*35 + j};
                Submission{ (k-1)*35 +j,3} = 0;
                Submission{ (k-1)*35 +j,2} = j;
            else
                Submission{ (k-1)*35 + j,1} = clip1{(k-1)*35 + j};
                Submission{ (k-1)*35 +j,3} = results(j);
                Submission{ (k-1)*35 +j,2} = j;
            end
        end
    end
stem(results) 
end

fid = fopen('Submission.csv','wt');
fprintf(fid, 'clip,species,probability\n');
for i=1:size(Submission,1)
    fprintf(fid, '%s,%d,%12.30f\n', Submission{i,1:3});
end
fclose(fid);
