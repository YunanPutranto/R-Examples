aggreg2<-function(x,ENV)  # x .. data
{
   # aggregate data - calculate counts for patterns
   notnaidx<-!is.na(x[1,])  # which columns are not missing

   compdat<-x[,notnaidx]    # remove NA columns from data
   ncomp<-ncol(x)

   counts<-countpattern2(compdat)

   # calculate CL vector s

   nnaidx<-log2int(notnaidx)
   iout<-vector(length=2^ncomp)
   RET<-.Fortran("calcs",
               ncomp=as.integer(ncomp),
               nnaidx=as.integer(nnaidx),
               iout=as.integer(iout)
         )

   list(counts=counts,notnaidx=notnaidx,s=RET$iout)

}
