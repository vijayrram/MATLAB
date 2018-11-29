function [solution] = generate (set, sums, length)

% function EVOLVE solves the following problem using a genetic algorithm:

% Given a set consisting of positive integers (must include 1), form a
% sequence of integers, from the set of given length, that sum up to the
% given sum.

% VARIABLE NAME - CLASS -- SIZE --- DESCRIPTION
% set ----------- uint --- (1, n) - the set of acceptable integers
% sums ---------- uint --- (1, 1) - the sum to be achieved
% length -------- uint --- (1, 1) - the length of the sequence 

%  ERRORS IN INPUTS

% if the set is an empty set
if (numel (set) == 0)
    error ('EmptySet: The given set is an empty set.');
end

% if the set is not of the correct dimensions
if (size (set, 1) ~= 1)
    error ('IncorrectSize: The dimensions of the given set are wrong.');
end

% if the set does not contain only integers
for a = 1:numel (set)
    if (~((set(a) > 0) && (set (a) == round (set (a)))))
        error ('NotInteger: The given set contains non-integral elements or non-positive integers.');
    end
end

% if the set does not contain 1.
if (~(find (1 == set)))
    error ('NoUnitError: The given set does not contain 1.');
end 

% EVALUATE THE LEAST LENGTH POSSIBLE
% temporary variable for keeping track of the length
temp_length = 0;
% temporary variable for keeping track of the sum
temp_sums = 0;
% temporary variable for storing the sorted set
temp_set = sort (set);
% temporary variable to keep track of indices
temp_index = numel (temp_set);
% evaluation
while (sums ~= temp_sums)
    % selection of the best possible number for least length of sequence
    temp_num = temp_set (temp_index);
    
    % validation of the chosen number (true = valid)
    if (temp_sums + temp_num <= sums)
        % updation of the temporary sum
        temp_sums = temp_sums + temp_num;
        
        % updation of the temporary length
        temp_length = temp_length + 1;
    else
        % change the temporary index
        temp_index = temp_index - 1;
    end
    
    % validation of the temporary index (true = invalid)
    if (temp_index <= 0)
        error ('NoSolution: The given conditions do not have any valid solution.');
    end
    
    % validation of the temporary length (true = invalid)
    if (temp_length > length)
        error ('NoSolution: The given conditions do not have any valid solution.');
    end
end

% if the solution cannot be achieved for the given inputs
if (length > sums)
    error ('NoSolution: The given conditions do not have any valid solution.');
end
disp (' ');

% APPLICABLE METHODS

% description of the possible methods to employ
disp ('The problem can be solved using the following algorithms:');
disp ('1. Genetic Algorithm           : Generate possible solutions and "evolve" them to satisfy the given length conditions.');
disp ('2. Random and Switch Algorithm : Generate a random sequence of the given length and switch out entries shifting toward a solution.');
disp ('3. Greedy Algorithm            : Move to an optimum solution from the extremum sequences using "greedy" steps.');
disp (' ');

disp ('Each method has its pros and cons.')
disp (' ');

disp ('The genetic algorithm takes longer time but generates multiple, not necessarily distinct, solutions simultaneously.')
disp ('The memory required and processing power required is the highest.');
disp (' ');

disp ('The random and switch algorithm generates only one solution but takes significantly less time than the genetic algorithm.');
disp ('The memory required and the processing power required is the least.');
disp (' ');

disp ('The greedy algorithm generates a unique solution for any given problem but takes the least amount of time.');
disp ('Either memory is required or the input is altered. And, the processing power required is moderate.');
disp ('Also, it will definitely identify if there are no solutions, unlike the other algorithms.');
disp (' ');

disp ('All the solutions are sorted, but only the Greedy algorithm needs to sort the solution.')
disp (' ');

% collection of the input for the method to use
method = input ('Enter the serial number of the method you choose to use: ');
disp (' ');
switch (method)
    case 1
        % GENETIC ALGORITHM
        
        % get starting size of the sample population
        start_size = input ('N: The starting size of the population. Input, N / 3 = ');
        start_size = ceil (start_size * 3);
        
        % display chosen starting size
        fprintf ('The starting size of the population is %d.', start_size);
        disp (' ');
        disp (' ');
        
        % CREATION OF VALID SOLUTIONS AND CALCULATION OF FITNESS (to be minimised)
        
        % preallocation for speed
        fitness = zeros;
        sample = cell (1);
        % loop till required
        for a = 1:start_size
            % temporary variable to check for matching with the sum
            temp = 0;
            % initialisation for the sequence of valid integers
            sequence = zeros (1);
            while temp < sums
                % generate random number from the set
                b = set (randi (numel (set), 1));
                
                % check for validity for adding to the sequence (true = valid)
                if (temp + b <= sums)
                    % length of the current sequence
                    last = numel (sequence);
                    
                    % add the new term to the sequence
                    sequence (1, last + 1) = b;
                    
                    % update the temporary variable
                    temp = temp + b;
                end
            end
            % remove starting zero
            sequence (:, 1) = [];
            
            % save the generated sequences
            sample{a} = sequence;
            
            % CALCULATE THE FITNESS
            
            % difference in the length of the sequence to the one desired
            fitness (1, a) = abs (numel(sequence) - length);
            % length of the sequence minus required length
            fitness (2, a) = numel(sequence) - length;
        end
        
        
        % APPLICATION OF THE GENETIC ALGORITHM
        
        % exit condition
        excon = 0;
        % loop till exit condition is matched
        while (~excon)
            % SORTING OF THE SAMPLE ACCORDING TO FITNESS (absolute difference).
            
            % BUBBLE SORT (ascending order)
            % variable for the number of elements
            N = size (fitness, 2);
            for a = 1:N
                for b = (a + 1):N
                    if (fitness (1, a) > fitness (1, b))
                        % sorting fitness
                        temp = fitness (:, a);
                        fitness (:, a) = fitness (:, b);
                        fitness (:, b) = temp;
                        
                        % sorting sample set
                        temp = sample{a};
                        sample{a} = sample{b};
                        sample{b} = temp;
                    end
                end
            end
            disp (' ');
            
            % REMOVAL OF UNFIT INDIVIDUALS
            
            % preallocation of temporary variables for speed
            temp_fit = zeros (2, 1);
            temp_sample = cell (1);
            for a = 1:ceil (N / 3)
                temp_fit (:, a) = fitness (:, a);
                temp_sample{a} = sample{a};
            end
            fitness = temp_fit;
            sample = temp_sample;
            
            % sample fitness (global)
            sample_fit = [sum(fitness (1, :)); sum(fitness (2, :))];
            
            % EVALUATE EXIT CONDITION (true = exit)
            if (sample_fit (1, 1) == 0)
                excon = 1;
                
                % SAVE THE SOLUTION
                
                % preallocation for speed
                solution = zeros (1, length);
                
                % loop till saved
                for a = 1:numel (sample);
                    solution (a, :) = sort (sample{a});
                end
            end
            
            % continuation upon not satisfying the exit condition
            if (~excon)
                % REPRODUCTION BETWEEN THE SURVIVING SEQUENCES
                
                % initialise variable for the progeny
                progeny = cell (1);
                while ((numel (progeny) + numel (sample)) < (start_size + 1))
                    % choose the random parent sequences
                    parents = {cell2mat(sample (randi (numel (sample), 1))),...
                        cell2mat(sample (randi (numel (sample), 1)))};
                    
                    % choose the crossover point
                    crossover = [randi([0, numel(parents{1})], 1), randi([0, numel(parents{2})], 1)];
                    
                    % perform the crossover
                    children = {[parents{1}(1:crossover (1)), parents{2}((crossover (2) + 1):end)],...
                        [parents{2}(1:crossover (2)), parents{1}((crossover (1) + 1):end)]};
                    
                    % mutation of the children till the survive (match the conditions)
                    for a = 1:numel (children)
                        if (sum (children{a}) < sums)
                            % additive mutation is beneficial
                            while (sum (children{a}) < sums)
                                % generate random number from the set
                                b = set (randi (numel (set), 1));
                                
                                % check for validity for adding to the sequence (true = valid)
                                if ((sum (children{a}) + b) <= sums)
                                    % length of the current sequence
                                    last = numel (children{a});
                                    
                                    % add the new term to the sequence
                                    children{a}(1, last + 1) = b;
                                end
                            end
                        elseif (sum (children{a}) > sums)
                            % subtractive mutation is beneficial
                            while (sum (children{a}) > sums)
                                % remove a random number
                                children{a}(:, randi(numel (children{a}))) = [];
                            end
                            
                            % correct overshooting by adding numbers
                            while (sum (children{a}) < sums)
                                % generate random number from the set
                                b = set (randi (numel (set), 1));
                                
                                % check for validity for adding to the sequence (true = valid)
                                if ((sum (children{a}) + b) <= sums)
                                    % length of the current sequence
                                    last = numel (children{a});
                                    
                                    % add the new term to the sequence
                                    children{a}(1, last + 1) = b;
                                end
                            end
                        end
                    end
                    
                    % ADDITION OF THE MUTATED CHILDREN TO THE LIST OF PROGENY
                    
                    % number of current progeny
                    last = numel (progeny);
                    
                    % loop through for all children
                    for a = 1:numel (children)
                        % addition of children
                        progeny{last + 1} = children{a};
                        
                        % number of current progeny
                        last = numel (progeny);
                    end
                end
                
                % ADD THE PROGENY TO THE CURRENT SAMPLE SET
                
                % number of current progeny
                last = numel (sample);
                
                % loop through for all surviving progeny
                for a = 2:numel (progeny)
                    % addition of children
                    sample{last + 1} = progeny{a};
                    
                    % number of current progeny
                    last = numel (sample);
                end
                
                % CALCULATE THE FITNESS
                
                % difference in the length of the sequence to the one desired
                for a = 1:numel (sample)
                    % difference in the length of the sequence to the one desired
                    fitness (1, a) = abs (numel(sample{a}) - length);
                    % length of the sequence minus required length
                    fitness (2, a) = numel(sample{a}) - length;
                end
            end
        end
    case 2
        % RANDOM and SWITCH ALGORITHM
        
        % GENERATE A RANDOM SEQUENCE
        % preallocation for speed
        sequence = zeros;
        % loop till required
        for a = 1:length
            sequence (a) = set (randi (numel (set), 1));
        end
        
        % calculate the fitness of the sequence
        fitness = sum (sequence) - sums;
        
        % APPLICATION OF THE SWITCH (if necessary)
        while (fitness ~= 0)
            % check for the direction the fitness needs to improve
            if (fitness > 0)
                % generate a random number
                random = set (randi (numel (set), 1));
                
                % choose an entry to switch
                index = randi (numel (sequence), 1);
                
                % make the switch if fitness improves (true = improves)
                if ((fitness + random - sequence (index)) < fitness)
                    sequence (index) = random;
                end
            else
                % generate a random number
                random = set (randi (numel (set), 1));
                
                % choose an entry to switch
                index = randi (numel (sequence), 1);
                
                % make the switch if fitness improves (true = improves)
                if ((fitness + random - sequence (index)) > fitness)
                    sequence (index) = random;
                end
            end
            
            % calculate the fitness of the sequence
            fitness = sum (sequence) - sums;
        end
        
        % save the solution
        solution = sort (sequence);
    case 3
        % GREEDY ALGORITHM
        
        % sort the given set
        set = sort (set);
        
        % initialise the extremum sequence
        sequence = min (set) * ones (1, length);
        
        % calculate fitness
        fitness = sum (sequence) - sums;
        
        % APPLICATION OF THE GREEDY ALGORITHM (if necessary)
        
        % index to track the choice element from the set
        index_set = numel (set);
        
        % index to track the choice element from the sequence
        index_seq = numel (sequence);
        
        % repeat the greedy step till desired
        while (fitness < 0)
            % exit for incorrect indices
            if ((index_set <= 0) || (index_seq <= 0))
                error ('NoSolution: The given conditions do not have any valid solution.');
            end
            
            % validation of the direction of change in fitness (true = valid)
            if ((sum (sequence) - sequence (index_seq) + set (index_set)) <= sums)
                % switch out the element in the sequence
                sequence (index_seq) = set (index_set);
                
                % update the index of the sequence
                index_seq = index_seq - 1;
            else
                % update the index of the set
                index_set = index_set - 1;
            end
            
            % calculate fitness
            fitness = sum (sequence) - sums;
        end
        
        % save the solution
        solution = sort (sequence);
    otherwise
        % ERRANEOUS INPUT
        
        % display error message
        error ('InapplicableAlgorithmChoice: There is no algorithm for the input choice');
end

end