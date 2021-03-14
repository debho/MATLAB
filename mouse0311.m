
% reads data into matrices
if ~exist('data','var')
    data = readmatrix('20210108_data.csv');
    type = readmatrix('20210108_type.csv');
end

% ch1(type=2): Parietal, ch2 (type=3): Frontal, ch3(type=4): NC, ch4(type=5): EMG
fs = 250;
eeg_par = double(data(type == 2));
eeg_par = normalize(eeg_par - median(eeg_par));
eeg_par_t = array2timetable(eeg_par', 'SampleRate', fs);

eeg_fro = double(data(type == 3));
eeg_fro = equalVectors(eeg_fro,eeg_par);
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

[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors('boris_binary_20210311_mouse.csv',0,0,true);
behRanges = binBehaviors(binBeh,behTime,5,false);


close all
% spectrogram
figure('position',[0 0 1000 500]);
pspectrum(eeg_fro_t, "spectrogram", "FrequencyLimits", [0 35]); % ~delta–beta
colormap(jet)
% caxis auto
caxis([-40 5]); % adjusted empirically
title("Spectrogram of EEG Data")

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



