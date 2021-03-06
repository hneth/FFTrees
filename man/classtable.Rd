% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/classtable_function.R
\name{classtable}
\alias{classtable}
\title{Calculates several classification statistics from binary prediction and criterion (e.g.; truth) vectors}
\usage{
classtable(prediction.v = NULL, criterion.v, sens.w = 0.5, cost.v = NULL,
  correction = 0.25, cost.outcomes = list(hi = 0, fa = 1, mi = 1, cr = 0))
}
\arguments{
\item{prediction.v}{logical. A logical vector of predictions}

\item{criterion.v}{logical A logical vector of criterion (true) values}

\item{sens.w}{numeric. Weight given to sensitivity, must range from 0 to 1.}

\item{cost.v}{list. An optional list of additional costs to be added to each case.}

\item{correction}{numeric. Correction added to all counts for calculating dprime}

\item{cost.outcomes}{list. A list of length 4 with names 'hi', 'fa', 'mi', and 'cr' specifying the costs of a hit, false alarm, miss, and correct rejection rspectively. E.g.; \code{cost.outcomes = listc("hi" = 0, "fa" = 10, "mi" = 20, "cr" = 0)} means that a false alarm and miss cost 10 and 20 respectively while correct decisions have no cost.}
}
\description{
Calculates several classification statistics from binary prediction and criterion (e.g.; truth) vectors
}
