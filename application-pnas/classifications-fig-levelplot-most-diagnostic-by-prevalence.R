categories_prevalence <- table(categories_2001$pretty)

# make a copy our main theta matrix with added counts in rownames
theta_diagnostic_with_prevalence <- theta_diagnostic
rownames(theta_diagnostic_with_prevalence) <- paste(
    rownames(theta_diagnostic),
    categories_prevalence, sep=": ")

# prepare index to reorder theta matrix
categories_ordered_by_prevalence <-
    names(sort(categories_prevalence, decreasing=TRUE))

theta_index <- 1:33
names(theta_index) <- rownames(theta_diagnostic)
theta_index <- theta_index[categories_ordered_by_prevalence]

# reorder theta matrix
theta_diagnostic_ordered_by_prevalence  <-
    theta_diagnostic_with_prevalence[rev(theta_index),theta_index]

# plotting
colors_plot <- rev(category_levels[names(theta_index),]$color)

theta_plot <- t(theta_diagnostic_ordered_by_prevalence)

print(levelplot(theta_plot, 
	xlab = NULL, 
	ylab = NULL, 
	scales = list(
		tck = 1,
		x = list(rot = 45),
		y = list(col = colors_plot)),
	cuts = 12, 
	col.regions = gray(20:0/20), 
	colorkey = list(space = "right"),
	par.settings = theme.nopadding,
	panel = function(...) {
		panel.levelplot(...);
		# the grid:
		panel.abline(h = seq(1.5, 32.5), col = "lightgray");
		panel.abline(v = seq(1.5, 32.5), col = "lightgray");
		}
	))
