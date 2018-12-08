# spike-count-correlations
MATLAB tools for spike count and signal correlation analyses of neurophysiological data

These MATLAB functions compute and plot spike count correlations (*r<sub>sc</sub>*), signal correlations (*r<sub>sig</sub>*), and *r<sub>sc</sub>* as a function of *r<sub>sig</sub>*, as in [Leavitt et al. (2017) *PNAS*](https://www.pnas.org/content/114/12/E2494 "Leavitt et al. (2017) PNAS"). See [Cohen and Kohn (2011) *Nat. Neuro.*](http://marlenecohen.com/pubs/CohenKohn2011.pdf "rsc review") for an explanation and review of (*r<sub>sc</sub>*) and (*r<sub>sig</sub>*).

## Function overview.

**mL_example_rsc_rsig_analysis**: Script to demonstrate function usage. Running this will approximately recreate [Figures 2A&B](https://www.pnas.org/content/114/12/E2494#F2 "PNAS paper Figs. 2A&B") of Leavitt et al. (2017) *PNAS*.

**mL_rsc_rsig**: Compute *r<sub>sc</sub>* or *r<sub>sig</sub>*.

**mL_mean_matched_rsc**: Compute *r<sub>sc</sub>* across groups of neurons whose distributions of geometric mean firing rates have been matched (see [Methods](https://www.pnas.org/content/114/12/E2494#sec-18 "PNAS paper methods") section of Leavitt et al. (2017) PNAS).

**mL_mean_matched_rsc_vs_rsig**: Compute geometric mean-matched *r<sub>sc</sub>* as a function of *r<sub>sig</sub>*.

**mL_matchDistributions**: Function for matching distributions (see [Methods](https://www.pnas.org/content/114/12/E2494#sec-18 "PNAS paper methods") section of Leavitt et al. (2017) PNAS).

**mL_geometricMeanRates**: Simple function for computing [geometric mean](https://en.wikipedia.org/wiki/Geometric_mean "Wikipedia geometric mean") for each pair of values in a vector.

**mL_plotShadedErrorBar**: The bar plot is dead.

**ciplot**: For plotting a line with error. Lightly modified from the [version on the MATLAB file exchange]( https://www.mathworks.com/matlabcentral/fileexchange/63314-ciplot-lower-upper-x-colour-alpha).

**example_attention_data**: Data from one session of [Tremblay et al., (2015) *Neuron*](https://www.cell.com/neuron/fulltext/S0896-6273(14)01073-3 "Tremblay et al. (2015) Neuron").

Examine the function files for full details.
