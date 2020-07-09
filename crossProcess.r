setwd("/storage/home/jlp592/work/UkraineWithYearEffect/")
load(file = "./preProcessCross.RData")
source("./MCMC.r")
                                        # Calculate Estimates
nsu.est = colMeans(nsu)
phat.est = colMeans(phat)
logit.est = colMeans(logit(phat))
lognsu.est = colMeans(log(nsu) )

errors.nsu = (nsu.est - data$NSU)^2
errors.phat = (phat.est - data$phat)^2
    
coverage.phat = array(dim=c(27,7,9,19))
coverage.NSU = array(dim=c(27,9,19))

CL = 1:19*.05

for(site in 1:27)
{
    for(year in 1:9)
    {
        for(list in 1:7)
        {
            if(!is.na(data$phat[site,list,year]))
            {                
                lower = quantile(phat[,site,list,year], na.rm = TRUE, probs = .5 - (1 - CL)/2)
                upper = quantile(phat[,site,list,year], na.rm = TRUE, probs = .5 + (1 - CL)/2)

                coverage.phat[site,list,year,] = (lower < data$phat[site,list,year]) & ( data$phat[site,list,year] < upper)
                
            }

        }
        if(!is.na(data$NSU[site,year]))
        {
            lower = quantile(nsu[,site,year], na.rm = TRUE, probs = .5 - (1 - CL)/2)
            upper = quantile(nsu[,site,year], na.rm = TRUE, probs = .5 + (1 - CL)/2)

            coverage.NSU[site,year,] = (lower < data$NSU[site,year]) & ( data$NSU[site,year] < upper)
        }
    }
}

save(list = c("coverage.NSU", "coverage.phat", "nsu.est", "phat.est", "errors.nsu", "errors.phat", "logit.est", "lognsu.est"), file = "./crossResults.RData")

