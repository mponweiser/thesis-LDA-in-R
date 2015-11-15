## produce and save 1. tm corpus from abstracts and 2. dataframe from
## matching metadata

setwd("/media/NTFS500GB_A/pnas-scrapy/pnas/")

abstracts_meta <- read.table("meta.csv", header = T, sep=",",
        quote="\"", encoding = "UTF-8", stringsAsFactors = F)

require("tm")

abstracts_reader <- FunctionGenerator(function(...) 
    function(elem, language, id) {
        PlainTextDocument(x = elem$content,
                datetimestamp = as.POSIXlt(Sys.time(), tz = "GMT"),
                # heading = elem$content[[1]], 
                id = id,
                origin = elem$uri,
                language = language)
    })

abstracts_source <- DirSource(".",
    pattern = "\\.abstract\\.txt", recursive = TRUE)

abstracts_corpus <- Corpus(abstracts_source, readerControl = list(
    reader = abstracts_reader, language = "en_US"))

## reformat paths
abstracts_meta$abstract_local_path <- paste("./",
        abstracts_meta$abstract_local_path, sep="")

## we have complete and unique metadata, now find abstracts in corpus
abstracts_origin_chr <- sapply(abstracts_corpus, Origin)
corpus_index_reordered <- match(abstracts_meta$abstract_local_path,
        abstracts_origin_chr)
## select abstracts by available metadata
abstracts_corpus <- abstracts_corpus[corpus_index_reordered]

## select metadata to match the corpus
abstracts_origin_chr <- sapply(abstracts_corpus, Origin)
meta_index_reordered <- match(abstracts_origin_chr,
        abstracts_meta$abstract_local_path)
abstracts_meta <- abstracts_meta[meta_index_reordered,]

## Fill in "local" corpus metadata, will be needed for merging
## headings with abstracts
## This takes a couple of hours !

system.time(
    for (i in seq_along(abstracts_corpus))
        meta(abstracts_corpus[[i]], type = "local", tag = "Heading") <-
        abstracts_meta$title[[i]])

# alternatively: this is 20% slower
# system.time(meta(abstracts_corpus, type = "local", tag = "Heading") <-
#    abstracts_meta$title)

## delete columns: title, url_extract, url_abstract_is_duplicate,
## download_*, warning
abstracts_meta <- abstracts_meta[,-c(4,10,13,14,15,25)]

## attach metadata to the corpus as DMetaData, "indexed"
## -- not recommended, because DTM has no links to metadata
## and loading the complete corpus would be unnecessary
# for (name in names(meta_df))
# meta(abstracts_corpus, tag = name) <- meta_df[name]
## also possible:
# DMetaData(abstracts)$title <- meta_df$title
# meta(abstracts)$title[1]

save(abstracts_corpus, file = "pnas-abstracts-tm-corpus.RData", compress = TRUE)
save(abstracts_meta, file = "pnas-abstracts-meta-dataframe.RData", compress = TRUE)
