% Script M-file: biowulf_test.m
% Brute force calculation of the fourth power of a random symmetric matrix. 
% 
% For biowulf testing.
% Tue Feb 22 10:46:17 EST 2005

% Matrix size.
n = 7750;          % 580 s on p2800/4G
n = 8000;          % 630 s on p2800/4G
A = zeros(n);

% Initialize the random number generator.
rand('state', 0);

fprintf(1, 'Generating the random matrix of size %d ...', n);

% All entries unifomly distributed on interval [-1, 1]. Zeroes along the
% diagonal.
for i = 1:n
	for j = i + 1:n
		tmp = 2 * rand - 1;
		A(i, j) = tmp;
		A(j, i) = tmp;
	end
end

fprintf(1, ' Done.\n');

%
fprintf(1, 'Raising to the fourth power .................');
A = A * A * A * A;
fprintf(1, ' Done.\n');
%
