%% Child_Rhyme preprocessing

%{ This is the script for preprocessing eeg data for the child EEG rhyme
%project in the Language, Environment and NeuroDevelopment (LEND) Lab at
%Louisiana State University.
%}

% Author: Will Decker
% Date: January 30, 2024
% Updates:
    % 02/01/24: Will Decker finished initial version of script

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

%% Establish some constants and variables

% filter and epoch params

lowpass = 30; % in Hz
highpass = 0.1; % in Hz
EPOCH_BASELINE = -500.0; % epoch baseline
EPOCH_END = 1000.0; % epoch offset

% establish subject list

[d,s,r] = xlsread([txtdir '/subjects.xlsx']);
subject_list = r;
numsubjects = (length(s));

%% Start EEGLAB

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
eeglab nogui

%% Filter, reref and remove empty time blocks

% which subjects to run?

sub_start = 1; % start with first subject
sub_end = r{end}; % end with the last subject

% iter through subjects

for s = sub_start:sub_end

    subject = subject_list{s};

    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    eeglab('redraw');

    EEG = pop_loadbv(rawdir, [subject '.vhdr'], [], []);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',subject,'gui','off'); 
    EEG = eeg_checkset( EEG );

    EEG = pop_eegfilt ( EEG, highpass, lowpass, [], [0], 0, 0, 'fir1', 0);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_fl'],'gui','off'); 
    EEG = eeg_checkset( EEG );

    EEG = pop_reref ( EEG, []);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_fl_rr'],'gui','off'); 
    EEG = eeg_checkset( EEG );

    EEG = erplab_deleteTimeSegments(EEG, 0, 3000, 3000); %preserves data 3000ms before and after any event code, all other data is removed.

    EEG = pop_saveset( EEG, [subject '_fl_rr'], workdir);
end

%% Interpolate bad electrodes

% This step is done manually

%% Idependent Component Analysis (ICA)

% which subjects to run?

sub_start = 1; % start with first subject
sub_end = r{end}; % end with the last subject

for s = sub_start:sub_end 

    subject = subject_list{s};

    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    eeglab('redraw');

    EEG = pop_loadset ([subject '_clean.set'],workdir); % ensure that all files are properly named; the code will not work unless the files are named correctly
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    EEG = pop_saveset( EEG, [subject '_ICA'], workdir);

end

%% Removing bad ICA Components with MARA

% This step is done manually



