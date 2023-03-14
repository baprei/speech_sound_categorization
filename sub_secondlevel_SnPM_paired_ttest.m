function sub_secondlevel_SnPM_paired_ttest(SecondLevelInput,Sample,HomeDir,Analyses,InputFile)

% This function computes a second level paired ttest for distance maps
% perceptual (da vs ga) vs acoustic (high vs low F3) 

% dependencies    

    % the script relies on SPM12 subfunctions 
    % install SPM12 (http://www.fil.ion.ucl.ac.uk/spm).
    
%% set input parameters

%HomeDir='/pool-neu02/ds-neu2b/baprei-srv/Documents/DSC_3011204.02_908';
addpath(fullfile(HomeDir,'code'));

spm_dir = '/p01-hdd/dsa/baprei-srv/local_software/spm12'; 
addpath(spm_dir); % add spm directory to the matlab path

numSubjects=length(SecondLevelInput.participant_id);

% check if results dir exists / mkdir if necessary
OutDir=fullfile(HomeDir,'analyses',['secondlevel_MVPA_paired_ttest' '_' Analyses{1} '_vs_' Analyses{2}]);
if exist(OutDir)==0
    mkdir(fullfile(HomeDir,'analyses'),['secondlevel_MVPA_paired_ttest' '_' Analyses{1} '_vs_' Analyses{2}])   
end
cd(OutDir);

% Analyses Conditions
%Analyses={'iph40Hz','aph40Hz'}; % define categories
FileIdentifier=['msw' InputFile];

%% spm batch

% Specify model
%-----------------------------------------------------------------------

mbatch1{1}.spm.tools.snpm.des.PairT.DesignName = 'MultiSub: Paired T test; 2 conditions, 1 scan per condition';
mbatch1{1}.spm.tools.snpm.des.PairT.DesignFile = 'snpm_bch_ui_PairT';
mbatch1{1}.spm.tools.snpm.des.PairT.dir = cellstr(OutDir);

%mbatch1{1}.spm.stats.factorial_design.dir = cellstr(OutDir); % define output directory

%Load con images
Cnt=1;

        
for s=1:numSubjects
    P={};
    for iAnalysis=1:length(Analyses)

        participant_id=SecondLevelInput.participant_id{s};% participant_id identifier
        Analysis=['MVPA_' SecondLevelInput.(Analyses{iAnalysis}){s} '_crossnobis_xclass_cv'];

        SubjConDir=fullfile(HomeDir,participant_id,Analysis);

        File=dir(fullfile(SubjConDir ,FileIdentifier));
        %disp(participant_id)
        P=[P;fullfile(File.folder,File.name)];

    end
    %mbatch1{1}.spm.stats.factorial_design.des.t2.(['scans' num2str(iAnalysis)])= P;   
    mbatch1{1}.spm.tools.snpm.des.PairT.fsubject(s).scans = P;  
    mbatch1{1}.spm.tools.snpm.des.PairT.fsubject(s).scindex = [1 2];
    Cnt=Cnt+1;    
end

% Specify other options
mbatch1{1}.spm.tools.snpm.des.PairT.nPerm = 5000;
mbatch1{1}.spm.tools.snpm.des.PairT.vFWHM = [0 0 0];
mbatch1{1}.spm.tools.snpm.des.PairT.bVolm = 1;
mbatch1{1}.spm.tools.snpm.des.PairT.ST.ST_none = 0;
mbatch1{1}.spm.tools.snpm.des.PairT.masking.tm.tm_none = 1;
mbatch1{1}.spm.tools.snpm.des.PairT.masking.im = 1;
mbatch1{1}.spm.tools.snpm.des.PairT.masking.em = {''};
mbatch1{1}.spm.tools.snpm.des.PairT.globalc.g_omit = 1;
mbatch1{1}.spm.tools.snpm.des.PairT.globalm.gmsca.gmsca_no = 1;
mbatch1{1}.spm.tools.snpm.des.PairT.globalm.glonorm = 1;


% Compute
%-----------------------------------------------------------------------

mbatch2{1}.spm.tools.snpm.cp.snpmcfg = cellstr(fullfile(pwd,'SnPWcfg.mat'));

% Results
%-----------------------------------------------------------------------
   
mbatch3{1}.spm.tools.snpm.inference.SnPMmat = {fullfile(pwd,'SnPM.mat')};
mbatch3{1}.spm.tools.snpm.inference.Thr.Vox.VoxSig.Pth = 0.01;
mbatch3{1}.spm.tools.snpm.inference.Thr.Vox.VoxSig.FDRth = 0.05;
%mbatch3{1}.spm.tools.snpm.inference.Thr.Vox.VoxSig.FWEth = 0.05;
mbatch3{1}.spm.tools.snpm.inference.Tsign = 1; % Positive effects
%mbatch3{1}.spm.tools.snpm.inference.WriteFiltImg.WF_no = 1;
mbatch3{1}.spm.tools.snpm.inference.WriteFiltImg.name = 'SnPM_thresholded_p_FDR_05';
mbatch3{1}.spm.tools.snpm.inference.Report = 'MIPtable';


% Run spm batch
%-----------------------------------------------------------------------

% Initialise cfg_util
spm_jobman('initcfg');
		spm_jobman('run',mbatch1);
        spm_jobman('run',mbatch2);
        spm_jobman('run',mbatch3);
        

       
% % Compute Contrasts
% %----------------------------------------------------------------------- 
% 
% load('SPM.mat');
% 
% 
% % T aph > iph
% cvector=[1 -1];
% SPM.xCon=spm_FcUtil('Set','percept > acoustic','T','c',cvector',SPM.xX.xKXs);
% % 
% % T iph > aph
% cvector=[-1 1];
% SPM.xCon(end+1)=spm_FcUtil('Set','percept < acoustic','T','c',cvector',SPM.xX.xKXs);
% % 
% spm_contrasts(SPM);