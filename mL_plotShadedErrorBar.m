function[] = mL_plotShadedErrorBar(yData,upper,lower,varargin)

% Because bar plots shouldn't exist anymore. Plots the data in yData with
% error bars determined by upper and lower.
%
% INPUT ARGUMENTS data, vector. means, medians, variances, whatever.
%
% upper, vector. same size as data. upper error bar limit.
%
% lower, vector. lower error bar limit.
%
% OPTIONAL STRING/ARGUMENT PAIRS
%
% 'xData', x axis vaues.
%
% 'handle', figure handle.
%
% 'width', scalar. Half the width of error bars. Defaults to .15 (bar width
% of .5) or .25 of the smallest interval between xData values.

p = inputParser ;
p.addRequired('yData') ;
p.addRequired('upper') ;
p.addRequired('lower') ;

% Optional string-argument pairs
p.addParameter('handle',[]) ;
p.addParameter('xData',[]) ;
p.addParameter('width',.15) ;
p.addParameter('color',[.5 .5 .5]) ;

parse(p,yData,upper,lower,varargin{:}) ;

barWidth = p.Results.width ;

if ~isempty(p.Results.xData)
    xData = p.Results.xData ;
    xDataDiff = diff(xData) ;
    if length(xDataDiff) > 0
        barWidth = min(xDataDiff)/4 ;
    end
else
    xData = 1:length(upper) ;
end

yVertices = [upper; upper; lower; lower] ;
xVertices = [xData-barWidth; xData+barWidth; xData+barWidth; xData-barWidth] ;

if isempty(p.Results.handle)
    figure ;
else
    figure(p.Results.handle)
end

hold on ;
patch(xVertices,yVertices,p.Results.color,'FaceAlpha',.5,'EdgeColor','none') ;

if ~isempty(yData)
    plotXData = [xData-barWidth; xData+barWidth] ;
    plotYData = [yData; yData] ;
    plot(plotXData,plotYData,'LineWidth',1.5,'Color',p.Results.color) ;
end
set(gca,'XTick',xData) ;