%% Child_Rhyme preprocessing

%{ This is the script for preprocessing eeg data for the child EEG rhyme
%project in the Language, Environment and NeuroDevelopment (LEND) Lab at
%Louisiana State University.
%}

% Author: Will Decker
% Date: January 30, 2024
% Updates:

%% Dirs and locations

% user account
USER = char(getenv('USER'));

if ~strcmp(USER, 'lendlab')
    USER = 'lendlab';
end

% directory vars as chars
lendserv = strcat('/Volumes/', USER, '/');
projectdir = strcat(lendserv, 'projects/Child_Rhyme/');
scriptsdir = strcat(projectdir, 'analysis/scripts/EEG-Rhyme-Scripts/');
rawdir = strcat(projectdir, 'data/eeg/');
workdir = strcat(projectdir, 'analysis/workdir');
txtdir = strcat(projectdir, 'analysis/txtdir');
erpdir = strcat(projectdir,'analysis/erpdir');

% dir object
eegdirs = struct(...
    'lendserv', {dir(fullfile(lendserv))}, ...
    'projectdir', {dir(fullfile(projectdir))}, ...
    'scriptsdir', {dir(fullfile(scriptsdir))}, ...
    'rawdir', {dir(fullfile(rawdir))},...
    'workdir', {dir(fullfile(workdir))}, ...
    'txtdir', {dir(fullfile(txtdir))}, ...
    'erpdir', {dir(fullfile(erpdir))});

%% Enter necessary dir

cd(char({eegdirs.scriptsdir(1).folder}.'))





