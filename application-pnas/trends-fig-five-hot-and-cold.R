cold_and_hot_ts <- cbind(
    theta_mean_by_year_ts[,topics_cold[1:5]],
    theta_mean_by_year_ts[,topics_hot[1:5]], deparse.level=0)
colnames(cold_and_hot_ts) <- 
    as.character(c(topics_cold[1:5], topics_hot[1:5]))

print(xyplot(cold_and_hot_ts,
	layout = c(2, 1),
        screens = c(rep("Cold topics", 5), rep("Hot topics", 5)),
	superpose = TRUE,
        ylim = c(0, 0.015),
	ylab = expression(paste("Mean ",theta)),
	xlab = "Year",
	type = c("l", "g"),
	auto.key = list(space = "right"), 
	scales = list(x = list(alternating = FALSE))
	#par.settings = standard.theme(color = FALSE)
        ))
