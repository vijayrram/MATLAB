function [] = flowfree ()

% function FLOWFREE () solves a given flow-free puzzle

% leave space
disp (' ');

% get the inputs, constants and process them
getinput ();

% boolean for
found = false;

% variable to track generations
generation = 0;

% while a fitness samples is not found
while (~(found))
    % display status
    fprintf ('Working with generation %d', generation);
    disp (' ');
    
    % display status
    disp ('Calculating fitnesses.');
    
    % calculate fitness
    fitness (samples, dim, col, sam, pos, direction);
    
    % if a solution is not found
    if (~(found))
        
        % display status
        disp ('Removing the least fit samples.');
        
        % remove the least fitness
        remove (samples, cfitness, ffitness, tfitness, sample);
        
        % clear unnecessary variables
        clear *fitness
        
        % display status
        disp ('Mating the surviving samples.');
        
        % pick random pairs and mate them
        mate (samples, sam, mutation, dim);
        
        % update generation
        generation = generation + 1;
    end
    
    % leave a space
    disp (' ');
end

% assign solution to caller
assignin ('caller', 'solution', solution);

end

% -------------------------------------------------------------------------

function [] = getinput ()

% function GETINPUT () gets the inputs for the puzzle and processes them

% GET INPUT
% dimensions of the board
dim = input ('Input the dimensions of the board. (1, 2): ');

% number of colours
col = input ('Input the number of colours. (1, 1): ');

% number of samples
times = input ('Input the number of times the number of samples is to be multipled. (1, 1): ');
sample = input (sprintf ('Input the number of samples. NOTE: The number used will be %d times the input. (1, 1): ', times));
sam = sample * times;

% number of colours
mutation = input ('Input the mutation rate (R = P/Q as [P, Q]). (1, 2): ');

% leave space
disp (' ');

% INPUT POSITIONS OF THE COLOURS

% pre-allocation for speed
pos = cell (1);
for a = 1:col
    % first colour
    pos{a, 1} = input (sprintf ('Input the first position of colour %d.  (1, 2): ', a));
    
    % first colour
    pos{a, 2} = input (sprintf ('Input the second position of colour %d. (1, 2): ', a));
    
    % leave space
    disp (' ');
end

% PROCESSING

% GENERATE THE TEMPLATE

% empty board
template = zeros (dim);

% add the colours
for a = 1:col
    for b = 1:2
        template (pos{a, b}(1, 1), pos{a, b}(1, 2)) = a;
    end
end

% GENERATE SAMPLE SOLUTIONS

% pre-allocation for speed
samples = cell (1);

% direction of flows
for a = 1:sam
    samples{a} = randi (4, dim);
end

% remove redundant values (starting and stopping locations)
for a = 1:sam
    for b = 1:col
        samples{a}(pos{b, 2}(1, 1), pos{b, 2}(1, 2)) = NaN;
    end
end

% GET THE DIRECTIONS

% simple
direction = [-1,  0,  0,  1; 0, -1,  1,  0];

% assign variables back to workspace
assignin ('caller', 'dim', dim);
assignin ('caller', 'col', col);
assignin ('caller', 'sam', sam);
assignin ('caller', 'pos', pos);
assignin ('caller', 'sample', sample);
assignin ('caller', 'samples', samples);
assignin ('caller', 'direction', direction);
assignin ('caller', 'mutation', mutation);
% assignin ('caller', 'template', template);

end

% -------------------------------------------------------------------------

function [] = fitness (samples, dim, col, sam, pos, direction)

% function FITNESS calculates the fitness of all the samples

% VARIABLE - CLASS -- SIZE --- DESCRIPTION
% samples -- cell --- (1, n) ---- samples under consideration
% dim ------ double - (1, 2) ---- dimensions of the board
% col ------ double - (1, 1) ---- number of colours
% sam ------ double - (1, 1) ---- number of samples
% pos ------ cell --- (m, n) ---- positions of the colours
% direction ------ doule -- (4, 4, 2) - directions for moving

% fill in the samples and get connected fitness
filledsamples = cell(1);
cfitness = zeros;
fill (samples, dim, col, sam, pos, direction);

% CALCULATE FITNESS

% filled fitness
ffitness = zeros;
filled (filledsamples, dim, sam);

% total fitness
tfitness = cfitness .* ffitness;

% SEARCH FOR A SOLUTION

% boolean if a solution is found
found = false;

% search
indices = find (1 == tfitness);

% pre-allocation for speed
solution = cell (1);
for a = 1:size (indices, 2)
    % save found solutions
    solution{a, 1} = filledsamples{indices (a)};
    solution{a, 2} = samples{indices (a)};
    
    % note that a solution is found
    found = true;
end

% assign variables back to workspace
assignin ('caller', 'solution', solution);
assignin ('caller', 'cfitness', cfitness);
assignin ('caller', 'ffitness', ffitness);
assignin ('caller', 'tfitness', tfitness);
assignin ('caller', 'found', found);

end

% -------------------------------------------------------------------------

function [] = fill (samples, dim, col, sam, pos, direction)

% function FILL fills in the samples with the flowing colours

% VARIABLE ------ CLASS -- SIZE ------ DESCRIPTION
% samples ------- cell --- (1, n) ---- samples under consideration
% dim ----------- double - (1, 2) ---- dimensions of the board
% col ----------- double - (1, 1) ---- number of colours
% sam ----------- double - (1, 1) ---- number of samples
% pos ----------- cell --- (m, n) ---- positions of the colours
% direction ----- doule -- (4, 4, 2) - directions for moving
% filledsamples - cell --- (1, n) ---- filled samples under consideration

% BEGIN FILLING IN

% pre-allocation for speed
filledsamples = cell (1);
cfitness = zeros;

for a = 1:sam
    % temporary variable to store the filling sample
    tempfill = zeros (dim);
    
    % count of connected colours
    count = 0;
    
    % fill in the sample
    for b = 1:col
        % boolean for exiting from filling
        excon = false;
        
        % boolean for connected
        connected = false;
        
        % starting locations
        start = [pos{b}(1, 1), pos{b}(1, 2)];
        old = start;
        while (~(excon))
            % fill
            tempfill (old (1, 1), old (1, 2)) = b;
            
            % new co-ordinates
            if (~(isnan (samples{a}(old (1, 1), old (1, 2)))))
                new = old + [direction(1, samples{a}(old (1, 1), old (1, 2))),...
                    direction(2, samples{a}(old (1, 1), old (1, 2)))];
            end
            
            % LOOK FOR DEAD ENDS OR PATH COMPLETION
            
            % boolean variable for dead-end
            deadend = false;
            
            
            if ((new (1, 1) < 1) || (new (1, 2) < 1) || (new (1, 1) > dim (1, 1)) || (new (1, 2) > dim (1, 2)))
                % out of bounds
                deadend = true;
            elseif ((isnan (new (1, 1))) || (isnan (new (1, 2))))
                % NaN indices
                deadend = true;
            elseif (tempfill (new (1, 1), new (1, 2)) ~= 0)
                % already filled
                deadend = true;
            elseif ((new (1, 1) == pos{b, 2}(1, 1)) && (new (1, 2) == pos{b, 2}(1, 2)))
                % path completion
                deadend = true;
                
                % fill new cell
                tempfill (new (1, 1), new (1, 2)) = b;
                
                % note connectedness
                connected = true;
            end
            
            % update or exit
            if (deadend)
                % if a dead end is found
                excon = true;
                
                if (connected)
                    count = count + 1;
                end
            else
                % update co-ordinates
                old = new;
            end
        end
    end
    
    % add in the filled sample
    filledsamples{a} = tempfill;
    
    % connected fitness
    cfitness (1, a) = count / col;
end

% assign variables back to workspace
assignin ('caller', 'cfitness', cfitness);
assignin ('caller', 'filledsamples', filledsamples);

end

% -------------------------------------------------------------------------

function [] = filled (filledsamples, dim, sam)

% function FILL fills in the samples with the flowing colours

% VARIABLE ------ CLASS -- SIZE --- DESCRIPTION
% filledsamples - cell --- (1, n) ---- filled samples under consideration
% dim ----------- double - (1, 2) ---- dimensions of the board
% sam ----------- double - (1, 1) ---- number of samples

% GET THE FITNESS VALUE

% pre-allocation for speed
ffitness = zeros;

% count filled cells
for a = 1:sam
    % temporary variable to count filled in cells
    count = 0;
    
    for x = 1:dim (1, 1)
        for y = 1:dim (1, 2)
            if (filledsamples{a}(x, y) ~= 0)
                % if it is filled
                count = count + 1;
            end
        end
    end
    
    % get the fitness
    ffitness (1, a) = count / (dim (1, 1) * dim (1, 2));
end

% assign variables back to workspace
assignin ('caller', 'ffitness', ffitness);

end

% -------------------------------------------------------------------------

function [] = remove (samples, cfitness, ffitness, tfitness, sample)

% function REMOVE removes the least fitness samples

% VARIABLE - CLASS -- SIZE --- DESCRIPTION
% samples -- cell --- (1, n) - samples under consideration
% cfitness ----- double - (1, n) - connected fitness of the samples
% ffitness ----- double - (1, n) - filled fitness of the samples
% tfitness ----- double - (1, n) - total fitness of the samples
% sample --- double - (1, 1) - original number of samples

% size of the samples
currentsize = size (samples, 2);

while (currentsize > sample)
    % REMOVE THE LEAST fitness
    
    % FIND THE INDICES OF THE LEAST fitness
    
    % total fitness
    indtfitness = min (tfitness) == tfitness;
    
    if (sum (indtfitness, 2) == 1)
        % IF ONLY ONE SAMPLE IS FOUND, REMOVE THE SAMPLE
        
        % temporary variable to store valid samples
        tempsamples = cell (1);
        
        % temporary variables to store fitnesses
        tempt = zeros;
        tempf = zeros;
        tempc = zeros;
        
        % index variable
        tempind = 1;
        
        % search and remove
        for a = 1:currentsize
            if (~(indtfitness (a)))
                % if it is not the least, store it
                tempsamples{tempind} = samples{a};
                
                % store fitnesses
                tempt (1, tempind) = tfitness (1, a);
                tempf (1, tempind) = ffitness (1, a);
                tempc (1, tempind) = cfitness (1, a);
                
                % update the index
                tempind = tempind + 1;
            end
        end
        
        % save after removing
        samples = tempsamples;
        tfitness = tempt;
        ffitness = tempf;
        cfitness = tempc;
    else
        % IF MULTIPLES SAMPLES ARE FOUND, COMPOUND WITH CONNECTED FITNESS
        
        % pre-allocation for speed
        tcfitness = zeros;
        for a = 1:currentsize
            if (indtfitness (a) == 0)
                tcfitness (a) = NaN;
            else
                tcfitness (a) = cfitness (a) / indtfitness (a);
            end
        end
        
        % connected fitness
        indtcfitness = min (tcfitness) == tcfitness;
        
        if (sum (indtcfitness, 2) == 1)
            % REMOVE THE SAMPLE
            
            % temporary variable to store valid samples
            tempsamples = cell (1);
            
            % temporary variables to store fitnesses
            tempt = zeros;
            tempf = zeros;
            tempc = zeros;
            
            % index variable
            tempind = 1;
            
            % search and remove
            for a = 1:currentsize
                if (~(indtcfitness (a)))
                    % if it is not the least, store it
                    tempsamples{tempind} = samples{a};
                    
                    % store fitnesses
                    tempt (1, tempind) = tfitness (1, a);
                    tempf (1, tempind) = ffitness (1, a);
                    tempc (1, tempind) = cfitness (1, a);
                    
                    % update the index
                    tempind = tempind + 1;
                end
            end
            
            % save after removing
            samples = tempsamples;
            tfitness = tempt;
            ffitness = tempf;
            cfitness = tempc;
        elseif (sum (indtcfitness, 2) == 0)
            % IF NO SAMPLE IS FOUND, CHECK WITH FILLED FITNESS
            
            % pre-allocation for speed
            tffitness = zeros;
            for a = 1:currentsize
                if (indtfitness (a) == 0)
                    tffitness (a) = NaN;
                else
                    tffitness (a) = ffitness (a) / indtfitness (a);
                end
            end
            
            % connected fitness
            indtffitness = min (tffitness) == tffitness;
            
            if (sum (indtffitness, 2) == 1)
                % IF ONE SAMPLE IS FOUND, NOREMOVE THE SAMPLE
                
                % temporary variable to store valid samples
                tempsamples = cell (1);
                
                % temporary variables to store fitnesses
                tempt = zeros;
                tempf = zeros;
                tempc = zeros;
                
                % index variable
                tempind = 1;
                
                % search and remove
                for a = 1:currentsize
                    if (~(indtffitness (a)))
                        % if it is not the least, store it
                        tempsamples{tempind} = samples{a};
                        
                        % store fitnesses
                        tempt (1, tempind) = tfitness (1, a);
                        tempf (1, tempind) = ffitness (1, a);
                        tempc (1, tempind) = cfitness (1, a);
                        
                        % update the index
                        tempind = tempind + 1;
                    end
                end
                
                % save after removing
                samples = tempsamples;
                tfitness = tempt;
                ffitness = tempf;
                cfitness = tempc;
            else
                % IF MULTIPLES SAMPLES ARE FOUND, REMOVE A RANDOM SAMPLE
                
                % index to remove
                ind = randi (sum (indtffitness, 2));
                
                % temporary variable to store valid samples
                tempsamples = cell (1);
                
                % temporary variables to store fitnesses
                tempt = zeros;
                tempf = zeros;
                tempc = zeros;
                
                % index variables
                tempind = 1;
                over = 0;
                
                % search and remove
                for a = 1:currentsize
                    % count the minima
                    if (indtffitness (a) == 1)
                        over = over + 1;
                    end
                    
                    % allow the right samples
                    if (over ~= ind)
                        % if it is not the least, store it
                        tempsamples{tempind} = samples{a};
                        
                        % store fitnesses
                        tempt (1, tempind) = tfitness (1, a);
                        tempf (1, tempind) = ffitness (1, a);
                        tempc (1, tempind) = cfitness (1, a);
                        
                        % update the index
                        tempind = tempind + 1;
                    end
                end
                
                % save after removing
                samples = tempsamples;
                tfitness = tempt;
                ffitness = tempf;
                cfitness = tempc;
            end
        else
            % IF MULTIPLE SAMPLES ARE FOUND, COMPUND WITH FILLED FITNESS
            
            % pre-allocation for speed
            tcffitness = zeros;
            for a = 1:currentsize
                if (indtcfitness (a) == 0)
                    tcffitness (a) = NaN;
                else
                    tcffitness (a) = ffitness (a) / indtcfitness (a);
                end
            end
            
            % get the fitness
            indtcffitness = min (tcffitness) == tcffitness;
            
            if (sum (indtcffitness, 2) == 1)
                % IF ONLY ONE SAMPLE IS FOUND, REMOVE THAT
                
                % temporary variable to store valid samples
                tempsamples = cell (1);
                
                % temporary variables to store fitnesses
                tempt = zeros;
                tempf = zeros;
                tempc = zeros;
                
                % index variable
                tempind = 1;
                
                % search and remove
                for a = 1:currentsize
                    if (~(indtcffitness (a)))
                        % if it is not the least, store it
                        tempsamples{tempind} = samples{a};
                        
                        % store fitnesses
                        tempt (1, tempind) = tfitness (1, a);
                        tempf (1, tempind) = ffitness (1, a);
                        tempc (1, tempind) = cfitness (1, a);
                        
                        % update the index
                        tempind = tempind + 1;
                    end
                end
                
                % save after removing
                samples = tempsamples;
                tfitness = tempt;
                ffitness = tempf;
                cfitness = tempc;
            else
                % IF MULTIPLE SAMPLES ARE FOUND, REMOVE A RANDOM SAMPLES
                
                % index to remove
                ind = randi (sum (indtcffitness, 2));
                
                % temporary variable to store valid samples
                tempsamples = cell (1);
                
                % temporary variables to store fitnesses
                tempt = zeros;
                tempf = zeros;
                tempc = zeros;
                
                % index variables
                tempind = 1;
                over = 0;
                
                % search and remove
                for a = 1:currentsize
                    % count the minima
                    if (indtcffitness (a) == 1)
                        over = over + 1;
                    end
                    
                    % allow the right samples
                    if (over ~= ind)
                        % if it is not the least, store it
                        tempsamples{tempind} = samples{a};
                        
                        % store fitnesses
                        tempt (1, tempind) = tfitness (1, a);
                        tempf (1, tempind) = ffitness (1, a);
                        tempc (1, tempind) = cfitness (1, a);
                        
                        % update the index
                        tempind = tempind + 1;
                    end
                end
                
                % save after removing
                samples = tempsamples;
                tfitness = tempt;
                ffitness = tempf;
                cfitness = tempc;
            end
        end
    end
    
    % update looping index
    currentsize = size (samples, 2);
end

% assign varialbles back to workspace
assignin ('caller', 'samples', samples);

end

% -------------------------------------------------------------------------

function [] = mate (samples, sam, mutation, dim)

% function MATE generates new samples out of the surviving samples

% VARIABLE -- CLASS -- SIZE --- DESCRIPTION
% samples -- cell --- (1, n) - samples under consideration
% sam ------ double - (1, 1) - final number of samples after generation
% mutation - double - (1, 2) - determine the rate of mutation
% dim ------ double - (1, 2) - dimensions of the board

% GENERATION OF SAMPLES

% pre-allocation of variable to save children
children = cell (1);

% index for the children
ind = 1;

% current size
currentsize = size (samples, 2);

% begin
while (currentsize < sam)
    % choose the parent
    parent = samples{randi (size (samples, 2))};
    
    % GENERATE A CHILD
    
    % pre-allocation for speed
    child = zeros;
    for a = 1:dim (1, 1)
        for b = 1:dim (1, 2)
            if (isnan (parent (a, b)))
                child (a, b) = NaN;
            else
                % temporary mutation check
                check = randi (mutation (1, 2));
                
                % if within limits
                if (check <= mutation (1, 1))
                    child (a, b) = randi (4);
                else
                    child (a, b) = parent (a, b);
                end
            end
        end
    end
    
    % save the new sample
    children {ind} = child;
    ind = ind + 1;
    
    % update looping index
    currentsize = size (samples, 2) + size (children, 2);
end

% addition of children
for a = 1:size (children, 2)
    samples{end + 1} = children{a};
end

% assign variables back to workspace
assignin ('caller', 'samples', samples);
end