%% Final project part 2



%% using the .mat file data (no need to load again)

load('raw_training_data.mat');

%% parameters that we can adjust:
% porportion of training data
p_train = 1;

% N value in the create R matrix function
N = 3;

% window length of the moving window, as well as overlap (in second)
win_len = 0.1;
win_overlap = 0.05;

%%

fs = 1000; 

sub1_dg = train_dg{1};
sub2_dg = train_dg{2};
sub3_dg = train_dg{3};

sub1_ecog = train_ecog{1};
sub2_ecog = train_ecog{2};
sub3_ecog = train_ecog{3};


len = length(sub1_ecog);

sub1_train = sub1_ecog(1:len * p_train, :);
sub2_train = sub2_ecog(1:len * p_train, :);
sub3_train = sub3_ecog(1:len * p_train, :);



%% Get Features
% run getWindowedFeats_release function, normalize the data

%% patient 1
all_feats1 = getWindowedFeats(sub1_train, fs, win_len, win_overlap);

all_feats1 = normalize(all_feats1);

% patient 2 features
all_feats2 = normalize(getWindowedFeats(sub2_train, fs, win_len, win_overlap));

% patient 3 features
all_feats3 = normalize(getWindowedFeats(sub3_train, fs, win_len, win_overlap));


%% Q3.2 Create R matrix
% run create_R_matrix
R1 = create_R_matrix(all_feats1, N);
R2 = create_R_matrix(all_feats2, N);
R3 = create_R_matrix(all_feats3, N);


%% Train classifiers (8 points)

%% Q4.1 Classifier 1: 
% Classifier 1: Get angle predictions using optimal linear decoding. That is, 
% calculate the linear filter (i.e. the weights matrix) as defined by 
% Equation 1 for all 5 finger angles.


% get the target matrix (M x 5), from the training part of the dataglove
% data

Y1_train = get_target_matrix(sub1_dg(1:len * p_train, :), win_len, win_overlap, fs);
Y2_train = get_target_matrix(sub2_dg(1:len * p_train, :), win_len, win_overlap, fs);
Y3_train = get_target_matrix(sub3_dg(1:len * p_train, :), win_len, win_overlap, fs);

f1 = (R1' * R1) \ (R1' * Y1_train);
f2 = (R2' * R2) \ (R2' * Y2_train);
f3 = (R3' * R3) \ (R3' * Y3_train);

% store the f's

f_values = cell({f1, f2, f3});


Ypred1 = R1 * f1;
Ypred2 = R2 * f2;
Ypred3 = R3 * f3;


%% CALL THE MAKE PREDICTIONS FILE

cd('/Users/qian/Desktop/BE521/homeworks/Final_Project_Competition');
load('leaderboard_data.mat');


pd = make_predictions(leaderboard_ecog, fs, win_len, win_overlap, N, f_values);



%% predicted_dg, interpolation
p = cell(1, 3);
predicted_dg = cell(3, 1);

% pad
for i = 1:3
   % add one more window to make interpolation easier
   cell_content = pd{1, i};
   p{1, i} = cat(1, cell_content, cell_content(size(cell_content, 1), :)); 
   
   v1 = spline(1:50:147451, p{1, i}(:, 1), 1:1:147500)';
   v2 = spline(1:50:147451, p{1, i}(:, 2), 1:1:147500)';
   v3 = spline(1:50:147451, p{1, i}(:, 3), 1:1:147500)';
   v4 = spline(1:50:147451, p{1, i}(:, 4), 1:1:147500)';
   v5 = spline(1:50:147451, p{1, i}(:, 5), 1:1:147500)';
   % interpolate each finger
   predicted_dg{i, 1} = cat(2, v1, v2, v3, v4, v5);
   
end

% % no pad
% for i = 1:3
%    % add one more window to make interpolation easier
%    cell_content = pd{1, i};
%    
%    v1 = spline(1:50:147401, p{1, i}(:, 1), 1:1:147500)';
%    v2 = spline(1:50:147401, p{1, i}(:, 2), 1:1:147500)';
%    v3 = spline(1:50:147401, p{1, i}(:, 3), 1:1:147500)';
%    v4 = spline(1:50:147401, p{1, i}(:, 4), 1:1:147500)';
%    v5 = spline(1:50:147401, p{1, i}(:, 5), 1:1:147500)';
%    % interpolate each finger
%    predicted_dg(i, 1} = cat(2, v1, v2, v3, v4, v5);
%    
% end


%% testing with parts of part 1 data

cd('/Users/qian/Desktop/BE521/homeworks/Final_Project_Competition');
load('final_proj_part1_data.mat');
%%
train_ecog{1, 1}(:, 62) =train_ecog{1, 1}(:, 61); 
train_ecog{2, 1}(:, 47) =train_ecog{2, 1}(:, 46); 
train_ecog{2, 1}(:, 48) =train_ecog{2, 1}(:, 46); 

%%
test_prediction = make_predictions(train_ecog, fs, win_len, win_overlap, N, f_values);


%% get correlation
rho_subject1 = zeros(1, 5);
rho_subject2 = zeros(1, 5);
rho_subject3 = zeros(1, 5);

testy1 = get_target_matrix(train_dg{1, 1}, win_len, win_overlap, fs);
testy2 = get_target_matrix(train_dg{1, 2}, win_len, win_overlap, fs);
testy3 = get_target_matrix(train_dg{1, 3}, win_len, win_overlap, fs);

for i = 1:5
    rho_subject1(1, i) = corr(testy1(:, i), test_prediction{1, 1}(:, i));
    rho_subject2(1, i) = corr(testy2(:, i), test_prediction{1, 2}(:, i));
    rho_subject3(1, i) = corr(testy3(:, i), test_prediction{1, 3}(:, i));
end

% correlation for each finger for subject 1, 2, 3:
rho_subject1
rho_subject2
rho_subject3



%% helper functions
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
