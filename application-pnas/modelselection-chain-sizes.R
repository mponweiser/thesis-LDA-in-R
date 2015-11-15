library("topicmodels")

load("modelselection-parameters.Rda")

sizes <- data.frame(
	objectsize = as.numeric(NA)[1:length(parameters$samples)],
	filesize = as.numeric(NA))

for(jj in 1:sum(parameters$chains)) {
	FILE <- paste("modelselection-chain-", jj, "-", parameters$topics[[jj]], ".Rda", sep = "")
	load(FILE)
	print(FILE)
	sizes$objectsize[jj] <- object.size(chain)
        sizes$filesize[jj] <- file.info(FILE)[["size"]]
}

save(sizes, file = "modelselection-chain-sizes.Rda")
