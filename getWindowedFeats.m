function [all_feats]=getWindowedFeats_release(raw_data, fs, window_length, window_overlap)
    %
    % getWindowedFeats_release.m
    %
    % Instructions: Write a function which processes data through the steps
    %               of filtering, feature calculation, creation of R matrix
    %               and returns features.
    %
    %               Points will be awarded for completing each step
    %               appropriately (note that if one of the functions you call
    %               within this script returns a bad output you won't be double
    %               penalized)
    %
    %               Note that you will need to run the filter_data and
    %               get_features functions within this script. We also 
    %               recommend applying the create_R_matrix function here
    %               too.
    %
    % Inputs:   raw_data:       The raw data for all patients
    %           fs:             The raw sampling frequency
    %           window_length:  The length of window *** in second
    %           window_overlap: The overlap in window *** in second
    %
    % Output:   all_feats:      All calculated features
    %
%% Your code here (3 points)

% First, filter the raw data
    clean_data = filter_data(raw_data);

    
    % calculate the num of windows
    numchans = length(clean_data(1, :));
    numWin = floor((length(clean_data)/fs - window_length)/(window_length - window_overlap)) + 1;
    % numwins x total # of features (channels * 6)
    windows_features_df = zeros(numWin, numchans * 6); % there are 6 features
    
    datasInWindow = window_length * fs; % how samples in the duration of window length

    % Then, loop through sliding windows    
    for i = 1: numWin
        % get the window bound
        up = (i - 1) * fs * (window_length - window_overlap) + 1; % how many displacements before this
        down = up + datasInWindow - 1;
        % (vertically cutting out windows)
        % Within loop calculate feature for each segment (call get_features)
        windows_features_df(i, :) = get_features_andrew(clean_data(up:down, :), fs); 
    end
    
    % no apply r matrix
    all_feats = windows_features_df;

   
% Finally, return feature matrix

end