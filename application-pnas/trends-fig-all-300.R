library(lattice)
print(xyplot(theta_mean_by_year_ts[,names(sort(theta_mean_lm_coef_slope))],
	layout = c(5, 6),
	#screens = c(rep("cold topics", 5), rep("hot topics", 5)),
	screens = rep(1:30, each = 10),
	superpose = TRUE,
	col = "blue",
	alpha = 0.3,
	ylim = c(0, 0.015),
        #ylab = "Mean theta",
        ylab = expression(paste("Mean ",theta)),
	xlab = "Year",
	type = c("l", "g"),
	#aspect = "xy",
	#auto.key = list(space = "right"), 
	auto.key = FALSE,
	scales = list(x = list(alternating = FALSE)),
	#par.settings = standard.theme(color = FALSE)
	))
