#$ -N pnas-modelselection-logl

# email on end and abort
#$ -M m.ponweiser@gmail.com
#$ -m ea
R-g --vanilla <<-EOF
library("topicmodels")

source("lda-gibbs-tools.R")

load("modelselection-parameters.Rda")

result <- data.frame(
	topics = parameters\$topics,
	ChainId = parameters\$topicsChainId,
	logLikelihood = as.numeric(NA))

for(jj in 1:sum(parameters\$chains)) {
	FILE <- paste("modelselection-chain-", jj, "-", parameters\$topics[[jj]],
			".Rda", sep = "")
	print(FILE)
	load(FILE)
	result\$logLikelihood[jj] <- harmonicMeanPwT(chain, precision=2000)
}

save(result, file = "modelselection-result.Rda")

EOF
