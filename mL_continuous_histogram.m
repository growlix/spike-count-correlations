function [values, binError, binVals, binCenter, h] = ...
    mL_continuous_histogram...
    (binData,plotData,binSize,stepSize,valueFun,errorFun,plotIt)
% Generates a histogram from binData, then finds all the corresponding
% values in plotData for each bin in binData, computes the valueFun for the
% value in each bin, stepped by stepSize, and plots the error for each bin
% [errorFun]. First bin starts at the first value. Note binData and
% plotData are paired; each index of binData corresponds to the same index
% in plotData. 'plotIt' is a logical indicating whether it should be
% plotted.

if (exist('plotIt','var') && isempty(plotIt))
    plotIt = 1 ;
elseif ~exist('plotIt','var')
    plotIt = 1 ;
end

minVal = nanmin(binData) ;
maxVal = nanmax(binData) ;

binStart = minVal ;
binEnd = minVal + binSize ;

dataIncomplete = 1 ;

values = [] ;
binError = [] ;
binCenter = [] ;

binVals = {} ;
binN = 1 ;

while dataIncomplete
    
    inCurrBin = plotData(binData>=binStart & binData<binEnd) ;
    currBinVal = valueFun(inCurrBin) ;
    values = [values currBinVal] ;
    binVals{binN} = inCurrBin;
    currBinError = errorFun(inCurrBin) ;
    binError = [binError currBinError] ;
    binCenter = [binCenter (binStart+binEnd)/2] ;
    
    if isempty(binData) || binEnd > maxVal
        dataIncomplete = 0 ;
    end
    
    binStart = binStart + stepSize ;
    binEnd = binEnd + stepSize ;
    binN = binN+1 ;
end

if plotIt
    h = figure ;
    hold on ;
    ciplot(values-binError,values+binError,binCenter,[.5 .5 .5]) ;
    plot(binCenter,values,'color','k') ;
    hold off ;
end