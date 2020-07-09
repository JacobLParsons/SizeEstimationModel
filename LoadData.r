library(dplyr)
library(forcats)

LoadData = function()
{    
                                        # Open Data Files
    dat2009 = read.table("./data/2009Local.csv", sep = ",", header = TRUE)
    dat2011 = read.table("./data/2011Local.csv", sep = ",", header = TRUE)
    dat2016 = read.table("./data/2016Local.csv", sep = ",", header = TRUE)

                                        # Load Multipler Data
    lists = c("DTF", "DTP", "Hospital", "NGO", "Prevention", "SMT", "Survey") 
    sites = dat2009$Oblast
    years = c("2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015")
    
    phat = array(data=NA,dim = c(27,7,9), dimnames = list(sites, lists, years))
    Y = array(data=NA,dim = c(27,7,9), dimnames = list(sites, lists, years))
    n = array(data=NA,dim = c(27,7,9), dimnames = list(sites, lists, years))

    ## DTF List

    phat[,1,9]= dat2016$Percent.Reporting.a.Stay
    Y[,1,9] = dat2016$Total.Num.Staying.In.State.Drug.Facility
    n[,1,9] = dat2016$Surveyed.in.2015

    ## DTP List
    
    phat[,2,8]= dat2016$Report.Covered.2014
    Y[,2,8] = dat2016$Covered.By.Drug.Treatment.Program.2014
    n[,2,8] = dat2016$Surveyed.in.2015

    phat[,2,9]= dat2016$Report.Covered.2015
    Y[,2,9] = dat2016$Covered.By.Drug.Treatment.Program.2015
    n[,2,9] = dat2016$Surveyed.in.2015
    
    ## Hospitalization List
    
    phat[,3,1] = dat2009$Percent.Report.in.2008.being.hospitalized.in.2007
    Y[,3,1] = dat2009$X2007.Total.Hospitalized
    n[,3,1] = dat2009$Num.Surveyed

    phat[,3,4] = dat2011$Prop.of.2011.Survey.Hospitalized.in.2010
    Y[,3,4] = dat2011$Total.Hospitalized.in.2010
    n[,3,4] = dat2011$X2011.Survey.Sample.Size
    
    phat[,3,8]= dat2016$Percent.Reporting.Hospitalization.2014
    Y[,3,8] = dat2016$Hospitalized.For.Addiction.2014
    n[,3,8] = dat2016$Surveyed.in.2015
    
    phat[,3,9] = dat2016$Percent.Reporting.Hospitalization.2015
    Y[,3,9] = dat2016$Hospitalized.For.Addiction.2015
    n[,3,9] = dat2016$Surveyed.in.2015
    
    ## NGO List
    
    phat[,4,4] = dat2011$Overlap/dat2011$Number.Answered.Question.on.Survey
    Y[,4,4] = dat2011$Total.Registered.with.NGO.for.Rapid.Tests
    n[,4,4] = dat2011$X2011.Survey.Sample.Size
    
    phat[,4,9]= dat2016$Reported.Registration.to.NGO
    Y[,4,9] = dat2016$Registered.by.NGO
    n[,4,9] = dat2016$Surveyed.in.2015
    
    ## Prevention List
    
    phat[,5,4] = dat2011$Proportion.in.Survey.Reporting.Registration
    Y[,5,4] = dat2011$Total.Registered.for.Prevention.Services
    n[,5,4] = dat2011$X2011.Survey.Sample.Size
    
    ## SMT List
    
    phat[,6,4] = dat2011$Proportion.Reporting.to.have.Recieved.in.2011
    Y[,6,4] = dat2011$Total.Recieved.SMT
    n[,6,4] = dat2011$X2011.Survey.Sample.Size
    
    phat[,6,8]= dat2016$Reported.SMT.2014
    Y[,6,8] = dat2016$Recieved.SMT.2014
    n[,6,8] = dat2016$Surveyed.in.2015
    
    phat[,6,9] = dat2016$Reported.SMT.2015
    Y[,6,9] = dat2016$Recieved.SMT.2015
    n[,6,9] = dat2016$Surveyed.in.2015
    
    ## Behav Surveys 

    phat[,7,3] = dat2011$Prop.of.2011.also.in.2009
    Y[,7,3] = dat2011$Number.Surveyed.in.2009
    n[,7,3] = dat2011$X2011.Survey.Sample.Size
    
    phat[,7,7]= dat2016$Num.Reporting.Being.Surveyed.in.2013/dat2016$Surveyed.in.2015
    Y[,7,7] = dat2016$Surveyed.in.2013
    n[,7,7] = dat2016$Surveyed.in.2015

    
                                        # Load NSU Data
    
    NSU = matrix(data=NA, nrow = 27, ncol = 9, dimnames = list(sites, years) )
    NSU.se = matrix(data=NA, nrow = 27, ncol = 9, dimnames = list(sites, years) )

    NSU[,2] = dat2009$NSU
    NSU.se[,2] = (NSU[,2] - dat2009$NSU.Lower)/2

                                        # Load Population    

    pop = read.table("./data/pop.csv", sep = ",", header = TRUE)
    R = as.matrix(pop[,-1])
    rownames(R) = dat2009$Oblast                                       
    colnames(R) = c("2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017" )
    
    ## Remove Years not in data
    R = R[,-c(10,11)]

    data = list("n" = n, "phat" = phat, "Y" = Y, "NSU" = NSU, "NSU.se" = NSU.se, "R" = R)

    return(data)
}
