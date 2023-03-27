### Get the packages

````julia
using Pkg; Pkg.instantiate()
````

# Geodata in Julia

The geodata ecosystem in Julia has matured a lot, but is not in a fully stable state yet.

My geodata skills are pretty basic, but here is what I know...

My stack:
- [Raster.jl](https://github.com/rafaqz/Rasters.jl) for raster data (geotiff, Netcdf, ascii-grid, etc)
- [Shapefile.jl](https://github.com/JuliaGeo/Shapefile.jl) for, you guessed, shapefiles
- [ArchGDAL.jl](https://github.com/yeesian/ArchGDAL.jl) for interactions with the GDAL lib
- [Proj4.jl](https://github.com/JuliaGeo/Proj.jl) for map projections

## Geo Ecosystem

- https://juliageo.org/ -- biggest geo-group
- https://github.com/JuliaEarth -- for geostatistics
- https://ecojulia.org/ -- (spatial)ecology
- https://github.com/GenericMappingTools/GMT.jl (for Huw)

## Raster data

(a good tutorial https://github.com/xKDR/datascience-tutorials)

First download some data:

````julia
using Downloads # ships with Julia
using Rasters, ZipFile
mkpath("data")
# download if not already downloaded
!isfile("data/dhm200.zip") && Downloads.download("https://data.geo.admin.ch/ch.swisstopo.digitales-hoehenmodell_25/data.zip", "data/dhm200.zip")
# this extracts the file we want from the zip-file (yep, a bit complicated)
zip = ZipFile.Reader("data/dhm200.zip")
write("data/dhm200.asc", read(zip.files[1]))
close(zip)

ra = Raster("data/dhm200.asc")
````

### Plot raster

````julia
using Plots
plotly()  # use the Plotly.jl backend, this allows zooming withing the Jupyter notebook
plot(ra, ticks=:native,   # thus Rasters.jl provides a plot-receipt and plotting is easy
     size=(1000,700),     # make it bigger
     max_res=2000)        # Rasters downsamples before plotting to make plotting faster.  Max number of gridpoints
````

### Index raster

Rasters have powerful (but also complicated) indexing capabilities.

See https://rafaqz.github.io/Rasters.jl/stable/

````julia
ra[5,6] # index the underlying matrix normally

ra[X(Near(600000)), Y(Near(250876))]     # shows where the x-y are
````

````julia
ra[X(Near(600000)), Y(Near(250876))][1]  # index with the [1] to get the value out
````

````julia
ra[X(500000..550000), Y(130000..150000)] # a range
````

### Other raster operations

resample, mosaic, crop...

See the [docs](https://rafaqz.github.io/Rasters.jl/stable/#Methods-that-change-the-reslolution-or-extent-of-an-object)

### Rasters can be used like normal arrays

Example play game of life.

````julia
grid = ra .> 1000 # all cells above 1000m a.s.l. are alive
include("game-of-life.jl") # load the file with the GOL functions
for i=1:5; update_grid!(grid) end # run 5 iterations
plot(grid)  # note that grid is still a Raster
````

### Shapefiles

Shapefiles contain vector polygons (and such)

First, download and extract data about zip-code (PLZ) areas in Switzerland

````julia
!isfile("data/plz.zip") && Downloads.download("https://data.geo.admin.ch/ch.swisstopo-vd.ortschaftenverzeichnis_plz/PLZO_SHP_LV03.zip", "data/plz.zip")
zip = ZipFile.Reader("data/plz.zip")
for f in zip.files
    name = basename(f.name)
    if startswith(name, "PLZO_PLZ")
        write("data/$(name)", read(f))
    end
end
close(zip)
````

### Shapefiles

Read it and select Zermatt (3920)

````julia
using Shapefile
tab = Shapefile.Table("data/PLZO_PLZ.shp")

zermatt = findfirst(tab.PLZ.==3920)
plot(tab.geometry[zermatt])
````

### Shapefiles & DataFrames

Shapefiles contain tables of attributes which can be handled with DataFrames, if so desired

````julia
using DataFrames
DataFrame(tab)
````

### Shapefiles polygons

Shapefiles contain polygons, the can be accessed with:

````julia
shp = Shapefile.shapes(tab)
poly = shp[1]
Rasters.GeoInterface.coordinates.(poly.points) # points in a vector
````

### Crop and mask raster

Read it and select Zermatt (3920)

````julia
ra_z = crop(ra; to = tab.geometry[zermatt])
mask_z = mask(ra_z, with = tab.geometry[zermatt])
plot(mask_z)
````

# Exercise

- Download the Swiss Glacier Inventory 2016 from https://www.glamos.ch/en/downloads#inventories/B56-03
- look up Gornergletscher
- plot it into the last plot we just did
- mask the elevation map with the Gornergletscher outline and calculate the mean elevation

