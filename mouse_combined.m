close all; % closes all figures, can probably take this out once i'm done fixing code
for i = 1:2
    if(i==1)
        load('20210108_var.mat')
    else
        load('20210311_var.mat')
    end
    % do plots   
    % SPECTROGRAM
    % current issues: spectrograms still showing separately
    figure('position',[0 0 2800 1000]);
   
    subplot(1,2,i);
    pspectrum(eeg_t,"spectrogram","FrequencyLimits",[1 30]);
    colormap(jet);
    if(i==1)
        caxis([-40 5]); % manually adjusts for Day 1
    else
        caxis auto;
    end
    title(sprintf("Spectrogram for Day %i",i));
    if(i==1)
        bTime = behTime/60/60;
    else
        bTime = behTime/60;
    end
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
end

% STATISTICAL ANALYSIS
 