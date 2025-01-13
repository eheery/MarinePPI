#' Identify and access GHS tiles necessary for assembling a single population density raster for the specified study area
#' 
#' @param study_area  Grid generated for study area
#' @param data_directory  Directory where GHS raster files have been downloaded and unzipped
#' @param tile_schema_URL url for the shapefile of GHS tile areas
#' @param tile_library_URL url for the GHS library containing individual zipfiles of each raster tile
#' @return sf POLYGON object of tile areas
#' @export
get_ghs_tiles <- function(study_area, 
                          data_directory = "downloads", 
                          tile_schema_URL = "https://ghsl.jrc.ec.europa.eu/download/GHSL_data_54009_shapefile.zip",
                          tile_library_URL = "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_BUILT_S_GLOBE_R2023A/GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100/V1-0/tiles/"){
  # Import tile schema (downloading and unzipping from GHS website if necessary)
  fls <- list.files(paste( getwd(), data_directory, sep = "/"))
  if(length(which( endsWith( fls, "shp") & (stringr::str_detect( fls, "tile_schema")) )) == 0){
    print(paste0("Downloading and unzipping shapefile from ", tile_schema_URL))
    temp <- tempfile()
    utils::download.file(tile_schema_URL,temp)
    utils::unzip( temp, exdir = paste( getwd(), data_directory, sep = "/") )
    unlink(temp) 
    fls <- list.files(paste( getwd(), data_directory, sep = "/"))
    tile_schema_filename <- fls[which( endsWith( fls, "shp") & (stringr::str_detect( fls, "tile_schema")) )]
    if(length(tile_schema_filename) > 1) stop("More than one tile schema in data folder")
    if(length(tile_schema_filename) == 0) stop(".shp file for tile schema not found")
  }else{
    tile_schema_filename <- fls[which( endsWith( fls, "shp") & (stringr::str_detect( fls, "tile_schema")) )] }
  tile_schema <- sf::st_read( paste( getwd(), data_directory, tile_schema_filename, sep = "/"),quiet=TRUE)
 
  # Convert to mollweide
  g_moll <- sf::st_transform( study_area, crs = sf::st_crs(tile_schema))
  
  # Filter out intersecting tiles
  tl <- sf::st_filter( tile_schema , g_moll, .predicate = sf::st_intersects)
  if(nrow(tl) == 0){stop("Grid does not overlap with any tiles. Check grid geometry.")}
  fls <- list.files(paste( getwd(), data_directory, sep = "/"))
  tl_report <- data.frame( 
    SelectedTiles = tl$tile_id,
    AlreadyAccessed = sapply( tl$tile_id, function(x){ any( endsWith(fls, paste0(x, ".tif"  )) )}) )
  
  # Download any tiles not previously accessed
  if(any(tl_report[['AlreadyAccessed']] == FALSE)){
    id <- with(tl_report[which(tl_report[['AlreadyAccessed']] == FALSE ),], SelectedTiles)
    download_ghs_tiles(tileIDs=id, data_directory = data_directory, URL = tile_library_URL) }
  fls <- list.files(paste( getwd(), data_directory, sep = "/"))
  tl_report$Filename = sapply( tl_report$SelectedTiles, function(x){ fls[endsWith( fls, paste0(x, ".tif"  ) )] })
  accesseddatetime <- sapply( tl_report$Filename, function(x){ 
    as.character(file.info(paste( getwd(), data_directory, x, sep = "/"))$ctime) })
  tl_report$AccessedAtDate = as.Date( substr( as.character(accesseddatetime), 1, 10), "%Y-%m-%d")
  tl_report$AccessedAtTime = sapply(  accesseddatetime, function(x){ substr( as.character(x), 12, nchar(x)) })
  
  out <- list(SelectedTiles = tl_report, TileSchema = tile_schema, GridMoll = g_moll)
  
  return(out)}
  