%% Notes:
% Written by Jacob Momsen and Julie Schneider
% Dependencies: EEGlab, Fieldtrip, ERPLab, and the Statistics and Machine Learning Toolbox 
%% Initialize EEGlab %%
clear
eeglab;

%% startup FT
restoredefaultpath
addpath /Users/julie/Documents/MATLAB/eeglab2021.0/plugins/fieldtrip
ft_defaults

%% set up file and folders
% establish working directory 
ftfolder =  '/Volumes/lendlab/projects/EEG_Rhyme/analysis/derivatives/ft_output/';
bdffolder = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/txtdir/binlists/';
parentfolder = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir/epoch_bins/';

% establish parameters
date = 'May11';

% establish subject list
[d,s,r]=xlsread('subjects.xlsx');
subject_list = r;
numsubjects = (length(s));

 %% FT Preprocessing %%
 %% Event List Correction
for s=[26] %12 has some kind of error, 14 has no 513 data
    subject = subject_list{s};

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',[subject '_verb_ICAR_corrected.set'],'filepath',parentfolder);
    %EEG = pop_importevent( EEG, 'append','no','event',[parentfolder [subject '_verb'] filesep [subject '_Verb_ICAR_corrected.txt']],'fields',{'number','type','latency','urevent','duration'},'skipline',1,'timeunit',0.001,'align',0);
    EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' });
    EEG = pop_saveset( EEG, 'filename',[subject '_verb_ICAR_corrected.set'],'filepath',parentfolder);

end

%% Epoching for correct bins
for s=1:numsubjects %102519_1f has no 513 data 
    subject = subject_list{s};

    EEG = pop_loadset('filename',[subject '_verb_ICAR_corrected.set'],'filepath',parentfolder);
    EEG  = pop_binlister(EEG , 'BDF', [bdffolder 'binlist.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
    EEG = pop_epochbin( EEG , [-500 1000.0],  [ -500 0]);
    %EEG = pop_reref(EEG,[]); %Need to re-run without this rereference step
    EEG = eeg_checkset( EEG );
eeglab redraw

% when we're ready to do AR
EEG  = pop_artmwppth( EEG , 'Channel',  1:62, 'Flag',  1, 'Threshold',  100, 'Twindow', [ -500 998], 'Windowsize',  200, 'Windowstep',  100 ); % GUI: 15-Apr-2022 13:58:02
EEG = pop_rejepoch(EEG, EEG.reject.rejmanual);
EEG = pop_saveset( EEG, 'filename',[subject '_all_bins.set'],'filepath',ftfolder);
eeglab redraw
end