function step3b_MVPA_percept_crossnobis_xclass_cv(Sample,HomeDir,Stimulus,roi_name,glm_name)

% This function uses a leave-one-run-out (LORO) cross-validation design to 
% compute the crossnobis distance between the trials with (da vs ga) responses
% that were averaged a the single run level. 
% using the decoding toolbox (TDT)

% Basil Preisig 03-03-2021

cfg_group={};misc_group={};
for iSubj=1:length(Sample)
    %% set parameters
    participant_id=Sample{iSubj}; % get participant id

    % Set defaults
    cfg = decoding_defaults;

    % Set the analysis that should be performed (default is 'searchlight')
    cfg.analysis = 'searchlight';

    % Set the filepath where your SPM.mat, contrast images, and beta files are
    % store (firstlevel directory
    beta_loc = fullfile(HomeDir,participant_id,glm_name); % testset

    % Set the filename of your brain mask (or your ROI masks as cell matrix) 
    MaskDir=beta_loc;
    cfg.files.mask = fullfile(MaskDir,roi_name);

    % libsvm
    %cfg.results.output = {'AUC_minus_chance','SVM_weights'}; % Hint: If you like to know the SL size at around a voxel, add 'ninputdim';
    cfg.results.output = 'other_meandist';
    %cfg.results.output = ; % if you really want the weights, use 'SVM_weights' 'SVM_pattern
    %cfg.decoding.method = 'classification_kernel';

    % These parameters carry out the multivariate noise normalization using the
    % residuals
    cfg.scale.method = 'cov'; % we scale by noise covariance
    cfg.scale.estimation = 'separate'; % we scale all data for each run separately while iterating across searchlight spheres
    cfg.scale.shrinkage = 'lw2'; % Ledoit-Wolf shrinkage retaining variances

    % set everything to calculate (dis)similarity estimates
    cfg.decoding.software = 'distance'; % the difference to 'similarity' is that this averages across data with the same label
    cfg.decoding.method = 'classification'; % this is more a placeholder
    cfg.decoding.train.classification.model_parameters = 'cveuclidean'; % cross-validated Euclidean after noise normalization

    % The crossnobis distance is identical to the cross-validated Euclidean
    % distance after prewhitening (multivariate noise normalization). It has
    % been shown that a good estimate for the multivariate noise is provided
    % by the residuals of the first-level model, in addition with Ledoit-Wolf
    % regularization. Here we calculate those residuals. If you have them
    % available already, you can load them into misc.residuals using only the
    % voxels from cfg.files.mask
    [misc.residuals,cfg.files.residuals.chunk] = residuals_from_spm(fullfile(beta_loc,'SPM.mat'),cfg.files.mask); % this only needs to be run once and can be saved and loaded 
    misc_group=[misc_group;misc];

    % parameters for libsvm (linear SV classification, cost = 1, no screen output)
    %cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; 

    % searchlight
%     cfg.searchlight.unit = 'mm';
%     cfg.searchlight.radius = 8; % this will yield a searchlight radius of 8mm.
%     cfg.searchlight.spherical = 1;
%     cfg.verbose = 2; % set 1, if you want all information to be printed on screen

    % Decide whether you want to see the searchlight/ROI/... during decoding
    %cfg.plot_selected_voxels = 100; % 0: no plotting, 1: every step, 2: every second step, 100: every hundredth step...
    cfg.plot_selected_voxels =0;

    % Overwrite previous
    cfg.results.overwrite = 1;


    %% specify the decoding design

    % An example

    % In a design, there are several matrices, one for training, one for test,
    % and one for the labels that are used (there is also a set vector which we
    % don't need right now). In each matrix, a column represents one decoding 
    % step (e.g. cross-validation run) while a row represents one sample (i.e.
    % brain image). The decoding analysis will later iterate over the columns 
    % of this design matrix. For example, you might start off with training on 
    % the first 5 runs and leaving out the 6th run. Then the columns of the 
    % design matrix will look as follows (we also add the run numbers and file
    % names to make it clearer):
    % cfg.design.train cfg.design.test cfg.design.label cfg.files.chunk  cfg.files.name
    %        1                0              -1               1         ..\beta_0001.img
    %        1                0               1               1         ..\beta_0002.img
    %        1                0              -1               2         ..\beta_0009.img 
    %        1                0               1               2         ..\beta_0010.img 
    %        1                0              -1               3         ..\beta_0017.img 
    %        1                0               1               3         ..\beta_0018.img 
    %        1                0              -1               4         ..\beta_0025.img 
    %        1                0               1               4         ..\beta_0026.img 
    %        1                0              -1               5         ..\beta_0033.img 
    %        1                0               1               5         ..\beta_0034.img 
    %        0                1              -1               6         ..\beta_0041.img 
    %        0                1               1               6         ..\beta_0042.img 

    %% get betas
    % 
    % load(fullfile(beta_loc,'SPM.mat')) % load SPM.mat
    % 
    % reg_names = {SPM.xCon.name};
    % idx_reg_stimuli=find(contains(reg_names(1,:),Stimulus_subset));
    % reg_stimuli=reg_names(1,idx_reg_stimuli);
    % labelnames=reg_stimuli;

    % The following function extracts all beta names and corresponding run
    % numbers from the SPM.mat
    regressor_names = design_from_spm(beta_loc);
    idx_reg_stimuli=find((contains(regressor_names(1,:),'da_DA') | ...
        contains(regressor_names(1,:),'ga_GA') | ...
        contains(regressor_names(1,:),['LE_' Stimulus '_RE_amb'])) & ...
        ~contains(regressor_names(1,:),'NAN'));

    % idx_reg_stimuli=find(contains(regressor_names(1,:),Stimulus_subset) & ...
    %    ~contains(regressor_names(1,:),'NAN'));

    reg_stimuli=regressor_names(:,idx_reg_stimuli);
    labelnames=reg_stimuli(3,:);

    % check if each stimulus set is equally large
    % define labels according to the stimulus class
    labels(contains(labelnames,'DA'))=1;
    labels(contains(labelnames,'GA'))=2;

    % file names
    Beta=dir(fullfile(beta_loc,'beta*.nii'));

    for i=1:length(labelnames)
        idx=find(strcmp(regressor_names(3,:),labelnames{i}));
        cfg.files.name{i,1}=fullfile(Beta(idx).folder,Beta(idx).name);
    end

    % add files
    cfg.files.label=labels';

    % extract run number from file names
    RunIdx=regexp(labelnames,'\d+(\.)?(\d+)?','match'); % extract all number in cellstr arrary
    RunIdx = cat(1,RunIdx{:}); % reshape cellstr array

    cfg.files.chunk=str2num(cell2mat(RunIdx(:,1)));%cell2mat(reg_numbers(sort_idx)');
    cfg.files.set=ones(length(labels),1); 

    cfg.files.xclass(contains(reg_stimuli(1,:),'da'))=1;
    cfg.files.xclass(contains(reg_stimuli(1,:),'ga'))=1;
    cfg.files.xclass(contains(reg_stimuli(1,:),'amb'))=2;
    % Extract all information for the cfg.files structure (labels will be [1 -1] )
    %cfg = decoding_describe_data(cfg,labelnames,labels,reg_stimuli,beta_loc);

    cfg.files.twoway=0; % training on 1, testing on 2 (if set to ==1, then testing and training in both directions

    cfg.design = make_design_xclass_cv(cfg);

    % This creates a design in which cross-validation is done between the distance estimates
    %cfg.design = make_design_similarity_cv(cfg);

    %% plot
    % if you want to see your design matrix, use
    %display_design(cfg);
    %plot_design(cfg)
    % cfg.design.unbalanced_data = 'ok';

    %% Set the output directory where data will be saved, e.g. 'c:\exp\results\buttonpress'
    cfg.results.dir = fullfile(HomeDir,participant_id,['MVPA_percept_' Stimulus '_crossnobis_xclass_cv']);
    
    
    cfg.results.write = 1; % no results are written to disk

    if exist(cfg.results.dir)==0
        mkdir(cfg.results.dir)
    end

    cfg_group=[cfg_group; cfg];
end

%% Fifth, run the decoding analysis

% Run decoding
parfor iSubj=1:size(Sample,1)  
    decoding(cfg_group{iSubj},[],misc_group{iSubj});
end
