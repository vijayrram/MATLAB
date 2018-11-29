function [] = mastermindguess ()

clc;

% DEFINE VARIABLES

variables ();

% DISPLAY GAME-START MESSAGE

fprintf ('Let''s play a game of Mastermind.  Think of a %d-digit number (0 to %d).  I shall try to guess it within %d tries.', n, 10 ^ n - 1, maxtries);
disp (' ');
disp (' ');

% OBTAIN SAMPLESPACE

samplespace = sample(n);

% BEGIN

tries = 0;
over = false;

while ((tries < maxtries) && ~(over))
    % new try
    tries = tries + 1;
    
    if (tries == 5040)
        disp (' ');
    end
    
    % generate guess
    guesses(tries).guess = algorithm (2, samplespace, checked, isthere, guesses); %#ok<*AGROW>
    % NOTE: refer function for details about the first input parameter
    
    % display the guess
    fprintf ('Guess %d of %d: ', tries, maxtries);
    fprintf ('%d', guesses(tries).guess);
    disp (' ');
    
    % obtain hints
    guesses(tries).hints = input ('Enter the number of Cows and Bulls: [C, B] = ');
    disp (' ');
    
    if (guesses(tries).hints(1, 2) == n)
        % solution is found
        over = true;
        
        % display the solution
        fprintf ('The solution is found to be: ''');
        fprintf ('%d', guesses(end).guess);
        if (tries == 1)
            fprintf (''' in %d try.', tries);
        else
            fprintf (''' in %d tries.', tries);
        end
        disp (' ');
        disp (' ');
    else
        % reevaluate the samplespace
        samplespace = evaluate (2, samplespace, checked, isthere, guesses);
        % NOTE: refer function for details about the first input parameter
    end
    
end

end

% -------------------------------------------------------------------------

function [samplespace] = sample (n)

% range of possible values
temp = (0:(10 ^ n - 1))';

% get the digits
space = zeros (10 ^ n, n);
for a = 1:n
    space(:, n - a + 1) = mod (temp, 10);
    temp = floor (temp ./ 10);
end

% structuralise
samplespace(:).samples = space;
samplespace(:).valid = ones (10 ^ n, 1);

end

% -------------------------------------------------------------------------

function [] = variables ()

% number of digits
n = 4;

% checked digits
checked.no = 0:9;
checked.yes = [];

% isthere digits
isthere.no = [];
isthere.yes = [];

% guesses and hints
guesses.guess = [];
guesses.hints = [];

% maximum number of tries
maxtries = Inf;

% returning variables to the caller
assignin ('caller', 'n', n);
assignin ('caller', 'checked', checked);
assignin ('caller', 'isthere', isthere);
assignin ('caller', 'guesses', guesses);
assignin ('caller', 'maxtries', maxtries);

end

% -------------------------------------------------------------------------

function [guess] = algorithm (type, samplespace, checked, isthere, guesses) %#ok<*INUSD>

switch (type)
    case 1
        % algorithm selects guesses randomly from the list of samples
        
        if ~(sum (samplespace.valid, 1))
            error ('Obtaining Guess: Samplespace is Empty');
        end
        
        found = false;
        while ~(found)
            % select a random sample
            ind = randi (size (samplespace.samples, 1));
            
            % check for the validity of the sample
            if (samplespace.valid(ind, 1) && ~(found))
                guess = samplespace.samples(ind, :);
                found = true;
            end
        end
    case 2
        % algorithm selects guesses according to their levels of uniqueness
        
        found = false;
        uniqueness = 'singles';
        while ~(found)
            switch (uniqueness)
                case 'singles'
                    % all digits are unique
                    
                    % search through the samplespace
                    for ind = 1:size (samplespace.samples, 1)
                        % check if valid
                        if (samplespace.valid(ind, 1) && ~(found))
                            % check if the sample matches the uniquness
                            if (unique (samplespace.samples(ind, :), uniqueness))
                                guess = samplespace.samples(ind, :);
                                found = true;
                            end
                        end
                    end
                    
                    % change uniquness value if no guess is found
                    if ~(found)
                        uniqueness = 'duet';
                    end
                case 'duet'
                    % one pair of digits repeated, other two are unique
                    
                    % search through the samplespace
                    for ind = 1:size (samplespace.samples, 1)
                        % check if valid
                        if (samplespace.valid(ind, 1) && ~(found))
                            % check if the sample matches the uniquness
                            if (unique (samplespace.samples(ind, :), uniqueness))
                                guess = samplespace.samples(ind, :);
                                found = true;
                            end
                        end
                    end
                    
                    % change uniquness value if no guess is found
                    if ~(found)
                        uniqueness = 'duets';
                    end
                case 'duets'
                    % two pairs of digits repeated
                    
                    % search through the samplespace
                    for ind = 1:size (samplespace.samples, 1)
                        % check if valid
                        if (samplespace.valid(ind, 1) && ~(found))
                            % check if the sample matches the uniquness
                            if (unique (samplespace.samples(ind, :), uniqueness))
                                guess = samplespace.samples(ind, :);
                                found = true;
                            end
                        end
                    end
                    
                    % change uniquness value if no guess is found
                    if ~(found)
                        uniqueness = 'triplet';
                    end
                case 'triplet'
                    % three digits repeated, another different
                    
                    % search through the samplespace
                    for ind = 1:size (samplespace.samples, 1)
                        % check if valid
                        if (samplespace.valid(ind, 1) && ~(found))
                            % check if the sample matches the uniquness
                            if (unique (samplespace.samples(ind, :), uniqueness))
                                guess = samplespace.samples(ind, :);
                                found = true;
                            end
                        end
                    end
                    
                    % change uniquness value if no guess is found
                    if ~(found)
                        uniqueness = 'quad';
                    end
                case 'quad'
                    % all four digits repeated
                    
                    % search through the samplespace
                    for ind = 1:size (samplespace.samples, 1)
                        % check if valid
                        if (samplespace.valid(ind, 1) && ~(found))
                            % check if the sample matches the uniquness
                            if (unique (samplespace.samples(ind, :), uniqueness))
                                guess = samplespace.samples(ind, :);
                                found = true;
                            end
                        end
                    end
                    
                    % if no guess is found
                    if ~(found)
                        error ('Obtaining Guess: Samplespace is Empty');
                    end
            end
        end
    otherwise
        error ('Making Guess: Input type is incorrect');
end

end

% -------------------------------------------------------------------------

function [samplespace] = evaluate (type, samplespace, checked, isthere, guesses) %#ok<*INUSL>

switch (type)
    case 1
        % evaluation method removes only the incorrect guess
        
        % search for the guess in the samplespace
        for ind = 1:size (samplespace.samples, 1)
            % if found, remove it
            if (guesses(end).guess == samplespace.samples(ind, :))
                samplespace.valid(ind, 1) = 0;
            end
        end
    case 2
        % evaluation method removes all impossible samples based on the given hints
        
        % search for the guess in the samplespace
        for ind = 1:size (samplespace.samples, 1)
            % if found, remove it
            if (guesses(end).guess == samplespace.samples(ind, :))
                samplespace.valid(ind, 1) = 0;
            end
            
            % for only Cows, remove all samples with any matching positions
            if ~(guesses(end).hints(1, 2))
                if (samplespace.valid(ind, 1))
                    for indi = 1:size (samplespace.samples, 2)
                        if ((guesses(end).guess(1, indi) == samplespace.samples(ind, indi)))
                            samplespace.valid(ind, 1) = 0;
                        end
                    end
                end
            end
            
            % remove other impossible combinations
            if (samplespace.valid(ind, 1))
                matches = 0;
                matched.guess = [1, 1, 1, 1];
                matched.sample = [1, 1, 1, 1];
                for indi = 1:size (samplespace.samples, 2)
                    for indj = 1:size (guesses(end).guess, 2)
                        if ((guesses(end).guess(1, indj) == samplespace.samples(ind, indi)) && (matched.sample(1, indi)) && (matched.guess(1, indj)))
                            matches = matches + 1;
                            matched.sample(1, indi) = 0;
                            matched.guess(1, indj) = 0;
                        end
                    end
                end
                % if the number of matching digits do not match
                if (matches ~= sum (guesses(end).hints, 2))
                    samplespace.valid(ind, 1) = 0;
                end
            end
        end
    otherwise
        error ('Evaluating Samplespace: Input type is incorrect');
end

end

% -------------------------------------------------------------------------

function [valid] = unique (sample, uniqueness)

% calculate and tabulate values
table = zeros (size (sample, 2));
for indi = 1:size (sample, 2)
    for indj = 1:size (sample, 2)
        if (sample (1, indi) == sample (1, indj))
            table (indi, indj) = 1;
        else
            table (indi, indj) = 0;
        end
    end
end
sumval = sum (sum (table, 1), 2);

switch (uniqueness)
    case 'singles'
        % all digits are unique
        if (sumval == 4)
            valid = true;
        else
            valid = false;
        end
    case 'duet'
        % one pair of digits repeated, other two are unique
        if (sumval == 6)
            valid = true;
        else
            valid = false;
        end
    case 'duets'
        % two pairs of digits repeated
        if (sumval == 8)
            valid = true;
        else
            valid = false;
        end
    case 'triplet'
        % three digits repeated, another different
        if (sumval == 10)
            valid = true;
        else
            valid = false;
        end
    case 'quad'
        % all four digits repeated
        if (sumval == 16)
            valid = true;
        else
            valid = false;
        end
end

end