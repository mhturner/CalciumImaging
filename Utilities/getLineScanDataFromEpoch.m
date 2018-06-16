function res = getLineScanDataFromEpoch(epoch,offsetCorrect,dataFolder)
if nargin < 2
    offsetCorrect = true;
    dataFolder = '/Users/mhturner/Dropbox/CurrentData/CalciumImaging/';
elseif nargin < 3
    dataFolder = '/Users/mhturner/Dropbox/CurrentData/CalciumImaging/';
end
cellName = char(epoch.cell.label);
dayFolder = cellName(1:8); %yyyymmdd
imagingDataFolder = [dataFolder, dayFolder,'/'];

cellID = cellName(10:end); %cn
scanNumber = epoch.protocolSettings.get('scanNumber');
fileName = ['0000',num2str(scanNumber)];
fileName = [cellID, '_',fileName(end-4 : end)];
fullFilePath = [imagingDataFolder,fileName];
[header, pmtData, scannerPosData, roiGroup] = ...
    readLineScanDataFiles_riekeLab(fullFilePath);

noChannels = size(header.acqChannels,1);
noROIs = size(roiGroup.rois,2);
traceLen = size(pmtData,1) / noROIs;

channelData = [];
for ii = 1:noROIs %each ROI
    traceStart = round(traceLen * (ii-1) + 1);
    traceEnd = round(traceLen * ii);
    for cc = 1:noChannels %each channel
        channelData(ii,:,cc) = mean(squeeze(pmtData(traceStart:traceEnd,cc,:)));
    end
end
frameTimes = (1:header.numFrames) .* header.frameDuration;
offsetFrames = frameTimes < 0.15; %first 150 msec;
if (offsetCorrect)
    for cc = 1:noChannels
        offset = mean(mean(channelData(:,offsetFrames,cc)));
        channelData(:,:,cc) = channelData(:,:,cc) - offset;
    end
end
res.roiGroup = roiGroup;
res.channelData = channelData;
res.frameTimes = frameTimes; %sec
res.numFrames = header.numFrames;
end