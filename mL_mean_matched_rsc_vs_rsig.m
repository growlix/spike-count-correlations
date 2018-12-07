function [binVals, binMeans, binErrors, binCenters, figureHandles]...
    = mL_mean_matched_rsc_vs_rsig(rsc,rsig,geoMeanRates,varargin)
% Computes geometric mean-matched rsc as a function of rsignal.
%
% INPUT ARGUMENTS:
%
% rsc: c x 1 cell array of vectors of rsc. Each cell is a p x 1 vector of
% rsc values. Different cells correspond to different conditions across
% which distributions of geometric mean firing rates should be matched. The
% pair of neurons generating the value at a given index should be uniform
% across cells and input arguments, e.g. rsc{1}(1), rsig{1}(1), and
% geoMeanRates{1}(1) are all derived from the same neuronal pair.
%
% rsig: c x 1 cell array of vectors of rsc
%
% geoMeanRates: c x 1 cell array of vectors of geometric mean firing rates.
%
% OPTIONAL STRING/ARGUMENT PAIRS:
%
% 'geoMeanBins': vector of bin edges for creating geometric mean firing
% histogram to be matched. The value X(i) is in the kth bin if edges(k) ?
% X(i) < edges(k+1). Strongly recommend determining your own bins by
% examining the data distributions of geometric mean firing rates you're
% providing. Defaults to number bins = ceil(1 + log2(numel(X))) where X is
% the condition with the fewest elements, and bin edges cover the minimum
% and maximum across all geoMeanRates.
%
% 'iterations': number of iterations over which to repeat the
% distribution-matching procedure. Default = 500.
%
% 'conditionNames': c x 1 cell array of strings associated with each cell
% in the other arguments.
%
% 'rSigBin': values for binning rsc values by rsig. 2 x 1 vector in which
% Defaults to  2 x 1 vector in which the first value is the bin width and
% the second value is the step size. Default = [.2 .05].
%
% 'centralFun': function handle for measure of central tendency. This is
% function applied to the values of rsc in a given rsignal bin Default =
% @nanmean.
%
% 'errorFun': function handle for measure of error/variability around
% measure of central tendency. Default = standard error, corrected for #
% iterations.
%
% OUTPUT ARGUMENTS:
% 
% binVals: 1 x c cell vector, in which each element is a cell
% vector of rsignal bins, each of which contains the values of rsc for that
% bin. E.g. binVals{1} contains a cell array of rsignal bins for the first
% condition. binVals{1}{1} contains the rsc values for the first rsignal
% bin for the first condition.
%
% binMeans: 1 x c cell vector, in which each element is a
% vector of mean rsc values for each rsignal bin. binMeans{1}(1) =
% mean(binVals{1}{1}).
%
% binErrors. Same as binMeans, except for error. binErrors{1}(1) =
% errorFun(binVals{1}{1}).
%
% binCenters. 1 x c cell array, in which each element is a vector bin
% centers for rsignal bins.
%
% Input parser
p = inputParser ;
p.addRequired('rsc') ;
p.addRequired('rsig') ;
p.addRequired('geoMeanRates') ;
p.addParameter('geoMeanBins',[]) ;
p.addParameter('iterations',500) ;
p.addParameter('conditionNames',[]) ;
p.addParameter('rSigBin',[.2 .05]) ;
p.addParameter('centralFun',@nanmean) ;
p.addParameter('errorFun',[]) ;

% Parse inputs
parse(p,rsc,rsig,geoMeanRates,varargin{:}) ;

nConditions = length(rsc) ;

nIterations = p.Results.iterations ;

% If no error function is provided, use default
if isempty(p.Results.errorFun)
    % Function for computing standard error that corrects for the number of
    % iterations
    sampleSizeAdjusted_stdErrFun = ...
        @(x) nanstd(x)./sqrt(sum(~isnan(x))./nIterations) ;
else
    errorFun = p.Results.errorFun ;
end

% Determine bins
if isempty(p.Results.geoMeanBins)
    conditionMinMax = [] ;
    conditionNumel = [] ;
    % Loop through conditions
    for conditionI = 1:nConditions
        % Geometric mean rates for current condition
        conditionGeoMeanRates = geoMeanRates{conditionI} ;
        % Min and max for condition
        conditionMinMax(conditionI,1) = min(conditionGeoMeanRates) ;
        conditionMinMax(conditionI,2) = max(conditionGeoMeanRates) ;
        % Number of elements in current condition
        conditionNumel(conditionI) = numel(conditionGeoMeanRates) ;
    end
    minNumel = min(conditionNumel) ;
    nBins = ceil(1 + log2(minNumel)) ;
    binMin = min(conditionMinMax(:,1)) ;
    binMax = max(conditionMinMax(:,2)) ;
    [~, geoMeanBins] = discretize([binMin binMax],nBins) ;
end

% Generate matched distributions
parfor i = 1:nIterations
    [~, sampleInds, ~] = ...
        mL_matchDistributions(geoMeanRates,geoMeanBins) ;
    subsampleInds{i} = sampleInds ;
end

subsampleInds = vertcat(subsampleInds{:}) ;

% signal correlation bin parameters
rSigBinSize = p.Results.rSigBin(1) ;
rSigBinStep = p.Results.rSigBin(2) ;

% Loop through each condition and plot results
for conditionI = 1:nConditions
    currSubsampleInds = subsampleInds(:,conditionI) ;
    [binMeans{conditionI}, binErrors{conditionI}, binVals{conditionI},...
        binCenters{conditionI}, figureHandles{conditionI}]...
        = mL_continuous_histogram...
    (rsig{conditionI}(currSubsampleInds),...
    rsc{conditionI}(currSubsampleInds),...
    rSigBinSize,rSigBinStep,...
    p.Results.centralFun,sampleSizeAdjusted_stdErrFun,1) ;

    plotTitle = 'rsc vs rsignal' ;
    if ~isempty(p.Results.conditionNames)
       plotTitle = [p.Results.conditionNames{conditionI} ' ' plotTitle] ;
    end
    title(plotTitle) ;
    ylabel('rsc')
    xlabel('rsignal')
    set(gca,'TickDir','out') ;
    axis square ;
end
