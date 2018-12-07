function [r, p, pair] = mL_rsc_rsig(rates,varargin)

% Computes spike count correlations (rsc) or signal correlations(rsig)
% between pairs of neurons. Spike count correlations are defined as the
% Pearson's correlation of the variability of two neurons' responses to
% repeated presentations of the same stimulus. Signal correlations are
% defined as the correlation between two neurons' mean responses to a set
% of stimuli.
%
% INPUT ARGUMENTS:
%
% rates: a t x n matrix of spike rates, in which t = trials and n =
% neurons.
%
% OUTPUT ARGUMENTS:
%
% r: a p x 1 vector of Pearson's correlation coefficients. p: a p x 1
% vector of p-values. pair: a p x 2 matrix indicating the ordinal identity
% of each of the two neurons for which the correlation was computed (e.g.
% [2 1; 3 1; ...] denotes that neurons 2 and 1, comprise the first pair,
% neurons 3 and 1, comprise the second pair, etc.). The order is as output
% from the pdist function: (2,1), (3,1), ..., (n,1), (3,2), ..., (n,2),
% ..., (n,n?1)
%
% OPTIONAL STRING/ARGUMENT PAIRS
%
% 'corr': a string indicating which type of correlation to compute, either
% 'rsc' for spike count correlation (default) or 'rsig' for signal
% correlation.
%
% 'class': a t x 1 vector of integers indicating the associated class (e.g.
% stimulus) for each each trial. Each unique class is normalized
% separately. If no value is passed for 'class', will assume all trials
% belong to the same class.
%
% 'minimumRate': scalar > 0. Neurons with a mean firing rate < minimumRate
% will be excluded from analysis and will have their associated rsc values
% set to nan. Default = 1Hz.

% Input parser
p = inputParser ;
p.addRequired('rates') ;
p.addParameter('class',[]) ;
p.addParameter('minimumRate',1) ;
p.addParameter('corr','rsc') ;

% Parse inputs
parse(p,rates,varargin{:}) ;

nTrials = size(rates,1) ;
nNeurons = size(rates,2) ;
compute_rsc = true ;
% Check if computing signal or spike count correlation
if strcmp(p.Results.corr,'rsig')
    compute_rsc = false ;
end

% If 'class' is not provided, make a vector of ones
class = p.Results.class ;
if isempty(class)
    class = ones(nTrials,1) ;
end

% NaN out low firing rate units
meanRates = nanmean(rates) ;
belowThresholdNeurons = meanRates < p.Results.minimumRate ;
rates(:,belowThresholdNeurons) = nan ;

% Unique classes
uniqueClasses = unique(class) ;
% Number of unique classes
nClasses = length(uniqueClasses) ;
% Initialize matrix to hold transformed rates. Matrix will be different
% size depending on whether computing signal or spike count correlations.
if compute_rsc
    transformedRates = nan.*ones(size(rates)) ;
else
    transformedRates = nan.*ones(nClasses,nNeurons) ;
end
% Iterate through each class and normalize firing rates
for classI = 1:nClasses
    % Current class
    currClass = uniqueClasses(classI) ;
    % Indices of trials belonging to current class
    currClassInds = class == currClass ;
    currClassRates = rates(currClassInds,:) ;
    
    if compute_rsc
        % Normalize (z-score) firing rates in current class
        transformedRates(currClassInds,:) = (currClassRates - ...
            nanmean(currClassRates))./nanstd(currClassRates) ;
    else
        transformedRates(classI,:) = nanmean(currClassRates) ;
    end
end

% Compute pearson's correlation
[r, p] = corrcoef(transformedRates,'rows','pairwise') ;
% Convert from matrices to vectors
r = internalMat2Vec(r) ;
p = internalMat2Vec(p) ;

% Determine pairs
pairMat1 = repmat(1:nNeurons,nNeurons,1) ;
pairMat2 = repmat((1:nNeurons)',1,nNeurons) ;

pair = [internalMat2Vec(pairMat1) internalMat2Vec(pairMat2)] ;

end

function[outputVector] = internalMat2Vec(inputMatrix)
% Returns lower triangular component of matrix as a vector
outputVector = inputMatrix(tril(true(size(inputMatrix)),-1)) ;
end
