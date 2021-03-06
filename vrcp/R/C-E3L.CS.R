# Nonlinearizable C-E3L
# Common variance for both segments
# Smoothness

llsearch.E3L.CCS <- function(x, y, n, jlo, jhi,start1,start2,start3)
{
  fj <- matrix(0, n)
  fxy <- matrix(0, jhi - jlo + 1)
  
  jgrid <- expand.grid(jlo:jhi)
  k.ll <- apply(jgrid, 1, p.estFUN.E3L.CCS, x = x, y = y, n = n,
                start1=start1, start2=start2, start3=start3)
  
  fxy <- matrix(k.ll, nrow = jhi-jlo+1)
  rownames(fxy) <- jlo:jhi
  
  z <- findmax(fxy)
  jcrit <- z$imax + jlo - 1
  list(jhat = jcrit, value = max(fxy))
}

#  Function for deriving the ML estimates of the change-points problem.

p.estFUN.E3L.CCS <- function(j, x, y, n,start1,start2,start3){
  a <- p.est.E3L.CCS(x,y,n,j,start1,start2,start3)
  s2 <- a$sigma2
  return(p.ll.CCS(n, j, s2))
}

p.est.E3L.CCS <- function(x,y,n,j,start1,start2,start3){
  xa <- x[1:j]
  ya <- y[1:j]
  jp1 <- j+1
  xb <- x[jp1:n]
  yb <- y[jp1:n] 
  fun <- nls(y ~ I(x <= x[j])*(b0 + b1*x[j] - b1/a2 + b1/a2*exp(a2*(x-x[j]))) +
               I(x > x[j])*(b0 + b1*x), 
             start = list(a2 = start1,b0 = start2, b1 = start3))
  a2 <- summary(fun)$coe[1]
  b0 <- summary(fun)$coe[2]
  b1 <- summary(fun)$coe[3]
  a1 <- b1/a2
  a0 <- b0 + b1 * x[j] - a1
  beta <-c(a0,a1,a2,b0,b1)
  s2 <- (sum((ya-a0-a1*exp(a2*(xa-x[j])))^2) + sum((yb-b0-b1*xb)^2))/n
  list(a0=beta[1],a1=beta[2],a2=beta[3],b0=beta[4],b1=beta[5],sigma2=s2,xj=x[j])
}

#  Function to compute the log-likelihood of the change-point problem

p.ll.CCS <- function(n, j, s2){
  q1 <- n * log(sqrt(2 * pi))
  q2 <- 0.5 * n  * (1 + log(s2))
  - (q1 + q2)
}

findmax <-function(a)
{
  maxa<-max(a)
  imax<- which(a==max(a),arr.ind=TRUE)[1]
  jmax<-which(a==max(a),arr.ind=TRUE)[2]
  list(imax = imax, jmax = jmax, value = maxa)
}
