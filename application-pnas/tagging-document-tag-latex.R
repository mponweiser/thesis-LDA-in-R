document_tag_latex <- function(model_lda, corpus_tm, document_index) {
    paste0 <- function( ..., sep="" ) paste( ..., sep = sep )
    return_strings <- "
    \\definecolor{tagging-base}{gray}{0.65}
    \\definecolor{tagging-1}{gray}{0.60}
    \\definecolor{tagging-2}{gray}{0.55}
    \\definecolor{tagging-3}{gray}{0.55}
    \\definecolor{tagging-4}{gray}{0.45}
    \\definecolor{tagging-5}{gray}{0.37}
    \\definecolor{tagging-6}{gray}{0.30}
    \\definecolor{tagging-7}{gray}{0.22}
    \\definecolor{tagging-8}{gray}{0.25}
    \\definecolor{tagging-9}{gray}{0.17}
    \\definecolor{tagging-10}{gray}{0.10}
    "
    # split abstract into tokens by whitespace 
    # (tm does tokenization only after punctuation removal)
    words <- unlist(strsplit(corpus_tm[[document_index]], " "))
    #words <- c("(,(twoparentheses","(test1--test2","te-st-test2","test))")
    # save punctuation separately
    words_punctuation_index <- gregexpr("[[:punct:]]", words)
    words_punctuation_index_leading <- gregexpr("^[[:punct:]]+", words)
    words_punctuation_index_trailing <- gregexpr("[[:punct:]]+$", words)

    # remove punctuation, to lower
    terms <- gsub("[[:punct:]]","", words, perl=T)
    terms <- gsub("[[:digit:]]","", terms, perl=T)
    terms <- tolower(terms)

    # most prevalent topic in abstract?
    topic_prevalent <- which.max(model_lda@gamma[document_index,])
    wordassignments_df <- data.frame(
            topics = model_lda@wordassignments[document_index,]$v,
            terms = model_lda@terms[model_lda@wordassignments[document_index,]$j])

    wordassignments_index <- list()
    model_terms_index_list <- list()
    for(jj in 1:length(words)) { 
            wordassignments_index[[jj]] <- which(wordassignments_df$terms == terms[jj])
            model_terms_index_list[[jj]] <- which(model_lda@terms == terms[jj])
            }
    model_terms_index <- as.numeric(model_terms_index_list)

    phi_log <- model_lda@beta[topic_prevalent,(model_terms_index)]

    word_phi_levels <- cut(phi_log,10,labels= F)
    colors_latex <- paste0("tagging-",1:10, sep="")

    color_base <- "tagging-base"

    # cases:
    # superscripts: word is in wordassignments of ldaModel, can, but need not have contrast
    # contrast: word is a word of phi, can, but need not have superscript, create index in advance

    for(jj in 1:length(words)) { 
        # leading punctuation in base color
        word_split <- unlist(strsplit(words[[jj]] , ""))
        leading <- sum(attr(words_punctuation_index_leading[[jj]],"match.length"))
        if(leading<0) leading <- 0
        trailing <- sum(attr(words_punctuation_index_trailing[[jj]],"match.length"))
        if(trailing<0) trailing <- 0
        if(leading>0) { 
            return_strings <- paste0(return_strings,"\n\\textcolor{", color_base, "}{")
            for(kk in 1:leading) return_strings <- paste0(return_strings, word_split[kk])
            return_strings <- paste0(return_strings,"}")
        }
        return_strings <- paste0(return_strings,"\\textcolor{")
        # determine color for current word
        if(!is.na(word_phi_levels[jj]))
            return_strings <- paste0(return_strings,
                colors_latex[word_phi_levels[[jj]]])
        else return_strings <- paste0(return_strings, color_base)
        return_strings <- paste0(return_strings, "}{")
        for(kk in ((leading+1):(length(word_split)-trailing)))
            return_strings <- paste0(return_strings, word_split[kk])
        return_strings <- paste0(return_strings, "}")
        # topic superscript, if applicable
        if(length(wordassignments_index[[jj]]) != 0) {
            return_strings <- paste0(return_strings,"\\textcolor{")
            if(!is.na(word_phi_levels[jj])) return_strings <- paste0(return_strings, colors_latex[word_phi_levels[[jj]]])
            else return_strings <- paste0(return_strings, color_base)
            return_strings <- paste0(return_strings, "}{")
            return_strings <- paste0(return_strings, "\\textsuperscript{")
            return_strings <- paste0(return_strings,
                    wordassignments_df$topics[[wordassignments_index[[jj]]]])
            if(!is.na(word_phi_levels[jj])) return_strings <- paste0(return_strings, "}")
            return_strings <- paste0(return_strings, "}")
        }
        # trailing punctuation in base color
        if(trailing>0) { 
            return_strings <-
                paste0(return_strings,"\\textcolor{", color_base, "}{")
            for(kk in
                    ((length(word_split)-trailing+1):length(word_split)))
            return_strings <-
                paste0(return_strings, word_split[kk])
            return_strings <- paste0(return_strings, "}")
        }
        return_strings <- paste0(return_strings, " ")
    }
    return(return_strings)
}

cat(document_tag_latex(model_lda, abstracts_corpus,
                example_abstract))
