% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fftrees_create.R
\name{fftrees_create}
\alias{fftrees_create}
\title{Create an object of class \code{FFTrees}}
\usage{
fftrees_create(
  formula = NULL,
  data = NULL,
  data.test = NULL,
  algorithm = NULL,
  goal = NULL,
  goal.chase = NULL,
  goal.threshold = NULL,
  max.levels = NULL,
  numthresh.method = NULL,
  numthresh.n = NULL,
  repeat.cues = NULL,
  stopping.rule = NULL,
  stopping.par = NULL,
  sens.w = NULL,
  cost.outcomes = NULL,
  cost.cues = NULL,
  main = NULL,
  decision.labels = NULL,
  my.goal = NULL,
  my.goal.fun = NULL,
  my.tree = NULL,
  quiet = NULL
)
}
\arguments{
\item{formula}{A formula (with a binary criterion variable).}

\item{data}{Training data (as data frame).}

\item{data.test}{Data for testing models/prediction (as data frame).}

\item{algorithm}{Algorithm for growing FFTs (\code{"ifan"} or \code{"dfan"}) (as character string).}

\item{goal}{Measure used to select FFTs (as character string).}

\item{goal.chase}{Measure used to optimize FFT creation (as character string).}

\item{goal.threshold}{Measure used to optimize cue thresholds (as character string).}

\item{max.levels}{integer.}

\item{numthresh.method}{string.}

\item{numthresh.n}{integer.}

\item{repeat.cues}{logical.}

\item{stopping.rule}{string.}

\item{stopping.par}{numeric.}

\item{sens.w}{numeric.}

\item{cost.outcomes}{list.}

\item{cost.cues}{list.}

\item{main}{string.}

\item{decision.labels}{string.}

\item{my.goal}{The name of an optimization measure defined by \code{my.goal.fun} (as a character string).
Example: \code{my.goal = "my_acc"} (see \code{my.goal.fun} for corresponding function).
Default: \code{my.goal = NULL}.}

\item{my.goal.fun}{The definition of an outcome measure to optimize, defined as a function
of the frequency counts of the 4 basic classification outcomes \code{hi, fa, mi, cr}
(i.e., an R function with 4 arguments \code{hi, fa, mi, cr}).
Example: \code{my.goal.fun = function(hi, fa, mi, cr){(hi + cr)/(hi + fa + mi + cr)}} (i.e., accuracy).
Default: \code{my.goal.fun = NULL}.}

\item{my.tree}{A verbal description of an FFT, i.e., an "FFT in words" (as character string).
For example, \code{my.tree = "If age > 20, predict TRUE. If sex = {m}, predict FALSE. Otherwise, predict TRUE."}.}

\item{quiet}{A list of logical elements.}
}
\value{
A new \code{FFTrees} object.
}
\description{
\code{fftrees_create} creates an \code{FFTrees} object.

\code{fftrees_create} is called internally by the main \code{\link{FFTrees}} function.
Its main purpose is to verify and store various parameters
(e.g., to denote algorithms, goals, thresholds) to be used in maximization processes
and for evaluation purposes (e.g., \code{sens.w} and cost values).
}
\seealso{
\code{\link{fftrees_define}} for defining FFTs;
\code{\link{FFTrees}} for creating FFTs from and applying them to data.
}
\keyword{internal}
