#' @include class_AmObject.R
NULL

#' @title PeriodSelector
#' @author datastorm-open
#' @description Defines the PeriodSelector properties.
#' 
#' @slot periods \code{list}.
#' Period object has 4 properties - period, count, label and selected.
#' Possible period values are:
#' "ss" - seconds, "mm" - minutes, "hh" - hours, "DD" - days, "MM" - months and "YYYY" - years.
#' property "count" specifies how many periods this button will select.
#' "label" will be displayed on a button and "selected" is logical.
#' which specifies if this button is selected when chart is initialized or not.
#' 
#' @slot listeners \code{list} containining the listeners to add to the object.
#' The list must be named as in the official API. Each element must be a character string.
#' See examples for details.
#' 
#' @slot otherProperties \code{list}
#' containing other avalaible properties not yet implemented in the package.
#' 
#' @slot value
#' Object of class \code{numeric}.
#' 
#' @export
setClass(Class = "PeriodSelector", contains = "AmObject",
         representation = representation(periods = "list"))

#' @title Initializes a PeriodSelector
#' @description Uses the constructors to create the object with its properties
#' or update an existing one with the setters.
#' 
#' @param .Object \linkS4class{PeriodSelector}.
#' @param periods \code{list}.
#' Period object has 4 properties - period, count, label and selected.
#' Possible period values are:
#' "ss" - seconds, "mm" - minutes, "hh" - hours, "DD" - days, "MM" - months and "YYYY" - years.
#' property "count" specifies how many periods this button will select.
#' "label" will be displayed on a button and "selected" is a logical.
#' which specifies if this button is selected when chart is initialized or not.
#' @param ... other properties of PeriodSelector.
#' @return (updated) .Object of class \linkS4class{PeriodSelector}.
#' @examples
#' new( "PeriodSelector")
#' @rdname initialize-PeriodSelector
#' @export
setMethod(f = "initialize", signature = c("PeriodSelector"),
          definition = function(.Object, periods, ...)
          {            
            if (!missing(periods)) {
              .Object@periods <- periods
            } else {}
            .Object <- setProperties(.Object, ...)
            validObject(.Object)
            return(.Object)
          })

# CONSTRUCTOR ####
#' @rdname  initialize-PeriodSelector
#' @examples
#' periodSelector(fillAlpha = .4, value = 1)
#' periodSelector(fillAlpha = .4, adjustBorderColor = TRUE, gridThickness = 1)
#' @export
periodSelector <- function(periods, ...){
  .Object <- new(Class="PeriodSelector")
  if (!missing(periods)) {
    .Object@period <- periods
  } else {}
  .Object <-  setProperties(.Object, ...)
  return( .Object )
}

#' @rdname initialize-PeriodSelector
#' @export
setGeneric("addPeriod", def = function(.Object, ...) { standardGeneric("addPeriod")} )
#' @examples
#' addPeriod(.Object = periodSelector(), period = "MM", selected = TRUE,
#'           count = 1, label= "1 month")
#' @rdname initialize-PeriodSelector
#' @export
setMethod( f = "addPeriod", signature = c("PeriodSelector"),
           definition = function(.Object, ...)
           {
             .Object@periods <- rlist::list.append(.Object@periods, list(...) )
             validObject(.Object)
             return(.Object)
           })

#' @rdname listProperties-AmObject
#' @examples
#' listProperties(periodSelector(fillAlpha = .4, value = 1))
setMethod( f = "listProperties", signature = "PeriodSelector",
           definition = function(.Object)
           { 
             ls <- callNextMethod()
             if (length(.Object@periods)) {
               ls <- rlist::list.append(ls, periods = .Object@periods)
             } else {}
             return(ls)
           })
