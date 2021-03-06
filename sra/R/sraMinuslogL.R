sraMinuslogL <-
function (sradata, FUNtimeseries = sraAutoregTimeseries, Bulmer = TRUE, 
    logvarME = log(1e-20), ...) 
{
    ss <- split(sradata, sradata$rep)
    minuslogL <- 0
    for (pop in ss) {
        range <- 1:(nrow(pop) - 1)
        tsr <- do.call(what = FUNtimeseries, args = c(list(beta = (pop$sel[range] - 
            pop$mean[range])/(pop$var[range]), delta = (pop$vsel[range] - 
            pop$var[range])/pop$var[range], ...)))
        minuslogL <- minuslogL + sraAutoregTsMinuslogL(pop$mean, 
            pop$var, pop$N, tsr$mean, tsr$varP, logvarME = logvarME)
    }
    return(minuslogL)
}
