using Rasters, GBIF2, Plots

obs = GBIF2.occurrence_search("Passer montanus", country=:CH, hasCoordinate=true, limit=4000)
coords = collect((r.decimalLongitude, r.decimalLatitude) for r in obs)

env_var = RasterStack(CHELSA{BioClim}, (1, 3, 7, 12))[Band(1)]
collect(extract(env_var, coords))

# Download a borders shapefile
ne_url = "https://github.com/nvkelso/natural-earth-vector/raw/master/10m_cultural/ne_10m_admin_0_countries"
shp_url, dbf_url  = ne_url * ".shp", ne_url * ".dbf"
shp_name, dbf_name = "country_borders.shp", "country_borders.dbf"
isfile(shp_name) || Downloads.download(shp_url, shp_name)
isfile(dbf_url) || Downloads.download(dbf_url, dbf_name)

# Load the shapes for world countries
countries = Shapefile.Table(shp_name) |> DataFrame
CHE_polygon = countries[countries.ADM0_A3 .== "CHE", :geometry]

env_var_CHE = trim(mask(env_var; with=CHE_polygon); pad=10)
plot(env_var_CHE)