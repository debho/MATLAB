for i = 1:2
    if(i==1)
        load('20210108_var.mat')
    else
        load('20210311_var.mat')
    end
    % do plots
    % SPECTROGRAM
    % current issues: spectrograms aren't printing on the same figure
    % BORIS plot isn't showing up on Day 1
    figure('position',[0 0 2800 1000]);
    subplot(1,2,i);
    pspectrum(eeg_t,"spectrogram","FrequencyLimits",[1 30]);
    colormap(jet);
    caxis auto;
    title(sprintf("Spectrogram for Day %i",i));
    
    bTime = behTime/60;
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
 