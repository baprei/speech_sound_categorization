function step4d_secondlevel_auditory_peaks_task(Sample,HomeDir)

% This function computes a second level one sample ttest for the individual
% firstlevel contrast (all auditory stimuli > baseline) to identify brain 
% regions that responded significantly to auditory stimuli during task fMRI. 

% dependencies    
    % the function uses firstlevel contrast images derived from
    % step1b_firstlevel_glm_sS.m

    % the script relies on SPM12 subfunctions 
    % install SPM12 (http://www.fil.ion.ucl.ac.uk/spm).

% Basil Preisig 17-4-2019

%% set input parameters

%HomeDir='/pool-neu02/ds-neu2b/baprei-srv/Documents/DSC_3011204.02_908';
addpath(fullfile(HomeDir,'code'));

spm_dir = '/pool-neu02/ds-neu2b/baprei-srv/local_software/spm12'; 
addpath(spm_dir); % add spm directory to the matlab path

numSubjects=length(Sample);

% check if results dir exists / mkdir if necessary
OutDir=fullfile(HomeDir,'analyses','secondlevel_auditory_peaks_task');
if exist(OutDir)==0
    mkdir(fullfile(HomeDir,'analyses'),'secondlevel_auditory_peaks_task')   
end
cd(OutDir);

%% spm batch

% Specify model
%-----------------------------------------------------------------------

mbatch1{1}.spm.stats.factorial_design.dir = cellstr(OutDir); % define output directory


% add image files
P=[];
for s=1:numSubjects
    
    participant_id=Sample{s};% participant_id identifier
    SubjConDir=fullfile(HomeDir,participant_id,'firstlevel_glm_sS_1');
    
    load(fullfile(SubjConDir,'SPM.mat')); % load spm mat.
    ContrastName='Sound>baseline'; % 'Sound > baseline' contrast name
    con_idx=find(strcmp({SPM.xCon.name},ContrastName)); % find contrast index           
    temp = fullfile(SubjConDir,['con_',sprintf('%04d',con_idx),'.nii']); % add contrast filepath
    
    P=[P;temp];
end

% Specify other options
mbatch1{1}.spm.stats.factorial_design.des.t1.scans=cellstr(P); % add con images
mbatch1{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
mbatch1{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
mbatch1{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
mbatch1{1}.spm.stats.factorial_design.masking.im = 1;
mbatch1{1}.spm.stats.factorial_design.masking.em = {''};
mbatch1{1}.spm.stats.factorial_design.globalc.g_omit = 1;
mbatch1{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
mbatch1{1}.spm.stats.factorial_design.globalm.glonorm = 1;



% Model estimation parameters
%-----------------------------------------------------------------------
mbatch2{1}.spm.stats.fmri_est.spmmat = cellstr(fullfile(pwd,'SPM.mat'));
mbatch2{1}.spm.stats.fmri_est.write_residuals = 0;
mbatch2{1}.spm.stats.fmri_est.method.Classical = 1;

% Results
%-----------------------------------------------------------------------
   

% Initialise cfg_util
spm_jobman('initcfg');
		spm_jobman('run',mbatch1);
        spm_jobman('run',mbatch2);
        
        
% Define Contrasts
%-----------------------------------------------------------------------
% Define Contrasts
%-----------------------------------------------------------------------

load SPM.mat

% all auditory stimuli > baseline
SPM.xCon=spm_FcUtil('Set',['all auditory stimuli > baseline'],'T','c',1,SPM.xX.xKXs);

spm_contrasts(SPM);


