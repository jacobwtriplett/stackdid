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
{depvar}
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

{syntab: Estimator-specific options}
{synopt:{bf:{help reghdfe##options:reghdfe}}}options for {cmd:reghdfe}{p_end}
{synopt:{bf:{help ppmlhdfe##options:ppmlhdfe}}}options for {cmd:ppmlhdfe} if 
{cmd:poisson} specified{p_end}

{syntab: Display}
{synopt:{opt notab:ulate}}do not display tabulation of treatment panel{p_end}

{syntab: Saving}
{synopt:{opt clear}}replace data in memory with stacked data used in regression{p_end}
{synopt:{opt saving(filename, ...)}}save stacked data to {it:filename}; see {helpb saving_option:[G-3] saving option}{p_end}
{synopt:{opt nobuild}}do not build stacked data; proceed directly to regression{p_end}

{synoptline}
{p2coldent:* starred options are required}{p_end}
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
{opth tr:eatment(varname)} is a binary (0,1) indicator that an observation is treated.

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
{opt notab:ulate} suppress printing tabulation of treatment across {it:group} and 
{it:time}.  Such a tabulation can be a useful data visualization, but is unweildy 
for many groups and long ranges of time.

{dlgtab:Saving}

{phang}
{opt clear} replaces the data in memory with the stacked cohorts built by {cmd:stackdid} and used by {it:estimator}.  This option {it:must} be specified
if the post-estimation return function {cmd:e(sample)} is desired.  If {cmd:clear}
is not specified, the original data in memory is restored after estimation.

{phang}
{opt saving(filename [, replace])} saves the stacked cohorts built by {cmd:stackdid}
 and used by {it:estimator} to {it:filename}.
 
{phang2}{opt replace} permits {cmd:saving()} to overwite an existing dataset.{p_end}

{phang}
{opt nobuild} does not build stacked data and proceeds directly to estimation.  
This option assumes the data in memory are stacked data already built by {cmd:stackdid}.  
See {help stackdid##remarks:remarks} for the intended use case.


{marker remarks}{...}
{title:Remarks}

{pstd}
Practictioners often build upon a baseline specification with increasingly strict
fixed effects and/or controls.  {cmd:stackdid} will always create the same stacks
when the required options ({cmd:treatment()}, {cmd:group()}, {cmd:time()}, {cmd:window()}) and {cmd:nevertreat} are the same.  Thus, you can reduce redundant computation using the {cmd:clear} 
option in the first specification and the {cmd:nobuild} option in subsequent 
specifications.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
[todo: (1) subsequent specifications, using {cmd:clear} and {cmd:nobuild}; (2) triple-diff]


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:stackdid} stores the following in {cmd:r()}:

{phang2}[todo]

{pstd}
See {it:estimator}'s help file for results stored in {cmd:e()}.


{title:Author}

{pstd}Jacob Triplett{p_end}
{pstd}Carnegie Mellon University{p_end}
{pstd}jacobtri@andrew.cmu.edu{p_end}


{marker references}{...}
{title:References}

{phang}
Sergio Correia, 2014. "REGHDFE: Stata module to perform linear or instrumental-variable regression absorbing any number of high-dimensional fixed effects," Statistical Software Components S457874, Boston College Department of Economics, revised 21 Aug 2023.

{phang}
Sergio Correia, Paulo Guimarães, Thomas Zylkin: "ppmlhdfe: Fast Poisson Estimation with High-Dimensional Fixed Effects", 2019; arXiv:1903.01690.

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

