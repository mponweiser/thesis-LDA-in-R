#SUBDIRS = application-pnas web-scraping
# globs taken from kile, also considering todo files and backup/swap
TEMPFILEGLOB = *.aux *.bit *.blg *.bbl *.lof *.log *.lot *.glo *.glx *.gxg *.gxs *.idx *.ilg *.ind *.out *.url *.svn *.toc *.tdo *.tex~ *.tex.backup *.dvi *.swp

# default target "all", dependencies: main.pdf
all: 
	./0-corpus-and-dtm.sh
	./1-modelselection-result.sh
	./2-lda-model-fitting.sh
	./3-classifications.sh
	./4-trends.sh
	./5-tagging.sh
	./6-appendix-table.sh
	R CMD Sweave classifications-original-topics-table.Rnw
	R CMD Sweave trends-original-terms-table.Rnw 

# declare target to be phony, as no file "clean" exists
.PHONY: clean
clean:
	# leading minus considers failed rm successful
	#-rm -f $(TEMPFILEGLOB)
	#-for d in $(SUBDIRS);do cd $$d; rm -f $(TEMPFILEGLOB); cd ..; done
	#rm corpus-and-dtm.tex
	#rm modelselection-result.tex
	rm modelselection-result-002.pdf
	#rm lda-model-fitting.tex
	rm classifications-06.pdf
	rm classifications-13.pdf
	rm classifications-015.pdf
	rm classifications-016.pdf
	#rm classifications.tex
	rm trends-09.pdf
	rm trends-11.pdf
	#rm trends.tex
	rm Rplots.pdf
	#rm tagging.tex
	#rm appendix-model-300-terms-tables.tex
	#rm classifications-original-topics-table.tex
	#rm trends-original-terms-table.tex
