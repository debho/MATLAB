if ~exist('data','var')
    data = readmatrix('20210108_data.csv');
    type = readmatrix('20210108_type.csv');
end

% ch1(type=2): Parietal, ch2 (type=3): Frontal, ch3(type=4): NC, ch4(type=5): EMG
fs = 250;
eeg_par = data(type == 2);
eeg_par = normalize(eeg_par - median(eeg_par));
eeg_par_t = array2timetable(eeg_par', 'SampleRate', fs);
eeg_par_t.Time = eeg_par_t.Time;

eeg_fro = data(type == 3);
eeg_fro = equalVectors(eeg_fro,eeg_par);
eeg_fro = normalize(eeg_fro - median(eeg_fro));
eeg_fro_t = array2timetable(eeg_fro', 'SampleRate', fs);
eeg_fro_t.Time = eeg_fro_t.Time;

eeg_emg = data(type == 5);
eeg_emg = equalVectors(eeg_emg,eeg_par);
eeg_emg = normalize(eeg_emg - median(eeg_emg));
eeg_emg_t = array2timetable(eeg_emg', 'SampleRate', fs);
eeg_emg_t.Time = eeg_emg_t.Time;

Hd = EMGFilter;
emgFilt = filter(Hd,double(eeg_emg_t.Var1));

% fs_axy = 25;
axyx = data(type == 7);
axyx = equalVectors(axyx,eeg_par);

axyy = data(type == 8);
axyy = equalVectors(axyy,eeg_par);

axyz = data(type == 9);
axyz = equalVectors(axyz,eeg_par);

axyODBA = normalize(abs(diff(axyx)) + abs(diff(axyy)) + abs(diff(axyz)),'range');
axyODBA_t = array2timetable(axyODBA', 'SampleRate', fs);
axyODBA_t.Time = axyODBA_t.Time;

[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors('boris_binary_20210108_mouse.csv',29,145,false);
behRanges = binBehaviors(binBeh,behTime,5,false);


close all;
figure('position',[0,0,1000,500]);

plot(eeg_emg_t.Time,emgFilt,'k');
ylim([-2 2]);
xlim([min(eeg_emg_t.Time),max(eeg_emg_t.Time)]);

hold on;
plot(seconds(behTime),binBeh(:,1) + binBeh(:,3) + binBeh(:,5),'r'); % all movement
hold on;
plot(seconds(behTime),binBeh(:,2)*-1,'b'); % sleep

yyaxis right;
plot(axyODBA_t.Time,axyODBA_t.Var1,'g');