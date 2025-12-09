# MarinePPI

`MarinePPI` is an R package for calculating Population Pressure Index
(PPI) for marine field sites using global built-up area data (e.g.,
GHSL). It supports efficient, tile-aware raster handling and site-level
summaries with customizable buffers.

## Installation

Install the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("eheery/MarinePPI")
```

Next, load the package into your R workspace:

``` r
library(MarinePPI)
```

#### Specify the directory for raster downloads

The MarinePPI workflow involves downloading raster data of population
density from the Global Human Settlement Layer (GHSL;
<https://ghsl.jrc.ec.europa.eu/>) for our study area. Although GHSL
covers the entire globe, it is distributed in individual raster tiles to
make downloading and processing more efficient.

To manage these tiles and streamline the PPI calculations, MarinePPI
requires a dedicated raster directory. This directory serves multiple
purposes:

- Stores downloaded tiles from GHSL so they are only downloaded once.
- Caches mosaicked rasters (stitched together from multiple tiles) for
  locations that span tile boundaries.
- Maintains a consistent file structure that our functions rely on to
  find, reuse, and write raster data efficiently.

The directory should contain two subfolders (if these don’t already
exist, they will be created for you automatically as you use functions
in MarinePPI):

- downloads/ – where raw GHSL tiles are saved.
- mosaics/ – where multi-tile mosaicked rasters are stored after
  stitching.

You can point to any folder on your computer to serve as this raster
directory. Just ensure the directory exists and that you have write
access.

``` r
# Specify raster directory on your computer
raster_directory <- "your raster directory filepath"
```

## Specifications

The MarinePPI workflow uses a series of functions to identify which GHSL
raster files overlap with the input coordinates, download any missing
raster files into the downloads/ folder, and automatically mosaic
multiple tiles into a single file (if needed), saved in the mosaics/
folder. You can reuse these files across sessions to reduce redundant
computation and downloads.

#### Field Site Locations

First, we need create a data frame of geospatial coordinates ***in
decimal degrees*** for our field sites. As an example, the sample
dataset, *PugetSoundSites*, includes 22 field locations in the Salish
Sea. (*Note*: By default, MarinePPI functions assume that lon/lat values
use the Coordinate Reference System, WGS84, which is used in GPS. If
your coordinates use a different coordinate reference system, such as
NAD83 (EPSG:4269), which is commonly used by US federal agencies (see
this [useful
guide](https://www.nceas.ucsb.edu/sites/default/files/2020-04/OverviewCoordinateReferenceSystems.pdf),
you will need to specify this in the \`locations_crs\` argument of the
*get_tile_list()* function below).

``` r
# Load sample data set
data("PugetSoundSites")
```

#### Buffer Distances

Next, we specify the buffer distances we wish to use for PPI
calculations. These values will be used to specify the focal mean radii
and should be provided **in kilometers**. Buffer distances can be
provided either as a single value or as a vector of values, each in
kilometers. Here, we use an example of 5 buffer distances between 1 km
and 20 km:

``` r
# Specify radii for PPI calculations IN KILOMETERS
b <- c(1, 2, 5, 10, 20)
```

#### Tile Schema

Lastly, we need to access the shapefile of GHSL raster tile areas to
discern which tiles overlap with our field sites and buffer distances.
We do this using teh *get_tile_schema()* function:

``` r
schema <- get_tile_schema(data_directory = raster_directory)
```

## Calculate PPI values

Now we have all of the details needed to calculate Population Proximity
Indices (PPI) for our field sites. The *calculate_ppi_chunked()*
function identifies, downloads (if missing), and stitches together the
population density raster layer for our respective study area. It then
calculates PPI values in chunks (separately for each of the unique
combination of raster tiles associated with our respective field sites
and maximum buffer distance. It returns an *sf* points file

``` r
ppi_estimates <- calculate_ppi_chunked(
  locations = PugetSoundSites,
  longitude_col = "Lon_dd",
  latitude_col = "Lat_dd",
  tile_schema = schema,
  data_directory = raster_directory,
  buffers_km = b,       # you can adjust this to any buffer distances
  progress = TRUE                  # shows progress bars
)
```

#### Sites that span multiple tiles

In the example above, all of the sites in *PugetSoundSites* happen to
fall within a single GHSL raster tile area (as indicated in the tile
column of our output). If your sites span multiple GHSL rastser tile
areas, *calculate_ppi_chunked()* will mosaic tiles together as needed
and save them as new rasters in the mosaics/ folder in your raster
directory. Here’s an example using coordinates from the coast of Eastern
Australia:

``` r
# Study area as defined by coordinates in eastern Australia
data("EasternAustraliaSites")

ppi_estimates2 <- calculate_ppi_chunked(
  locations = EasternAustraliaSites,
  longitude_col = "Longitude",
  latitude_col = "Latitude",
  tile_schema = schema,
  data_directory = raster_directory,
  buffers_km = b,       # you can adjust this to any buffer distances
  progress = TRUE                  # shows progress bars
)
```

#### Visualizing PPI Gradients

In some cases, we may be more interested in visualizing gradients in
population proximity across seascapes rather than in deriving PPI values
for specific field sites. The *generate_ppi_grid()* function calculates
population proximity estimates for a grid of cells for a given area and
resolution. In the example below, we estimate PPI within a 20 km buffer
distance for each cell in a 5 x 5 km grid for the Salish Sea bioregion.
Land polygons from the *ne_coutnries()* function in the rnaturalearth
package are specified in the land_polygon function in order to cut down
on computation time (when land_polygons != NULL, PPI calculations are
skipped for grid cells that overlap completely with land).

``` r
library(ggplot2)

# Set bounds 
salish_sea_region <- list(
  lon = c(-125.93, -120.65),
  lat = c(46.59, 50.86)
)

# Land polygons
land <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf")

# Compute PPI gradient
ppi_gradient <- generate_ppi_grid(
  lon = salish_sea_region$lon,
  lat = salish_sea_region$lat,
  buffers_km = 20, # 20 km buffer radius for PPI calculations
  tile_schema = schema,
  data_directory = raster_directory,
  land_polygons = land,
  grid_resolution_km = 5) # 5 km x 5 km grid cells

# Visualize
ggplot() + 
  geom_sf(data = ppi_gradient$PPI, aes(fill = PPI20km), color = NA) +
  geom_sf(data = ppi_gradient$Land ) +
  theme_minimal()
```

The rudamentary map shown here is provided for visualizing purposes
only. For more advanced mapping, one can save the spatial data layer
generated from *generate_ppi_grid()* as a shapefile (using the *sf*
function *st_write()*).

![Fig. 1 Visualization of PPI gradient computed for the Salish Sea
region. Code for generating the figure is shown above, using a 20km
buffer radius for 5 km resolution for grid
cells.](reference/figures/salish_sea_map.png)

Fig. 1 Visualization of PPI gradient computed for the Salish Sea region.
Code for generating the figure is shown above, using a 20km buffer
radius for 5 km resolution for grid cells.

# Contributing

We welcome contributions! Please open issues or submit pull requests.

# License

This package is licensed under the MIT License.
