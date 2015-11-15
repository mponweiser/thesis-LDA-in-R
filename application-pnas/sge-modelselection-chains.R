#$ -N pnas-modelselection-chain
#$ -t 1:62

# email on end and abort
#$ -M m.ponweiser@gmail.com
#$ -m ea
R-g --vanilla <<-EOF
library("topicmodels")

load("pnasDtm.Rda")
source("lda-gibbs-tools.R")

chains <- c(8, 8, 8, 8, 8, 8, 8, 6)
parameters <- list(
    chains = chains,
    seeds = 1:sum(chains),
    topics = rep(c(50, 100, 200, 300, 400, 500, 600, 1000),chains),
    topicsChainId = unlist(sapply(chains, function(x) seq(1,x))),
    samples = rep(c(10, 10, 10, 10, 10, 10, 10, 2), chains),
    burnIn = rep(c(1100, 1100, 1100, 1100, 1100, 1100, 1100, 800), chains),
    sampleInterval = rep(c(100, 100, 100, 100, 100, 100, 100, 100), chains))

jobid <- as.integer(Sys.getenv("SGE_TASK_ID"))

chain <- ldaGibbsSamples(
    pnasDtm,
    k = parameters\$topics[jobid], 
    burniniter = parameters\$burnIn[jobid], 
    sampleinterval = parameters\$sampleInterval[jobid], 
    nsamples = parameters\$samples[jobid],
    control = list(alpha = 50 / parameters\$topics[jobid],
                    seed = parameters\$seeds[jobid] )
    )

# concatenate filename, save file:
FILE <- paste("modelselection-chain-", jobid, "-", parameters\$topics[jobid],
    ".Rda", sep = "")
save(chain, file = FILE)

save(parameters, file = "modelselection-parameters.Rda")

EOF
