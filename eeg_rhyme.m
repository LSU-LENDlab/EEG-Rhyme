%% Notes
% when running by section over long periods of time, MATLAB may not save
% your variables. You may need to rerun the first section of code.

%% Enter directory

cd '/Volumes/lendlab/projects/EEG_Rhyme/analysis/matlab_scripts'


%%
%%set up file and folders: Run this every time you re-open matlab
% establish working directory 
rawdir = '/Volumes/lendlab/projects/EEG_Rhyme/data/rawdir'; %folder that houses the data from the rhyme tasks (exposure, post-test1 and post-test2)
workdir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir'; 
txtdir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/txtdir';
erpdir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir';


% establish parameters
 
lowpass = 30; % in Hz
highpass = 0.1; % in Hz
epoch_baseline = -500.0; %epoch baseline
epoch_end = 1000.0; %epoch offset

% establish subject list

[d,s,r] = xlsread ('subjects.xlsx'); % Type the name of the .xlsx file within the ''(quotes).
subject_list = r;
numsubjects = (length(s));


%% Preprocessing steps
% Step 1: load file, filter, referencing
for s=58:63 %change number of subjects as needed

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


%% Interpolating bad electrodes

% Step 2: Manually scroll through the data and interpolate bad
% channels/reject bad blocks. Save this as subject _clean.set in the
% working directory
% To scroll through data: EEGLAB >> Tools >> Plot >> Channel data (scroll) 
% To interpolate bad electrodes EEGLAB >> Tools >> Interpolate electrodes >> Select from data channels
        % Note: we are interpolating electrodes sepherically

%% ICA
%Step 3: Run ICA

for s=55:63 %change number of subjects as needed

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
% Load ICA file
% Tools > IC Artifact Classification (MARA) > MARA Classification
% Select 'Plot and select components for removal' > Ok
% Review bad components and select which to remove (only remove those with
    % artifact likelihood of 70%(0.70) or higher
% Record removed artifacts in participant database
% Tools > Remove components from data > Yes (Plot Single Trials)
% If plot single trials looks cleaner, click to 'Accept' the removal
% Save file as subjectID_ICA_clean.set

%% ERP Analysis

clear
eeglab;
% %%set up file and folders: Run this every time you re-open matlab
% % establish working directory 
% rawdir = '/Users/lendlab/Library/CloudStorage/Box-Box/LEND_Lab/projects/EEG_Rhyme/data/rawdir'; %folder that houses the data from the rhyme tasks (exposure, post-test1 and post-test2)
% workdir = '/Users/lendlab/Library/CloudStorage/Box-Box/LEND_Lab/projects/EEG_Rhyme/analysis/wkdir'; 
% txtdir = '/Users/lendlab/Library/CloudStorage/Box-Box/LEND_Lab/projects/EEG_Rhyme/analysis/txtdir';
% erpdir = '/Users/lendlab/Library/CloudStorage/Box-Box/LEND_Lab/projects/EEG_Rhyme/analysis/erpdir';
% 

% establish subject list
% When analyzing multiple subjects at once, change subject list to correct
% condition

%[d,s,r] = xlsread ('norhyme_subjects.xlsx');
[d,s,r] = xlsread ('rhyme_subjects.xlsx');
subject_list = r;
numsubjects = (length(s));

epoch_baseline = -500.0; %epoch baseline
epoch_end = 1000.0; %epoch offset
%condition = 'norhyme'; %rhyme or norhyme (NO SPACES), MAKE SURE TO CHANGE DEPENDING ON PARTICIPANT (see participant database)
condition = 'rhyme' ;

%%
for s=[7:63] %change number of subjects as needed
    
    subject = subject_list{s};

     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
     eeglab('redraw');

% Create eventlist, apply binlist, extract epochs, and artifact rejection
EEG = pop_loadset ([subject '_ICA_clean.set'], workdir);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );v

EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', [txtdir filesep [subject '.txt']] ); 
EEG = eeg_checkset( EEG );
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 

EEG  = pop_binlister( EEG , 'BDF', [txtdir filesep 'binlists/master_combined_binlist.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); % GUI: 10-Aug-2022 11:28:45
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
EEG = pop_epochbin( EEG , [epoch_baseline epoch_end],  'pre'); 
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

EEG = pop_exporteegeventlist( EEG , 'Filename', [txtdir filesep [subject '_bins.txt']] ); % GUI: 11-Aug-2022 13:27:29

EEG  = pop_artextval( EEG , 'Channel',  [], 'Flag',  1, 'Threshold', [ -75 75], 'Twindow', [epoch_baseline epoch_end] );
EEG  = pop_artmwppth( EEG , 'Channel',  [], 'Flag',  1, 'Threshold', 75, 'Twindow', [epoch_baseline epoch_end], 'Windowsize',  200, 'Windowstep',  100 ); 
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',[workdir filesep [subject '_epoch_ar.set']],'gui', 'off'); 

end

%% Epoch based on event codes (Rhyme)

% load subject list
[d,s,r] = xlsread ('norhyme_subjects.xlsx');
subject_list = r;
numsubjects = (length(s));

condition = 'rhyme' ;%rhyme or norhyme (NO SPACES), MAKE SURE TO CHANGE DEPENDING ON PARTICIPANT (see participant database)
% bin11 = {'S221' 'S222'};
% bin12 = {'S223' 'S224'};
bin11 = {'S231' 'S232'};
bin12 = {'S233' 'S234'};
min = -0.5;
max = 1.5;

for s = 26

        subject = subject_list{s};

% Epoch based on event code
EEG = pop_loadset ([subject '_ICA_clean.set'], workdir);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

% epoch bin11
EEG = pop_epoch( EEG, bin11 , [min max], 'newname', 'first and second target word', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-500 0] ,[]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',['/Users/lendlab/Desktop/epoch_files/no_rhyme/' [subject '_epoch_bin11.set']],'gui','off'); 

EEG = pop_loadset ([subject '_ICA_clean.set'], workdir);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );   

% epoch bin12
EEG = pop_epoch( EEG, bin12 , [min max], 'newname', 'first and second target word', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-500 0] ,[]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',['/Users/lendlab/Desktop/epoch_files/no_rhyme/' [subject '_epoch_bin12.set']],'gui','off'); 

end



%% Epoch based on event codes (No Rhyme)

% load subject list
[d,s,r] = xlsread ('norhyme_subjects.xlsx');
subject_list = r;
numsubjects = (length(s));

condition = 'norhyme'; %rhyme or norhyme (NO SPACES), MAKE SURE TO CHANGE DEPENDING ON PARTICIPANT (see participant database)
bin11 = {'231' '232'};
bin12 = {'233' '234'};
min = -0.5;
max = 1.5;

for s = 25:numsubjects

        subject = subject_list{s};


% Epoch based on event code
EEG = pop_loadset ([subject '_ICA_clean.set'], workdir);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

% epoch bin11
EEG = pop_epoch(EEG, bin11,'eventindices', [231 232], [min max]);
EEG = eeg_checkset( EEG );
EEG = pop_rmbase(EEG, [-500 0], []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',['Users/lendlab/Desktop/epoch_files/no_rhyme/' [subject '_epoch_bin11.set']],'gui','off'); 

% epoch bin12
EEG = pop_epoch(EEG, bin12, 'eventindicies', [233 234], [min max]);
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-500 0] ,[]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',['Users/lendlab/Desktop/epoch_files/no_rhyme/'  [subject '_epoch_bin12.set']],'gui','off'); 

end
%% Editing and Saving binlist
%{ The binlist is saved in the txtdir in the server (see "setting up files and folders" section for the exact loaction). For later analysis to be completed,
%you must edit the binlist and save it as a .csv file. Below are the
%instructions for how to do that correctly: %}

% 1. Open txtdir
% 2. select [subject_id_bins.txt] and open it as an Excel doc
% 3. Delete rows 1-46
% 4. Save the file in the txtdir in a .csv format. 

%% Average ERP together

clear
eeglab;
%%set up file and folders: Run this every time you re-open matlab
% establish working directory 
maindir = '/Volumes/lendlab/projects/EEG_Rhyme/data/rawdir/'; %folder that houses the data from the rhyme tasks (exposure, post-test1 and post-test2)
workdir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir/'; 
txtdir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/txtdir/';
erpdir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/';

% establish subject list
% When analyzing multiple subjects at once, change subject list to correct
% condition

%[d,s,r] = xlsread ('norhyme_subjects.xlsx');
[d,s,r] = xlsread ('rhyme_subjects.xlsx');
subject_list = r;
numsubjects = (length(s));

epoch_baseline = -500.0; %epoch baseline
epoch_end = 1000.0; %epoch offset
%condition = 'norhyme'; %rhyme or norhyme (NO SPACES), MAKE SURE TO CHANGE DEPENDING ON PARTICIPANT (see participant database)
condition = 'rhyme' ;


for s=1:numsubjects %change number of subjects as needed
    
    subject = subject_list{s};

     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
     eeglab('redraw');

EEG = pop_loadset('filename',[subject '_epoch_ar.set'],'filepath',workdir);
ERP = pop_averager( EEG , 'Criterion', 'good', 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
ERP = pop_filterp( ERP,  [] , 'Cutoff',  20, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
ERP = pop_binoperator( ERP, {  'b15 = b12-b11 label Late minus Early trials'});
ERP = pop_erpchanoperator( ERP, {  'ch32 = (ch1 +ch2 + ch3 + ch4 + ch5 +ch6)/6 label left frontal',  'ch33 = (ch26 +ch27 + ch28 + ch29 + ch30 +ch31)/6 label right frontal',...
  'ch34 = (ch7+ch8+ch9+ch10+ch11)/5 label left central',  'ch35 = (ch20+ch21+ch22+ch24+ch25)/5 label right central',...
  'ch36 = (ch13+ch14+ch15)/3 label left parietal',  'ch37 = (ch17+ch18+ch19)/3 label right parietal', 'ch38 = (ch1+ch6+ch28+ch31)/4 label frontal'} , 'ErrorMsg', 'popup',...
 'KeepLocations',  1, 'Warning', 'off' );
ERP = pop_savemyerp(ERP, 'erpname', subject, 'filename', [subject '.erp'], 'filepath', [erpdir filesep condition filesep], 'Warning', 'off'); 

end

%% ERP Edits: Filter, Channel edit, Bin editor

erpdir = '/Volumes/juschnei/lendlab/projects/EEG_Rhyme/analysis/erpdir/';

[d,on s,r] = xlsread ('norhyme_subjects.xlsx');
%[d,s,r] = xlsread ('rhyme_subjects.xlsx');
subject_list = r;
numsubjects = (length(s));

epoch_baseline = -500.0; %epoch baseline
epoch_end = 1000.0; %epoch offset
condition = 'norhyme'; %rhyme or norhyme (NO SPACES), MAKE SURE TO CHANGE DEPENDING ON PARTICIPANT (see participant database)
%condition = 'rhyme' ;

for s=4           :numsubjects %change number of subjects as needed
    
    subject = subject_list{s};

     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
     eeglab('redraw');

ERP = pop_loaderp( 'filename', [subject '.erp'], 'filepath', [erpdir condition filesep] );
ERP = pop_filterp( ERP,  [] , 'Cutoff',  20, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  2 );
ERP = pop_binoperator( ERP, {  'b13 = b12-b11 label Late minus Early trials'});
ERP = pop_erpchanoperator( ERP, {  'ch32 = (ch1 +ch2 + ch3 + ch4 + ch5 +ch6)/6 label left frontal',  'ch33 = (ch26 +ch27 + ch28 + ch29 + ch30 +ch31)/6 label right frontal',...
  'ch34 = (ch7+ch8+ch9+ch10+ch11)/5 label left central',  'ch35 = (ch20+ch21+ch22+ch24+ch25)/5 label right central',...
  'ch36 = (ch13+ch14+ch15)/3 label left parietal',  'ch37 = (ch17+ch18+ch19)/3 label right parietal', 'ch38 = (ch1+ch6+ch28+ch31)/4 label frontal'} , 'ErrorMsg', 'popup',...
 'KeepLocations',  1, 'Warning', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', [subject 'filt'], 'filename', [subject '_filt.erp'], 'filepath', [erpdir condition filesep]);

end

%% ERP Measurement tool

listdir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/ERP_list.txt';
bin11dir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin11';
bin12dir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin12';
bin21dir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin21';
bin22dir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin22';
bin23dir = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin13';

%bin11
ALLERP = pop_geterpvalues( listdir, [ 150 350],  11,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin11/ERP_mean_amp_test_150-350.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );
ALLERP = pop_geterpvalues( listdir, [ 350 550],  11,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin11/ERP_mean_amp_test_350-550.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );
ALLERP = pop_geterpvalues( listdir, [ 550 750],  11,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin11/ERP_mean_amp_test_550-750.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

%bin12
ALLERP = pop_geterpvalues( listdir, [ 150 350],  12,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin12/ERP_mean_amp_test_150-350.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );
ALLERP = pop_geterpvalues( listdir, [ 350 550],  12,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin12/ERP_mean_amp_test_350-550.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );
ALLERP = pop_geterpvalues( listdir, [ 550 750],  12,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin12/ERP_mean_amp_test_550-750.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );
%bin21
ALLERP = pop_geterpvalues( listdir, [ 150 350],  21,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin21/ERP_mean_amp_test_150-350.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

ALLERP = pop_geterpvalues( listdir, [ 350 550],  21,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin21/ERP_mean_amp_test_350-550.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

ALLERP = pop_geterpvalues( listdir, [ 550 750],  21,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin21/ERP_mean_amp_test_550-750.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

%bin22

ALLERP = pop_geterpvalues( listdir, [ 150 350],  22,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin22/ERP_mean_amp_test_150-350.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

ALLERP = pop_geterpvalues( listdir, [ 350 550],  22,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin22/ERP_mean_amp_test_350-550.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

ALLERP = pop_geterpvalues( listdir, [ 550 750],  22,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin22/ERP_mean_amp_test_550-750.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );
%bin23

ALLERP = pop_geterpvalues( listdir, [ 150 350],  23,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin23/ERP_mean_amp_test_150-350.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

ALLERP = pop_geterpvalues( listdir, [ 350 550],  23,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin23/ERP_mean_amp_test_350-550.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );

ALLERP = pop_geterpvalues( listdir, [ 550 750],  23,  1:37 , 'Baseline', 'pre', 'FileFormat',...
 'wide', 'Filename', '/Volumes/lendlab/projects/EEG_Rhyme/analysis/erpdir/ERP_Measurement/bin23/ERP_mean_amp_test_550-750.txt', 'Fracreplace', 'NaN',...
 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  3 );
