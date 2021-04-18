function [predicted_dg] = flatten_small_spikes(prediction_interpolated)

    predicted_dg = cell(3, 1);
    
    % after noise reduction, flatten small spikes
    
    % set thresholds
    max_threshold = 1.5;
    min_threshold = 0.2;
    % number of runs
    numRuns = 10;
    % half-width of spike replacement
    half_width = 50;
    
    
    for run = 1:numRuns
        for sub = 1:3
            predicted_dg{sub,1} = zeros(147500,1);
            thispatient = prediction_interpolated{sub,1};
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
                    spikestart = index_spikes(spike,1)-half_width;
                    spikeend = index_spikes(spike,1)+half_width;

                    if spikestart < 0
                        spikestart = 1;
                    end
                    if spikeend > 147500
                        spikeend = 147500;
                    end

                    %flattened(spikestart:spikeend) = 0;
                    flattened(spikestart:spikeend) = spline([spikestart,spikeend],...
                    [flattened(spikestart),flattened(spikeend)],...
                    spikestart:spikeend);
                end
                predicted_dg{sub, 1}(:,finger) = flattened;
            end

        end
    end