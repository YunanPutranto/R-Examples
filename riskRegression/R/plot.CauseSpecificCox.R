#' @export 
plot.CauseSpecificCox <- function(x,
                                  cause,
                                  newdata,
                                  xlab,
                                  ylab,
                                  xlim,
                                  ylim,
                                  lwd,
                                  col,
                                  lty,
                                  axes=TRUE,
                                  percent=TRUE                      ,
                                  legend=TRUE,
                                  add=FALSE,
                                  ...){
    if (missing(cause))
        cause <- x$causes[1]
    plot.riskRegression(x,
                        cause=cause,
                        newdata=newdata,
                        xlab=xlab,
                        ylab=ylab,
                        xlim=xlim,
                        ylim=ylim,
                        lwd=lwd,
                        col=col,
                        lty=lty,
                        axes=axes,
                        percent=percent,
                        legend=legend,
                        add=add,
                        ...)
}
