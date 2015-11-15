# setwd("/media/NTFS500GB_A/pnas-scrapy/pnas/")

meta_df <- read.table("meta.csv", header = T, sep=",",
        quote="\"", encoding = "UTF-8", stringsAsFactors = F)

require("tm")

abstracts_reader <- FunctionGenerator(function(...) 
    function(elem, language, id) {
        PlainTextDocument(x = elem$content,
                datetimestamp = as.POSIXlt(Sys.time(), tz = "GMT"),
                #heading = elem$content[[1]], 
                id = id,
                origin = elem$uri,
                language = language)
    })

abstracts_source <- DirSource(".",
    pattern = "\\.abstract\\.txt", recursive = TRUE)

abstracts <- Corpus(abstracts_source, readerControl = list(
    reader = abstracts_reader, language = "en_US"))

## reformat paths
meta_df$abstract_local_path <- paste("./",
        meta_df$abstract_local_path, sep="")

## we have complete and unique metadata, now find abstracts in corpus
abstracts_origin_chr <- sapply(abstracts, Origin)
corpus_reordered_index <- match(meta_df$abstract_local_path,
        abstracts_origin_chr)
## select abstracts by available metadata
abstracts <- abstracts[corpus_reordered_index]

## select metadata to match the corpus
abstracts_origin_chr <- sapply(abstracts, Origin)
meta_reordered_index <- match(abstracts_origin_chr,
        meta_df$abstract_local_path)
meta_df <- meta_df[meta_reordered_index,]

# now metadata can be merged into corpus
#names(meta_df)
for (name in names(meta_df)[-c(10,13,14,15,25)])
    meta(abstracts, tag = name) <- meta_df[name]

# does not work:
# sapply(names(meta_df), function(x) meta(abstracts, tag=x) <- meta_df[x])

## also:
# DMetaData(abstracts)$title <- meta_df$title

#meta(abstracts)$title[1]

save(abstracts, file = "tm-corpus-pnas-abstracts.rda", compress = TRUE)
