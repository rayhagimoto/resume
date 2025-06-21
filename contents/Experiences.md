# Profile

I'm Ray Hagimoto. I was born and raised in Singapore, where I lived until I was 18.
I moved to Texas to pursue an education in Physics. I enjoy highly collaborative environments, writing software, and solving complex problems. 

# Tech Stack
- Primary language: Strongest in Python; experienced with scientific computing, machine learning, and data analysis using libraries such as numpy, pandas, LightGBM, PyMC, TensorFlow, matplotlib, and OpenCV. Most modeling, scripting, and research workflows have been Python-based.

- C++: Basic working knowledge. Comfortable reading, modifying, and integrating small C++ modules into Python pipelines (e.g., via bindings or performance-critical routines), but not proficient in low-level systems programming or large-scale C++ development. Not suited for C++-centric roles without ramp-up time.

- SQL: No production experience yet. Completed foundational training (IBM Coursera course) and capable of querying structured data and performing joins and aggregations. Would require practice for advanced data engineering workflows.

- Workflow and infrastructure: Familiar with Docker, SLURM, AWS Lambda, and S3 for orchestrating experiments and automating pipelines. Experience building containerized, serverless inference systems with real-time alerting.

- Learning agility: Have successfully ramped up on unfamiliar tools and frameworks (e.g., PyMC, ArviZ, serverless CV workflows) for research and production-grade projects. Enjoy steep learning curves and adapting to new technical stacks when required.

# Graduate student projects

## Searching for axion-like particles through CMB birefringence from string-wall networks (JCAP 2022)

Designed and implemented a Bayesian inference pipeline to constrain axion-like particle (ALP) models using cosmic microwave background (CMB) polarization data. Developed a modular simulation framework in Python to model birefringence signals produced by string-wall networks of topological defects, and evaluated their imprint on anisotropic CMB polarization. Used PyMC and Aesara to construct differentiable log-likelihood functions, perform Markov Chain Monte Carlo (MCMC) sampling, and extract posterior distributions for physically meaningful parameters.

Built numerically stable estimators for the birefringence angular power spectrum using symbolic computation, trapezoidal integration, and Legendre polynomial transforms. Constructed anisotropic birefringence sky maps from Monte Carlo simulations on the HEALPix sphere, validating analytic approximations with ensemble averages. Applied both Gaussian and chi-squared likelihood models to observational data, enabling consistent statistical inference across angular scales and instrument datasets.

Produced all figures for the final publication and carried out the full analysis that led to the project’s central result: placing the first constraints on birefringence signals from collapsing axion string-wall networks. Found no evidence for anisotropic birefringence, placing upper bounds on the ALP-photon coupling and defect network parameters. Demonstrated that recent claims of isotropic birefringence are difficult to reconcile with the non-detection of anisotropic effects, motivating future observational efforts. Published these results in the Journal of Cosmology and Astroparticle Physics.

Project outcomes contributed to theoretical modeling of ALP topological defects and shaped the interpretation of polarization data from Planck, ACTpol, SPTpol, BICEP2, and Polarbear. Helped identify signal features relevant to next-generation CMB experiments such as LiteBIRD and CMB-S4.

Demonstrated expertise in simulation-based inference, probabilistic programming, scientific computing, and model validation using real-world data. Built transferable skills in Bayesian statistics, Python-based data analysis, and uncertainty quantification applicable to data science, machine learning, and quantitative research roles.

## Measures of non-Gaussianity in axion-string induced CMB birefringence (JCAP 2023)

Developed simulation and analysis pipeline to quantify non-Gaussian signatures of axion-string-induced cosmic birefringence in the cosmic microwave background (CMB). Implemented the loop-crossing model in Python to generate over 150,000 birefringence sky map realizations and computed spherical harmonic multipole coefficients to evaluate higher-order statistics, including kurtosis and bispectrum. Derived and validated an analytical expression for the excess kurtosis that accurately matches simulation results across a range of angular scales. Demonstrated that the kurtosis is consistently positive at low multipoles and decreases with multipole index following a broken power law. Calculated the sample variance of the bispectrum estimator and identified deviations of up to 80% from the Gaussian expectation at low multipoles. Results show that higher-order statistics can break parameter degeneracies in the birefringence power spectrum, enabling independent constraints on the axion-photon coupling and string network properties. Findings support the use of non-Gaussian features as a diagnostic for axion-string-induced birefringence in future CMB experiments.

## Neutron star cooling with lepton-flavor-violating axions (Phys. Rev. D 2024)

Developed a high-performance Python codebase to compute axion emissivities from lepton-flavor-violating scattering processes in neutron star cores, enabling the first astrophysical constraints on the axion coupling between electrons and muons using neutron star cooling arguments. Implemented a nine-dimensional phase space integral using adaptive Monte Carlo integration with the VEGAS algorithm, incorporating relativistic kinematics, thermal Fermi-Dirac distributions, and spin-summed matrix elements across six distinct scattering channels. Optimized numerical routines using just-in-time compilation and validated analytical approximations against full numerical results, achieving agreement within ten percent over a wide parameter range. Extended the calculations to supernova conditions by accounting for plasma screening effects and evaluating emissivities up to one hundred MeV.

These results established new astrophysical limits on the axion coupling strength that are competitive with, and in some cases stronger than, the best existing laboratory and cosmological bounds. Published in Journal of Cosmology and Astroparticle Physics, the work advances the use of stellar environments as probes of feebly interacting new physics in the lepton sector.

## Extracting axion string network parameters from simulated CMB birefringence maps using convolutional neural networks (JCAP 2025)

Developed simulation and inference pipeline to extract axion string network parameters from cosmic microwave background birefringence maps using spherical convolutional neural networks. Implemented the full birefringence simulation framework under the loop-crossing model, including stochastic sampling, HEALPix-based map generation, and scalable Monte Carlo workflows. Trained neural networks to estimate model parameters and constructed likelihood-free inference algorithms using approximate Bayesian computation, validating the networks' ability to recover parameter combinations that are inaccessible to standard power spectrum analyses. Demonstrated that the networks can infer both power spectrum–driven parameters and orthogonal combinations sensitive to higher-order statistics. Quantified estimator precision and evaluated robustness under varying noise levels, showing predictable degradation in accuracy at experimental noise scales.

Established that machine learning methods can break parameter degeneracies present in conventional analyses, enabling new constraints on axion-like particles through non-Gaussian features in birefringence. This work provides the first demonstration of extracting axion string signatures beyond the power spectrum using neural networks, with relevance for future CMB experiments.

Demonstrated skills in scientific computing, deep learning with TensorFlow, spherical data modeling, simulation-based inference, parallel programming, and statistical visualization.

# Susquehanna International Group Internship (June 2024 – Aug 2024)

I participated in a 10-week quantitative research internship at Susquehanna International Group, the largest U.S. equity options market maker. My focus was building predictive models for short-horizon trading decisions using high-frequency options and equities data in a simulated environment. The internship included structured training on derivatives pricing, market microstructure, and competitive signal-based strategy design.

My core project involved designing and implementing predictive models and signal-to-execution logic in a backtestable framework. I engineered features informed by domain intuition—particularly around trade flow and possible hedging effects—to help predict short-term equity price direction. These features served as inputs to boosted decision tree classifiers trained using LightGBM, with validation-based early stopping and out-of-sample testing to evaluate generalization.

I used a rolling train-validation-test structure, typically 6 months for training, 3 for validation, and 3 for testing. I monitored validation loss to decide early stopping points and selected models based on their best performance before overfitting. I evaluated the models’ performance using residuals, precision-recall scores, and profit-focused metrics aligned with strategy goals.

While I worked with time-ordered financial data, I did not perform traditional time series analysis such as ARIMA, GARCH, or seasonality modeling during the internship. My exposure to those techniques comes from separate interview exercises at SIG and Cubist, where I was asked to:

Forecast two-month forward volatility using ARIMA (via statsmodels).

Investigate whether a proposed signal had predictive power for asset prices using linear regression.

In both cases, I self-studied the necessary time series methods and produced full reports (included in my materials) that demonstrate my ability to learn and apply statistical forecasting models when required.

# Personal Projects

**Automated Wildlife Detection and Alert System (AWS + OpenCV)**
*Remote — 2025*
Designed and deployed a real-time anomaly detection pipeline using AWS Lambda, S3, and OpenCV to monitor backyard wildlife via camera trap images. Built a custom background subtraction algorithm with a running exponential moving average, luminance thresholding, and feature-based contour scoring to detect object-level anomalies based on size, shape, and aspect ratio. Integrated two Lambda functions: one for CV inference and one for secure upload handling via presigned S3 URLs. Used Tasker automation to upload compressed images from an Android device to S3, triggering detection. Connected a Telegram bot to push annotated image alerts in real time (within seconds). Gained experience in cloud-native CV deployment, event-driven architecture, and end-to-end ML pipeline robustness testing.

* Built a cloud-native detection pipeline with AWS and OpenCV for real-time wildlife monitoring.
* Engineered image differencing with contour scoring to enhance anomaly detection.
* Deployed event-driven Telegram alerts with sub-second latency from image capture to notification.

**Automated Resume Templater**
[GitHub: https://github.com/rayhagimoto/resume](https://github.com/rayhagimoto/resume) — 2025
Built a containerized resume generation tool that compiles YAML-formatted resume content into an ATS-compatible PDF using LaTeX and `latexmk`. Designed for cross-platform reproducibility and consistent rendering via a Dockerized build pipeline. Users define content modularly in YAML, enabling structured sections that can be swapped or extended. The system integrates a custom LaTeX template submodule for optimized formatting and emphasizes developer-centric usability and reproducible builds.

* Built a YAML-to-PDF resume generator using LaTeX and Docker for consistent, portable builds.
* Enabled modular content editing and custom template styling with reproducible environments.
