% Example script for computing signal correlations, spike count
% correlations, and plotting the geometric mean-matched spike count
% correlations as a function of signal correlation across three different
% trial periods.

% Data from one session of the attention task from Trebmlay et al., Neuron
% (2015).
load example_data ;

epochStrings = {'fixation','cue','cueAndDistracters'} ;
nEpochs = length(epochStrings) ;

% Compute rsc, rsig, and geometric mean firing rates for each epoch
for epochI = 1:nEpochs
    
    currEpochString = epochStrings{epochI} ;
    
    currEpochRates = example_data.([currEpochString 'Rates']) ;
    
    rsc{epochI} = mL_rsc_rsig...
        (currEpochRates,'class',example_data.cueLocation) ;
    
    rsig{epochI} = mL_rsc_rsig...
        (currEpochRates,'class',example_data.cueLocation,'corr','rsig') ;
    
    geoMeanRates{epochI} = mL_geometricMeanRates(currEpochRates) ;
end

% Compute geometric mean-matched rsc for each epoch
[means, errors] = mL_mean_matched_rsc(rsc,geoMeanRates,...
    'conditionNames',epochStrings) ;

% Compute geometric mean-matched rsc as a function of rsignal for each
% epoch
[binVals, binMeans, binErrors, binCenters, figureHandles]...
    = mL_mean_matched_rsc_vs_rsig(rsc,rsig,geoMeanRates,'conditionNames',...
    epochStrings,'rSigBin',[.25,.05]) ;

% Adjust y axis limits to be identical
for epochI = 1:nEpochs
    currFigHandle = figureHandles{epochI} ;
    currFigHandle.Children.YLim = [-.04 .16] ;
end