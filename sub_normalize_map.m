function sub_normalize_map(participant_id,HomeDir,AnalysisName,MapType)

% This function normalizes the Map Volume (.nii)

% Inputs:
%   -participant_id
%   -Home directory (HomeDir)
%   -AnalysisName of the decoding analysis
%   -MapType (AUC minus chance, accuracy minus chance ...)

% Output:
%   -normalized 3D brain volume (.nii)

% Basil Preisig 05-03-2021


%% set parameters

AnalysisDir=fullfile(HomeDir,participant_id,AnalysisName);
DefFieldDir=fullfile(HomeDir,participant_id,'anat');

if exist(AnalysisDir, 'dir') ~= 0

    %% spm batch

    mbatch{1}.spm.spatial.normalise.write.subj.def = cellstr(fullfile(DefFieldDir,['y','_',participant_id,'_','T1.nii']));
    mbatch{1}.spm.spatial.normalise.write.subj.resample = cellstr(fullfile(AnalysisDir,MapType));
    mbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
    mbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    mbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    mbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

    spm_jobman('run',mbatch);

end
