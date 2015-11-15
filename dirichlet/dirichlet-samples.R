## http://stackoverflow.com/questions/3712402/r-how-to-change-lattice-levelplot-color-theme
lattice.options(default.theme = standard.theme(color = FALSE))
rd<-vector()
alpha = c(.01, .1, 1, 10, 100)
for (alp in alpha) rd <- c(rd, as.vector(t(rdirichlet(5,rep(alp,5)))))
rddf <- expand.grid(k=as.character(1:5), smpl=paste("Sample",
                1:5), alp=paste("alpha =",alpha))
rddf$value <- rd
print(xyplot(value~ k | smpl*alp, data=rddf, type=c("p","h") , between=list(y=1), xlab="Event", ylab="Probability"))
#print(dotplot(k~ value | alp*smpl, data=rddf, type=c("p","h") , between=list(x=1), xlab="Probability", ylab="Event"))
