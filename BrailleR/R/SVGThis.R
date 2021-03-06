
# this file is only for the SVGThis method and associated utility functions.
# SVGThis.default() needs interactive session but specific methods need not be

# this from Paul via maps example
## chekc it is not already incorporated into new version of gridSVG.
addInfo <- function(name, title, desc) {
    grid::grid.set(name,
             grid::gTree(children=
                   grid::gList(
                       elementGrob("title",
                                   children=grid::gList(textNodeGrob(title))),
                       elementGrob("desc",
                                   children=grid::gList(textNodeGrob(desc))),
                       grid::grid.get(name)),
                   name=name),
             redraw=FALSE)
}

# next is partly from Paul via maps example, with additions from Jonathan
MakeTigerReady=function(svgfile){ # for alterations needed on all SVG files
if(file.exists(svgfile)){
cat("\n", file=svgfile, append=TRUE) # otherwise warnings returned on readLines() below
temp <- readLines(con=svgfile)
writeLines(gsub("ISO8859-1", "ASCII", temp), con=svgfile)
}
else{ warning("The specified SVG does not exist.\n")}
return(invisible(NULL))
}

# method is mostly Jonathan's use of Paul/Simon's work
SVGThis=function(x, file="test.svg"){
UseMethod("SVGThis")
}

SVGThis.default=function(x, file="test.svg"){
if(is.null(x)){ # must be running interactively
if(dev.cur()>1){ # there must also be an open graphics/grid device

if(length(grid::grid.ls(print=FALSE)$name) == 0) {# if not grid already, then convert
 gridGraphics::grid.echo()}

# then export to SVG
gridSVG::grid.export(name=file)
MakeTigerReady(svgfile=file)
# no specific processing to be done in this function.
} # end open device condition
else{ # no current device
warning("There is no current graphics device to convert to SVG.\n")} 
} # end interactive condition
else{ # not interactive session
warning("The default SVGThis() method only works for objects of specific classes.\nThe object supplied does not yet have a a method written for it.\n")}
return(invisible(NULL))
}

SVGThis.histogram=function(x, file="test.svg"){
# really should check that the histogram wasn't plotted already before... 
# but simpler to just do the plotting ourselves and close the device later
x # ensure we create a histogram on a new graphics device
gridGraphics::grid.echo() # hist() currently uses graphics package
# use gridSVG ideas in here
gridSVG::grid.garnish("graphics-plot-1-bottom-axis-line-1", title="the x axis")
gridSVG::grid.garnish("graphics-plot-1-left-axis-line-1", title="the y axis") 
# these titles are included in the <g> tag not a <title> tag
# checking back with the maps example, Paul used...
addInfo("graphics-plot-1-bottom-axis-line-1", title="the x axis", desc="need something much smarter in here")
addInfo("graphics-plot-1-left-axis-line-1", title="the y axis", desc="need something much smarter in here")
# but these push the plotting line down a peg in the svg file so what was 1.1 is now 1.2
# is that important?

gridSVG::grid.export(name=file)
dev.off() # remove our graph window
MakeTigerReady(svgfile=file)
# add class-specific content to svg file from here onwards
# short descriptions should be automatic, such as axis labels or marks
# long descriptions need to be constructed, such as describe all axis marks together
# find some way to embed the object from which the graph was created
return(invisible(NULL))
}
