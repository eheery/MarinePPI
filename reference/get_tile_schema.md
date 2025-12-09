# Download and load the GHSL tile schema shapefile (land tiles only)

This function checks for the GHSL tile schema shapefile in a given local
directory. If the shapefile is missing, it downloads and unzips the
schema from the official GHSL (Global Human Settlement Layer)
repository. It returns the tile schema as an `sf` object.

## Usage

``` r
get_tile_schema(
  data_directory,
  tile_schema_URL =
    "https://ghsl.jrc.ec.europa.eu/download/GHSL_data_54009_shapefile.zip"
)
```

## Arguments

- data_directory:

  A character string specifying the directory where the tile schema
  shapefile should be stored. If it is not present, it will be
  downloaded here.

- tile_schema_URL:

  A character string specifying the URL of the zipped tile schema
  shapefile. Defaults to the GHSL land tile schema URL.

## Value

An `sf` object containing the tile schema polygons with a `tile_id`
column.

## Details

The function ensures that the returned object includes a `tile_id`
column, which is required for matching spatial buffers to the correct
raster tiles. It also filters to land tiles only, based on filenames
that include `"tile_schema_land.shp"`.

## Examples

``` r
if (FALSE) { # \dontrun{
schema <- get_tile_schema(data_directory = "Reference Files/rasters")
plot(schema["tile_id"])
} # }
```
