library(dplyr)
library(xslt)
library(rdrop2)

map_geographical_coverage <- function(eml){
  name <- xml2::xml_find_all(eml, "//geographicCoverage/geographicDescription")
  name <- unlist(xml2::as_list(name))

  west <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/westBoundingCoordinate")
  west <- as.numeric(unlist(xml2::as_list(west)))

  east <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/eastBoundingCoordinate")
  east <- as.numeric(unlist(xml2::as_list(east)))

  north <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/northBoundingCoordinate")
  north <- as.numeric(unlist(xml2::as_list(north)))

  south <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/southBoundingCoordinate")
  south <- as.numeric(unlist(xml2::as_list(south)))

  geo_info <- data.frame(name = name,
                         west = west, east = east,
                         south = south, north = north)

  map <- leaflet::leaflet(geo_info) %>%
    leaflet::addProviderTiles("CartoDB.Positron") %>%
    leaflet::addRectangles(
      lng1 = west, lat1 = south,
      lng2 = east, lat2 = north,
      popup = name,
      fillColor = "transparent"
    )
  htmlwidgets::saveWidget(map, file = "www/map.html", selfcontained = TRUE)
}

write_custom_css <- function(publish_mode){

  # get the css we always use
  main_css <- readLines("../template_emldown/main_custom.css")

  edu_css <- readLines("../template_emldown/educational_custom.css")

  writeLines(main_css, con = "custom.css")

  if(publish_mode){
    cat(edu_css, file= "custom.css", append = TRUE)
  }
}

render_eml <- function(file, open = TRUE, outfile = "DataPaper.html",
                       publish_mode = TRUE, output_dir = "/docs",
                       encoding = "") {
  eml <- xml2::read_xml(file, encoding = encoding)
  style <- xml2::read_xml("../template_emldown/bootstrap.xsl")
  html <- xslt::xml_xslt(eml, style)
  # make map
  map_geographical_coverage(eml)
  xml2::write_html(html, outfile)
  # add custom css
  write_custom_css(publish_mode)
return(outfile)
  if (open == TRUE) {
    browseURL(outfile)

  }

}
