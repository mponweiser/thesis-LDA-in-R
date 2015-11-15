library(xtable)
terms_most_diagnostic <- get_terms(model_lda,5)[,topics_most_diagnostic]
terms_topics_unique <-
    terms_most_diagnostic[,unique(colnames(terms_most_diagnostic))]
topics_per_tab <- 6
topics_total <- ncol(terms_topics_unique)
for(i in 1:(topics_total %/% topics_per_tab)) { 
    xtable_raw <- xtable(terms_topics_unique[,(topics_per_tab * (i-1)
                    + 1):(topics_per_tab * i), drop = FALSE])
    xtable_strings <-
        unlist(strsplit(capture.output(print(xtable_raw)), "\n"))	
    xtable_strings <- xtable_strings[xtable_strings != "\\begin{table}[ht]"]
    xtable_strings <- xtable_strings[xtable_strings != "\\end{table}"]
    cat(xtable_strings, sep = "\n")
}
if((topics_total %% topics_per_tab) != 0) {
    xtable_raw <- xtable(terms_topics_unique[,(topics_per_tab*i +
                    1):topics_total, drop = FALSE])
    xtable_strings <-
        unlist(strsplit(capture.output(print(xtable_raw)), "\n"))	
    xtable_strings <- xtable_strings[xtable_strings != "\\begin{table}[ht]"]
    xtable_strings <- xtable_strings[xtable_strings != "\\end{table}"]
    cat(xtable_strings, sep = "\n")
}
