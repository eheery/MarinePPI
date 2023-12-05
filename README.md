MarinePPI
================

MarinePPI calculates the Population Proximity Index (PPI) for marine
sites using the approach from [Feist and Levin
2016](https://www.frontiersin.org/articles/10.3389/fmars.2016.00113/full).
PPI estimates are calculated from global estimates of population density
that are available from the [Global Human Settlement Layer (GHSL)
project](https://ghsl.jrc.ec.europa.eu/) (European Commission, Joint
Research Center and Directorate-General for Regional and Urban Policy).

## Installation

## Requirements

R packages:

- [sf](https://r-spatial.github.io/sf/index.html)
- [sp](https://cran.r-project.org/web/packages/sp/index.html)
- [raster](https://rspatial.org/raster/pkg/index.html)
- [terra](https://cran.r-project.org/web/packages/terra/index.html)
- [exactextractr](https://github.com/isciences/exactextractr)
- [ggspatial](https://cran.r-project.org/web/packages/ggspatial/index.html)

To run MarinePPI, you will need:

- A viable **internet connection** so that MarinePPI subroutines can
  download rasters and shapefiles from GHSL,
- A data frame of **geospatial coordinates** specifying the marine site
  locations, and;
- To specify **buffer distance(s)** for PPI calculations. This is the
  radius that will be used for focal means and should be specified in
  kilometers (km).

## Example

This example shows how to run MarinePPI for 22 survey sites from Heery
et al. (in preparation: *A standardized approach for quantifying
urban-related losses in habitat-forming macroalgae and marine biogenic
complexity*) using 5 buffer distances: 1, 2, 5, 10, and 20 km.

#### Geospatial coordinates

The csv of geospatial coordinates for this example is available
[here](https://github.com/eheery/MarinePPI/blob/main/data/example_locations.csv).
We import it into R and convert it to an [sf
POINTS](https://r-spatial.github.io/sf/articles/sf1.html) object as
follows:

``` r
# Import data frame
sites_df <- read.csv( here::here( 'data','example_locations.csv'), header = TRUE)

# Convert to sf object
sites <- st_as_sf(sites_df, coords = c("Lon_dd", "Lat_dd"), crs = 4326)
sites
```

    ## Simple feature collection with 22 features and 1 field
    ## Geometry type: POINT
    ## Dimension:     XY
    ## Bounding box:  xmin: -122.6754 ymin: 47.26065 xmax: -122.3051 ymax: 48.00288
    ## Geodetic CRS:  WGS 84
    ## First 10 features:
    ##                         Location                   geometry
    ## 1              Alki Fishing Reef POINT (-122.4085 47.55783)
    ## 2                  Alki Pipeline    POINT (-122.4163 47.57)
    ## 3        Blake Island Breakwater POINT (-122.4814 47.54297)
    ## 4                   Boeing Creek POINT (-122.3858 47.75112)
    ## 5                Centennial Park POINT (-122.3775 47.62614)
    ## 6   Des Moines Marina Breakwater  POINT (-122.3316 47.3988)
    ## 7                     Don Armeni POINT (-122.3826 47.59392)
    ## 8      Edmonds Marina Breakwater POINT (-122.3929 47.80869)
    ## 9  Elliott Bay Marina Breakwater POINT (-122.3949 47.62745)
    ## 10                 Gedney Island POINT (-122.3051 48.00288)

#### Buffer distances

We can specify our buffer distances as a single value or a vector of
values. This are the radius distance over which R will compute
population density focal means. They should be specified in kilometers
(km):

``` r
# Buffer distances in km
B <- c(1, 2, 5, 10, 20)
B
```

    ## [1]  1  2  5 10 20

#### Calculating PPI for a set of coordinates

The MarinePPI function is specified as follows:

``` r
PPI <- MarinePPI( locs = sites, buffer = B )
```

    ## Loading required package: raster

    ## Loading required package: sp

    ## 
    ## Attaching package: 'raster'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     select

    ## Loading required package: terra

    ## terra 1.7.18

    ## 
    ## Attaching package: 'terra'

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

    ## Loading required package: exactextractr

    ## [1] "Calculating PPI for 22 points"
    ## [1] "... 1km buffer"
    ## [1] "... 2km buffer"
    ## [1] "... 5km buffer"
    ## [1] "... 10km buffer"
    ## [1] "... 20km buffer"

The function returns two lists, Estimates and Specs.

The first item in the Estimates list is an sf POINTS object called
**Sites** containing our geospatial coordinates with PPI estimates for
each buffer distance stored in separate columns:

``` r
PPI$Estimates$Sites
```

    ## Simple feature collection with 22 features and 6 fields
    ## Geometry type: POINT
    ## Dimension:     XY
    ## Bounding box:  xmin: -122.6754 ymin: 47.26065 xmax: -122.3051 ymax: 48.00288
    ## Geodetic CRS:  WGS 84
    ## First 10 features:
    ##                         Location                   geometry    PPI-1km
    ## 1              Alki Fishing Reef POINT (-122.4085 47.55783)  613.89594
    ## 2                  Alki Pipeline    POINT (-122.4163 47.57)  737.19629
    ## 3        Blake Island Breakwater POINT (-122.4814 47.54297)   10.98671
    ## 4                   Boeing Creek POINT (-122.3858 47.75112)  206.05341
    ## 5                Centennial Park POINT (-122.3775 47.62614) 1132.24780
    ## 6   Des Moines Marina Breakwater  POINT (-122.3316 47.3988) 1060.34363
    ## 7                     Don Armeni POINT (-122.3826 47.59392)  279.19016
    ## 8      Edmonds Marina Breakwater POINT (-122.3929 47.80869) 1004.32434
    ## 9  Elliott Bay Marina Breakwater POINT (-122.3949 47.62745)  477.75131
    ## 10                 Gedney Island POINT (-122.3051 48.00288)   60.24902
    ##        PPI-2km    PPI-5km  PPI-10km PPI-20km
    ## 1  1021.740173 1033.88647  982.6188 935.0135
    ## 2   977.063354  930.12964  941.3745 923.7169
    ## 3     2.815145  119.02279  673.6862 806.5791
    ## 4   401.273163  998.79108  940.3234 884.7988
    ## 5  1557.774536 1437.56421 1104.5277 930.3113
    ## 6  1074.698608  900.65320  974.2508 849.7846
    ## 7   831.799438 1029.52856 1105.1189 948.6052
    ## 8   941.231567  916.02325  840.2173 754.1924
    ## 9   548.861328 1076.23157 1084.1317 920.2118
    ## 10   43.289448   91.68916  546.8644 696.4127

If we had run MarinePPI with the argument getgridcalcs set to TRUE,
there would be a second sf POLYGONS object called Grid in the Estimates
list containing PPI estimates for each grid cell (see below:
*Calculating PPI for the broader study area*).

The Specs list contains additional information we might want to recount
or access regarding the PPI calculations. This includes:

- **Grid**: A list of (1) GridCells - the sf POLYGONS object of grid
  cells used in focal mean calculations; and (2) Dimensions - the
  dimensions of grid cells in km

``` r
PPI$Specs$Grid
```

    ## $GridCells
    ## Simple feature collection with 9912 features and 1 field
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -122.6847 ymin: 47.25584 xmax: -122.2942 ymax: 48.01044
    ## Geodetic CRS:  WGS 84
    ## First 10 features:
    ##                         gridcells CalculatePPI
    ## 1  POLYGON ((-122.6847 47.2558...            0
    ## 2  POLYGON ((-122.678 47.25584...            0
    ## 3  POLYGON ((-122.6714 47.2558...            0
    ## 4  POLYGON ((-122.6648 47.2558...            0
    ## 5  POLYGON ((-122.6582 47.2558...            0
    ## 6  POLYGON ((-122.6516 47.2558...            0
    ## 7  POLYGON ((-122.645 47.25584...            0
    ## 8  POLYGON ((-122.6383 47.2558...            0
    ## 9  POLYGON ((-122.6317 47.2558...            0
    ## 10 POLYGON ((-122.6251 47.2558...            0
    ## 
    ## $Dimensions
    ## [1] 0.5

- **Buffers**: the buffer distances used (vector provided as original
  input to the *buffer* argument)

``` r
PPI$Specs$Grid
```

    ## $GridCells
    ## Simple feature collection with 9912 features and 1 field
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -122.6847 ymin: 47.25584 xmax: -122.2942 ymax: 48.01044
    ## Geodetic CRS:  WGS 84
    ## First 10 features:
    ##                         gridcells CalculatePPI
    ## 1  POLYGON ((-122.6847 47.2558...            0
    ## 2  POLYGON ((-122.678 47.25584...            0
    ## 3  POLYGON ((-122.6714 47.2558...            0
    ## 4  POLYGON ((-122.6648 47.2558...            0
    ## 5  POLYGON ((-122.6582 47.2558...            0
    ## 6  POLYGON ((-122.6516 47.2558...            0
    ## 7  POLYGON ((-122.645 47.25584...            0
    ## 8  POLYGON ((-122.6383 47.2558...            0
    ## 9  POLYGON ((-122.6317 47.2558...            0
    ## 10 POLYGON ((-122.6251 47.2558...            0
    ## 
    ## $Dimensions
    ## [1] 0.5

- **Tiles**: info about GHS raster tiles that were compiled to generate
  the population density raster layer for the study area of interest.
  This includes 3 objects: (1) SelectedTiles - a data frame showing
  which tiles were selected, (2) TileSchema - an sf POLYGONS object of
  all GHS tiles for the globe, and (3) GridMoll - the grid in Molleweide
  projection)

``` r
PPI$Specs$Tiles
```

    ## $SelectedTiles
    ##       SelectedTiles AlreadyAccessed
    ## R4_C9         R4_C9            TRUE
    ##                                                      Filename AccessedAtDate
    ## R4_C9 GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_R4_C9.tif     2023-12-04
    ##       AccessedAtTime
    ## R4_C9       03:34:41
    ## 
    ## $TileSchema
    ## Simple feature collection with 375 features and 5 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -18041000 ymin: -9e+06 xmax: 18041000 ymax: 9e+06
    ## Projected CRS: World_Mollweide
    ## First 10 features:
    ##    tile_id      left top     right bottom                       geometry
    ## 1  R10_C10  -9041000   0  -8041000 -1e+06 POLYGON ((-9041000 0, -8041...
    ## 2  R10_C11  -8041000   0  -7041000 -1e+06 POLYGON ((-8041000 0, -7041...
    ## 3  R10_C12  -7041000   0  -6041000 -1e+06 POLYGON ((-7041000 0, -6041...
    ## 4  R10_C13  -6041000   0  -5041000 -1e+06 POLYGON ((-6041000 0, -5041...
    ## 5  R10_C14  -5041000   0  -4041000 -1e+06 POLYGON ((-5041000 0, -4041...
    ## 6  R10_C15  -4041000   0  -3041000 -1e+06 POLYGON ((-4041000 0, -3041...
    ## 7  R10_C17  -2041000   0  -1041000 -1e+06 POLYGON ((-2041000 0, -1041...
    ## 8  R10_C19    -41000   0    959000 -1e+06 POLYGON ((-41000 0, 959000 ...
    ## 9   R10_C1 -18041000   0 -17041000 -1e+06 POLYGON ((-18041000 0, -170...
    ## 10 R10_C20    959000   0   1959000 -1e+06 POLYGON ((959000 0, 1959000...
    ## 
    ## $GridMoll
    ## Simple feature collection with 9912 features and 1 field
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -9657291 ymin: 5583145 xmax: -9539426 ymax: 5663559
    ## Projected CRS: World_Mollweide
    ## First 10 features:
    ##                         gridcells CalculatePPI
    ## 1  POLYGON ((-9657291 5583145,...            0
    ## 2  POLYGON ((-9656770 5583145,...            0
    ## 3  POLYGON ((-9656249 5583145,...            0
    ## 4  POLYGON ((-9655728 5583145,...            0
    ## 5  POLYGON ((-9655207 5583145,...            0
    ## 6  POLYGON ((-9654686 5583145,...            0
    ## 7  POLYGON ((-9654165 5583145,...            0
    ## 8  POLYGON ((-9653644 5583145,...            0
    ## 9  POLYGON ((-9653123 5583145,...            0
    ## 10 POLYGON ((-9652602 5583145,...            0

- **Raster**: The final compiled population density raster for our study
  area

``` r
PPI$Specs$Raster
```

    ## class       : SpatRaster 
    ## dimensions  : 825, 1199, 1  (nrow, ncol, nlyr)
    ## resolution  : 100, 100  (x, y)
    ## extent      : -9658300, -9538400, 5582100, 5664600  (xmin, xmax, ymin, ymax)
    ## coord. ref. : World_Mollweide 
    ## source(s)   : memory
    ## name        : GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_R4_C9 
    ## min value   :                                                   0 
    ## max value   :                                               10000

#### Calculating PPI for the broader study area

Sometimes we may be more interested in the gradient pattern of PPI
across a larger study area than we are for a specific set of survey
sites. In this case, specify the *getgridcalcs* in *MarinePPI* as TRUE:

``` r
PPI <- MarinePPI( locs = sites, buffer = c(5, 20), getgridcalcs=TRUE )
```

    ## [1] "Calculating PPI for 22 points"
    ## [1] "... 5km buffer"
    ## [1] "... 20km buffer"
    ## [1] "Calculating PPI for 9462 polygons"
    ## [1] "... 5km buffer"
    ## [1] "... 20km buffer"

In this round, the function calculated PPI estimates twice for each
buffer distance - the first time for our geospatial coordinates, and the
second time for each polygon in the grid overlaying our study area. The
latter are now visible by calling the second element in the Estimates
list, Grid:

``` r
PPI$Estimates$Grid
```

    ## Simple feature collection with 9462 features and 3 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -122.678 ymin: 47.26033 xmax: -122.3008 ymax: 48.00595
    ## Geodetic CRS:  WGS 84
    ## First 10 features:
    ##                         gridcells CalculatePPI  PPI-5km PPI-20km
    ## 61 POLYGON ((-122.678 47.26033...            1 161.3455 478.4637
    ## 62 POLYGON ((-122.6714 47.2603...            1 169.8639 480.9441
    ## 63 POLYGON ((-122.6648 47.2603...            1 193.1722 484.0063
    ## 64 POLYGON ((-122.6582 47.2603...            1 215.2496 487.5446
    ## 65 POLYGON ((-122.6516 47.2603...            1 231.0710 487.1612
    ## 66 POLYGON ((-122.645 47.26033...            1 247.5596 489.6198
    ## 67 POLYGON ((-122.6383 47.2603...            1 279.9511 495.3346
    ## 68 POLYGON ((-122.6317 47.2603...            1 315.2872 497.2146
    ## 69 POLYGON ((-122.6251 47.2603...            1 352.7644 498.6447
    ## 70 POLYGON ((-122.6185 47.2603...            1 395.8501 500.6723

## Visualization

To visualize our results, it’s helpful to have high resolution layers of
surrounding land masses. One option is to download the [Global
Self-consistent, Hierarchical, High-resolution Geography Database
(GSHHG)](https://www.ngdc.noaa.gov/mgg/shorelines/) from NOAA. I have
included high and full resolution GSHHG (v2.3.7) shapefiles for
land-ocean boundaries (L1) in the data folder for this example.

``` r
# Import GSHHS Shapefile
shoreline <- st_read( here::here("notebook", "GSHHS_f_L1.shp") )
```

    ## Reading layer `GSHHS_f_L1' from data source 
    ##   `C:\Users\Eliza\OneDrive\Projects\GitHub\MarinePPI\notebook\GSHHS_f_L1.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 179837 features and 6 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -180 ymin: -68.92453 xmax: 180 ymax: 83.63339
    ## Geodetic CRS:  WGS 84

``` r
# Convert to Mollweide
shoreline_moll <- st_transform(shoreline, crs = "ESRI:54009")

# Get land polygons in Mollweide
land_moll <- st_intersection( st_union(st_geometry( PPI$Specs$Tiles$GridMoll)), shoreline_moll)

# Convert to WGS 84
land <- st_transform( land_moll, crs ="EPSG:4326")

# Save cropped shapefile
st_write( land, here::here("data", "example_cropped_gshhg.shp"))
```

    ## Writing layer `example_cropped_gshhg' to data source 
    ##   `C:/Users/Eliza/OneDrive/Projects/GitHub/MarinePPI/data/example_cropped_gshhg.shp' using driver `ESRI Shapefile'
    ## Writing 9 features with 0 fields and geometry type Unknown (any).

``` r
gridbb <- st_bbox(PPI$Estimates$Grid)
shrink <- c( diff(gridbb[c(1,3)])*0.1, diff(gridbb[c(2,4)])*0.1)
study_area_map <- ggplot() +
  geom_sf(data = PPI$Estimates$Grid, aes(fill = `PPI-5km`), color = NA) +
  geom_sf(data = land, color = NA ) +
  coord_sf(xlim = st_bbox(PPI$Estimates$Grid)[c(1,3)],ylim = st_bbox(PPI$Estimates$Grid)[c(2,4)]) +
  ggspatial::annotation_north_arrow(
    which_north = "true", 
    location = 'bl', 
    pad_x=unit(0.5,'cm'),pad_y=unit(1.5,'cm'),
    height = unit(0.5, "cm"),width = unit(0.5, "cm")) +
  ggspatial::annotation_scale(
    location = 'br', 
    pad_x=unit(0.75,'cm'),pad_y=unit(0.75,'cm')) +
  scale_fill_viridis_c(begin = 0.3) + 
  theme_classic() +
  theme(legend.position = 'left')
```

![](README_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->
