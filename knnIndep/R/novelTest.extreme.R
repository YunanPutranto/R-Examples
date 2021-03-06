novelTest.extreme <-
function(xdata,ydata,maxi=length(xdata)-1){
	rx= rank(xdata,ties.method="random")	
	ry= rank(ydata,ties.method="random")	
	N = length(rx)
	
	paths = sapply(1:maxi,generate.paths,rx,ry,N)
	
	pvalues = sapply(1:maxi,function(i){
				if(i == 1){
					ps=P_ceq(i,paths[i,],N)
				}else{
					ps=Pc_givena(i,paths[i,],paths[i-1,],N);
					ind = ps >= .5
					ind2 = (paths[i,] - 1) >= paths[i-1,]
					ind = ind & ind2
					ps[ind] = 1-Pc_givena(i,paths[i,ind]-1,paths[i-1,ind],N)
					ps[ind & !ind2] = .5
				}
				return(ps)})
	
	extremes = 2*pmin(pvalues,1-pvalues)
	aggr = apply(extremes,2,min) 
	return(-2*sum(log(aggr)))
}
