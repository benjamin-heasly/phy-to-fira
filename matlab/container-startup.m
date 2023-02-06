% Log what we have here for official Matlab stuff.
ver

% Get home folder on the path.
addpath('/home/matlab');

% Get plexon sdk on the path.
plexonSdkPath = '/home/matlab/Matlab-Offline-Files-SDK';
addpath(genpath(plexonSdkPath));

fprintf('Found Plexon SDK at %s\n', which('mexPlex'));

% Get npy-matlab toolbox on the path.
npyMatlabPath = '/home/matlab/npy-matlab';
addpath(genpath(npyMatlabPath));

fprintf('Found npy-matlab at %s\n', which('readNPY'));

% Get Gold Lab Matlab Utils on the path.
labMatlabUtilsPath = '/home/matlab/Lab_Matlab_Utilities';
addpath(genpath(labMatlabUtilsPath));

fprintf('Found Gold Lab Lab_Matlab_Utilities at %s\n', which('buildFIRA_init'));

% Get phy-to-fira (from this repo) on the path.
addpath('/home/matlab/phy-to-fira');

fprintf('Found phy-to-fira at %s\n', which('phyToFira'));
