function [SecondLevelInput]=step3e_secondlevel_input(HomeDir,Sample,SmallestnTrialsPerRun,minTrialsPerRun)

% This function determines, which participants enter the 2nd level analysis
% based on their minimal numbers of /ga/ responses for highF3 trials and
% /da/ responses for lowF3 trials per run per participants for ambiguous trials

% if participants could contribute enough trials for both analyses, the
% average image of these analyses will be computed calling the sub_function
% sub_compute_average_image()

% written by Basil Preisig 12-05-2021

Cnt=1;
for iSubj=1:length(Sample)
     
    % check nTrials
    if SmallestnTrialsPerRun.LE_highF3_RE_amb_GA(iSubj) >= minTrialsPerRun &&  ...
            SmallestnTrialsPerRun.LE_lowF3_RE_amb_DA(iSubj) >= minTrialsPerRun
        
        SecondLevelInput.participant_id{Cnt,1}=Sample{iSubj};        
        SecondLevelInput.percept{Cnt,1}='percept_mean';
        SecondLevelInput.acoustic{Cnt,1}='acoustic_mean';

        Condition={'percept','acoustic'};
        
        %% compute average image
        % if participants could contribute enough trials for both analyses, the
        % average image of these analyses will be computed calling the sub function
        % sub_compute_average_image()
        addpath(fullfile(HomeDir,'code'))
        sub_compute_average_image(HomeDir,Sample{iSubj},Condition)
        Cnt=Cnt+1;

    elseif SmallestnTrialsPerRun.LE_highF3_RE_amb_GA(iSubj) >= minTrialsPerRun &&  ...
            SmallestnTrialsPerRun.LE_lowF3_RE_amb_DA(iSubj) < minTrialsPerRun
        
        SecondLevelInput.participant_id{Cnt,1}=Sample{iSubj}; 
        SecondLevelInput.percept{Cnt,1}='percept_highF3';
        SecondLevelInput.acoustic{Cnt,1}='acoustic_GA';
        Cnt=Cnt+1;

    elseif SmallestnTrialsPerRun.LE_highF3_RE_amb_GA(iSubj) < minTrialsPerRun &&  ...
            SmallestnTrialsPerRun.LE_lowF3_RE_amb_DA(iSubj) >= minTrialsPerRun
        
        SecondLevelInput.participant_id{Cnt,1}=Sample{iSubj}; 
        SecondLevelInput.percept{Cnt,1}='percept_lowF3';
        SecondLevelInput.acoustic{Cnt,1}='acoustic_DA';
        Cnt=Cnt+1;
        
    end
end

SecondLevelInput=struct2table(SecondLevelInput);