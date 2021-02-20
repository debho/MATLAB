% reads data into matrices
data = readmatrix('20210108_data.csv');
type = readmatrix('20210108_type.csv');

% extracts EEG data
idx1 = type == 2;
eeg1 = data(idx1); % finds the indices of type in type matrix and finds corresponding data in data matrix

idx2 = type == 3;
eeg2 = data(idx2);

idx3 = type == 4;
eeg3 = data(idx3);

idx4 = type == 5;
eeg4 = data(idx4);

% converts matrices to timetables
fs = 250; % EEG was sampled at 250Hz
eeg1 = array2timetable(eeg1', 'SampleRate', fs);
eeg2 = array2timetable(eeg2', 'SampleRate', fs);
eeg3 = array2timetable(eeg3', 'SampleRate', fs);
eeg4 = array2timetable(eeg4', 'SampleRate', fs);
eeg = synchronize(eeg1,eeg2,eeg3,eeg4); % puts data from all 4 contacts into one table
eeg.Properties.VariableNames = ["Parietal", "Frontal", " ", "EMG"];

% spectrogram
pspectrum(eeg1, "spectrogram", "FrequencyLimits", [0 100])
colormap(jet)
caxis auto
ylim([0 35])
title("Spectrogram of EEG Data")
hold off

% extracting binary behaviors
[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors('boris_binary_20210108_mouse.csv',true);
% plotting binned behaviors
behRanges = binBehaviors(binBeh,5,true);
hold off

% sleep
Parr = [];
eeg1Beh = find(behRanges(:,1) == 2); % eeg1
for ii = 1:numel(eeg1Beh)
  tstart = (behRanges(eeg1Beh(ii),2) - 1) * fs;
  tend = behRanges(eeg1Beh(ii),3) * fs;
   pspec = array2timetable(eeg1.Var1(tstart:tend), "SampleRate", fs);
   [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
   Parr(ii,:) = 10*log10(P);
end
figure;
plot(F, mean(Parr));
xlabel("Frequency (Hz)")
ylabel("Mean Power")
title("Mean Power against Frequency (Sleep)")
% stats - Parr has 147 different values, you can extract freq band like:
bandPowers = Parr(:,F>1 & F<4);
% take mean of dim=2
bandPower = mean(bandPowers,2);
% make sure it's relatively stable across each bin
figure;
plot(bandPower);
title("Mean Power at 2Hz (Sleep)")

% wake-still
Parr2 = [];
eeg1Beh2 = find(behRanges(:,1) == 4);
for ii = 1:numel(eeg1Beh2)
  tstart = (behRanges(eeg1Beh2(ii),2) - 1) * fs;
  tend = behRanges(eeg1Beh2(ii),3) * fs;
   pspec = array2timetable(eeg1.Var1(tstart:tend), "SampleRate", fs);
   [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
   Parr2(ii,:) = 10*log10(P);
end

figure;
plot(F, mean(Parr2));
xlabel("Frequency (Hz)")
ylabel("Mean Power")
title("Mean Power against Frequency (Wake-Still)")
% extracting freq band between 1-4Hz
bandPowers2 = Parr2(:,F>1 & F<4);
% take mean of dim=2
bandPower2 = mean(bandPowers2,2);
% make sure it's relatively stable across each bin
figure;
plot(bandPower2);
title("Mean Power at 2Hz (Wake-Still)")

% walking
Parr3 = [];
eeg1Beh3 = find(behRanges(:,1) == 5);
for ii = 1:numel(eeg1Beh3)
  tstart = (behRanges(eeg1Beh3(ii),2) - 1) * fs;
  tend = behRanges(eeg1Beh3(ii),3) * fs;
   pspec = array2timetable(eeg1.Var1(tstart:tend), "SampleRate", fs);
   [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
   Parr3(ii,:) = 10*log10(P);
end

figure;
plot(F, mean(Parr3));
xlabel("Frequency (Hz)")
ylabel("Mean Power")
title("Mean Power against Frequency (Walking)")
% extracting freq band between 1-4Hz
bandPowers3 = Parr3(:,F>1 & F<4);
% take mean of dim=2
bandPower3 = mean(bandPowers3,2);
% make sure it's relatively stable across each bin
figure;
plot(bandPower3);
title("Mean Power at 2Hz (Walking)")
% NOTE: Mean Power graph was plotted wrongly before, updated the code so I
% need to update the graph on Github

% ANOVA
meansCombined = zeros(552,3); %definitely not the most efficient way but i didn't know how else to join the columns for analysis
meansCombined(:,1) = [bandPower; zeros(375,1)];
meansCombined(:,2) = bandPower2;
meansCombined(:,3) = [bandPower3; zeros(430,1)];
meansCombined(meansCombined == 0) = NaN;
p = anova1(meansCombined);

% testing time offset correction
% twitch
emgFixedfirst5 = eeg4(2751:77751,:); %start of where biologger data aligns with video
%emgFixedfirst5 = array2timetable(emgFixedfirst5, "SampleRate", fs);
Parr4 = [];
eeg1Beh4 = find(behRanges(:,1) == 3);
for ii = 1:40
  tstart = (behRanges(eeg1Beh4(ii),2) - 1) * fs;
  tend = behRanges(eeg1Beh4(ii),3) * fs;
   pspec = array2timetable(emgFixedfirst5(tstart:tend), "SampleRate", fs);
   [P,F] = pspectrum(pspec, "FrequencyLimits", [0 100]);
   Parr4(ii,:) = 10*log10(P);
end

figure;
plot(F, mean(Parr4));
xlabel("Frequency (Hz)")
ylabel("Mean Power")
title("Mean Power against Frequency (Twitch)")
% extracting freq band between 1-4Hz
bandPowers4 = Parr4(:,F>1 & F<4);
% take mean of dim=2
bandPower4 = mean(bandPowers4,2);
% make sure it's relatively stable across each bin
figure;
plot(bandPower4);
title("Mean Power at 2Hz (Twitch)")
pspectrum(emgFixedfirst5, "spectrogram", "FrequencyLimits", [0 100])
colormap(jet)
caxis auto
title("EMG Data for First 5 minutes")




