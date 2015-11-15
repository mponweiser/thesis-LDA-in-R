terms_hot <- get_terms(model_lda,12)[,topics_hot[1:5]]
terms_cold <- get_terms(model_lda,12)[,topics_cold[1:5]]

for(i in list(terms_cold, terms_hot)) { 
	xTable <- xtable(i)
	xTableStrings <- unlist(strsplit(capture.output(print(xTable)), "\n"))	
	xTableStrings <- xTableStrings[xTableStrings != "\\begin{table}[ht]"]
	xTableStrings <- xTableStrings[xTableStrings != "\\end{table}"]
	cat(xTableStrings, sep = "\n")
}
