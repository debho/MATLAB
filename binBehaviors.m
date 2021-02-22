% bins do not ensure behavior lasts for the whole duration of the bin, but
% it does exclude the possibility that bins overlap
% looping is not the most efficient way of doing this, but since we only
% perform it once, who cares, it is easier to follow/modify
function behRanges = binBehaviors(binBeh,behTime,binInterval,doPlot)

behRanges = [];
rangeCount = 1;
for iBeh = 1:size(binBeh,2)
    thisBehData = binBeh(:,iBeh);
    
    isCounting = false;
    jj = 0;
    % subtract binInterval to force last entry >= binInterval
    % !! binInterval is 'samples' rather the seconds if behTime has been
    % adjusted with compressBy and offset
    for iTime = 1:numel(thisBehData)-binInterval
        if thisBehData(iTime) == 1 && ~isCounting
            behRanges(rangeCount,1) = iBeh; % index
            behRanges(rangeCount,2) = behTime(iTime); % start
            isCounting = true;
        end
        if isCounting
            jj = jj + 1;
        end
        if jj == binInterval
            behRanges(rangeCount,3) = behTime(iTime); % end
            rangeCount = rangeCount + 1;
            jj = 0;
            isCounting = false;
        end
    end
end

if ~doPlot, return, end

colors = lines(size(binBeh,2));
h = figure('position',[0 0 1000 500]);
for iBeh = 1:size(binBeh,2)
    thisBehData = behRanges(behRanges(:,1)==iBeh,2:3);
    for ii = 1:size(thisBehData,1)
        plot(thisBehData(ii,1),iBeh,'.','markerSize',10,'color',colors(iBeh,:));
        hold on;
        plot([thisBehData(ii,1),thisBehData(ii,2)],[iBeh,iBeh],'-','color',colors(iBeh,:));
    end
end
title('Binned Behaviors');
ax = gca;
ax.YGrid = 'on';
ax.FontSize = 14;
set(gcf,'color','w');
yticks(1:size(binBeh,2));
ylim([0,size(binBeh,2)+1]);
ylabel('Behavior ID');
xlim([1,size(binBeh,1)]);
xlabel('sample');