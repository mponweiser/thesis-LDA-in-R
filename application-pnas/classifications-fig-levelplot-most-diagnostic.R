# we reorder both axes by major category
order_by_major_index <- 1:33
names(order_by_major_index) <- rownames(theta_diagnostic)
order_by_major_index <- order_by_major_index[category_levels$pretty]
theta_diagnostic_ordered_by_major <-
    theta_diagnostic[order_by_major_index,order_by_major_index]

# transpose the matrix and reverse rows for orientation like in GS04
theta_diagnostic_plot <-
    t(theta_diagnostic_ordered_by_major[nrow(theta_diagnostic_ordered_by_major):1,])

# problem: there is a bias for theta, meaning no values are actually zero
# drawing must therefore make sure to assign lower values the color "white".
# solution: cuts = 12
colors_plot <- rev(category_levels$color)

print(levelplot(theta_diagnostic_plot, 
	xlab = NULL, 
	ylab = NULL, 
	scales = list(
		tck = 1,
		x = list(rot = 45),
		y = list(col = colors_plot)),
	cuts = 12, 
	col.regions = gray(20:0/20), 
	colorkey = list(
		space = "right",
		tick.number = 10),
	par.settings = theme.nopadding,
	panel = function(...) {
		panel.levelplot(...);
		# the grid:
		panel.abline(h = seq(1.5, 32.5), col = "lightgray");
		panel.abline(v = seq(1.5, 32.5), col = "lightgray");
		panel.abline(h = c(4.5, 14.5));
		panel.abline(v = c(33-3.5, 33-13.5));
		}
	))
