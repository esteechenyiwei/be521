function [R]=create_R_matrix_release(features, N_wind)
    %
    % get_features_release.m
    %
    % Instructions: Write a function to calculate R matrix.             
    %
    % Input:    features:   (samples x (channels*features))
    %           N_wind:     Number of windows to use
    %
    % Output:   R:          (samples x (N_wind*channels*features))
    % 
%% Your code here (5 points)
    numSamples = length(features(:, 1));
    % pad with the first n-1 rows
    padded_features = cat(1, features(1: N_wind - 1, :), features);

    % split the padded features matrix into 6 individual vertical groups of columns,
    % where each group rcontains (num_channel) columns. 
    numChans = length(padded_features(1, :)) / 6;
    f1 = padded_features(:, 1:numChans);
    f2 = padded_features(:, numChans + 1: 2 * numChans);
    f3 = padded_features(:, 2 * numChans + 1: 3 * numChans);
    f4 = padded_features(:, 3 * numChans + 1: 4 * numChans);
    f5 = padded_features(:, 4 * numChans + 1: 5 * numChans);
    f6 = padded_features(:, 5 * numChans + 1: 6 * numChans);
%     % last 4 features
%     f7 = padded_features(:, 6 * numChans + 1: 7 * numChans);
%     f8 = padded_features(:, 7 * numChans + 1: 8 * numChans);
%     f9 = padded_features(:, 8 * numChans + 1: 9 * numChans);
%     f10 = padded_features(:, 9 * numChans + 1: 10 * numChans);
    
    % used to the actual 6 groups of columns in the R matrix
    % A - f1, B - f2, etc..... (from left to right in the R matrix)
    A = zeros(numSamples, N_wind * numChans); %f1
    B = zeros(numSamples, N_wind * numChans); %f2
    C = zeros(numSamples, N_wind * numChans); %f3
    D = zeros(numSamples, N_wind * numChans); %f4
    E = zeros(numSamples, N_wind * numChans); %f5
    F = zeros(numSamples, N_wind * numChans); %f6
%     % last 4 
%     G = zeros(numSamples, N_wind * numChans); %f7
%     H = zeros(numSamples, N_wind * numChans); %f8
%     I = zeros(numSamples, N_wind * numChans); %f9
%     J = zeros(numSamples, N_wind * numChans); %f10
    
   
    for i = N_wind : numSamples + N_wind - 1 % outer loop: loop rows in the unpadded part, in total M rows (1 + n-1 to M+n-1)
%         all_channels_feats_all_groups = cell(1, 10);
%         for k = 1:10
%             all_channels_feats_all_groups{1, i} = zeros(N_wind, numChans);
%         end
        all_channels_featA = zeros(N_wind, numChans);
        all_channels_featB = zeros(N_wind, numChans);
        all_channels_featC = zeros(N_wind, numChans);
        all_channels_featD = zeros(N_wind, numChans);
        all_channels_featE = zeros(N_wind, numChans);
        all_channels_featF = zeros(N_wind, numChans); 
%         all_channels_featG = zeros(N_wind, numChans);
%         all_channels_featH = zeros(N_wind, numChans);
%         all_channels_featI = zeros(N_wind, numChans);
%         all_channels_featJ = zeros(N_wind, numChans); 
           
        j = N_wind;
        
        while j > 0 % inner loop: loop from i - N_wind (smallest, 1) + 1 to i itself (N)
            
            all_channels_featA(N_wind - j + 1, :) =  f1(i - j + 1, :);
            all_channels_featB(N_wind - j + 1, :) =  f2(i - j + 1, :);
            all_channels_featC(N_wind - j + 1, :) =  f3(i - j + 1, :);
            all_channels_featD(N_wind - j + 1, :) =  f4(i - j + 1, :);
            all_channels_featE(N_wind - j + 1, :) =  f5(i - j + 1, :);
            all_channels_featF(N_wind - j + 1, :) =  f6(i - j + 1, :);
%             all_channels_featG(N_wind - j + 1, :) =  f7(i - j + 1, :);
%             all_channels_featH(N_wind - j + 1, :) =  f8(i - j + 1, :);
%             all_channels_featI(N_wind - j + 1, :) =  f9(i - j + 1, :);
%             all_channels_featJ(N_wind - j + 1, :) =  f10(i - j + 1, :);
            
            j = j - 1;
        end
        
        % store the rows into each feature group 
        A(i - N_wind + 1, :) = (reshape(all_channels_featA, [], 1))';
        B(i - N_wind + 1, :) = (reshape(all_channels_featB, [], 1))';
        C(i - N_wind + 1, :) = (reshape(all_channels_featC, [], 1))';
        D(i - N_wind + 1, :) = (reshape(all_channels_featD, [], 1))';
        E(i - N_wind + 1, :) = (reshape(all_channels_featE, [], 1))';
        F(i - N_wind + 1, :) = (reshape(all_channels_featF, [], 1))';
%         G(i - N_wind + 1, :) = (reshape(all_channels_featG, [], 1))';
%         H(i - N_wind + 1, :) = (reshape(all_channels_featH, [], 1))';
%         I(i - N_wind + 1, :) = (reshape(all_channels_featI, [], 1))';
%         J(i - N_wind + 1, :) = (reshape(all_channels_featJ, [], 1))';
         
    end
    
%   combine the 6 feature groups into 1 by cat
    o = ones(length(A(:, 1)), 1);
    R = cat(2, o, A, B, C, D, E, F);
        
        
    
    


end