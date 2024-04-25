{smcl}
{* *! version 0.1  27feb2024}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "References" "references##references"}{...}

{title:Title}

{phang}
{bf:stackdid} {hline 2} Stacked Difference-in-Differences Regression

{marker syntax}{...}
{title:Syntax}

{p 8 20 2}
{cmdab:stackdid}
[{depvar}]
[{indepvars}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab: Main}
{p2coldent:* {opth tr:eatment(varname)}}binary treatment indicator{p_end}
{p2coldent:* {opth gr:oup(varname)}}panelvar at which treatment occurs{p_end}
{p2coldent:* {opth t:ime(varname)}}timevar at which treatment occurs{p_end}
{p2coldent:* {opth w:indow(numlist)}}window of time to consider relative to treatment{p_end}
{synopt:{opt nevertreat}}use only never-treated observations as controls; default
behavior is to use never-treated and not-yet-treated observations{p_end}
{synopt:{opt poisson}}estimate a Poisson regression instead of a linear regression{p_end}
{synopt:{opt nobuild}}do not build stacked data{p_end}
{synopt:{opt noreg:ress}}do not perform regression{p_end}

{syntab: Estimator-specific options}
{synopt:{bf:{help reghdfe##options:reghdfe}}}options for {cmd:reghdfe}{p_end}
{synopt:{bf:{help ppmlhdfe##options:ppmlhdfe}}}options for {cmd:ppmlhdfe} if 
{cmd:poisson} specified{p_end}

{syntab: Display}
{synopt:{opt notab:ulate}}do not display tabulation of treatment panel{p_end}
{synopt:{opt nolog}}do not display build log{p_end}

{syntab: Saving}
{synopt:{opt clear}}replace data in memory with stacked data used in regression{p_end}
{synopt:{opt saving(filename, ...)}}save stacked data to {it:filename}; see {helpb saving_option:[G-3] saving option}{p_end}

{synoptline}
{p2coldent:{cmd:by} is allowed; see {help prefix}.}{p_end}
{p2coldent:for allowed weights, see {it:estimator}'s help file.}{p_end}
{p2coldent:* starred options are required, unless {cmd:nobuild} is specified.}{p_end}

{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stackdid} performs a stacked difference-in-differences regression for 
staggered treatment settings, as described in Gormley and Matsa (2011).  It offers three primary advantages compared to a standard difference-in-differences approach in such settings:{p_end}

{phang2}(1) is not subject to earlier bias from dynamic effects{p_end}
{phang2}(2) can easily isolate a particular window if interest around each event{p_end}
{phang2}(3) can easily be extended into a triple-difference specification{p_end}

{pstd}This method generally requires restructuring the data in memory into "stacks"
of "cohorts" centered on treatment events.  {cmd:stackdid} will create these stacks 
and perform the specified regression.  The typical specification is{p_end}

{phang2} y_{ict} = {\beta}d_{ict} + {\delta}_{ct} + {\alpha}_{ic} + u_{ict} {p_end}

{pstd}
where d_{ict} is a treatment indicator, {\delta}_{ct} is a cohort-time fixed effect,
and {\alpha}_{ic} is a group-cohort fixed effect.  Since {cmd:stackdid} creates 
the stacks of cohorts, it also creates the cohort-time fixed effect and the 
group-cohort fixed effect; the user may specify additional fixed effects 
using {cmd:absorb()}.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth tr:eatment(varname)} is a binary (0,1) indicator that an observation is 
treated;  for example, if a group is treated only in 2004, {it:varname} equals 1 
in 2004 and 0 otherwise for observations in that group.  Missing values are 
allowed and denote unobserved treatment status.

{phang}
{opth gr:oup(varname)} is the panelvar at which treatment occurs.

{phang}
{opth t:ime(varname)} is the timevar at which treatment occurs.

{phang}
{opth w:indow(numlist)} is the window of time (relative to treatment) to include in a stack; for example, {cmd:window(-10 10)} specifies ten years before and after treatment.  However, not 
all cohort observations in this window will 
necessarily enter the stack: first, a treated group exits the stack if its 
treatment status subsequently turns off again.  Second, a control group exits 
the stack if it becomes treated (or, if {cmd:nevertreat} is specified, such 
groups will not be controls in the first place).

{phang}
{opt nevertreat} specifies that only never-treated groups be controls.  This reduces
the number of groups eligible to be used as controls, or has no effect.  If this 
is not specified, controls consist of never-treated groups {it:and} not-yet-treated 
groups.

{phang}
{opt poisson} specifies that the model be estimated using a poisson regression 
instead of a linear regression.  Functionally, this changes the underlying 
estimation command from {cmd:reghdfe} to {cmd:ppmlhdfe}; see 
{it:estimator-specific options}.

{phang}
{opt nobuild} does not build stacked data and proceeds directly to estimation.  
This option assumes the data in memory are stacked data already built by {cmd:stackdid}.  
See {help stackdid##remarks:remarks} for the intended use case.

{phang}
{opt noreg:ress} does not perform the estimation step.


{dlgtab:Estimator-specific options}

{pstd}
Linear regressions and Poisson regressions are allowed by {cmd:stackdid} thanks
to the {it:excellent} estimation commands {cmd:reghdfe} and {cmd:ppmlhdfe} contributed
by Sergio Correia et al.  Thus, {cmd:stackdid} "inherits" these commands' options;
see their help files for full documentation.{p_end}

{synoptset 22}{...}
{synopthdr:estimator}
{synoptline}
{synopt:{bf:{help reghdfe}}}linear regression with multiple fixed effects{p_end}
{synopt:{bf:{help ppmlhdfe}}}Poisson psuedo-likelihood regression with multiple fixed effects{p_end}
{synoptline}

{dlgtab:Display}

{phang}
{opt notab:ulate} suppress printing to the console a tabulation of treatment 
across {it:group} and {it:time}.  Such a tabulation can be a useful data 
visualization (both before and after building stacked data), but is unweildy for 
many groups and long ranges of time.

{phang}
{opt nolog} suppresses printing to console a build log.

{dlgtab:Saving}

{phang}
{opt clear} replaces the data in memory with the stacked data built by {cmd:stackdid} and used by {it:estimator}.  This option must be specified
if the post-estimation return function {cmd:e(sample)} is desired.  If {cmd:clear}
is not specified, the original data in memory are restored after estimation.

{phang}
{opt saving(filename [, replace])} saves the stacked cohorts built by {cmd:stackdid}
 and used by {it:estimator} to {it:filename}.
 
{phang2}{opt replace} permits {cmd:saving()} to overwite an existing dataset.{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:stackdid} has three primary features.  Options are provided to isolate any
one or two of these. If all three of these options are specified, {cmd:stackdid} 
does nothing.

{phang2}{space 4}{it:feature}{space 32}{it:optionally off}{p_end}
{phang2}{hline 57}{p_end}
{phang2}(1) tabulate treatment panel to console{space 4}{opt notab:ulate}{p_end}
{phang2}(2) build stacked data{space 21}{opt nobuild}{p_end}
{phang2}(3) perform specified regression{space 11}{opt noreg:ress}{p_end}
{phang2}{hline 57}{p_end}

{pstd}
Practictioners often build upon a baseline specification with increasingly strict
fixed effects and/or controls.  {cmd:stackdid} will always create the same stacks
when the required options ({cmd:treatment()}, {cmd:group()}, {cmd:time()}, {cmd:window()}) and {cmd:nevertreat} are the same.  Thus, one can reduce redundant computation using the {cmd:clear} 
option in the first specification and the {cmd:nobuild} option in subsequent 
specifications.

{pstd}
Although {cmd:stackdid} without the {cmd:clear} option returns the original 
data, Stata will flag it as having changed.  This is an artifact of building 
stacks in memory, adjacent to the original data.  The consequence is that 
{cmd:use} and {cmd:exit} will prompt you to clear the data in memory.


{marker examples}{...}
{title:Examples}

{pstd}
An example dataset is included in the {cmd:stackdid} package.  Half of the fifty 
groups are initially assigned 'treated' status, and every four years a group 
changes treatment status with probability 0.25.  The outcome variable has an 
autoregressive component persistent in continuous treatment, encouraging the 
application of {cmd:stackdid}.  A window of five years before and after 
treatment events is to be specified.

{pstd}Load the example data{p_end}
{phang2}{cmd:. use stackdid_example, clear}{p_end}

{pstd}Basic usage{p_end}
{phang2}{cmd:. stackdid y treatment, tr(treatment) gr(group) t(time) w(-5 5)}{p_end}

{pstd}Subsequent specifications{p_end}
{phang2}{cmd:. stackdid y treatment, tr(treatment) gr(group) t(time) w(-5 5) clear}{p_end}
{phang2}{cmd:. stackdid y treatment, nobuild absorb({it:some_fe})}{p_end}

{pstd}Triple difference{p_end}
{phang2}{cmd:. }{it:todo}{p_end}

{pstd}If {opt group()} is needed for {it:estimator}{p_end}
{phang2}{cmd:. stackdid, tr(treatment) gr(group) t(time) w(-5 5) clear noreg}{p_end}
{phang2}{cmd:. {it:estimator} y treatment, group(...)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:stackdid} stores the following in {cmd:r()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 26 2: Scalars}{p_end}
{synopt:{cmd:r(N_orig)}}number of observations in original data{p_end}
{synopt:{cmd:r(N_stacked)}}number of observations in stacked data (also see {cmd:e(N)}){p_end}

{p2col 5 23 26 2: Macros}{p_end}
{synopt:{cmd:r(cmdline)}}command as typed{p_end}
{synopt:{cmd:r(regline)}}command fed to {it:estimator} (also see {cmd:e(cmdline)}){p_end}
{synopt:{cmd:r(treatment)}}treatment variable{p_end}
{synopt:{cmd:r(group)}}group variable{p_end}
{synopt:{cmd:r(time)}}time variable{p_end}
{synopt:{cmd:r(window)}}window numlist{p_end}

{pstd}
See {it:estimator}'s help file for results stored in {cmd:e()}.


{title:Author}

{pstd}Jacob Triplett{p_end}
{pstd}Carnegie Mellon University{p_end}
{pstd}jacobtri@andrew.cmu.edu{p_end}


{marker references}{...}
{title:References}

{phang}
Sergio Correia, Paulo Guimarães, Thomas Zylkin: "ppmlhdfe: Fast Poisson Estimation with High-Dimensional Fixed Effects", 2019; arXiv:1903.01690.

{phang}
Sergio Correia, 2014. "REGHDFE: Stata module to perform linear or instrumental-variable regression absorbing any number of high-dimensional fixed effects," Statistical Software Components S457874, Boston College Department of Economics, revised 21 Aug 2023.

{phang}
Todd A. Gormley, David A. Matsa, Growing Out of Trouble? Corporate Responses to Liability Risk, The Review of Financial Studies, Volume 24, Issue 8, August 2011, Pages 2781–2821, https://doi.org/10.1093/rfs/hhr011.{p_end}

{phang}
Todd A. Gormley, David A. Matsa,
Playing it safe? Managerial preferences, risk, and agency conflicts,
Journal of Financial Economics,
Volume 122, Issue 3,
2016,
Pages 431-455,
ISSN 0304-405X,
https://doi.org/10.1016/j.jfineco.2016.08.002.
{p_end}

