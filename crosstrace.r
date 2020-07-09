for(site in 1:27)
{
    setwd(paste("./CrossValidation/", site, "/", sep = ""))
    load("./1.RData")
                                        # Trace Plots
    dir.create("./plots/", showWarnings = FALSE)
    dir.create("./plots/delta", showWarnings = FALSE)
    dir.create("./plots/gamma", showWarnings = FALSE)
    dir.create("./plots/pi", showWarnings = FALSE)

    png(filename="./plots/muTracePlot.png")
    plot(chain$mu)
    dev.off()

    png(filename="./plots/thetaTracePlot.png")
    plot(chain$theta)
    dev.off()

    for(j in 1:7)
    {
        png(filename=paste("./plots/gamma/",j,".png", sep = ""))
        plot(chain$gamma[,j])
        dev.off()
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

    mean(chain$mu)
    mean(chain$theta)

}
