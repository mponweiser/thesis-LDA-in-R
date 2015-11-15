library("topicmodels")
library("xtable")

load("model-lda-gibbs-300topics.RData")

topics_total <- model_lda@k
topics_per_line <- 5
lines_per_page <- 3

topics_index <- split(1:topics_total, rep(1:topics_total,
                each=topics_per_line*lines_per_page, len=topics_total))

page_cat <- function(topics, model_lda) {

    terms <- get_terms(model_lda,12)[,min(topics):max(topics)]

    # make output safe for plain pdflatex
    terms <- iconv(terms,from="UTF-8",to="ASCII",sub="")

    cat("\\begin{table}")
    for(i in 1:(length(topics) %/% topics_per_line)) { 
        xtable_raw <- xtable(terms[,(topics_per_line * (i-1)
                        + 1):(topics_per_line * i), drop = FALSE])
        xtable_strings <-
            unlist(strsplit(capture.output(print(xtable_raw)), "\n"))	
        xtable_strings <- xtable_strings[xtable_strings != "\\begin{table}[ht]"]
        xtable_strings <- xtable_strings[xtable_strings != "\\end{table}"]
        cat(xtable_strings, sep = "\n")
    }
    if((length(topics) %% topics_per_line) != 0) {
        xtable_raw <- xtable(terms[,(topics_per_line*i +
                        1):topics_total, drop = FALSE])
        xtable_strings <-
            unlist(strsplit(capture.output(print(xtable_raw)), "\n"))	
        xtable_strings <- xtable_strings[xtable_strings != "\\begin{table}[ht]"]
        xtable_strings <- xtable_strings[xtable_strings != "\\end{table}"]
        cat(xtable_strings, sep = "\n")
    }
    # clearpage because otherwise there are too many open floats
    cat(paste("\\caption{Twelve most probable terms of Topics ",
                    min(topics)," to ",max(topics),".}
    \\end{table}
    \\clearpage",sep=""))
}
lapply(topics_index, page_cat, model_lda)
