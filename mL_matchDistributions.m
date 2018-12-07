function [matchedDistributions, sampleInds, minDistribution] = ...
    mL_matchDistributions(data,edges)
% Bins/creates a histogram from the values in each column of [data] using
% bins defined by [edges], then matches the distributions by finding the
% minimum value in each bin across distributions and subsampling such that
% there are an identical number of values in each bin. Data can also be a
% cell array of different length vectors.
%
% matchedDistributions is a matrix in which the distributions across
% columns of [data] have been matched.
% 
% sampleInds is a matrix in which each column contains the indices sampled
% from the corresponding column in [data] to generate the matched
% distributions.
%
% minDistribution is the bin counts describing the distribution common to
% the columns in [data].
%
% Run this a bunch of times if you want an more accurate estimate of the
% matched distribution.

if iscell(data)
   largestNumel = max(cellfun(@numel,data)) ;
   dataMatrix = nan.*ones(largestNumel,length(data)) ;
   for distributionN = 1:length(data)
       currNumel = numel(data{distributionN}) ;
       dataMatrix(1:currNumel,distributionN) = data{distributionN}(:) ;
   end
   data = dataMatrix ;
end

nDistibutions = size(data,2) ;
binCounts = [] ;
binIndices = nan.*data ;

for dataColumnN = 1:nDistibutions
    [n, ~, bin] = histcounts(data(:,dataColumnN),edges) ;
    binCounts = [binCounts n'] ;
    binIndices(:,dataColumnN) = bin ;
end
% Find the minimum common distribution
minDistribution = min(binCounts,[],2) ;
% Variable to hold matched distributions
matchedDistributions = nan.*ones(sum(minDistribution),nDistibutions) ;
% Variable to hold subsampled indices
sampleInds = matchedDistributions ;
% Indices of matchedDistributions into which to place subsampled values
matchDistStartInds = [1; cumsum(minDistribution(1:end-1))+1] ;
matchDistEndInds = cumsum(minDistribution) ;
% Number of bins
nBins = size(binCounts,1) ;

% Loop through distributions
for dataColumnN = 1:nDistibutions
    % Loop through bins
    for binN = 1:nBins
        % Minimum of current bin
        currBinMin = minDistribution(binN) ;
        % Indices of data in current bin
        currDataBinInds = find(binIndices(:,dataColumnN) == binN) ;
        
        % Subsample data
        currSubsampleInds = datasample(currDataBinInds,currBinMin,...
            'replace',false) ;
        currSubsampleData = data(currSubsampleInds,dataColumnN) ;
        % Indices in matchedDistributions that will be filled with
        % subsampled data
        currStartInd = matchDistStartInds(binN) ;
        currEndInd = matchDistEndInds(binN) ;
        % Put subsampled data into matchedDistributions matrix
        matchedDistributions(currStartInd:currEndInd,dataColumnN) = ...
            currSubsampleData ;
        % Put subsampled indices into sampleInds matrix
        sampleInds(currStartInd:currEndInd,dataColumnN) = ...
            currSubsampleInds ;
        
    end
end