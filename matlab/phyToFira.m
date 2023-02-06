% A "main" entrypoint for converting Phy and .plx data Gold Lab FIRA.
%
% This combines various Numpy and other files from the Phy tool (spike
% sorting curation) with a Plexon raw ".plx" file and several optional
% arguments.  It produces a Gold Lab FIRA struct and saves this to a .mat
% file.
%
% Inputs:
%
% phyFile -- name of a Phy "params.py" file, should be in the same folder
%            as several other .npy and .tsv files from Phy
% plxFile -- name of the .plx file to be parsed
% spmFile -- path to the spm script to use for parsing -- the folder
%            containing this file will be added to the Matlab path.
% outDir -- folder to receive output .mat file that contains the FIRA
%           struct
%
% In addition to these positional arguments, several name-value
% pairs are allowed.  When provided, these will be passed on to the lab's
% "bFile" utility.
%
% spike_list -- Spike channel/unit/cluster ids to keep.  Default is 'all',
%               for all ids.  Clusters from Phy would be in range 0:999,
%               channels/units from Plexon would be 1000+.
% sig_list -- Plexon analog channel ids to keep.  Default is [] for none.
% keep_matCmds -- Whether to extract Matlab commands.  Default is false.
% keep_dio -- Whether to extract digital io words.  Default is false.
% flags -- Any flags to pass on to buildFIRA_init().  Default is 0.
% messageH -- Any messageH to pass on to buildFIRA_init().  Default is [].
% rawFlag -- Whether to leave FIRA in a raw data state (true) or to parse
%            data for each trial (false).  Default is false -- parse the
%            trials.
%
% Outputs:
%
% convertedFile -- path to the .mat file that contains the converted FIRA
%                  struct.
function convertedFile = phyToFira(phyFile, plxFile, spmFile, outDir, varargin)

arguments
    phyFile { mustBeFile }
    plxFile { mustBeFile }
    spmFile = '';
    outDir = pwd();
end

arguments (Repeating)
    varargin
end

parser = inputParser();
parser.CaseSensitive = true;
parser.KeepUnmatched = false;
parser.PartialMatching = false;
parser.StructExpand = true;

parser.addParameter('spike_list', 'all');
parser.addParameter('sig_list', []);
parser.addParameter('keep_matCmds', 0);
parser.addParameter('keep_dio', 1);
parser.addParameter('flags', 0);
parser.addParameter('messageH', []);
parser.addParameter('rawFlag', false);

parser.parse(varargin{:});

start = datetime('now', 'Format', 'uuuuMMdd''T''HHmmss');
fprintf('phyToFira Start at: %s\n', char(start));

fprintf('phyToFira Converting Phy file: %s\n', phyFile);
fprintf('phyToFira Converting .plx file: %s\n', plxFile);

fprintf('phyToFira Using spmFile: %s\n', spmFile);
[spmDir, spmName] = fileparts(spmFile);
if isfolder(spmDir)
    fprintf('phyToFira Adding spm dir to path: %s\n', spmDir);
    addpath(spmDir)
end

if ~isfolder(outDir)
    mkdir(outDir);
end

[~, plxFileBase] = fileparts(plxFile);
convertedFile = fullfile(outDir, [plxFileBase '.mat']);
fprintf('phyToFira Writing converted file to: %s\n', convertedFile);


%% bFile does the conversion.

fprintf('phyToFira Building FIRA with bFile ...\n');
bFile({plxFile, phyFile}, ...
    [], ...
    spmName, ...
    convertedFile, ...
    parser.Results.spike_list, ...
    parser.Results.sig_list, ...
    parser.Results.keep_matCmds, ...
    parser.Results.keep_dio, ...
    parser.Results.flags, ...
    parser.Results.messageH, ...
    parser.Results.rawFlag);
fprintf('phyToFira Done building FIRA.\n');

finish = datetime('now', 'Format', 'uuuuMMdd''T''HHmmss');
duration = finish - start;
fprintf('plxToKilosort Finish at: %s (%s elapsed)\n', char(finish), char(duration));
