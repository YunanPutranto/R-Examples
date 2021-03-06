touchstep.tail<-function(node,curroot,boundrec,child,sibling,infopointer,
low,upp,rho,dendat,dist.type="euclid")
{
# Checks whether "node" touches some of the leafs of the branch whose
# root is "curroot". Goes through the branch starting at "curroot".
# "comprec" is associated with the "node"
# "currec" is the bounding box of "cur"
# "pointrec" is associated with "cur"

d<-length(low[1,])

note<-infopointer[node]   #nodefinder[infopointer[node]]
comprec<-dendat[note,]
r1<-rho[note]

itemnum<-length(child)
pino<-matrix(0,itemnum,1)
potetouch<-1
istouch<-0
pino[1]<-curroot
pinin<-1
while ((pinin>0) && (istouch==0)){
      cur<-pino[pinin]      #take from stack
      pinin<-pinin-1

      # create currec and pointrec
      currec<-boundrec[cur,]
      note<-infopointer[cur]   #nodefinder[infopointer[cur]]
      pointrec<-dendat[note,]
      # find touches  
      r2<-rho[note]       
      potetouch<-touchi.tail(comprec,currec,r1,dist.type=dist.type) 
      istouch<-touchi.tail(comprec,pointrec,r1,r2,dist.type=dist.type)

      # put to the stack
      if (sibling[cur]>0){
            pinin<-pinin+1
            pino[pinin]<-sibling[cur]
      }
      # go to left and put right nodes to the stack
      while ((child[cur]>0) && (istouch==0) && (potetouch==1)){
            cur<-child[cur]

            # create currec and pointrec
            currec<-boundrec[cur,]
            note<-infopointer[cur]   #nodefinder[infopointer[cur]]
            pointrec<-dendat[note,]
            # find touches                        
            r2<-rho[note]
            potetouch<-touchi.tail(comprec,currec,r1,dist.type=dist.type) 
            istouch<-touchi.tail(comprec,pointrec,r1,r2,dist.type=dist.type)
 
            if (sibling[cur]>0){
                 pinin<-pinin+1
                 pino[pinin]<-sibling[cur]
            }
      }
}

return(istouch)
}                                    
