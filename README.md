# speech_sound_categorization
Data DOI: https://doi.org/10.34973/9ayw-yf48

Article title: Speech sound categorization: The contribution of non-auditory and auditory cortical regions
Authors: Basil C. Preisig, Lars Riecke, & Alexis Hervais-Adelman
Article DOI: https://doi.org/10.1016/j.neuroimage.2022.119375
Correspondance: basilpreisig@gmail.com

Content information

This collection contains all data and code to reproduce the analyses described in Preisig, Riecke, &
Hervais-Adelman (2022). For privacy reasons, all native space anatomical scans are defaced. All steps
that require the identifiable anatomical scan (fMRI preprocessing steps: (1) functional realignment and
unwarping, (2) co-registration of the structural image to the mean EPI, (3) normalization of the
structural image to a standard template, (4) application of the normalization parameters to all EPI
volumes) cannot be reproduced. Evidently, all derivatives (normalized T1.nii, normalized and smoothed
functional images, and motion parameters) from these preprocessing steps that are necessary to
reproduce subsequent analyses are shared.
Code
Most of the analysis code is written in MATLAB. A comprehensive overview and a stepwise description
of all analyses is provided by the file code/README_data_analysis_steps.m. The analysis scripts write
firstlevel data (at the individual participant level) into participant subfolders. Additional grouplevel
analyses will be stored in the subfolder /analyses. In principle, one only needs to install all the relevant
software (see dependencies) and to set the appropriate folderpaths in README_data_analysis_steps.m
to run the analyses.

Dependencies

MATLAB
• SPM12 (http://www.fil.ion.ucl.ac.uk/spm)
• TDT – The decoding toolbox (https://sites.google.com/site/tdtdecodingtoolbox/)
• Fieldtrip (https://www.fieldtriptoolbox.org/)
• cBrewer (https://ch.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-
schemes-for-matlab)
• mseb (https://ch.mathworks.com/matlabcentral/fileexchange/47950-mseb-x-y-errbar-
lineprops-transparent)
R (https://www.r-project.org/)
JASP (https://jasp-stats.org/)
Other important resources
https://neurostars.org/ (TDT mailing list)
https://doi.org/10.34973/dt33-sj34 (The published data collection from our previous study using this
dataset)
