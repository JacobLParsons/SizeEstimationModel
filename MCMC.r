library(truncnorm)
library(LaplacesDemon)
library(abind)

chainBind = function(chainA, chainB)
{

    
    chain = list("alpha0" = c(chainA$"alpha0", chainB$"alpha0"),
    "a0" = c(chainA$"a0", chainB$"a0"),
    "beta0" = c(chainA$"beta0", chainB$"beta0"),
    "b0" = c(chainA$"b0", chainB$"b0"),
    "alpha" = rbind(chainA$"alpha", chainB$"alpha"),
    "a"= rbind(chainA$"a", chainB$"a"),
    "beta" = rbind(chainA$"beta", chainB$"beta"),
    "b"= rbind(chainA$"b", chainB$"b"),
    "pi" = abind(chainA$pi, chainB$pi, along = 1),
    "sigmaPiSq" = abind(chainA$sigmaPiSq, chainB$sigmaPiSq, along = 1),
    "N" =abind(chainA$N, chainB$N, along = 1),
    "p" = abind(chainA$p, chainB$p, along = 1),
    "sigmaPSq" = abind(chainA$sigmaPSq, chainB$sigmaPSq, along = 1),
    "sigmaNSq" = abind(chainA$sigmaNSq, chainB$sigmaNSq, along = 1),
    "tauSq" = abind(chainA$tauSq, chainB$tauSq, along = 1),
    "sigmaGammaSq" = abind(chainA$sigmaGammaSq, chainB$sigmaGammaSq, along = 1),
    "sigmaDeltaSq" = abind(chainA$sigmaDeltaSq, chainB$sigmaDeltaSq, along = 1),
    "sigmaESq" = abind(chainA$sigmaESq, chainB$sigmaESq, along = 1),
    "mu" = abind(chainA$mu, chainB$mu, along = 1),
    "theta" = abind(chainA$theta, chainB$theta, along = 1),      
    "gamma" = abind(chainA$gamma, chainB$gamma, along = 1),
    "delta" = abind(chainA$delta, chainB$delta, along = 1),
    "yearTrend" = abind(chainA$yearTrend, chainB$yearTrend, along = 1),
    "sigmaSq.yearTrend" = abind(chainA$"sigmaSq.yearTrend", chainB$"sigmaSq.yearTrend", along = 1)
    )

    return(chain)    
}

makeChain = function(data, length)
{
    numSites = length(data$R[,1])
    numLists = length(data$phat[1,,1])
    numYears = length(data$R[1,])
    
    chain = list("alpha0" = rep(NaN, length),
                 "a0" = rep(NaN, length),
                 "beta0" = rep(NaN, length),
                 "b0" = rep(NaN, length),
                 "alpha" = matrix(NaN, ncol = numLists, nrow = length),
                 "a" = matrix(NaN, ncol = numLists, nrow = length),
                 "beta" = matrix(NaN, ncol = numLists, nrow = length),
                 "b" = matrix(NaN, ncol = numLists, nrow = length),
                 "pi" = array(NaN, dim = c(length, numSites, numYears)),
                 "sigmaPiSq" = rep(NaN, length),             
                 "N" = array(NaN, dim = c(length, numSites, numYears)),
                 "p" = array(NaN, dim = c(length, numSites, numLists, numYears)),
                 "sigmaPSq" = rep(NaN, length),
                 "sigmaNSq" = array(NaN, dim = c(length, numSites, numYears)),
                 "tauSq" = array(NaN, dim = c(length)),
                 "sigmaGammaSq" = rep(NaN, length),
                 "sigmaDeltaSq" = rep(NaN, length),
                 "sigmaESq" = rep(NaN, length),
                 "mu" = rep(NaN, length),
                 "theta" = rep(NaN, length),
                 "gamma" = matrix(NaN, nrow = length, ncol = numLists),
                 "delta" = matrix(NaN, nrow = length, ncol = numSites),
                 "yearTrend" = matrix(NaN, nrow = length, ncol = numYears),
                 "sigmaSq.yearTrend" = rep(NaN, length)
                 )

    return(chain)
}

initialize = function(data)
{
    numSites = length(data$R[,1])
    numLists = length(data$phat[1,,1])
    numYears = length(data$R[1,])

    
    current = list("alpha0" = 3,
                   "a0" = log(.5),
                   "beta0" = 3,
                   "b0" = log(6),
                   "alpha" = rep(3, numLists), 
                   "a" = rep(log(.5), numLists),
                   "beta" = rep(3, numLists),
                   "b" = rep(log(6), numLists),
                   "pi" = array(.3, dim = c(numSites, numYears)),
                   "sigmaPiSq" = 1,             
                   "N" = array(100000, dim = c(numSites, numYears) ),
                   "p" = array(.5, dim = c(numSites, numLists, numYears)),
                   "sigmaPSq" = 1,
                   "sigmaNSq" = array(20000, dim = c(numSites, numYears)),
                   "tauSq" = 1,
                   "sigmaGammaSq" = 1,
                   "sigmaDeltaSq" = 1,
                   "sigmaESq" = 1,
                   "mu" = 0,
                   "theta" = 0,
                   "gamma" = rep(0, numLists), 
                   "delta" = rep(0, numSites),
                   "yearTrend" = rep(0, numYears),
                   "sigmaSq.yearTrend" = 0
                   )

    return(current)
}

abSample = function(probs, aprev, bprev)
{

    ### M-H Step for a
    aprop = rtruncnorm(1, a = 0, b = 1, mean = aprev, sd = .25)

    logBottomPropDensity = log(dtruncnorm(aprop,a = 0, b = 1, mean = aprev, sd = .05)) 
    logTopPropDensity = log(dtruncnorm(aprev,a = 0, b = 1, mean = aprop, sd = .05)) 

    logTopPost = sum(dbeta(probs, shape1 = aprop*bprev, shape2 = bprev - aprop*bprev, log=TRUE )) 

    logBottomPost = sum(dbeta(probs, shape1 = aprev*bprev, shape2 = bprev - (aprev*bprev), log=TRUE ))

    PropProb = exp(logTopPropDensity + logTopPost - logBottomPropDensity - logBottomPost)

    U = runif(1)

    if(is.na(U < PropProb) )
    {
        PropProb = 0
    }

    if(U < PropProb)
    {
        acurrent = aprop
    } else
    {
        acurrent = aprev
    }
    
    ### M-H Step for b
    bprop = rtruncnorm(n = 1,mean = bprev, a = 0 )

    logBottomPropDensity = log(dtruncnorm(bprop, a = 0, mean = bprev ))
    logTopPropDensity = log(dtruncnorm(bprev, a = 0, mean = bprop ))

    logTopPost = sum(dbeta(probs, shape1 = acurrent*bprop, shape2 = bprop - acurrent*bprop, log=TRUE ) ) + dgamma(bprop, 1 , .01, log = TRUE) 
    logBottomPost = sum(dbeta(probs, shape1 = acurrent*bprev, shape2 = bprev - acurrent*bprev, log=TRUE ) ) + dgamma(bprev, 1 , .01, log = TRUE)

    PropProb = exp(logTopPropDensity + logTopPost - logBottomPropDensity - logBottomPost)

    U = runif(1)
    
    if(is.na(U < PropProb) )
    {
        PropProb = 0
    }

    if(U < PropProb)
    {
        bcurrent = bprop
    } else
    {
        bcurrent = bprev
    }

    return(c(acurrent, bcurrent))
}
                         

logit = function(input)
{
    return( log(input / (1 - input) ) )
}


invlogit = function(x)
{
    return( 1 / (1 + exp(-x)) )
}

updatePi = function(current, data)
{
    yearTrend = current$yearTrend
    
    tune = 3
    numSites = length(data$R[,1])
    numYears = length(data$R[1,])
    pinew = current$pi

    ## When do we have no data?
    Ypresent = apply(!is.na(data$Y), MARGIN = c(1,3), FUN = max)
    NSUpresent = !is.na(data$NSU)

    NoData = !Ypresent & !NSUpresent

    ## Update First Year
    ## Generate Proposal Value
    piprev = current$pi[,1]
    logitpiprev = logit(piprev)
    logitpiprop = rnorm(length(piprev), mean = logitpiprev, sd = tune)
    piprop = invlogit(logitpiprop)
    
    ## Calculate Four Components of Acceptance

    dataInfluence = dbinom(current$N[,1], size = data$R[,1], prob = piprop, log = TRUE)
    dataInfluence[NoData[,1]]= 0
    
    logTopPost = dbeta(piprop, shape1 = current$alpha0, shape2 = current$beta0, log = TRUE) +
        log(piprop) + log(invlogit(-logitpiprop)) + 
        dataInfluence +
        dnorm(logit(current$pi[,2]), mean = logitpiprop + yearTrend[2], sd = sqrt(current$sigmaPiSq), log = TRUE)

    dataInfluence = dbinom(current$N[,1], size = data$R[,1], prob = piprev, log = TRUE) 
    dataInfluence[NoData[,1]]= 0
    
    logBottomPost = dbeta(piprev, shape1 = current$alpha0, shape2 = current$beta0, log = TRUE) +
        log(piprev) + log(invlogit(-logitpiprev)) + 
        dataInfluence +
        dnorm(logit(current$pi[,2]), mean = logitpiprev + yearTrend[2], sd = sqrt(current$sigmaPiSq), log = TRUE)

    ## Calculate Acceptance Probability
    prob = exp(logTopPost - logBottomPost)

    ## Accept/Reject
    U = runif(length(prob))

    pinew[which(U < prob),1] = piprop[which(U < prob)]
    pinew[which(U >= prob),1] = piprev[which(U >= prob)]

    
    ## Update Interior Years Prevalence
    for(t in 2:(numYears-1) )
    {
        ## Generate Proposal Value
        piprev = current$pi[,t]
        logitpiprev = logit(piprev)
        logitpiprop = rnorm(length(piprev), mean = logitpiprev, sd = tune)
        piprop = invlogit(logitpiprop)
        
        ## Calculate Four Components of Acceptance
        dataInfluence = dbinom(current$N[,t], size = data$R[,t], prob = piprop, log = TRUE)
        dataInfluence[NoData[,t]]= 0
        
        logTopPost = dataInfluence +
            dnorm(logit(current$pi[,t+1]), mean = logitpiprop + yearTrend[t + 1], sd = sqrt(current$sigmaPiSq), log = TRUE) +
            dnorm(logitpiprop , mean = logit(pinew[,t-1]) + yearTrend[t], sd = sqrt(current$sigmaPiSq), log = TRUE) 

        dataInfluence = dbinom(current$N[,t], size = data$R[,t], prob = piprev, log = TRUE) 
        dataInfluence[NoData[,t]]= 0
        
        logBottomPost = dataInfluence +
            dnorm(logit(current$pi[,t+1]), mean = logitpiprev + yearTrend[t+1], sd = sqrt(current$sigmaPiSq), log = TRUE) +
            dnorm(logitpiprev , mean = logit(pinew[,t-1]) + yearTrend[t], sd = sqrt(current$sigmaPiSq), log = TRUE)

        ## Calculate Acceptance Probability
        prob = exp(logTopPost - logBottomPost)

        ## Accept/Reject
        U = runif(length(prob))

        pinew[which(U < prob),t] = piprop[which(U < prob)]
        pinew[which(U >= prob),t] = piprev[which(U >= prob)] 

    }
    
    ## Update Last Pi
    t = numYears
    
    ## Generate Proposal Value
    piprev = current$pi[,t]
    logitpiprev = logit(piprev)
    logitpiprop = rnorm(length(piprev), mean = logitpiprev, sd = tune)
    piprop = invlogit(logitpiprop)
    
    ## Calculate Four Components of Acceptance

    dataInfluence = dbinom(current$N[,t], size = data$R[,t], prob = piprop, log = TRUE)  
    dataInfluence[NoData[,t]]= 0
    
    logTopPost = dataInfluence +
        dnorm(logitpiprop , mean = logit(pinew[,t-1]) + yearTrend[t], sd = sqrt(current$sigmaPiSq), log = TRUE)

    dataInfluence = dbinom(current$N[,t], size = data$R[,t], prob = piprev, log = TRUE) 
    dataInfluence[NoData[,t]]= 0

    logBottomPost = dataInfluence + 
        dnorm(logitpiprev , mean = logit(pinew[,t-1]) + yearTrend[t], sd = sqrt(current$sigmaPiSq), log = TRUE)

    ## Calculate Acceptance Probability
    prob = exp(logTopPost - logBottomPost)

    ## Accept/Reject
    U = runif(length(prob))

    pinew[which(U < prob),t] = piprop[which(U < prob)]
    pinew[which(U >= prob),t] = piprev[which(U >= prob)] 
    
    return(pinew)            
}

updateN = function(current, data)
{
    Nnew = current$N
    
    ## Which data is present?
    Ypresent = apply(!is.na(data$Y), MARGIN = c(1,3), FUN = max)
    NSUpresent = !is.na(data$NSU)

    ## Four Cases
    NoData = !Ypresent & !NSUpresent
    OnlyY = Ypresent & !NSUpresent
    OnlyNSU = !Ypresent & NSUpresent
    Both = Ypresent & NSUpresent

    ## No Data
    Nnew[NoData] = rbinom(n = sum(NoData), size = data$R[NoData], prob = current$pi[NoData])
    
    ## Only Y Has data - ONLY! 
    tempY = data$Ya
    tempY[is.na(tempY)] = 0
        
    upperBound =  data$R[OnlyY]
    Nprev = current$N[OnlyY]
    Nprop = rbinom(n=sum(OnlyY), size =  upperBound, prob = Nprev/upperBound) 
    Naccept = rep(NA, length = sum(OnlyY))
    
    ## Calculate Four Components of Acceptance Probability
    logTopPropDensity = dbinom(Nprev, size = upperBound, prob = Nprop/upperBound, log = TRUE) #dpois(Nprev, Nprop, log = TRUE)
    logBottomPropDensity = dbinom(Nprop, size = upperBound, prob = Nprev/upperBound, log = TRUE) #dpois(Nprop, Nprev, log = TRUE)

    Ntemp = data$Y
        
    for(li in 1:dim(data$Y)[2])
    {
        Ntemp[,li,] = current$N
        Ntemp[,li,][OnlyY] = Nprop
    }
    
    logTopPost = dbinom(Nprop, size = data$R[OnlyY] , prob = current$pi[OnlyY], log = TRUE)   +
        apply(dbinom(data$Y, size = Ntemp, prob = current$p, log = TRUE), FUN = sum, MARGIN = c(1,3), na.rm = TRUE)[which(OnlyY)]

    Ntemp = data$Y
        
    for(li in 1:dim(data$Y)[2])
    {
        Ntemp[,li,] = current$N
        Ntemp[,li,][OnlyY] = Nprev
    }
    
    logBottomPost = dbinom(Nprev, size = data$R[OnlyY] , prob = current$pi[OnlyY], log = TRUE) +
        apply(dbinom(data$Y, size = Ntemp, prob = current$p, log = TRUE), FUN = sum, MARGIN = c(1,3), na.rm = TRUE)[which(OnlyY)]
    
    ## Calculate Acceptance Probability
    prob = exp(logTopPropDensity + logTopPost - logBottomPropDensity - logBottomPost)

    ## Accept/Reject
    U = runif(length(Naccept))

    accept = U < prob
    posinf = prob 
    accept[is.na(accept)] = FALSE

    Naccept[accept] = Nprop[accept]
    Naccept[!accept] = Nprev[!accept]

    Nnew[OnlyY] = Naccept

    ## Only NSU Has Data
    upperBound =  data$R[OnlyNSU]
    Nprev = current$N[OnlyNSU]
    Nprop = rbinom(n=sum(OnlyNSU), size =  upperBound, prob = Nprev/upperBound) 
    Naccept = rep(NA, length = sum(OnlyNSU))

    ## Calculate Four Components of Acceptance Probability
    logTopPropDensity = dbinom(Nprev, size = upperBound, prob = Nprop/upperBound, log = TRUE) #dpois(Nprev, Nprop, log = TRUE)
    logBottomPropDensity = dbinom(Nprop, size = upperBound, prob = Nprev/upperBound, log = TRUE) #dpois(Nprop, Nprev, log = TRUE)

    logTopPost = dbinom(Nprop, size = data$R[OnlyNSU] , prob = current$pi[OnlyNSU], log = TRUE) +
        dnorm(log(data$NSU[OnlyNSU]), mean = log(Nprop) + current$mu, sd = sqrt(current$sigmaNSq[OnlyNSU])/Nprop, log = TRUE) 
    

    logBottomPost = dbinom(Nprev, size = data$R[OnlyNSU] , prob = current$pi[OnlyNSU], log = TRUE) +
        dnorm(log(data$NSU[OnlyNSU]), mean = log(Nprev) + current$mu, sd = sqrt(current$sigmaNSq[OnlyNSU])/Nprev, log = TRUE) 

    ## Calculate Acceptance Probability
    prob = exp(logTopPropDensity + logTopPost - logBottomPropDensity - logBottomPost)

    ## Accept/Reject
    U = runif(length(Naccept))

    Naccept[U < prob] = Nprop[U < prob]
    Naccept[U >= prob] = Nprev[U >= prob]

    Nnew[OnlyNSU] = Naccept

    ## Both (Not Currently Needed) 
    tempY = data$Ya
    tempY[is.na(tempY)] = 0
        
    upperBound =  data$R[Both]
    Nprev = current$N[Both]
    Nprop = rbinom(n=sum(Both), size =  upperBound, prob = Nprev/upperBound) 
    Naccept = rep(NA, length = sum(Both))
    
    ## Calculate Four Components of Acceptance Probability
    logTopPropDensity = dbinom(Nprev, size = upperBound, prob = Nprop/upperBound, log = TRUE) #dpois(Nprev, Nprop, log = TRUE)
    logBottomPropDensity = dbinom(Nprop, size = upperBound, prob = Nprev/upperBound, log = TRUE) #dpois(Nprop, Nprev, log = TRUE)

    Ntemp = data$Y
        
    for(li in 1:dim(data$Y)[2])
    {
        Ntemp[,li,] = current$N
        Ntemp[,li,][Both] = Nprop
    }
    
    logTopPost = dbinom(Nprop, size = data$R[Both] , prob = current$pi[Both], log = TRUE)   +
        apply(dbinom(data$Y, size = Ntemp, prob = current$p, log = TRUE), FUN = sum, MARGIN = c(1,3), na.rm = TRUE)[which(Both)] +
        dnorm(log(data$NSU[Both]), mean = log(Nprop) + current$mu, sd = sqrt(current$sigmaNSq[Both])/Nprop, log = TRUE) 

    Ntemp = data$Y
        
    for(li in 1:dim(data$Y)[2])
    {
        Ntemp[,li,] = current$N
        Ntemp[,li,][Both] = Nprev
    }
    
    logBottomPost = dbinom(Nprev, size = data$R[Both] , prob = current$pi[Both], log = TRUE) +
        apply(dbinom(data$Y, size = Ntemp, prob = current$p, log = TRUE), FUN = sum, MARGIN = c(1,3), na.rm = TRUE)[which(Both)] +
        dnorm(log(data$NSU[Both]), mean = log(Nprev) + current$mu, sd = sqrt(current$sigmaNSq[Both])/Nprev, log = TRUE) 
    
    ## Calculate Acceptance Probability
    prob = exp(logTopPropDensity + logTopPost - logBottomPropDensity - logBottomPost)

    ## Accept/Reject
    U = runif(length(Naccept))

    accept = U < prob
    posinf = prob 
    accept[is.na(accept)] = FALSE

    Naccept[accept] = Nprop[accept]
    Naccept[!accept] = Nprev[!accept]

    Nnew[Both] = Naccept

    
    return(Nnew)
}


updateP = function(current,data)
{
    tune = .5
    numSites = length(data$R[,1])
    numLists = length(data$Y[1,,1])
    numYears = length(data$R[1,])
    pnew = current$p

    ## When do we have no data?
    Ypresent = !is.na(data$Y) # For Now Treat phat and Y as pairs. 
    for(j in 1:numLists)
    {
        ## Update First Year
        ## Generate Proposal Value
        pprev = current$p[,j,1]
        logitpprev = logit(pprev)
        logitpprop = rnorm(length(pprev), mean = logitpprev, sd = tune)
        pprop = invlogit(logitpprop)
        
        ## Calculate Four Components of Acceptance

        dataInfluence = dbinom(data$Y[,j,1], size = current$N[,1], prob = pprop, log = TRUE) +
            dnorm(data$logit[,j,1], mean = logitpprop + current$theta + current$gamma[j] + current$delta , sd = current$sigmaESq/data$n[,j,1])
        dataInfluence[!Ypresent[,j,1]]= 0
        
        logTopPost = dbeta(pprop, shape1 = current$alpha[j], shape2 = current$beta[j], log = TRUE) +
            log(pprop) + log(invlogit(-logitpprop)) + 
            dataInfluence +
            dnorm(logit(current$p[,j,2]), mean = logitpprop, sd = sqrt(current$sigmaPSq), log = TRUE)

        dataInfluence = dbinom(data$Y[,j,1], size = current$N[,1], prob = pprev, log = TRUE) +
            dnorm(data$logit[,j,1], mean = logitpprev + current$theta + current$gamma[j] + current$delta , sd = current$sigmaESq/data$n[,j,1])
        dataInfluence[!Ypresent[,j,1]]= 0
        
        logBottomPost = dbeta(pprev, shape1 = current$alpha[j], shape2 = current$beta[j], log = TRUE) +
            log(pprev) + log(invlogit(-logitpprev)) + 
            dataInfluence +
            dnorm(logit(current$p[,j,2]), mean = logitpprev, sd = sqrt(current$sigmaPSq), log = TRUE)

        ## Calculate Acceptance Probability
        prob = exp(logTopPost - logBottomPost)

        ## Accept/Reject
        U = runif(length(prob))

        pnew[which(U < prob),j,1] = pprop[which(U < prob)]
        pnew[which(U >= prob),j,1] = pprev[which(U >= prob)]

        ## Update Interior Years
        for(t in 2:(numYears-1) )
        {
            ## Generate Proposal Value
            pprev = current$p[,j,t]
            logitpprev = logit(pprev)
            logitpprop = rnorm(length(pprev), mean = logitpprev, sd = tune)
            pprop = invlogit(logitpprop)
            
            ## Calculate Four Components of Acceptance
            dataInfluence = dbinom(data$Y[,j,t], size = current$N[,t], prob = pprop, log = TRUE) +
                dnorm(data$logit[,j,t], mean = logitpprop + current$theta + current$gamma[j] + current$delta , sd = current$sigmaESq/data$n[,j,t])
            dataInfluence[!Ypresent[,j,t]]= 0
            
            logTopPost = dataInfluence +
                dnorm(logit(current$p[,j,t+1]), mean = logitpprop, sd = sqrt(current$sigmaPSq), log = TRUE) +
                dnorm(logitpprop , mean = logit(pnew[,j,t-1]), sd = sqrt(current$sigmaPSq), log = TRUE) 

            dataInfluence = dbinom(data$Y[,j,t], size = current$N[,t], prob = pprev, log = TRUE) +
                dnorm(data$logit[,j,t], mean = logitpprev + current$theta + current$gamma[j] + current$delta , sd = current$sigmaESq/data$n[,j,t])
            dataInfluence[!Ypresent[,j,t]]= 0
             
            logBottomPost = dataInfluence +
                dnorm(logit(current$p[,j,t+1]), mean = logitpprev, sd = sqrt(current$sigmaPSq), log = TRUE) +
                dnorm(logitpprev , mean = logit(pnew[,j,t-1]), sd = sqrt(current$sigmaPSq), log = TRUE)

            ## Calculate Acceptance Probability
            prob = exp(logTopPost - logBottomPost)

            ## Accept/Reject
            U = runif(length(prob))

            pnew[which(U < prob),j,t] = pprop[which(U < prob)]
            pnew[which(U >= prob),j,t] = pprev[which(U >= prob)] 

        }

        ## Update Last P
        t = numYears
        
        ## Generate Proposal Value
        pprev = current$p[,j,t]
        logitpprev = logit(pprev)
        logitpprop = rnorm(length(pprev), mean = logitpprev, sd = tune)
        pprop = invlogit(logitpprop)
        
        ## Calculate Four Components of Acceptance

        dataInfluence = dbinom(data$Y[,j,t], size = current$N[,t], prob = pprop, log = TRUE) +
            dnorm(data$logit[,j,t], mean = logitpprop + current$theta + current$gamma[j] + current$delta , sd = current$sigmaESq/data$n[,j,t])
        dataInfluence[!Ypresent[,j,t]]= 0
        
        logTopPost = dataInfluence +
            dnorm(logitpprop , mean = logit(pnew[,j,t-1]), sd = sqrt(current$sigmaPSq), log = TRUE)

        dataInfluence = dbinom(data$Y[,j,t], size = current$N[,t], prob = pprev, log = TRUE) +
            dnorm(data$logit[,j,t], mean = logitpprev + current$theta + current$gamma[j] + current$delta , sd = current$sigmaESq/data$n[,j,t])
        dataInfluence[!Ypresent[,j,t]]= 0

        logBottomPost = dataInfluence + 
            dnorm(logitpprev , mean = logit(pnew[,j,t-1]), sd = sqrt(current$sigmaPSq), log = TRUE)

        ## Calculate Acceptance Probability
        prob = exp(logTopPost - logBottomPost)

        ## Accept/Reject
        U = runif(length(prob))

        pnew[which(U < prob),j,t] = pprop[which(U < prob)]
        pnew[which(U >= prob),j,t] = pprev[which(U >= prob)]         
        
    }

    return(pnew)

}


updateSigmaPiSq = function(current, data)
{
    yearTrend = current$yearTrend
    
    ## Which Data Do We have
    Ypresent = apply(!is.na(data$Y), MARGIN = c(1,3), FUN = max)
    NSUpresent = !is.na(data$NSU)

    NoData = !Ypresent & !NSUpresent

    numSteps = rowSums(!NoData) - 1
        
    steps = array(0, dim = c(length(numSteps), max(numSteps)))
    
    for(i in 1:length(numSteps))
    {
        indices = which(!NoData[i,])   
        
        for(j in 1:numSteps[i] )
        {
            
            dist = indices[j+1] - indices[j]
            diff = logit(current$pi[i,indices[j+1]]) - logit(current$pi[i,indices[j]]) - sum(yearTrend[(indices[j]+1):indices[j+1]])
            steps[i,j] = diff/sqrt(dist)
        }                
    }
    
    sigmaPiSq = 1/rgamma(n=1, shape = 5 + sum(numSteps)/2 , rate = 5 + sum ( (steps)^2 )/2 )

    return(sigmaPiSq)
}


updateSigmaPSq = function(current, data)
{
    ## Which Data Do We have
    Ypresent = !is.na(data$Y)

    numSteps = apply(Ypresent, MARGIN = c(1,2), FUN = sum) - 1
    numSteps[numSteps == -1] = 0
        
    steps = array(0, dim = c(length(numSteps[,1]), length(numSteps[1,]) , max(numSteps)))
    
    for(i in 1:length(numSteps[,1]))       
    {
        for(j in 1:length(numSteps[1,]))
        {
            if(numSteps[i,j] > 0)
            {   
                indices = which(Ypresent[i,j,], arr.ind=TRUE)   
                
                for(k in 1:numSteps[i,j] )
                {                
                    dist = indices[k+1] - indices[k]
                    diff = logit(current$p[i,j,indices[k+1]]) - logit(current$p[i,j,indices[k]])
                    steps[i,j,k] = diff/sqrt(dist)
                }
            }
        }
    }
    
    sigmaPSq = 1/rgamma(n=1, shape = .5 + sum(numSteps)/2 , rate = .5 + sum ( (steps)^2 )/2 )

    return(sigmaPSq)
}


update = function(current, data)
{
    numLists = length(data$phat[1,,1])
    numYears = length(data$R[1,])
    
    ## Update alpha0 and beta0
    updatedvalues = abSample(probs = current$"pi"[,1],
                             aprev = current$"a0",
                             bprev = current$"b0")
    current$"a0" = updatedvalues[1]
    current$"b0" = updatedvalues[2]
    current$"alpha0" = current$"a0"*current$"b0"
    current$"beta0" = current$"b0" - current$"a0"*current$"b0"

    for(j in 1:numLists)
    {
        ## Update alpha and beta
        updatedvalues = abSample(probs = current$"p"[,j,1],
                                 aprev = current$"a"[j],
                                 bprev = current$"b"[j])
        
        current$"a"[j] = updatedvalues[1]
        current$"b"[j] = updatedvalues[2]
        current$"alpha"[j] = current$"a"[j]*current$"b"[j]
        current$"beta"[j] = current$"b"[j] - current$"a"[j]*current$"b"[j]
    }

    ## Update pi
    current$"pi" = updatePi(current, data)

    ## Update p
    current$"p" = updateP(current, data)

    ## Update sigmaPiSq
    current$"sigmaPiSq" = updateSigmaPiSq(current,data)

    current$yearTrend[0] = 0
    
    ## Update yearTrend
    for(t in 2:numYears)
    {
        mean = logit(current$pi[,t-1])         
        var = 1/(1/current$sigmaSq.yearTrend + numSites/current$sigmaPiSq )
        coef = sum(logit(current$pi[,t])  - mean )/current$sigmaPiSq

        current$"yearTrend"[t] = rnorm(n = 1, mean = var*coef, sd = sqrt(var)) #0
    }
    
    ## Update sigma        
    current$"sigmaPSq" =  updateSigmaPSq(current,data)
    
    ## Update N
    #current$"N" = ceiling(data$R*current$pi)#updateN(current,data)
    current$"N" = updateN(current,data)

    ## Update sigmaNSq
    Z = current$"N"*(log(data$"NSU") - log(current$"N") - current$mu)/data$"NSU.se"
    NSUpresent = !is.na(data$"NSU")
    current$"tauSq" = 1/rgamma(n=1, shape = 1 + length(Z[NSUpresent])/2 , rate = 1 + sum ( Z[NSUpresent]^2)/2 )
    current$"sigmaNSq" = (data$"NSU.se"^2)*current$"tauSq"

    ## Update mu
    NSUpresent = !is.na(data$NSU)
    var = 1 / ( 1 + sum((current$N[NSUpresent])^2/(current$sigmaNSq[NSUpresent]) ) )
    coef = sum(current$N[NSUpresent]^2*(log(data$NSU[NSUpresent]) - log(current$N[NSUpresent]) )/(current$sigmaNSq[NSUpresent] ) )

    current$"mu" = rnorm(n = 1, mean = var*coef, sd = sqrt(var) )

    ## Update theta
    mean = logit(current$p) + replicate(numYears,outer(current$delta, current$gamma, FUN=function(x,y) (x+y)))
    logitpresent = !is.na(data$logit)
    var = 1/(1 + sum(data$n[logitpresent])/current$sigmaESq )
    coef = sum(data$n[logitpresent]*(data$logit[logitpresent] - mean[logitpresent]) )/current$sigmaESq

    current$"theta" = rnorm(n = 1, mean = var*coef, sd = sqrt(var))

    ## Update Gamma
    mean = logit(current$p) + current$theta + current$delta
    var = 1/( (1/current$sigmaGammaSq) + rowSums(colSums(data$n, na.rm = TRUE))/current$sigmaESq)
    coef = rowSums(colSums(data$n*(data$logit - mean), na.rm = TRUE ))/current$sigmaESq

    current$"gamma" = rnorm(length(current$"gamma"), mean = coef*var, sd = sqrt(var))

    ## Update Delta
    mean = logit(current$p) + current$theta + replicate(numYears,t(replicate(numSites,current$gamma)))
    var =  1/( (1/current$sigmaDeltaSq) + rowSums(data$n, na.rm = TRUE)/current$sigmaESq)
    coef = rowSums(data$n*(data$logit - mean), na.rm = TRUE )/current$sigmaESq

    current$"delta" = rnorm(numSites, mean = coef*var, sd = sqrt(var))

    ## Update SigmaDeltaSq
    current$sigmaDeltaSq = 1/rgamma(n=1, shape = 5 + length(current$delta)/2 , rate = 5 + sum ( (current$delta)^2 )/2 )

    ## Update SigmaGammaSq
    current$sigmaGammaSq = 1/rgamma(n=1, shape = 5 + length(current$gamma)/2 , rate = 5 + sum ( (current$gamma)^2 )/2 )

    ## Update SigmaESq
    mean = logit(current$p) + current$theta + replicate(numYears,outer(current$delta, current$gamma, FUN=function(x,y) (x+y)))
    current$sigmaESq = 1/rgamma(n=1, shape = 1 + sum(!is.na(data$logit))/2 , rate = 1 + sum ( data$n*(data$logit - mean)^2 , na.rm=TRUE)/2 )                                           

    ## Update "sigmaSq.yearTrend"
    current$"sigmaSq.yearTrend" = 1/rgamma(n=1, shape = .5 + length(current$yearTrend)/2 , rate = .5 + sum ( (current$yearTrend)^2 )/2 )
    
    return(current)
}

runMCMC = function(data, length, thin, burnin)
{
    
    ## Allocate Memory For Chain
    chain = makeChain(data, length)
    
    ## Initialize Chain
    current = initialize(data)

    ## Burn-In
    for(k in 1:burnin)
    {
        ## Update Chain
        current = update(current, data)
    }
    
    ## Start Update Loop
    for(k in 1:(length*thin))
    {
        ## Update Chain
        current = update(current, data)
        
        ## Save Every thinth Iteration
        if( (k %% thin) == 0)
        {
            chain$"alpha0"[k/thin] = current$"alpha0"
            chain$"a0"[k/thin] = current$"a0"
            chain$"beta0"[k/thin] = current$"beta0"
            chain$"b0"[k/thin] = current$"b0"
            chain$"alpha"[k/thin,] = current$"alpha"
            chain$"a"[k/thin,] = current$"a"
            chain$"beta"[k/thin,] = current$"beta"
            chain$"b"[k/thin,] = current$"b"
            chain$"pi"[k/thin,,] = current$"pi"
            chain$"sigmaPiSq"[k/thin] = current$"sigmaPiSq"
            chain$"N"[k/thin,,] = current$"N"
            chain$"p"[k/thin,,,] = current$"p"
            chain$"sigmaPSq"[k/thin] = current$"sigmaPSq"
            chain$"sigmaNSq"[k/thin,,] = current$"sigmaNSq"
            chain$"sigmaGammaSq"[k/thin] = current$"sigmaGammaSq"
            chain$"sigmaDeltaSq"[k/thin] = current$"sigmaDeltaSq"
            chain$"sigmaESq"[k/thin] = current$"sigmaESq"
            chain$"mu"[k/thin] = current$"mu"
            chain$"theta"[k/thin] = current$"theta"
            chain$"gamma"[k/thin,] = current$"gamma"
            chain$"delta"[k/thin,] = current$"delta"
            chain$"yearTrend"[k/thin,] = current$"yearTrend"
            chain$"sigmaSq.yearTrend"[k/thin] = current$"sigmaSq.yearTrend"
        }
    }

    
    ## return chain
    return(chain)
}

