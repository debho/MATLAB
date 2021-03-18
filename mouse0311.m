% reads data into matrices
usePath = '/Users/deb/Desktop/mouse-ephys'; % Deb, just change this to where all the files are
if ~exist('data','var')
    load(fullfile(usePath,'/Users/deb/Desktop/mouse-ephys/20210311_RecWDebInes.mat'));
end

[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors(fullfile(usePath,...
    'boris_binary_20210311_mouse.csv'),0,-17,false);
behRanges = binBehaviors(binBeh,behTime,5,false);

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

    pspectrum(eeg_t,"spectrogram","FrequencyLimits",[1 30]); % ~delta–beta
    colormap(jet)
    caxis auto;
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
hold off

% power spectra
% sleep
Parr = [];
eeg_parBeh = find(behRanges(:,1) == 3);
for ii = 1:numel(eeg_parBeh)
    tstart = round(behRanges(eeg_parBeh(ii),2) * fs);
    tend = round(behRanges(eeg_parBeh(ii),3) * fs);
    pspec = array2timetable(eeg_t.Var1(tstart:tend), "SampleRate", fs);
    [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
    Parr(ii,:) = 10*log10(P);
end

hSpectrum = figure;
plot(F, mean(Parr));
hold on; % for others!
xlabel("Frequency (Hz)")
ylabel("Mean Power")
title("Mean Power against Frequency")

% extract freq band
bandPowers = Parr(:,F>1 & F<4);
% take mean of dim=2
bandPower = mean(bandPowers,2);
% make sure it's relatively stable across each bin
figure;
plot(bandPower);
title("Mean Power at 2Hz (Sleep)")

% wake-still
Parr2 = [];
eeg_parBeh2 = find(behRanges(:,1) == 5);
for ii = 1:numel(eeg_parBeh2)
    tstart = round(behRanges(eeg_parBeh2(ii),2) * fs);
    tend = round(behRanges(eeg_parBeh2(ii),3) * fs);
    pspec = array2timetable(eeg_t.Var1(tstart:tend), "SampleRate", fs);
    [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
    Parr2(ii,:) = 10*log10(P);
end


figure(hSpectrum);
plot(F, mean(Parr2));
legend({'sleep','wake-still'});
bandPowers2 = Parr2(:,F>1 & F<4);
bandPower2 = mean(bandPowers2,2);
figure;
plot(bandPower2);
title("Mean Power at 2Hz (Wake-Still)")


% ANOVA for 2Hz
% hypothesis: band powers are different
y = [bandPower;bandPower2];
group = [zeros(size(bandPower));ones(size(bandPower2))];
[~,~,stats] = anovan(y,group); % follow format in documentation
results = multcompare(stats);

% sleep and wake-still are different at 2Hz

% means at 1Hz
power1Hz = mean(bandPowers,1)';
figure;
plot(power1Hz);
hold on
power1Hz2 = mean(bandPowers2,1)';
plot(power1Hz2);
title("Mean Power at 1Hz")
legend({'sleep', 'wake-still'});

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