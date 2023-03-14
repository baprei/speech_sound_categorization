function supplemental_plot_behavioral_data(HomeDir,Sample)

% This function plots the behavioral mean data recorded during binaural
% integration (Fig 1C) and unambiguous control trials (Fig 1D)

% First Version written by Basil Preisig: 04-05-2022

%% load data

data=readtable(fullfile(HomeDir,'analyses','behavioral_data_mean.txt'));
data(strcmp(data.participant_id,'sub-028'),:)=[];% exclude sub-028;
%% plot data

% dependent variable: proportion of /ga/ responses:

% plot parameters:
AxesFontSize=18;
MarkerSizeDataPoint=5.5;
XLimits=[0.5 2.5];
YLimits=[-0.1 1.1];

TransferDir='/media/Transfer/forBasil/1a_fMRI_binaural_integration/Fig';

% LE_ColorMap=[[0 1 1];[0 1 0]];
% RE_ColorMap=[[1 0 1];[1 0 1]];

ColorMap_Bar=[[1 1 1];[0.5 0.5 0.5]];
ColorMap_DataDots=[[0 1 1];[0 1 0]];

Conditions={'Binaural integration','Unambiguous control stimuli'};



for iCon=1:length(Conditions)
    figure('Position', [0 0 400 600]);
    %% assign data
    if iCon ==1
        Response(:,1)=data.LE_highF3_RE_amb_GA;
        Response(:,2)=data.LE_lowF3_RE_amb_GA;
        ColorMap=ColorMap_DataDots;
        XTickLabels={'highF3','lowF3'};
        
    elseif iCon ==2
        Response(:,1)=data.LE_highF3_RE_da_GA;
        Response(:,2)=data.LE_lowF3_RE_ga_GA;
        ColorMap=ColorMap_Bar;
        xlabel('RE stimulus')
        XTickLabels={'/da/','/ga/'};
    end
    
    for iLevel=1:2
        %% compute mean and sem
        y=mean(Response(:,iLevel));
        y_sem=std(Response(:,iLevel))/size(Sample,1)^(1/2);

        %% plot
        %subplot(1,2,iCon)

        bar(iLevel,y,'FaceColor',ColorMap_Bar(iLevel,:));hold on;
        errorbar(iLevel,y,y_sem,'Color',[0 0 0])

        %% plot individual datapoints
        rng(1,'twister')
        x_ind=(0.25).*rand(length(Response),1) + (iLevel-0.15);

        for i=1:length(x_ind)
            %LightGrey=[0.8 0.8 0.8];
            h=plot(x_ind(i),Response(i,iLevel),'LineStyle','none','color',[0 0 0],'Marker','o','MarkerSize',MarkerSizeDataPoint, ...
                'MarkerFaceColor', ColorMap_DataDots(iLevel,:)); alpha(.2)
            hold on
            
            % store coordinates of individual datapoints to connect them
            % later by line
            line_x(i,iLevel)=x_ind(i);
            line_y(i,iLevel)=Response(i,iLevel);
        end
        

    
    
    end
    
    %% connect data points of the same participant across levels by line
    
    for i=1:length(x_ind)
        line([line_x(i,1) line_x(i,2)],[line_y(i,1) line_y(i,2)],'Color',[0.5 0.5 0.5],'LineStyle','--');   
    end
    
%     
%     if iCon == 1
%         xlabel('LE stimulus')
%     elseif iCon == 2
%         xlabel('RE stimulus')
%     end
    
    ylabel('proportion of /ga/ responses');
    
    
    % axes limits
    xlim(XLimits);
    ylim(YLimits);
    
    % ticklabels
    xticks([1:2])
    xticklabels(['' ''])
%     xticklabels(XTickLabels)
%     yticks([0:0.2:1])
%     
%     % colors ticklabels
%     ax = gca;
%     ax.XTickLabel{1} = ['\color{cyan}' ax.XTickLabel{1}];
%     ax.XTickLabel{2} = ['\color{green}' ax.XTickLabel{2}];
    
    % adjust fontsize and fontname
    set(gca,'FontSize',AxesFontSize,'FontName', 'Arial'); %,'FontWeight','bold'
    
    %title(Conditions{iCon})
    % save figure to disk
    filename=fullfile(TransferDir,['Fig_1C_behavioral_data' Conditions{iCon} '.tif']);
    saveas(gcf,filename)
    
end




