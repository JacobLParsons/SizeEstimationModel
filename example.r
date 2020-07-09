source("./LoadData.r") 
source("./MCMC.r")
                                        # Load Data
data = LoadData()
data$logit = logit(data$phat)
data$logit[is.infinite(data$logit)] = NA
                                    
                                        # Run Simulation
NSU = data$NSU
numYears = 9
numSites = 27

mu = -1
tauSq = 1

missingNSU = is.na(data$NSU)
missingY = is.na(data$Y)
missingLogit = is.na(data$logit)

data$Y[missingY] = NA
data$Y[missingLogit] = NA
data$logit[missingY] = NA
data$NSU[missingNSU] = NA

Ypresent = apply(!is.na(data$Y), MARGIN = c(1,3), FUN = max)
NSUpresent = !is.na(data$NSU)

NoData = !Ypresent & !NSUpresent
OnlyY = Ypresent & !NSUpresent
OnlyNSU = !Ypresent & NSUpresent
Both = Ypresent & NSUpresent
                                        # Run Chain


                                        # Run Chain For Real Data

                                        # Load Data
data = LoadData()
data$logit = logit(data$phat)
data$logit[is.infinite(data$logit)] = NA


length = 5000
thin = 400
burnin = 10000

missingNSU = is.na(data$NSU)
missingY = is.na(data$Y)
missingLogit = is.na(data$logits)

data$Y[missingLogit] = NA
data$logit[missingY] = NA

                                        # Start With Last point of Other Analysis

                                        # Run Chain
chain = makeChain(data, length)

#1:1 runs a single chain.
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

    save.image(file = paste("./results/", n, ".RData", sep = "") )
}
 
save(file = "./results/current.RData",list = c("current") )

#Plots start here

                                        # Trace Plots

png(filename="./plots/muTracePlot.png")
plot(chain$mu)
dev.off()

png(filename="./plots/thetaTracePlot.png")
plot(chain$theta)
dev.off()

for(i in 1:numSites)
{
    png(filename=paste("./plots/delta/",i,".png", sep = ""))
    plot(chain$delta[,i])
    dev.off()
}

for(j in 1:7)
{
    png(filename=paste("./plots/gamma/",j,".png", sep = ""))
    plot(chain$gamma[,j])
    dev.off()
}

for(i in 1:numSites)
{
    for(j in 1:7)
    {
        png(filename=paste("./plots/pi/",i,"-", j,".png", sep = ""))
        plot(chain$pi[,i,j])
        dev.off()
    }    
}


RateEstimates = colMeans(chain$pi)
png(filename="./plots/RateEstimates.png")
plot(RateEstimates[1,], type="l", ylim = c(0, .15), main = "Population Prevalence Estimates Over Time", ylab = "Rate Estimate", xlab = "Time")
        
for(i in 2:25)
{
  lines(RateEstimates[i,], type="l", col=i)
}
dev.off()


SizeEstimates = colMeans(chain$N)
png(filename="./plots/SizeEstimates.png")
plot(SizeEstimates[1,], type="l", ylim = c(0, 150000), main = "Population Size Estimates Over Time", ylab = "Size Estimate", xlab = "Time")
for(i in 2:25)
{
  lines(SizeEstimates[i,], type="l", col=i)
}

dev.off()


for(i in 1:numYears)
{
        png(filename=paste("./plots/yearTrend/",i,".png", sep = ""))
        plot(chain$yearTrend[,i])
        dev.off()
}




mean(chain$mu)
mean(chain$theta)

png(filename="./plots/N1-2.png")
plot(chain$N[,1,2])
dev.off()

png(filename="./plots/muvsyear.png")
plot(chain$mu, chain$yearTrend[,2])
dev.off()

setEPS()
postscript("./plots/fittedvalues.eps", height = 4, width = 5.5)
par(mfrow=c(1,1), las = 0,mex=0.5, mai=c(0.5,0.5,0.2,0.2))
RateEstimates = colMeans(chain$pi)

plot(RateEstimates[1,], type="l", ylim = c(0, .1), main = "Population prevalence estimates over time", ylab = "Rate estimate", xlab = "Year", axes=F)
        
for(i in 2:25)
{
  lines(RateEstimates[i,], type="l")
}
axis(1, at=1:9, labels=2007:2015)
axis(2)
dev.off()

setEPS()
postscript("./plots/fittedvalues2.eps", height = 4, width = 5.5)
par(mfrow=c(1,1), las = 0,mex=0.5, mai=c(0.5,0.5,0.2,0.2))

SizeEstimates = colMeans(chain$N)
plot(SizeEstimates[1,], type="l", ylim = c(0, 140000), main = "Population size estimates over time", ylab = "Size estimate (in thousands)", xlab = "Year",axes=F)
for(i in 2:25)
{
  lines(SizeEstimates[i,], type="l")
}
axis(1, at=1:9, labels=2007:2015)
axis(2, at=(0:7)*20000,labels = (0:7)*20)
dev.off()
