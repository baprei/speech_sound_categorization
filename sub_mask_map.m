function sub_mask_map(participant_id,HomeDir,AnalysisName,MapType,AuditoryMask,Prefix)

% This function uses the normalized auditory mask to mask out voxels
% outside the brain

% Inputs:
%   -participant_id
%   -Home directory (HomeDir)
%   -AnalysisName of the decoding analysis
%   -MapType (AUC minus chance, accuracy minus chance ...)
%   -AuditoryMask (analyses/auditory_mask/sound_vs_baseline_p001_unc.nii,
%   -Prefix for output image
%   see step2a_create_fistlevel_auditory_mask.m)

%% set parameters

AnalysisDir=fullfile(HomeDir,participant_id,AnalysisName);

if exist(AnalysisDir, 'dir') ~= 0

    %% get Map & Mask File

    MapFile=dir(fullfile(AnalysisDir,MapType));
    V=spm_vol(fullfile(MapFile.folder,MapFile.name));
    Map=spm_read_vols(spm_vol(fullfile(MapFile.folder,MapFile.name)));

    Mask=spm_read_vols(spm_vol(AuditoryMask));

    %% write to volume
    Volume=nan(size(Map));    
    %Volume(~isnan(Mask))=Map(~isnan(Mask));
    Volume(Mask==1)=Map(Mask==1);
    
    % without changing the name in the V struct / this will overwrite the
    % unmasked Map File
    V.fname=fullfile(AnalysisDir,[Prefix MapFile.name]);
    spm_write_vol(V,Volume);

end

