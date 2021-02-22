if ~exist('data','var')
    data = readmatrix('20210108_data.csv');
    type = readmatrix('20210108_type.csv');
end

% ch1(type=2): Parietal, ch2 (type=3): Frontal, ch3(type=4): NC, ch4(type=5): EMG
fs_axy = 25;
axyx = data(type == 8);
axyx_t = array2timetable(axyx', 'SampleRate', fs_axy);

fs = 250;
eeg_par = data(type == 2);
eeg_par = normalize(eeg_par - median(eeg_par));
eeg_par_t = array2timetable(eeg_par', 'SampleRate', fs);
eeg_par_t.Time = eeg_par_t.Time - seconds(0);

eeg_fro = data(type == 3);
eeg_fro = normalize(eeg_fro - median(eeg_fro));
eeg_fro_t = array2timetable(eeg_fro', 'SampleRate', fs);
eeg_fro_t.Time = eeg_fro_t.Time - seconds(0);

eeg_emg = data(type == 5);
eeg_emg = normalize(eeg_emg - median(eeg_emg));
eeg_emg_t = array2timetable(eeg_emg', 'SampleRate', fs);
eeg_emg_t.Time = eeg_emg_t.Time - seconds(0);

% extracting binary behaviors
[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors('boris_binary_20210108_mouse.csv',false);
% plotting binned behaviors
behRanges = binBehaviors(binBeh,5,false);

close all;
figure('position',[0,0,1000,500]);

plot(eeg_emg_t.Time,eeg_emg_t.Var1,'k');
ylim([-10 10]);
xlim([min(eeg_emg_t.Time),max(eeg_emg_t.Time)]);

hold on;
plot(binBeh(:,1) + binBeh(:,3),'r'); % twitches
hold on;
plot(binBeh(:,2)*-1,'b'); % sleep

yyaxis right;
plot(axyx_t.Time,axyx_t.Var1,'g');