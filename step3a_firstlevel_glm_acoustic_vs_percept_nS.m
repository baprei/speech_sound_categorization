function step3a_firstlevel_glm_acoustic_vs_percept_nS(participant_id,HomeDir)
% 
% this function computes a firstlevel GLM for each stimulus (high vs low F3  
% response (ga vs da) combination (percept & acoustics within a single
% stimulus or response)
% using SPM12

% this function uses preprocessed fMRI data that can be downloaded here
% (https://doi.org/10.34973/dt33-sj34)

% dependencies    
    % the function calls sub_get_auditory_events.m

    % the script relies on SPM12 subfunctions 
    % install SPM12 (http://www.fil.ion.ucl.ac.uk/spm).

% written by Basil Preisig 24-02-2021

 
%% set parameters

DataDir=fullfile(HomeDir,participant_id,'func'); % input data directory

% check whether output data directory exists, if not, create new one
OutDir=fullfile(HomeDir,participant_id,'firstlevel_glm_acoustic_vs_percept_nS');
if exist(OutDir)==0
    mkdir(fullfile(HomeDir,participant_id),'firstlevel_glm_acoustic_vs_percept_nS')
else
    delete(fullfile(OutDir,'*'))
end
cd(OutDir)

% active blocks
RT=3; % Repetition time (i.e, TR) in seconds
TA=1; % Time of acquisition (in seconds)
nVolsPerBlock=128;

%shamBlocks=[3,5,7,9];
Blocks=[1:4];
nBlocks=length(Blocks);

nVols=nVolsPerBlock*nBlocks;


%% Create SPM design Matrix

clear SPM

for iBlock=1:length(Blocks) %Loop over runs
    
    %load the movement parameters for the relevant run/block:
    MPfile=dir(fullfile(DataDir,['rp','_',participant_id,'_','b',num2str(iBlock), ...
        '_','auditory_task_bold.txt']));
    movements=load(fullfile(DataDir,MPfile.name));
    name_regress = {'x_trans','y_trans','z_trans','x_rot','y_rot','z_rot'};
   

    
   %% get logfile data
   [TrialData,~]=sub_get_auditory_events(participant_id,iBlock,fullfile(HomeDir));
   
   Stimuli=unique(TrialData.Stimulus_name);
   Response=unique(TrialData.Response);
   
   ShamRampTrials=[3,4,125,126];
   [~,Trials]=intersect(TrialData.Trial,ShamRampTrials);
   TrialData.ShamRamp(:,1)=zeros(size(TrialData,1),1);
   TrialData.ShamRamp(Trials,1)=1;
   
   Cnt=1;
   for i=1:length(Stimuli)
       for j=1:length(Response)
           names{Cnt}=[Stimuli{i} '_' upper(Response{j})];
           onsets{Cnt}=TrialData.Stimulus_onset(contains(TrialData.Stimulus_name,Stimuli{i}) & ...
               contains(TrialData.Response,Response{j}) & TrialData.ShamRamp==0);
           Cnt=Cnt+1;
       end
   end
   
%    for i=1:size(TrialData,1)
%        if TrialData.Trial(i)==3 || TrialData.Trial(i)==4 || TrialData.Trial(i)==125 || TrialData.Trial(i)==126 % sham ramp trials
%            names{i}=[TrialData.Stimulus_name{i} '_' num2str(TrialData.Trial(i)) '_' ...
%             upper(TrialData.Response{i}),'_Ramp'];
%        else
%            names{i}=[TrialData.Stimulus_name{i} '_' num2str(TrialData.Trial(i)) '_' ...
%                upper(TrialData.Response{i})];
%        end
%        onsets{i}=TrialData.Stimulus_onset(i);
%    end

   names{end+1}='ShamRampTrials';
   onsets{end+1}=TrialData.Stimulus_onset(TrialData.ShamRamp==1);
   
   names{end+1}='ButtonPress';
   onsets{end+1}=TrialData.ButtonPressOnset(TrialData.Button~=0);
   IncludeConditions=[1:length(names)];
   
   %% Get nii files
    flist{iBlock} = spm_select('ExtFPList',DataDir,['^u',participant_id,'_','b', ...
    num2str(iBlock),'.*'],[1 inf]);
    
    %% Now, looping over conditions within the run:
    condcount=0; %Condcount can be redundant but allows flexible indexing
    for cond=IncludeConditions %length(names)
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

% a spmT contrast for each individual stimulus response combination
Stimuli={'LE_highF3_RE_amb_DA','LE_lowF3_RE_amb_DA','LE_highF3_RE_da_DA','LE_lowF3_RE_ga_DA', ...
    'LE_highF3_RE_amb_GA','LE_lowF3_RE_amb_GA','LE_highF3_RE_da_GA','LE_lowF3_RE_ga_GA'};

for iBlock=1:length(Blocks)
    for iStim=1:length(Stimuli)
        Subset=find(contains(SPM.xX.name,['Sn(',num2str(iBlock),') ',Stimuli{iStim}]) & ...
            ~contains(SPM.xX.name,'Ramp'));
        Cnt=1;
        for j=1:length(Subset)        
            cvector=zeros(SPM.xBF.order,length(SPM.xX.name));       
            for B=1:SPM.xBF.order
                Indices=Subset(j);
                cvector(B,Indices)=1;       
               if isfield(SPM.xCon,'name')~=1       
                SPM.xCon = spm_FcUtil('Set',SPM.xX.name{Subset(j)},'T','c',cvector(B,:)',SPM.xX.xKXs);
               else
                SPM.xCon(end+1) = spm_FcUtil('Set',SPM.xX.name{Subset(j)},'T','c',cvector(B,:)',SPM.xX.xKXs);
               end
            end
            if SPM.xBF.order>1
                eval(sprintf('%s_All=cvector',CN{:}));
                SPM.xCon(end+1) = spm_FcUtil('Set',SPM.xX.name{Subset(j)},'T','c',cvector(B,:)',SPM.xX.xKXs);
            end   
            Cnt=Cnt+1;
        end
    end
end

% % a spmT contrast for individual response combination
% Stimuli={'amb_DA','amb_GA'};
% 
% for iBlock=1:length(Blocks)
%     for iStim=1:length(Stimuli)
%         Subset=find(contains(SPM.xX.name,['Sn(',num2str(iBlock),') ']) & ...
%             contains(SPM.xX.name,Stimuli{iStim}) & ...
%             ~contains(SPM.xX.name,'Ramp'));
%         Cnt=1;
%         %for j=1:length(Subset)        
%             cvector=zeros(SPM.xBF.order,length(SPM.xX.name));       
%             for B=1:SPM.xBF.order
%                 Indices=Subset;
%                 cvector(B,Indices)=1;       
%                if isfield(SPM.xCon,'name')~=1       
%                 SPM.xCon = spm_FcUtil('Set',['Sn(',num2str(iBlock),') ' ...
%                     'percept_' Stimuli{iStim}],'T','c',cvector(B,:)',SPM.xX.xKXs);
%                else
%                 SPM.xCon(end+1) = spm_FcUtil('Set',['Sn(',num2str(iBlock),') ' ...
%                     'percept_' Stimuli{iStim}],'T','c',cvector(B,:)',SPM.xX.xKXs);
%                end
%             end
%             if SPM.xBF.order>1
%                 eval(sprintf('%s_All=cvector',CN{:}));
%                 SPM.xCon(end+1) = spm_FcUtil('Set',['Sn(',num2str(iBlock),') ' ...
%                     'percept_' Stimuli{iStim}],'T','c',cvector(B,:)',SPM.xX.xKXs);
%             end   
%             Cnt=Cnt+1;
%         %end
%     end
% end
% 
% % a spmT contrast for acoustic stimulus presentations
% Stimuli={'LE_highF3_RE_amb','LE_lowF3_RE_amb'};
% 
% for iBlock=1:length(Blocks)
%     for iStim=1:length(Stimuli)
%         Subset=find(contains(SPM.xX.name,['Sn(',num2str(iBlock),') ']) & ...
%             contains(SPM.xX.name,Stimuli{iStim}) & ...
%             ~contains(SPM.xX.name,'Ramp'));
%         Cnt=1;
%         %for j=1:length(Subset)        
%             cvector=zeros(SPM.xBF.order,length(SPM.xX.name));       
%             for B=1:SPM.xBF.order
%                 Indices=Subset;
%                 cvector(B,Indices)=1;       
%                if isfield(SPM.xCon,'name')~=1       
%                 SPM.xCon = spm_FcUtil('Set',['Sn(',num2str(iBlock),') ' ...
%                     'acoustics_' Stimuli{iStim}],'T','c',cvector(B,:)',SPM.xX.xKXs);
%                else
%                 SPM.xCon(end+1) = spm_FcUtil('Set',['Sn(',num2str(iBlock),') ' ...
%                     'acoustics_' Stimuli{iStim}],'T','c',cvector(B,:)',SPM.xX.xKXs);
%                end
%             end
%             if SPM.xBF.order>1
%                 eval(sprintf('%s_All=cvector',CN{:}));
%                 SPM.xCon(end+1) = spm_FcUtil('Set',['Sn(',num2str(iBlock),') ' ...
%                     'acoustics_' Stimuli{iStim}],'T','c',cvector(B,:)',SPM.xX.xKXs);
%             end   
%             Cnt=Cnt+1;
%         %end
%     end
% end


%% sound > baseline
cvector=zeros(SPM.xBF.order,length(SPM.xX.name));
cvector(find(~contains(SPM.xX.name,'ButtonPress') & ~contains(SPM.xX.name,'constant') ...
    & ~contains(SPM.xX.name,'x_trans') & ~contains(SPM.xX.name,'y_trans') ...
    & ~contains(SPM.xX.name,'z_trans') & ~contains(SPM.xX.name,'x_rot') ...
    & ~contains(SPM.xX.name,'y_rot') & ~contains(SPM.xX.name,'z_rot')))=1;
SPM.xCon(end+1) = spm_FcUtil('Set',['Sound > baseline'],'T','c',cvector',SPM.xX.xKXs);



spm_contrasts(SPM);

