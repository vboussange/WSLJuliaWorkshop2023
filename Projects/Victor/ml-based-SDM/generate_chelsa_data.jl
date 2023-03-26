cd(@__DIR__)
using Rasters
ENV["RASTERDATASOURCES_PATH"] = "/Users/victorboussange/ETHZ/projects/raster_data"

env_var = RasterStack(CHELSA{BioClim}, (1, 3, 7, 12))[Band(1)]

if false
    # cropping the raster to switzerland with shape files
    using Downloads, Shapefile, DataFrames
    # Download a borders shapefile
    shp_name, dbf_name = "country_borders.shp", "country_borders.dbf"
    ne_url = "https://github.com/nvkelso/natural-earth-vector/raw/master/10m_cultural/ne_10m_admin_0_countries"
    shp_url, dbf_url  = ne_url * ".shp", ne_url * ".dbf"
    isfile(shp_name) || Downloads.download(shp_url, shp_name)
    isfile(dbf_url) || Downloads.download(dbf_url, dbf_name)

    # Load the shapefile, and selecto CH borders
    countries = Shapefile.Table(shp_name) |> DataFrame
    CHbounds = countries[countries.ADM0_A3 .== "CHE", :geometry]
    env_var_CHE = trim(mask(env_var; with=CHbounds); pad=10)
else
    # cropping roughly as a square
    CHbounds = X(5. .. 11.), Y(45. .. 48.)
    env_var_CHE = env_var[CHbounds...]
end

using Plots
plot(env_var_CHE)
dir_raster = "data/CH_CHELSA_BIOCLIM"
isdir(dir_raster) ? nothing : mkdir(dir_raster)
write("data/CH_CHELSA_BIOCLIM/CH_CHELSA_BIOCLIM.tif", env_var_CHE)


#testing 
env_var_l = RasterStack("data/CH_CHELSA_BIOCLIM/")[Band(1)]
plot(env_var_l)
