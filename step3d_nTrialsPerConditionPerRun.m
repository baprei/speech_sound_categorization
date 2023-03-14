function [data_long,data_min_wide,data_sum_wide]=step3d_nTrialsPerConditionPerRun(HomeDir)

% This function calculates the minimal number of /da/ responses for lowF3
% trials and the minimal number of /ga/ responses for highF3 trials per run
% per participants for ambiguous trials

% First Version: 27-04-2021 Basil Preisig

%% set parameters


t=readtable(fullfile(HomeDir,'analyses','behavioral_trial_data.txt'));

% reduce to sham
t=t(strcmp(t.TACS,'Sham'),:);

Subj=unique(t.participant_id);
Blocks=unique(t.Block);

Stimuli={'LE_highF3_RE_amb','LE_lowF3_RE_amb','LE_highF3_RE_da','LE_highF3_RE_ga'};
Response={'ga','da','ga','da'};

Cnt1=1;Cnt2=1;
for iSubj=1:length(Subj)
    
    subset=t(strcmp(t.participant_id,Subj{iSubj}),:);
    
    for iStimulus=1:length(Stimuli)
        %for iResponse=1:length(Response)
        
        Stimulus_Response=[Stimuli{iStimulus} '_' upper(Response{iStimulus})];
        
            for iBlock=1:length(Blocks)
                
                trial_idx=find(strcmp(t.participant_id,Subj{iSubj}) & ...
                    strcmp(t.Stimulus_name,Stimuli{iStimulus}) & ...
                        strcmp(t.Response,Response{iStimulus}) & t.Block==Blocks(iBlock));
                    
                data_long.participant_id{Cnt1,1}=Subj{iSubj};
                data_long.Block(Cnt1,1)=iBlock;
                data_long.trial{Cnt1,1}=Stimulus_Response;
                data_long.n_trial(Cnt1,1)=numel(trial_idx);
                
                Cnt1=Cnt1+1;
                
            end
            
            idx=find(strcmp(data_long.participant_id,Subj{iSubj}) & ...
                strcmp(data_long.trial,Stimulus_Response));
            subset=data_long.n_trial(idx,:);
            
            data_min_wide.participant_id{iSubj,1}=Subj{iSubj};
            data_min_wide.(Stimulus_Response)(iSubj,1)=min(data_long.n_trial(idx,:)); % smallest count per Stimulus response combination per Block
            
            data_sum_wide.participant_id{iSubj,1}=Subj{iSubj};
            data_sum_wide.(Stimulus_Response)(iSubj,1)=sum(data_long.n_trial(idx,:)); % smallest count per Stimulus response combination per Block
                      
        %end
    end
       
end

data_min_wide=struct2table(data_min_wide);
data_sum_wide=struct2table(data_sum_wide);
data_long=struct2table(data_long);


writetable(data_sum_wide,fullfile(HomeDir,'analyses','summary_table_resp_trials.txt'));

