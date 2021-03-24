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
    
end

% STATISTICAL ANALYSIS
 
