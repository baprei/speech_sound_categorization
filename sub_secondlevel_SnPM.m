function sub_secondlevel_SnPM(Sample,HomeDir,Analysis,InputFile)

% This function computes a second level one sample ttest using the SnPM
% toolbox for the individual normalized and smoothed MVPA maps 
% to identify brain regions that represent categorical information for the 
% selected Analysis. 

% dependencies    
    % the function uses firstlevel contrast images derived from
    % step3_firstlevel_glm_uv.m

    % the script relies on SPM12 subfunctions 
    % install SPM12 (http://www.fil.ion.ucl.ac.uk/spm).

%% set input parameters

%HomeDir='/pool-neu02/ds-neu2b/baprei-srv/Documents/DSC_3011204.02_908';
addpath(fullfile(HomeDir,'code'));

spm_dir = '/p01-hdd/dsa/baprei-srv/local_software/spm12'; 
addpath(spm_dir); % add spm directory to the matlab path

numSubjects=length(Sample);

% check if results dir exists / mkdir if necessary
OutDir=fullfile(HomeDir,'analyses',['secondlevel_' Analysis]);
if exist(OutDir)==0
    mkdir(fullfile(HomeDir,'analyses'),['secondlevel_' Analysis])   
end
cd(OutDir);

%InputFile='res_AUC_minus_chance.nii';
FileIdentifier=['sw' InputFile];
%FileIdentifier=InputFile;
%% spm batch

% Specify Model
%-----------------------------------------------------------------------

mbatch1{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
mbatch1{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
mbatch1{1}.spm.tools.snpm.des.OneSampT.dir = cellstr(OutDir); % define output directory


% add image files
P=[];
for s=1:numSubjects
    
    participant_id=Sample{s};% participant_id identifier
    SubjConDir=fullfile(HomeDir,participant_id,Analysis);
    if exist(SubjConDir)~=0   
        File=dir(fullfile(SubjConDir ,FileIdentifier));
        disp(participant_id)
        P=[P;fullfile(File.folder,File.name)];
    end
end



mbatch1{1}.spm.tools.snpm.des.OneSampT.P=cellstr(P);
mbatch1{1}.spm.tools.snpm.des.OneSampT.nPerm = 5000;
mbatch1{1}.spm.tools.snpm.des.OneSampT.vFWHM = [0 0 0];
mbatch1{1}.spm.tools.snpm.des.OneSampT.bVolm = 1;
mbatch1{1}.spm.tools.snpm.des.OneSampT.ST.ST_none = 0;
mbatch1{1}.spm.tools.snpm.des.OneSampT.masking.tm.tm_none = 1;
mbatch1{1}.spm.tools.snpm.des.OneSampT.masking.im = 1;
%mbatch1{1}.spm.tools.snpm.des.OneSampT.masking.em = {'/pool-neu02/ds-neu2b/baprei-srv/Documents/DAC_3011204.02_908/3_tACS_fMRI_study2/data_analysis/TDT/decoding_perRunInt_acc/bb_auditory_clusters_FWE_p05_ab.nii'};
mbatch1{1}.spm.tools.snpm.des.OneSampT.masking.em = {''};
mbatch1{1}.spm.tools.snpm.des.OneSampT.globalc.g_omit = 1;
mbatch1{1}.spm.tools.snpm.des.OneSampT.globalm.gmsca.gmsca_no = 1;
mbatch1{1}.spm.tools.snpm.des.OneSampT.globalm.glonorm = 1;


% Compute
%-----------------------------------------------------------------------

mbatch2{1}.spm.tools.snpm.cp.snpmcfg = cellstr(fullfile(pwd,'SnPWcfg.mat'));

% Results
%-----------------------------------------------------------------------
   
mbatch3{1}.spm.tools.snpm.inference.SnPMmat = {fullfile(pwd,'SnPM.mat')};
%mbatch3{1}.spm.tools.snpm.inference.Thr.Vox.VoxSig.Pth = 0.001;
mbatch3{1}.spm.tools.snpm.inference.Thr.Vox.VoxSig.FDRth = 0.05;
%mbatch3{1}.spm.tools.snpm.inference.Thr.Vox.VoxSig.FWEth = 0.05;
mbatch3{1}.spm.tools.snpm.inference.Tsign = 1; % Positive effects
%mbatch3{1}.spm.tools.snpm.inference.WriteFiltImg.WF_no = 1;
%mbatch3{1}.spm.tools.snpm.inference.WriteFiltImg.name = 'SnPM_thresholded_p_unc_001';
mbatch3{1}.spm.tools.snpm.inference.WriteFiltImg.name = 'SnPM_thresholded_p_FDR_05';
mbatch3{1}.spm.tools.snpm.inference.Report = 'MIPtable';




% Initialise cfg_util
spm_jobman('initcfg');
		spm_jobman('run',mbatch1);
        spm_jobman('run',mbatch2);
        spm_jobman('run',mbatch3);
        
        


