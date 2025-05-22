
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MarinePPI

<!-- badges: start -->

[![R-CMD-check](https://github.com/eheery/MarinePPI/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/eheery/MarinePPI/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

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

## Getting Started

To calculate PPI for a set of coordinates, you’ll need:

- A CSV or data frame of longitude/latitude points
- A vector of buffer distances in kilometers (radii within which PPI
  should be calculated)
- Internet access to retrieve the GHSL tile schema and raster tiles
  (using functions from this package)

Here is a minimal example:

``` r
library(MarinePPI)

# Load site coordinates
site_data <- read.csv("data/sites.csv")

# Load tile schema
tile_schema <- sf::read_sf(system.file("extdata", "ghsl_tile_schema.gpkg", package = "MarinePPI"))

# Calculate PPI using pre-downloaded rasters
ppi_results <- calculate_ppi_chunked(
  locations = site_data,
  tile_schema = tile_schema,
  data_directory = "data/ghsl_tiles"
)
```

# Vignette

A detailed walkthrough is available in the package vignette:

``` r
vignette("CalculatePPI", package = "MarinePPI")
```

Or view it on GitHub.

# Contributing

We welcome contributions! Please open issues or submit pull requests.

# License

This package is licensed under the MIT License.
