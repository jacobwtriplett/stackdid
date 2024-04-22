*! version 0.1 12apr2024
capture program drop stackdid
program define stackdid, rclass byable(onecall)
        
/* SYNTAX */
        
        if _by() { // needs testing
                local BY `"by `_byvars'`_byrc0':"'
        }
        
        if replay() {
                if `"`e(cmd)'"'!="stackdid" { // stackdid is not eclass
                        error 301
                }
                if _by() {
                        error 190
                }
                Estimate `0' /* display results */
                error `e(rc)'
                exit  
        }
        
        syntax anything                 /*
        */      [aw fw pw iw] [if] [in] /* what does if/in apply to?
        */      [,                      /*
        */      TReatment(varname numeric) /*
        */      GRoup(varname)          /*
        */      Time(varname numeric)   /*
        */      Window(string)          /*
        */      nevertreat              /*
        */      poisson                 /*
        */      NOTABulate              /*
        */      clear                   /*
        */      saving(string)          /*
        */      nobuild                 /*
        */      NOREGress               /* UNDOCUMENTED (yet)
        */      absorb(varlist)         /* UNDOCUMENTED
        */      *                       /* estimator-specific options other than absorb()
        */      ]
   
        * Confirm required options, or nobuild, specified
        if ("`treatment'"=="" | "`group'"=="" | "`time'"=="" | "`window'"=="") & ("`build'"=="") {
                di as err "options treatment(), group(), time(), and window() " ///
                          "are required, unless nobuild is specified"
                exit 198
        }
        
        * Tabulate treatment panel
        if ("`tabulate'"=="") {
                if ("`build'"=="") {
                        table (`group') (`time'), nototal statistic(firstnm `treatment')
                }
                else    table (`r(group)') (`r(time)'), nototal statistic(firstnm `r(treatment)')
        }
        
/* BUILD */

        if ("`build'"=="") {
                
                * Assert treatment takes values {0,1,.}
                capture assert inlist(`treatment',0,1,.) // if/in? 
                if (_rc) { 
                        di as err "`treatment' is not a 0/1/. variable"
                        exit 450
                }

                * Parse window()
                gettoken pre post: window
                capture assert `pre'<`post' & inrange(0,`pre'+1,`post'-1)
                if (_rc) {
                        di as err "option window() specified incorrectly"
                        exit 198
                }
                
                * Assert varnames are available
                foreach vname in __cohort __cohort_time __cohort_group {
                        capture ds `vname'
                        if (!_rc) {
                                di as err "varname `vname' must be available"
                                exit 110 
                        }
                }
                tempvar treat_prev treat_event nevertreated tostack treated latest_treat lost_treat gained_treat stacked

                * Find event times
                sort `group' `time'
                qui gen byte `treat_prev' = `treatment'[_n-1]==1 if (`group'[_n-1]==`group' & `time'[_n-1]!=`time')
                qui replace  `treat_prev' = `treat_prev'[_n-1]==1 if (`treatment'==1 & missing(`treat_prev'))
                qui gen byte `treat_event' = (`treatment'==1 & `treat_prev'!=1)
                qui levelsof `time' if (`treat_event'==1), local(cohorts)
                di _n as text "treatment cohorts: " as result "`cohorts'"
                drop `treat_prev'
                
                * Initialize cohort identifier and nevertreated identifier
                qui gen __cohort = . // missing means original, nonmissing means stacked... (datatype to match `time'?)
                if ("`nevertreat'"!="") qui egen byte `nevertreated' = min(`treatment'==0), by(`group')
                
                * For each cohort...
                foreach co of local cohorts {                
                        
                        * (helper: treated/control ... {1:treatment cohort, 0:control, .:neither})
                        qui egen byte `treated' = max(cond(`time'==`co',`treat_event'==1,.)), by(`group')
                        if ("`nevertreat'"!="") qui replace `treated' = . if (`treated'==0 & `nevertreated'==0)
                        
                        * (1): grab everything within window of event
                        qui gen byte `tostack' = inrange(`time', `pre'+`co', `post'+`co') if missing(__cohort) & !missing(`treated')
                        
                        * (2): remove latest treatment and prior
                        qui egen byte `latest_treat' = max(cond(`treatment'==1,`time',.)) if (`tostack'==1 & `time'<`co')
                        qui replace `tostack' = 0 if (`tostack'==1 & `time'<=`latest_treat' & !missing(`latest_treat'))

                        * (3): remove if treated group loses treatment status post-event
                        qui egen byte `lost_treat' = min(cond(`treatment'==0,`time',.)) if (`treated'==1 & `co'<`time')
                        qui replace `tostack' = 0 if (`treated'==1 & `lost_treat'<=`time' & !missing(`lost_treat'))
                        
                        * (4): remove if control group gains treatment status post-event
                        if ("`nevertreat'"=="") {
                                qui egen byte `gained_treat' = min(cond(`treatment'==1,`time',.)) if (`treated'==0 & `co'<`time')
                                qui replace `tostack' = 0 if (`treated'==0 & `gained_treat'<=`time' & !missing(`gained_treat'))
                                drop `gained_treat'
                        }

                        * (5): create stack using -expand-
                        drop `treated' `latest_treat' `lost_treat'
                        di as text "cohort " as result "`co'" as text " stacked " _cont
                        expand 2 if (`tostack'==1), gen(`stacked')
                        qui replace __cohort = `co' if (`stacked'==1)
                        drop `tostack' `stacked'
                        
                }
                
                * Generate fixed effects
                qui egen __cohort_time  = group(__cohort `time')  if !missing(__cohort), autotype
                qui egen __cohort_group = group(__cohort `group') if !missing(__cohort), autotype 
                
                * Label saved (non-temporary) variables 
                label var __cohort "treatment cohort, identified by time of treatment, from -stackdid-"
                label var __cohort_time "cohort-time fixed effect, from -stackdid-"
                label var __cohort_group "group-cohort fixed effect, from -stackdid-"
                
                * Clean up & grab N
                drop `treat_event'
                if ("`nevertreat'"!="") drop `nevertreated'
                qui count if missing(__cohort)
                local N_orig = r(N)
                qui count if !missing(__cohort)
                local N_stacked = r(N)
                
                * Apply clear/saving options
                if ("`clear'"!="") {
                        qui drop if missing(__cohort)
                        if ("`saving'"!="") {
                                save `saving'
                        }
                }
                else if ("`saving'"!="") {
                        preserve
                                qui drop if missing(__cohort)
                                save `saving'
                        restore
                }
                di
        }
        
/* ESTIMATE */
        
        if ("`regress'"=="") {
                local cmd = cond("`poisson'"!="", "ppmlhdfe", "reghdfe")
                local abs absorb(`absorb' __cohort_time __cohort_group)
                `cmd' `anything' [`weight'`exp'] `if' `in', `abs' `options'
                return local regline "e(cmdline)"
        }
        
/* CLEAN UP */
        
        if ("`clear'"=="" & "`build'"=="") {
                qui drop if !missing(__cohort)
                drop __cohort __cohort_time __cohort_group
        }
        
/* RETURNS + MESSAGES

        if ("`build'"=="") {
                return local treatment "`treatment'"
                return local group "`group'"
                return local time "`time'"
                return local window "`window'"
        }
        return local cmdline "stackdid `0'"
        if ("`regress'"=="") return local regline "e(cmdline)"
        return scalar N_orig = `N_orig'
        return scalar N_stacked = `N_stacked'
        
*/
        
end
