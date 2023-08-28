% Directories
% Type in the locations of these directories within the ''(quotes)
workdir = '/Users/lendlab/Library/CloudStorage/Box-Box/LEND_Lab/projects/EEG_Rhyme/analysis/workdirnew'; % The 'workdir' is an active directory that MATLAB will send all working data to

[d,s,r] = xlsread ('/Users/lendlab/Library/CloudStorage/Box-Box/LEND_Lab/projects/EEG_Rhyme/analysis/matlab_scripts/subjects.xlsx'); % Type the name of the .xlsx file within the ''(quotes). Note: it must be in the current directory.
subjects = r;
numsubjects = (length(s));

% Subjects to run
subject_start = 7; % subject in position 'x' in subjects variable
subject_end = 47; % subject in position 'x' in subjects variable

% establish data objects
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
eeglab('redraw');
    

% establish subject list
for s = subject_start : subject_end
    subject = subjects{s};
    


    EEG = pop_loadset ([subject '_epoch_ar.set'],workdir, 'all');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );5

end