%%
% reads data into matrices
usePath = '/Users/deb/Desktop/mouse-ephys'; % Deb, just change this to where all the files are
usePath = '/Users/matt/Downloads';
if ~exist('data','var')
    load(fullfile(usePath,'/20210311_RecWDebInes.mat'));
end

[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors(fullfile(usePath,...
    'boris_binary_20210311_mouse.csv'),0,-17,false);
behRanges = binBehaviors(binBeh,behTime,5,false);

%%
% spectrograms
% ch1(type=2): EMG, ch2 (type=3): ?, ch3(type=4): ?, ch4(type=5): ?
fs = 241;
close all
figure('position',[0 0 1400 1000]);
for iType = 3
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
    
    % codes spectrograms
    pspectrum(eeg_t,"spectrogram","FrequencyLimits",[1 30]); % ~delta–beta
    colormap(jet)
    caxis auto;
    title(sprintf("Spectrogram Ch%i, 03-11-2021",iType-1));
    % puts behavioral observations on top of spectrogram
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
hold off

%%
% power spectra
% sleep
Parr_sleep = [];
eeg_Beh = find(behRanges(:,1) == 3);
for ii = 1:numel(eeg_Beh)
    tstart = round(behRanges(eeg_Beh(ii),2) * fs);
    tend = round(behRanges(eeg_Beh(ii),3) * fs);
    pspec = array2timetable(eeg_t.Var1(tstart:tend), "SampleRate", fs);
    [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
    Parr_sleep(ii,:) = 10*log10(P);
end

% % % % deltaSleep = figure;
% % % % for freqType = 0:3
% % % %     % extract freq band
% % % %     bandPowers = Parr_sleep(:,F>freqType & F<freqType + 1);
% % % %     % take mean of dim=2 (columns)
% % % %     bandPower = mean(bandPowers,2);
% % % %     % make sure it's relatively stable across each bin
% % % %     figure(deltaSleep);
% % % %     plot(bandPower);
% % % %     hold on;
% % % %     title("Mean Delta Power (Sleep), 03-11-2021")
% % % %     ylabel("Power")
% % % %     xlabel("Bins")
% % % % end
% % % % legend({'1Hz','2Hz','3Hz','4Hz'});
% % % % hold off;


% wake-still
Parr_wake_still = [];
eeg_Beh2 = find(behRanges(:,1) == 5);
for ii = 1:numel(eeg_Beh2)
    tstart = round(behRanges(eeg_Beh2(ii),2) * fs);
    tend = round(behRanges(eeg_Beh2(ii),3) * fs);
    pspec = array2timetable(eeg_t.Var1(tstart:tend), "SampleRate", fs);
    [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
    Parr_wake_still(ii,:) = 10*log10(P);
end

% OK now you have Parr_sleep size(67 x 4096) and Parr_wake_still
% size(220,4096)... 4096 is the frequencies 1-100Hz (stored in F)
% sweep frequencies
pvalue_at_F = NaN(size(F));
for iFreq = 1:numel(F)
    x = [Parr_sleep(:,iFreq);Parr_wake_still(:,iFreq)];
    groups = [zeros(size(Parr_sleep(:,iFreq)));ones(size(Parr_wake_still(:,iFreq)))];
    pvalue_at_F(iFreq) = anova1(x,groups,'off');
end

%% do all your figure stuff in one place so you can run this section separately
close all
lw = 2;
hSpectrum = ff(1000,500);
plot(F,mean(Parr_sleep),'linewidth',lw);
hold on; % for others!
xlabel("Frequency (Hz)")
ylabel("Mean Power")
title("Mean Power against Frequency, 03-11-20")
plot(F, mean(Parr_wake_still),'linewidth',lw);
set(gca,'fontsize',16);
grid on;

pThresh = [0.05, 0.01, 0.001];
colors = winter(numel(pThresh));
plotAt = max(ylim); % just find a place to plot the asterik
for iThresh = 1:numel(pThresh)
    useXlocs = find(pvalue_at_F < pThresh(iThresh));
    plot(F(useXlocs),ones(size(useXlocs))*(plotAt-iThresh),'*','color',colors(iThresh,:));
end

legend({'sleep','wake-still','p < 0.05','p < 0.01','p < 0.001'},'location','southwest');


% % % % deltaWake = figure;
% % % % for freqType = 0:3
% % % %     bandPowers2 = Parr_wake_still(:,F>freqType & F<freqType + 1);
% % % %     bandPower2 = mean(bandPowers2,2);
% % % %     figure(deltaWake);
% % % %     plot(bandPower2);
% % % %     hold on;
% % % %     title("Mean Delta Power (Wake-Still)")
% % % %     ylabel("Power")
% % % %     xlabel("Bins")
% % % % end
% % % % legend({'1Hz','2Hz','3Hz','4Hz'});
% % % % hold off;


% ANOVA for delta power
% hypothesis: band powers are different
% % % % y = [bandPower;bandPower2];
% % % % group = [zeros(size(bandPower));ones(size(bandPower2))];
% % % % [~,~,stats] = anovan(y,group); % follow format in documentation
% % % % results = multcompare(stats);
% % % % yticklabels({'wake-still','sleep'});
% sleep and wake-still have different delta power

%% axy code that we don't need for now
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
%%

% save('20210311_var.mat') % saves variables into a .mat file