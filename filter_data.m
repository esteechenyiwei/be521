function clean_data = filter_data_release(raw_eeg)
    %
    % filter_data_release.m
    %
    % Instructions: Write a filter function to clean underlying data.
    %               The filter type and parameters are up to you.
    %               Points will be awarded for reasonable filter type,
    %               parameters, and correct application. Please note there 
    %               are many acceptable answers, but make sure you aren't 
    %               throwing out crucial data or adversely distorting the 
    %               underlying data!
    %
    % Input:    raw_eeg (samples x channels)
    %
    % Output:   clean_data (samples x channels)
    % 
%% Your code here (2 points) 

    %% UNFINISHED =========== FILTER DATA ===============
    % use a band pass filter because we want to focus on spikes that have
    % the frequency from 0.2 hz to 200 hz.
    
    load('coefficients.mat');
    clean_data = filtfilt(Num, 1, raw_eeg);
    
    
    %% do CAR filtering
    numchans = size(raw_eeg, 2);
    
    common_averages = mean(raw_eeg, 2);
    mat = repmat(common_averages, 1, numchans);
    
    % cleaned data = origianl data - mean of each row across channels
    clean_data = clean_data - mat;
    
    
    
end