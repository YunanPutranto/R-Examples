tb.dilute <- data.frame(
reaction = c(
  13.25,11.25, 8.50,
  14.25,11.75,10.00,
  15.50,13.75,10.25,
  15.75,13.00,10.75,
  15.25,17.00,11.50,
  17.50,16.00,11.75),
animal = gl(6,3,18),
logdose = gl(3,1,18, labels = c(.5,0,-.5)))
