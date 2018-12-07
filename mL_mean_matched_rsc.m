function [centralTendency, error]...
    = mL_mean_matched_rsc(rsc,geoMeanRates,varargin)
% Computes geometric mean-matched rsc as a function of rsignal.
%
% INPUT ARGUMENTS:
%
% rsc: c x 1 cell array of vectors of rsc. Each cell is a p x 1 vector of
% rsc values. Different cells correspond to different conditions across
% which distributions of geometric mean firing rates should be matched. The
% pair of neurons generating the value at a given index should be uniform
% across cells and input arguments, e.g. rsc{1}(1) and
% geoMeanRates{1}(1) are all derived from the same neuronal pair.
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
% centralTendency: 1 x c vector of centralTendency (e.g. mean values) for
% each condition.
%
% error: same as centralTendency, but for errorFun (e.g. standard error).
%
% Input parser
p = inputParser ;
p.addRequired('rsc') ;
p.addRequired('geoMeanRates') ;
p.addParameter('geoMeanBins',[]) ;
p.addParameter('iterations',500) ;
p.addParameter('conditionNames',[]) ;
p.addParameter('centralFun',@nanmean) ;
p.addParameter('errorFun',[]) ;

% Parse inputs
parse(p,rsc,geoMeanRates,varargin{:}) ;

nConditions = length(rsc) ;

nIterations = p.Results.iterations ;

% If no error function is provided, use default
if isempty(p.Results.errorFun)
    % Function for computing standard error that corrects for the number of
    % iterations
    errorFun = ...
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

% Loop through each condition and create matched distributions
for conditionI = 1:nConditions
    currSubsampleInds = subsampleInds(:,conditionI) ;
    currSubsampledrsc = rsc{conditionI}(currSubsampleInds) ;
    centralTendency(1,conditionI) = p.Results.centralFun(currSubsampledrsc) ;
    error(1,conditionI) = errorFun(currSubsampledrsc) ;
end

mL_plotShadedErrorBar(centralTendency,centralTendency+error,centralTendency-error) ;

if ~isempty(p.Results.conditionNames)
    set(gca,'XTickLabel',p.Results.conditionNames) ;
end

ylabel('rsc')
set(gca,'TickDir','out') ;
axis square ;