
setMethod("residuals", "lavaan",
function(object, type="raw", labels=TRUE) {

    # lowercase type
    type <- tolower(type)

    # catch type="casewise"
    if(type %in% c("casewise","case","obs","observations","ov")) {
        return( lav_residuals_casewise(object, labels = labels) )
    }
 
    # checks
    if(type %in% c("normalized", "standardized")) {
        if(object@Options$estimator != "ML") {
            stop("standardized and normalized residuals only availabe if estimator = ML (or MLF, MLR, MLM\n")
        }
        if(object@Fit@npar > 0L && !object@Fit@converged) {
            stop("lavaan ERROR: model dit not converge")
        }
    }
    # NOTE: for some reason, Mplus does not compute the normalized/standardized
    # residuals if estimator = MLM !!!
 

    # check type
    if(!type %in% c("raw", "cor",
        "cor.bollen", "cor.bentler", "cor.eqs",
        "normalized", "standardized", "casewise")) {
        stop("type must be one of \"raw\", \"cor\", \"cor.bollen\", \"cor.bentler\", \"normalized\" or \"standardized\" or \"casewise\"")
    }
    
    # if cor, choose 'default'
    if(type == "cor") {
        if(object@Options$mimic == "EQS") {
            type <- "cor.bentler"
        } else {
            type <- "cor.bollen"
        }
    }

    # check for 0 parameters if type == standardized
    if(type == "standardized" &&
       object@Fit@npar == 0) {
        stop("lavaan ERROR: can not compute standardized residuals if there are no free parameters in the model")
    }

    G <- object@Data@ngroups
    meanstructure <- object@Model@meanstructure
    ov.names <- object@Data@ov.names

    # if type == standardized, we need VarCov and Delta
    if(type == "standardized") {
        # fixed.x idx?
        x.idx <- integer(0)
        if(object@Options$fixed.x) {
            x.idx <- match(vnames(object@ParTable, "ov.x", group=1L),
                           object@Data@ov.names[[1L]]) ### FIXME!!!! will not
                                                       ### work for different
        }                                              ### models in groups

        if(length(x.idx) > 0L) {
            # we need to:
            # 1) to `augment' VarCov and Delta with the fixed.x  elements
            # 2) set cov between free and fixed.x elements in VarCov to zero

            # create 'augmented' User object (as if fixed.x=FALSE was used)
            augUser <- object@ParTable
            idx <- which(augUser$exo > 0L)
            augUser$exo[       idx ] <- 0L
            augUser$free[      idx ] <- max(augUser$free) + 1:length(idx) 
            #augUser$unco[idx ] <- max(augUser$unco) + 1:length(idx) 
            augModel <- lav_model(lavpartable    = augUser,
                                  representation = object@Options$representation,
                                  parameterization = object@Options$parameterization,
                                  link           = object@Options$link,
                                  debug          = object@Options$debug)
            VarCov <- lav_model_vcov(lavmodel       = augModel, 
                                     lavsamplestats = object@SampleStats,
                                     lavdata        = object@Data,
                                     lavpartable    = object@ParTable,
                                     lavoptions     = object@Options)
            # set cov between free and fixed.x elements to zero
            ###
            ### FIXME: should we not do this on the information level,
            ###        *before* we compute VarCov?
            ###
            fixed.x.idx <- max(object@ParTable$free) + 1:length(idx) 
            free.idx    <- 1:max(object@ParTable$free)
            VarCov[free.idx, fixed.x.idx] <- 0.0
            VarCov[fixed.x.idx, free.idx] <- 0.0

            Delta  <- computeDelta(lavmodel = augModel)
        } else {
            VarCov <- lav_model_vcov(lavmodel       = object@Model,
                                     lavdata        = object@Data,
                                     lavpartable    = object@ParTable,
                                     lavsamplestats = object@SampleStats,
                                     lavoptions     = object@Options)
            Delta  <- computeDelta(lavmodel = object@Model)
        }   
    }

    R <- vector("list", length=G)
    for(g in 1:G) {

        # add type
        R[[g]]$type <- type

        # sample moments
        if(!object@SampleStats@missing.flag) {
            S <- object@SampleStats@cov[[g]]
            M <- object@SampleStats@mean[[g]]
        } else {
            S <- object@SampleStats@missing.h1[[g]]$sigma
            M <- object@SampleStats@missing.h1[[g]]$mu
        }
        if(!meanstructure) {
            M <- numeric( length(M) )
        }
        nvar <- ncol(S)

        # residuals (for this group)
        if(type == "cor.bollen") {
            R[[g]]$cov  <- cov2cor(S) - cov2cor(object@Fit@Sigma.hat[[g]])
            R[[g]]$mean <- ( M/sqrt(diag(S)) -
                object@Fit@Mu.hat[[g]]/sqrt(diag(object@Fit@Sigma.hat[[g]])) )
        } else if(type == "cor.bentler" || type == "cor.eqs") {
            # Bentler EQS manual: divide by (sqrt of) OBSERVED variances
            delta <- 1/sqrt(diag(S))
            DELTA <- diag(delta, nrow=nvar, ncol=nvar)
            R[[g]]$cov  <- DELTA %*% (S - object@Fit@Sigma.hat[[g]]) %*% DELTA
            R[[g]]$mean <- (M - object@Fit@Mu.hat[[g]])/sqrt(diag(S))
        } else {
            # covariance/raw residuals
            R[[g]]$cov  <- S - object@Fit@Sigma.hat[[g]]
            R[[g]]$mean <- M - object@Fit@Mu.hat[[g]]
        }
        if(labels) {
            rownames(R[[g]]$cov) <- colnames(R[[g]]$cov) <- ov.names[[g]]
        }
        if(object@Model@categorical) {
            R[[g]]$th <- object@SampleStats@th[[g]] - object@Fit@TH[[g]]
            if(length(object@Model@num.idx[[g]]) > 0L) {
                R[[g]]$th <- R[[g]]$th[-object@Model@num.idx[[g]]]
            }
            if(labels) {
                names(R[[g]]$th) <- vnames(object@ParTable, type="th", group=g)
            }
        }

        if(type == "normalized" || type == "standardized") {
         
            # compute normalized residuals
            N <- object@SampleStats@nobs[[g]]; nvar <- length(R[[g]]$mean)
            idx.mean <- 1:nvar

            if(object@Options$se == "standard" ||
               object@Options$se == "none") {
                dS <- diag(S)
                Var.mean <- Var.sample.mean <- dS / N 
                Var.cov  <- Var.sample.cov  <- (tcrossprod(dS) + S*S) / N
                # this is identical to solve(A1)/N for complete data!!
            } else if(object@Options$se == "robust.huber.white" ||
                      object@Options$se == "robust.sem") {
                A1 <- compute.A1.sample(lavsamplestats = object@SampleStats, 
                                        group = g, 
                                        meanstructure = meanstructure,
                                        information = object@Options$information)
                B1 <- compute.B1.sample(lavsamplestats = object@SampleStats, 
                                        lavdata = object@Data, group = g,
                                        meanstructure = meanstructure)
                Info <- (solve(A1) %*% B1 %*% solve(A1)) / N
                Var.mean <- Var.sample.mean <- diag(Info)[idx.mean]
                Var.cov  <- Var.sample.cov  <- lav_matrix_vech_reverse(diag(Info)[-idx.mean])
            } else if(object@Options$se == "first.order") {
                B1 <- compute.B1.sample(lavsamplestats = object@SampleStats, 
                                        lavdata = object@Data, group=g,
                                        meanstructure=meanstructure)
                Info <- solve(B1) / N
                Var.mean <- Var.sample.mean <- diag(Info)[idx.mean]
                Var.cov  <- Var.sample.cov  <- lav_matrix_vech_reverse(diag(Info)[-idx.mean])
            }
        }

        if(type == "standardized") {

            Var.model <- diag(Delta[[g]] %*% VarCov %*% t(Delta[[g]]))
 
            if(meanstructure) {
                Var.model.mean <- Var.model[idx.mean]
                Var.model.cov  <- lav_matrix_vech_reverse(Var.model[-idx.mean])
            } else {
                Var.model.mean <- rep(0, nvar)
                Var.model.cov  <- lav_matrix_vech_reverse(Var.model)
            }

            Var.mean <- (Var.sample.mean - Var.model.mean)
            Var.cov  <- (Var.sample.cov  - Var.model.cov )

            # not for fixed x covariates
            if(length(x.idx) > 0L) {
                Var.mean[x.idx] <- 1.0
                Var.cov[x.idx,x.idx] <- 1.0
            }

            # avoid negative variances
            Var.mean[which(Var.mean < 0)] <- NA
            Var.cov[ which(Var.cov  < 0)] <- NA
        }

        # normalize/standardize
        if(type == "normalized" || type == "standardized") {
            # avoid small number (< 1.0e-15) to be divided
            # by another small number and get bigger...
            # FIXME!!!
            tol <- 1.0e-5
            R[[g]]$mean[ which(abs(R[[g]]$mean) < tol)] <- 0.0
            R[[g]]$cov[ which(abs(R[[g]]$cov) < tol)] <- 0.0
            
            R[[g]]$mean <- R[[g]]$mean / sqrt( Var.mean )
            R[[g]]$cov  <- R[[g]]$cov  / sqrt( Var.cov  )
        }

        # prepare for pretty printing
        R[[g]]$mean <- as.numeric(R[[g]]$mean)
        if(labels) names(R[[g]]$mean) <- ov.names[[g]]
        class(R[[g]]$mean) <- c("lavaan.vector", "numeric")
        class(R[[g]]$cov) <- c("lavaan.matrix.symmetric", "matrix")
    }

    # replace 'cov' by 'cor' if type == "cor"
    if(type %in% c("cor","cor.bollen","cor.eqs","cor.bentler")) {
        if("th" %in% names(R[[1]])) {
            R <- lapply(R, "names<-", c("type", "cor", "mean", "th") )
        } else {
            R <- lapply(R, "names<-", c("type", "cor", "mean") )
        }
    }

    if(G == 1) {
        R <- R[[1]]
    } else {
        names(R) <- unlist(object@Data@group.label)
    }

    R
})

setMethod("resid", "lavaan",
function(object, type="raw") {
    residuals(object, type=type)
})

lav_residuals_casewise <- function(object, labels = labels) {

    # check if we have full data
    if(object@Data@data.type != "full") {
        stop("lavaan ERROR: casewise residuals not available if sample statistics were used for fitting the model")
    }

    G <- object@Data@ngroups
    ov.names <- object@Data@ov.names

    X <- object@Data@X
    if(object@Model@categorical) {
        # add 'eXo' columns to X
        X <- lapply(seq_len(object@Data@ngroups), function(g) {
                    ret <- cbind(X[[g]], object@Data@eXo[[g]])
                    ret })
    }
    M <- lav_predict_yhat(object)
    # Note: if M has already class lavaan.matrix, print goes crazy
    # with Error: C stack usage is too close to the limit
    OUT <- lapply(seq_len(G), function(x) { 
               out <- X[[x]] - M[[x]] 
               class(out) <- c("lavaan.matrix", "matrix")
               out
           })

    if(labels) {
        for(g in 1:G) {
            colnames(OUT[[g]]) <- object@pta$vnames$ov[[g]]
        }
    }

    if(G == 1) {
        OUT <- OUT[[1]]
    } else {
        names(OUT) <- unlist(object@Data@group.label)
    }

    OUT
}

