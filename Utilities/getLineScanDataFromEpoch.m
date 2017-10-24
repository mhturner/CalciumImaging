function res = getLineScanDataFromEpoch(epoch,dataFolder)

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
    traceStart = traceLen * (ii-1) + 1;
    traceEnd = traceLen * ii;
    for cc = 1:noChannels %each channel
        channelData(ii,:,cc) = mean(squeeze(pmtData(traceStart:traceEnd,cc,:)));
    end
end

res.channelData = channelData;

end