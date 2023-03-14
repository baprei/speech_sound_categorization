function sub_compute_average_image(HomeDir,participant_id,Condition)

% This function computes a average image for acoustic and perceptual
% representaitons in participants who contributed enough trials to decode
% within high and lowF3 and GA and DA response trials 

% First version: written by Basil Preisig 12-05-2021

%% load distance maps

for iCon=1:length(Condition)
    Analyses=dir(fullfile(HomeDir,participant_id));    
    Analyses=Analyses(contains({Analyses.name},['MVPA_' Condition{iCon}]) & ...
        ~contains({Analyses.name},'mean'));

    for i=1:length(Analyses)
        iMap=dir(fullfile(Analyses(i).folder,Analyses(i).name,'msw*'));
        DistanceMaps(:,:,:,i,iCon)=spm_read_vols(spm_vol(fullfile(iMap.folder,iMap.name)));        
    end
end


for iCon=1:length(Condition)
    
    map_meandist=mean(DistanceMaps(:,:,:,:,iCon),4);
    
    % Output folder name
    DirName=['MVPA_' Condition{iCon} '_mean' '_crossnobis_xclass_cv'];
    OutputFolder=fullfile(HomeDir,participant_id,DirName);
    if ~exist(OutputFolder,'dir')
        mkdir(fullfile(HomeDir,participant_id),DirName);
    end
    %FileName='swres_other_meandist.nii';
    V=spm_vol(fullfile(iMap.folder,iMap.name)); % load any v struct    
    V.fname=fullfile(OutputFolder,'mswres_other_meandist.nii'); % change name v struct

    spm_write_vol(V,map_meandist);

end