load(file = "./crossResults.RData")
source("./LoadData.r")
source("./MCMC.r")

data = LoadData()

CL = 1:19*.05
CI.Percent = 1 - CL

coverage.phat.percent = apply(coverage.phat ,MARGIN = 4, FUN = mean, na.rm = TRUE)
coverage.nsu.percent = apply(coverage.NSU,MARGIN = 3, FUN = mean, na.rm = TRUE)


setEPS()
postscript("./plots/predictions.eps", height = 3, width = 6)

par(mfrow=c(1,2),mex=0.5, mai=c(0.5,0.5,0.2,0.2))
plot( logit.est, logit(data$phat), ylab = "Observed logit estimated proportion", xlab = "Predicted logit estimate")
abline(a = 0, b=1)


plot( lognsu.est, log(data$NSU), ylab = "Observed log NSU estimate", xlab = "Predicted log NSU estimate")
abline(a = 0, b=1)
dev.off()

data$phat[is.infinite(logit(data$phat))] = NA
present = !is.na(logit(data$phat)) & !is.nan(logit(data$phat))
cor(logit(phat.est)[present], logit(data$phat)[present])

present = !is.na(log(data$NSU)) & !is.nan(log(data$NSU))
cor(log(nsu.est)[present], log(data$NSU)[present])
