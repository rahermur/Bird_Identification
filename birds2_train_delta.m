clc; clear; close all;

allFiles = dir( './datos/train_set/train_set/');
addpath './datos/train_set/train_set/'
addpath './rastamat'
allFiles = allFiles(3:end);
verbose = 0; sonido = 0;
fc_2 = 0.5; 
fc_1 = 0.02;
bands = 16;
% Syllbale Segmentation:
[ output ,S] = syllable_segmentation_train( allFiles,fc_1,fc_2,verbose);

close all;
X_tr = [];
train = cell(length(output),1);
Y_tr = [];
ratio = 192;

for i = 1:length(output) 
    
    syllables = output{i};
    [s,fs] = audioread(allFiles(i).name);
    % Filtering: 
    [B1,A1] = butter(10,fc_2,'low');
    train1_low = filter(B1,A1,s);
    [B2,A2] = butter(10,fc_1,'high');
    s = filter(B2,A2,train1_low);
    % MFCCC and Delta-MFCC for features:
    [cepstra, aspectrum, pspectrum] = extract_MFCC(s,fs);
    [deltaCepstrum] = calculoDeltaCepstrum(cepstra',2)';
    features = [cepstra; deltaCepstrum];
    % Syllable instants:
    T2 = [];
     for k = 1:length(syllables.T_n)
        T2 =[ T2  syllables.T_n(k)*ratio - ratio/2 : syllables.T_n(k)*ratio + ratio/2];
     end

     idx = [ floor(T2/171)-2; floor(T2/171)-1; floor(T2/171)];
     idx(idx<1) = 1;
     idx(idx>size(features,2)) = size(features,2);
     idx = unique(idx);
     idx = sort(idx);
     
     features2 = features(:,idx);
     
     if sonido
        sound(s(T2),fs);
     end
     
     X_tr = [X_tr  features2];
     Y_tr = [Y_tr i*ones(1,size(features2,2))];
     disp('---------------------------------------')
     disp(['Feature Extraction...  ',num2str(i), '  Bird: ' , num2str(allFiles(i).name) ]);
end

%%
disp('---------------------------------------')
disp(['Feature Extraction Phase 2']);
% sliding window:
%load ./processed_data/workspace1
%clear Total_new_features Label_new;
M = 25;
Label_new = [];
Total_new_features = [];
for k = 1: length(allFiles)
    pajaro = X_tr(:,Y_tr==k);
    new_features = zeros((M+1)*size(X_tr,1),size(pajaro,2)-M);
    for j = 1: size(pajaro,2)-M
        aux = pajaro(:,j:j+M);
        new_features(:,j) = aux(:);
    end
    Total_new_features = [Total_new_features new_features];
    Label_new = [Label_new k*ones(1,size(pajaro,2)-M) ];
end
Total_new_features = Total_new_features.';
Label_new = Label_new.';

%save ./processed_data/Training Total_new_features Label_new;
%clear
%%
%load ./processed_data/Training
% LDA Projection: 
ncomps = 29;
X_tr2 = Total_new_features;
Y_tr2 = Label_new;
X_train = (X_tr2 - repmat(mean(X_tr2,2),1,size(X_tr2,2)) ) ...
    ./repmat(std(X_tr2')',1,size(X_tr2,2)) ;

W = lda(X_train,Y_tr2,ncomps);
x = X_train*W';

figure;
hold all;
for j = 1:35
    plot3(x(Y_tr2==j,1),x(Y_tr2==j,2),x(Y_tr2==j,3),'x')
end

X_train_p = x;
Y_tr = Y_tr2;
%%
%save processed_data/project_train  W
save processed_data/DataProcessed2  X_train_p Y_tr


