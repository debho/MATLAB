% reads data into matrices
data = readmatrix('20210108_data.csv');
type = readmatrix('20210108_type.csv');

% extracts EEG data
% finds the indices of each type in the type matrix and finds corresponding
% data in the data matrix

idx1 = type == 2;
eeg1 = data(idx1);

idx2 = type == 3;
eeg2 = data(idx2);

idx3 = type == 4;
eeg3 = data(idx3);

idx4 = type == 5;
eeg4 = data(idx4);

% power spectrum with FFT from 1-100Hz

fs = 250; % EEG was sampled at 250Hz
eeg1 = array2timetable(fft(eeg1'), 'SampleRate', fs);
eeg2 = array2timetable(fft(eeg2'), 'SampleRate', fs);
eeg3 = array2timetable(fft(eeg3'), 'SampleRate', fs);
eeg4 = array2timetable(fft(eeg4'), 'SampleRate', fs);
eeg = synchronize(eeg1,eeg2,eeg3,eeg4);
eeg.Properties.VariableNames = ["EEG 1", "EEG 2", "EEG 3", "EEG 4"];

% power spectrum plots
pspectrum(eeg1, "FrequencyLimits", [0 100])
hold on 
pspectrum(eeg2, "FrequencyLimits", [0 100])
hold on 
pspectrum(eeg3, "FrequencyLimits", [0 100])
hold on
pspectrum(eeg4, "FrequencyLimits", [0 100])
legend("EEG 1", "EEG 2", "EEG 3", "EEG 4")
xlabel("Frequency (Hz)")
ylabel("Power")
hold off

% spectrograms
pspectrum(eeg1, eeg(:,"Time"), "spectrogram", "FrequencyLimits", [0 100])
% ^ keeps giving me an error message, not sure how to fix it

