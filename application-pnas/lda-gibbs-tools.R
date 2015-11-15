library("topicmodels")

ldaGibbsSamples <- function(dtm, k, burniniter, sampleinterval, nsamples, control=NULL, model=NULL, ...) {
    	# x:DTM, k:numberoftopics, 
    	# wrapper function for: LDA(dtm, numberoftopic, method="Gibbs", control=list(...), model=LDAObject, ...)
    	# possible control values for LDA/Gibbs: delta=numeric, iter=integer, alpha=numeric
    	# control is later parsed by .list2object or .list2VEMcontrol. Even if present in control, the iteration number will be overwritten by the separately specified arguments.
    	# requires library("topicmodels") by Bettina Grün
    	# Value: returns a list of objects of class "LDA"
    	# Considerations: lda.samples[[1]]@call yields just the interal variable names, is therefore useless.

	# check control and remove iter parameter, if present
    	if (!is.null(control)) {
		stopifnot(is.list(control))    
        	control <- control[control != "iter"]
	} 

    	chain <- list(LDA(dtm, k, method = "Gibbs", c(control, list(iter = burniniter), model, ...)))

    	for (jj in 1:nsamples) { 
		lastSampleIndex <- jj-1
		if(jj == 1) lastSampleIndex <- 1

        	chain[[jj]] <- LDA(dtm, k, method="Gibbs", c(control,
			list(iter = sampleinterval)), model = chain[[lastSampleIndex]], ...)
	}
    	return(chain)
}

logPwzT <- function(model) { 
	# takes one sample of a fitted model and calculates p(w|z,T) in logarithmic form
	# we have to do this in logarithms because gamma(W) etc. would generate range errors
	# This is equation (2) in Griffiths2004

	BETA <- model@delta
	M <- model@Dim[1] # number of documents
	V <- model@Dim[2] # number of unique terms...W, or V
	K <- model@k # number of topics (T)

	nwsum <- rowSums(model@nw)
	lPwz1 <- K * (lgamma(V * BETA)-V * lgamma(BETA))

	# second factor
	lPwz2 <- 0
	for(j in 1:K) {
		subsum <- 0
		for(w in 1:V) subsum <- subsum + lgamma(model@nw[j,w] + BETA)
		lPwz2 <- lPwz2 + (subsum - lgamma(nwsum[j] + V*BETA))
	}

	# or nicer by BG, will test this out
	# subsum <- apply(model@nw, 1, function(z) sum(sapply(z, function(x) lgamma(x + BETA))))
	# Pwz2 <- sum(subsum - lgamma(colSums(model@nw) + V * BETA))

	lPwz <- lPwz1 + lPwz2
}

harmonicMeanPwT <- function(chain, precision=2000L) {
	# takes a chain of model samples and returns p(w|T) by harmonic mean
	# precision...number of bits used by Rmpfr

	# TODO insert check of chain type?
	
	library("Rmpfr")

	logLikelihoods <- sapply(chain, logPwzT)

	# harmonic mean is the reciprocal of the arithmetic mean of the reciprocals.
	# 1/mean(1/a)

	# Trick from bayesm to shift the values into a range of nicer numbers: (found by BG)
	#logMargDenNR <- function (ll) {
	#med = median(ll)
	#return(med - log(mean(exp(-ll + med))))
	#}

	llMed <- median(logLikelihoods)
	as.double(llMed - log(mean(exp(-mpfr(logLikelihoods, prec = precision) + llMed))))

	#is theoretically equal to: 1/mean(exp(-mpfr(logLikelihoods,prec=precision)))
}

testLda <- function() { 
	data("AssociatedPress", package="topicmodels")
	LDA(AssociatedPress[1:20], method="Gibbs", k=2, burniniter=0, sampleinterval=10, nsamples=2, control=list(alpha=0.1))
}

testLdaGibbsSamples <- function() { 
	data("AssociatedPress", package="topicmodels")
	ldaGibbsSamples(AssociatedPress[1:20], k=2, burniniter=10, sampleinterval=10, nsamples=10, control=list(alpha=0.1))
}
