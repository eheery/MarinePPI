#' Import raster tiles for the study area of interest and (if more than one) assemble into a single, mosaiced spatial data layer.
#' 
#' @param tileIDs vector of tile_ids for selected GHS raster tiles
#' @param study_area  sf object of the study area grid in Molleweide projection to match the coordinate reference system of raster tiles
#' @param data_directory  Directory where GHS raster files have been downloaded and unzipped
#' @param study_area_buffer  Extra buffer around the study area to which population density raster should be cropped. Default = 1km.
#' @return A raster layer of population densities.
#' @export
compile_rasters <- function(tileIDs, study_area, data_directory = "downloads", study_area_buffer = 1000){

  tif_files <- list.files(paste(getwd(), data_directory, sep = "/"))
  tif_files <- tif_files[endsWith(tif_files, ".tif")]
  selected_tifs <- tif_files[stringr::str_detect(tif_files, tileIDs)]
  tifs <- lapply( selected_tifs, function(i){ terra::rast(paste(getwd(), data_directory, i, sep = "/")) })

  if( length( tifs ) > 1){
    ghs_pop_mosaic <- tifs[[1]]
    print(paste0( "raster 1 added - ", Sys.time()))
    for(i in 2:length(tifs)){
      ghs_pop_mosaic <- terra::mosaic(ghs_pop_mosaic, tifs[[i]], fun = 'mean')
      print(paste0( "raster ", i, " added - ", Sys.time()))}
    r <- ghs_pop_mosaic
  }else{
    r <- tifs[[1]]}
  
  out <- raster::crop( r, raster::extent( sf::st_bbox( sf::st_buffer( study_area, dist = study_area_buffer) ) ) )

  return(out)}
