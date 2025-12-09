# Calculate PPI for a set of sites or grid cells given one or more buffer distances

This function computes the focal mean of population density within one
or more buffer distances around a set of input locations or polygons,
using the exactextractr package for accurate spatial summaries.

## Usage

``` r
calculate_ppi(locs, buffer, compiled_raster, progress = FALSE)
```

## Arguments

- locs:

  An `sf` object of geospatial features (typically POINTS or POLYGONS).

- buffer:

  A numeric vector of one or more buffer distances (in kilometers) to
  use in focal mean calculations.

- compiled_raster:

  A `terra` raster object containing population densities.

- progress:

  Logical; if TRUE, shows progress bar during
  [`exactextractr::exact_extract()`](https://isciences.gitlab.io/exactextractr/reference/exact_extract.html)
  operations.

## Value

An `sf` object with additional columns for each PPI buffer (e.g.,
PPI-10km).
