`signrank.shape` <- function(X, fixed.loc=FALSE, location=NULL, init=NULL, steps=Inf, eps=1e-6, maxiter=100, na.action=na.fail)
{ 
 X <- na.action(X)
 X<-as.matrix(X) 

 p<-dim(X)[2]
 if(p==1) return(diag(1))
 if (is.null(init)) {V<-covshape(X)
 }else{ if(is.function(init)) init<-init(X)
  V<-to.shape(init)
 }
 if (is.null(location)) {mu<-colMeans(X)
 }else{ if(is.function(location)) location<-location(X)
  mu<-location
 }
 
 if(is.finite(steps)) maxiter<-Inf
 iter<-0

 if(!fixed.loc){
  while(TRUE)
  {
   if(iter>=steps) return(res)
   if(iter>=maxiter) stop("maxiter reached")
   iter<-iter+1
   sqrtV<-mat.sqrt(V)
   A <- solve(sqrtV)
   Z <- sweep(X,2,mu)%*%t(A)  
   mu.new <- mu+sqrtV%*%hl.center.step(Z,rep(0,p)) 
   V.new <- sqrtV%*%SRCov(Z,rep(0,p))%*%sqrtV 
   
   V.new <- to.shape(V.new)
   res <- V.new
   attr(res,"location") <- as.vector(mu.new)
   if(all(is.infinite(steps),mat.norm(V.new-V)<eps,sqrt(sum((mu.new -mu)^2))<eps)) return(res)
   mu<-mu.new
   V<-V.new
  }
 }else
 {
 X<-sweep(X,2,mu)

  while(TRUE)
 {
   if(iter>=steps) return(res)
   if(iter>=maxiter) stop("maxiter reached")
   iter<-iter+1
   sqrtV<-mat.sqrt(V)
   Q<-signranks(X%*%solve(sqrtV))
   V.new<-sqrtV%*%(t(Q)%*%Q)%*%sqrtV
   V.new<-to.shape(V.new)
   res<-V.new
   attr(res,"location") <- mu
   if(all(is.infinite(steps),mat.norm(V.new-V)<eps)) return(res)
   V<-V.new
 }
 }
}

