topics_by_ratio_reordered <- topics_by_ratio[1:5,order_by_major_index]

topics_most_diagnostic_five <-
    unique(as.vector(topics_by_ratio_reordered))

# because most plots' coordinate system starts at the bottom, we have to convert the data:
theta_plot <-
    t(theta_mean_ratios[rev(order_by_major_index),topics_most_diagnostic_five])
rownames(theta_plot) <- paste(topics_most_diagnostic_five)

colors_plot <- rev(category_levels$color)

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
    #par.settings = theme.nopadding,
    panel = function(...) {
        panel.levelplot(...);
        panel.abline(v = seq(1.5, nrow(theta_plot)-0.5), col = "lightgray");
        panel.abline(h = seq(1.5, 32.5), col = "lightgray");
        panel.abline(h = 4.5);
        panel.abline(h = 14.5);
        #panel.abline(v = length(fiveMostDiagnosticTopics)-8.5);
        #panel.abline(v = length(fiveMostDiagnosticTopics)-31.5);
        }
    ))
