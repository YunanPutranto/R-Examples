library(urca)
data(UKpppuip)
names(UKpppuip)
attach(UKpppuip)
dat1 <- cbind(p1, p2, e12, i1, i2)
dat2 <- cbind(doilp0, doilp1)
args('ca.jo')
H1 <- ca.jo(dat1, type = 'trace', K = 2, season = 4,
            dumvar = dat2)
H1.trace <- summary(ca.jo(dat1, type = 'trace', K = 2,
                          season = 4, dumvar = dat2))
H1.eigen <- summary(ca.jo(dat1, type = 'eigen', K = 2,
                          season = 4, dumvar = dat2))
