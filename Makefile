# This is a generic Makefile that can be used to compile somewhat complicated
# LaTeX documents. It assumes a directory structure like this
#        .
#        ├── figures/*.{pdf,tex}
#        ├── MAIN.tex
#        ├── Makefile
#        ├── Preamble.tex
#        ├── sections/*.tex
#        └── latex.out/
# and that you want to use a LaTeX runner such as latexrun or latexmk. The
# Makefile's configured for latexrun but it should be easy to switch to
# something else by customising the variables $(LATEXRUN) and $(LATEXRUN_OPTS).
#
# The watch task uses [watchman](https://github.com/facebook/watchman) to watch
# all the files defined in the variables $(MAIN), $(BIB_FILE), $(FIGURES),
# $(PREAMBLE), $(SECTIONS) and $(OTHER_FILES) running the all task if any of
# them changes. To use the watch task, you must install watchman AND pywatchman
# (which provides the watchman-make command).

# Main TeX file WITHOUT extension
MAIN = vita
PREAMBLE = preamble.tex
# No references? Just assign this to nothing.
BIB_FILE =

TMP_DIR = latex.out
FIGURE_DIR = figures
SECTIONS_DIR = sections

FIGURES = $(wildcard $(FIGURE_DIR)/*.tex $(FIGURE_DIR)/*.pdf)
SECTIONS = $(shell find $(SECTIONS_DIR) -type f -name '*.tex')

# Define any other files (e.g., BibLaTeX configuration files) here.
OTHER_FILES =

LATEX = lualatex
LATEX_OPTS = --interaction=nonstopmode --shell-escape
LATEXRUN = latexrun
LATEXRUN_OPTS = --latex-cmd=$(LATEX) --latex-args="$(LATEX_OPTS)" --bibtex-cmd=biber -O=$(TMP_DIR)

.PHONY: FORCE
$(MAIN).pdf: FORCE $(MAIN).tex $(FIGURES) $(SECTIONS) $(BIB_FILE) $(OTHER_FILES)
	$(LATEXRUN) $(LATEXRUN_OPTS) $(MAIN).tex

.PHONY: clean
clean:
	$(LATEXRUN) --clean-all

.PHONY: all
all: $(MAIN).pdf

.PHONY: watch
watch: $(MAIN).pdf
	watchman-make -p $(MAIN).tex $(PREAMBLE) $(FIGURES) $(SECTIONS) $(BIB_FILE) $(OTHER_FILES) -t all

.PHONY: view
view: $(MAIN).pdf
	@open -a "PDF Expert" $(MAIN).pdf
