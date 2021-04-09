function [features] = get_features_release(clean_data,fs)
    %
    % get_features_release.m
    %
    % Instructions: Write a function to calculate features.
    %               Please create 4 OR MORE different features for each channel.
    %               Some of these features can be of the same type (for example, 
    %               power in different frequency bands, etc) but you should
    %               have at least 2 different types of features as well
    %               (Such as frequency dependent, signal morphology, etc.)
    %               Feel free to use features you have seen before in this
    %               class, features that have been used in the literature
    %               for similar problems, or design your own!
    %
    % Input:    clean_data: (samples x channels)
    %           fs:         sampling frequency
    %
    % Output:   features:   (1 x (channels*features))
    % 
%% Your code here (8 points)
    nchannels = size(clean_data,2);
    nfeatures = 6;
    % Initialize output matrix
    features = zeros(nchannels,nfeatures);
    
%     % Area
%     AFn = @(x) sum(abs(x));
%     % Energy
%     EFn = @(x) sum(x.*x);
%     % Line Length
%     LLFn = @(x) sum(abs(diff(x)));
%     % zx corssing
%     ZXFn = @(x) sum(((x(1:end - 1)- mean(x) > 0) .* (x(2:end) - mean(x) < 0)) | ((x(1:end - 1)- mean(x) < 0) .* (x(2:end) - mean(x) > 0)));
%     
    % Average time-domain voltage
    ATDVFn = @(x) mean(x);
    
    % Average frequency-domain magnitude in consecutive 15 Hz bands
    freqs = linspace(0,200,201);
    for i = 1:nchannels
        x = clean_data(:,i);
       
        features(i,1) = ATDVFn(x);
        s = spectrogram(x,100,50,freqs,fs,'yaxis');
        features(i,2) = mean(abs(s(9:13)));
        features(i,3) = mean(abs(s(19:25)));
        features(i,4) = mean(abs(s(76:116)));
        features(i,5) = mean(abs(s(126:160)));
        features(i,6) = mean(abs(s(160:176)));
        
%         features(i,7) = AFn(x);
%         features(i,8) = EFn(x);
%         features(i,9) = LLFn(x);
%         features(i,10) = ZXFn(x);

    end
    % 1 x [(feat 1.....64 channels)(feat 2 ...... 64 channels) etc]
    features = (reshape(features,[], 1))';
end

