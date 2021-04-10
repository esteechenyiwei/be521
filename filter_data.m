function clean_data = filter_data(raw_eeg)
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
    bpfilt = designfilt('bandpassfir', 'FilterOrder', 20, 'CutoffFrequency1',0.15,'CutoffFrequency2',200,'SampleRate',1000);
    bpfiltered = filter(bpfilt, raw_eeg);
    % common average reference filter
    signal_total = zeros(length(raw_eeg), 1);
    for i = 1:size(raw_eeg, 2)
        signal_total = signal_total + bpfiltered(:, i);
    end
    CAR = signal_total / size(raw_eeg, 2);
    clean_data = zeros(length(raw_eeg), size(raw_eeg, 2));
    for i = 1:size(raw_eeg, 2)
        clean_data(:, i) = bpfiltered(:, i) - CAR;
    end
end