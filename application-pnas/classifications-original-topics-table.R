library(xtable)

terms_topics_unique <- matrix(data = c(
    c("insect","myb","pheromone","lens","larvae"),
    c("species","phylogenetic","evolution","evolutionary","sequences"),
    c("gene","vector","vectors","expression","transfer"),
    c("structure","angstrom","crystal","residues","structures"),
    c("folding","native","protein","state","energy"),
    c("nuclear","nucleus","localization","cytoplasm","export"),
    c("neural","development","dorsal","embryos","ventral"),
    c("species","global","climate","co2","water"),
    c("species","selection","evolution","genetic","populations"),
    c("chromosome","region","chromosomes","kb","map"),
    c("cells","cell","antigen","lymphocytes","cd4"),
    c("tumor","cancer","tumors","human","cells"),
    c("host","bacterial","bacteria","strains","salmonella"),
    c("synaptic","neurons","postsynaptic","hippocampal","synapses"),
    c("resistance","resistant","drug","drugs","sensitive"),
    c("channel","channels","voltage","current","currents"),
    c("plants","plant","arabidopsis","tobacco","leaves"),
    c("cortex","brain","subjects","task","areas"),
    c("theory","time","space","given","problem"),
    c("hair","mechanical","mb","sensory","ear"),
    c("large","scale","density","observed","observations"),
    c("time","spectroscopy","nmr","spectra","transfer"),
    c("force","surface","molecules","solution","surfaces"),
    c("population","populations","genetic","diversity","isolates"),
    c("research","new","information","understanding","paper"),
    c("age","old","aging","life","young")), nrow=5,
    dimnames = list(1:5, paste("Topic",c(217,274,126,63,200,209, 42,2,280,15,64,102,
    112,210,201,165,142,222, 39,105,221,270,55,114, 109,120))))

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
