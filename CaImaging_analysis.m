%% RESET. NEW TREE.
clear list; clear all; clear java; close all; clc; %#ok<CLJAVA,CLALL>
loader = edu.washington.rieke.Analysis.getEntityLoader();
treeFactory = edu.washington.rieke.Analysis.getEpochTreeFactory();
dataFolder = '/Users/mhturner/Dropbox/CurrentData/CalciumImaging/';

import auimodel.*
import vuidocument.*
cd('~/Dropbox/RiekeLab/Analysis/MATLAB/RFSurround/')
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

%%
currentNode = gui.getSelectedEpochTreeNodes{1};

res = getLineScanDataFromEpoch(currentNode.epochList.elements(1),dataFolder);

figure(30); clf; hold on;
plot(res.channelData(1,:,1),'r');
plot(res.channelData(2,:,1),'g');
plot(res.channelData(3,:,1),'b');




