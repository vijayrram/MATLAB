function [] = mastermindthink ()

% function MASTERMIND game of mastermind with 4 digits and 15 tries

clc;

% number of digits
n = 4;

% clear extra inputs
clear varargin;

% round-up n to the nearest integer
n = ceil (n);

% choose the maximum number of tries
maxtries = 15;

% choose the random number
num = randi (power(10, n), 1);

% set win to false
win = false;

% create array of the chosen number for comparing with guesses
temp = num;
numarr = zeros;
for x = 1:n
    numarr (n - x + 1) = mod (temp, 10);
    temp = floor (temp / 10);
end

% start playing
for tries = 1:maxtries
    % exit if the player wins
    if (win)
        break;
    end
    
    if (tries ~= 1)
        disp (' ');
    end
    disp (' ');
    % input guess
    guess = input (sprintf ('Enter guess %d of %d: ', tries, maxtries));
    
    % create array of the guess for comparing with the chosen number
    temp = guess;
    guessarr = zeros;
    for a = 1:n
        guessarr (n - a + 1) = mod (temp, 10);
        temp = floor (temp / 10);
    end
    
    % start comparing
    
    % no. of bulls found
    nbulls = 0;
    
    % array to store the position of found bulls
    bullarr = zeros;
    
    % search for bulls
    % temp. var. for nbulls
    b = 1;
    for x = 1:n
        % if a bull is found
        if (numarr (x) == guessarr (x))
            % add to the number of bulls found
            nbulls = nbulls + 1;
            
            % store the position of the bull
            bullarr (b) = x;
            
            % increase the array index
            b = b + 1;
        end
    end
    
    % no. of cows found
    ncows = 0;
    
    % array to store the position of found cows
    cowarr = zeros;
    
    % search for cows
    % temp. var. for ncows
    b = 1;
    
    % run through the guessarr
    for x = 1:n
        % go through if there are no repeats
        repeat = false;
        
        % run through the numarr
        for y = 1:n
            % variable to avoid already checked digits
            checked = false;
            
            if (~repeat)
                % exit if the current num digit is a bull
                for z = 1:numel (bullarr)
                    if (y == bullarr (z))
                        checked = true;
                    end
                end
                
                % exit if the current guess digit is a bull
                for z = 1:numel (bullarr)
                    if (x == bullarr (z))
                        checked = true;
                    end
                end
                
                % exit if the current num digit is a cow
                for z = 1:numel (cowarr)
                    if ((y == cowarr (z)) && (~checked))
                        checked = true;
                    end
                end
                
                % if a cow is found
                if ((guessarr (x) == numarr (y)) && (~checked))
                    % add to the number of bulls found
                    ncows = ncows + 1;
                    
                    % store the position of the bull
                    cowarr (b) = y;
                    
                    % increase the array index
                    b = b + 1;
                    
                    % avoid multiple checks
                    break;
                end
            end
        end
    end
    
    % give hints
    if (nbulls == n)
        % display victory message
        disp (' ');
        fprintf ('Hey!  You won.  GG WP!');
        win = true;
    else
        % display the number of bulls
        disp (' ');
        fprintf ('The number of bulls is %d.', nbulls);
        
        % display the number of cows
        disp (' ');
        fprintf ('The number of cows is %d.', ncows);
    end
end

% if all tries are exhaused and the number is not found
if (~win)
    % display failure message
    disp (' ');
    disp (' ');
    fprintf ('Hey! I won.  Better luck next time.');
    
    % display the chosen number
    disp (' ');
    fprintf ('I had thought of the number %d.', num);
end

disp (' ');
disp (' ');
end