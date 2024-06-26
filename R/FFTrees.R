#' Main function to create and apply fast-and-frugal trees (FFTs)
#'
#' @description \code{FFTrees} is the workhorse function of the \strong{FFTrees} package for creating fast-and-frugal trees (FFTs).
#'
#' FFTs are decision algorithms for solving binary classification tasks, i.e., they predict the values of a binary criterion variable based on 1 or multiple predictor variables (cues).
#'
#' Using \code{FFTrees} on \code{data} usually generates a range of FFTs and corresponding summary statistics (as an \code{FFTrees} object)
#' that can then be printed, plotted, and examined further.
#'
#' The criterion and predictor variables are specified in \code{\link{formula}} notation.
#' Based on the settings of \code{data} and \code{data.test}, FFTs are trained on a (required) training dataset
#' (given the set of current \code{goal} values) and evaluated on (or predict) an (optional) test dataset.
#'
#' If an existing \code{FFTrees} object \code{object} or \code{tree.definitions} are provided as inputs,
#' no new FFTs are created.
#' When both arguments are provided, \code{tree.definitions} take priority over the FFTs in an existing \code{object}.
#' Specifically,
#'
#' \itemize{
#'
#'   \item{If \code{tree.definitions} are provided, these are assigned to the FFTs of \code{x}.}
#'
#'   \item{If no \code{tree.definitions} are provided, but an existing \code{FFTrees} object \code{object} is provided,
#'   the trees from \code{object} are assigned to the FFTs of \code{x}.}
#'
#' }
#'
#' @param formula A formula. A \code{\link{formula}} specifying a binary criterion variable (as logical) as a function of 1 or more predictor variables (cues).
#' @param data A data frame. A dataset used for training (fitting) FFTs and alternative algorithms.
#' \code{data} must contain the binary criterion variable specified in \code{formula} and potential predictors (which can be categorical or numeric variables).
#' @param data.test A data frame. An optional dataset used for model testing (prediction) with the same structure as data.
#' @param algorithm A character string. The algorithm used to create FFTs. Can be \code{'ifan'}, \code{'dfan'}.
#' @param train.p numeric. What percentage of the data to use for training when \code{data.test} is not specified?
#' For example, \code{train.p = .50} will randomly split \code{data} into a 50\% training set and a 50\% test set.
#' Default: \code{train.p = 1} (i.e., using \emph{all} data for training).
#'
#' @param goal A character string indicating the statistic to maximize when \emph{selecting trees}:
#' \code{"acc"} = overall accuracy, \code{"bacc"} = balanced accuracy, \code{"wacc"} = weighted accuracy,
#' \code{"dprime"} = discriminability, \code{"cost"} = costs (based on \code{cost.outcomes} and \code{cost.cues}).
#' @param goal.chase A character string indicating the statistic to maximize when \emph{constructing trees}:
#' \code{"acc"} = overall accuracy, \code{"bacc"} = balanced accuracy, \code{"wacc"} = weighted accuracy,
#' \code{"dprime"} = discriminability, \code{"cost"} = costs (based on \code{cost.outcomes} and \code{cost.cues}).
#' @param goal.threshold A character string indicating the criterion to maximize when \emph{optimizing cue thresholds}:
#' \code{"acc"} = overall accuracy, \code{"bacc"} = balanced accuracy, \code{"wacc"} = weighted accuracy,
#' \code{"dprime"} = discriminability, \code{"cost"} = costs (based only on \code{cost.outcomes}, as \code{cost.cues} are constant per cue).
#' All default goals are set in \code{\link{fftrees_create}}.
#'
#' @param max.levels integer. The maximum number of nodes (or levels) considered for an FFT.
#' As all combinations of possible exit structures are considered, larger values of \code{max.levels} will create larger sets of FFTs.
#'
#' @param numthresh.method How should thresholds for numeric cues be determined (as character)?
#' \code{"o"} will optimize thresholds (for \code{goal.threshold}), while \code{"m"} will use the median.
#' Default: \code{numthresh.method = "o"}.
#' @param numthresh.n The number of numeric thresholds to try (as integer).
#' Default: \code{numthresh.n = 10}.
#'
#' @param repeat.cues May cues occur multiple times within a tree (as logical)?
#' Default: \code{repeat.cues = TRUE}.
#'
#' @param stopping.rule A character string indicating the method to stop growing trees.
#' Available options are:
#' \itemize{
#'   \item{\code{"exemplars"}: A tree grows until only a small proportion of unclassified exemplars remain;}
#'   \item{\code{"levels"}: A tree grows until a certain level is reached;}
#'   \item{\code{"statdelta"}: A tree grows until the change in the criterion statistic \code{goal.chase} exceeds some threshold level.
#'   (This setting is currently experimental and includes the first level beyond threshold.
#'   As tree statistics can be non-monotonic, this option may yield inconsistent results.)}
#'   }
#' All stopping methods use \code{stopping.par} to set a numeric threshold value.
#' Default: \code{stopping.rule = "exemplars"}.
#' @param stopping.par numeric. A numeric parameter indicating the criterion value for the current \code{stopping.rule}.
#' For stopping.rule \code{"levels"}, this is the number of desired levels (as an integer).
#' For stopping rule \code{"exemplars"}, this is the smallest proportion of exemplars allowed in the last level.
#' For stopping.rule \code{"statdelta"}, this is the minimum required change (in the \code{goal.chase} value) to include a level.
#' Default: \code{stopping.par = .10}.
#'
#' @param sens.w A numeric value from \code{0} to \code{1} indicating how to weight
#' sensitivity relative to specificity when optimizing \emph{weighted} accuracy (e.g., \code{goal = 'wacc'}).
#' Default: \code{sens.w = .50} (i.e., \code{wacc} corresponds to \code{bacc}).
#'
#' @param cost.outcomes A list of length 4 specifying the cost value for one of the 4 possible classification outcomes.
#' The list elements must be named \code{'hi'}, \code{'fa'}, \code{'mi'}, and \code{'cr'}
#' (for specifying the costs of a hit, false alarm, miss, and correct rejection, respectively) and provide a numeric cost value.
#' E.g.; \code{cost.outcomes = listc("hi" = 0, "fa" = 10, "mi" = 20, "cr" = 0)} imposes false alarm and miss costs of \code{10} and \code{20} units, respectively, while correct decisions have no costs.
#' @param cost.cues A list containing the cost of each cue (in some common unit).
#' Each list element must have a name corresponding to a cue (i.e., a variable in \code{data}), and should be a single (positive numeric) value.
#' Cues in \code{data} that are not present in \code{cost.cues} are assumed to have no costs (i.e., a cost value of \code{0}).
#'
#' @param main string. An optional label for the dataset. Passed on to other functions, like \code{\link{plot.FFTrees}}, and \code{\link{print.FFTrees}}.
#' @param decision.labels A vector of strings of length 2 for the text labels for negative and positive decision/prediction outcomes
#' (i.e., left vs. right, noise vs. signal, 0 vs. 1, respectively, as character).
#' E.g.; \code{decision.labels = c("Healthy", "Diseased")}.
#'
#' @param my.goal The name of an optimization measure defined by \code{my.goal.fun} (as a character string).
#' Example: \code{my.goal = "my_acc"} (see \code{my.goal.fun} for corresponding function).
#' Default: \code{my.goal = NULL}.
#' @param my.goal.fun The definition of an outcome measure to optimize, defined as a function
#' of the frequency counts of the 4 basic classification outcomes \code{hi, fa, mi, cr}
#' (i.e., an R function with 4 arguments \code{hi, fa, mi, cr}).
#' Example: \code{my.goal.fun = function(hi, fa, mi, cr){(hi + cr)/(hi + fa + mi + cr)}} (i.e., accuracy).
#' Default: \code{my.goal.fun = NULL}.
#'
#' @param my.tree A verbal description of an FFT, i.e., an "FFT in words" (as character string).
#' For example, \code{my.tree = "If age > 20, predict TRUE. If sex = {m}, predict FALSE. Otherwise, predict TRUE."}.
#'
#' @param object An optional existing \code{FFTrees} object.
#' When specified, no new FFTs are fitted, but existing trees are applied to \code{data} and \code{data.test}.
#' When \code{formula}, \code{data} or \code{data.test} are not specified, the current values of \code{object} are used.
#' @param tree.definitions An optional \code{data.frame} of hard-coded FFT definitions (in the format of \code{x$trees$definitions} of an \code{FFTrees} object \code{x}).
#' If specified, no new FFTs are being fitted (i.e., \code{algorithm} and functions for evaluating cues and creating FFTs are skipped).
#' Instead, the tree definitions provided are used to re-evaluate the current \code{FFTrees} object on current data.
#'
#' @param quiet A list of 4 logical arguments: Should detailed progress reports be suppressed?
#' Setting list elements to \code{FALSE} is helpful when diagnosing errors.
#' Default: \code{quiet = list(ini = TRUE, fin = FALSE, mis = FALSE, set = TRUE)},
#' for initial vs. final steps, missing cases, and parameter settings, respectively.
#' Providing a single logical value sets all elements to \code{TRUE} or \code{FALSE}.
#'
#' @param comp,do.comp,do.lr,do.cart,do.svm,do.rf,force,rank.method,rounding,store.data,verbose Deprecated arguments (unused or replaced, to be retired in future releases).
#'
#' @return An \code{FFTrees} object with the following elements:
#' \describe{
#'   \item{criterion_name}{The name of the binary criterion variable (as character).}
#'   \item{cue_names}{The names of all potential predictor variables (cues) in the data (as character).}
#'   \item{formula}{The \code{\link{formula}} specified when creating the FFTs.}
#'   \item{trees}{A list of FFTs created, with further details contained in \code{n}, \code{best}, \code{definitions}, \code{inwords}, \code{stats}, \code{level_stats}, and \code{decisions}.}
#'   \item{data}{The original training and test data (if available).}
#'   \item{params}{A list of defined control parameters (e.g.; \code{algorithm}, \code{goal}, \code{sens.w}, as well as various thresholds, stopping rule, and cost parameters).}
#'   \item{cues}{A list of cue information, with further details contained in \code{thresholds} and \code{stats}.}
#' }
#'
#' @examples
#'
#' # 1. Create fast-and-frugal trees (FFTs) for heart disease:
#' heart.fft <- FFTrees(formula = diagnosis ~ .,
#'                      data = heart.train,
#'                      data.test = heart.test,
#'                      main = "Heart Disease",
#'                      decision.labels = c("Healthy", "Diseased")
#'                      )
#'
#' # 2. Print a summary of the result:
#' heart.fft  # same as:
#' # print(heart.fft, data = "train", tree = "best.train")
#'
#' # 3. Plot an FFT applied to training data:
#' plot(heart.fft)  # same as:
#' # plot(heart.fft, what = "all", data = "train", tree = "best.train")
#'
#' # 4. Apply FFT to (new) testing data:
#' plot(heart.fft, data = "test")            # predict for Tree 1
#' plot(heart.fft, data = "test", tree = 2)  # predict for Tree 2
#'
#' # 5. Predict classes and probabilities for new data:
#' predict(heart.fft, newdata = heartdisease)
#' predict(heart.fft, newdata = heartdisease, type = "prob")
#'
#' # 6. Create a custom tree (from verbal description) with my.tree:
#' custom.fft <- FFTrees(
#'   formula = diagnosis ~ .,
#'   data = heartdisease,
#'   my.tree = "If age < 50, predict False.
#'              If sex = 1, predict True.
#'              If chol > 300, predict True, otherwise predict False.",
#'   main = "My custom FFT")
#'
#' # Plot the (pretty bad) custom tree:
#' plot(custom.fft)
#'
#' @aliases FFTrees-function
#'
#' @seealso
#' \code{\link{print.FFTrees}} for printing FFTs;
#' \code{\link{plot.FFTrees}} for plotting FFTs;
#' \code{\link{summary.FFTrees}} for summarizing FFTs;
#' \code{\link{inwords}} for obtaining a verbal description of FFTs;
#' \code{\link{showcues}} for plotting cue accuracies.
#'
#' @importFrom stats as.formula formula glm predict sd
#'
#' @export

FFTrees <- function(formula = NULL,
                    data = NULL,
                    data.test = NULL,
                    algorithm = "ifan",
                    train.p = 1,
                    #
                    goal = NULL,              # (default set in fftrees_create.R)
                    goal.chase = NULL,        # (default set in fftrees_create.R)
                    goal.threshold = NULL,    # (default set in fftrees_create.R)
                    #
                    max.levels = NULL,        # (default set in fftrees_create.R)
                    numthresh.method = "o",
                    numthresh.n = 10,
                    repeat.cues = TRUE,
                    stopping.rule = "exemplars",
                    stopping.par = .10,
                    #
                    sens.w = .50,
                    #
                    cost.outcomes = NULL,     # (default set in fftrees_create.R)
                    cost.cues = NULL,         # (default set in fftrees_create.R)
                    #
                    main = NULL,
                    decision.labels = c("False", "True"),  # in 0:FALSE/noise/left vs. 1:TRUE/signal/right order
                    #
                    #
                    my.goal = NULL,      # e.g., "my_acc",  # name of my.goal (as character)
                    my.goal.fun = NULL,  # e.g., function(hi, fa, mi, cr){(hi + cr)/(hi + fa + mi + cr)},  # a function of (hi, fa, mi, cr)
                    my.tree = NULL,
                    #
                    object = NULL,
                    tree.definitions = NULL,

                    #
                    quiet = list(ini = TRUE, fin = FALSE, mis = FALSE, set = TRUE),  # a list of 4 Boolean args
                    # ufeed = 2L,        # ToDo: user feedback level (from feed_types 0:3)
                    #
                    # Deprecated args:   Use instead:
                    comp = NULL,         # do.comp
                    force = NULL,        # (none)
                    rank.method = NULL,  # algorithm
                    rounding = NULL,     # in fftrees_cuerank()
                    store.data = NULL,   # (none)
                    verbose = NULL,       # progress
                    do.comp = NULL,
                    do.cart = NULL,
                    do.lr = NULL,
                    do.rf = NULL,
                    do.svm = NULL
) {

  # Prepare: ------

  # A. Handle deprecated arguments and options: ------

  if (!is.null(comp)) {
    stop("comp is hard deprecated and no longer supported as of FFTrees 2.1.0")
  }

  if (!is.null(do.comp)) {
    stop("do.comp is hard deprecated and no longer supported as of FFTrees 2.1.0")
  }

  if (!is.null(do.cart)) {
    stop("do.cart is hard deprecated and no longer supported as of FFTrees 2.1.0")
  }

  if (!is.null(do.lr)) {
    stop("do.lr is hard deprecated and no longer supported as of FFTrees 2.1.0")
  }

  if (!is.null(do.rf)) {
    stop("do.rf is hard deprecated and no longer supported as of FFTrees 2.1.0")
  }

  if (!is.null(do.svm)) {
    stop("do.csvm is hard deprecated and no longer supported as of FFTrees 2.1.0")
  }

  if (!is.null(force)){
    warning("The argument 'force' is deprecated and ignored.")
  }

  if (!is.null(rank.method)) {
    warning("The argument 'rank.method' is deprecated. Use 'algorithm' instead.")

    algorithm <- rank.method
  }

  if (!is.null(rounding)) {
    warning("The argument 'rounding' is deprecated and ignored.")
  }

  if (!is.null(store.data)) {
    warning("The argument 'store.data' is deprecated and ignored.")
  }

  if (!is.null(verbose)) {
    warning("The argument 'verbose' is deprecated. Use 'progress' instead.")

    progress <- verbose
  }

  if (any(c("max", "zigzag") %in% algorithm)) {
    stop("The 'max' and 'zigzag' algorithms are no longer supported.")
  }

  if (is.logical(quiet)) {

    quiet <- list(ini = quiet, fin = quiet, mis = quiet, set = quiet)

    if (any(sapply(quiet, isFALSE))) {

      cli::cli_alert_success("Set 'quiet' elements to '{quiet}'.")

    }

  }


  # B. Verify inputs: ------


  # Provide user feedback: ----

  # if (!quiet$ini) { cli::cli_h2("Get FFTrees:") }


  # object: ----

  if (!is.null(object)) { # an FFTrees object is provided:

    # Verify:
    testthat::expect_s3_class(object, class = "FFTrees")

    # Fill in some missing defaults by current object values:

    # Main formula and data parameters (to keep/preserve):
    if (is.null(formula)) { formula <- object$formula }
    if (is.null(data)) { data <- object$data$train }
    if (is.null(data.test) & (!is.null(object$data$test))) { data.test <- object$data$test }

    # goal parameters:
    if (is.null(goal)) { goal <- object$params$goal }
    if (is.null(goal.chase)) { goal.chase <- object$params$goal.chase }
    if (is.null(goal.threshold)) { goal.threshold <- object$params$goal.threshold }

    # cost parameters:
    if (is.null(cost.outcomes)) { cost.outcomes <- object$params$cost.outcomes }
    if (is.null(cost.cues)) { cost.cues <- object$params$cost.cues }

    # Other candidates (of parameters to keep/preserve):
    # numthresh, stopping, ...
    if (is.null(algorithm)) { algorithm <- object$params$algorithm }
    if (is.null(max.levels)) { max.levels <- object$params$max.levels }

    # Provide user feedback: ----

    if (any(sapply(quiet, isFALSE))) {

      msg <- paste0("Using the FFTrees object provided (and some of its key parameters).")

      # cat(u_f_hig(msg, "\n"))

      cli::cli_alert_info(msg)

    }

  }


  # tree.definitions: ----

  if (!is.null(tree.definitions)){

    # Verify:

    # ToDo: Verify integrity of tree definitions:
    # 1. tree.definitions contains valid tree definitions (in appropriate format):
    testthat::expect_true(verify_ffts_df(tree.definitions))

    # 2. tree.definitions fit to provided data (see verify_all_cues_in_data() in helper.R)

  }


  # formula: ----

  # Get criterion (from formula):
  criterion_name <- get_lhs_formula(formula)

  if (!criterion_name %in% names(data)){
    stop(paste0("A criterion variable '", criterion_name, "' was not found in data"))
  }


  # C. Handle data: ------

  # Split training / test data: ----

  if ((train.p < 1) && is.null(data.test)) {

    # Save original data:
    data_o <- data

    train_cases <- caret::createDataPartition(data_o[[criterion_name]], p = train.p)[[1]]

    data      <- data_o[train_cases, ]
    data.test <- data_o[-train_cases, ]


    # Provide user feedback: ----

    if (any(sapply(quiet, isFALSE))) {

      msg <- paste0("Split data into a ", scales::percent(train.p), " (N = ", scales::comma(nrow(data)), ") training and ",
                    scales::percent(1 - train.p), " (N = ", scales::comma(nrow(data.test)), ") test set.")

      # cat(u_f_fin(msg), "\n")

      cli::cli_alert_success(msg)

    }

  }


  # Main: ------

  # 1. Create a new FFTrees object x: ----

  x <- fftrees_create(formula = formula,
                      data = data,
                      data.test = data.test,
                      algorithm = algorithm,
                      #
                      goal = goal,
                      goal.chase = goal.chase,
                      goal.threshold = goal.threshold,
                      #
                      max.levels = max.levels,
                      numthresh.method = numthresh.method,
                      numthresh.n = numthresh.n,
                      stopping.rule = stopping.rule,
                      stopping.par = stopping.par,
                      repeat.cues = repeat.cues,
                      #
                      sens.w = sens.w,
                      #
                      cost.outcomes = cost.outcomes,
                      cost.cues = cost.cues,
                      #
                      main = main,
                      decision.labels = decision.labels,
                      #
                      my.goal = my.goal,
                      my.goal.fun = my.goal.fun,
                      my.tree = my.tree,
                      #
                      quiet = quiet # as list, stored in x$params$quiet
  )


  # 2. Create FFT definitions for x: ----

  x <- fftrees_define(x,
                      object = object,
                      tree.definitions = tree.definitions)


  # 3. Apply x to training data: ----

  x <- fftrees_apply(x, mydata = "train")  # apply and re-assign!


  # 4. Rank trees in x by goal: ----

  x <- fftrees_ranktrees(x)


  # 5. Apply x to test data: ----

  if (!is.null(x$data$test)) {
    x <- fftrees_apply(x, mydata = "test")  # apply and re-assign!
  }


  # 6. Express trees in x in words: ----

  x <- fftrees_ffttowords(x,
                          mydata = "train",  # data type: 'train'->'decide' or 'test'->'predict'
                          digits = 2)



  # Provide user feedback: ----

  # if (!quiet$fin) { cli::cli_h2("Got FFTrees.") }


  # Output: ------

  return(x)

} # FFTrees().


# ToDo: ------

# - When providing a valid FFTrees object:
#   Fill in missing defaults (formula, data, ...) with corresponding object values.

# Note source of confusion: The `tree` variable in tree definitions sometimes serves as:
# 1. a counter (`tree_i` in `fftrees_apply()`), but mostly as
# 2. an ID variable (i.e., `tree` = 1 is "best" tree after ranking...).
# ToDo: Assign a separate `tree_id` (which acts as an identifier/name handler for a tree
#       and is moved with tree definition by ranking.

# eof.
