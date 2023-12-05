#' Wrapper function for calculating PPI
#' 
#' @param locs  An sf object of geospatial coordinates (POINTS) or grid cells (POLYGONS).
#' @param buffer A vector of one or more buffer distance(s) that should be in focal mean calculations, expressed in kilometers.
#' @param getgridcalcs logical; do you want to return PPI estimates for the entire grid? 
#' @param dimensions A number specifying the desired dimensions of square grid cells in kilometers; default is 0.5 x 0.5 km.
#' @param bounds If preferred, the grid can be calculated with specific bounds by providing a vector of bounding values here in the format, c(xmin, ymin, xmax, ymax)
#' @param data_directory  Data directory where GHS files should be stored.
#' @param tile_schema_URL url for the shapefile of GHS tile areas
#' @param tile_library_URL url for the GHS library containing individual zipfiles of each raster tile
#' @param study_area_buffer  Extra buffer around the study area to which population density raster should be cropped. Default = 1km.
#' @param progress if TRUE, display a progress bar while running exactextractr::exact_extract()
#' @returns sf objects containing calculated values of PPI for each sites and/or grid cell (depending on the how the argument outputtype is specified).
MarinePPI <- function( locs, 
                       buffer, 
                       getgridcalcs = FALSE, 
                       dimensions = 0.5, 
                       bounds = NULL, 
                       data_directory = "data", 
                       tile_schema_URL = "https://ghsl.jrc.ec.europa.eu/download/GHSL_data_54009_shapefile.zip",
                       tile_library_URL = "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_BUILT_S_GLOBE_R2023A/GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100/V1-0/tiles/",
                       study_area_buffer=1000,
                       progress = FALSE){
  require(sf) 
  require(ggplot2)
  
  # Create grid
  g <- make_grid(
    locs=locs, 
    buffer=buffer, 
    dimensions=dimensions, 
    bounds=bounds)
  
  # Convert to molleweide
  tiles <- get_ghs_tiles(
    study_area=g, 
    data_directory=data_directory, 
    tile_schema_URL=tile_schema_URL, 
    tile_library_URL=tile_library_URL)
  
  # Import and compile into mosaic if 1 or more
  m <- compile_rasters(
    tileIDs=tiles$SelectedTiles$SelectedTiles, 
    study_area=tiles$GridMoll, 
    data_directory=data_directory,
    study_area_buffer=study_area_buffer)
  
  # PPI Calculations
  ppi <- calculate_ppi( 
    locs=locs, 
    buffer=buffer, 
    compiled_raster=m, 
    progress=progress )
  
  
  out <- list( 
    Estimates = list( Sites = ppi, Grid = NULL),
    Specs = list( Grid = list( GridCells = g, Dimensions = dimensions), 
                  Buffers = buffer, 
                  Tiles = tiles, 
                  Raster = m))
  
  if( getgridcalcs == TRUE ){
    out$Estimates$Grid <- calculate_ppi( subset( g, CalculatePPI == 1), buffer, compiled_raster=m, progress=progress)}
  
  return(out)}

