clear
eeglab;
close all;

%% startup FT
% restoredefaultpath
% addpath /Users/julie/Documents/MATLAB/eeglab2021.0/plugins/fieldtrip
% ft_defaults

%% set up file and folders
% establish working directory 
%% set up file and folders
% establish working directory 
ftfolder =  '/Volumes/lendlab/projects/EEG_Rhyme/analysis/derivatives/ft_output/';
bdffolder = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/txtdir/binlists/';
erspfolder = '/Volumes/lendlab/projects/EEG_Rhyme/analysis/wkdir/epoch_bins/';

% establish parameters
date = 'May11';
condition = 'no_rhyme';

% establish subject list
[d,s,r]=xlsread('norhyme_subjects_n27.xlsx');
subject_list = r;
numsubjects = (length(s));

% load channel information
% load goodchanstuff_HL.mat;

%% Perform condition .set to FT transfers%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for s=1:numsubjects
    subject = subject_list{s};
      fprintf('\n\n\n*** Loading condition 1 EEGLAB data from subject (%s) ***\n\n\n', s , subject);
    EEG = pop_loadset('filename', [subject '_epoch_bin11.set'],'filepath',[erspfolder filesep condition filesep]);
eeglab redraw
%convert set to data 
FTcurrentdata = eeglab2fieldtrip (EEG, 'preprocessing','none');
FTcurrentdata_rhyme11.(['sub_' subject]) = FTcurrentdata;
clearvars FTcurrentdata
end

%% set up freqanalysis cfg %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 3:0.5:30;                         % analysis 3 to 30 Hz in steps of 0.5 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.4;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.025:1;                  % time window "slides" from -0.5 to 1 sec in steps of 25 msec/.025
%TFRhann = ft_freqanalysis(cfg, dataFIC);

%% run freqanalysis for conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make sure you have fieldtrip installed and added to the path.
for s=1:numsubjects
    subject = subject_list{s};
        fprintf('\n\n\n*** Running condition 1 frequency analysis for (%s) ***\n\n\n', s , subject);
   %Run frequency analysis
        freq_currentsubject = ft_freqanalysis(cfg, FTcurrentdata_rhyme12.(['sub_' subject]));
        freq_rhyme12.(['sub_' subject]) = freq_currentsubject;
end
clearvars freq_currentsubject

%% Average freq structures
cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim = 'all';
cfg.toilim = 'all';
cfg.channel = 'all';
cfg.paramter = 'powspctrm';

%% %Make a good electrode configuration (subject.elec) to slap onto your grand average
%stuctures by taking one from any random previous subject. The grand
%average step drops the elecrode information for some reason
goodelectrodeconfig = freq_rhyme11.(['sub_' subject_list{1}]).elec

GA_freq_rhyme11 = ft_freqgrandaverage(cfg,  freq_rhyme11.(['sub_' subject_list{1}]),freq_rhyme11.(['sub_' subject_list{2}]),	freq_rhyme11.(['sub_' subject_list{3}]),	 freq_rhyme11.(['sub_' subject_list{4}]),	  freq_rhyme11.(['sub_' subject_list{5}]),   freq_rhyme11.(['sub_' subject_list{6}]),	freq_rhyme11.(['sub_' subject_list{7}]),	 freq_rhyme11.(['sub_' subject_list{8}]),	  freq_rhyme11.(['sub_' subject_list{9}]),    freq_rhyme11.(['sub_' subject_list{10}]),	freq_rhyme11.(['sub_' subject_list{11}]),	freq_rhyme11.(['sub_' subject_list{12}]),	freq_rhyme11.(['sub_' subject_list{13}]),	freq_rhyme11.(['sub_' subject_list{14}]),	freq_rhyme11.(['sub_' subject_list{15}]),	freq_rhyme11.(['sub_' subject_list{16}]),	freq_rhyme11.(['sub_' subject_list{17}]),	freq_rhyme11.(['sub_' subject_list{18}]),	freq_rhyme11.(['sub_' subject_list{19}]),	freq_rhyme11.(['sub_' subject_list{20}]),	freq_rhyme11.(['sub_' subject_list{21}]),	freq_rhyme11.(['sub_' subject_list{22}]),	freq_rhyme11.(['sub_' subject_list{23}]),	freq_rhyme11.(['sub_' subject_list{24}]),	freq_rhyme11.(['sub_' subject_list{24}]), freq_rhyme11.(['sub_' subject_list{25}]), freq_rhyme11.(['sub_' subject_list{26}]), freq_rhyme11.(['sub_' subject_list{27}]))
GA_freq_rhyme11.elec = goodelectrodeconfig;

GA_freq_rhyme12 = ft_freqgrandaverage(cfg,  freq_rhyme12.(['sub_' subject_list{1}]),	   freq_rhyme12.(['sub_' subject_list{2}]),	freq_rhyme12.(['sub_' subject_list{3}]),	 freq_rhyme12.(['sub_' subject_list{4}]),	  freq_rhyme12.(['sub_' subject_list{5}]),   freq_rhyme12.(['sub_' subject_list{6}]),	freq_rhyme12.(['sub_' subject_list{7}]),	 freq_rhyme12.(['sub_' subject_list{8}]),	  freq_rhyme12.(['sub_' subject_list{9}]),    freq_rhyme12.(['sub_' subject_list{10}]),	freq_rhyme12.(['sub_' subject_list{11}]),	freq_rhyme12.(['sub_' subject_list{12}]),	freq_rhyme12.(['sub_' subject_list{13}]),	freq_rhyme12.(['sub_' subject_list{14}]),	freq_rhyme12.(['sub_' subject_list{15}]),	freq_rhyme12.(['sub_' subject_list{16}]),	freq_rhyme12.(['sub_' subject_list{17}]),	freq_rhyme12.(['sub_' subject_list{18}]),	freq_rhyme12.(['sub_' subject_list{19}]),	freq_rhyme12.(['sub_' subject_list{20}]),	freq_rhyme12.(['sub_' subject_list{21}]),	freq_rhyme12.(['sub_' subject_list{22}]),	freq_rhyme12.(['sub_' subject_list{23}]),	freq_rhyme12.(['sub_' subject_list{24}]),	freq_rhyme12.(['sub_' subject_list{24}]), freq_rhyme12.(['sub_' subject_list{25}]), freq_rhyme12.(['sub_' subject_list{26}]), freq_rhyme12.(['sub_' subject_list{27}]))
GA_freq_rhyme12.elec = goodelectrodeconfig;

GA_freq_norhyme11 = ft_freqgrandaverage(cfg,  freq_norhyme11.(['sub_' subject_list{1}]),  freq_norhyme11.(['sub_' subject_list{2}]),	freq_norhyme11.(['sub_' subject_list{3}]),	 freq_norhyme11.(['sub_' subject_list{4}]),	  freq_norhyme11.(['sub_' subject_list{5}]),   freq_norhyme11.(['sub_' subject_list{6}]),	freq_norhyme11.(['sub_' subject_list{7}]),	 freq_norhyme11.(['sub_' subject_list{8}]),	  freq_norhyme11.(['sub_' subject_list{9}]),    freq_norhyme11.(['sub_' subject_list{10}]),	freq_norhyme11.(['sub_' subject_list{11}]),	freq_norhyme11.(['sub_' subject_list{12}]),	freq_norhyme11.(['sub_' subject_list{13}]),	freq_norhyme11.(['sub_' subject_list{14}]),	freq_norhyme11.(['sub_' subject_list{15}]),	freq_norhyme11.(['sub_' subject_list{16}]),	freq_norhyme11.(['sub_' subject_list{17}]),	freq_norhyme11.(['sub_' subject_list{18}]),	freq_norhyme11.(['sub_' subject_list{19}]),	freq_norhyme11.(['sub_' subject_list{20}]),	freq_norhyme11.(['sub_' subject_list{21}]),	freq_norhyme11.(['sub_' subject_list{22}]),	freq_norhyme11.(['sub_' subject_list{23}]),	freq_norhyme11.(['sub_' subject_list{24}]),	freq_norhyme11.(['sub_' subject_list{24}]), freq_norhyme11.(['sub_' subject_list{25}]), freq_norhyme11.(['sub_' subject_list{26}]), freq_norhyme11.(['sub_' subject_list{27}]))
GA_freq_norhyme11.elec = goodelectrodeconfig;

GA_freq_norhyme12 = ft_freqgrandaverage(cfg,  freq_norhyme12.(['sub_' subject_list{1}]),	   freq_norhyme12.(['sub_' subject_list{2}]),	freq_norhyme12.(['sub_' subject_list{3}]),	 freq_norhyme12.(['sub_' subject_list{4}]),	  freq_norhyme12.(['sub_' subject_list{5}]),   freq_norhyme12.(['sub_' subject_list{6}]),	freq_norhyme12.(['sub_' subject_list{7}]),	 freq_norhyme12.(['sub_' subject_list{8}]),	  freq_norhyme12.(['sub_' subject_list{9}]),    freq_norhyme12.(['sub_' subject_list{10}]),	freq_norhyme12.(['sub_' subject_list{11}]),	freq_norhyme12.(['sub_' subject_list{12}]),	freq_norhyme12.(['sub_' subject_list{13}]),	freq_norhyme12.(['sub_' subject_list{14}]),	freq_norhyme12.(['sub_' subject_list{15}]),	freq_norhyme12.(['sub_' subject_list{16}]),	freq_norhyme12.(['sub_' subject_list{17}]),	freq_norhyme12.(['sub_' subject_list{18}]),	freq_norhyme12.(['sub_' subject_list{19}]),	freq_norhyme12.(['sub_' subject_list{20}]),	freq_norhyme12.(['sub_' subject_list{21}]),	freq_norhyme12.(['sub_' subject_list{22}]),	freq_norhyme12.(['sub_' subject_list{23}]),	freq_norhyme12.(['sub_' subject_list{24}]),	freq_norhyme12.(['sub_' subject_list{24}]), freq_norhyme12.(['sub_' subject_list{25}]), freq_norhyme12.(['sub_' subject_list{26}]), freq_norhyme12.(['sub_' subject_list{27}]))
GA_freq_norhyme12.elec = goodelectrodeconfig;

%% Make difference value between conditions
% concrete - abstract within conceptual condition
GA_rhyme_diff = GA_freq_rhyme11;
GA_rhyme_diff.powspctrm = GA_freq_rhyme12.powspctrm - GA_freq_rhyme11.powspctrm;

GA_norhyme_diff = GA_freq_norhyme11;
GA_norhyme_diff.powspctrm = GA_freq_norhyme12.powspctrm - GA_freq_norhyme11.powspctrm;

%% Permutation test: Paired Samples T-test
cfg = [];
cfg.channel          = {'all'};
cfg.latency          = [0.0 1.0];
cfg.frequency        = [13 17];
cfg.avgovertime      = 'yes' ;                  
cfg.avgoverfreq      = 'yes';
cfg.method           = 'montecarlo';
cfg.tail             = 0;

cfg.computestat    = 'yes' 
cfg.computecritval = 'yes'
cfg.computeprob    = 'yes'
cfg.correctm         = 'cluster';

% paired samples t-test: depsamplesT
cfg.statistic = 'indepsamplesT';
cfg.clusteralpha     = 0.05;  %the alpha-value used for the initial test-statistic (in my case a paired t-test) for thresholding the data
cfg.clusterstatistic = 'maxsum';
cfg.clustercritval = 0.05;
cfg.minnbchan        = 3; %alter for triangulation
cfg.clustertail      = cfg.tail;
cfg.alpha            = 0.05; %0.05 one-sided and .025 is two-sided
cfg.numrandomization= 500;
cfg.correcttail = 'alpha';

% specifies with which sensors other sensors can form clusters
cfg_neighb.method    = 'triangulation';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, GA_freq_rhyme11);

%You can also set up neighbors with a template from the interwebs
% cfg_neighb.method    = 'template';
% cfg.neighbours       = chan62_neighborfile

%% within groups t-test design 
% description of multivariate comparison here: https://www.fieldtriptoolbox.org/faq/how_can_i_test_an_interaction_effect_using_cluster-based_permutation_tests/
% design info can be found here: https://www.fieldtriptoolbox.org/walkthrough/#statistics
% 
% subj = size(numsubjects,2);
% design = zeros(2,subj*2);
% for i = 1:subj
% design(2,i) = i;
% end
% for i = 1:subj
% design(2,i+subj:2*subj) = i;
% end
% 
% design(1,1:subj)=1;
% design(1,subj+1:2*subj)=2;
% cfg.design   = design;
% cfg.ivar     = 1; %   cfg.ivar  = independent variable, row number of the design that contains the labels of the conditions to be compared (default=1)
% cfg.uvar     = 2; %   cfg.uvar  = unit variable, row number of design that contains the labels of the units-of-observation, i.e. subjects or trials (default=2)

%% for a between groups design
% % description of multivariate comparison here: https://www.fieldtriptoolbox.org/faq/how_can_i_test_an_interaction_effect_using_cluster-based_permutation_tests/
% % design info can be found here: https://www.fieldtriptoolbox.org/walkthrough/#statistics
cfg.keepindividual = 'yes'
subj = 28;
cfg.design = [ones(1,subj), ones(1,subj)*2];
cfg.ivar     = 1; %   cfg.ivar  = independent variable, row number of the design that contains the labels of the conditions to be compared (default=1)

%% between groups t-test permutation test
stats_group_cluster = ft_freqstatistics(cfg, GA_norhyme_diff, GA_rhyme_diff)

%% cluster lister positive
stats_group_cluster.posclusters = stats_group_cluster.posclusters(1);
clusterfinderrows = [];
clusterfindercolumns = [];
chan_list = stats_group_cluster.label;
clusterlister = {'one','two','three','four','five','six','seven','eight',...
    'nine','ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen'...
    'seventeed','eighteen','nineteen','twenty'};
%%% For loop for all channels %%%
for q = (1:length(chan_list));
    numchans = length(chan_list);
    channy = chan_list{q};
    slicer = stats_group_cluster.posclusterslabelmat(q,:,:);
    compactdata = squeeze(slicer);
%%% Loop through different clusters
for spec_cluster = 1:length(stats_group_cluster.posclusters)
    clear clusterlocs
     clusternamer =  clusterlister{spec_cluster};
    [row,col] = find(compactdata==spec_cluster);
    coord_cells = row;
    coord_cells(:,2) = col;
    current_row = 0;
%%% loop to find our frequencies
for time_freq_finder = 1:length(coord_cells(:,1));
    current_row = current_row+1;
    cellvalue = coord_cells(time_freq_finder,1);
    clusterlocs(current_row, 1) =  stats_group_cluster.freq(cellvalue);
end
        current_row = 0;  
%%% loop to find our times
for time_freq_finder = 1:length(coord_cells(:,1)); 
      current_row = current_row+1;
cellvalue = coord_cells(time_freq_finder,2);
clusterlocs(current_row, 2) = stats_group_cluster.time(cellvalue);   
end
if isempty(coord_cells)==0;   
    cluster_master.(clusternamer).(channy) = clusterlocs;  
else     
end
end
end

%% extract positive clusters
data = stats_group_cluster;
channels = data.label(sum(sum(data.posclusterslabelmat==1,3),2)>0);
timepoints = data.time(squeeze(sum(sum(data.posclusterslabelmat==1,2),1))>0)';
freqpoints = data.freq(squeeze(sum(sum(data.posclusterslabelmat==1,3),1))>0)';
%% extract negative clusters
data = stats_Hidiff_cluster;
channels = data.label(sum(sum(data.negclusterslabelmat==1,3),2)>0);
timepoints = data.time(squeeze(sum(sum(data.negclusterslabelmat==1,2),1))>0)';
freqpoints = data.freq(squeeze(sum(sum(data.negclusterslabelmat==1,3),1))>0)';

%% topoplot
 %%%%TOPOPLOT of entrie scalp
load('quickcap64.mat');
cfg = [];
cfg.xlim = [0.3 0.6]; % time range
cfg.ylim = [13 30]; % insert freq range
cfg.zlim = [-0.3 0.3];
cfg.baseline = [-0.5 0];
cfg.baselinetype = 'absolute';
cfg.layout = lay;
%figure; ft_topoplotTFR(cfg, GA_313_413_diff); colorbar
%figure; ft_topoplotTFR(cfg, GA_freq_413); colorbar
figure; ft_topoplotTFR(cfg, GA_rhyme_diff); colorbar
figure; ft_topoplotTFR(cfg, GA_norhyme_diff); colorbar

%% 
cfg = [];
cfg.baseline = [-0.5 0];
cfg.baselinetype = 'absolute'; %absolute or relative
cfg.parameter = 'powspctrm';
cfg.zlim = [-0.5 0.5];
cfg.xlim = [0 0.75];
cfg.ylim = [3 30];
cfg.channel = ['FcZ']; %pick any channel or avgof channels
cfg.masknans = 'yes';
figure; ft_singleplotTFR(cfg, GA_313_413_diff);colorbar
figure; ft_singleplotTFR(cfg, GA_freq_313);colorbar
figure; ft_singleplotTFR(cfg, GA_freq_413);colorbar

%% Extract amplitude data
freq_idx = find(ismember(GA_Hi_diff.freq, freqpoints))
time_idx = find(ismember(GA_Hi_diff.time, timepoints))
channel_idx = find(ismember(GA_Hi_diff.label, channels))
