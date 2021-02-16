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
hold off

% extracting binary behaviors
[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors('boris_binary_20210108_mouse.csv',true);
% plotting binned behaviors
behRanges = binBehaviors(binBeh,5,true);
hold off

% power spectrum plots
%pspectrum(eeg1, "FrequencyLimits", [0 100])
%hold on 
%pspectrum(eeg2, "FrequencyLimits", [0 100])
%hold on 
%pspectrum(eeg3, "FrequencyLimits", [0 100])
%hold on
%pspectrum(eeg4, "FrequencyLimits", [0 100])
%legend("Parietal", "Frontal", " ", "EMG")
%xlabel("Frequency (Hz)")
%ylabel("Power")
%hold off

% plotting power spectra with FFT on 5-sec bins
for index = behRanges(1:end,2:3)
    tstart = behRanges(:,2) * fs;
    tend = behRanges(:,3) * fs;
    pspec = data(tstart:tend);
end

pspectrum(pspec)
% not sure why it shows up as normalized frequency?




