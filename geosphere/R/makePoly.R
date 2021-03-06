# author Robert Hijmans
# April 2010
# version 0.1
# license GPL



.makeSinglePoly <- function(p, interval=10000, r=6378137) {
	res <- p[1,]
	for (i in 1:(nrow(p)-1)) {
		if (! isTRUE( all.equal(p[i,], p[i+1,]) )) {
			d <- distHaversine(p[i,], p[i+1,], r=r)
			n <- floor(d / interval)
			if (n > 0) {
				pts <- gcIntermediate(p[i,],p[i+1,], n)
				pts <- rbind(p[i,], pts, p[i+1,])
				res <- rbind(res, pts, p[i+1,])
			} else {
				res <- rbind(res, p[i+1,])
			}
		}
	}
	if (nrow(res) < 3) stop('cannot make a valid polygon')
	return(res)
}
 
 
 
.makeSingleLine <- function(p, interval=10000, r=6378137) {
	res <- p[1,]
	for (i in 1:(nrow(p)-1)) {
		if (! isTRUE( all.equal(p[i,], p[i+1,]) )) {
			d <- distHaversine(p[i,], p[i+1,], r=r)
			n <- floor(d / interval)
			if (n > 0) {
				pts <- gcIntermediate(p[i,],p[i+1,], n)
				pts <- rbind(p[i,], pts, p[i+1,])
				res <- rbind(res, pts, p[i+1,])
			} else {
				res <- rbind(res, p[i+1,])
			}
		}
	}
	if (nrow(res) < 2) stop('cannot make a valid polygon')
	return(res)
}
 
 
makePoly <- function(p, interval=10000, r=6378137, sp=FALSE) {
	if (inherits(p, 'SpatialPolygons')) {
		test <- !is.projected(p)
		if (! isTRUE (test) ) {
			if (is.na(test)) {
				warning('Coordinate reference system of SpatialPolygons object is not set. Assuming it is degrees (longitude/latitude)!')  			
			} else {
				stop('Points are projected. They should be in degrees (longitude/latitude)')  
			}
			# or rather transform them ....?
		}
	
		x <- p@polygons
		n <- length(x)
		polys = list()
		for (i in 1:n) {
			parts <- length(x[[i]]@Polygons )
			partlist <- list()
			for (j in 1:parts) {
				crd <- x[[i]]@Polygons[[j]]@coords
				crd <- .makeSinglePoly(crd, interval=interval, r=r)
				partlist[[j]] <- Polygon(crd)
			}
			polys[[i]] <- Polygons(partlist, i)
		}
		polys <- SpatialPolygons(polys)
		if (inherits(p, 'SpatialPolygonsDataFrame')) {
			rownames(p@data) <- 1:nrow(p@data)
			polys <- SpatialPolygonsDataFrame(polys, p@data)	
		}
		polys@proj4string <- p@proj4string
		return(polys)
	} else {
		p <- .pointsToMatrix(p)
		if (nrow(p) < 3) {
			stop('cannot make a polygon (insufficent number of vertices)')
		}
		if (! isTRUE(all.equal(p[1,], p[nrow(p),]))) {
			p <- rbind(p, p[1,])
		}
		res <- .makeSinglePoly(p, interval=interval, r=r) 
		if (sp) {
			res <- SpatialPolygons(list(Polygons(list(Polygon(res)), 1)))
			res@proj4string <- CRS("+proj=longlat +datum=WGS84")
		}
		return(res)
	}
} 



makeLine <- function(p, interval=10000, r=6378137, sp=FALSE) {
	if (inherits(p, 'SpatialLines')) {
		test <- !is.projected(p)
		if (! isTRUE (test) ) {
			if (is.na(test)) {
				warning('Coordinate reference system of SpatialPolygons object is not set. Assuming it is degrees (longitude/latitude)!')  			
			} else {
				stop('Points are projected. They should be in degrees (longitude/latitude)')  
			}
			# or rather transform them ....?
		}
	
	
		x = p@lines
		n = length(x)
		lines = list()
		for (i in 1:n) {
			parts = length(x[[i]]@Lines )
			partlist = list()
			for (j in 1:parts) {
				crd = x[[i]]@Lines[[j]]@coords
				crd = .makeSingleLine(crd, interval=interval, r=r)
				partlist[[j]] = Line(crd)
			}
			lines[[i]] = Lines(partlist, i)
		}
		lines <- SpatialLines(lines)
		if (inherits(p, 'SpatialLinesDataFrame')) {
			lines <- SpatialLinesDataFrame(lines, p@data)	
		}
		lines@proj4string <- p@proj4string
		return(lines)
	} else {
		p <- .pointsToMatrix(p)
		if (nrow(p) < 3) {
			stop('cannot make a polygon (insufficent number of vertices)')
		}
		res <- .makeSingleLine(p, interval=interval, r=r) 
		if (sp) {
			res <- SpatialLines(list(Lines(list(Line(res)), 1)))
			res@proj4string <- CRS("+proj=longlat +datum=WGS84")
		}
		return(res)
	}
} 



