library("MCMCpack")
DiriPlotData <- function(gridsize=100, alpha) {
    # needs grid interval of at least 1/100, otherwise there will be nasty outliers on the Z side that corrupt the plot
    gridaxis <- seq(0, 1, length= gridsize)
    dens <- matrix(nr=gridsize,nc=gridsize)
    for(x in 1:gridsize) {
          for (y in 1:gridsize) { 
              dens[x,y] <- NA # not really necessary, is initialized as NA anyway
              # although there is a check in ddirichlet for the gridaxis to be on the simplex, we have to put in a check to avoid plotting of the saltus to the ground plane (which does not look good)
              if ((gridaxis[x] + gridaxis[y]) < 1) dens[x,y] <- ddirichlet(c(gridaxis[x],gridaxis[y],(1-gridaxis[x]-gridaxis[y])) , alpha ) }
          }
    list(gridline=gridaxis, values=dens)
}
   
DiriPersp <- function(alph=c(2,3,2), ...) {
    # oldpar <- par(bg = "white")
    diridata <- DiriPlotData(gridsize=60,alpha=alph)
    persp(diridata$gridline, diridata$gridline, diridata$values, zlim=c(-3,3), theta = 310, expand = 0.5, col = "lightblue", ticktype="detailed", xlab="X", ylab="Y", zlab="density", ...)
    title(main = bquote(list(alpha[1]==.(alph[1]),
                            alpha[2]==.(alph[2]),
                            alpha[3]==.(alph[3]))))
}

par(mfrow=c(3,2))
DiriPersp(c(4,4,2),phi = 50)
DiriPersp(c(2,4,4),phi = 50)
DiriPersp(c(2,4,2),phi = 40)
DiriPersp(c(2,2,2),phi = 40)
DiriPersp(c(1,1,1),phi = 30)
DiriPersp(c(0.5,.5,.5),phi = 30)
