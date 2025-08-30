# stackdid: Stacked Difference-in-Differences Regression

A Stata command that performs stacked difference-in-differences regression for staggered treatment settings, as described in [Gormley and Matsa (2011, 2016)](https://doi.org/10.1093/rfs/hhr011). This method offers three primary advantages compared to a standard difference-in-differences approach in such settings:

1. Not subject to earlier bias from dynamic effects
2. Can easily isolate a particular window of interest around each event
3. Can easily be extended into a triple-difference specification

## Installation

```stata
ssc install stackdid
```

## Syntax

```stata
stackdid [depvar] [indepvars] [if] [in] [weight] [, options]
```

## Options

### Main Options

* **treatment(varname)** - *(required)* A binary (0,1) indicator that an observation is treated in a given period; for example, if a group is treated only in 2004, varname equals 1 in 2004 and 0 otherwise for observations in that group.

* **group(varname)** - *(required)* The panelvar at which treatment occurs. This need not be the same panelvar as set in xtset; for example, if treatment is determined at the state-year level, specify group(state), even if the data are at the firm-year level.

* **window(numlist)** - The window of time (relative to treatment) to include in a stack. For example, window(-10 10) specifies that a 2004 cohort consists of 1994-2013 data. However, not all cohort observations in this window will necessarily enter the stack:
  - A treated group exits the stack if its treatment status subsequently turns off again
  - A control group exits the stack if it becomes treated (or, if nevertreat is specified, such groups will not be controls in the first place)

* **nevertreat** - Specifies that only never-treated groups be controls. This reduces the number of groups eligible to be used as controls, or has no effect. If this is not specified, controls consist of never-treated groups and not-yet-treated groups.

* **absorb(varlist)** - Fixed effects to be absorbed within cohorts. This means fixed effects in varlist are interacted with the cohort identifier _cohort. If this option is omitted, _cohort becomes the only fixed effect. Factor variables are allowed in varlist.

* **sw** - applies a sample weighting scheme. This adjusts for the repeated use of control units by weighting each observation by the inverse of its frequency in the stacked sample.

* **poisson** - Specifies that the model be estimated using a Poisson regression instead of a linear regression. Functionally, this changes the underlying estimation command from reghdfe to ppmlhdfe.

* **nobuild** - Does not build stacked data and proceeds directly to estimation. This option assumes the data in memory are stacked data already built by stackdid.

* **noregress** - Does not perform the estimation step.

### Estimator-specific Options

Linear regressions and Poisson regressions are allowed by stackdid thanks to the excellent estimation commands reghdfe and ppmlhdfe contributed by Sergio Correia et al. Thus, stackdid "inherits" these commands' options.

| Estimator | Description |
|-----------|-------------|
| reghdfe | Linear regression with multiple fixed effects |
| ppmlhdfe | Poisson pseudo-likelihood regression with multiple fixed effects |

### Display Options

* **nolog** - Suppresses printing to console a build log.

### Saving Options

* **clear** - Replaces the data in memory with the stacked data built by stackdid and used by estimator. This option must be specified if the post-estimation return function e(sample) is desired. If clear is not specified, the original data in memory are restored after estimation.

* **saving(filename [, replace])** - Saves the stacked cohorts built by stackdid and used by estimator to filename.
  - replace permits saving() to overwrite an existing dataset.

## Remarks

**Treatment Types**: Treatment may be considered permanent or impermanent. In the case of Gormley & Matsa (2011), treatment is permanent, meaning it remains on once on. For data like this, stackdid executes exactly as described in that paper. In the case of Gormley & Matsa (2016), treatment is impermanent, meaning it may turn off after being on. Once again, stackdid executes exactly as described in that paper, and issues the notice "impermanent treatment detected". There is no need to tell stackdid what type the data are—it is automatically detected. Finally, in the most general case of impermanent treatment (where treatment may turn on and off any number of times), stackdid executes in the style of the papers above, selecting valid pre and post observations for each treatment event.

stackdid has two primary features. Options are provided to isolate either of these. If both of these options are specified, stackdid does nothing.

| Feature | Optionally Off |
|---------|----------------|
| (1) build stacked data | nobuild |
| (2) perform specified regression | noregress |

Practitioners often build upon a baseline specification with increasingly strict fixed effects and/or controls. stackdid will always create the same stacks when the required options (treatment() and group()), window() and nevertreat are the same. Thus, one can reduce redundant computation using the clear option in the first specification and the nobuild option in subsequent specifications.

stackdid requires the data to be a panel set by xtset. There is no requirement to be strongly balanced.

## Examples

Generically, adapting specifications to stacked regressions can be as simple as replacing reghdfe (or ppmlhdfe) with stackdid and specifying the two required options, treatment() and group().
```stata
reghdfe  y x1 x2 x3, absorb(w1#w2) cluster(w1)
stackdid y x1 x2 x3, absorb(w1#w2) cluster(w1) tr(x1) gr(g1)
```

Specific examples are illustrated using simulated data. In it, a balanced panel of 500 fictional firms (firm_id) in 2000-2011 are divided into eleven groups (sector) with three treatment events. The outcome variable (y) has an autoregressive component persistent in continuous treatment, encouraging the application of stackdid. The sample of firms is bisected by binary characteristic char. A window of three years before and after treatment events is to be specified.

```stata
* Load the example data and apply xtset
use https://raw.githubusercontent.com/jacobwtriplett/stackdid/main/stackdid_example
xtset firm_id year

* Basic usage
stackdid y treatXpost, tr(treatXpost) gr(sector) w(-3 3)

* Subsequent specifications
stackdid y treatXpost, tr(treatXpost) gr(sector) w(-3 3) clear
stackdid y treatXpost, nobuild absorb(firm_id)

* Triple difference
stackdid y treatXpost treatXpostXchar, nobuild absorb(year#char)

* If group() is needed for estimator
stackdid, tr(treatXpost) gr(sector) w(-3 3) clear noreg
estimator y treatXpost, group(...)

* Suggested: visually decompose cohorts
table (sector) (year) (_cohort), statistic(firstnm treatXpost) nototal
```

## Stored Results

stackdid stores the following in r():

### Scalars
* r(N_original) - Number of observations in original data
* r(N_stacked) - Number of observations in stacked data (also see e(N))

### Macros
* r(cmdline) - Command as typed
* r(regline) - Command fed to estimator (also see e(cmdline))
* r(treatment) - Treatment variable
* r(group) - Group variable
* r(window) - Window numlist

See estimator's help file for results stored in e().

## Author

Jacob Triplett  
University of North Carolina  
Kenan-Flagler Business School  
jacob_triplett@kenan-flagler.unc.edu

## Acknowledgments

I wish to thank Todd Gormley for the inspiration to develop this package, and Todd Gormley and David Matsa for invaluable guidance during its development.

## References

- Sergio Correia, Paulo Guimarães, Thomas Zylkin: "ppmlhdfe: Fast Poisson Estimation with High-Dimensional Fixed Effects", 2019; arXiv:1903.01690.

- Sergio Correia, 2014. "REGHDFE: Stata module to perform linear or instrumental-variable regression absorbing any number of high-dimensional fixed effects," Statistical Software Components S457874, Boston College Department of Economics, revised 2 23.

- Todd A. Gormley, David A. Matsa, Growing Out of Trouble? Corporate Responses to Liability Risk, The Review of Financial Studies, Volume 24, Issue 8, August 2011, Pages 2781–2821, https://doi.org/10.1093/rfs/hhr011.

- Todd A. Gormley, David A. Matsa, Playing it safe? Managerial preferences, risk, and agency conflicts, Journal of Financial Economics, Volume 122, Issue 3, 2016, Pages 431-455, ISSN 0304-405X, https://doi.org/10.1016/j.jfineco.2016.08.002.

- Todd A. Gormley, Manish Jha, and Meng Wang, The Politicization of Social Responsibility (March 11, 2024). Available at SSRN: https://ssrn.com/abstract=4558097
