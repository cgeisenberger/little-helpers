These sections contain material relating to R which I found (extremely) useful and keep referring back to.


## Table Of Contents

* [RStudio's Shiny](#r-shiny)
* [R Markdown](#markdown)
* [R Programming](#r-programming)
* [Machine Learning](#machine-learning)
* [Visualization](#visualization)
* [Bioinformatics](#bioinformatics)
    - [General](#general)
    - [Bioconductor](#bioconductor)



## R Shiny

* [First stop: RStudio's Shiny](https://shiny.rstudio.com)
* [Hadley Wickham's Mastering Shiny](https://mastering-shiny.org)
* [Shinyapps.io User Guide](https://docs.rstudio.com/shinyapps.io/index.html)


## Markdown

* [RStudios R Markdown Page](https://rmarkdown.rstudio.com/index.html)
* [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/)


## R Programming

* Source code inspection: [lint(er)](https://en.wikipedia.org/wiki/Lint_(software))
* 
* Coding Style
    - [Tidyverse Style Guide](https://style.tidyverse.org)
    - [Google’s R Style Guide](https://google.github.io/styleguide/Rguide.html)


## Machine learning

* [mlr3](https://mlr3.mlr-org.com)
* [tidymodels](https://www.tidymodels.org) (based on the older [caret](https://topepo.github.io/caret/index.html))


## Visualization 

* [ggplot2](https://ggplot2.tidyverse.org)
* [plotly](https://plotly.com/r/)
* specific topics
    - tables: [gt](https://github.com/rstudio/gt)
    - more complex layouts: [patchwork](https://github.com/thomasp85/patchwork)


## Bioinformatics


### General

* [Blog post on genomics workflow](https://blog.liang2.tw/posts/2015/12/biocondutor-genomic-data/)
* [Talk: Genomics in R](https://blog.liang2.tw/2019Talk-Genomics-in-R/)
* [list of important file formats](https://www.encodeproject.org/help/file-formats/)


### Bioconductor

* BAM files: Rsamtools and GenomicAlignments
* Genomic data: GenomicRanges (& IRanges, GenomicAlignments, GenomicFeatures, VariantAnnotation and rtracklayer)
* SummarizedExperiment
* (Acces to) Data: Bioconductor Repo, GEOquery, ArrayExpress, SRAdb
* Visualization
    - [gviz](https://bioconductor.org/packages/release/bioc/html/Gviz.html)
    - [ggbio]()
    - [biovizBase]()
    - [epivizr]()
    - [karyoploteR](https://bernatgel.github.io/karyoploter_tutorial/)
    - [gggenes](https://cran.r-project.org/web/packages/gggenes/index.html)
* Big Data: rhdf5, h5vc, BiocParallel, GenomicFiles
* Transcript Metadata
    - [GenomicFeatures](https://bioconductor.org/packages/release/bioc/html/GenomicFeatures.html)
    - TxDb objects


## Building packages

* Intro to get up and running: [Hilary Parker's blog](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/)
* Hadley Wickham: [R Packages](http://r-pkgs.had.co.nz)
* [tl;dr version](./packages.md)
* official: [Writing R Extensions](https://cran.r-project.org/doc/manuals/R-exts.html#Creating-R-packages)
