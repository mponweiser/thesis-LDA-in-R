library(xtable)
topics_prevalent_five <- sort(model_lda@gamma[example_abstract,],index.return=T, decreasing=T)$ix[1:5]
#sort(ldaModel@gamma[abstract,],index.return=T, decreasing=T)
terms_prevalent <- get_terms(model_lda,12)[,topics_prevalent_five]
prevalence <- model_lda@gamma[example_abstract,topics_prevalent_five]
prevalence_table <- rbind(
format(model_lda@gamma[example_abstract,topics_prevalent_five],
        digits=4),
        terms_prevalent <-
        get_terms(model_lda,12)[,topics_prevalent_five]
)
rownames(prevalence_table) <- c("Probability",paste(1:12))

xTable <-  xtable(prevalence_table)
xTableStrings <- unlist(strsplit(capture.output(print(xTable)), "\n"))	
replaceString <- grep("Probability", xTableStrings) 
#replaceString <- grep("  12", xTableStrings) 
xTableStrings[[replaceString]] <- paste(xTableStrings[[replaceString]], "\\hline", sep="\n")
xTableStrings <- xTableStrings[xTableStrings != "\\begin{table}[ht]"]
xTableStrings <- xTableStrings[xTableStrings != "\\end{table}"]
cat(xTableStrings, sep = "\n")
