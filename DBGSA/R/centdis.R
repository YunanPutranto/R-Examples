#���ķ�����룺
centdis<-function(C,num,Meth){
C<-t(C);
A<-as.matrix(C[1:num,]);
B<-as.matrix(C[(1+num):nrow(C),]);
if (Meth=="stat")
{
C<-rbind(A,B);
cr<-nrow(C);
cc<-ncol(C);
for(n in 1:cc){
A[,n]<-A[,n]*(1/sd(C[,n]));
B[,n]<-B[,n]*(1/sd(C[,n]));
}
AA<-apply(A,2,mean);#����A�����ģ���ֵΪAA��
BB<-apply(B,2,mean);#����B�����ģ���ֵΪBB��
C<-rbind(AA,BB)
D<-as.matrix(dist(C,method="euclidean",diag=TRUE,upper=TRUE))
}
else
{AA<-apply(A,2,mean);#����A�����ģ���ֵΪAA��
BB<-apply(B,2,mean);#����B�����ģ���ֵΪBB��
C<-rbind(AA,BB)
D<-as.matrix(dist(C,method=Meth,diag=TRUE,upper=TRUE));}##��������������������ʾ�Խ����ϵ�Ԫ��
return (D[1,2])
}