extractdctable.default <- 
function(x, ...)
{
    quantiles <- c(0.025, 0.25, 0.5, 0.75, 0.975)
    y <- as.matrix(x)
    Mean <- apply(y, 2, mean)
    Sd <- apply(y, 2, sd)
    if (nchain(x) > 1) {
        abin <- getOption("dcoptions")$autoburnin
        rhat <- try(gelman.diag(x, autoburnin=abin)$psrf[,1])
        if (inherits(rhat, "try-error"))
            rhat <- NA
    } else rhat <- NA
    if (!is.null(quantiles)) {
        Qa <- apply(y, 2, quantile, probs=quantiles)
        rval <- rbind(mean = Mean, sd = Sd, Qa, r.hat=rhat)
    } else {
        rval <- rbind(mean = Mean, sd = Sd, r.hat=rhat)
    }
    rval <- t(rval)
    if (nrow(rval) == 1)
        rownames(rval) <- varnames(x, allow.null=FALSE)
    rval
}
