% right now, time interval = 1s, so indexing is easy...
% if data is exported with greater resolution, the behTime matrix would
% need to be referenced OR the event times in behExtract would need to be
% converted from index to time

function [behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors(filename,doPlot)

fid = fopen(filename);
behNames = strsplit(fgetl(fid),',');
behNames = behNames(2:end); % remove time label
fclose(fid);
binBeh = readmatrix(filename,'NumHeaderLines',1);
behTime = binBeh(:,1); % save time
binBeh(:,1) = []; % remove time data

extractedLabels = {'EventId','EventStart','EventEnd','Duration'};
behExtract = [];
for iBeh = 1:size(binBeh,2) % 1 is time
    thisBehData = logical(binBeh(:,iBeh)); % point events can be >1, force binary
    eventsStart = find(diff(thisBehData) == 1);
    eventsEnd = find(diff(thisBehData) == -1);
    
    useRange = size(behExtract,1) + 1:size(behExtract,1) + numel(eventsStart);
    behExtract(useRange,1) = repmat(iBeh,[numel(eventsStart),1]);
    behExtract(useRange,2) = eventsStart;
    behExtract(useRange,3) = eventsEnd;
    behExtract(useRange,4) = eventsEnd-eventsStart;
end

if ~doPlot, return, end
%%
colors = lines(size(binBeh,2));
h = figure('position',[0 0 1000 500]);
for iBeh = 1:numel(behNames)
    % imported data
    xData = find(binBeh(:,iBeh)==1);
    plot(xData,repmat(iBeh,size(xData)),'.','markerSize',10,'color',colors(iBeh,:));
    hold on;
    % exorted data
    thisBehData = behExtract(behExtract(:,1)==iBeh,:);
    for ii = 1:size(thisBehData,1)
        plot(thisBehData(ii,2),iBeh,'o','markerSize',10,'color',colors(iBeh,:)); % open
        plot(thisBehData(ii,3),iBeh,'x','markerSize',10,'color',colors(iBeh,:)); % close
    end
end
title('Imported and Extracted Behaviors');
ax = gca;
ax.YGrid = 'on';
ax.FontSize = 14;
set(gcf,'color','w');
yticks(1:size(binBeh,2));
ylim([0,size(binBeh,2)+1]);
yticklabels(behNames);
xlim([behTime(1),behTime(end)]);
xlabel('time (s)');

saveas(h,strrep(filename,'.csv','.png'));

% remember to adjust times to match ephys