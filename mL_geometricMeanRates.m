function[geoMeanRates] = mL_geometricMeanRates(rates)
% Takes a trials x neurons matrix of firing rates and computes the
% geometric mean firing rate for each neuron pair.

nNeurons = size(rates,2) ;
meanRates = nanmean(rates) ;
geoMeanRates = ones(nNeurons.*(nNeurons-1)./2,1) ;

neuronCounter = 1 ;
for neuron1 = 1:nNeurons-1
    for neuron2 = neuron1+1:nNeurons
        geoMeanRates(neuronCounter) = ...
            sqrt(meanRates(neuron1).*meanRates(neuron2)) ;
        neuronCounter = neuronCounter + 1 ;
    end
end