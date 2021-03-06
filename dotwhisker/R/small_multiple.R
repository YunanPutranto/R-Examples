#' Generate a 'Small Multiple' Plot of Regression Results
#'
#' \code{small_multiple} is a function for plotting regression results of multiple models as a 'small multiple' plot
#'
#' @param x Either a tidy data.frame including results from multiple models (see 'Details') or a list of model objects that can be tidied with \code{\link[broom]{tidy}}
#' @param alpha A number setting the criterion of the confidence intervals. The default value is .05, corresponding to 95-percent confidence intervals.
#' @param dodge_size A number (typically between 0 and 0.3; the default is .06) indicating how much horizontal separation should appear between different submodels' coefficients when multiple submodels are graphed in a single plot.  Lower values tend to look better when the number of models is small, while a higher value may be helpful when many submodels appear on the same plot.
#'
#' @details
#' Kastellec and Leoni (2007)
#' \code{small_multiple} takes a tidy data.frame of regression results or a list of model objects and generates a dot-and-whisker plot of the results of a single variable across the multiple models.
#'
#' Tidy data.frames to be plotted should include the variables \code{term} (names of predictors), \code{estimate} (corresponding estimates of coefficients or other quantities of interest), \code{std.error} (corresponding standard errors), and \code{model} (identifying the corresponding model).
#' In place of \code{std.error} one may substitute \code{lb} (the lower bounds of the confidence intervals of each estimate) and \code{ub} (the corresponding upper bounds).
#'
#' Alternately, \code{small_multiple} accepts as input a list of model objects that can be tidied by \code{\link[broom]{tidy}}.
#'
#' Optionally, more than one set of results can be clustered to facilitate comparison within each \code{model}; one example of when this may be desireable is to compare results across samples.  In that case, the data.frame should also include a variable \code{submodel} identifying the submodel of the results.
#'
#' @return The function returns a \code{ggplot} object.
#'
#' @note Ideally, the y-axes of small multiple plots would vary by predictor, but small_multiple does not currently support this behavior.
#'
#' @examples
#' library(broom)
#' library(dplyr)
#'
#' # Generate a tidy data.frame of regression results from six models
#'
#' m <- list()
#' ordered_vars <- c("wt", "cyl", "disp", "hp", "gear", "am")
#' m[[1]] <- lm(mpg ~ wt, data = mtcars)
#' m123456_df <- m[[1]] %>% tidy %>% by_2sd(mtcars) %>%
#'   mutate(model = "Model 1")
#'
#' for (i in 2:6) {
#'  m[[i]] <- update(m[[i-1]], paste(". ~ . +", ordered_vars[i]))
#'  m123456_df <- rbind(m123456_df, m[[i]] %>% tidy %>% by_2sd(mtcars) %>%
#'    mutate(model = paste("Model", i)))
#' }
#'
#' # Generate a 'small multiple' plot
#' small_multiple(m123456_df)
#'
#'
#' ## Using submodels to compare results across different samples
#' # Generate a tidy data.frame of regression results from five models on
#' # the mtcars data subset by transmission type (am)
#' ordered_vars <- c("wt", "cyl", "disp", "hp", "gear")
#' mod <- "mpg ~ wt"
#' by_trans <- mtcars %>% group_by(am) %>%  # group data by transmission
#'   do(tidy(lm(mod, data = .))) %>%        # run model on each group
#'   rename(submodel = am) %>%              # make submodel variable
#'   mutate(model = "Model 1")              # make model variable
#'
#' for (i in 2:5) {
#'   mod <- paste(mod, "+", ordered_vars[i])
#'   by_trans <- rbind(by_trans, mtcars %>% group_by(am) %>%
#'                    do(tidy(lm(mod, data = .))) %>%
#'                    rename(submodel = am) %>%
#'                    mutate(model = paste("Model", i)))
#' }
#'
#' small_multiple(by_trans) +
#' theme_bw() + ylab("Coefficient Estimate") +
#'     geom_hline(yintercept = 0, colour = "grey60", linetype = 2) +
#'     theme(axis.text.x  = element_text(angle = 45, hjust = 1),
#'           legend.position=c(0, 0), legend.justification=c(0, 0),
#'           legend.title = element_text(size=9),
#'           legend.background = element_rect(color="gray90"),
#'           legend.margin = unit(-3, "pt"),
#'           legend.key.size = unit(10, "pt")) +
#'     scale_colour_hue(name = "Transmission",
#'     breaks = c(0, 1),
#'     labels = c("Automatic", "Manual"))
#'
#' @import dplyr
#' @importFrom stringr str_replace
#'
#' @export

small_multiple <- function(x, dodge_size = .06, alpha=.05) {
    # If x is list of model objects, convert to a tidy data.frame
    df <- dw_tidy(x)

    # set variables that will appear in pipelines to NULL to make R CMD check happy
    estimate <- submodel <- NULL

    n_vars <- length(unique(df$term))

    # Confirm number of models and submodels, get model names
    if (!"model" %in% names(df)) {
        if (length(df$term) == n_vars) {
            stop("'Small multiple' plots are used to compare results across many different models; please submit results from more than one model")
        } else {
            stop("Please add a variable named 'model' to distinguish different models")
        }
    } else {
        if ("submodel" %in% names(df)) {
            if (!is.factor(df$submodel)) {
                df$submodel <- factor(df$submodel, levels = unique(df$submodel))
            }
            df$mod <- df$model
            df$model <- paste0(df$model, df$submodel)
            sub_names <- unique(df$submodel)
            n_sub <- length(sub_names)
        } else {
            df$submodel <- 1
            n_sub <- 1
        }
    }
    mod_names <- unique(df$model)
    n_models <- length(mod_names)

    # Add rows of NAs for variables not included in a particular model
    df <- add_NAs(df, n_models, mod_names)
    if ("submodel" %in% names(df)) {
        df$model <- stringr::str_replace(df$model, as.character(df$submodel), "")
        mod_names <- unique(df$model)
        n_models <- length(mod_names)
    }

    # Confirm alpha within bounds
    if (alpha < 0 | alpha > 1) {
        stop("Value of alpha for the confidential intervals should be between 0 and 1.")
    }

    # Generate lower and upper bound if not included in results
    if ((!"lb" %in% names(df)) | (!"ub" %in% names(df))) {
        ci <- 1 - alpha/2
        lb <- c(df$estimate - qnorm(ci) * df$std.error)
        ub <- c(df$estimate + qnorm(ci) * df$std.error)

        df <- cbind(df, lb, ub)
    }

    # Calculate x-axis shift for plotting multiple submodels, generate x index
    if (n_sub == 1) {
        df$shift <- 0
    } else {
        shift <- seq(-dodge_size, dodge_size, length.out = n_sub)
        df$shift <- rep(rep(shift, each = n_vars), times = n_models)
    }
    x_ind <- rep(seq(1, n_models), each = n_vars*n_sub)
    df$x_ind <- x_ind

    # Catch difference between single and multiple submodels
    if (length(x_ind) != length(mod_names)) {
        x_ind <- unique(x_ind)
    }

    # Plot
    p <- ggplot(df, aes(x = x_ind + shift, y = estimate, colour=factor(submodel))) +
        geom_point(na.rm = TRUE) +
        geom_segment(aes(x = x_ind + shift,
                         xend = x_ind + shift,
                         y = ub, yend = lb,
                         colour=factor(submodel)), na.rm = TRUE) +
        scale_x_continuous(breaks=x_ind, labels=mod_names) +
        xlab("") +
        facet_grid(term ~ ., scales = "free_y")

    if (n_sub == 1) {
        p <- p + theme(legend.position="none")
    }

    return(p)
}
