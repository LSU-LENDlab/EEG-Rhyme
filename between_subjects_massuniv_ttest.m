 %% Mass Univariate Analysis Between-Subjects t-test

% Author: Will Decker 
% Date created: November 7, 2022

%% Establish working directory
% All mass univariate analysis will take place in this folder
% Make sure all .erp files are moved over to this folder!!!

cd '/Users/lendlab/Library/CloudStorage/Box-Box/LEND_Lab/projects/EEG_Rhyme/analysis/erpdirnew/massuni'

%% Converting [.erp] files to [.gnd] files

% estsablish list of .erp files 

norhyme = readtext('norhyme_filt_list.txt');
rhyme = readtext('rhyme_filt_list.txt');
%total = readtext('total.txt');

% index cell arrays (list of .erp files)y

% load .erp files, convert to .GND file, save file to directory
GND = erplab2GND(norhyme, 'out_fname', 'norhyme_filt.GND'); 
GND = erplab2GND(rhyme, 'out_fname', 'rhyme_filt.GND');
%GND = erplab2GND(total, 'out_fname', 'total.GND');


%% Converting [.gnd] files to [.grp] files

GRP = GNDs2GRP({'norhyme_filt.GND', 'rhyme_filt.GND'},... % load the two .GND files created in the previous section
     'create_difs', 'yes' ,'out_fname', 'eeg_rhyme_filt.GRP'); 

%% Create differences of bins of interest

GRP = bin_dif(GND,12,11, 'target words 3&4-targets words 1&2');
GND = gui_erp(GND,'bin',13);
%% Mean time window analysis
% tmax permutation test using GRP

GRP = tmaxGRP('eeg_rhyme_filt.GRP', 13, 'time_wind', [450 550]);
GRP = tmaxGRP('eeg_rhyme_filt.GRP', 13, 'time_wind', [300 800]);
GRP = tmaxGRP('eeg_rhyme_filt.GRP', 13, 'time_wind', [300 800]);

%% Cluster Permutation Analysis

GRP=clustGRP('eeg_rhyme_filt.GRP',13,'time_wind',[180 270],'mean_wind','yes');


 %%

% plot group averave for rhyme condition and apply 20 hz filter
% load single erp file, apply filter, save new file with 'filt' name
% plot both conditions, apply filter and if it's still bad, plot each
% individual and see which one is messing up
% use the new filterd .erps for mass uni analysis
% calculate bin diff between bins 12 - 11

%% FMUT analysis 
% Documentation is here:https://github.com/ericcfields/FMUT/wiki
% Download to install: https://github.com/ericcfields/FMUT/releases
% Sample script: https://github.com/aschetti/test_FMUT/blob/main/scripts/test_FMUT.m
% in 'spatial_neighbors' function, line 55 has been changed with the
% addition of '-7' 

%[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
%close all;

massuni = '/Volumes/juschnei/lendlab/projects/EEG_Rhyme/analysis/erpdir/MassUni';
pathdata_mass = [massuni 'MUT/'];

% analysis parameters
numb_perm = 1e3;
time_wind = [400 600];

load eeg_rhyme_filt.GRP -MAT

GRP =FclustGRP(GRP, 'bin', 13);

save([pathdata_mass 'test_FMUT.GRP']); % save GRP file

report_results(GRP, 1) % show results in command window