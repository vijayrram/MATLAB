function [out] = square(in)

% function SQUARE (in) squares the input (array representation of a number)

% VARIABLE NAME - CLASS -- SIZE --- DESCRIPTION
% in ------------ double - (1, n) - array representation of the number to
%                                   be squared

% CHECK FOR ERRORS

% class discrepancies
if (~(isnumeric (in)))
    error ('IncorrectClass: Input variable is not of the correct class.');
end

% representation discrepancies
if ((in ~= round (in)) || (0 > in))
    error ('NotWhole: Input is not a whole number.');
end

% SPLITTING OF THE DIGITS

% temporary variable to store
temp = in;

% index variable
a = 1;
while (temp > 0)
    in (a) = mod (temp, 10);
    temp = floor (temp / 10);
    a = a + 1;
end

% flip
in = fliplr (in);

% CALCULATION OF THE DUPLEX

% preallocation for speed
duplex = zeros (1, 2 * size (in, 2) - 1);
for a = 1:(2 * size (in, 2) - 1)
    if (a <= size (in, 2))
        % input for the duplex function
        d_in = in (1, 1:a);
        
        % split even and odd inputs. EVEN = TRUE
        if (~(mod (size (d_in, 2), 2)))
            % temporary variable to keep track of the partial sums
            temp = 0;
             
            % calculation of the partial duplex
            for b = 1:(size (d_in, 2) / 2)
                temp = d_in (b) * d_in (end - b + 1);
            end
            duplex (1, a) = temp * 2;
        else
            % temporary variable to keep track of the partial sums
            temp = 0;
            
            % calculation of the partial duplex
            for b = 1:floor (size (d_in, 2) / 2)
                temp = d_in (b) * d_in (end - b + 1);
            end
            duplex (1, a) = temp * 2 + d_in (floor (size (d_in, 2) / 2) + 1) ^ 2;
        end
    else
        % input for the duplex function
        d_in = in ((a - size (in, 2) + 1):end);
        
        % split even and odd inputs. EVEN = TRUE
        if (~(mod (size (d_in, 2), 2)))
            % temporary variable to keep track of the partial sums
            temp = 0;
             
            % calculation of the partial duplex
            for b = 1:(size (d_in, 2) / 2)
                temp = d_in (b) * d_in (end - b + 1);
            end
            duplex (1, a) = temp * 2;
        else
            % temporary variable to keep track of the partial sums
            temp = 0;
            
            % calculation of the partial duplex
            for b = 1:floor (size (d_in, 2) / 2)
                temp = d_in (b) * d_in (end - b + 1);
            end
            duplex (1, a) = temp * 2 + d_in (floor (size (d_in, 2) / 2) + 1) ^ 2;
        end
    end
end

% CALCULATION OF THE SQUARE

% create buffer cell
duplex = [0, duplex];

% carry over
for a = 2:size (duplex, 2)
    A = size (duplex, 2) - a + 2;
    if (duplex (A) > 9)
        % temporary variable to track overflow
        temp = duplex (A);
        duplex (A) = mod (duplex (A), 10);
        duplex (A - 1) = duplex (A - 1) + floor (temp / 10);
    end
end

% REMOVE LEADING ZEROS

% % temporary variable to track exit condition
% excon = false;
while (1)
    if (duplex (1) ~= 0)
        break;
    else
        duplex (1) = [];
    end
end

out = duplex;

end