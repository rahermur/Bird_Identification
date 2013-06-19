clc; clear; close all;
verbose = 0; sonido = 0;
allFiles = dir( './datos/test_set/test_set/');
addpath './datos/test_set/test_set/'
addpath './rastamat/'
allFiles = allFiles(3:end);
fc_2 = 0.5; 
fc_1 = 0.03;
bands = 16;
[ output ,S] = syllable_segmentation_test( allFiles,fc_1,fc_2,verbose,sonido);

%%
close all;
X_tst = [];
ratio = 192;
clip = [];
for i = 1:length(output) 
    
    syllables = output{i};
    [s,fs] = audioread(allFiles(i).name);
    
    [B1,A1] = butter(10,fc_2,'low');
    test1_low = filter(B1,A1,s);
    [B2,A2] = butter(10,fc_1,'high');
    s = filter(B2,A2,test1_low);
    
    [cepstra, aspectrum, pspectrum] = extract_MFCC(s,fs);
    [deltaCepstrum] = calculoDeltaCepstrum(cepstra',2)';
    features = [cepstra; deltaCepstrum];
    
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
     
     X_tst = [X_tst  features2];
     clip = [clip i*ones(1,size(features2,2))];
     disp('---------------------------------------')
     disp(['Feature Extraction...  ',num2str(i), '  Bird: ' , num2str(allFiles(i).name) ]);
end
save ./processed_data/workspace_Test;

%%

disp('---------------------------------------')
disp(['Feature Extraction Phase 2']);
% 
% load ./processed_data/workspace_Test X_tst clip
% clear Total_new_features Label_new;
M = 25;
Label_new = [];
Total_new_features = [];
for k = 1: 90
    
    pajaro = X_tst(:,clip==k);
    new_features = zeros((M+1)*size(X_tst,1),size(pajaro,2)-M);
    for j = 1: size(pajaro,2)-M
        aux = pajaro(:,j:j+M);
        new_features(:,j) = aux(:);
    end
    Total_new_features = [Total_new_features new_features];
    Label_new = [Label_new k*ones(1,size(pajaro,2)-M) ];
end
Total_new_features = Total_new_features.';
Label_new = Label_new.';

save('./processed_data/Testing2.mat','Total_new_features','Label_new','-v7.3');
%%
load ./processed_data/Testing2 Total_new_features Label_new
ncomps = 50;
Y = randperm(length(Label_new));
Y = Y(1:round(length(Label_new)*0.6));
X_tst2 = Total_new_features(Y,:);
Y_tst2 = Label_new(Y);
clear Total_new_features Label_new Y;
X_test =(X_tst2 - repmat(mean(X_tst2,2),1,size(X_tst2,2)) ) ...
    ./repmat(std(X_tst2')',1,size(X_tst2,2)) ;
%%
load processed_data/project_train
x = X_test*W';

figure;
hold all;
for j = 1:90
    plot3(x(Y_tst2==j,1),x(Y_tst2==j,2),x(Y_tst2==j,3),'x')
end

X_test_p = x;
save  processed_data/test_X X_test_p Y_tst2