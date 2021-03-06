MCA <- function (X, ncp = 5, ind.sup = NULL, quanti.sup = NULL, quali.sup = NULL,
    graph = TRUE, level.ventil = 0, axes = c(1, 2), row.w = NULL, 
    method="Indicator",na.method="NA",tab.disj=NULL){
    
############
ventil.tab <- function (tab, level.ventil=0.05,row.w=NULL,ind.sup=NULL,quali.sup=NULL,quanti.sup=NULL) {
 if (is.null(row.w)) row.w <- rep(1,nrow(tab)-length(ind.sup))
 col.var <- 1:ncol(tab)
 if (!is.null(c(quali.sup,quanti.sup))) col.var = col.var[-c(quali.sup,quanti.sup)]
 for (i in col.var) {
   if (is.factor(tab[,i])){
      tab[,i] <- ventilation(tab[,i],level.ventil=level.ventil,row.w=row.w,ind.sup=ind.sup)
   }
   if (is.ordered(tab[,i])){
      tab[,i] <- ventilation.ordonnee(tab[,i],level.ventil=level.ventil,row.w=row.w,ind.sup=ind.sup)
   }
 }
 return(tab)
}

ventilation <- function(Xqual,level.ventil=0.05,row.w=NULL,ind.sup=NULL) {
 if (!is.factor(Xqual)) stop("Xqual should be a factor \n")
 modalites <- levels(Xqual)
 if (length(modalites)<=1) stop("not enough levels \n")
 if (is.null(ind.sup)) {
  ind.act <- (1:length(Xqual))
 } else {ind.act <- (1:length(Xqual))[-ind.sup]}
 tabl <- table(Xqual[ind.act])
 if (!is.null(row.w)){
   for (j in 1:nlevels(Xqual)) tabl[j] <- sum((Xqual[ind.act]==levels(Xqual)[j])*row.w,na.rm=TRUE)
 }
 selecti <- (tabl/sum(tabl,na.rm=TRUE))< level.ventil
 if (sum(selecti)==length(modalites)) return(Xqual)

 if (!any(selecti)) return(Xqual) else {
  lesquels <- modalites[!selecti]
#  if (length(lesquels)==1) return(NULL) else {
  if (length(lesquels)==1) return(Xqual) else {
   prov <- factor(Xqual[(Xqual%in%lesquels)],levels=lesquels)
   prov <- table(prov)
   proba <- prov/sum(prov)

   for (j in modalites[selecti]) {
    Xqual[which(Xqual==j)] <- sample(lesquels,sum(Xqual==j,na.rm=TRUE), replace=TRUE,prob=proba)
   }
   Xqualvent <- factor(as.character(Xqual))
  }
 }
 return(Xqualvent)
}

ventilation.ordonnee <- function(Xqual,level.ventil=0.05,ind.sup=NULL,row.w=NULL) {
 if (!is.ordered(Xqual)) stop("Xqual must be ordered \n")
 mod <- levels(Xqual)
 if (length(mod)<=1) stop("not enough levels \n")
 if (is.null(ind.sup)) {
  ind.act <- (1:length(Xqual))
 } else {ind.act <- (1:length(Xqual))[-ind.sup]}
 tabl <- table(Xqual[ind.act])
 if (!is.null(row.w)){
   for (j in 1:nlevels(Xqual)) tabl[j] <- sum((Xqual[ind.act]==levels(Xqual)[j])*row.w,na.rm=TRUE)
 }
 selecti <- (tabl/sum(tabl))<level.ventil
 if (!any(selecti)) return(Xqual) else {
  numero <- which(selecti)
  while(any((tabl/sum(tabl))<level.ventil)) {
   j <- which(((tabl/sum(tabl))<level.ventil))[1]
   K <- length(mod)
   if (j<K) {
    if ((j>1)&(j<K-1)) levels(Xqual) <- c(mod[1:(j-1)],paste(mod[j],mod[j+1],sep="."),paste(mod[j],mod[j+1],sep="."),mod[j+2:K])
    if (j==1) levels(Xqual) <- c(paste(mod[j],mod[j+1],sep="."),paste(mod[j],mod[j+1],sep="."),mod[j+2:K])
    if (j==(K-1)) levels(Xqual) <- c(mod[1:(j-1)],paste(mod[j],mod[j+1],sep="."),paste(mod[j],mod[j+1],sep="."))
   } else {
      levels(Xqual) <- c(mod[1:(j-2)],paste(mod[j-1],mod[j],sep="."),paste(mod[j-1],mod[j],sep="."))
   }
  }
 }
# if (nlevels(Xqual)>1) return(Xqual)
# else return(NULL)
 return(Xqual)
}

  # fct.eta2 <- function(vec,x,weights) {
     # res <- summary(lm(x~vec,weights=weights))$r.squared
  # }
  

fct.eta2 <- function(vec,x,weights) {   ## pb avec les poids
  VB <- function(xx) {
	return(sum((colSums((tt*xx)*weights)^2)/ni))
  }
  tt <- tab.disjonctif(vec)
  ni <- colSums(tt*weights)
  unlist(lapply(as.data.frame(x),VB))/colSums(x^2*weights)
}


#############
## Main program    
#############

  if (is.null(rownames(X))) rownames(X) <- 1:nrow(X)
  if (is.null(colnames(X))) colnames(X) <- colnames(X, do.NULL = FALSE,prefix="V")
  X <- as.data.frame(X)
  X <- droplevels(X)
  ind.act <- (1:nrow(X))[!(1:nrow(X))%in%ind.sup]

  if (!is.null(which(lapply(X,class)=="logical"))){
    for (k in which(lapply(X,class)=="logical")) X[,k] <- as.factor(X[,k])
  }

    if (level.ventil > 0) X <- ventil.tab(X,level.ventil=level.ventil,row.w=row.w,ind.sup=ind.sup,quali.sup=quali.sup,quanti.sup=quanti.sup)

  niveau <- NULL
  for (j in 1:ncol(X)) niveau = c(niveau, levels(X[, j]))
  for (j in 1:ncol(X)) {
      if (sum(niveau %in% levels(X[, j])) != nlevels(X[, j])) levels(X[, j]) = paste(attributes(X)$names[j], levels(X[, j]), sep = "_")
  }

nonact <- c(quanti.sup,quali.sup)
if (!is.null(nonact)) act <- (1:ncol(X))[-nonact]
else act <- (1:ncol(X))
Z <- tab.disjonctif(X[, act,drop=FALSE])
if (any(is.na(X[,act]))){
 if (is.null(tab.disj)){
  if (na.method=="Average") {
    tab.disj <- tab.disjonctif.prop(X[ind.act, act],row.w=row.w)
    Z[ind.act,] <- tab.disj
  }
  if (na.method=="NA"){
    warnings('Missing values for one variable are considered as a new category; you can use method="Average" or use the imputeMCA function of the missMDA package')
    for (j in act) X[,j] <- as.factor(replace(as.character(X[,j]),is.na(X[,j]),paste(attributes(X)$names[j],".NA",sep="")))
    Z <- tab.disjonctif(X[, act])
  }
 } else Z[ind.act,] <- tab.disj
}
Ztot <- Z

col.sup <- NULL
if (!is.null(quali.sup)){
     if (any(is.na(X[,quali.sup,drop=FALSE]))){
       for (j in quali.sup) X[,j] <- as.factor(replace(as.character(X[,j]),is.na(X[,j]),paste(attributes(X)$names[j],".NA",sep="")))
     }
     X[,quali.sup] <- ventil.tab(X[,quali.sup,drop=FALSE],level.ventil=level.ventil,row.w=row.w,ind.sup=ind.sup)
     Zqs <- tab.disjonctif(X[, quali.sup])
     Ztot <- cbind.data.frame(Z, Zqs)
     col.sup <- (ncol(Z) + 1):ncol(Ztot)
}
Xact <- X[,act]

if (!is.null(quanti.sup)){
     if (any(is.na(X[,quanti.sup,drop=FALSE]))){
       for (j in quanti.sup) X[,j] <- replace(X[,j],is.na(X[,j]), mean(X[,j], na.rm=TRUE))
     }
     X.quanti.sup <- as.matrix(X[, quanti.sup])
     if (!is.null(ind.sup)) X.quanti.sup <- X.quanti.sup[ind.act, ,drop=FALSE]
     colnames(X.quanti.sup) = attributes(X)$names[quanti.sup]
}

    if (is.null(row.w)) row.w = rep(1, nrow(X) - length(ind.sup))
    if (length(row.w) != nrow(X) - length(ind.sup)) stop("length of vector row.w should be the number of active rows")
    if (tolower(method)=="burt") {  ## boucle utile pour calculer la distance au cdg et pour calculer les cos2
      res.mca <- CA(Ztot, ncp = ncol(Z)-length(act), row.sup = ind.sup, col.sup = col.sup, graph = FALSE, row.w = row.w) 
      res.mca$col$coord <- t(t(res.mca$col$coord)*sqrt(res.mca$eig[1:ncol(res.mca$col$coord),1]))
      auxil <- rowSums(res.mca$col$coord^2)
      if (!is.null(col.sup)){ 
	    res.mca$col.sup$coord <- t(t(res.mca$col.sup$coord)*sqrt(res.mca$eig[1:ncol(res.mca$col.sup$coord),1]))
        auxil2 <- rowSums(res.mca$col.sup$coord^2)
	  }
    }
#    res.mca <- CA(Ztot, ncp = ncol(Z)-length(act), row.sup = ind.sup, col.sup = col.sup, graph = FALSE, row.w = row.w)
    res.mca <- CA(Ztot, ncp = min(ncp,ncol(Z)-length(act)), row.sup = ind.sup, col.sup = col.sup, graph = FALSE, row.w = row.w)
    if (is.null(ncol(res.mca$row$coord))) res.mca$row$coord = matrix(res.mca$row$coord,ncol=1) 
    ncp <- ncol(res.mca$row$coord)
    res.mca$call$X <- X
    res.mca$call$ind.sup = ind.sup
    res.mca$call$quali = (1:ncol(X))
    if (!is.null(quali.sup) | !is.null(quanti.sup)) res.mca$call$quali <- res.mca$call$quali[-c(quali.sup, quanti.sup)]
    res.mca$call$quali.sup = quali.sup
    res.mca$call$quanti.sup = quanti.sup
    res.mca$call$row.w = row.w
	res.mca$call$call <- match.call()
#	res.mca$call$call <- sys.calls()[[1]]
    if (length(act)>1) res.mca$eig <- res.mca$eig[1:min(length(ind.act)-1,sum(sapply(Xact,nlevels))-length(act)),]
    else res.mca$eig <- res.mca$eig[1:(nlevels(Xact)-1),]
    names(res.mca)[3] <- "ind"
    res.mca$ind <- res.mca$ind[1:3]
    names(res.mca$ind) <- c("coord", "contrib", "cos2")
    names(res.mca)[4] <- "var"
    if (tolower(method)=="burt"){
      res.mca$var$coord <- t(t(res.mca$var$coord)*sqrt(res.mca$eig[1:ncol(res.mca$var$coord),1]))
      res.mca$var$cos2 <- res.mca$var$coord^2/auxil
    }
    res.mca$var <- res.mca$var[1:3]
    names(res.mca$var) <- c("coord", "contrib", "cos2")
    indice <- 6
    if (!is.null(ind.sup)) {
        names(res.mca)[indice] <- "ind.sup"
        names(res.mca$ind.sup) <- c("coord", "cos2")
        indice <- indice + 1
        Xact = X[ind.act,act ,drop=FALSE]
    }
    if (!is.null(quali.sup)) {
        names(res.mca)[indice] <- "quali.sup"
        names(res.mca$quali.sup) <- c("coord", "cos2")
        if (tolower(method)=="burt"){
          res.mca$quali.sup$coord <- t(t(res.mca$quali.sup$coord)*sqrt(res.mca$eig[1:ncol(res.mca$quali.sup$coord),1]))
          res.mca$quali.sup$cos2 <- res.mca$quali.sup$coord^2/auxil2
        }
    }

    if (!is.null(ind.sup)) Z = Z[ind.act, ]
    Nj <- colSums(Z * row.w)
    N <- sum(Nj)/(ncol(X) - length(quali.sup) - length(quanti.sup))
    if (N>1) coef <- sqrt(Nj * ((N - 1)/(N - Nj)))
	else coef <- sqrt(Nj)
    res.mca$var$v.test <- as.matrix(res.mca$var$coord*coef)

	# if (ncp>1) eta2 <- t(sapply(Xact,fct.eta2,res.mca$ind$coord,weights=row.w))
	# else {
	  # eta2 <- as.matrix(sapply(Xact,fct.eta2,res.mca$ind$coord,weights=row.w),ncol=ncp)
      # colnames(eta2) = paste("Dim", 1:ncp)
      # rownames(eta2) = colnames(Xact)
	# }

    variable <- rep(attributes(Xact)$names,unlist(lapply(Xact,nlevels)))
    if (length(act)>1){
      CTR <- aggregate(res.mca$var$contrib/100,by=list(factor(variable)),FUN=sum)
      rownames(CTR) <- CTR[,1]
      CTR <- t(t(CTR[,-1,drop=FALSE])*res.mca$eig[1:ncp,1])*ncol(Xact)
      eta2 <- CTR[attributes(Xact)$names,,drop=FALSE]
      res.mca$var$eta2 <- eta2
    }
	
    if (!is.null(quali.sup)) {
        if (!is.null(ind.sup)) Zqs = Zqs[ind.act, ]
        Nj <- colSums(Zqs * row.w)
        if (N>1) coef <- sqrt(Nj * ((N - 1)/(N - Nj)))
		else coef <- sqrt(Nj)
        res.mca$quali.sup$v.test <- as.matrix(res.mca$quali.sup$coord*coef)

        eta2 = matrix(NA, length(quali.sup), ncp)
        colnames(eta2) = paste("Dim", 1:ncp)
        rownames(eta2) = attributes(X)$names[quali.sup]
#        for (i in 1:ncp)  eta2[, i] <- unlist(lapply(as.data.frame(X[rownames(Xact), quali.sup]),fct.eta2,res.mca$ind$coord[,i],weights=row.w))
		 if (ncp>1) eta2 <- t(sapply(as.data.frame(X[rownames(Xact), quali.sup,drop=FALSE]),fct.eta2,res.mca$ind$coord,weights=row.w))
		 else {
		   eta2 <- as.matrix(sapply(as.data.frame(X[rownames(Xact), quali.sup,drop=FALSE]),fct.eta2,res.mca$ind$coord,weights=row.w),ncol=ncp)
		 }
		
        res.mca$quali.sup$eta2 <- eta2
    }

    if (!is.null(quanti.sup)) {
        U <- res.mca$svd$U
        coord.quanti.sup <- matrix(NA, ncol(X.quanti.sup), ncp)
        coord.quanti.sup <- cov.wt(cbind.data.frame(U,X.quanti.sup),cor=TRUE,wt=row.w,method="ML")$cor[-(1:ncol(U)),1:ncol(U),drop=FALSE]
#		coord.quanti.sup <- cor(X.quanti.sup,U,method="pearson")
        dimnames(coord.quanti.sup) <- list(colnames(X.quanti.sup), paste("Dim", 1:ncp))
        res.mca$quanti.sup$coord <- coord.quanti.sup
    }

    if (tolower(method)=="burt"){
      res.mca$eig[,1] <- res.mca$eig[,1]^2
      res.mca$eig[,2] <- res.mca$eig[,1]/sum(res.mca$eig[,1]) * 100
      res.mca$eig[,3] <- cumsum(res.mca$eig[,2])      
    }

    class(res.mca) <- c("MCA", "list")
    if (graph & (ncp>1)) {
        plot.MCA(res.mca, choix = "ind", invisible="ind", axes = axes,new.plot=TRUE)
        if (method=="Indicator") plot.MCA(res.mca, choix = "ind", invisible=c("var","quali.sup","quanti.sup"), axes = axes,new.plot=TRUE,cex=0.8)
		plot.MCA(res.mca, choix = "var", axes = axes,new.plot=TRUE)
        if (!is.null(quanti.sup)) plot.MCA(res.mca, choix = "quanti.sup", axes = axes,new.plot=TRUE)
    }
    return(res.mca)
}
