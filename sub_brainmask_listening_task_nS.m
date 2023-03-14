function sub_brainmask_listening_task_nS(participant_id, HomeDir,glm_name)

% This function conmputes a brainmask which includes the voxels that are
% shared between listening and task blocks

% inputs
%   -participant_id
%   -HomeDir
%   -glm_name

% First Version: Basil Preisig 16-12-2021

%% define parameters

%FileName1=fullfile(HomeDir,participant_id,glm_name{1}); % filename of the first mask
%FileName2=fullfile(HomeDir,participant_id,glm_name{2}); % filename of the 2nd mask

for iglm=1:length(glm_name)
    MASK(:,:,:,iglm)=spm_read_vols(spm_vol(fullfile(HomeDir,participant_id,glm_name{iglm},'mask.nii')));
end

%% compute comon mask

MASK_mean=mean(MASK(:,:,:,:),4);

Volume=nan(size(MASK_mean)); 
Volume(MASK_mean==1)=1; % find voxels that are shared between masks

%% write mask to glm folders

for iglm=1:length(glm_name)
    V=spm_vol(fullfile(HomeDir,participant_id,glm_name{iglm},'mask.nii'));
    V.fname=fullfile(HomeDir,participant_id,glm_name{iglm},'brainmask.nii');
    spm_write_vol(V,Volume); % write to volume
end


