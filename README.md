# Predictive-Analytics-Eksamen-2026

Repository for the Predictive Analytics exam 2026. It contains two separate workstreams:

## Structure

```
.
├── latex/          # LaTeX source for the exam report
│   └── main.tex    # Main LaTeX document
└── R/              # R scripts for data analysis
    └── analysis.R  # Main analysis script
```

## LaTeX

The `latex/` folder holds all LaTeX source files.  
Compile the report with:

```bash
cd latex
pdflatex main.tex
bibtex main        # if bibliography is used
pdflatex main.tex
pdflatex main.tex
```

The generated PDF and other build artifacts are excluded from version control via `.gitignore`.

## R

The `R/` folder holds all R scripts.  
Open the project in RStudio or run a script directly:

```r
source("R/analysis.R")
```

Required packages can be installed with:

```r
install.packages(c("tidyverse", "caret", "ggplot2"))
```
