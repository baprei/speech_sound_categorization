
function [Data,iTACS]=sub_get_auditory_events(participant_id,iBlock,HomeDir)

% function that extracts the relevant information from the logfiles

% get logfiles
Files=dir(fullfile(HomeDir,participant_id,'func', [participant_id '*' 'auditory_' '*.txt']));

% load Logfile of an individual block
if isempty(iBlock)==1
    iFileName=fullfile(Files(1).folder,[participant_id '_auditory_listening_events.txt']);
else
    iFileName=fullfile(Files(iBlock).folder,[participant_id '_b' num2str(iBlock) ...
        '_auditory_task_events.txt']);
end

%iFileName=fullfile(Files(iBlock).folder,Files(iBlock).name);
fid = fopen(iFileName);
indata = textscan(fid,'%d %s %d %s %d %s %d %d %d %d %d %d %d %d %d %d %d %d','headerLines',6,'Delimiter','\t');
fclose(fid);       

% get stimulation condition from logfile      
[~,~,iTACS] =textread(iFileName,'%s %s %s',5);
iTACS=iTACS{5}; % TACS condition

% Trial,Subj,Block,TACS,Stimulus_name,Response,RT,TACS_Stimulus_Phase
Data.Trial(:,1)=double(indata{1}); % Trial
Data.participant_id(:,1)=repmat(cellstr(participant_id),length(indata{1,1}),1);

if isempty(iBlock)==1
    Data.Block(:,1)=repmat(1,length(indata{1,1}),1);
else
    Data.Block(:,1)=repmat(iBlock,length(indata{1,1}),1);
end
Data.TACS(:,1)=repmat(cellstr(iTACS),length(indata{1,1}),1);
Data.Stimulus_name(:,1)=indata{6};
Data.fMRI_scan_trigger_time(:,1)=double(indata{8});
Data.Stimulus_onset_trigger(:,1)=double(indata{10});
Data.Stimulus_onset(:,1)=(double(indata{10})-double(indata{8}(1)))/1000; % Stimulus_onset_relative to scan start in secs
Data.Button=double(indata{3}); % Button
Data.Response(:,1)=indata{4};% Response
Data.RT(:,1)=double(indata{5});% RT
Data.TACS_Stimulus_phase(:,1)=double(indata{13}); % TACS_Stimulus_phase];

% convert to data table
Data=struct2table(Data);

% remove no stimulus trials
Data(strcmp(Data.Stimulus_name,'no_stimulus'),:)=[];

% rename stimuli
% LE=left ear, RE=right ear
% amb=ambiguous speech sound
Data.Stimulus_name(strcmp(Data.Stimulus_name,'base_da_chirp_left'))={'LE_highF3_RE_amb'}; 
Data.Stimulus_name(strcmp(Data.Stimulus_name,'base_ga_chirp_left'))={'LE_lowF3_RE_amb'};

Data.Stimulus_name(strcmp(Data.Stimulus_name,'daga_base1_chirp1_left'))={'LE_highF3_RE_da'};
Data.Stimulus_name(strcmp(Data.Stimulus_name,'daga_base17_chirp17_left'))={'LE_lowF3_RE_ga'};

% fix response
Data.Response(strcmp(Data.Response,'da '))={'da'};

%ButtonPressOnset
Temp=Data.Stimulus_onset+(Data.RT/1000);
Data.ButtonPressOnset(Data.Button~=0)=Temp(Data.Button~=0);

