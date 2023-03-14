function supplemental_plot_psychometry(HomeDir,Sample)

% This function aggregates the data from the initial psychometric
% assessment (pretest) that was used to determine the individual category
% boundary.

% The function uses logistic regression to fit a psychometric curve to
% individual data to determine the individual category boundaries

% The function plots the group mean and the individual psychometric curves
% used as a supplemental figure for the current manuscript

% https://doi.org/10.1101/2021.10.08.463391 

% First Version written by Basil Preisig 04-05-2022

%% parameters

SaveDir=fullfile(HomeDir,'analyses','Fig');
AxesFontSize=8;

%% get data
figure('Position', [0 0 600 850]);
%fig_position = [50 50 450 450]; % coordinates for figures

for iSubj=1:length(Sample)
    data_isubj=readtable(fullfile(HomeDir,Sample{iSubj},'psychometry',[Sample{iSubj},'_psychometry.txt']));
    
    %% loop over trials
    for iTrial=1:size(data_isubj,1)
        %% extract steps of the stimlus continuum
        Steps(iTrial,1)=sscanf(data_isubj.iStimulus{iTrial},'daga_base%f');%steps
        
        %% recode response entries into binary variable (0=ga; 1=da)
        if strcmp(data_isubj.iResponse{iTrial,1},'da') == 1 || strcmp(data_isubj.iResponse{iTrial,1},'da ') == 1 %Response category
            Response(iTrial,1) = 0; 
        elseif strcmp(data_isubj.iResponse{iTrial,1},'ga') == 1 || strcmp(data_isubj.iResponse{iTrial,1},'ga ') == 1
            Response(iTrial,1) = 1;
        elseif strcmp(data_isubj.iResponse{iTrial,1},'NaN') == 1
            Response(iTrial,1) = NaN; %category mistake
        end        
    end
    
    %% logistic fit
    [Steps,index] = sortrows(Steps); % sort steps
    Response = Response(index);% sort responses by steps
    Table = table(Response, Steps);   
    [means, ~, ~, groups] = grpstats(Response,Steps);
    data_mean(iSubj,:)=means';
    %% fit a model
    mdl = fitglm(Table, 'Response~Steps','Distribution','binomial'); 
    
    %% use that model to predict data from a full continuum
    StepsRange = [0:0.1:18]';
    PredTable = table(StepsRange);      
    PredTable.Properties.VariableNames{1} = 'Steps';
    PredResp = predict(mdl, PredTable);
    
    %% Get crossover-point value (position on the continuum)
    [val, pos] = nanmin((PredResp-0.5).^2);
    BoundPos = StepsRange(pos);
    
    %% plot individual psychometric curves and raw data
    h(iSubj)=subplot(7,4,iSubj); hold on
    plot([1:2:17],means, 'LineWidth', 1.5,'Color','k'); hold on
    plot(StepsRange, PredResp,'LineWidth', 1.5,'Color',[0.5 0.5 0.5]);
    %plot(StepsRange, PredResp, 'LineStyle',':','LineWidth', 1,'Color','r');
    line([1,19],[0.5,0.5],'Color','black','LineStyle','--','LineWidth',0.5)
    plot(BoundPos, 0.5,'x','MarkerSize',15,'Color',	'm'); hold on
    xticks([1:4:17])
    title(Sample{iSubj})
    if iSubj==1
        ylabel('proportion of /ga/ responses')
    elseif iSubj==25
        xlabel('steps from /da/ to /ga/')
    end
    
    % axes font size / font name
    set(gca,'FontSize',AxesFontSize,'FontName', 'Arial');
   
end



myLegend = legend('data participant', 'logistic fit','50% line','category boundary');

%set(h,'Units', 'pixels')
myPosition1=get(h(24),'Position');
myPosition2=get(h(27),'Position');
set(myLegend,'Position',[myPosition1(1) myPosition2(2) myPosition1(3) myPosition1(4)])


filename1=fullfile(SaveDir,['Fig_S1_individual_psychometry.tif']);
saveas(gcf,filename1)

filename2=fullfile(TransferDir,['Fig_S1_individual_psychometry.tif']);
saveas(gcf,filename2)

%% plot

% group mean (compute mean per participant per step -> compute group mean
% and sem)
GroupMean=mean(data_mean,1);
GroupSEM=std(data_mean,1)/size(Sample,1)^(1/2);

% parameters
AxesFontSize=18;

figure(),
errorbar(GroupMean,GroupSEM,'LineWidth',1.5,'Color','m')

% axes limits
xlim([0 10])
ylim([0 1])

% axes ticks
xticks([1:9])
xticklabels([1:2:17])

yticks([0:0.2:1])

% axes lables
xlabel('steps from /da/ to /ga/')
ylabel('proportion of /ga/ responses')

% axes font size / font name
set(gca,'FontSize',AxesFontSize,'FontName', 'Arial');

% save figure to disk
filename3=fullfile(SaveDir,['Fig_1A_group_psychometry.tif']);
saveas(gcf,filename3)

