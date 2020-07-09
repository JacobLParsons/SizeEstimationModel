# SizeEstimationModel
A Bayesian hierarchical modeling approach to combining multiple data sources.

Files:

MCMC.r - Contains the functions used to run the chain as well as a few utility functions for
combining chains etc... The most useful file for implementing the function.

confirmation.r - Tests to illustrate model capabilities and use in a portable manner. 

MCMC.ro - Early draft of MCMC.r. Don't use this.

Simulation.org - Contains simulations illustrating the use of MCMC.r and model test cases as code blocks. 

example.r - Contains an example use of the MCMC.r set of functions and illustrates how model fitting was done.

cross*.r Cross Validation Examples

LoadData.r - Particular to the Ukraine Example

Note: Several scripts and files heavily rely on PSU's cluster and its particular environment (including a few shell scripts). MCMC.r and Confirmation.r should be completely usable outside this environment and allow for applying our model to other problems. 

.............................................................

Interpreting results: The chain is stored as a list and each parameter can be accessed using "$" in the following way:

chain$"alpha0"[k/thin] = current$"alpha0"

A list of interesting parameters (order of dimensions is always (sample number,site, sub-population, year) with irrelevant dimensions left out:

Beta Hyper parameters for distribution of target population prevalence in initial year:

"alpha0"  (Dimension: Chain Length)

"beta0"   (Dimension: Chain Length)

Beta Hyper parameters for distribution of sub-population prevalence in initial year:

"alpha" (Dimension: Chain Length x Number of Subgroups)

"beta" (Dimension: Chain Length x Number of Subgroups)

Prevalence of target population:

"pi" (Dimension: Chain Length x Number of Sites x Number of Years)

Size of target population:

"N" (Dimension: Chain Length x Number of Sites x Number of Years)

Prevalence of subgroups:

"p" (Dimension: Chain Length x Number of Sites x Number of Subgroups x Number of Years)

Average Network Scale up bias (Log Scale):

"mu" (Dimension: Chain Length)

Average Multiplier Proportion Estimate Bias (Logit Scale):

"theta"(Dimension: Chain Length)

Sub-group specific Proportion Estimate Bias (Logit Scale):

"gamma" (Dimension: Chain Length x Number of Subgroups)

Site specific Proportion Estimate Bias (Logit Scale):

"delta" (Dimension: Chain Length x Number of Sites)

National level average shift in prevalence of target population (logit scale):

"yearTrend" (Dimension: Chain Length x Number of Years)

.............................................................

Data Format:

The data should be a list with the following entries (NA should be used where data is not available):

"phat" - An array with dimensions: number of sites x number of sub-groups x number of years.
         phat[i,j,t] is the estimate proportion of target population that falls into subgroup
	 j at site i during year t.

 "n" - An array with dimensions: number of sites x number of sub-groups x number of years.
       n[i,j,t] is the sample size used to generate phat[i,j,t]. NA indicates data not collected.
      
 "Y" - An array with dimensions: number of sites x number of sub-groups x number of years.
       Y[i,j,t] is the true size of the subgroup j at site i during year t.

 "NSU" - A number of sites x number of years matrix. NSU[i,t] is the estimated size of the
       	 target population at site i during year t using the network scale-up method.
	 
 "NSU.se" - A number of sites x number of years matrix. NSU.se[i,t] is the estimated
 	    standard error of NSU[i,t].
	    
 "R" - A number of sites x number of years matrix. The estimated size of the reference
       population at site i in year t.
       
 "logit" - logit = logit(phat).  All phat is assumed to to be valid input to logit(). 

.............................................................

Required Libraries (all available from CRAN):

truncnorm
LaplacesDemon
abind
dplyr
forcats

.............................................................

Known Bugs:

- The number of sites and number of years should be stored as global variables (numYears and numSites respectively). Although this violates good style principles, it avoids repeatedly determining these numbers from the data or passing them between functions. This should be fixed later.



