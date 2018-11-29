function [positions] = gravity (filename)

% clear
clearvars -except filename
close all;
clc;

% import data
inputdata (filename);

% process data
pos = [x, y, z];
vel = [u, v, w];

% new plot
set(0, 'DefaultFigureWindowStyle', 'docked')
if (isplot)
    figure;
else
    close all;
end

% define constants
G = 1;

% store positions and velocites
positions = zeros(size(pos, 1), size(pos, 2), size(pos, 3), nIter);
positions (:, :, 1) = pos;
velocities = zeros(size(pos, 1), size(pos, 2), size(pos, 3), nIter);
velocities (:, :, 1) = vel;
accelerations = zeros(size(pos, 1), size(pos, 2), size(pos, 3), nIter);

% main loop
for iter = 1:nIter
    % display status
    fprintf ('No. of iterations run = %d of %d.', iter - 1, nIter);
    disp (' ');
    
    % calculate accelerations
    acc = zeros(size(pos, 1), size(pos, 2));
    for ind_a = 1:size(positions, 1)
        % temp var
        temp = zeros(1, 3);
        for ind_b = 1:size(positions, 1)
            % not self
            if (ind_a ~= ind_b)
                % direction and distance
                dir = positions (ind_b, :, iter) - positions (ind_a, :, iter);
                dist = norm(dir, 2);
                dir = dir / dist;
                
                % superposition
                if (dist >= 0.1)
                    temp = temp + G * mass (ind_b) * dir / (dist) ^ 2;
                end
            end
        end
        acc (ind_a, :) = temp;
    end
    
    % store accelerations
    accelerations (:, :, iter) = acc;
    
    % update velocities;
    velocities (:, :, :, iter + 1) = velocities (:, :, iter) + accelerations (:, :, iter) * dt;
    
    % update positions;
    positions (:, :, :, iter + 1) = positions (:, :, iter) + velocities (:, :, iter) * dt;
end
% display status
fprintf ('No. of iterations run = %d of %d.', iter, nIter);
disp (' ');

% center each frame if required
if (iscenter)
    for iter = 1:nIter + 1
        % display status
        fprintf ('No. of positions centered = %d of %d.', iter - 1, nIter);
        disp (' ');
        
        % update positions
        positions (:, 1, iter) = positions (:, 1, iter) - positions (center, 1, iter) * ones(size(pos, 1), 1, 1);
        positions (:, 2, iter) = positions (:, 2, iter) - positions (center, 2, iter) * ones(size(pos, 1), 1, 1);
        positions (:, 3, iter) = positions (:, 3, iter) - positions (center, 3, iter) * ones(size(pos, 1), 1, 1);
    end
    fprintf ('No. of positions centered = %d of %d.', iter, nIter);
    disp (' ');
end

% plot if required
if (isplot)
    % alarm for attention
    for ind_a = 1:5
        beep;
        pause(1);
    end
    
    % pause if required
    if (ispause)
        keyboard;
    end
    
    hold off;
    if (ishold)
        hold on;
    end
    
    % get graph limits
    pos_x = positions(:, 1, 1, :);
    pos_y = positions(:, 2, 1, :);
    pos_z = positions(:, 3, 1, :);
    lim_x = max(max(abs(pos_x))) + 1e-3;
    lim_y = max(max(abs(pos_y))) + 1e-3;
    lim_z = max(max(abs(pos_z))) + 1e-3;
    for iter = 1:nIter
        if (mod(iter - 1, jump) == 0)
            % display status
            fprintf ('No. of images plotted = %d of %d.', (iter - 1) / jump, nIter / jump);
            disp (' ');
            
            % plot the positions
            if (isproj)
                plot(positions (:, 1, iter), positions (:, 2, iter), '.');
                axis([-lim_x, lim_x, -lim_y, lim_y], 'square');
            else
                plot3(positions (:, 1, iter), positions (:, 2, iter), positions (:, 3, iter), '.');
                axis([-lim_x, lim_x, -lim_y, lim_y, -lim_z, lim_z], 'equal');
            end
            % plot the positions
            %     plot3(positions (:, 1, iter), positions (:, 2, iter), positions (:, 3, iter), '*');
            %     axis([-lim, lim, -lim, lim, -lim, lim]);
            pause (0.01);
        end
    end
    % display status
    fprintf ('No. of images plotted = %d of %d.', iter / jump, nIter / jump);
    disp (' ');
end

end

% -------------------------------------------------------------------------

function [] = inputdata (filename)

% sub function - import data and create variables

% import data
input = importdata (filename);

% name of variables
vars = input.textdata;

% assign values and return variables To_coeff workspace
for index = 1:length(vars)
    if ~(strcmp(vars{index}, ''))
        variable = [];
        for ind_i = 1:length(input.data (:,index))
            if ~(isnan(input.data (ind_i, index)))
                variable = [variable, input.data(ind_i, index)]; %#ok<AGROW>
            end
        end
        
        assignin ('caller', vars{index}, variable');
    end
end

end