### Creating R packages (tl;dr)


## List of good ressources 

* Intro to get up and running: [Hilary Parker's blog](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/)
* Best one-stop ressource: [Hadley Wickham's R Packages](http://r-pkgs.had.co.nz)
* The official: [Writing R Extensions](https://cran.r-project.org/doc/manuals/R-exts.html#Creating-R-packages)


## The tl;dr version to follow along

* general
  - reference: [Hadley Wickhams book](http://r-pkgs.had.co.nz)
  - install: `devtools`, `roxygen2`, `rmarkdown`, `testthat`
  - initialize: `devtools::create("path/to/package/pkgname")`
  - open `path/to/package/pkgname/pkgname.Rproj` (assumes RStudio is used)
* [Github integration](http://r-pkgs.had.co.nz/git.html)
  - navigate to package folder, run `git init`
  - navigate to [github.com/new](https://github.com/new) and create new repository (use package name)
  - copy git adress (green `clone` button)
  - execute `git remote add origin <repository address>`
  - add `URL` and `BugReports` fields to DESCRIPTION file (example [here](http://r-pkgs.had.co.nz/git.html#github-init))
* [code](http://r-pkgs.had.co.nz/r.html)
  - goes into `R/`
  - functions go into scripts (good names, sensible no. of functions per script)
  - stick to [style guide](https://style.tidyverse.org)
* [data](http://r-pkgs.had.co.nz/data.html)
  - create `/data`
  - create files from R objects via `usethis::use_data()`
  - if starting from raw data
    * create `/data-raw` with `devtools::use_data_raw()`
    * include script for preprocessing (such as `/data-raw/preprocessing.R`)
    * export files (also `usethis::use_data()`)
    * [example](https://github.com/hadley/babynames/blob/master/data-raw/applicants.R)
* [documentation](http://r-pkgs.had.co.nz/man.html)
  - primer (read this first!)
    * initiate with `devtools::document()` (`Shift` + `Cmd` + `D`)
    * document (in this order): functions, package, data
    * syntax (rd.html prob most useful): [roxygen vignettes](https://cran.r-project.org/web/packages/roxygen2/vignettes/)
  - functions
    * add `roxygen`-compatible documentation (see [example](http://r-pkgs.had.co.nz/man.html#man-functions))
    * generate (`devtools::document()`) -> inspect (`?function_name`) -> repeat
  - package
    * create `R/pkgname.R`
    * see ([example](http://r-pkgs.had.co.nz/man.html#man-packages))
  - data
    * create dummy file in `R/` (such as `R/data.R`)
    * see ([example](https://github.com/hadley/babynames/blob/master/R/data.R))
  - R6 classes
    * R6 is [supported](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd.html)
    * methods added via `$set` [currently not](https://github.com/r-lib/roxygen2/issues/931)
* [vignette](http://r-pkgs.had.co.nz/vignettes.html)
  - execute `devtools::use_vignette("my-vignette")`
  - change vignette -> knit (`Cmd` + `Shift` + `K`) -> repeat\
  - if referring to own package when writing, functions/objects have to be exported!
* [testing](http://r-pkgs.had.co.nz/tests.html)
  - set up with `devtools::use_testthat()`
* namespace
  - use `@export` in roxygen tag to export objects and functions
  


## A few more pointers

* use `.Rbuildignore` to differentiate package and other content
* [packages ≠ libraries](http://r-pkgs.had.co.nz/package.html#library)
* RStudio: press `Ctrl + .` to lookup function within current package
* packages must only create objects, not run code!
* don't change landscape: do not use `library()/require()`, `options()` or `source()` or `setwd()`
* separate functions that create output (such as plots)
* use `::` for functions from other packages (unless there is A LOT of them)
* `Imports:` preferred over `Depends:` in most cases
