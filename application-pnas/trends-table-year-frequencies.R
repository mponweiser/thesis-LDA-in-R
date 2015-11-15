library(xtable)
frequencies <- t(table(abstracts_meta$year))
rownames(frequencies) <- "Frequency"
xTable <- xtable(frequencies)
xTableStrings <- unlist(strsplit(capture.output(print(xTable)), "\n"))	
xTableStrings <- xTableStrings[xTableStrings != "\\begin{table}[ht]"]
xTableStrings <- xTableStrings[xTableStrings != "\\end{table}"]
cat(xTableStrings, sep = "\n")
