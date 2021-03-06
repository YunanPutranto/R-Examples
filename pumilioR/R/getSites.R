getSites <- function(pumilio_URL, credentials = NA, pumiliologin = NA){
	
	if (!is.na(credentials)){
		pumilio_URL <- gsub("http://", paste("http://", credentials, "@", sep=""), pumilio_URL)
		}

	if (!is.na(pumiliologin)){
		pumilio_XML_URL <- paste(pumilio_URL, "xml.php?login=", pumiliologin, sep = "")
	}else{
		pumilio_XML_URL <- paste(pumilio_URL, "xml.php", sep = "")
	}
	
	#Get XML contents
	pumilio_XML <- xmlTreeParse(getURL(pumilio_XML_URL))
	
	pumilio_list <- xmlToList(node = pumilio_XML, addAttributes = TRUE)
	
	sites_list <- as.data.frame(t(pumilio_list$Sites), row.names = FALSE)

	cat(paste(" \n  Found ", dim(sites_list)[1], " results\n\n", sep=""))
  
	invisible(sites_list)
	}