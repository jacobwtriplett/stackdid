# stackdid: Stacked Difference-in-Differences Regression

A Stata command that performs stacked difference-in-differences regression for staggered treatment settings, as described in [Gormley and Matsa (2011)](https://doi.org/10.1093/rfs/hhr011).

## Key Features

- Not subject to bias from dynamic effects
- Can easily isolate a particular window of interest around each event
- Can easily be extended into a triple-difference specification

## Installation

```stata
ssc install stackdid
```

## Syntax

```stata
stackdid [depvar] [indepvars] [if] [in] [weight] [, options]
```

### Required Options
- `treatment(varname)`: Binary treatment indicator
- `group(varname)`: Panelvar at which treatment occurs

### Optional Options
- `window(numlist)`: Window of time to consider relative to treatment
- `nevertreat`: Use only never-treated observations as controls
- `absorb(varlist)`: Fixed effects to be absorbed
- `poisson`: Estimate a Poisson regression instead of linear regression
- `nobuild`: Do not build stacked data
- `noregress`: Do not perform regression

See help file for complete options list.

## Example Usage

```stata
* Load example data
use https://raw.githubusercontent.com/jacobwtriplett/stackdid/main/stackdid_example
xtset firm_id year

* Basic usage
stackdid y treatXpost, tr(treatXpost) gr(sector) w(-3 3)

* With fixed effects
stackdid y treatXpost, tr(treatXpost) gr(sector) w(-3 3) clear
stackdid y treatXpost, nobuild absorb(firm_id)

* Triple difference
stackdid y treatXpost treatXpostXchar, nobuild absorb(year#char)
```

## Technical Details

The command restructures data into "stacks" of "cohorts" centered on treatment events. The typical specification is:

```
y = beta*D + delta + alpha + epsilon
```

where:
- D: Treatment indicator
- delta: Cohort-time fixed effect
- alpha: Unit-cohort fixed effect
- epsilon: Random disturbance

## Dependencies

Relies on estimation commands contributed by Sergio Correia et al.:
- `reghdfe`: Linear regression with multiple fixed effects
- `ppmlhdfe`: Poisson pseudo-likelihood regression with multiple fixed effects

## Author

Jacob Triplett  
University of North Carolina  
Kenan-Flagler Business School  
jacob_triplett@kenan-flagler.unc.edu

## Acknowledgments

Thanks to Todd Gormley for the inspiration to develop this package, and Todd Gormley and David Matsa for invaluable guidance during its development.

## References

- Gormley, T. A., & Matsa, D. A. (2011). Growing Out of Trouble? Corporate Responses to Liability Risk. The Review of Financial Studies, 24(8), 2781-2821. https://doi.org/10.1093/rfs/hhr011
- Correia, S., Guimarães, P., & Zylkin, T. (2019). ppmlhdfe: Fast Poisson Estimation with High-Dimensional Fixed Effects. arXiv:1903.01690
- Correia, S. (2014). REGHDFE: Stata module to perform linear or instrumental-variable regression absorbing any number of high-dimensional fixed effects. Statistical Software Components S457874
