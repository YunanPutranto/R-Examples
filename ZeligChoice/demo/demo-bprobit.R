library(VGAM)

# Zelig 4 code:
library(Zelig)
library(ZeligChoice)
data(sanction)
z.out1 <- zelig(cbind(import, export) ~ coop + cost + target,
                model = "bprobit", data = sanction)
summary(z.out1)
x.low <- setx(z.out1, cost = 1)
set.seed(42)
s.out1 <- sim(z.out1, x = x.low)
summary(s.out1)

# Zelig 5 code:
data(sanction)
z5 <- zbprobit$new()
z5$zelig(cbind(import, export) ~ coop + cost + target, data = sanction)
z5
z5$setx(cost = 1)
set.seed(42)
z5$sim(num = 1000)
z5$summarize()
z5$cite()

# z5$zelig(list(import ~ coop + cost + target, export ~ coop + cost + target), data = sanction)
