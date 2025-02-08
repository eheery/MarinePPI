MarinePPI
================
Eliza Heery

<!-- badges: start -->
<!-- badges: end -->

The *MarinePPI* package provides a series of R functions that allow you
to calculate the Population Proximity Index (PPI) of marine sites, as
outlined in Heery et al. (in review): *A standardized approach for
quantifying urban-related losses in habitat-forming macroalgae and
marine biogenic complexity*).

## Installation

You can install the development version of MarinePPI like so:

``` r
devtools::install_github("eheery/MarinePPI")
#> Using GitHub PAT from the git credential store.
#> Skipping install of 'MarinePPI' from a github remote, the SHA1 (6ebb7188) has not changed since last install.
#>   Use `force = TRUE` to force installation
```

## Example

``` r
library(MarinePPI)
library(sf)
#> Linking to GEOS 3.12.2, GDAL 3.9.3, PROJ 9.4.1; sf_use_s2() is TRUE
```

As an example, we start with a data frame of geospatial coordinates and
site names for 22 marine locations in Puget Sound, Washington.
Coordinates are in decimal degrees.

Whether using these locations or a different set of sites, the first
step is to convert the data frame of site coordinates to an sf object,
specifying the correct Coordinate Reference System (crs). We use the
EPSG code 4326 for WGS84, which is used in GPS, but your code may need
to be different if your coordinates use a different coordinate reference
system, such as NAD83 (EPSG:4269), which is commonly used by US federal
agencies (see this [useful
guide](https://www.nceas.ucsb.edu/sites/default/files/2020-04/OverviewCoordinateReferenceSystems.pdf)
to learn more about coordinate reference systems in R):

``` r
data("PugetSoundSites")

# Convert to sf object
sites <- st_as_sf(PugetSoundSites, coords = c("Lon_dd", "Lat_dd"), crs = 4326)
sites
#> Simple feature collection with 22 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -122.6754 ymin: 47.26065 xmax: -122.3051 ymax: 48.00288
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>                         Location                   geometry
#> 1              Alki Fishing Reef POINT (-122.4085 47.55783)
#> 2                  Alki Pipeline    POINT (-122.4163 47.57)
#> 3        Blake Island Breakwater POINT (-122.4814 47.54297)
#> 4                   Boeing Creek POINT (-122.3858 47.75112)
#> 5                Centennial Park POINT (-122.3775 47.62614)
#> 6   Des Moines Marina Breakwater  POINT (-122.3316 47.3988)
#> 7                     Don Armeni POINT (-122.3826 47.59392)
#> 8      Edmonds Marina Breakwater POINT (-122.3929 47.80869)
#> 9  Elliott Bay Marina Breakwater POINT (-122.3949 47.62745)
#> 10                 Gedney Island POINT (-122.3051 48.00288)
```

#### Specify buffer distance

Next, we specify the buffer distance(s) that we want to use for focal
mean calculations in kilometers. This can be either a single number or a
vector of numbers. Here, we use an example of 10 km:

``` r
# Specify buffer (in km)
b <- 10
```

#### Create Grid of Study Area

We then create a grid of empty cells overlaying our study sites. The
function *make_grid()* does this for us. By default, grid cell
dimensions are set to 0.5 km, but you can change this with the
*dimensions* argument if desired. The total grid area is set based on
the buffer distance(s) we specified above, though you can make this area
larger if desired by specifying bounds manually using the *bounds*
argument and providing a vector of values (e.g. c(xmin, ymin, xmax,
ymax)):

``` r
# Create grid overlaying study area
g <- make_grid( locs = sites, buffer = b )
g
#> Simple feature collection with 9912 features and 1 field
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -122.6847 ymin: 47.25584 xmax: -122.2942 ymax: 48.01044
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>                         gridcells CalculatePPI
#> 1  POLYGON ((-122.6847 47.2558...            0
#> 2  POLYGON ((-122.678 47.25584...            0
#> 3  POLYGON ((-122.6714 47.2558...            0
#> 4  POLYGON ((-122.6648 47.2558...            0
#> 5  POLYGON ((-122.6582 47.2558...            0
#> 6  POLYGON ((-122.6516 47.2558...            0
#> 7  POLYGON ((-122.645 47.25584...            0
#> 8  POLYGON ((-122.6383 47.2558...            0
#> 9  POLYGON ((-122.6317 47.2558...            0
#> 10 POLYGON ((-122.6251 47.2558...            0
```

#### Prepare Population Density Layer

Next, we download raster data of population density from the Global
Human Settlement Layer project (GHSL; <https://ghsl.jrc.ec.europa.eu/>)
for our study area. Raster data are available for the entire globe but
are broken into tiles to make downloading more efficient. We use a
series of functions to identify which tiles overlap with our grid area,
download them, and then stitch them together.

Before starting this process, specify a directory location where the
downloads will be saved (these are large files!).

``` r
# Specify download directory
download.directory <- here::here("data", "downloads")
```

Use the *get_ghs_tiles()* function to identify and download the GHS
tiles that overlay the grid area:

``` r
# Download GHS tiles
tiles <- get_ghs_tiles( study_area = g, data_directory = download.directory)
#> [1] "Downloading and unzipping shapefile from https://ghsl.jrc.ec.europa.eu/download/GHSL_data_54009_shapefile.zip"
```

Then, use the *compile_rasters()* function to compile the downloaded
raster files into a single mosaic layer of population density:

``` r
# Import and compile into mosaic if 1 or more
m <- compile_rasters(
  tileIDs = tiles$tl_report$SelectedTiles, 
  study_area = tiles$GridMoll, 
  data_directory = download.directory)
```

Finally, compute PPI as the focal mean of population density around each
site (as outlined in [Feist and Levin
2016](https://www.frontiersin.org/articles/10.3389/fmars.2016.00113/full)):

``` r
# Calculate PPI for study sites
ppi <- calculate_ppi( locs = sites, buffer = b, compiled_raster = m )
#> [1] "Calculating PPI for 22 points"
#> [1] "... 10km buffer"
```

#### Calculating PPI for the broader study area

Sometimes we may be more interested in the gradient pattern of PPI
across a larger study area than we are for a specific set of survey
sites. To do this we can calculate a PPI value for grid cells in the
population raster. This can take a long time, particularly if your
compiled raster object (m) includes a mosaic of more than one tile. In
this case, you may want to modify *m* to a lower resolution before
sending it to *calculate_ppi* (for instance, using *raster::aggregate(m,
fact=10)*).

``` r
# Get PPI gradient
ppi_gradient <- calculate_ppi( locs = g, buffer = b, compiled_raster=m, progress = TRUE)
#> [1] "Calculating PPI for 9912 polygons"
#> [1] "... 10km buffer"
#>   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |=======                                                               |  11%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |================                                                      |  24%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |=====================                                                 |  31%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |=======================                                               |  34%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |============================                                          |  41%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |=================================                                     |  48%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |===================================                                   |  51%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |=====================================                                 |  54%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |==========================================                            |  61%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |============================================                          |  64%  |                                                                              |=============================================                         |  64%  |                                                                              |=============================================                         |  65%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |=================================================                     |  71%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |========================================================              |  81%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |==========================================================            |  84%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |===============================================================       |  91%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |=================================================================     |  94%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%
```

## Visualization

To visualize our results, it’s helpful to have high resolution layers of
surrounding land masses. One option is to download the [Global
Self-consistent, Hierarchical, High-resolution Geography Database
(GSHHG)](https://www.ngdc.noaa.gov/mgg/shorelines/) from NOAA. For the
purposes of this example, I’m using the sf object generated by the
*giscoR* function, *gisco_get_coastallines()*:

``` r
coast_sf <- giscoR::gisco_get_coastallines(resolution  = "1") 
```

We transform it to the same coordinate reference system as the raster
files (Mollweide):

``` r
coast_moll <- st_transform(coast_sf, crs = "ESRI:54009")
```

Then we use the *sf::st_intersection()* function to find the area where
the coast_moll sf object and our Mollweide grid (an output from the
*get_ghs_tiles()* function) object overlap:

``` r
land_moll <- st_intersection( st_union(st_geometry( tiles$GridMoll )), coast_moll)
```

We convert to the coordinate reference system of our original sites
file:

``` r
land_sf <- st_transform( land_moll, crs = st_crs(sites))
```

We can then include this in our map of plotted PPI values:

``` r
library(ggplot2)
library(ggspatial)

study_area_map <- ggplot() +
  geom_sf(data = ppi_gradient, aes(fill = `PPI-10km`), color = NA) +
  geom_sf(data = st_crop( land_sf, st_bbox(g)), color = NA ) +
  coord_sf(xlim = st_bbox(ppi_gradient)[c(1,3)],ylim = st_bbox(ppi_gradient)[c(2,4)]) +
  annotation_north_arrow(which_north = "true", location = 'br', pad_x=unit(0.75,'cm'),pad_y=unit(1.75,'cm'),height = unit(1, "cm"),width = unit(1, "cm")) +
  annotation_scale(location = 'br', pad_x=unit(0.75,'cm'),pad_y=unit(1,'cm')) +
  scale_fill_viridis_c(begin = 0.3) + 
  theme_classic() +
  scale_x_continuous(breaks = c(-122.6, -122.5, -122.4, -122.3)) +
  theme(legend.position = 'top') 
```

    #> png 
    #>   2

![](README_files/figure-gfm/unnamed-chunk-18-1.png)<!-- -->
