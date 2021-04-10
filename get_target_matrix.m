function [Y] = get_target_matrix(labels, window_length, window_overlap, fs)
    % downsampling
    
    downsampled_labels = downsample(labels, 40);
    % sampling rate decreases by 40 times
    new_fs = fs / 40;
    
    % using the old data to get numWin
    numWin = floor((length(downsampled_labels(:, 1))/new_fs - window_length)/(window_length - window_overlap)) + 1;
    
    windows_fingers_df = zeros(numWin, 5); 

    % Then, loop through sliding windows    
    for i = 1: numWin
        % get the start finger angle that corresponds to the features of
        % that window
        up = int64((i - 1) * new_fs * (window_length - window_overlap)) + 1 + 1;

        % (vertically cutting out windows)
        % each window contains 5 data point
        windows_fingers_df(i, :) = downsampled_labels(up, :); 
    end
    
    % no apply r matrix
    Y = windows_fingers_df;
end