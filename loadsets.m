 %% Load subjects from excel

% Author: JMS 
% Date created: November 21, 2022

%Load subject excel file
[d,s,r]=xlsread('rhyme_subjects.xlsx');
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

for k=1:length(s);

EEG = pop_loadset('filename',[s{k} '_epoch_bin11.set'],'filepath',('/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir/epoch_bins/rhyme/'));
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
EEG = pop_loadset('filename',[s{k} '_epoch_bin12.set'],'filepath',('/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir/epoch_bins/rhyme/'));
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
end

[d,s,r]=xlsread('norhyme_subjects.xlsx');
for k=1:length(s);

EEG = pop_loadset('filename',[s{k} '_epoch_bin11.set'],'filepath',('/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir/epoch_bins/no_rhyme/'));
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
EEG = pop_loadset('filename',[s{k} '_epoch_bin12.set'],'filepath',('/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir/epoch_bins/no_rhyme/'));
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
end

disp('LoadDataSets is done running');