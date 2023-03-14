function step4a_firstlevel_glm_listening_sS(participant_id,HomeDir)

% this function creates a firstlevel GLM of the passive listening blocks
% using SPM12

% dependencies    
    % the function calls sub_get_auditory_events.m

    % the script relies on SPM12 subfunctions 
    % install SPM12 (http://www.fil.ion.ucl.ac.uk/spm).

% written by Basil Preisig 09-02-2021


%% set parameters

DataDir=fullfile(HomeDir,participant_id,'func'); % input data directory

% check whether output data directory exists, if not, create new one
OutDir=fullfile(HomeDir,participant_id,'firstlevel_glm_listening_sS');
if exist(OutDir)==0
    mkdir(fullfile(HomeDir,participant_id),'firstlevel_glm_listening_sS')
else
    delete(fullfile(OutDir,'*'))
end
cd(OutDir)

% active blocks
RT=2; % Repetition time (i.e, TR) in seconds
TA=1; % Time of acquisition (in seconds)
nVolsPerBlock=336;

Blocks=1;
nBlocks=length(Blocks);

nVols=nVolsPerBlock*nBlocks;


%% Create SPM design Matrix

clear SPM
for iBlock=1:length(Blocks) %Loop over runs
    
    %load the movement parameters for the relevant run/block:
    MPfile=dir(fullfile(DataDir,['rp','_',participant_id, ...
        '_','auditory_listening_bold.txt']));
    movements=load(fullfile(DataDir,MPfile.name));
    name_regress = {'x_trans','y_trans','z_trans','x_rot','y_rot','z_rot'};
    
   %% get logfile data
   [TrialData]=sub_get_auditory_events(participant_id,[],HomeDir);
   
   onsets{1}=TrialData.Stimulus_onset';
   names={'all_auditory'};
   %onsets{2}=TrialData.ButtonPressOnset(TrialData.Button~=0)';
   %names={'all_auditory','ButtonPress'};
     
   %% Get nii files
    flist{iBlock} = spm_select('ExtFPList',DataDir,['^swu',participant_id, ...
        '_auditory_listening_bold','.*'],[1 inf]);
    
%% Now, looping over conditions within the run:
    condcount=0; %Condcount can be redundant but allows flexible indexing
    for cond=1:length(names)
        condcount=condcount+1;
        %%%Structure for the SPM design matrix uses these fields:
        SPM.Sess(iBlock).U(condcount).name=names(cond);
        if isfield(SPM.Sess(iBlock).U(condcount),'ons')==0
            SPM.Sess(iBlock).U(condcount).ons=[];
        end
        
        Onsets=cell2mat(onsets(cond));
        if ~isempty(Onsets)
            SPM.Sess(iBlock).U(condcount).ons=Onsets;
            SPM.Sess(iBlock).U(condcount).dur=repmat(0.250,1,length(SPM.Sess(iBlock).U(condcount).ons));% or set =0 for event-related:       SPM.iBlock(iBlock).U(cond).dur=0;
        else
            SPM.Sess(iBlock).U(condcount).ons=nVolsPerBlock*RT;
            SPM.Sess(iBlock).U(condcount).dur=0;
        end
        
        SPM.Sess(iBlock).U(condcount).P(1).name = 'none';%no parametric modulator
                
    end %end conds loop
        
    % add motion parameters as covariates
    SPM.Sess(iBlock).C.C = movements;
    SPM.Sess(iBlock).C.name = name_regress;
    SPM.nscan(iBlock) = size(flist{iBlock},1); %Specify number of scans per iBlock
    clear names onsets
end %end iBlock loops

SPM.xY.P=strvcat(flist); %Concatenate all the files into the design matrix. For some reason these all go together and not by session
SPM.xY.RT=RT; %TR of acquisitions
 
 
%% basis functions and timing parameters
%---------------------------------------------------------------------------
% OPTIONS:'hrf'
%         'hrf (with time derivative)'
%         'hrf (with time and dispersion derivat0ives)'
%         'Fourier set'
%         'Fourier set (Hanning)'
%         'Gamma functions'
%         'Finite Impulse Response'
%---------------------------------------------------------------------------
SPM.xBF.name       = 'hrf';
SPM.xBF.order      = 1; % order of basis set
SPM.xBF.T          = 66; % usually, number of slices, but for sparse design let's do 8*TA:
SPM.xBF.T0         = round(((TA/2)/RT)*SPM.xBF.T); %the middle slice of the
SPM.xBF.UNITS      = 'secs';% OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;% OPTIONS: 1|2 = order of convolution
 
%% global normalization: OPTIONS:'Scaling'|'None'
%---------------------------------------------------------------------------
SPM.xGX.iGXcalc    = 'None';
 
 
%% low frequency confound: high-pass cutoff (secs) [Inf = no
% filtering] default is 128
%---------------------------------------------------------------------------
 
SPM.xX.K.HParam = nVols;
 
%% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%-----------------------------------------------6:------------------------
SPM.xVi.form       = 'AR(1) + w';
 
%% Configure design matrix
%===========================================================================
SPM = spm_fmri_spm_ui(SPM);
 
%% Estimate parameters
%===========================================================================
SPM = spm_spm(SPM);
 
%% Contrasts
%===========================================================================

% effects of interest
cvector=[eye(length(SPM.xX.name)-(length(name_regress)+nBlocks)), ...
    zeros(length(SPM.xX.name)-(length(name_regress)+nBlocks),length(name_regress)+nBlocks)];
SPM.xCon = spm_FcUtil('Set','effects of interest','F','c',cvector',SPM.xX.xKXs);

% Sound>baseline
cvector=zeros(SPM.xBF.order,length(SPM.xX.name));
cvector(find(contains(SPM.xX.name,'all_auditory')))=1;
SPM.xCon(end+1) = spm_FcUtil('Set',['Sound>baseline'],'T','c',cvector',SPM.xX.xKXs);


spm_contrasts(SPM);

