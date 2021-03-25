%%
% reads data into matrices

data = readmatrix('20210108_data.csv');
type = readmatrix('20210108_type.csv');

% ch1(type=2): Parietal, ch2 (type=3): Frontal, ch3(type=4): NC, ch4(type=5): EMG
fs = 250;
eeg_par = double(data(type == 2));
[B,I] = rmoutliers(eeg_par); % get indices of outliers
eeg_par(I==1) = NaN; % set them to NaN
eeg_par = fillmissing(eeg_par,'nearest'); % fill them in    
eeg_par = normalize(eeg_par - median(eeg_par));
eeg_par_t = array2timetable(eeg_par', 'SampleRate', fs);

eeg_fro = double(data(type == 3));
eeg_fro = equalVectors(eeg_fro,eeg_par);
[B,I] = rmoutliers(eeg_fro); % get indices of outliers
eeg_fro(I==1) = NaN; % set them to NaN
eeg_fro = fillmissing(eeg_fro,'nearest'); % fill them in    
eeg_fro = normalize(eeg_fro - median(eeg_fro));
eeg_fro_t = array2timetable(eeg_fro', 'SampleRate', fs);

eeg_emg = double(data(type == 5));
eeg_emg = equalVectors(eeg_emg,eeg_par);
eeg_emg = normalize(eeg_emg - median(eeg_emg));
eeg_emg_t = array2timetable(eeg_emg', 'SampleRate', fs);

Hd = EMGFilter;
emgFilt = filter(Hd,double(eeg_emg_t.Var1));

% fs_axy = 25;
axyx = double(data(type == 7));
axyx = equalVectors(axyx,eeg_par);

axyy = double(data(type == 8));
axyy = equalVectors(axyy,eeg_par);

axyz = double(data(type == 9));
axyz = equalVectors(axyz,eeg_par);

axyODBA = normalize(abs(diff(axyx)) + abs(diff(axyy)) + abs(diff(axyz)),'range');
axyODBA_t = array2timetable(axyODBA', 'SampleRate', fs);
axyODBA_t.Time = axyODBA_t.Time;

% % % % eeg = synchronize(eeg_par,eeg_fro,eeg_emg); % puts data from all 4 contacts into one table
% % % % eeg.Properties.VariableNames = ["Parietal", "Frontal", "EMG"];

% important settings for messed up time alignment!
[behNames,behTime,behExtract,extractedLabels,binBeh] = ...
    extractBinaryBehaviors('boris_binary_20210108_mouse.csv',29,145,false);
behRanges = binBehaviors(binBeh,behTime,5,false);

%% SPECTROGRAM
close all
figure('position',[0 0 1000 500]);
pspectrum(eeg_fro_t, "spectrogram", "FrequencyLimits", [0 35]); % ~delta–beta
colormap(jet)
%caxis auto
caxis([-40 5]); % adjusted empirically
title("Spectrogram of EEG Data, 01-08-2021")

bTime = behTime/60/60;
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

%% DELTA-ALPHA WALKING
lns = [];
figure('position',[0 0 1000 500]);
plot(eeg_fro_t.Time,eeg_fro_t.Var1,'k');
hold on;
Hd = Filter_delta;
deltaFilt = filter(Hd,eeg_fro_t.Var1);
plot(eeg_fro_t.Time,deltaFilt,'r-','linewidth',1.5);
lns(1) = plot(eeg_fro_t.Time,abs(hilbert(deltaFilt)),'r:');

Hd = Filter_alpha;
alphaFilt = filter(Hd,eeg_fro_t.Var1);
lns(2) = plot(eeg_fro_t.Time,abs(hilbert(alphaFilt)),'b');

ylim([-5 5]);
colors = lines(5);
for ii = 5
    ln = plot(seconds(behTime(binBeh(:,ii)==1)),5,'.','color',colors(ii,:),'markersize',15);
    lns(3) = ln(1);
    hold on;
end
% legend(lns,behNames);
legend(lns,{'Delta','Alpha','Walking'});
ylim([-5 10]);
set(gca,'fontsize',14);
set(gcf,'color','w');
yticks([]);
grid on;

%% POWER SPECTRA
% sleep
Parr_sleep = [];
eeg_Beh = find(behRanges(:,1) == 2);
for ii = 1:numel(eeg_Beh)
    tstart = round(behRanges(eeg_Beh(ii),2) * fs);
    tend = round(behRanges(eeg_Beh(ii),3) * fs);
    pspec = array2timetable(eeg_par_t.Var1(tstart:tend), "SampleRate", fs);
    [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
    Parr_sleep(ii,:) = 10*log10(P);
end

% wake-still
Parr_wake_still = [];
eeg_Beh2 = find(behRanges(:,1) == 4);
for ii = 1:numel(eeg_Beh2)
    tstart = round(behRanges(eeg_Beh2(ii),2) * fs);
    tend = round(behRanges(eeg_Beh2(ii),3) * fs);
    pspec = array2timetable(eeg_par_t.Var1(tstart:tend), "SampleRate", fs);
    [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
    Parr_wake_still(ii,:) = 10*log10(P);
end

% walking
Parr_walk = [];
eeg_Beh3 = find(behRanges(:,1) == 5);
for ii = 1:numel(eeg_Beh3)
    tstart = round(behRanges(eeg_Beh3(ii),2) * fs);
    tend = round(behRanges(eeg_Beh3(ii),3) * fs);
    pspec = array2timetable(eeg_par_t.Var1(tstart:tend), "SampleRate", fs);
    [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
    Parr_walk(ii,:) = 10*log10(P);
end

pvalue_at_F = NaN(size(F));
for iFreq = 1:numel(F)
    x = [Parr_sleep(:,iFreq);Parr_wake_still(:,iFreq);Parr_walk(:,iFreq)];
    groups = [zeros(size(Parr_sleep(:,iFreq)));ones(size(Parr_wake_still(:,iFreq)));2*ones(size(Parr_walk(:,iFreq)))];
    pvalue_at_F(iFreq) = anova1(x,groups,'off');
end

close all
lw = 2;
hSpectrum = ff(1400,500);
usexlims = [[0,100];[0,10]];
for iPlot = 1:2
    subplot(1,2,iPlot);
    plot(F,mean(Parr_sleep),'linewidth',lw);
    hold on; % for others!
    xlabel("Frequency (Hz)")
    ylabel("Mean Power")
    plot(F, mean(Parr_wake_still),'linewidth',lw);
    plot(F, mean(Parr_walk),'linewidth',lw);
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
        title("Mean Power against Frequency, 01-08-21");
        legend({'sleep','wake-still','walking','p < 0.001','p < 0.01','p < 0.05'},'location','southwest');
    else
        title('Zoomed-in on low frequencies');
    end
end

%% OLD PSPEC CODE
%hSpectrum = figure;
%plot(F, mean(Parr_sleep));
%hold on; % for others!
% stats - Parr has 147 different values, you can extract freq band like:
%bandPowers = Parr_sleep(:,F>1 & F<4);
% take mean of dim=2
%bandPower = mean(bandPowers,2);
% make sure it's relatively stable across each bin
%figure;
%plot(bandPower);
%title("Mean Delta Power (Sleep)")
%ylabel("Power")
%xlabel("Bins")

%figure(hSpectrum);
%plot(F, mean(Parr_wake_still));
% extracting freq band between 1-4Hz
%bandPowers2 = Parr_wake_still(:,F>1 & F<4);
% take mean of dim=2
%bandPower2 = mean(bandPowers2,2);
% make sure it's relatively stable across each bin
%figure;
%plot(bandPower2);
%title("Mean Delta Power (Wake-Still)")
%ylabel("Power")
%xlabel("Bins")

%figure(hSpectrum);
%plot(F, mean(Parr_walk));
%xlabel("Frequency (Hz)")
%ylabel("Mean Power")
%title("Mean Power against Frequency, 01-08-2021")
%legend({'sleep','wake-still','walking'});

% extracting freq band between 1-4Hz
%bandPowers3 = Parr_walk(:,F>1 & F<4);
% take mean of dim=2
%bandPower3 = mean(bandPowers3,2);
% make sure it's relatively stable across each bin
%figure;
%plot(bandPower3);
%title("Mean Delta Power (Walking)")
%ylabel("Power")
%xlabel("Bins")

%% STATISTICAL ANALYSIS
% ANOVA for delta power
% hypothesis: band powers are different
%y = [bandPower;bandPower2;bandPower3];
%group = [zeros(size(bandPower));ones(size(bandPower2));2*ones(size(bandPower3))];
%[~,~,stats] = anovan(y,group); % follow format in documentation
%results = multcompare(stats);

% you can see that group 2 (walking) is sig diff from others
% but group 0&1 are not significant from each other

%% CODE THAT WE NO LONGER NEED
% % % % meansCombined = zeros(552,3); %definitely not the most efficient way but i didn't know how else to join the columns for analysis
% % % % meansCombined(:,1) = [bandPower; zeros(375,1)];
% % % % meansCombined(:,2) = bandPower2;
% % % % meansCombined(:,3) = [bandPower3; zeros(430,1)];
% % % % meansCombined(meansCombined == 0) = NaN;
% % % % p = anova1(meansCombined);


% !! see run_checkDataAlignment

% testing time offset correction
% plot 5 minutes of EMG data alongside twitch data points
% % % % emgFixedfirst5 = eeg_emg(2751:77750,:); % extracts EMG data for first 5 min of video
% % % % 
% % % % Parr4 = [];
% % % % emgTwitch = find(behRanges(:,1) == 3); % identifies bins with twitches
% % % % for ii = 1:numel(emgTwitch)
% % % %     tstart = (behRanges(emgTwitch(ii),2) - 1) * fs;
% % % %     tend = behRanges(emgTwitch(ii),3) * fs;
% % % %     pspec = array2timetable(emgFixedfirst5.Var1(tstart:tend), "SampleRate", fs);
% % % %     [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
% % % %     Parr4(ii,:) = 10*log10(P);
% % % % end

%% SAVES VARIABLES
eeg_t = eeg_par_t;
save('20210108_var.mat','eeg_t','fs','binBeh','behExtract','behNames','behRanges','behTime','Parr_sleep','Parr_wake_still','eeg_Beh','eeg_Beh2','Parr_walk','eeg_Beh3','bTime') % saves variables into a .mat file
