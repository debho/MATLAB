% reads data into matrices
usePath = '/Users/matt/Downloads'; % Deb, just change this to where all the files are
if ~exist('data','var')
    load(fullfile(usePath,'/Users/matt/Downloads/20210311_RecWDebInes.mat'));
end

[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors(fullfile(usePath,...
    'boris_binary_20210311_mouse.csv'),0,16,false);
behRanges = binBehaviors(binBeh,behTime,5,false);

% ch1(type=2): ?, ch2 (type=3): ?, ch3(type=4): ?, ch4(type=5): ?
fs = 250;
close all
figure('position',[0 0 1400 1000]);
for iType = 2:5
    subplot(2,2,iType-1);
    eeg = double(data(type == iType));
    % remove outliers, careful with this method, not perfect but looks like
    % there's isolated massive artifacts, so this will work here
    [B,I] = rmoutliers(eeg); % get indices of outliers
    eeg(I==1) = NaN; % set them to NaN
    eeg = fillmissing(eeg,'nearest'); % fill them in
    
    eeg = normalize(eeg - median(eeg));
    eeg_t = array2timetable(eeg','SampleRate',fs);

    % not sure what this is used for?
    % Hd = EMGFilter;
    % emgFilt = filter(Hd,double(eeg_emg_t.Var1));

    pspectrum(eeg_t,"spectrogram","FrequencyLimits",[1 30]); % ~delta–beta
    colormap(jet)
    caxis auto
%     caxis([-40 5]); % adjust empirically if you need to tune it
    title(sprintf("Spectrogram Ch%i",iType-1));

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

    % fs_axy = 25;
    
%     axyx = double(data(type == 7));
%     axyx = equalVectors(axyx,eeg);
% 
%     axyy = double(data(type == 8));
%     axyy = equalVectors(axyy,eeg);
% 
%     axyz = double(data(type == 9));
%     axyz = equalVectors(axyz,eeg);
% axyODBA = normalize(abs(diff(axyx)) + abs(diff(axyy)) + abs(diff(axyz)),'range');
% axyODBA_t = array2timetable(axyODBA','SampleRate',fs);
% axyODBA_t.Time = axyODBA_t.Time;