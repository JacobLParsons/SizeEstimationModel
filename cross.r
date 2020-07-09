args <- commandArgs(trailingOnly = TRUE)
site = as.integer(args[1])
                                        # Load Data

setwd("/storage/work/jlp592/UkraineWithYearEffect/")

source("./LoadData.r")
source("./MCMC.r")

numYears = 9
numSites = 26

                                        # Load Data
data = LoadData()

                                        # Remove Chosen Site From Data
data$n = data$n[-site,,]
data$phat = data$phat[-site,,]
data$Y = data$Y[-site,,]
data$NSU = data$NSU[-site,]
data$NSU.se = data$NSU.se[-site,]
data$R = data$R[-site,]
data$logit = logit(data$phat)
data$logit[is.infinite(data$logit)] = NA

length = 5000
thin = 300
burnin = 10000


missingNSU = is.na(data$NSU)
missingY = is.na(data$Y)
missingLogit = is.na(data$logits)

data$Y[missingLogit] = NA
data$logit[missingY] = NA



                                        # Load Start of Chain

load(paste("./CrossValidation/", site, "/current.RData", sep = ""))


                                        # Run Chain
chain = makeChain(data, length)

for(n in 1:1)
{
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

            print(k/thin)
        }
    }

    save.image(file = paste("./CrossValidation/", site, "/", n, ".RData", sep = "") )
}

save(file = paste("./CrossValidation/", site, "/current.RData", sep = ""), list = c("current") )

