clear all
close all
clc

%% set parameters

% collection home directory
HomeDir='../DSC_3011204.02_679';

% add analysis code
addpath(fullfile(HomeDir,'code'))

% dependencies (Matlab/spm12/rstudio)
spm_dir = '../spm12'; 
addpath(spm_dir); % add spm directory to the matlab path

% add marsbar
addpath ../spm12/toolbox/marsbar

%cbrewer
addpath ../cbrewer 

%mseb
addpath '../mseb'

% add toolbox decoding toolbox
toolboxRoot = '../decoding_toolbox_v3.997'; addpath(genpath(toolboxRoot));

%% step 1: binaural integration

% load participants fMRI
t=readtable(fullfile(HomeDir,'participants_incl_fMRI.txt'));
Sample=t.participant_id;

% This R script aggregates the trial level behavioral data and calculates hit rate
% per Stimulus class for sham run
% -step1a_aggregate_behavioral_data.R

% This JASP file computes the descriptives sample mean +/- sem per Stimulus
% class
% -step1b_behavioral_data_mean.jasp

%% step2: BOLD patterns differentiating /da/ vs /ga/ syllable reports

% firstlevel glm fMRI
%--------------------------------------------------------------------------

% Feature extraction for subsequent MVPA was carried out in subjects' 
% native image space using using the realigned and unwrapped EPI images.
parfor iSubj=1:size(Sample,1)   
    step2a_firstlevel_task_glm_nS(Sample{iSubj},HomeDir)     
end

% common brain mask for passive listening and task
%--------------------------------------------------------------------------------
glm_name={'firstlevel_glm_task_nS','firstlevel_glm_listening_nS'};
for iSubj=1:size(Sample,1)
    % This function conmputes a brainmask which includes the voxels that are
    % shared between listening and task blocks
    sub_brainmask_listening_task_nS(Sample{iSubj}, HomeDir,glm_name)
end

% Compute crossnobis distance between /da/ vs /ga/ response using
% MVPA searchlight procedure using the TDT toolbox
%------------------------------------------------------------------------------
glm_name='firstlevel_glm_task_nS';
roi_name='brainmask.nii';

% We computed the crossnobis distance between /da/ and /ga/ reports as the 
% arithmetic product of the perceptual distances in unambiguous and ambiguous 
% stimuli. 
%(/da/ report unambiguous - /ga/ report unambiguous) × (/da/ report ambiguous - /ga/ report ambiguous)
step2b_MVPA_task_crossnobis_xclass_cv(Sample,HomeDir,roi_name,glm_name);

% normalize and smooth meandist maps
%------------------------------------------------------------------------------

% For group-level inference, individual crossnobis distance maps were normalized 
% and smoothed (using a Gaussian kernel with a full-width at half maximum of 8 mm)
AnalysisName={'MVPA_task_crossnobis_xclass_cv'};
MapType='res_other_meandist.nii';
Prefix='';

smoothkern=8; %mm

ThresholdGroupMask=fullfile(HomeDir,'analyses','secondlevel_auditory_peaks_task', ...
    'mask.nii'); %normalized mask

for iSubj=1:size(Sample,1) 
    for iAnalysis=1:length(AnalysisName)

        % normalize meandist map
        sub_normalize_map(Sample{iSubj},HomeDir,AnalysisName{iAnalysis},MapType)

        % smooth meandist map
        sub_smooth_map(Sample{iSubj},HomeDir,AnalysisName{iAnalysis},['w' MapType],smoothkern)

        %mask out meandist map voxels outside the brain
        sub_mask_map(Sample{iSubj},HomeDir,AnalysisName{iAnalysis},['sw' MapType],ThresholdGroupMask,Prefix)
    
    end

end

% Grouplevel analysis
%-----------------------------------------------------------------------------
for iAnalysis=1:length(AnalysisName)
    
    % This function computes a grouplevel one sample ttest using the SnPM
    % toolbox for the individual normalized and smoothed crossnobis distance maps 
    % to identify brain regions that represent categorical information for the 
    % selected Analysis.    
    sub_secondlevel_SnPM(Sample,HomeDir,AnalysisName{iAnalysis},MapType)    
end

% This script plots grouplevel data presented in Fig 4 using MRIcroGL
%step2c_Fig2_MRICroGL.py


%% step 3:	Acoustic or phonemic representation?

% In follow-up analyses, we tested whether categorical patterns derived from 
% the unambiguous stimuli in the localized regions generalize better to the 
% stimulus percept (/da/ vs /ga/) within the same acoustic stimulus, or to 
% the presented acoustic stimulus (high vs low F3) within the same stimulus percept. 

% Firstlevel glm fMRI
%---------------------------------------------------------------------------

parfor iSubj=1:size(Sample,1)            
%     percept (min n=20 trials per category)
        % -1) LE_highF3_RE_amb stimulus (da vs ga percept), n=16
        % -2) LE_lowF3_RE_amb stimulus (da vs ga percept), n=15
 
%     acoustics (min n=20 trials per category)
        % -3) DA response trials (high vs low F3 stimulus), n=15
        % -4) GA response trials (high vs low F3 stimulus), n=16    
      step3a_firstlevel_glm_acoustic_vs_percept_nS(Sample{iSubj},HomeDir) % native Space data for decoding    
end

% MVPA searchlight analysis using TDT toolbox
%-----------------------------------------------------------------------------
glm_name='firstlevel_glm_acoustic_vs_percept_nS';
roi_name='brainmask.nii';

% Compute crossnobis distance between /da/ vs /ga/  within single stimulus 
% (highF3 or lowF3)
Stimulus={'highF3','lowF3'};
for i=1:length(Stimulus)
    step3b_MVPA_percept_crossnobis_xclass_cv(Sample,HomeDir,Stimulus{i},roi_name,glm_name);
end

% Compute crossnobis distance between high vs lowF3  within single response 
% (ga vs da responses)
Response={'DA','GA'};
for i=1:length(Response)
    step3c_MVPA_acoustic_crossnobis_xclass_cv(Sample,HomeDir,Response{i},roi_name,glm_name);
end

%normalize and smooth decoding maps
%--------------------------------------------------------------------------------------
AnalysisName={'MVPA_percept_highF3_crossnobis_xclass_cv', ...
    'MVPA_percept_lowF3_crossnobis_xclass_cv', ...
    'MVPA_acoustic_DA_crossnobis_xclass_cv', ...
    'MVPA_acoustic_GA_crossnobis_xclass_cv'};
MapType='res_other_meandist.nii';
Prefix='m';
smoothkern=8; %mm

% Follow-up MVPA analysis constrained to the regions presented identified
% in step 2
ThresholdGroupMask=fullfile(HomeDir,'analyses','secondlevel_MVPA_task_crossnobis_xclass_cv', ...
    'SnPM_thresholded_FDR_05_binarized.nii'); %normalized mask


for iSubj=1:size(Sample,1) 
    for iAnalysis=1:length(AnalysisName)

    % normalize meandist map
    sub_normalize_map(Sample{iSubj},HomeDir,AnalysisName{iAnalysis},MapType)

    % smooth meandist map
    sub_smooth_map(Sample{iSubj},HomeDir,AnalysisName{iAnalysis},['w' MapType],smoothkern)

    %mask out meandist map voxels outside the brain
    sub_mask_map(Sample{iSubj},HomeDir,AnalysisName{iAnalysis},['sw' MapType],ThresholdGroupMask,Prefix)
    
    end

end

% Grouplevel analysis for perceptual and acoustic representations
%-------------------------------------------------------------------------

% This function calculates the minimal number of /da/ responses for lowF3
% trials and the minimal number of /ga/ responses for highF3 trials per run
% per participants during ambiguous trials
[nTrials, SmallestnTrialsPerRun,nTrials_wide]=step3d_nTrialsPerConditionPerRun(HomeDir);

minTrialsPerRun=2;% minimal n trials per Run

% Find participant that contribute to both analyses
% and compute average image for those
[SecondLevelInput]=step3e_secondlevel_input(HomeDir,Sample,SmallestnTrialsPerRun,minTrialsPerRun);

% This function computes a second level one sample ttest using the SnPM
% toolbox for the individual normalized and smoothed crossnobis distance maps 
Representation={'percept','acoustic'};
for iRep=1:length(Representation)      
    sub_secondlevel_subgroups_SnPM(SecondLevelInput,HomeDir,Representation{iRep},MapType)   
end

% This script plots the data presented in Fig3A using MRIcroGL
% step3f_Fig3A_MRICroGL.py

% contrast perceptual > acoustic maps
Representation={'percept','acoustic'};
sub_secondlevel_SnPM_paired_ttest(SecondLevelInput,Sample,HomeDir,Representation,MapType)

% contrast acoustic > perceptual maps
Representation={'acoustic','percept'};
sub_secondlevel_SnPM_paired_ttest(SecondLevelInput,Sample,HomeDir,Representation,MapType)

% This script plots the data presented in Fig3B using MRIcroGL
% step3g_Fig3B_MRICroGL.py

%% step 4: Auditory activation during passive listening and task

% firstlevel glm fMRI
%---------------------------------------------------------------------------
parfor iSubj=1:size(Sample,1)
    
    % passive listening (baseline block)
    step4a_firstlevel_glm_listening_sS(Sample{iSubj},HomeDir)
    
    % task fMRI
    step4b_firstlevel_glm_task_sS(Sample{iSubj},HomeDir) % standard Space (sS) to define grouplevel auditory mask
        
end

% Grouplevel analysis 
%-----------------------------------------------------------------------------

% These function computes a second level one sample ttest:

% to identify brain regions that responded significantly to auditory stimuli during listening. 
step4c_secondlevel_auditory_peaks_listening(Sample,HomeDir)

% to identify brain regions that responded significantly to auditory stimuli and task. 
step4d_secondlevel_auditory_peaks_task(Sample,HomeDir)

% This script plots the data presented in Fig 4 using MRIcroGL
% step4e_Fig4_MRICroGL.py