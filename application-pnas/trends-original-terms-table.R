library("xtable")
terms_cold <- matrix(data=c(
        c("cdna","amino","sequence","acid","protein","isolated","encoding","cloned","acids","identity","clone","expressed"),
        c("kda","protein","purified","molecular","mass","chromatography","polypeptide","gel","sds","band","apparent","labeled"),
        c("antibody","antibodies","monoclonal","antigen","igg","mab","specific","epitope","human","mabs","recognized","sera")),
        ncol = 3, dimnames = list(1:12,paste("Topic",c(37, 289,
                                75))))
terms_hot <- matrix(data=c(
        c("species","global","climate","co2","water","environmental","years","marine","carbon","diversity","ocean","extinction"),
        c("mice","deficient","normal","gene","null","mouse","type","homozygous","role","knockout","development","generated"),
        c("apoptosis","death","cell","induced","bcl","cells","apoptotic","caspase","fas","survival","programmed","mediated")),
        ncol = 3, dimnames = list(1:12,paste("Topic",c(2, 134,
                                179))))
for(i in list(terms_cold,terms_hot)) { 
	xTable <- xtable(i)
	xTableStrings <- unlist(strsplit(capture.output(print(xTable)), "\n"))	
	xTableStrings <- xTableStrings[xTableStrings != "\\begin{table}[ht]"]
	xTableStrings <- xTableStrings[xTableStrings != "\\end{table}"]
	cat(xTableStrings, sep = "\n")
}
