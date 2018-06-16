%% RESET. NEW TREE.
clear list; clear all; clear java; close all; clc; %#ok<CLJAVA,CLALL>
loader = edu.washington.rieke.Analysis.getEntityLoader();
treeFactory = edu.washington.rieke.Analysis.getEpochTreeFactory();
dataFolder = '/Users/mhturner/Dropbox/CurrentData/CalciumImaging/';

import auimodel.*
import vuidocument.*
cd('~/Dropbox/RiekeLab/Analysis/MATLAB/CalciumImaging/')
%% Large imaging tree
list = loader.loadEpochList([dataFolder,'CaImaging.mat'],dataFolder);

cellTypeSplit = @(list)splitOnCellType(list);
cellTypeSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, cellTypeSplit);

protocolIDSplit = @(list)splitOnShortProtocolID(list);
protocolIDSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, protocolIDSplit);


tree = riekesuite.analysis.buildTree(list, {cellTypeSplit_java,'cell.label',...
    protocolIDSplit_java,...
    'protocolSettings(scanNumber)'});
gui = epochTreeGUI(tree);
gui.showImagingTraces = true;
%%
currentNode = gui.getSelectedEpochTreeNodes{1};
scansToPull = 51:56;
noChannels = 4;
channelData = [];
for scanNo = 1:length(scansToPull)

    currentScanEpoch = currentNode.childBySplitValue(scansToPull(scanNo));
    res = getLineScanDataFromEpoch(currentScanEpoch.epochList.firstValue);
    for cc = 1:noChannels
        channelData(cc,:,scanNo) = res.channelData(cc,:,1);
    end
end
%mean over all trials
meanROIResp = mean(channelData,3);

%covert to deltaF/F and plot
baselineStart = 0.5; baselineEnd = 1.5;
frameStart = find(res.frameTimes>baselineStart,1);
temp = find(res.frameTimes<baselineEnd);
frameEnd = temp(end);
figure(5); clf;
colors = pmkmp(noChannels);
for cc = 1:noChannels
    rawTrace = meanROIResp(cc,:);
    bl = mean(rawTrace(frameStart:frameEnd));
    blCorrected = (rawTrace - bl) / bl;
    subplot(211); hold on;
    plot(res.frameTimes(frameStart:end), blCorrected(frameStart:end), 'Color',colors(cc,:))
end
subplot(212);
voltageRes = getMeanResponseTrace(currentNode.childBySplitValue(54).epochList,'iClamp');
startInd = find(res.frameTimes(frameStart) == voltageRes.timeVector);

plot(voltageRes.timeVector(startInd:end),voltageRes.mean(startInd:end),'k')
%%
dataFolder = '/Users/mhturner/Dropbox/CurrentData/CalciumImaging/20180221/';
[header, Aout, imgInfo] = scanimage.util.opentif([dataFolder,'c2_00048.tif'],...
    'channel',2);

meanImg = mean(squeeze(Aout),3);
figure(6); clf; imagesc(meanImg); colormap(gray); axis image; axis square; axis off;
brighten(0.35)

for cc = 1:4
    currentCenter_rel = res.roiGroup.rois(cc).scanfields.centerXY ./ (2*pi); %rel to center, as fraction of xydim
    currentSize_rel = res.roiGroup.rois(cc).scanfields.sizeXY ./ (2*pi);
    currentCenter_abs = currentCenter_rel .* 256 + 128;
    disp(currentCenter_rel)
    figure(6); hold on;
    plot(res.roiGroup.rois(cc).scanfields.transformParams.offsetX,...
        res.roiGroup.rois(cc).scanfields.transformParams.offsetY,...
        'rx')
end




