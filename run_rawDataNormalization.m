ff(1000,800);
axs = [];
useSamples = 50000*2;
for iType = 2:5
    axs(1) = subplot(211);
    eeg = data(type == iType);
    eeg = eeg(1:useSamples);
    
    Hd = Filter_highPass;
    plot(eeg);
    hold on
    title('Raw Data');
    
    axs(2) = subplot(212);
    plot(filter(Hd,normalize(double(eeg))));
%     plot(normalize(double(eeg)));
    hold on;
    title('Z-score Normalized');
end
linkaxes(axs,'x');
subplot(211);
legend(compose('Ch%i',1:4));
subplot(212);
legend(compose('Ch%i',1:4));