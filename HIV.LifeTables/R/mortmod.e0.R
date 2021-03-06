mortmod.e0 <- function(e0, prev, region=1, sex=1, opt=TRUE){
	
lt.mx <- function(nmx, sex="female", age=c(0,1,seq(5,100,5)), nax=NULL){
	if(is.null(nax)){

		nax <- rep(2.5,length(age))

		if (sex=="male") { # TRUE for male, FALSE for female
			if (nmx[1] >= 0.107) {
				nax[1] <- 0.33
				nax[2] <- 1.352
			} else {
				nax[1] <- 0.045+2.684*nmx[1]
				nax[2] <- 1.651-2.816*nmx[1]
				}
			} 
		if (sex=="female") {
			if (nmx[1] >= 0.107) {
				nax[1] <- 0.35
				nax[2] <- 1.361
			} else {
				nax[1] <- 0.053+2.8*nmx[1]
				nax[2] <- 1.522-1.518*nmx[1]
				}
			}
	} else {nax=nax}
    
    n <- c(diff(age), 999)
    nqx <- (n*nmx)/(1+(n-nax)*nmx)
    nqx <- c(nqx[-(length(nqx))], 1)
    for(i in 1:length(nqx)){
    	if(nqx[i] > 1) nqx[i] <- 1
    	}
    nage <- length(age)

    #nqx <- round(nqx, 4)

    npx <- 1 - nqx
    max.age <- min(which(npx==0))
    l0=100000
    lx <- round(cumprod(c(l0, npx)))
    #lx <- (cumprod(c(l0, npx)))
    ndx <- -diff(lx)
    lxpn <- lx[-1]
    nLx <- n * lxpn + ndx * nax
    lx <- lx[1:length(age)]
    nLx[max.age] <- lx[max.age]/nmx[max.age]
    Tx <- rev(cumsum(rev(nLx)))
    ex <- Tx/lx
    lt <- cbind(Age = age, nax = nax, nmx = nmx, nqx = nqx, npx = npx, ndx = ndx, lx = lx, nLx = round(nLx), Tx = round(Tx), 
        ex = round(ex, 2))
     lt <- lt[lt[,6]!=0,]
     e0 <- lt[1,10]
     lt.45q15 <- 1-(lx[14]/lx[5])
     lt.5q0 <- 1-(lx[3]/lx[1])
     return(list(e0=e0, lt.5q0=lt.5q0, lt.45q15=lt.45q15, lt=lt))
        }	
		
if(region==1 & sex==0){ # Africa, male
	intercept <- median(svd.coeffs.xp[africa.nums,1])
	b1.m <- predict.lm(co1.e0mod.a.m, newdata=data.frame(le.a.m=e0))
	b2.m <- predict.lm(co2.e0mod.a.m, newdata=data.frame(le.a.m=e0, prev.a=prev))
	b3.m <- predict.lm(co3.e0mod.a.m, newdata=data.frame(le.a.m=e0, prev.a=prev))
	
	if(opt==FALSE){
	out.mort <- intercept + b1.m*Mx.svd.scores[,1] + b2.m*Mx.svd.scores[,2] + b3.m*Mx.svd.scores[,3]} # if
	
## optimize the intercent when predicting the mortality rates from the weights
	if(opt==TRUE){
		out.mort.func <- function(intercept.alter){
		out.mort <- intercept.alter + b1.m*Mx.svd.scores[,1] + b2.m*Mx.svd.scores[,2] + b3.m*Mx.svd.scores[,3]
		lt.out <- lt.mx(nmx=exp(out.mort[1:22]), sex="male", age=c(0,1,seq(5,100,5)))
		e0.diff <- abs(e0-unname(lt.out$e0))
	return(e0.diff)	
	} # function to be optimized
	
	intercept.opt <- optimize(f=out.mort.func, interval=c(-2,2))$minimum
	
	out.mort <- intercept.opt + b1.m*Mx.svd.scores[,1] + b2.m*Mx.svd.scores[,2] + b3.m*Mx.svd.scores[,3]} # if
	
	out.mort <- exp(out.mort)
	return(out.mort[1:22])
}

if(region==1 & sex==1){ # Africa, female
	intercept <- median(svd.coeffs.xp[africa.nums,1])
	b1.f <- predict.lm(co1.e0mod.a.f, newdata=data.frame(le.a.f=e0))
	b2.f <- predict.lm(co2.e0mod.a.f, newdata=data.frame(le.a.f=e0, prev.a=prev))
	b3.f <- predict.lm(co3.e0mod.a.f, newdata=data.frame(le.a.f=e0, prev.a=prev))
	
	if(opt==FALSE){
	out.mort <- intercept + b1.f*Mx.svd.scores[,1] + b2.f*Mx.svd.scores[,2] + b3.f*Mx.svd.scores[,3]}
	
## optimize the intercent when predicting the mortality rates from the weights
	if(opt==TRUE){
		out.mort.func <- function(intercept.alter){
		out.mort <- intercept.alter + b1.f*Mx.svd.scores[,1] + b2.f*Mx.svd.scores[,2] + b3.f*Mx.svd.scores[,3]
		lt.out <- lt.mx(nmx=exp(out.mort[(22+1):(22*2)]), sex="female", age=c(0,1,seq(5,100,5)))
		e0.diff <- abs(e0-unname(lt.out$e0))
	return(e0.diff)	
	} # function to be optimized
	
	intercept.opt <- optimize(f=out.mort.func, interval=c(-2,2))$minimum
	
	out.mort <- intercept.opt + b1.f*Mx.svd.scores[,1] + b2.f*Mx.svd.scores[,2] + b3.f*Mx.svd.scores[,3]} # if
		
	out.mort <- exp(out.mort)
	return(out.mort[(22+1):(22*2)])
}

if(region==0 & sex==0){ # Non-Africa, male
	intercept <- median(svd.coeffs.xp[la.nums,1])
	b1.m <- predict.lm(co1.e0mod.na.m, newdata=data.frame(le.na.m=e0))
	b2.m <- predict.lm(co2.e0mod.na.m, newdata=data.frame(le.na.m=e0, prev.na=prev))
	b3.m <- predict.lm(co3.e0mod.na.m, newdata=data.frame(le.na.m=e0, prev.na=prev))
	
	if(opt==FALSE){
	out.mort <- intercept + b1.m*Mx.svd.scores[,1] + b2.m*Mx.svd.scores[,2] + b3.m*Mx.svd.scores[,3]}
	
## optimize the intercent when predicting the mortality rates from the weights
	if(opt==TRUE){
		out.mort.func <- function(intercept.alter){
		out.mort <- intercept.alter + b1.m*Mx.svd.scores[,1] + b2.m*Mx.svd.scores[,2] + b3.m*Mx.svd.scores[,3]
		lt.out <- lt.mx(nmx=exp(out.mort[1:22]), sex="male", age=c(0,1,seq(5,100,5)))
		e0.diff <- abs(e0-unname(lt.out$e0))
	return(e0.diff)	
	} # function to be optimized
	
	intercept.opt <- optimize(f=out.mort.func, interval=c(-2,2))$minimum
	
	out.mort <- intercept.opt + b1.m*Mx.svd.scores[,1] + b2.m*Mx.svd.scores[,2] + b3.m*Mx.svd.scores[,3]} # if
	
	out.mort <- exp(out.mort)
	return(out.mort[1:22])
}
if(region==0 & sex==1){ # Non-Africa, female
	intercept <- median(svd.coeffs.xp[la.nums,1])
	b1.f <- predict.lm(co1.e0mod.na.f, newdata=data.frame(le.na.f=e0))
	b2.f <- predict.lm(co2.e0mod.na.f, newdata=data.frame(le.na.f=e0, prev.na=prev))
	b3.f <- predict.lm(co3.e0mod.na.f, newdata=data.frame(le.na.f=e0, prev.na=prev))
	
	if(opt==FALSE){
	out.mort <- intercept + b1.f*Mx.svd.scores[,1] + b2.f*Mx.svd.scores[,2] + b3.f*Mx.svd.scores[,3]}
	
## optimize the intercent when predicting the mortality rates from the weights
	if(opt==TRUE){
		out.mort.func <- function(intercept.alter){
		out.mort <- intercept.alter + b1.f*Mx.svd.scores[,1] + b2.f*Mx.svd.scores[,2] + b3.f*Mx.svd.scores[,3]
		lt.out <- lt.mx(nmx=exp(out.mort[(22+1):(22*2)]), sex="female", age=c(0,1,seq(5,100,5)))
		e0.diff <- abs(e0-unname(lt.out$e0))
	return(e0.diff)	
	} # function to be optimized
	
	intercept.opt <- optimize(f=out.mort.func, interval=c(-2,2))$minimum
	
	out.mort <- intercept.opt + b1.f*Mx.svd.scores[,1] + b2.f*Mx.svd.scores[,2] + b3.f*Mx.svd.scores[,3]} # if
	
	out.mort <- exp(out.mort)
	return(out.mort[(22+1):(22*2)])
}
}
