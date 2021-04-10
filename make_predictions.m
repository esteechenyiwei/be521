function [predicted_dg] = make_predictions(test_ecog, fs, win_len, win_overlap, N, f_values)

% INPUTS: test_ecog - 3 x 1 cell array containing ECoG for each subject, where test_ecog{i} 
% to the ECoG for subject i. Each cell element contains a N x M testing ECoG,
% where N is the number of samples and M is the number of EEG channels.

% OUTPUTS: predicted_dg - 3 x 1 cell array, where predicted_dg{i} contains the 
% data_glove prediction for subject i, which is an N x 5 matrix (for
% fingers 1:5)

% Run time: The script has to run less than 1 hour. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% optimal linear decode test 

    % load the data
    %%

    % get windowed features for the test data

    % patient 1
    feats1 = getWindowedFeats(test_ecog{1}, fs, win_len, win_overlap);

    % patient 2 features
    feats2 = getWindowedFeats(test_ecog{2}, fs, win_len, win_overlap);
    % patient 3 features
    feats3 = getWindowedFeats(test_ecog{3}, fs, win_len, win_overlap);

    R1test = create_R_matrix(feats1, N);
    R2test = create_R_matrix(feats2, N);
    R3test = create_R_matrix(feats3, N);

    p1 = R1test * f_values{1};
    p2 = R2test * f_values{2};
    p3 = R3test * f_values{3};
    
   

    % calculate correlation coefficients between predicted and actual label for
    % each finger, for each subject

    
    prediction = cell({p1, p2, p3});
    predicted_dg = interpolation(prediction);

end

