object=my_visuals

build:
	pdflatex $(object).tex

bib:
	pdflatex $(object).tex
	bibtex $(object)
	pdflatex $(object).tex
	pdflatex $(object).tex

clean:
	rm -f	$(object).aux $(object).log $(object).out $(object).bbl $(object).blg

