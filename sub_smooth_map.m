function sub_smooth_map(participant_id,HomeDir,AnalysisName,MapType,smoothkern)

% This function smoothes the Map Volume (.nii)

% Inputs:
%   -participant_id
%   -Home directory (HomeDir)
%   -AnalysisName of the decoding analysis
%   -MapType (AUC minus chance, accuracy minus chance ...)
%   -smoothkern (smoothing kernel)

% Output:
%   -normalized 3D brain volume (.nii)

% Basil Preisig 05-03-2021


%% set parameters

AnalysisDir=fullfile(HomeDir,participant_id,AnalysisName);


%% spm batch

if exist(AnalysisDir, 'dir') ~= 0

    MapFile=dir(fullfile(AnalysisDir,MapType));
    mbatch{1}.spm.spatial.smooth.data = cellstr(fullfile(MapFile.folder, MapFile.name));
    mbatch{1}.spm.spatial.smooth.fwhm = [smoothkern smoothkern smoothkern];
    mbatch{1}.spm.spatial.smooth.dtype = 0;
    mbatch{1}.spm.spatial.smooth.im = 0;
    mbatch{1}.spm.spatial.smooth.prefix = 's';% 

    spm_jobman('run',mbatch);
    clear mbatch
    
end


    
