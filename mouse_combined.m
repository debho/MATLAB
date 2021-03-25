usePath = '/Users/deb/Desktop/mouse-ephys/';

close all; % closes all figures, can probably take this out once i'm done fixing code
% make figures BEFORE loop
hspectrum = ff(1200,800);
hpower = ff(1200,800);
for i = 1:2
    % !! you're not saving individual variables, you're saving the entire
    % workspace. Read my note again: save('myfile.mat','variable1') then use load('myfile.mat') in a loop
    % only save variables you will reuse, these files are gigantic
    if(i==1)
        load(fullfile(usePath,'20210108_var.mat'))
    else
        load(fullfile(usePath,'20210311_var.mat'))
    end
    % DO PLOTS   
    %% SPECTROGRAM
    % select figures like this to plot multiple things
    figure(hspectrum);
    subplot(2,1,i);
    pspectrum(eeg_t,"spectrogram","FrequencyLimits",[1 30]);
    colormap(jet);
    if(i==1)
        caxis([-40 5]); % manually adjusts for Day 1
    else
        caxis auto;
    end
    title(sprintf("Spectrogram for Day %i",i));
    % puts behavior plot on top of spectrogram
    yyaxis right;
    colors = lines(5);
    lns = [];
    for ii = 1:5
        ln = plot(bTime(binBeh(:,ii)==1),ii,'.','color',colors(ii,:),'markersize',15);
        lns(ii) = ln(1);
        hold on;
    end
    legend(lns,behNames);
    ylim([-10 20]);
    set(gca,'fontsize',14);
    set(gcf,'color','w');
    yticks([]);
    drawnow;
    
    %% POWER SPECTRA
    figure(hpower);
    subplot(1,2,i);
    
    %% SAVE VARIABLES INTO NEW ONES FOR ANALYSIS
    if(i==1)
        Parr_sleep1 = Parr_sleep;
        Parr_wake_still1 = Parr_wake_still;
    else
        Parr_sleep2 = Parr_sleep;
        Parr_wake_still2 = Parr_wake_still;
    end
    
end

%% STATISTICAL ANALYSIS
% sleep
pvalue_at_F = NaN(size(F));
for iFreq = 1:numel(F)
    x = [Parr_sleep1(:,iFreq);Parr_sleep2(:,iFreq)];
    groups = [zeros(size(Parr_sleep1(:,iFreq)));ones(size(Parr_sleep2(:,iFreq)))];
    pvalue_at_F(iFreq) = anova1(x,groups,'off');
end

lw = 2;
hSpectrum = ff(1400,500);
usexlims = [[0,100];[0,10]];
for iPlot = 1:2
    subplot(1,2,iPlot);
    plot(F,mean(Parr_sleep1),'linewidth',lw);
    hold on;
    xlabel("Frequency (Hz)")
    ylabel("Mean Power")
    plot(F, mean(Parr_sleep2),'linewidth',lw);
    set(gca,'fontsize',16);
    grid on;

    pThresh = [0.001, 0.01, 0.05];
    colors = gray(4);
    plotAt = max(ylim); % just find a place to plot the asterik
    for iThresh = 1:numel(pThresh)
        useXlocs = find(pvalue_at_F < pThresh(iThresh));
        plot(F(useXlocs),ones(size(useXlocs))*(plotAt-iThresh+1),'*','color',colors(iThresh,:));
    end

    xlim(usexlims(iPlot,:));
    if iPlot == 1
        title("Mean Power against Frequency, Sleep");
        legend({'Day 1','Day 2','p < 0.001','p < 0.01','p < 0.05'},'location','southwest');
    else
        title('Zoomed-in on low frequencies');
    end
end
