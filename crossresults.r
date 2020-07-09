source("./MCMC.r")
source("./LoadData.r")

site = 1
setwd(paste("./CrossValidation/", site, "/", sep = ""))
load("./1.RData")

setwd("../..")
data = LoadData()

phat = array(dim = c(length(chain$theta),27,7,9))
nsu = array(dim = c(length(chain$theta),27,9))

for(site in 1:27)
{
    setwd(paste("./CrossValidation/", site, "/", sep = ""))

    load("./1.RData")
        
    NSU.se = data$NSU.se
    setwd("../../")
    data = LoadData()                                        # Run Simulations

    for(n in 1:length(chain$theta))
    {
        delta = rnorm(n =1 , mean = 0, sd = sqrt(chain$sigmaDeltaSq[n]))
        theta = chain$theta[n]
        mu = chain$mu[n]
        tauSq = chain$sigmaNSq[n,2,2] / NSU.se[2,2]^2

        for(list in 1:7)
        {
            gamma = chain$gamma[n, list]
            p = rep(NaN, 9)
            
            for(year in 1:9)
            {
                
                epsilon = rnorm(n = 1, mean = 0, sd = sqrt(chain$sigmaESq[n]/data$n[site, list, year]) )

                if(year == 1)
                    p[year] = rbeta(n=1, shape1 = chain$alpha[n,list], shape2 = chain$beta[n,list])

                else
                {
                    logit.p = logit( p[year - 1]) + rnorm(n = 1, mean = 0, sd = sqrt(chain$sigmaPSq[n]))
                    p[year] = invlogit(logit.p)                    
                }

                logit.phat = logit(p[year]) + theta + gamma + delta + epsilon
                phat[n,site, list, year] = invlogit(logit.phat)
                
            }        
        }

        pi = rep(NaN, 9)

        for(year in 1:9)
        {
            yearTrend = chain$yearTrend[n,year]

            if(year == 1)
                pi[year] = rbeta(n=1, shape1 = chain$alpha0[n], shape2 = chain$beta0[n])

            else
            {
                logit.pi = logit( pi[year - 1]) + rnorm(n = 1, mean = yearTrend, sd = sqrt(chain$sigmaPiSq))
                pi[year] = invlogit(logit.pi)                    
            }

            N = rbinom(1, size = data$R[site, year], prob = pi[year])

            
            sigma = data$NSU.se[site,year]*sqrt(tauSq) / N

            nsu[n,site,year] = exp( log(N) + mu + rnorm(n=1, mean = 0, sd = sigma) )
            
        }
    }

    print(site)

}

save.image(file = "./preProcessCross.RData")
