function [predicted_dg] = interpolation(prediction)
    p1 = prediction{1, 1};
    p2 = prediction{1, 2};
    p3 = prediction{1, 3};
    % pad the beginning to make interpolation easier
    p1_padded = cat(1, p1(1, :), p1);
%     p1_padded = cat(1, p1_padded, p1(length(p1), :));
    p2_padded = cat(1, p2(1, :), p2);
%     p2_padded = cat(1, p2_padded, p2(length(p2), :));
    p3_padded = cat(1, p3(1, :), p3);
%     p3_padded = cat(1, p3_padded, p3(length(p3), :));
    predCell = cell({p1_padded, p2_padded, p3_padded});
    predicted_dg = cell(3, 1);
    for i = 1:3      
        content = predCell{1, i};
        % interpolate each finger
        v1 = spline(1:50:147451, content(:, 1), 1:1:147500)';
        v2 = spline(1:50:147451, content(:, 2), 1:1:147500)';
        v3 = spline(1:50:147451, content(:, 3), 1:1:147500)';
        v4 = spline(1:50:147451, content(:, 4), 1:1:147500)';
        v5 = spline(1:50:147451, content(:, 5), 1:1:147500)';
        predicted_dg{i, 1} = cat(2, v1, v2, v3, v4, v5);
    end
    
    % reduce the magnitude of the noise in background by multiplying a reducing
    % factor to all signal below a threshold
    for sub = 1:3
        filtered = predicted_dg{sub, 1};
        for i = 1:147500
            if filtered(i) < 0.7
                filtered(i) = filtered(i) * 0.1;
                %         else if filtered(i) > 1.3
                %             filtered(i) = filtered(i) * 2;
                %         end
            end
        end
        predicted_dg{sub, 1} = filtered;
    end
end

