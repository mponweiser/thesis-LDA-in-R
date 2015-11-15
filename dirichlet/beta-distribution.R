curve( dbeta(x,0.5,0.5), ylab="Density", xlim=c(0,1), ylim=c(0,5) )
curve( dbeta(x,1,1), add=TRUE, col='red' )
curve( dbeta(x,3,1), add=TRUE, col='green' )
curve( dbeta(x,1,5), add=TRUE, col='blue' )
curve( dbeta(x,2,2), add=TRUE, lty=2, lwd=1, col=par('fg') )
legend(par('usr')[2]/2, par('usr')[4], xjust=0.5,
        c('a=b=0.5', 'a=b=1', 'a=3, b=1', 'a=1, b=5', 'a=b=2' ),
        lty=c(1,1,1,1,2),
        col=c(par('fg'), 'red', 'green', 'blue', par('fg')))
