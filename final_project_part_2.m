%% Final project part 2

% Andrew's notes:
% Trial 1: N = 5
%   Test result: avg_corr = 0.7691
%   Result: R = 0.4470
% Trial 2: N = 5, used flatten_small_spikes.m
%   Test result: avg_corr = 0.7688
%   Result: R = 0.4409
% Trial 3: N = 5, used flatten_small_spikes.m, numRuns = 3
%   Test result: avg_corr = 0.7703
%   Result: 0.4409
% Trial 4: N = 4
%   Test result: avg_corr = 0.7355
%   Result: ?
% Trial 5: N = 4, used flatten_small_spikes.m
%   Test result: avg_corr = 0.7310
%   Result: ?
% Trial 6: N = 4, used flatten_small_spikes.m with spline setting instead
% of just setting peaks to 0
%   Test result: avg_corr = 0.7441
%   Result: ?
% Trial 7: N = 4, used flatten_small_spikes.m with spline setting instead
% of just setting peaks to 0, thresholds: 0.2 to 1.5
%   Test result: 0.7735
%   Result: ?
% Trial 8: N = 5, used flatten_small_spikes.m with spline setting instead
% of just setting peaks to 0, thresholds: 0.2 to 1.5
%   Test result: 0.7993
%   Result: 0.4556
% Trial 9: N = 7, used flatten_small_spikes.m with spline setting instead
% of just setting peaks to 0, thresholds: 0.2 to 1.5
%   Test result: 0.8437
%   Result: 0.4442
% Trial 10: N = 7, used flatten_small_spikes.m with spline setting instead
% of just setting peaks to 0, thresholds: 0.2 to 1.5, 10 runs of flattening
%   Test result: 0.8437
%   Result: 0.4442  (?)
% Trial 11: N = 7, used flatten_small_spikes.m with spline setting instead
% of just setting peaks to 0, thresholds: 0.2 to 1.5, 10 runs of
% flattening, +- 50 points
%   Test result: 0.8437
%   Result: 0.4588

%% using the .mat file data (no need to load again)

load('raw_training_data.mat');

%% parameters that we can adjust:
% porportion of training data
p_train = 1;

% N value in the create R matrix function
N = 7;

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

% patient 2 features
all_feats2 = getWindowedFeats(sub2_train, fs, win_len, win_overlap);

% patient 3 features
all_feats3 = getWindowedFeats(sub3_train, fs, win_len, win_overlap);


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

%cd('/Users/qian/Desktop/BE521/homeworks/Final_Project_Competition');
load('leaderboard_data.mat');


predicted_dg = make_predictions(leaderboard_ecog, fs, win_len, win_overlap, N, f_values);

%% (Kenneth) Test the interpolation method on training data and calculate average correlation 
% duplicate the first and last row to have 6000 points for interpolation
Ypred1_padded = cat(1, Ypred1(1, :), Ypred1);
Ypred1_padded = cat(1, Ypred1_padded, Ypred1(length(Ypred1), :));
Ypred2_padded = cat(1, Ypred2(1, :), Ypred2);
Ypred2_padded = cat(1, Ypred2_padded, Ypred2(length(Ypred2), :));
Ypred3_padded = cat(1, Ypred3(1, :), Ypred3);
Ypred3_padded = cat(1, Ypred3_padded, Ypred3(length(Ypred3), :));
% interpolate each subject to obtain 300000 prediction values
predCell = cell({Ypred1_padded, Ypred2_padded, Ypred3_padded});
predict_dg_train = cell(3, 1);
for i = 1:3
   content = predCell{1, i};
   % interpolate each finger
   v1 = spline(1:50:299951, content(:, 1), 1:1:300000)';
   v2 = spline(1:50:299951, content(:, 2), 1:1:300000)';
   v3 = spline(1:50:299951, content(:, 3), 1:1:300000)';
   v4 = spline(1:50:299951, content(:, 4), 1:1:300000)';
   v5 = spline(1:50:299951, content(:, 5), 1:1:300000)';
   predict_dg_train{i, 1} = cat(2, v1, v2, v3, v4, v5);
end

% reduce the magnitude of the noise in background by multiplying a reducing
% factor to all signal below a threshold
for sub = 1:3
    filtered = predict_dg_train{sub, 1};
    for i = 1:len
        if filtered(i) < 0.7
            filtered(i) = filtered(i) * 0.1;
%         else if filtered(i) > 1.3
%             filtered(i) = filtered(i) * 2;
%         end
        end
    end
    predict_dg_train{sub, 1} = filtered;
end

% after noise reduction, flatten small spikes

% set thresholds
    max_threshold = 1.5;
    min_threshold = .2;

for run = 1:10
    for sub = 1:3
        thispatient = predict_dg_train{sub,1};
        % loop through fingers
        for finger = 1:5
            flattened = thispatient(:,finger);

            % store first and last element for final padding
            %f_first = flattened(1);
            %f_last = flattened(end);

            % find where first derivative changes sign from positive to negative
            index_d1 = diff(flattened)<0; % 1 = positive derivative, 0 = negative derivative
             % 1 = neg to pos, 0 = no change, -1 = pos to neg.
            index_d2 = diff(index_d1);
            index_threshold = (flattened(2:end-1)>min_threshold) & (flattened(2:end-1)<max_threshold);
            % find indices of nonzero elements.
            % i.e., where threshold is passed AND pos to neg derivative
            index_spikes = find(index_d2 .* index_threshold);

            for spike = 1:size(index_spikes,1)
                spikestart = index_spikes(spike,1)-50;
                spikeend = index_spikes(spike,1)+50;

                if spikestart < 0
                    spikestart = 1;
                end
                if spikeend > 300000
                    spikeend = 300000;
                end

                %flattened(spikestart:spikeend) = 0;
                flattened(spikestart:spikeend) = spline([spikestart,spikeend],...
                    [flattened(spikestart),flattened(spikeend)],...
                    spikestart:spikeend);
            end
            predict_dg_train{sub, 1}(:,finger) = flattened;
        end
    end
end

% calculate average correlation
rho_sub1 = corr(sub1_dg, predict_dg_train{1, 1});
rho_sub2 = corr(sub2_dg, predict_dg_train{2, 1});
rho_sub3 = corr(sub3_dg, predict_dg_train{3, 1});
corr_sub1 = diag(rho_sub1);
corr_sub2 = diag(rho_sub2);
corr_sub3 = diag(rho_sub3);
% Only care about finger 1,2,3 and 5
corr1 = (sum(corr_sub1) - corr_sub1(4))/4;
corr2 = (sum(corr_sub2) - corr_sub2(4))/4;
corr3 = (sum(corr_sub3) - corr_sub3(4))/4;
avg_corr = (corr1 + corr2 + corr3)/3

% plot segments of the predicted angles and the actual angles of subject 1
figure(1)
hold on
pred1 = predict_dg_train{1, 1};
plot(pred1(90000:140000), 'r');
%plot([index_d1,1],'k');
plot(sub1_dg(90000:140000), 'b');
hold off

%% predicted_dg, interpolation
% p = cell(1, 3);
% predicted_dg = cell(3, 1);
% 
% % pad
% for i = 1:3
%    % add one more window to make interpolation easier
%    cell_content = pd{1, i};
%    p{1, i} = cat(1, cell_content, cell_content(size(cell_content, 1), :)); 
%    
%    v1 = spline(1:50:147451, p{1, i}(:, 1), 1:1:147500)';
%    v2 = spline(1:50:147451, p{1, i}(:, 2), 1:1:147500)';
%    v3 = spline(1:50:147451, p{1, i}(:, 3), 1:1:147500)';
%    v4 = spline(1:50:147451, p{1, i}(:, 4), 1:1:147500)';
%    v5 = spline(1:50:147451, p{1, i}(:, 5), 1:1:147500)';
%    % interpolate each finger
%    predicted_dg{i, 1} = cat(2, v1, v2, v3, v4, v5);
%    
% end
% 
% % % no pad
% % for i = 1:3
% %    % add one more window to make interpolation easier
% %    cell_content = pd{1, i};
% %    
% %    v1 = spline(1:50:147401, p{1, i}(:, 1), 1:1:147500)';
% %    v2 = spline(1:50:147401, p{1, i}(:, 2), 1:1:147500)';
% %    v3 = spline(1:50:147401, p{1, i}(:, 3), 1:1:147500)';
% %    v4 = spline(1:50:147401, p{1, i}(:, 4), 1:1:147500)';
% %    v5 = spline(1:50:147401, p{1, i}(:, 5), 1:1:147500)';
% %    % interpolate each finger
% %    predicted_dg(i, 1} = cat(2, v1, v2, v3, v4, v5);
% %    
% % end
% 
% 
% %% testing with parts of part 1 data
% 
% cd('/Users/qian/Desktop/BE521/homeworks/Final_Project_Competition');
% load('final_proj_part1_data.mat');
% %%
% train_ecog{1, 1}(:, 62) =train_ecog{1, 1}(:, 61); 
% train_ecog{2, 1}(:, 47) =train_ecog{2, 1}(:, 46); 
% train_ecog{2, 1}(:, 48) =train_ecog{2, 1}(:, 46); 
% 
% %%
% test_prediction = make_predictions(train_ecog, fs, win_len, win_overlap, N, f_values);
% 
% 
% %% get correlation
% % (Kenneth's comment) I think correlation needs to be calculated after
% % interpolation instead of calling corr() on the Y^ matrix and the
% % downsampled dataglove values. Also, the average correlation is calculated
% % as the average correlation of finger 1,2,3,5 for each subject. See my
% % section for the average correlation calculation
% rho_subject1 = zeros(1, 5);
% rho_subject2 = zeros(1, 5);
% rho_subject3 = zeros(1, 5);
% 
% testy1 = get_target_matrix(train_dg{1, 1}, win_len, win_overlap, fs);
% testy2 = get_target_matrix(train_dg{1, 2}, win_len, win_overlap, fs);
% testy3 = get_target_matrix(train_dg{1, 3}, win_len, win_overlap, fs);
% 
% for i = 1:5
%     rho_subject1(1, i) = corr(testy1(:, i), test_prediction{1, 1}(:, i));
%     rho_subject2(1, i) = corr(testy2(:, i), test_prediction{1, 2}(:, i));
%     rho_subject3(1, i) = corr(testy3(:, i), test_prediction{1, 3}(:, i));
% end
% 
% % correlation for each finger for subject 1, 2, 3:
% rho_subject1
% rho_subject2
% rho_subject3


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
