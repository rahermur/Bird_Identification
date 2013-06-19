function [ output ,S ] = syllable_segmentation_train( Files,fc_1,fc_2,verbose)

% Files : File names of auio clips
% fc_1 : lower cut-off frequency of bandpass filter
% fc_2 : upper cut-off frequency of bandpass filter

% Spectogram window: 
WinSize = 256;
alpha_kaiser = 8;
overlap = WinSize/4;
NFFT = 512;
U = 30;
maxK = 150;
W = kaiser(WinSize,alpha_kaiser);

trainSamples = size(Files,1);

output = cell(trainSamples,1);
for i = 1:trainSamples
    
    [s,fs]=audioread(Files(i).name);
    [B1,A1] = butter(10,fc_2,'low');
    train1_low = filter(B1,A1,s);
    [B2,A2] = butter(10,fc_1,'high');
    signal = filter(B2,A2,train1_low);
    % signal=SSBoll79(signal,fs,2);
    % signal = WienerScalart96(signal,fs,0.25);
    % Calculating spectogram
    [P,F,T,S] = spectrogram(signal,W,overlap,NFFT,fs);
    if verbose
        figure(1);
        surf(T,F,20*log10(abs(S)),'edgecolor','none'); axis tight; 
        view(0,90);
        xlabel('Time (Seconds)'); ylabel('Hz');
    end
    % Initializing maximum of spectogram
    A_n = [];W_n = [];T_n = [];
    max_an0 = -180; an0 = max_an0;
    k = 1;
    % Threshold: 
    U2 = ( 20*log10(max(max(S))) - 20*log10(mean(mean(S))) )/3;
    while max_an0 - an0 < 2*U2
        % Segmentation procedure:
        [value, location] = max(abs(S(:)));
        [fn,tn] = ind2sub(size(S),location); 
        fn = fn(1); tn0 = tn(1); 
        if verbose
            disp(['Syllable ',num2str(k), 'position : freq (' , num2str(fn/size(S,1)*fs/2) ,') time (', num2str(tn/size(S,2)*30),')']);
        end
        wn0 = fn; an0 = 20*log10(value);
        an_plus = []; wn_plus = [];
        
        for k1 = 1:maxK
            if tn0+k1 > size(S,2)
                k1 = k1-1;
                break;
            end
            [an_plus(k1), wn_plus(k1)] = max(20*log10(abs(S(:,tn0+k1))));
            if an0 - an_plus(k1) > U 
                an_plus(k1) = []; 
                wn_plus(k1) = []; k1 = k1-1;
                break;
            end
        end
        
        an_minus = []; wn_minus = [];
        for k2 = 1:maxK
            if tn0 -k2 ==0 
                k2 = k2-1;
                break;
            end
            [an_minus(k2), wn_minus(k2)] = max(20*log10(abs(S(:,tn0-k2))));
            if an0 - an_minus(k2) > U 
                an_minus(k2) = []; 
                wn_minus(k2) = []; 
                k2 = k2-1;
                break;
            end
        end
         % Ampitude, Frequency and Time of the segmentated syllable 
        a = [an_minus(end:-1:1) an0 an_plus];
        w = [wn_minus(end:-1:1) wn0 wn_plus];
        t = tn0-k2:tn0+k1;
        
        if k==1
            max_an0 = an0;
        end
        
        S(:,t) = 10.^ ((max_an0 - 20*U)/20);
        
        A_n = [A_n a];
        W_n =[W_n w];
        T_n = [T_n t];
        
        k = k+1;
    end
    
    [T_n,Idx_T] = sort(T_n);
    A_n = A_n(Idx_T);
    W_n = W_n(Idx_T);
   
    if verbose
        figure(2);
        surf(T,F,20*log10(abs(S)),'edgecolor','none'); axis tight; 
        view(0,90);
        xlabel('Time (Seconds)'); ylabel('Hz');
    end

    output{i}.A_n = A_n; 
    output{i}.W_n = W_n;
    output{i}.T_n = T_n;
    if verbose 
        figure(3);
        plot(A_n)
        figure(4);
        plot(W_n)
    end
    disp('---------------------------------------')
    disp(['Training Sample: ',num2str(i), '  Bird: ' , num2str(Files(i).name) ]);
end

end

