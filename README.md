
<!-- README.md is generated from README.Rmd. Please only edit the .Rmd file! -->
<!-- Title, version and logo: -->

# FFTrees 1.8.1 <img src = "./inst/FFTrees_Logo.jpg" align = "right" alt = "FFTrees" width = "225" />

<!-- Status badges start: -->

[![R-CMD-check](https://github.com/ndphillips/FFTrees/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ndphillips/FFTrees/actions/workflows/R-CMD-check.yaml)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/FFTrees)](https://CRAN.R-project.org/package=FFTrees)
[![Downloads](https://cranlogs.r-pkg.org/badges/FFTrees?color=brightgreen)](https://www.r-pkg.org/pkg/FFTrees)
<!-- Status badges end. -->

<!-- ALL badges start: -->
<!-- [![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/FFTrees)](https://CRAN.R-project.org/package=FFTrees) -->
<!-- [![Build Status](https://travis-ci.org/ndphillips/FFTrees.svg?branch=master)](https://travis-ci.org/ndphillips/FFTrees) -->
<!-- [![R-CMD-check](https://github.com/ndphillips/FFTrees/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ndphillips/FFTrees/actions/workflows/R-CMD-check.yaml) -->
<!-- [![Downloads](https://cranlogs.r-pkg.org/badges/FFTrees?color=brightgreen)](https://www.r-pkg.org/pkg/FFTrees) -->
<!-- ALL badges end. -->
<!-- Pkg goal: -->

The R package **FFTrees** creates, visualizes and evaluates
*fast-and-frugal decision trees* (FFTs) for solving binary
classification tasks following the methods described in Phillips, Neth,
Woike & Gaissmaier (2017,
as [html](https://journal.sjdm.org/17/17217/jdm17217.html) \|
[PDF](https://journal.sjdm.org/17/17217/jdm17217.pdf)).

## What are fast-and-frugal trees (FFTs)?

*Fast-and-frugal trees* (FFTs) are simple and transparent decision
algorithms for solving binary classification problems. The key feature
making FFTs faster and more frugal than other decision trees is that
every node allows for a decision. When predicting new outcomes, the
performance of FFTs competes with more complex algorithms and machine
learning techniques, such as logistic regression (LR), support-vector
machines (SVM), and random forests (RF). Apart from being faster and
requiring less information, FFTs tend to be robust against overfitting,
and easy to interpret, use, and communicate.

<!-- Quote (cited in guide.Rmd):   -->
<!-- In the words of @burton2020:  -->
<!-- "human users could interpret, justify, control, and interact with a fast-and-frugal decision aid..."  -->
<!-- [@burton2020. p.\ 229] -->
<!-- Full quote: -->
<!-- These fast-and-frugal trees (Hafenbrädl et al.,2016; Phillips, Neth, Woike, & Gaissmaier, 2017) are especially relevant to the algorithm aversion discussion not only because they allow the human decision maker to dictate the external measures upon which an augmented decision will be judged, but also because they are transparent. This in turn suggests that human users could interpret, justify, control, and interact with a fast-and-frugal decision aid, which touches on virtually all the drivers of algorithm aversion covered in this review.  -->
<!-- Source: [@burton2020. p.\ 229] -->

## Installation

The latest release of **FFTrees** is available from
[CRAN](https://CRAN.R-project.org/) at
<https://CRAN.R-project.org/package=FFTrees>:

``` r
install.packages("FFTrees")
```

The current development version can be installed from its
[GitHub](https://github.com) repository at
<https://github.com/ndphillips/FFTrees>:

``` r
# install.packages("devtools")
devtools::install_github("ndphillips/FFTrees", build_vignettes = TRUE)
```

## Getting started

As an example, let’s create a FFT predicting heart disease status
(*Healthy* vs. *Diseased*) based on the `heartdisease` dataset included
in **FFTrees**:

``` r
library(FFTrees)  # load package
```

### Using data

The `heartdisease` data provides medical information for 303 patients
that were tested for heart disease. The full data were split into two
subsets: A `heart.train` dataset for fitting decision trees, and
`heart.test` dataset for a testing the resulting trees. Here are the
first rows and columns of both subsets of the `heartdisease` data:

- `heart.train` (the training / fitting dataset) contains the data from
  150 patients:

``` r
head(heart.train)
```

    #> # A tibble: 6 × 14
    #>   diagnosis   age   sex cp    trestbps  chol   fbs restecg thalach exang oldpeak
    #>   <lgl>     <dbl> <dbl> <chr>    <dbl> <dbl> <dbl> <chr>     <dbl> <dbl>   <dbl>
    #> 1 FALSE        44     0 np         108   141     0 normal      175     0     0.6
    #> 2 FALSE        51     0 np         140   308     0 hypert…     142     0     1.5
    #> 3 FALSE        52     1 np         138   223     0 normal      169     0     0  
    #> 4 TRUE         48     1 aa         110   229     0 normal      168     0     1  
    #> 5 FALSE        59     1 aa         140   221     0 normal      164     1     0  
    #> 6 FALSE        58     1 np         105   240     0 hypert…     154     1     0.6
    #> # … with 3 more variables: slope <chr>, ca <dbl>, thal <chr>

- `heart.test` (the testing / prediction dataset) contains data from a
  new set of 153 patients:

``` r
head(heart.test)
```

    #> # A tibble: 6 × 14
    #>   diagnosis   age   sex cp    trestbps  chol   fbs restecg thalach exang oldpeak
    #>   <lgl>     <dbl> <dbl> <chr>    <dbl> <dbl> <dbl> <chr>     <dbl> <dbl>   <dbl>
    #> 1 FALSE        51     0 np         120   295     0 hypert…     157     0     0.6
    #> 2 TRUE         45     1 ta         110   264     0 normal      132     0     1.2
    #> 3 TRUE         53     1 a          123   282     0 normal       95     1     2  
    #> 4 TRUE         45     1 a          142   309     0 hypert…     147     1     0  
    #> 5 FALSE        66     1 a          120   302     0 hypert…     151     0     0.4
    #> 6 TRUE         48     1 a          130   256     1 hypert…     150     1     0  
    #> # … with 3 more variables: slope <chr>, ca <dbl>, thal <chr>

Most of the variables in our data are potential predictors. The (to-be
predicted) criterion variable is `diagnosis` — a logical column
indicating the true state for each patient (`TRUE` or `FALSE`, i.e.,
whether or not the patient suffers from heart disease).

### Creating fast-and-frugal trees (FFTs)

We use the main `FFTrees()` function to create FFTs for the
`heart.train` data and evaluate their predictive performance on the
`heart.test` data:

- Create an `FFTrees` object from the `heartdisease` data:

``` r
# Create an FFTrees object from the heartdisease data: 
heart_fft <- FFTrees(formula = diagnosis ~., 
                     data = heart.train,
                     data.test = heart.test, 
                     decision.labels = c("Healthy", "Disease"))
```

- Printing an `FFTrees` object shows basic information and summary
  statistics (on the best training tree, FFT #1):

``` r
# Print:
heart_fft
```

    #> FFTrees 
    #> - Trees: 7 fast-and-frugal trees predicting diagnosis
    #> - Outcome costs: [hi = 0, mi = 1, fa = 1, cr = 0]
    #> 
    #> FFT #1: Definition
    #> [1] If thal = {rd,fd}, decide Disease.
    #> [2] If cp != {a}, decide Healthy.
    #> [3] If ca > 0, decide Disease, otherwise, decide Healthy.
    #> 
    #> FFT #1: Training Accuracy
    #> Training data: N = 150, Pos (+) = 66 (44%) 
    #> 
    #> |          | True + | True - | Totals:
    #> |----------|--------|--------|
    #> | Decide + | hi  54 | fa  18 |      72
    #> | Decide - | mi  12 | cr  66 |      78
    #> |----------|--------|--------|
    #>   Totals:        66       84   N = 150
    #> 
    #> acc  = 80.0%   ppv  = 75.0%   npv  = 84.6%
    #> bacc = 80.2%   sens = 81.8%   spec = 78.6%
    #> 
    #> FFT #1: Training Speed, Frugality, and Cost
    #> mcu = 1.74,  pci = 0.87,  E(cost) = 0.200

- To evaluate the predictive performance of an FFT, we plot an `FFTrees`
  object (to visualize a tree and its performance) on the `test` data:

``` r
# Plot the best tree applied to the test data: 
plot(heart_fft,
     data = "test",
     main = "Heart Disease")
```

![An FFT predicting heart disease for `test`
data.](man/figures/README-example-heart-plot-1.png)

**Figure 1**: A fast-and-frugal tree (FFT) predicting heart disease for
`test` data and its performance characteristics.

- Additionally, we can compare the predictive performance between
  different machine learning algorithms on a range of metrics:

``` r
# Compare predictive performance across algorithms: 
heart_fft$competition$test
```

    #> # A tibble: 5 × 17
    #>   algorithm     n    hi    fa    mi    cr  sens  spec    far   ppv   npv   acc
    #>   <chr>     <int> <int> <int> <int> <int> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
    #> 1 fftrees     153    64    19     9    61 0.877 0.762 0.238  0.771 0.871 0.817
    #> 2 lr          153    55    13    18    67 0.753 0.838 0.162  0.809 0.788 0.797
    #> 3 cart        153    50    19    23    61 0.685 0.762 0.238  0.725 0.726 0.725
    #> 4 rf          153    59     8    14    72 0.808 0.9   0.1    0.881 0.837 0.856
    #> 5 svm         153    55     7    18    73 0.753 0.912 0.0875 0.887 0.802 0.837
    #> # … with 5 more variables: bacc <dbl>, wacc <dbl>, cost <dbl>, cost_dec <dbl>,
    #> #   cost_cue <dbl>

<!-- FFTs by verbal description: -->

### Building FFTs from verbal descriptions

FFTs are so simple that we even can create them ‘from words’ and then
apply them to data!

For example, let’s create a tree with the following three nodes and
evaluate its performance on the `heart.test` data:

1.  If `sex = 1`, predict *Disease*.
2.  If `age < 45`, predict *Healthy*.
3.  If `thal = {fd, normal}`, predict *Healthy*,  
    otherwise, predict *Disease*.

These conditions can directly be supplied to the `my.tree` argument of
`FFTrees()`:

``` r
# Create custom FFT 'in words' and apply it to test data:

# 1. Create my own FFT (from verbal description):
my_fft <- FFTrees(formula = diagnosis ~., 
                  data = heart.train,
                  data.test = heart.test, 
                  decision.labels = c("Healthy", "Disease"),
                  my.tree = "If sex = 1, predict Disease.
                             If age < 45, predict Healthy.
                             If thal = {fd, normal}, predict Healthy,  
                             Otherwise, predict Disease.")

# 2. Plot and evaluate my custom FFT (for test data):
plot(my_fft,
     data = "test",
     main = "My custom FFT")
```

![An FFT created from a verbal
description.](man/figures/README-example-heart-verbal-1.png)

**Figure 2**: An FFT predicting heart disease created from a verbal
description.

As we can see, this particular tree is somewhat biased: It has nearly
perfect *sensitivity* (i.e., is good at identifying cases of *Disease*)
but suffers from low *specificity* (i.e., performs poorly in identifying
*Healthy* cases). Expressed in terms of its errors, `my_fft` incurs few
misses at the expense of many false alarms. Although the *accuracy* of
our custom tree still exceeds the data’s baseline by a fair amount, the
FFTs in `heart_fft` (from above) strike a better balance.

<!-- A range of options, rather than 1 optimum: -->

Overall, what counts as the “best” tree for a particular problem depends
on many factors (e.g., the goal of fitting vs. predicting data and the
trade-offs between maximizing accuracy vs. incorporating the costs of
cues or errors). To explore this range of options, the **FFTrees**
package enables us to design and evaluate a range of FFTs.

## References

We had a lot of fun creating **FFTrees** and hope you like it too! As a
comprehensive, yet accessible introduction to FFTs, we recommend reading
our article in the journal *Judgment and Decision Making* ([2017,
volume 12, issue 4](https://journal.sjdm.org/vol12.4.html)), entitled
*FFTrees: A toolbox to create, visualize,and evaluate fast-and-frugal
decision trees* (available in
[html](https://journal.sjdm.org/17/17217/jdm17217.html) \|
[PDF](https://journal.sjdm.org/17/17217/jdm17217.pdf) ).

**Citation** (in APA format):

- Phillips, N. D., Neth, H., Woike, J. K. & Gaissmaier, W. (2017).
  FFTrees: A toolbox to create, visualize, and evaluate fast-and-frugal
  decision trees. *Judgment and Decision Making*, *12* (4), 344–368.
  Retrieved from <https://journal.sjdm.org/17/17217/jdm17217.pdf>

We encourage you to read the article to learn more about the history of
FFTs and how the **FFTrees** package creates, visualizes, and evaluates
them. When using **FFTrees** in your own work, please cite us and share
your experiences (e.g., [on
GitHub](https://github.com/ndphillips/FFTrees/issues)) so we can
continue developing the package.

<!-- Examples uses/publications (with links): -->

Here are some scientific publications that have used **FFTrees** (see
[Google
Scholar](https://scholar.google.com/scholar?oi=bibs&hl=en&cites=205528310591558601)
for the full list):

- [Lötsch, J., Haehner, A., & Hummel, T. (2020).
  Machine-learning-derived rules set excludes risk of Parkinson’s
  disease in patients with olfactory or gustatory symptoms with high
  accuracy. *Journal of Neurology*, *267*(2),
  469-478.](https://link.springer.com/article/10.1007/s00415-019-09604-6)

- [Kagan, R., Parlee, L., Beckett, B., Hayden, J. B., Gundle, K. R., &
  Doung, Y. C. (2020). Radiographic parameter-driven decision tree
  reliably predicts aseptic mechanical failure of compressive
  osseointegration fixation. *Acta Orthopaedica*, *91*(2),
  171-176.](https://www.tandfonline.com/doi/full/10.1080/17453674.2020.1716295)

- [Klement, R. J., Sonke, J. J., Allgäuer, M., Andratschke, N., Appold,
  S., Belderbos, J., … & Mantel, F. (2020). Correlating dose variables
  with local tumor control in stereotactic body radiotherapy for early
  stage non-small cell lung cancer: A modeling study on 1500 individual
  treatments. *International Journal of Radiation Oncology \* Biology \*
  Physics*.](https://www.sciencedirect.com/science/article/pii/S036030162030897X)

- [Nobre, G. G., Hunink, J. E., Baruth, B., Aerts, J. C., & Ward, P. J.
  (2019). Translating large-scale climate variability into crop
  production forecast in Europe. *Scientific Reports*, *9*(1),
  1-13.](https://www.nature.com/articles/s41598-018-38091-4)

- [Buchinsky, F. J., Valentino, W. L., Ruszkay, N., Powell, E.,
  Derkay, C. S., Seedat, R. Y., … & Mortelliti, A. J. (2019). Age at
  diagnosis, but not HPV type, is strongly associated with clinical
  course in recurrent respiratory papillomatosis. *PloS One*,
  *14*(6).](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6563955/)

<!-- footer: -->

------------------------------------------------------------------------

\[File `README.Rmd` last updated on 2023-01-12.\]

<!-- eof. -->
