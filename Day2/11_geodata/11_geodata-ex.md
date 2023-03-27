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

````
1926×1201×1 Raster{Float32,3} with dimensions: 
  X Projected{Float64} LinRange{Float64}(479900.0, 864900.0, 1926) ForwardOrdered Regular Intervals crs: WellKnownText,
  Y Projected{Float64} LinRange{Float64}(301900.0, 61900.0, 1201) ReverseOrdered Regular Intervals crs: WellKnownText,
  Band Categorical{Int64} 1:1 ForwardOrdered
extent: Extent(X = (479900.0, 865100.0), Y = (61900.0, 302100.0), Band = (1, 1))missingval: -9999.0
crs: 
values: [:, :, 1]
           301900.0  301700.0  …  62500.0  62300.0  62100.0  61900.0
 479900.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 480100.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 480300.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 480500.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 480700.0   -9999.0   -9999.0  …  -9999.0  -9999.0  -9999.0  -9999.0
      ⋮                        ⋱                        ⋮    
 863900.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 864100.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 864300.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 864500.0   -9999.0   -9999.0  …  -9999.0  -9999.0  -9999.0  -9999.0
 864700.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 864900.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
````

### Plot raster

````julia
using Plots
plotly()  # use the Plotly.jl backend, this allows zooming withing the Jupyter notebook
plot(ra, ticks=:native,   # thus Rasters.jl provides a plot-receipt and plotting is easy
     size=(1000,700),     # make it bigger
     max_res=2000)        # Rasters downsamples before plotting to make plotting faster.  Max number of gridpoints
````

````
Plot{Plots.PlotlyBackend() n=1}
Captured extra kwargs:
  Series{1}:
    max_res: 2000
    tickcolor: RGB{Float64}(0.3,0.3,0.3)

````

### Index raster

Rasters have powerful (but also complicated) indexing capabilities.

See https://rafaqz.github.io/Rasters.jl/stable/

````julia
ra[5,6] # index the underlying matrix normally

ra[X(Near(600000)), Y(Near(250876))]     # shows where the x-y are
````

````
1-element Raster{Float32,1} with dimensions: 
  Band Categorical{Int64} 1:1 ForwardOrdered
and reference dimensions: 
  X Projected{Float64} LinRange{Float64}(599900.0, 599900.0, 1) ForwardOrdered Regular Intervals crs: WellKnownText,
  Y Projected{Float64} LinRange{Float64}(250700.0, 250700.0, 1) ReverseOrdered Regular Intervals crs: WellKnownText
extent: Extent(Band = (1, 1),)missingval: -9999.0
values:  1  511.204
````

````julia
ra[X(Near(600000)), Y(Near(250876))][1]  # index with the [1] to get the value out
````

````
511.204f0
````

````julia
ra[X(500000..550000), Y(130000..150000)] # a range
````

````
249×99×1 Raster{Float32,3} with dimensions: 
  X Projected{Float64} LinRange{Float64}(500100.0, 549700.0, 249) ForwardOrdered Regular Intervals crs: WellKnownText,
  Y Projected{Float64} LinRange{Float64}(149700.0, 130100.0, 99) ReverseOrdered Regular Intervals crs: WellKnownText,
  Band Categorical{Int64} 1:1 ForwardOrdered
extent: Extent(X = (500100.00000000006, 549900.0), Y = (130100.0, 149900.0), Band = (1, 1))missingval: -9999.0
crs: 
values: [:, :, 1]
           149700.0    149500.0    …  130500.0    130300.0    130100.0
 500100.0    1435.7      1390.51         462.7       456.903     453.501
 500300.0    1413.3      1373.49         457.998     456.598     456.797
 500500.0    1385.5      1394.91         462.999     462.103     460.902
 500700.0    1379.0      1355.49         459.198     458.203     456.598
 500900.0    1341.5      1328.01   …     454.9       453.501     451.703
      ⋮                            ⋱                   ⋮      
 548700.0     621.2       640.597       1833.01     1821.51     1747.09
 548900.0     666.702     675.002       1796.09     1756.9      1668.39
 549100.0     681.296     706.996       1928.4      1782.0      1653.81
 549300.0     693.0       706.904  …    2104.21     1813.59     1724.89
 549500.0     686.697     685.998       1921.9      1789.99     1722.61
 549700.0     664.898     681.001       1864.21     1745.21     1653.49
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

````
Plot{Plots.PlotlyBackend() n=1}
Captured extra kwargs:
  Series{1}:
    tickcolor: RGB{Float64}(0.3,0.3,0.3)

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

````
Plot{Plots.PlotlyBackend() n=1}
````

### Shapefiles & DataFrames

Shapefiles contain tables of attributes which can be handled with DataFrames, if so desired

````julia
using DataFrames
DataFrame(tab)
````

````
4127×7 DataFrame
  Row │ geometry              UUID                               OS_UUID                            STATUS       INAEND  PLZ    ZUSZIFF
      │ Polygon               String                             String                             String       String  Int64  Int64
──────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    1 │ Polygon(1772 Points)  {0072F991-E46D-447E-A3BE-75467DB…  {281807DC-9C0B-4364-9A55-0E89568…  real         nein     3920        0
    2 │ Polygon(1809 Points)  {C3D3316F-1DFE-468E-BFC5-5C23087…  {F065D58C-3F88-46EF-9AA0-DA0A967…  real         nein     3864        0
    3 │ Polygon(1389 Points)  {479E660B-A0A5-4297-AA66-FA62735…  {45243689-766B-4FFC-9A14-AF0D17A…  real         nein     1948        1
    4 │ Polygon(1525 Points)  {FDFBFFDF-11C2-4CC9-B903-EF17677…  {678407FD-30DD-4699-A2D7-FD3602A…  real         nein     7504        0
    5 │ Polygon(1100 Points)  {CB229C54-DF46-45A0-B75F-6E77240…  {D4A72AA9-CF35-4F14-8AD4-03F2EDA…  real         nein     3984        2
    6 │ Polygon(1690 Points)  {5B28EF42-165A-4C06-AC5B-BFB4068…  {922C55FE-EF7F-46EA-A14B-98D2BDD…  real         nein     7530        0
    7 │ Polygon(1477 Points)  {6262A301-67E7-4095-BB32-9A62097…  {EAD450C6-15D2-4243-9DA6-F46D40B…  real         nein     3818        0
    8 │ Polygon(1536 Points)  {DCC5A542-C9B9-45B6-BD94-546E5B3…  {F744CFF2-ADAC-471D-A054-FE349F7…  real         nein     7250        0
    9 │ Polygon(1263 Points)  {195005AC-2846-4DD3-A72C-32765AF…  {3C6766E9-20A4-47BE-8AB5-C3FF1FF…  projektiert  nein     7132        0
   10 │ Polygon(1458 Points)  {88E5D38E-75F1-4694-8C59-1968396…  {2F609F6E-1EE8-4FED-8B49-17A2D1B…  real         nein     7550        0
   11 │ Polygon(1165 Points)  {E6D65221-2598-49D3-BADE-C690CEA…  {A1FA8294-D3E0-400F-AE3F-CCBD2D6…  real         nein     3718        0
   12 │ Polygon(1395 Points)  {E33DF701-C11D-4D87-A660-1067B16…  {8288A016-69C4-40F9-AE38-3CC00A4…  real         nein     8783        0
   13 │ Polygon(568 Points)   {2C2430F9-1F5B-42AF-AEC9-2ABA7EE…  {4FCF12AB-836D-4F4D-A2FE-B497905…  real         nein     1986        0
   14 │ Polygon(1358 Points)  {1321B152-868D-485E-9540-813FEB5…  {2544D2CB-D314-4EFD-A98D-3E80900…  real         nein     3775        0
   15 │ Polygon(821 Points)   {B1290F81-97A6-4241-A557-44568AD…  {F33562CF-FB58-4893-8A8F-27D413B…  real         nein     6475        0
   16 │ Polygon(672 Points)   {C46EB230-BF3C-4B75-9F7D-048E1AC…  {D7708D4D-F0D0-4E8A-88D2-26784C8…  real         nein     7185        0
   17 │ Polygon(2492 Points)  {8C684F4E-C8CC-4FFA-866E-FECA051…  {D51A0565-29CD-44D2-8047-8A5A762…  real         nein     3862        0
   18 │ Polygon(1577 Points)  {8F3290B0-54BD-4897-9D89-6E90421…  {DA1FF36B-D279-4EF2-84E2-2302E87…  real         nein     3863        0
   19 │ Polygon(1574 Points)  {ECA56177-62D9-47B7-92A6-9E9CB9C…  {2F569B1D-41D2-4306-81F7-E95120E…  real         nein     7554        0
   20 │ Polygon(1532 Points)  {3F6EE560-9739-49B6-B65C-DA92B74…  {FBF1ECBC-9F45-42D2-9DBF-D85F429…  real         nein     3905        0
   21 │ Polygon(717 Points)   {9566A37F-83B4-4182-A81A-32EA98C…  {EF3184EF-B47E-4D9E-91AB-4E1AE76…  real         nein     6565        0
   22 │ Polygon(1061 Points)  {EA34B036-B7ED-46CB-91AC-DE2CBAD…  {22E3DA1C-7DD4-4FD5-9876-F4830FC…  real         nein     7260        0
   23 │ Polygon(899 Points)   {16778F4B-9F7E-4C61-A488-966924A…  {1E3F77CF-9024-4135-A17C-155F7C6…  real         nein     6487        0
   24 │ Polygon(766 Points)   {4CC540A7-AB71-4E15-A637-79E4529…  {8198B95F-35CE-47D1-A857-ADBFCD2…  real         nein     3961       25
   25 │ Polygon(1526 Points)  {E07A07B1-D817-4B17-A38E-2DCF19F…  {67EE150D-BB4C-4C91-ACD2-A1EF237…  real         nein     7536        0
   26 │ Polygon(858 Points)   {C676B0ED-4BB1-41F7-8E4E-1E71DD4…  {26EB0EE9-9168-4646-B162-258CF64…  real         nein     1987        0
   27 │ Polygon(634 Points)   {C2C89C82-CCF6-40AB-9E78-2D906A6…  {C4AAAADC-DA4A-4ADE-BC33-F949EA5…  real         nein     7315        0
   28 │ Polygon(766 Points)   {C0C58FB1-0427-4582-B45A-58DA402…  {5ECFC759-A315-4E09-B2A5-6921967…  real         nein     3999        0
   29 │ Polygon(1244 Points)  {F3D28A59-0DD7-4FF8-82AB-081DE5E…  {105358C2-65F4-4418-A5AF-B1EAC3E…  real         nein     6780        0
   30 │ Polygon(1170 Points)  {77206F65-8C52-4C86-88BA-7C127E8…  {BE930C3E-B2C4-4977-B500-1E117D4…  projektiert  nein     7542        0
   31 │ Polygon(1770 Points)  {3D69AD22-E534-4F53-8ABB-8BAA241…  {00EAAD1A-21B4-4EAA-93A0-59F3729…  real         nein     8767        0
   32 │ Polygon(884 Points)   {493F127A-D422-4AEC-AF82-7A3605E…  {2BC587F3-AF45-44BE-B9EE-D5EC9F1…  real         nein     3907        0
   33 │ Polygon(596 Points)   {535CA6A1-40C9-4C5F-97C8-2CA30FA…  {DB0027A5-7BC2-486B-9D65-8B81A37…  real         nein     3919        0
   34 │ Polygon(1167 Points)  {5251AD11-4B1F-444D-AAD2-E1B196F…  {BA26522B-1C2C-49D1-9FD1-B8FB3D5…  real         nein     1946        0
   35 │ Polygon(1320 Points)  {8417B2E5-8240-4893-ABA9-DE35181…  {B9C098EA-C951-4947-8E20-2D327C4…  real         nein     3723        0
   36 │ Polygon(1486 Points)  {BF00F09F-1DCE-4C37-9EE9-3BDA795…  {79CDA8A1-4638-4BA9-B1BC-E944641…  real         nein     3715        0
   37 │ Polygon(1203 Points)  {73BB93A8-444B-41A8-AD92-E2037B1…  {6062CDA6-E7AB-4986-AA5D-69CFF9D…  real         nein     3907        4
   38 │ Polygon(372 Points)   {D271A6C8-0637-4341-AF66-E1408EF…  {83863173-FBBE-4D36-AD82-7BFF9C2…  real         nein     3914        1
   39 │ Polygon(5773 Points)  {82BF1BA5-19D5-405C-B54B-4AA86DF…  {83ACB377-ACFC-4D28-A330-E17CC36…  real         nein     1637        0
   40 │ Polygon(1048 Points)  {4EB3B33A-35CC-4AE9-B743-7D7A333…  {9F2AF288-8D74-49E0-935F-C9A9E30…  real         nein     6074        0
   41 │ Polygon(1005 Points)  {F84BCB77-81D1-4089-AB3B-5E7741B…  {6DD94FF8-70D0-46BF-869F-B9AB78A…  real         nein     1944        0
   42 │ Polygon(515 Points)   {09C31C6F-090E-4CA9-8AA0-F78F1BC…  {B3D7C8D4-5C3F-4CEF-B30E-7C20D79…  real         nein     3948        1
   43 │ Polygon(1190 Points)  {EF04EA9A-32E9-45BB-93D3-C43C5EC…  {9CD71607-2530-4398-B09B-8392C62…  real         nein     7516        0
   44 │ Polygon(959 Points)   {A727C206-6A77-4093-907B-606E3F4…  {48CCC8C9-A908-4C35-9FD6-A7AB102…  real         nein     6713        0
   45 │ Polygon(575 Points)   {2A3A8313-6374-4BC2-825A-CBEF83E…  {1DFB413D-31AA-46CD-8EE1-AE32E96…  projektiert  nein     7482        0
   46 │ Polygon(509 Points)   {3289BAE8-4328-4907-B413-548FF1F…  {ED836BED-6A7C-4384-9666-2F6CB3E…  real         nein     6491        0
   47 │ Polygon(1069 Points)  {9997CFC7-31C1-4845-8D60-1155FD7…  {A88D1B0F-8107-49FD-BE9D-3B8088D…  real         nein     3766        0
   48 │ Polygon(705 Points)   {A5060D31-0D5C-42C8-B25B-9A0AC74…  {7041D606-6D07-4807-9EA3-3816DCA…  real         nein     7457        0
   49 │ Polygon(311 Points)   {001E3BA1-1891-4609-811D-7745465…  {107BB76A-3AB4-44CE-867B-C22FA69…  projektiert  nein     7526        0
   50 │ Polygon(570 Points)   {488D43C2-CAAA-409E-9693-AA8AEF9…  {8865225A-8D9B-496E-B396-B60B026…  real         nein     6485        0
   51 │ Polygon(1310 Points)  {497930BF-5FE3-440C-96AE-73C0356…  {8939E1D6-6CE1-4191-937B-89B9992…  real         nein     6718        0
   52 │ Polygon(831 Points)   {715844EB-62EB-4925-9445-6632EF8…  {96AC681F-A03C-4B86-BDCF-1B52A71…  real         nein     7326        0
   53 │ Polygon(1435 Points)  {6587F483-EBD3-491B-8C0F-4FE3ADE…  {926329F5-CDFB-4E33-874B-4FC2FDF…  real         nein     7188        0
   54 │ Polygon(1548 Points)  {F21C0D28-44E2-4DF8-9A5C-6D29B3A…  {253B4E9B-275F-4E0A-9E47-76C1A74…  real         nein     7180        0
   55 │ Polygon(1839 Points)  {3E4A5B5F-E7DA-4555-9AF2-8F8752F…  {870B9B1E-900B-4794-964E-144F50B…  real         nein     6390        0
   56 │ Polygon(630 Points)   {7ED2A7C4-BCF2-4C75-849D-5214ABA…  {148BD49D-2574-41B0-BB2A-0716C9A…  real         nein     7149        0
   57 │ Polygon(599 Points)   {C4ECA961-70DA-49B3-927C-4DC3257…  {F0A89AD2-BBC3-4B05-9D3C-7732B1A…  real         nein     6482        0
   58 │ Polygon(2044 Points)  {010FA27A-C6D5-467B-BB5B-80F4D79…  {6AF39E0E-53DB-463A-812B-B91EB55…  real         nein     6436        0
   59 │ Polygon(1112 Points)  {974AA42C-1B1E-4C02-B7EB-85FA631…  {904B8A1A-CC7B-48BC-AEB8-D9E72F6…  real         nein     6781        4
   60 │ Polygon(1323 Points)  {CB37A324-C4BE-42E4-9E85-BEEFB87…  {D742EEA4-FCFA-4AC7-8F1A-2F23488…  real         nein     6436        2
   61 │ Polygon(926 Points)   {B79F1A16-945E-4048-875C-B7FCFFD…  {F2F499AD-89FE-407A-B82B-EB71ED4…  real         nein     7109        0
   62 │ Polygon(671 Points)   {D40DCE6C-FA4E-4955-AFB3-F77C110…  {4DC6D313-3486-42A0-864E-1370B93…  real         nein     3954        0
   63 │ Polygon(925 Points)   {9D87C353-F542-4261-994F-14F5842…  {59A1657B-4074-4BAD-B89F-F915866…  real         nein     6696        0
   64 │ Polygon(609 Points)   {D8A32B5D-971E-4A19-B9CF-72A3E42…  {B8B1182F-6FFB-4279-8B03-D13033F…  real         nein     7610        0
   65 │ Polygon(491 Points)   {CE25B73E-DD1B-48B0-9B75-26258A6…  {6BDC2217-ED67-40DB-8E60-661ECFA…  real         nein     1348        0
   66 │ Polygon(1340 Points)  {D1F1334F-A811-4CEE-8723-CE4DDAF…  {5C011E17-17BB-4281-B254-E344864…  real         nein     7525        0
   67 │ Polygon(1194 Points)  {5229DA53-5C95-4B38-91B3-0A8747A…  {B7E9C073-9CB4-442D-89B0-E0C901D…  real         nein     3996        0
   68 │ Polygon(1127 Points)  {6ADC76D6-9EF4-44E7-95FB-ECE5BB2…  {649A8656-F611-44E9-B8F7-9D89BA6…  real         nein     3824        0
   69 │ Polygon(967 Points)   {C110F179-FDDA-45A4-86F3-6DD848D…  {61754C4F-FCEA-4589-AD62-4F5F191…  real         nein     7522        0
   70 │ Polygon(571 Points)   {F3DA0486-0FCB-4F3A-B05F-B2DAFF9…  {066F72C3-3047-4BA0-9C1F-570CA33…  real         nein     6465        0
   71 │ Polygon(753 Points)   {33CCBB68-754A-4B3B-9F73-31BAE2F…  {111B658A-75EC-45F4-B467-1E0504B…  real         nein     6490        0
   72 │ Polygon(842 Points)   {C616EDA2-7844-499F-800C-1592134…  {16D46560-5584-4D5F-9A4A-5456A28…  real         nein     6461        0
   73 │ Polygon(2351 Points)  {A5043060-D3C4-450D-9270-33A1316…  {6C4135FE-249C-47FC-83BC-7606C74…  real         nein     8750        3
   74 │ Polygon(2111 Points)  {CB46547A-9802-4F37-8BAD-6A275D3…  {21A383A4-FCA3-473D-A0BC-2680E1C…  real         nein     9107        0
   75 │ Polygon(757 Points)   {1AFE49C0-A4E8-43EB-97BC-287CA13…  {98CA1FFC-9BF8-4DF1-B5A4-30B1318…  real         nein     7189        0
   76 │ Polygon(1596 Points)  {786E57A1-E6DC-4ACB-9458-AB49BE1…  {77945FEB-23FF-4B06-9C7D-DAF24E7…  real         nein     1965        0
   77 │ Polygon(1401 Points)  {3EF5C586-2E4B-459E-8544-5F0D6C6…  {7F5F959C-24B3-41C8-9CA7-AA9971A…  real         nein     7546        0
   78 │ Polygon(845 Points)   {5448EFA6-BB18-4718-B766-5C11CD9…  {081F5998-5E74-4F39-B248-0C90D04…  real         nein     6472        0
   79 │ Polygon(600 Points)   {5A2CD3E7-0F07-44AD-893D-7C0EEB2…  {3E3FFAEE-1266-42BC-B362-EEF301C…  real         nein     3929        0
   80 │ Polygon(783 Points)   {AF6EA2F0-4133-4CB7-A959-E77F34E…  {8D45681B-9757-4BFA-8E0C-05364CC…  real         nein     3782        0
   81 │ Polygon(788 Points)   {95CEECEC-2535-4874-BB2D-E649F0C…  {D81B0D96-B282-4034-8125-04B4090…  real         nein     3993        0
   82 │ Polygon(752 Points)   {BCBA54F4-DE39-41A9-BF34-883F869…  {BEBD83BA-E3F1-4981-A599-04F7C5D…  real         nein     3961       26
   83 │ Polygon(1100 Points)  {AC5F51F0-B904-44CD-B502-C4447FE…  {C8F27E18-1C69-4A5D-9467-5521603…  real         nein     6747        0
   84 │ Polygon(713 Points)   {53F07C45-5763-4580-9018-4601E65…  {CCFCAD52-7328-40EE-BEC3-28A8A90…  real         nein     6633        0
   85 │ Polygon(769 Points)   {A2E746DD-031D-4492-A054-46E9302…  {AB4A8D02-06FA-4D9F-880F-D430B4D…  real         nein     3924        0
   86 │ Polygon(1414 Points)  {88BB36BF-407D-4792-9BF6-581CCC4…  {82997420-D94C-4035-B1F1-190A999…  real         nein     7524        0
   87 │ Polygon(666 Points)   {4547062B-8645-46CF-9EE8-32AB502…  {D3C395A7-21E9-4ED6-B021-C6FEEF9…  real         nein     6563        0
   88 │ Polygon(1070 Points)  {D10B3948-DF65-4ADB-9C9F-130E925…  {6614FB5D-16B6-4303-8E4C-E4D5D5A…  real         nein     6690        0
   89 │ Polygon(709 Points)   {1808A5FD-401E-4AC2-BE45-2A58C4F…  {7553DE5B-1794-4C12-9F1D-266CA7D…  real         nein     3757        0
   90 │ Polygon(334 Points)   {B20066C4-357B-4547-B3FE-B3F69F4…  {FD6714FC-C277-4FB7-B156-C2F5B69…  real         nein     1865        0
   91 │ Polygon(683 Points)   {459BB4D3-B0DF-4BF0-987F-76FA702…  {64454D87-7601-4A2F-B7E1-2942D31…  real         nein     3928        0
   92 │ Polygon(879 Points)   {C0AAAE3B-72A6-4248-8E5C-C133155…  {F81941FC-0647-4A4C-86AA-EAA7243…  real         nein     6776        0
   93 │ Polygon(563 Points)   {16B47901-75F3-47BE-8EB7-BD85A44…  {FCBABEDD-482F-4B00-862C-D0DBE3B…  real         nein     7057        0
   94 │ Polygon(711 Points)   {6F6FD30D-8BA1-439A-AEB6-C117927…  {C3B34FE6-1DD3-4879-A732-7483016…  real         nein     7173        0
   95 │ Polygon(603 Points)   {FD33B7B2-332A-4960-B829-5AA53BC…  {9BE622FD-6F0D-4F3A-AD18-6C1D36E…  real         nein     3932        0
   96 │ Polygon(840 Points)   {E4C99B0D-AFED-45B3-AD67-78D899A…  {5CE016B3-B145-4673-978E-92860B0…  real         nein     7464        0
   97 │ Polygon(1425 Points)  {D4DAA59A-6E6F-48D9-8C26-DB892A5…  {C225373D-A9D2-43FE-A9FF-922BC52…  real         nein     3804        0
   98 │ Polygon(780 Points)   {68A6480D-F2DA-4B6A-AD9F-BC273FE…  {76AEDD5B-4699-4B9E-80C9-AF682EA…  projektiert  nein     6558        0
   99 │ Polygon(998 Points)   {FE228C72-31C1-493C-B966-F147623…  {C487E91A-0C27-434A-81E2-BD464A8…  real         nein     7050        0
  100 │ Polygon(1037 Points)  {3B34BEAE-B233-45EC-9EC4-C0BA0F8…  {AF212F71-C514-46C3-9CA4-C3E841F…  real         nein     6174        0
  101 │ Polygon(1027 Points)  {FB5DBFA2-2753-4D83-884C-A149EEB…  {D7464F29-53E7-4451-BC6B-00DFA21…  real         nein     6690        1
  102 │ Polygon(2125 Points)  {B51873C1-4C01-4CB4-B4A8-D7B7615…  {C7274AC0-F364-4D9A-9A34-6EBE1DA…  real         nein     8858        0
  103 │ Polygon(1118 Points)  {5B5C109F-9BBD-45D0-8792-3A8033A…  {1EE2593A-8EDF-4C2E-A6E3-881D787…  real         nein     1738        0
  104 │ Polygon(1105 Points)  {967BC084-ADCF-4190-BB20-CA5F18A…  {D5C2B1C5-1816-49E0-9654-BBE02E9…  real         nein     7503        0
  105 │ Polygon(1697 Points)  {93A696AD-DDAA-497F-9BC5-2AD8521…  {9A2E1C06-4454-43FF-979A-F8D8BAC…  real         nein     6055        0
  106 │ Polygon(1353 Points)  {6EA66D36-21C4-4C41-A185-FD54BAC…  {E65B612A-4D16-4226-8323-262FAA8…  real         nein     3537        0
  107 │ Polygon(1505 Points)  {1400082F-891A-48E1-9053-36C841E…  {7E154D65-4FEE-4C80-8D3B-28370B3…  real         nein     6072        0
  108 │ Polygon(2173 Points)  {C7DB41B8-6C0C-4CC6-9FD2-5EA18ED…  {7A6EA7DC-EC2C-4924-9729-5B39653…  real         nein     3855        0
  109 │ Polygon(1029 Points)  {9DFA9F80-C241-4267-B5AD-78A69BA…  {F4C57CDF-620B-4BCE-B880-B6A8531…  real         nein     1976        1
  110 │ Polygon(715 Points)   {1170B1F2-CF15-47D0-A80E-869D0A5…  {75BDCF5E-A5CB-42E1-A10D-97F3EB8…  real         nein     3785        0
  111 │ Polygon(1576 Points)  {CBCFF97E-C4EA-4FC0-ACA7-0EA142C…  {573F6B8E-1966-4134-9A15-3615249…  real         nein     7212        0
  112 │ Polygon(644 Points)   {8104AA6F-D1D4-42CE-AB92-BF5E86C…  {4CA72C1D-3FB2-497A-86E4-CB6FD5F…  real         nein     6634        0
  113 │ Polygon(685 Points)   {578BEC0F-EACF-42CC-9BBA-C19E13E…  {2B76E490-BB30-434E-895D-CBB4DDB…  real         nein     7438        0
  114 │ Polygon(439 Points)   {723A0FF4-A20C-4F34-A6D3-D4357DA…  {08046B0F-1D00-4C7A-8B1B-972E7C5…  projektiert  nein     7482        1
  115 │ Polygon(789 Points)   {99CD937C-BEC5-417B-84CF-5AB3C1D…  {9E5EB86E-D06E-489D-9F5F-7AA32A9…  real         nein     1902        0
  116 │ Polygon(1123 Points)  {A812ADAC-8AD8-455F-B621-54DBBB1…  {E123AEAF-4011-4CFA-9BB9-E211264…  real         nein     3770        0
  117 │ Polygon(384 Points)   {05694F83-6431-4585-9187-83E8A3E…  {54ACCD11-4AFE-46D1-AC2A-3F132D5…  real         nein     1937        0
  118 │ Polygon(833 Points)   {2B9C6858-B8C2-4B3D-86ED-9702536…  {17A6FB90-993B-4C82-A6A0-8BAF155…  projektiert  nein     7553        0
  119 │ Polygon(861 Points)   {F0C4877E-766D-45A0-978B-C8928FC…  {910F9278-93F7-432C-8AE5-C6FF919…  real         nein     6562        0
  120 │ Polygon(910 Points)   {1F61EDC8-0C50-4435-BB69-A38E0AF…  {5138B01E-BA2B-4EF3-A5A2-76E80CF…  real         nein     7543        0
  121 │ Polygon(925 Points)   {3326B8F7-B7DF-4D6E-94C7-05243C2…  {91E75990-6972-4853-B16A-1036EBC…  real         nein     6173        0
  122 │ Polygon(1245 Points)  {C809DCB8-80A4-4F40-97B0-5D29482…  {4CFFD29F-C924-4C1E-AD26-B716CDD…  real         nein     6063        0
  123 │ Polygon(879 Points)   {A6968EB3-FD91-45D1-B068-0AC51E7…  {5DFDCD00-4BF0-44FA-8089-CA4E7BA…  real         nein     3765        0
  124 │ Polygon(922 Points)   {83DBAA8D-8770-4F6F-9D1E-3C19AA6…  {0096842F-E1CF-49F0-A856-90DF1E3…  real         nein     6695        1
  125 │ Polygon(1447 Points)  {4955329F-D33E-4155-9EA7-EBDC934…  {06F3F2C4-1191-4F86-8D0C-8BD2A36…  real         nein     7563        0
  126 │ Polygon(1627 Points)  {E8C5F10D-DF95-4A54-A012-4EB0A28…  {4500F4EE-438F-49F5-88CE-C7EE700…  real         nein     6197        0
  127 │ Polygon(348 Points)   {7BB789FD-8649-42DD-9D61-F88723B…  {A7423118-6A71-49A4-B154-E4DF71E…  real         nein     7272        0
  128 │ Polygon(802 Points)   {7D8FB6D8-57BD-412C-B072-E6644DE…  {B2EB0818-D629-4FC6-8EFD-9D42EE8…  real         nein     1716        3
  129 │ Polygon(906 Points)   {A4A17EFB-4F9C-4453-AFB7-C964760…  {1F7E70DC-FA18-489C-8437-6A8FEE8…  real         nein     3988        0
  130 │ Polygon(1400 Points)  {E66BCBE9-DE7F-43C5-B7BA-4A7D0DC…  {5832DC20-D827-48DE-A476-F0EB7F5…  real         nein     8752        0
  131 │ Polygon(1991 Points)  {E9C39E31-F239-4CA2-AA45-C36D5BC…  {87649708-A8BA-4527-BEB0-002DDAA…  real         nein     6182        0
  132 │ Polygon(1022 Points)  {EAE70CDE-F6E2-4E24-822B-63F098F…  {39F51FCB-FF6E-461B-AC4E-30C547A…  real         nein     7445        0
  133 │ Polygon(1715 Points)  {76C8E3E5-E7FA-4717-882A-5110DCF…  {063D6346-D984-4B05-877F-809BC1D…  real         nein     9642        0
  134 │ Polygon(758 Points)   {A3A2F4B3-35A5-4883-B8E6-59F0834…  {5CE022DF-A0A3-45BD-BA78-88C6453…  real         nein     6078        0
  135 │ Polygon(832 Points)   {D18F17BA-03EC-4D54-8F03-62F2CCC…  {62EC3766-C42B-43AA-A6C3-A82C5B8…  projektiert  nein     7477        0
  136 │ Polygon(944 Points)   {78FC8CFE-EF88-42C3-A0EA-B96D9E6…  {664173CC-41BC-4271-8C1D-AF9F531…  real         nein     8873        0
  137 │ Polygon(1096 Points)  {ED7875D3-254A-4192-8B8A-862348A…  {8C5B566C-D26E-4527-8E27-A2B7D1F…  real         nein     7551        0
  138 │ Polygon(988 Points)   {8222DEF7-5511-49E0-9EF1-2CC4072…  {C28E4EC6-3111-403B-8DDE-7E81B76…  real         nein     7603        0
  139 │ Polygon(1575 Points)  {FFD0AA65-9F1F-4FB8-9ED7-0F9F9A9…  {88A0DA0F-B085-476E-ADB6-9D4797C…  real         nein     7246        0
  140 │ Polygon(977 Points)   {AA73AA61-2CC9-4DF9-885C-64BD31B…  {2DF56BC7-A564-445D-9B02-5B421F4…  real         nein     9472        2
  141 │ Polygon(1726 Points)  {29D85131-4FD4-49E8-B611-FFE1319…  {CB770A99-C4F3-44FB-A046-A505F67…  real         nein     1273        0
  142 │ Polygon(2281 Points)  {5D21E794-D33A-4B9F-A84D-CD97235…  {7EFBD19B-0FAD-4739-910F-D4A7191…  real         nein     8897        0
  143 │ Polygon(486 Points)   {2FA79F3B-BD00-438D-B9C5-24FC78A…  {8ABC81FD-2FFE-4838-97F5-82A1D3B…  real         nein     7532        0
  144 │ Polygon(603 Points)   {47704C98-3AAF-4097-9E23-0AB4186…  {F9E239C3-DA92-48EA-BCF3-FDBA266…  real         nein     1972        0
  145 │ Polygon(939 Points)   {4357BDA1-3FCC-45A8-9D93-514366F…  {0F2BECD2-BF12-41E0-B579-B6CB789…  real         nein     6196        0
  146 │ Polygon(662 Points)   {1B6D3B41-4FDA-472C-B5C2-FD43647…  {17C01C3C-A7C4-46CF-B5C4-70A15F5…  real         nein     6664        0
  147 │ Polygon(135 Points)   {657CFDD2-D1AC-4669-B9E8-97EE158…  {ED8EF201-5A8A-42CD-A758-321D9C8…  real         nein     9999        1
  148 │ Polygon(892 Points)   {519CD949-CC7E-430F-AC26-81198DD…  {0F37632D-9E0C-44C0-97C5-2F3D4C0…  real         nein     3457        0
  149 │ Polygon(633 Points)   {03F4C806-C4A7-40E9-B824-38501FE…  {7457A5D3-B720-43E1-A70A-A0B2739…  real         nein     7165        0
  150 │ Polygon(1085 Points)  {1A803ABF-CB16-4315-A542-21C3B4F…  {469499DB-8B9C-4100-9214-2B5DF42…  real         nein     7557        0
  151 │ Polygon(499 Points)   {42450D1C-ECBD-4EC4-9FDB-66A0812…  {3128D514-3903-40BD-B0F2-9513E3D…  real         nein     8751        0
  152 │ Polygon(1554 Points)  {96BA9A25-9763-4648-81D5-620DDBF…  {35F6AAE9-6831-464C-8A24-A8EF1D7…  real         nein     3860        0
  153 │ Polygon(1205 Points)  {76D74D1D-F99A-485F-878C-842BE4A…  {CE1B1352-3EFF-4331-A557-4109461…  real         nein     7304        0
  154 │ Polygon(1322 Points)  {D4FE4350-286C-458E-9FB5-B2D3F27…  {2B4CCD1A-10B3-4925-AD23-C0FD7C4…  real         nein     8766        0
  155 │ Polygon(2086 Points)  {692F32EC-385D-4AF8-9512-D3CBEE3…  {8DD005E2-52BC-4B2A-B9FC-FFFF602…  real         nein     6170        0
  156 │ Polygon(1139 Points)  {F52C86D1-9121-4B23-8266-87B2831…  {5CED6EDD-2AF5-4710-8240-26BF6EB…  real         nein     8765        0
  157 │ Polygon(468 Points)   {85BEEC0F-69BC-473E-850C-0E9B115…  {498EC24F-24AC-427D-9249-970DCA3…  real         nein     7014        0
  158 │ Polygon(419 Points)   {557F3397-650D-4E42-84F9-35C2774…  {AB65A0C5-8666-4A9E-B91A-2DF1D4B…  real         nein     7017        0
  159 │ Polygon(412 Points)   {E4A60DED-FEC6-40EC-B9E7-02014ED…  {4996A656-A206-49CA-97B9-DFF0053…  real         nein     3906        0
  160 │ Polygon(800 Points)   {95E63CAC-B47E-48BE-92F2-B99750E…  {130E7500-1783-40E5-983C-2EC1CC0…  real         nein     8842        0
  161 │ Polygon(733 Points)   {3344D83C-AD5F-45A7-B82D-9F60A0B…  {D021C4C9-7492-46DA-B3EF-77B0FDA…  real         nein     3903        0
  162 │ Polygon(530 Points)   {69B76A62-BAAF-457E-9D64-BAC590A…  {D311BB7B-C98A-4BDD-8E71-CBAD2FF…  real         nein     1923        0
  163 │ Polygon(496 Points)   {58E90DE9-7F31-4F7F-8B40-8727365…  {5E91CB50-4BB8-43E4-BF55-2796851…  real         nein     1997        1
  164 │ Polygon(427 Points)   {9F843631-C074-4C79-830C-5D2E159…  {ADB5A597-C696-46C3-8872-6CF7C9E…  real         nein     7032        0
  165 │ Polygon(715 Points)   {D28CC84E-F84B-4EFA-A9F0-C8B28DF…  {349558FE-37F7-405A-8C87-C3741F4…  real         nein     1929        0
  166 │ Polygon(6629 Points)  {E3CCC13C-D75A-4D2F-9C65-B9FDC4D…  {FD70C04C-A143-4B5D-BEDB-94D5F5B…  real         nein     1659        0
  167 │ Polygon(362 Points)   {81BDC25F-E637-45CD-B003-997A605…  {10B36E10-2C10-4A53-AA36-8721DE3…  real         nein     7742        0
  168 │ Polygon(1431 Points)  {19441071-10CD-4893-B86B-DE9F252…  {8B2D2B7C-9B2B-44FD-9AB9-63DF11D…  real         nein     6694        0
  169 │ Polygon(482 Points)   {EADA8573-82AE-4B09-9F50-52C40F8…  {E4F01DAF-D723-487C-B37C-65C4D6D…  real         nein     6744        0
  170 │ Polygon(855 Points)   {D8857321-8101-457A-A690-5074288…  {C137A8DF-C9AA-4034-A0D7-332DB5D…  real         nein     1874        0
  171 │ Polygon(610 Points)   {E1D055E2-CA40-47EB-95D7-6C93167…  {85B82920-59FA-416B-9966-5212752…  real         nein     7435        0
  172 │ Polygon(414 Points)   {BB9A4BED-01E2-4C96-A05C-DC24B15…  {149379A1-6B49-4F5F-B554-2856ECC…  real         nein     7710        0
  173 │ Polygon(510 Points)   {6F5FE6E3-1A17-47AC-A54B-649FE13…  {480F48C2-23CA-4489-A562-8D8F965…  real         nein     3922        2
  174 │ Polygon(501 Points)   {43C97869-1CDB-479B-AA18-03EA8E6…  {439D1742-930F-4D15-90FA-EF9D9CE…  real         nein     1926        0
  175 │ Polygon(685 Points)   {5EA470EE-89D3-4BC1-83EE-EAAC046…  {8D14801A-A18E-4CEA-92D9-DC6B38F…  real         nein     6535        0
  176 │ Polygon(789 Points)   {EAFC1A00-BF77-4A0B-B174-76101C4…  {3F837457-558A-4B67-A9B9-182C555…  real         nein     6637        0
  177 │ Polygon(1025 Points)  {E12C0D10-0C88-4370-9975-F831E84…  {4A9F13CE-8488-4C2F-AFC8-4F7B3FB…  real         nein     1882        0
  178 │ Polygon(1749 Points)  {5F7C3549-AA66-4A22-9D9B-69D32CE…  {B5ABF02C-AC8B-484D-AE32-4998912…  real         nein     6162        3
  179 │ Polygon(2757 Points)  {80486859-439C-4DDD-945D-DA5E28F…  {A17DD95B-F188-4CC0-80E7-1F82E0C…  real         nein     6130        0
  180 │ Polygon(712 Points)   {174B9674-FF97-4FC8-8FAD-955DEAB…  {BF4BE7F2-6AF3-4B96-AE7B-971AA0D…  real         nein     1660        3
  181 │ Polygon(2338 Points)  {FD0AFC0B-4818-4AA5-8223-EA48F05…  {3D094145-F178-435A-8764-593E31A…  real         nein     1660        0
  182 │ Polygon(974 Points)   {F0E75F47-623E-4844-A189-3CFDE00…  {4BB70756-C51D-4ECE-A271-2BE2CF5…  real         nein     1737        0
  183 │ Polygon(658 Points)   {0F252130-2984-412E-A499-A295C5C…  {9A6D6E45-F699-4595-A4A0-46DEC6B…  real         nein     3901       23
  184 │ Polygon(1543 Points)  {62BA6356-03FA-4B36-B6E5-BEAF22F…  {190D7F2A-4F3C-4B24-8009-D1967F0…  real         nein     1660        4
  185 │ Polygon(537 Points)   {25366863-9183-4B96-9FB0-1653D04…  {B2912531-C842-447A-BC56-AF76600…  real         nein     6493        0
  186 │ Polygon(761 Points)   {1199E9A0-2A3C-464B-B627-E6DEA16…  {CA7E374A-F81A-428F-8980-CC04F98…  real         nein     1880        4
  187 │ Polygon(389 Points)   {D9CF61FD-6A19-45E6-B96C-336DC2D…  {F2E0F3F0-09BE-4179-B87F-9E810F5…  projektiert  nein     7559        0
  188 │ Polygon(321 Points)   {1CCCAE03-1B07-4EEB-B893-A4AE161…  {59881308-45E0-4970-96E6-3BAA4AE…  real         nein     3756        0
  189 │ Polygon(462 Points)   {A8114F8E-2D27-46A2-A27B-4835980…  {6FF485AB-3C08-4479-ABE8-51A62E7…  real         nein     3952        0
  190 │ Polygon(1058 Points)  {24C07A64-1095-468E-BA18-F8FCD26…  {1143A8A6-3D68-4985-9E3D-F7C6872…  real         nein     9658        0
  191 │ Polygon(803 Points)   {8209C2B5-E49E-463A-B133-C283032…  {F8C3CFAC-D670-4220-B7A1-C5BCC9D…  real         nein     7434        0
  192 │ Polygon(417 Points)   {54A5F0D7-9A88-4EFA-A47D-5379752…  {6DB82FCD-68B3-4682-857B-B49E913…  real         nein     8884        0
  193 │ Polygon(431 Points)   {E1FF8164-A6C7-411E-BF93-9D6E07A…  {E6C02E44-6CE8-4CBB-84E7-7515806…  real         nein     7148        0
  194 │ Polygon(140 Points)   {C53BB291-80DE-4D8A-B032-BF87D98…  {3647A5B9-7253-4646-9D23-A2EEBBD…  real         nein     9999        0
  195 │ Polygon(466 Points)   {37543311-7D3B-41F9-8F2D-A6F29D6…  {A30CC1C3-A8BA-427A-8A0A-C8DD36F…  real         nein     3998        0
  196 │ Polygon(1588 Points)  {1CB1D12D-853E-47EB-A213-E12A92E…  {5B9600B4-1D8A-426A-9CA6-2A66173…  real         nein     9650        0
  197 │ Polygon(702 Points)   {AE6CB1EA-4299-4D6E-895A-8CECB0D…  {EEC337DB-2D46-403C-B860-7B37A26…  real         nein     7455        0
  198 │ Polygon(707 Points)   {95AFC503-FC8B-47E3-B7EC-9125125…  {E63D52E0-9343-4EE5-8AF8-84C0D74…  real         nein     3556        0
  199 │ Polygon(549 Points)   {358690E6-5B46-48AC-B3AF-8D72FDE…  {65E02584-B2C1-4DEB-B636-8C7AAFB…  real         nein     7232        0
  200 │ Polygon(827 Points)   {EFD16DD1-CB72-4A0A-8B97-EAC1C46…  {F5E33D98-591A-42C5-860E-50C74D2…  real         nein     9656        0
  201 │ Polygon(581 Points)   {1CE9448C-D240-47E5-816D-55F62A2…  {22659730-BA4D-4A1D-92EC-9739402…  real         nein     3657        0
  202 │ Polygon(956 Points)   {08BB75F5-5B10-400C-B5FA-9D96DEB…  {44D13DEE-0B73-4E92-AEE9-D4188AB…  real         nein     7545        0
  203 │ Polygon(1363 Points)  {0902D695-BD5F-4F74-84F9-452FFB9…  {4D6C3B1B-BCC7-451A-AD2C-2F381A5…  real         nein     6375        0
  204 │ Polygon(1620 Points)  {9A3A11A5-CF35-48CC-8DB5-86BCBBC…  {D29D5C2C-3CF6-4B43-90F1-2162F85…  real         nein     9630        0
  205 │ Polygon(639 Points)   {59F433AC-A8E2-4460-B838-B67C9F6…  {9B8F02DC-11BA-42D8-B3EE-2B668B0…  real         nein     7514        2
  206 │ Polygon(924 Points)   {D4EEAFA2-B414-49E5-A771-56A08B7…  {0087AF00-F14F-4296-8A70-9014C83…  real         nein     9651        0
  207 │ Polygon(458 Points)   {E01C6574-39AC-4100-B4AD-D05531C…  {1CBD3567-C4D4-46A2-BB21-9D367CA…  real         nein     6674        0
  208 │ Polygon(427 Points)   {606DA5D7-000D-4BDB-9FF1-1B03C57…  {19D4E4C4-24D9-4B37-9CB2-79B4574…  real         nein     1997        0
  209 │ Polygon(891 Points)   {2BEF6AFF-326A-4B55-973A-5B57FDF…  {6EDAB92C-4CFB-4EEE-B0ED-3EF7548…  real         nein     7492        0
  210 │ Polygon(1043 Points)  {557DA042-B720-44F6-A979-10B5CD4…  {CEFD2A75-C329-40E2-9386-C21D73C…  real         nein     7158        0
  211 │ Polygon(1475 Points)  {588856EB-20A7-4399-B5E5-443BCF6…  {6E35EA4A-B0A9-4AF1-8E40-9835A92…  real         nein     1618        0
  212 │ Polygon(743 Points)   {E42CE320-2F4D-465D-BD47-D7CD092…  {476811BA-61FE-4339-8DC7-A3E25D3…  real         nein     7742        2
  213 │ Polygon(902 Points)   {12DD97C9-F01B-46BF-927B-1FBAF5C…  {9A4765C4-C779-4677-9CA3-78041D8…  real         nein     1844        0
  214 │ Polygon(655 Points)   {D975501B-5652-46DC-BD25-07B7DA8…  {6D376B51-970F-4DAF-A392-F9A4451…  projektiert  nein     7527        0
  215 │ Polygon(502 Points)   {1F647607-E947-4EDF-AA12-5372684…  {32922FB9-E125-4B1C-A6BE-A7D30F8…  real         nein     1921        0
  216 │ Polygon(611 Points)   {8A839853-B0E0-4662-8C41-ED4DA98…  {47372334-61AF-4561-9A99-7D2E5D5…  real         nein     7444        0
  217 │ Polygon(507 Points)   {11F79FC4-BBE1-4E80-B48C-93344AC…  {86ACBF79-8550-42A5-B889-C40AE61…  real         nein     7462        0
  218 │ Polygon(95 Points)    {1B0EA85A-45F9-48B9-9A21-1EE5A49…  {0CC6F9C8-79D4-4306-9C93-7210AA4…  real         nein     1984        0
  219 │ Polygon(643 Points)   {D3121549-4274-48A1-A9BC-90B80E7…  {CC23E3A6-8159-4A81-AE1B-42CF13B…  real         nein     3860        3
  220 │ Polygon(383 Points)   {5FBBB2EF-7111-46AD-9DF7-12CDD29…  {3DC01E47-2844-4613-8784-FADD707…  real         nein     3900        0
  221 │ Polygon(726 Points)   {84412B3F-DC34-438C-90A0-CA2255B…  {3365892C-58C9-466F-8571-7AC57F7…  real         nein     6676        0
  222 │ Polygon(862 Points)   {C0DEBF1C-D148-45D1-A903-E8BF070…  {A33C0F15-E39E-45BA-9DFD-BDEA780…  real         nein     7494        0
  223 │ Polygon(1138 Points)  {46C7FF8D-0A7F-4F37-92F2-D2147EA…  {62A9A626-482B-4213-A4BD-DA41255…  real         nein     3823        0
  224 │ Polygon(645 Points)   {8454B5C5-92CB-4253-8B09-0716DCB…  {1FDD68D4-8B1F-416D-B9CC-3D4FAB4…  real         nein     3762        0
  225 │ Polygon(337 Points)   {7D4EA34D-CA4F-48FF-81B1-D7283F3…  {F8CA015F-85EB-4E50-B3BA-E292B1B…  real         nein     3927        0
  226 │ Polygon(1335 Points)  {488975A8-FA66-47C3-B180-4D0D009…  {A494C7A3-F5D5-44B6-8F5F-2B3F9E6…  real         nein     8762        0
  227 │ Polygon(380 Points)   {78AA0020-37D5-401D-9CA5-FE518D1…  {D2B7AF8D-1570-41E5-A475-D669875…  real         nein     6527        0
  228 │ Polygon(594 Points)   {D9E8529F-363C-45C9-A08B-C3669FC…  {E3A76536-4EC6-462F-B156-EE1EF7C…  real         nein     3772        0
  229 │ Polygon(971 Points)   {6332E0AA-A62D-4187-888D-275617A…  {54735E5C-6A4B-40FA-AE75-8DD41EB…  real         nein     3825        0
  230 │ Polygon(844 Points)   {48E2FB00-9C41-4BC9-B460-0221CED…  {DF51C43C-33DB-4318-87D4-90CC7D7…  real         nein     8500        0
  231 │ Polygon(866 Points)   {5E9C9C7C-127C-41BB-AEB3-5F419AE…  {876CED2A-6C4B-4554-BD26-5E13E15…  real         nein     3773        0
  232 │ Polygon(1479 Points)  {7C5299ED-C168-4150-9EC5-0EE6313…  {6FED6788-BD2B-4A01-9AFB-F792E7F…  real         nein     6166        0
  233 │ Polygon(465 Points)   {D65EAE7E-CAE4-4456-BAE1-717D047…  {32739B7E-5BC7-4D8A-ACA4-1A4474C…  real         nein     7440        0
  234 │ Polygon(507 Points)   {86FAF531-118D-4770-B6FE-3217254…  {67D1526B-DC05-4C8D-A49E-B88C266…  real         nein     6068        0
  235 │ Polygon(593 Points)   {5D85E754-3FA3-4D0C-AEDB-959B9D2…  {6803FA2E-AC30-4E9B-8B15-AC148C3…  real         nein     6720        2
  236 │ Polygon(524 Points)   {480D4945-3C64-475E-9CE1-2E3CFA5…  {48BB116A-6F1B-4D22-BADA-A06F619…  real         nein     6719        0
  237 │ Polygon(1062 Points)  {1F4DFAB3-D3DE-4A61-96C8-B59A9C5…  {2CFCC542-EF1E-47B3-9ED5-5A3D04A…  real         nein     7560        0
  238 │ Polygon(460 Points)   {4C88ED8B-4F0C-40F7-AF37-4E0A82B…  {5AC2313B-4696-4290-8BFD-6A570A6…  real         nein     3908        0
  239 │ Polygon(808 Points)   {AF218C73-FEC9-4DBC-B016-9BC976B…  {843DEA9D-FD1C-4094-97CC-B1ACB50…  real         nein     9475        0
  240 │ Polygon(471 Points)   {A6D9D0FB-BB29-41C7-B647-C874F21…  {1BC7B70E-852B-4BDC-B5D0-C0072AC…  real         nein     3947        0
  241 │ Polygon(965 Points)   {3BB138E7-E4CD-4476-8C85-390BE80…  {D287B7D3-24F6-4AC4-ACBC-B6F8CF4…  real         nein     3714        0
  242 │ Polygon(492 Points)   {04C0AAC7-6D56-4B9A-89E3-C81AE30…  {684EEAC3-9AE9-4E82-8760-E72D426…  real         nein     7107        0
  243 │ Polygon(946 Points)   {3F77828C-1A33-4E65-9F3E-91495FB…  {65FC3F67-B58A-4CCB-89D4-7703F1F…  real         nein     8886        0
  244 │ Polygon(650 Points)   {CCF3316C-9759-46B7-9CE4-8FA2CA0…  {4C1C457C-2F45-48E1-BC3E-9C5FFB1…  real         nein     6719        0
  245 │ Polygon(1417 Points)  {972F5F7B-70CB-41A0-B01D-1CDAEB9…  {5043B45F-4A26-4831-B35C-1E99ADA…  real         nein     1630        0
  246 │ Polygon(320 Points)   {031B2C76-FEEB-4398-9B46-2CF4D3E…  {6B9D0E3E-300A-41A9-BDFA-0B6ECB7…  real         nein     3985        0
  247 │ Polygon(533 Points)   {0A29DF96-361C-4F1F-8DE1-8722EA1…  {17ADC2BA-0DFF-4CB4-8424-0BD75A3…  real         nein     3186        0
  248 │ Polygon(323 Points)   {FAA62430-AEDB-4CD0-B293-6B698B3…  {28CFB01E-38E3-4167-AED9-23F9D36…  real         nein     1936        0
  249 │ Polygon(560 Points)   {C8E985E9-4FC1-4271-B58F-F4438B3…  {CBA0FBC5-0C78-4201-A236-538A595…  real         nein     3961       22
  250 │ Polygon(331 Points)   {C71D9805-A026-48E6-A28D-0AC9B47…  {9B9A0DDF-9822-4390-9447-8CC4F21…  real         nein     3937        0
  251 │ Polygon(608 Points)   {45D08AFD-165A-469F-BAB3-36D2536…  {05505AA5-4727-4906-859D-1195CA5…  real         nein     1873        0
  252 │ Polygon(164 Points)   {D107EF16-DA43-4660-8C0B-F374EC3…  {A13FC59E-EB39-466F-880A-F14943F…  real         nein     3942        0
  253 │ Polygon(908 Points)   {1F88B46B-18CE-42A5-96D5-DFE0005…  {C09FF121-4D0B-4026-BE44-B6C041D…  real         nein     2108        0
  254 │ Polygon(2044 Points)  {6EE59861-4BDA-43E8-B722-B24D04B…  {22A8F1E4-8684-4677-815F-E2CB772…  real         nein     6314        0
  255 │ Polygon(706 Points)   {9C99A56B-591D-4525-8159-728F7DF…  {C5ED6D0E-2FBC-42D1-AC7C-511CDD6…  real         nein     2400        0
  256 │ Polygon(602 Points)   {E170B555-45DF-4773-9107-9792869…  {4451A128-EBF2-42BD-A8EE-FEECE85…  real         nein     7500        0
  257 │ Polygon(881 Points)   {DC423724-A61C-4392-B1EC-F5ECA53…  {5E1F0507-DA0F-49B4-B018-F201A47…  real         nein     6103        0
  258 │ Polygon(841 Points)   {2F3D6097-69FC-4DD8-A4D3-EAF9A06…  {7ED3EB7F-F975-42F5-A860-1FCAA1E…  real         nein     7606        1
  259 │ Polygon(943 Points)   {4BD6F67A-140F-4D53-BD71-909BB03…  {EF9E0DC9-6CD9-44C9-BC24-85B1F4A…  real         nein     7134        0
  260 │ Polygon(838 Points)   {D99AC188-79F3-4A19-8761-F5F6B05…  {9AFD7924-EB93-41EC-9F88-9AAB614…  real         nein     3725        0
  261 │ Polygon(270 Points)   {BF787A54-9E58-44F4-9493-D5A6885…  {644A5D5B-C8D5-4DBD-BAF7-58ACE4F…  real         nein     7437        0
  262 │ Polygon(365 Points)   {85A25EFF-91E0-4B58-BEB0-99125E5…  {F5FB95DF-3643-4D87-9B5E-8589712…  real         nein     2126        0
  263 │ Polygon(773 Points)   {5E65138B-9E62-43D8-851D-B3017E4…  {A4A0D208-1AC5-4DCB-9351-C570A03…  real         nein     8857        0
  264 │ Polygon(974 Points)   {6F570E9A-38D3-46E8-9FCE-ADBB67A…  {EAE0F746-6F8A-493A-B4CB-CF5FE6F…  real         nein     1976        0
  265 │ Polygon(447 Points)   {AF9AE724-D6BB-4A7E-87ED-8A3BFE4…  {DB3AC401-27B3-47AD-85D4-7C34E02…  projektiert  nein     7453        0
  266 │ Polygon(1035 Points)  {976827BE-1904-4F76-A352-046BD17…  {4A899BF7-115C-4674-9501-D391BF8…  real         nein     3803        0
  267 │ Polygon(294 Points)   {E51242DC-A510-4673-A7A8-2545907…  {194B6A29-1467-4C63-A15C-C4BAB2C…  real         nein     7204        0
  268 │ Polygon(1477 Points)  {AAD4EBD2-B987-425F-897F-07F473E…  {4D74865E-5E6A-4727-996C-B398FCC…  real         nein     6017        0
  269 │ Polygon(364 Points)   {AC374CC4-A48F-4D17-984A-F7D681F…  {590F09D6-2CDF-4EB4-A629-C060DD3…  real         nein     3916        0
  270 │ Polygon(495 Points)   {3BDD89ED-0B2D-49E2-9E51-31BC869…  {EFD180D7-1FAA-4A3C-BCDE-47EC3B1…  real         nein     7078        0
  271 │ Polygon(480 Points)   {61DBAED6-CC74-4848-B2AA-C9769AC…  {B615B846-429F-48CA-9F3B-8772A40…  real         nein     7277        0
  272 │ Polygon(497 Points)   {F1400045-A462-422A-B14C-92B97C3…  {D1B7DD93-5C6B-44AF-8CEF-3315211…  real         nein     1893        0
  273 │ Polygon(432 Points)   {9E8BC4BE-425A-49C8-BA1C-89648C7…  {A5F13273-F4E8-45DC-896B-1CD818F…  real         nein     1945        0
  274 │ Polygon(631 Points)   {CF1F925A-19B8-4F72-9233-6978B0A…  {FA2839AB-AF91-4B67-91DD-55F36D4…  real         nein     7247        0
  275 │ Polygon(518 Points)   {A03E9077-3F35-4ECF-A124-74721B2…  {114540AF-B020-4C36-887E-CD53BD7…  real         nein     8844        0
  276 │ Polygon(1172 Points)  {892802AF-5D83-4A29-B21F-2CC6092…  {4FDEC948-D8D7-4E14-A647-8FCC083…  real         nein     7447        0
  277 │ Polygon(337 Points)   {1228B2D7-5387-44CF-B615-32B018D…  {4CEA7D1C-E658-446C-935E-C3A08C1…  projektiert  nein     7454        0
  278 │ Polygon(564 Points)   {96278A62-3F02-4FD7-A426-1E56EAF…  {BD50B16D-CB96-44F6-A0AF-1BFBB29…  real         nein     7000        0
  279 │ Polygon(146 Points)   {EF2641C8-213B-442E-B30A-422D8FA…  {FA767015-1361-4E2B-B93F-7894A18…  real         nein     9999        2
  280 │ Polygon(875 Points)   {B9150E73-D662-48F8-823E-78489C0…  {35B001EC-A46A-4131-AA8D-612BD9F…  real         nein     8843        0
  281 │ Polygon(737 Points)   {C86DED85-EE87-49D0-9FC9-0D4E280…  {7244D17E-FABF-4849-AD38-C9D7DF3…  real         nein     2540        0
  282 │ Polygon(1109 Points)  {27CCF8D2-3E86-4F90-905F-B537E82…  {C34325E6-61D6-4A9F-8C90-1E0FC4A…  real         nein     1147        0
  283 │ Polygon(221 Points)   {D50E52F5-EA90-4615-9258-FB70296…  {F18227AF-696F-414D-A218-47E1003…  real         nein     3781        0
  284 │ Polygon(454 Points)   {E4E89E8C-9C10-4B09-A4AF-D6C814E…  {C6664735-9AD6-48DD-A675-1DE8515…  real         nein     7746        0
  285 │ Polygon(919 Points)   {745AB9D1-E6F8-40F4-84C2-B98DC08…  {63A329B8-DD41-4514-9701-54F9855…  real         nein     4717        0
  286 │ Polygon(617 Points)   {E76C903D-4916-4560-9D5D-7A16E5D…  {3669B461-BADA-4BFB-B456-89C0F25…  real         nein     1896        2
  287 │ Polygon(430 Points)   {755501EA-6A3F-4F79-8930-78557B6…  {D24CC746-C562-41DB-87CD-5764DFF…  real         nein     3963        0
  288 │ Polygon(517 Points)   {07230F07-1056-4C32-8216-56A74ED…  {85341619-03A0-4246-8F00-0EEC0A7…  real         nein     6636        0
  289 │ Polygon(1238 Points)  {3CEC4E41-12D9-4D43-BB7D-F3FA419…  {C4A935EF-E0B3-4CB6-BBA3-89831EA…  real         nein     3555        0
  290 │ Polygon(1065 Points)  {70E40C02-87DC-45C5-A041-57792ED…  {863CF5CC-66DB-4F99-947D-67581F8…  real         nein     1856        0
  291 │ Polygon(901 Points)   {1E1C3D39-DBD5-4A84-880D-7FDA12A…  {415289BF-3CCC-4230-8383-7E8963F…  real         nein     6113        0
  292 │ Polygon(997 Points)   {CEF4CC90-5098-4C6E-AB59-C71D89D…  {B04E6461-6DEF-4BD7-9209-40842A0…  real         nein     3619        0
  293 │ Polygon(477 Points)   {6369B25D-243F-4066-B991-CFA2AD1…  {E5487B1A-B36B-4288-B3A1-8291604…  real         nein     7235        0
  294 │ Polygon(1615 Points)  {2F1D723D-85E7-4B2A-A310-5482993…  {8E60592E-CE66-4BAD-B4E2-E4F93A5…  real         nein     6133        0
  295 │ Polygon(1235 Points)  {BA6E12FF-421C-4CC8-B88F-BB8D977…  {4005B9BE-0E1F-4C2A-AECF-11E671C…  real         nein     3099        0
  296 │ Polygon(419 Points)   {7958DCD0-58B4-43F1-B821-423C764…  {F9FFA508-4A38-4AEC-BBAF-69BAF44…  real         nein     2406        4
  297 │ Polygon(837 Points)   {50114F56-34A9-4E45-9ABC-5115DF4…  {40FD3DBD-88A3-43F9-B9C4-1181998…  real         nein     7175        0
  298 │ Polygon(702 Points)   {EDA20AD8-4FED-4C71-8133-BE72EE7…  {8C052C2C-CE65-489F-B6B1-B4840B6…  real         nein     7310        0
  299 │ Polygon(962 Points)   {96EB62C5-7675-4F0C-844B-96A7096…  {70F007C5-B8D7-4B80-9D5E-CC0169E…  real         nein     1145        0
  300 │ Polygon(1040 Points)  {1C27EDCD-13C8-4C0B-824E-C4043F4…  {7AE658A7-B344-48BD-B7BB-9FD2A50…  real         nein     6300        0
  301 │ Polygon(376 Points)   {87A63F44-8D9F-4005-BD76-45E0575…  {3035476B-D389-49EF-83DA-6AD153C…  real         nein     1943        0
  302 │ Polygon(580 Points)   {CA494ED4-F192-468A-937F-5DC697D…  {B3B6925C-40C5-430B-BB15-759A063…  real         nein     6086        0
  303 │ Polygon(659 Points)   {D8235907-FC07-4DCE-9E52-D13BC41…  {1F19E110-B45F-413B-A0B9-3E66B54…  real         nein     3755        0
  304 │ Polygon(1749 Points)  {36258ED0-0997-4B54-91D9-FC0DAA2…  {88135452-9652-4ACF-9D0F-C237624…  real         nein     6192        0
  305 │ Polygon(587 Points)   {111811CA-0A2F-43DB-B32B-1A21D86…  {129BCD6A-BBF2-41F7-B79F-4495C47…  real         nein     7323        0
  306 │ Polygon(1485 Points)  {F6C22EF5-2E29-407A-A299-8EE0F87…  {BE868527-52CC-446B-8AE2-6FF082F…  real         nein     6376        0
  307 │ Polygon(543 Points)   {478B027E-968C-471C-8E79-0183684…  {0FCAE0ED-618C-4CBE-AB72-1304682…  projektiert  nein     7433        5
  308 │ Polygon(356 Points)   {C39D79FA-BCBE-45D5-B34F-BA9D1E5…  {74BE7EF9-8043-40AB-B860-DF2E615…  real         nein     3910        0
  309 │ Polygon(548 Points)   {104E581A-9BC7-4C6A-BF32-06F5DBB…  {2190CDAA-C127-4E9B-9951-A4D9F94…  real         nein     2336        0
  310 │ Polygon(467 Points)   {2F75B305-827D-4D19-B92B-C28CE82…  {EE9838CC-8E1D-405D-B872-D0611C9…  real         nein     7202        0
  311 │ Polygon(135 Points)   {A5447D71-1AB2-48B3-9A4B-A560840…  {D1FCDFD3-4856-4C8B-A5BA-6AA34F6…  real         nein     1973        0
  312 │ Polygon(1168 Points)  {AED14808-B39D-4629-A0D7-2AD31D8…  {B28A8EEC-D45A-4020-AEF2-46B5415…  real         nein     8852        0
  313 │ Polygon(192 Points)   {451898F4-2C25-4585-8995-EAB72B8…  {BE4DD36A-FD07-40D2-AAF2-1F23C36…  real         nein     6484        0
  314 │ Polygon(709 Points)   {01989A63-466F-45BE-A28F-20DC8A3…  {382B3C46-A08A-4603-89BF-8229C11…  real         nein     7432        0
  315 │ Polygon(490 Points)   {6D93EDB9-ACE8-44E1-BC97-086CB33…  {955AC621-D198-416A-B372-43ADBB5…  real         nein     2738        0
  316 │ Polygon(994 Points)   {649718C1-BB3F-42C4-8394-06F027E…  {F48EC187-EB2A-4954-B36A-0FBEA84…  real         nein     1977        0
  317 │ Polygon(560 Points)   {8CC689EC-584E-4C34-A1D9-D501405…  {D3A74D12-358D-4D61-9EB2-33AAB85…  real         nein     6387        0
  318 │ Polygon(338 Points)   {A4032C06-91A2-49A3-8C9F-A8E1379…  {F143865D-5045-4551-8B61-A05C2F8…  real         nein     1666        0
  319 │ Polygon(1015 Points)  {86117DCE-CE56-4AFC-A9BC-54F0CB5…  {E43E8460-AA72-4520-9892-4A277B1…  real         nein     9450        0
  320 │ Polygon(313 Points)   {2F2114D4-1AD9-4134-8EDC-35F781F…  {797F2D81-95B5-47D3-9854-836DDE8…  real         nein     3992        0
  321 │ Polygon(1661 Points)  {A9606986-77C5-4091-8097-7926349…  {2C76B9DB-EB7D-4312-A81E-31AB136…  real         nein     6064        0
  322 │ Polygon(388 Points)   {FCEFDDD5-BE20-4A8A-8F03-8E5AACA…  {F985E5F1-0ADC-4FED-A2FD-FA20A37…  real         nein     2518        0
  323 │ Polygon(345 Points)   {5394CE99-7F46-4626-A4AF-A7A3073…  {9E1F7F0A-65CE-4467-8E3F-FC331F8…  real         nein     7013        0
  324 │ Polygon(404 Points)   {B7DFA0B1-84F1-43B9-9A10-F44E61B…  {09440AEC-8657-4BD9-89C8-9AC29F3…  real         nein     6632        0
  325 │ Polygon(1342 Points)  {6E7266A5-1374-4622-B2BF-F8D21E0…  {93C770E6-61FE-414B-BCFD-3113744…  real         nein     8200        0
  326 │ Polygon(686 Points)   {9FAC495F-FBDF-41D5-8F45-FC4AF13…  {93387388-E53E-409A-AB10-E565764…  real         nein     1656        0
  327 │ Polygon(802 Points)   {A8E0C3D5-679F-4FCF-B059-402DC41…  {C6F9EE5E-6F4E-467F-9D36-A0259EF…  real         nein     1898        0
  328 │ Polygon(211 Points)   {4C20E6D4-4E9F-4BFA-A85E-2E0E4B1…  {0215F23D-94B8-4289-B4D5-DEF7E32…  real         nein     7741        0
  329 │ Polygon(508 Points)   {0F2B2A54-D554-4D67-916E-B37C562…  {1E3DB9FC-9BD9-4972-BD10-BEF7D2E…  real         nein     7505        0
  330 │ Polygon(5107 Points)  {2A02E77B-E467-46E7-86D0-6B5EBE6…  {F22BF41A-CD43-4A29-AC0F-3C00D76…  real         nein     8758        0
  331 │ Polygon(423 Points)   {2778FF69-698D-4989-9855-A28F1FB…  {A3EFB092-117D-4930-A7F7-A58B0D0…  real         nein     7745        0
  332 │ Polygon(784 Points)   {1E3F6567-F8E5-45BD-8384-6208BDD…  {A353A2D6-BE5C-43D5-A970-2A67FCD…  real         nein     6463        0
  333 │ Polygon(493 Points)   {23B07DFF-8BB0-4EC4-A784-858CD2F…  {36E0D55F-7B46-4C13-85C3-81C411C…  real         nein     6684        1
  334 │ Polygon(266 Points)   {E417AD67-D2C6-4CCC-B123-0703C11…  {F26B6A54-7072-4376-AE43-A53188E…  real         nein     1907        0
  335 │ Polygon(269 Points)   {CD943ADD-5B98-436B-B658-4126CE3…  {2E2E5ABF-F139-42B7-8B1C-49675DA…  real         nein     7456        0
  336 │ Polygon(532 Points)   {C4661AD3-EBB2-4B29-A5D3-3D081FB…  {B5F86F43-E732-489C-B7FA-70FE263…  real         nein     2127        0
  337 │ Polygon(680 Points)   {91EC9374-0468-4062-85A5-461DF19…  {C3329735-53B7-44A4-AB80-4655BCE…  real         nein     2105        0
  338 │ Polygon(456 Points)   {0D297608-CEC5-4EAD-8848-4188009…  {E82B82EF-730A-454B-B068-D8B309C…  projektiert  nein     7502        0
  339 │ Polygon(30 Points)    {8D956F8A-439A-43FE-9715-5E20183…  {A2088720-B4CD-4DDA-8A91-BB5CAC8…  real         nein     1985        0
  340 │ Polygon(449 Points)   {596DECCA-34A7-4F7D-8A6F-8A7724F…  {96228CC8-6A14-4B44-A3E2-93E86AC…  projektiert  nein     7502        0
  341 │ Polygon(1202 Points)  {C5C196BF-DCFA-4FCC-BFD4-CDEED87…  {D9F46691-0398-44E5-BB10-44081A5…  real         nein     3703       41
  342 │ Polygon(346 Points)   {BCCA74DE-FD4E-4606-8FEF-CD6D849…  {F38360BE-37DC-4D01-8446-737FC82…  real         nein     6673        0
  343 │ Polygon(460 Points)   {58B83EF6-A1FE-4ABE-B377-44C61FD…  {F408B373-F2DE-4C7D-A56E-7BDD0FE…  real         nein     8849        0
  344 │ Polygon(293 Points)   {8A0DCF0C-4C1D-4660-823B-F8D0641…  {22DDFCC3-2F13-4F1D-B390-0BE20CD…  projektiert  nein     7116        2
  345 │ Polygon(269 Points)   {615EC949-FA86-4842-A9F3-E3DADF8…  {08798251-EAD5-46EA-A2F7-5A3ECA5…  real         nein     6442        0
  346 │ Polygon(580 Points)   {073C3053-D501-47BA-9751-59706C2…  {C85FD9F1-015F-409B-B915-985729F…  real         nein     6418        0
  347 │ Polygon(784 Points)   {623B9356-8E16-4816-B170-8FE669F…  {0D9C3331-25AD-40FE-A863-87F9320…  real         nein     6067        0
  348 │ Polygon(858 Points)   {238A5D45-2CBC-449D-8DE4-95B106D…  {DC39A514-E900-41ED-8497-6EA9A35…  real         nein     9463        0
  349 │ Polygon(530 Points)   {DCC57E97-B458-42DE-BB06-0723E19…  {C916A7ED-A24F-4884-B110-F18D064…  real         nein     3807        0
  350 │ Polygon(697 Points)   {85365467-2997-4ABD-BFE4-F7B7752…  {B103867A-39EB-4923-95E5-B8D883B…  real         nein     6464        0
  351 │ Polygon(952 Points)   {315F208F-36C1-48D4-A201-ACA1EC3…  {AF6BE353-C8FE-4265-A47C-EF83CF1…  real         nein     3154        0
  352 │ Polygon(655 Points)   {015CA9B7-A230-43B2-A6F3-CAD1A36…  {AF3EB269-B095-40C9-9A5E-DDC2224…  real         nein     7270        0
  353 │ Polygon(772 Points)   {404DC044-EAA6-4980-875A-4F4744C…  {2841E924-D795-41C7-833F-C3A0326…  real         nein     4229        0
  354 │ Polygon(759 Points)   {3167DCCE-4052-493E-9EA2-96C254E…  {87EBD9C8-6393-488F-AE41-0411987…  real         nein     1337        0
  355 │ Polygon(1040 Points)  {BFF78512-1463-415C-9C30-06C08DA…  {58A5399F-A062-4D68-99C8-DE0150A…  real         nein     7166        0
  356 │ Polygon(515 Points)   {7CA8FCC3-324E-424A-869E-EFEF58A…  {28395CF7-ED2A-45DD-8F31-49A38A2…  real         nein     7513        0
  357 │ Polygon(553 Points)   {C65F0175-4A24-4EBD-AF2C-F51D0BB…  {B973CBFB-1521-43A4-B012-8543B61…  real         nein     3752        0
  358 │ Polygon(585 Points)   {515F1E4F-A1F3-46A6-BF2E-95E0341…  {9D1138D8-1C34-4829-9E22-D24CBEA…  real         nein     1925        0
  359 │ Polygon(697 Points)   {BA5E8BB6-2AA5-4095-B801-051E4B3…  {BB5F8A72-5D05-49D7-A02A-92B317F…  projektiert  nein     7460        0
  360 │ Polygon(726 Points)   {1BAA69B2-12AB-4A36-8657-7AA664B…  {B00B8446-271D-48EF-8258-415C5BB…  real         nein     8755        0
  361 │ Polygon(1598 Points)  {FCE821F8-2AA8-47AA-88C4-A22B90F…  {BB9EC3F2-F2A9-464E-8C7B-CF7D7B1…  real         nein     9057        0
  362 │ Polygon(962 Points)   {208C427E-5892-4132-9F3F-6031E4F…  {E032CC59-8D31-434F-B471-DFDC6ED…  real         nein     6710        0
  363 │ Polygon(608 Points)   {3BC43BBA-F4D7-41FE-A392-81BBF55…  {21E999CD-30D7-4466-8CFC-9266FEE…  real         nein     3783        0
  364 │ Polygon(1373 Points)  {2DD76511-6B06-4A5A-B5E3-3FE5C94…  {938BEB90-3D2B-4AD9-BF69-843E314…  real         nein     1880        0
  365 │ Polygon(645 Points)   {4F923363-2743-44C2-8BAA-0956578…  {267B58A6-B136-4637-B773-EE8370D…  real         nein     3944        0
  366 │ Polygon(909 Points)   {BB3F289C-FE03-4A3E-ABF5-4618D84…  {03D14C40-5DD1-43F2-9A69-C7A9423…  real         nein     9473        0
  367 │ Polygon(1612 Points)  {2DEEB4C4-8400-4AC4-B0F0-2B2AE61…  {A5F2053E-9330-46DE-963A-18148A8…  real         nein     6340        0
  368 │ Polygon(333 Points)   {B3740E56-75CB-4D33-93AD-6CB7B9E…  {64DCF60E-6030-4F4D-AFE0-5281958…  projektiert  nein     7122        0
  369 │ Polygon(414 Points)   {D75AA487-BC0C-4A0F-8F7C-0CC9F42…  {BF47AF53-EA89-4C74-ACC8-2B4A2D0…  real         nein     6685        0
  370 │ Polygon(806 Points)   {1379632A-39C9-4D9D-80DC-1A91F33…  {0F44BD3A-027D-4BBE-ABA1-876CA86…  real         nein     9057        3
  371 │ Polygon(500 Points)   {67855420-152C-4E73-A654-F317BC6…  {6E68D1F3-A40D-48C5-AE0E-361695D…  real         nein     6720        0
  372 │ Polygon(507 Points)   {557939C8-2D81-46AE-B855-B00FC20…  {75166E78-CE95-4C49-84ED-0C0EDDA…  real         nein     1920        0
  373 │ Polygon(1315 Points)  {C5D3778D-ECF4-4ED0-BBC6-F528BD6…  {0195D45C-62DE-4A6A-82AE-114A0AF…  real         nein     1884        0
  374 │ Polygon(341 Points)   {856CD357-5598-4DF4-8002-5861111…  {4A333C25-8204-4A67-A1BB-AB0BD36…  real         nein     7278        0
  375 │ Polygon(567 Points)   {E7982209-936A-4665-BED3-619077C…  {1465AEF1-A1FB-4915-BE5F-9F6FB18…  real         nein     7215        0
  376 │ Polygon(635 Points)   {6B28A83B-36AE-45A9-9C33-6AAA23A…  {BB41D79F-6148-4921-8254-BE28843…  real         nein     7083        0
  377 │ Polygon(252 Points)   {A9D12224-2DEB-431B-B5D4-2CC7342…  {E5985782-FA90-4B56-BF16-58CCF09…  real         nein     6473        0
  378 │ Polygon(1181 Points)  {BB1A271C-0D4F-4735-A58D-0A40266…  {C2B03113-2632-46B1-BC6B-6904B52…  real         nein     9058        0
  379 │ Polygon(533 Points)   {8C7548E7-99E1-4041-B1B7-84B3CB4…  {D6B9B964-4C63-42F0-B998-01B1D2A…  real         nein     1453        2
  380 │ Polygon(208 Points)   {89007691-DE14-460A-8CE1-B773F18…  {2C7DF3ED-663E-4F43-9444-2A1BE27…  real         nein     7436        0
  381 │ Polygon(514 Points)   {C81650F5-938D-4810-9A80-FB24E67…  {CFE75B36-F524-486B-9385-33ED103…  real         nein     8226        0
  382 │ Polygon(1332 Points)  {81082269-5C6E-4417-8E9D-E0571C8…  {4FE1F7DC-8A81-4FA1-A409-57E8BDA…  real         nein     3538        0
  383 │ Polygon(371 Points)   {016C5DB8-EA8D-47DC-8727-2D393AE…  {CBF461F8-5214-4ACC-914A-52B29B8…  real         nein     1669        5
  384 │ Polygon(130 Points)   {B1ACA5B4-4D05-4479-BBEF-301CC47…  {FDD38941-4950-4AF1-935C-B54CF29…  real         nein     1345        0
  385 │ Polygon(1146 Points)  {31EAAF2F-7324-45A9-B211-BB9F32D…  {9D7DB0FD-FEB5-4E43-97C8-57A7558…  real         nein     6403        0
  386 │ Polygon(482 Points)   {430F6675-E9BE-4EA7-AF9C-CAE1E21…  {44B7F8F7-59D7-479C-B869-BF8EDED…  real         nein     2906        0
  387 │ Polygon(614 Points)   {A74E48AF-77BF-456A-A113-2E8BCCE…  {7187B080-3DF4-4BB9-AE38-3F03B48…  real         nein     7064        0
  388 │ Polygon(735 Points)   {5E6FDB7E-7C36-4B95-97A5-CD9F06A…  {08CDE62C-9EF8-4256-A092-C705863…  real         nein     8753        0
  389 │ Polygon(1271 Points)  {7DE885FA-C598-4FE3-83B3-1C81C25…  {A57EB7C3-2AE1-4736-9AAE-728CE20…  real         nein     9200        0
  390 │ Polygon(1553 Points)  {BFDDE22D-F019-41A4-8714-39B8EBE…  {135148C9-7F9D-4F26-AE0F-397B315…  real         nein     9205        0
  391 │ Polygon(1595 Points)  {DFE8DA21-1127-4504-9E3B-58E30C7…  {0CB0F53C-B9A4-4A71-B421-EF46597…  real         nein     9100        0
  392 │ Polygon(280 Points)   {7D8518A2-BAB7-410B-AD0D-27F034B…  {9BF278E3-0054-4B3A-B28E-9715FDB…  real         nein     6702        0
  393 │ Polygon(257 Points)   {4DE8469F-CB70-4BA8-B98C-F8BF03C…  {87D48D6B-3350-495D-87D2-04F41A2…  real         nein     3979        0
  394 │ Polygon(569 Points)   {5CCFAB15-915E-4872-9E51-AA771EB…  {C4203707-A804-4C2E-9087-EA12516…  real         nein     9478        0
  395 │ Polygon(496 Points)   {A9F44C5F-F8AC-4303-8182-7AF5950…  {C1999FEC-7E9E-4276-A6CE-A61EC1D…  real         nein     7233        0
  396 │ Polygon(680 Points)   {FE59B7E8-D70F-4874-B6C8-7E4E8DC…  {DEB61E99-942E-4491-B33A-F018CB6…  real         nein     1428        1
  397 │ Polygon(594 Points)   {08D3A0AD-C4C1-450C-8291-0FD5C02…  {A6000682-033E-4BE0-994C-6B5913E…  real         nein     1325        0
  398 │ Polygon(437 Points)   {456BA62B-BF9B-4368-9DA4-C1BEB3B…  {F97AA081-C175-49CA-8117-E07B3FE…  real         nein     6415        0
  399 │ Polygon(2263 Points)  {3D69784F-FBBA-41A9-96C5-99748D3…  {C876C3F4-A37D-46DB-AD1C-2FF0378…  real         nein     6386        0
  400 │ Polygon(511 Points)   {50699C1B-16CD-42FB-A4D4-628C72D…  {9977C5C8-1462-4553-8F34-EA4C609…  real         nein     1634        0
  401 │ Polygon(2465 Points)  {D3DDD004-A4C9-413D-BFB3-EB0C385…  {1566FA2B-7EA5-4BAF-94DF-EBE07C0…  real         nein     8854        0
  402 │ Polygon(367 Points)   {0B4C30A5-DFD0-4646-AE8D-9C3D090…  {2BDA6616-421F-49FF-95D8-18D56C1…  real         nein     8846        0
  403 │ Polygon(1000 Points)  {848C709F-83A7-4F57-BAB3-3CEC431…  {5840B866-8CA4-4EEE-B364-EE6D085…  real         nein     1658        0
  404 │ Polygon(1483 Points)  {0DF14EAE-C76F-4AC4-BDC9-C4D33A0…  {32A0D9F9-A1A8-48AB-8191-E1E1007…  real         nein     8638        0
  405 │ Polygon(415 Points)   {97A8B2FA-EDB7-4F20-A4FA-E4CE81B…  {ED53643C-1721-461E-9033-5B93565…  real         nein     1911        0
  406 │ Polygon(826 Points)   {66C24359-8BC4-487C-8DD8-6A51537…  {87DA02DC-FBC3-481F-A1F0-E454514…  real         nein     1654        0
  407 │ Polygon(471 Points)   {CE575FDE-A684-493B-9985-E5BA079…  {40E5D89F-E773-4B0F-9A8A-8F5E415…  real         nein     7167        0
  408 │ Polygon(587 Points)   {6EF779D8-0F48-438A-B155-B0C3BBF…  {EE68C6E2-10DF-4D19-9A89-BFCC185…  real         nein     7075        0
  409 │ Polygon(230 Points)   {BFE33757-4FD8-45E7-A39A-46D5D51…  {4EF42F12-1C0D-47AF-8451-23132F7…  real         nein     1955        1
  410 │ Polygon(758 Points)   {3546DD22-1727-4389-9D9B-834B9CA…  {720C6329-1455-4109-9269-59F2108…  real         nein     1957        0
  411 │ Polygon(826 Points)   {4760DBA9-E0AE-4F97-82FE-D5F0F48…  {D601688F-BC57-4D03-870F-D9653B8…  projektiert  nein     6546        0
  412 │ Polygon(799 Points)   {DB7D6CD2-F012-471C-AB15-48584AB…  {8BB886CE-9024-4B2F-B119-84CCBF3…  real         nein     1264        0
  413 │ Polygon(859 Points)   {263CDE11-E111-46EA-8FF9-7DA553E…  {AF0BE9A5-D170-4330-BE6C-067D872…  real         nein     3854        0
  414 │ Polygon(688 Points)   {5B9983F0-1CDD-4631-B0EE-250968D…  {39E60289-211C-4523-9015-3EB33F2…  real         nein     8775        1
  415 │ Polygon(2197 Points)  {C6C8CE99-28D5-4643-95CA-7620085…  {743B3726-7CDB-492F-850E-AB12EAF…  real         nein     1269        0
  416 │ Polygon(2440 Points)  {F4FDFA25-9C8E-4B01-A3A7-4C964F9…  {1E7D51B0-854A-49E0-81A8-FBCF71E…  real         nein     8488        0
  417 │ Polygon(691 Points)   {A7D71F51-2502-4D09-85A3-49D601E…  {54C517BB-F0D8-4AFC-912B-9332CDC…  real         nein     3764        0
  418 │ Polygon(572 Points)   {6FF321B1-5C8E-45B4-B46B-08CF5E2…  {BC44CDF8-A8B4-4A4D-BDBC-3475876…  real         nein     8845        0
  419 │ Polygon(2578 Points)  {0CEE7691-06B8-4CD7-B9AD-5C250AB…  {DA9DEA3E-17E7-4AAB-8597-CDE427F…  real         nein     6388        0
  420 │ Polygon(527 Points)   {E2BEEC9D-2A6D-49A6-BDE3-F185333…  {0DA5084A-4373-43B0-BDE7-7380C34…  real         nein     7402        0
  421 │ Polygon(433 Points)   {5923303E-FEB9-4188-B080-7FEA944…  {8A1342BB-3CC7-4B49-8E23-03BE569…  real         nein     1446        0
  422 │ Polygon(497 Points)   {9AF909A1-D918-485D-AFC6-C8A6118…  {205CB361-2A2A-48B0-81D2-2254A1F…  real         nein     6683        0
  423 │ Polygon(1322 Points)  {A287EBA6-932E-474C-A6AD-C3DF5B9…  {292B140F-A2EF-40B8-A1FB-99101F9…  real         nein     8496        0
  424 │ Polygon(1024 Points)  {5CED0DA5-0733-4C51-9808-95E7E38…  {874DA441-5B7D-42FB-B26A-881C387…  real         nein     9056        0
  425 │ Polygon(327 Points)   {DA6A7458-1396-432F-9BDB-C64AB31…  {E3BEBFEA-1902-4C81-8575-6BD391A…  real         nein     7537        0
  426 │ Polygon(910 Points)   {91EE9DFD-5396-4AB1-BAFC-1F7FE24…  {A282FA82-49CF-4A21-B3AF-5143E2A…  real         nein     9657        0
  427 │ Polygon(832 Points)   {F3AACD0F-5FC7-4D57-A313-DFDD7A4…  {A2896C0E-5431-4C80-AB17-9DC38F3…  real         nein     2740        0
  428 │ Polygon(401 Points)   {9E23DF1F-880F-41D5-B34F-AAB5841…  {46F7ED70-2BF2-42E7-9978-3436FEA…  real         nein     1875        0
  429 │ Polygon(694 Points)   {4B4A1F9B-F786-4CB5-942F-E94B54F…  {165DAF88-0DE9-4956-8CF6-D724BD4…  real         nein     6022        0
  430 │ Polygon(622 Points)   {A85C4A13-1AFA-4EAC-B405-972A447…  {282F73EC-66BB-4EF4-887E-2F2E0E4…  real         nein     3236        0
  431 │ Polygon(810 Points)   {A9EBCCF6-7E0B-4679-ABEF-3D9C94D…  {8C0B90F8-3397-4DE6-BDC8-96AC290…  real         nein     3618        0
  432 │ Polygon(765 Points)   {E7C6537E-14A2-40B5-8E46-A160C28…  {18EE257F-F665-4D26-9AB8-2412EC8…  real         nein     6102        0
  433 │ Polygon(364 Points)   {64095FDE-EBB3-432D-B784-8294D08…  {D887A16B-C450-4215-BADD-2F86CAC…  real         nein     2608        2
  434 │ Polygon(329 Points)   {CC1811E7-3442-4EE0-A3E5-714DE74…  {9A70EDA4-EFF3-4372-8D06-487214B…  real         nein     1346        0
  435 │ Polygon(682 Points)   {EEB56B85-A941-481F-B13E-556E19F…  {B1B2D806-E65C-4766-B50E-C42056C…  real         nein     1656        1
  436 │ Polygon(1140 Points)  {6BA55C38-F88B-4ACE-BA82-9408BDA…  {CFE8CD06-FA74-4F94-96B2-0032ED8…  real         nein     6010        0
  437 │ Polygon(477 Points)   {3655059C-FB88-4266-A3A7-B35907E…  {564DB5DF-3B24-4BB0-946D-77E662E…  real         nein     7252        0
  438 │ Polygon(479 Points)   {81276B49-D73C-47A0-8745-80CA455…  {A9B41358-F71E-4971-BA5A-DE308E8…  real         nein     4313        0
  439 │ Polygon(671 Points)   {5D7216A9-D3E2-4104-A09F-14F706C…  {54DBC94F-DDA5-4B8E-AD80-A495B0B…  real         nein     6745        0
  440 │ Polygon(852 Points)   {E9219721-812A-4AC2-9AD1-918FF3D…  {B988118C-D5CC-4074-BDC1-F3D5E0F…  real         nein     3054        0
  441 │ Polygon(777 Points)   {39728832-8F45-47C7-AB2E-716FABA…  {5CBE915B-673E-43E4-B594-DDAB500…  real         nein     2545        0
  442 │ Polygon(394 Points)   {1D6BB8F4-F815-4ADA-BF64-6986059…  {C928FAFD-25E6-41DC-8143-AFBC538…  real         nein     3557        0
  443 │ Polygon(285 Points)   {536D5901-C6A4-4308-9118-75F659F…  {1BF3FD09-12D8-4CA5-90BB-C6D6AFA…  real         nein     6672        0
  444 │ Polygon(332 Points)   {3ADD299F-B5EB-4BC0-894E-9C7358F…  {9886CC2E-33EE-4B70-B1DD-40469B1…  real         nein     3985        2
  445 │ Polygon(522 Points)   {14C9B200-0ED1-4C5C-A4B9-FC6BE0D…  {5EA1B419-A8BA-40A3-BCC9-5D62566…  real         nein     1974        0
  446 │ Polygon(960 Points)   {41A4581E-A388-4E12-AE4B-16ED192…  {A0B2678E-44D5-4EF6-856C-BB09FF7…  real         nein     6430        0
  447 │ Polygon(2220 Points)  {4000FB79-F384-4363-AF2B-335C6AE…  {891D1924-1A9C-4633-898B-D3F2728…  real         nein     1070        0
  448 │ Polygon(407 Points)   {380A81D7-3A12-4726-8B99-59B1583…  {9F3663A1-9F54-437E-A370-8C924D4…  real         nein     7748        0
  449 │ Polygon(806 Points)   {486D288E-363A-421F-A94F-B3068F9…  {9E0A80E5-52A2-4095-B3F2-3C4F35D…  real         nein     3813        0
  450 │ Polygon(1357 Points)  {A5EC9B5F-C09A-429E-B460-392550B…  {600CD0FD-66FF-4F00-940C-B99C1F9…  real         nein     8302        0
  451 │ Polygon(545 Points)   {7499D35F-623E-40C8-9C8F-C39917E…  {5E819F49-156C-4B32-8680-189B25F…  real         nein     6703        0
  452 │ Polygon(693 Points)   {488A7B88-3A6A-499F-8EF7-21DF96C…  {51D9F735-827A-4B40-8421-1047B08…  projektiert  nein     6534        0
  453 │ Polygon(323 Points)   {947DFDCE-7627-41FF-A3C6-7E79D6B…  {B9FDEE13-564B-458E-BFE4-0968D5B…  real         nein     3717        0
  454 │ Polygon(449 Points)   {E4336186-16B3-473A-A75C-435246B…  {987493B5-5742-4162-A019-7BC07B4…  real         nein     2340        0
  455 │ Polygon(510 Points)   {30384ADE-1869-4670-9501-25DB047…  {3E8C7D75-376D-4BB6-8F2C-CC31C28…  real         nein     2523        0
  456 │ Polygon(253 Points)   {DAFECFEC-2824-486C-8089-3B55FF6…  {0C7E56E4-BAD0-4584-A87E-B45C121…  real         nein     7456        2
  457 │ Polygon(740 Points)   {0E0E16B0-9794-4CC9-B67A-5396C85…  {B55FA635-477F-47C8-B73F-B5B747C…  real         nein     6692        0
  458 │ Polygon(866 Points)   {84B488B9-339E-4648-B386-1D0C344…  {DEEF032A-C08A-499C-B50D-39E9335…  real         nein     9533        0
  459 │ Polygon(983 Points)   {D8898F5D-18CC-4D94-9345-8DD85AF…  {857CCCF7-8B1B-40CD-9FCB-F0D0696…  real         nein     1188        0
  460 │ Polygon(382 Points)   {F39FAE9E-EC0B-4FE6-965D-6A1D71B…  {D45EB0B0-3710-4421-98FC-70B89A1…  real         nein     6517        0
  461 │ Polygon(361 Points)   {2B770BA6-38C7-414C-9D79-05A09CF…  {ED47B067-A747-4CA9-B847-9D8F081…  real         nein     3967        0
  462 │ Polygon(1186 Points)  {4B638BDC-4FA0-41E5-A27E-57D8959…  {8FB8F88B-0E78-4D53-B768-194DFA4…  real         nein     2318        0
  463 │ Polygon(834 Points)   {71E55B63-610E-4611-8DF1-C66FBEA…  {ADDBF81B-E609-4C22-81BF-9E7C3F9…  real         nein     8820        0
  464 │ Polygon(1146 Points)  {9F16022F-D1E5-4886-80BD-0D58ED4…  {1930AEE6-D2FF-489E-9D0B-2CC5987…  real         nein     8722        0
  465 │ Polygon(166 Points)   {09EA2CC9-E13D-422C-908C-6D06A6D…  {208D233B-63F3-400D-97A3-B408BEA…  real         nein     3987        0
  466 │ Polygon(224 Points)   {33AFE4AB-C33E-4499-A110-2BFB236…  {BCC2FAC0-B53D-4B66-A83F-FD6B017…  real         nein     8718        0
  467 │ Polygon(438 Points)   {C4C0B3BB-6163-47F9-840A-E381219…  {3520D997-13BD-4ECA-8BB0-6DC8A0C…  real         nein     1854        0
  468 │ Polygon(607 Points)   {0D32781F-04E3-4151-91A1-54DCDD4…  {68FBDAF6-6E83-424D-B4BC-9A15E01…  real         nein     3232        0
  469 │ Polygon(239 Points)   {45200A92-935B-41B5-A8A4-A0618FD…  {18EECC26-8444-4330-AD86-2444A93…  real         nein     7023        0
  470 │ Polygon(1317 Points)  {54133CAE-C99F-4C0A-A83E-DF58034…  {36027EF1-5B5A-4765-8A6E-15CEF6A…  real         nein     3472        0
  471 │ Polygon(285 Points)   {9428D053-02D1-458D-8029-8A4D7F1…  {6B542086-EDB7-46D9-AC78-2E8A06A…  real         nein     1945       11
  472 │ Polygon(591 Points)   {316E1CE8-8878-4414-B170-B651F06…  {9016B8E9-A87B-496F-AFE7-EFCA4FD…  real         nein     2800        0
  473 │ Polygon(164 Points)   {066EA740-13D5-439C-94ED-989156B…  {58BB2805-C6F6-4DAF-BD42-A169173…  real         nein     3961       24
  474 │ Polygon(867 Points)   {2BF07B7D-AF1C-4859-ADF7-5CA8A43…  {8E41E038-24E2-4410-B9D9-BCEA34F…  real         nein     1623        0
  475 │ Polygon(2202 Points)  {AD75E512-CAB7-480D-920B-7BFCD55…  {DED56AAE-8D79-4CD9-8E39-EC30A34…  real         nein     8636        0
  476 │ Polygon(548 Points)   {43CB92B4-53E8-4A8C-889B-EF6B13E…  {FCAB9292-F354-4805-8E5D-006434F…  real         nein     7276        0
  477 │ Polygon(246 Points)   {95AA0619-E51A-467F-80F9-48D1009…  {B1453BC3-3660-4877-908B-CADFF9A…  real         nein     6707        0
  478 │ Polygon(368 Points)   {B4A62DAF-AED9-4A69-B229-4619C9F…  {272109EB-AAF0-40EB-8B88-0344BCF…  real         nein     3945        0
  479 │ Polygon(552 Points)   {55AE1392-5864-42B5-AE33-9050AD0…  {CAF466A2-AC17-4CE7-AD8F-A2120AA…  real         nein     3792        0
  480 │ Polygon(665 Points)   {AD92CB96-0BB2-405F-BF99-8B41A53…  {557338FB-24C6-4F2B-B433-2D751A6…  real         nein     2829        0
  481 │ Polygon(436 Points)   {D3FCCB53-45D5-4B73-946E-0B9D75F…  {11D3DBB3-6982-4340-84D6-5D931B4…  real         nein     3553        0
  482 │ Polygon(373 Points)   {6D005965-9984-456D-816F-1575392…  {81705444-46A1-4F96-BBC0-F3D4448…  real         nein     2333        0
  483 │ Polygon(635 Points)   {096D89E8-E4D5-48B1-80B0-5B641FF…  {664A6B33-E7A9-4660-9997-F5D1045…  real         nein     3826        0
  484 │ Polygon(430 Points)   {F54971F8-E739-459A-9606-2AED633…  {2A92FEF7-05F2-4065-80C3-2FC0492…  real         nein     6377        0
  485 │ Polygon(415 Points)   {DEDB3A42-463A-4FC0-BB16-4A26465…  {A8DD6A1F-B0FD-41A6-AFC8-99336B5…  real         nein     6462        0
  486 │ Polygon(625 Points)   {A2183AD2-DF37-49CE-A2C8-A4D6EEB…  {AF283BD6-4967-4215-BCAA-32D385C…  real         nein     6343        0
  487 │ Polygon(786 Points)   {FA0DE882-AD9E-496C-B601-E50CE16…  {A74D57E3-BE6E-4FFF-AF5B-6D18B50…  real         nein     6417        0
  488 │ Polygon(1645 Points)  {38EC26C1-85E1-48CD-AF0F-79725C1…  {1AF11C2A-2EFE-41DD-9E6A-F9C0BA1…  real         nein     1659        2
  489 │ Polygon(516 Points)   {F12D26DC-0A9A-4624-8230-E8F8F0F…  {A087365C-D6AE-4462-8471-9BA7C6B…  real         nein     4410        0
  490 │ Polygon(794 Points)   {1991C56A-E38D-40DB-B07E-A3F93B9…  {7BF77868-016B-45DB-8839-67B8B7F…  real         nein     7156        1
  491 │ Polygon(207 Points)   {88EACC1E-8437-4A73-944D-B90EF16…  {DCA6A266-D2BE-4742-B8EE-D4B47A7…  real         nein     7448        0
  492 │ Polygon(972 Points)   {9381F1DB-15C6-4CE2-8F3B-79AAAF1…  {2652DCE7-789A-4DD6-8BA2-3929EF1…  real         nein     7112        0
  493 │ Polygon(577 Points)   {33D99EB2-70FB-482B-B408-A7745AD…  {D48032A9-423E-4952-98DC-9800411…  real         nein     8213        0
  494 │ Polygon(487 Points)   {48C71E4D-245F-484C-AC8C-F9B2583…  {DE31437F-44D1-4B27-8054-5B7CE04…  real         nein     2314        0
  495 │ Polygon(277 Points)   {E59DBDC4-7249-4C96-9F4A-7542AAF…  {55FF5465-2B5C-476A-BFA8-3AA358E…  real         nein     3963        4
  496 │ Polygon(536 Points)   {BA9DA3A6-CAF2-4F48-BEFB-346B786…  {A29C1368-6704-4013-934D-9D4FDD2…  real         nein     6410        0
  497 │ Polygon(402 Points)   {2911A3D4-77DE-43B5-9C83-F19CF93…  {22BA4E19-81C1-412C-B123-20291C3…  real         nein     3176        0
  498 │ Polygon(665 Points)   {E2817D3E-BC6D-4AFB-A3A5-9668AC4…  {305017FB-2C86-4D7A-829E-04601CB…  real         nein     1950        0
  499 │ Polygon(450 Points)   {EDE074D1-283A-4EFE-BCA0-4B7101A…  {45661BA7-B7A0-47CA-B1E7-C3FC4B6…  real         nein     6468        0
  500 │ Polygon(604 Points)   {9B42B75D-AA1E-43E1-9428-0DB29E5…  {95DD1186-FC7B-4329-8A29-C02B3E5…  real         nein     6614        0
  501 │ Polygon(2191 Points)  {F7956D56-717C-4B4E-9E83-FA7B96D…  {79E6ECFD-012B-4A20-85A3-86EC0B3…  real         nein     8340        0
  502 │ Polygon(587 Points)   {FFF9C4C2-84C9-4BEB-9C06-2E54AED…  {C34AC6C6-25E1-40A6-B6A3-CA0F068…  real         nein     1872        0
  503 │ Polygon(194 Points)   {F49502BA-F4D3-4F89-B318-6E8C8E9…  {459D1557-F1DE-453A-8A9D-327627B…  real         nein     6635        0
  504 │ Polygon(341 Points)   {DC1D6393-FB3F-49A7-BA2B-B57F617…  {02F7D3A1-D066-4C64-B5B2-64086BF…  real         nein     3923        0
  505 │ Polygon(363 Points)   {96D73F2D-FE19-47AE-B432-5F1E7EE…  {B3243136-CFC1-4481-80BA-72542EB…  real         nein     8232        0
  506 │ Polygon(927 Points)   {C4654A94-640B-4CAB-ABC0-E527ACD…  {19083613-1318-4BF6-B5DE-134602C…  real         nein     7203        0
  507 │ Polygon(389 Points)   {67B6226D-E816-4B3E-8DBB-76C6B7C…  {F8BD5B35-7C23-4842-B8A3-F27748E…  real         nein     7241        0
  508 │ Polygon(385 Points)   {9D9A977B-5A0F-41C7-A6B6-47426B4…  {30DDCF34-DBEF-403B-9338-A63DB12…  real         nein     3942        2
  509 │ Polygon(567 Points)   {31248403-1091-4FA0-8C53-3471B2E…  {60283E3C-37B2-4518-8873-905DA52…  real         nein     2019        0
  510 │ Polygon(835 Points)   {A685C97D-96AD-4F80-AEF7-3EA9E29…  {4335886B-D59A-4627-BBE2-AF3EA95…  real         nein     2883        0
  511 │ Polygon(643 Points)   {6FE154AA-0523-4EC5-B3FA-E2AC970…  {4FD1065C-6B46-4337-908E-E8D68BE…  real         nein     5722        0
  512 │ Polygon(2323 Points)  {4725360A-2903-4C3A-9AF7-F2D8864…  {4C4025BF-F253-4DE7-8000-F5C33BC…  real         nein     8400        0
  513 │ Polygon(716 Points)   {66E65822-ED0D-4C8A-B148-261D045…  {02AA7C16-7F09-4C4B-A5B3-A3B8610…  real         nein     4704        0
  514 │ Polygon(619 Points)   {494DCB73-B1DE-457B-B245-1061A32…  {44241AA8-76A8-4FFE-BEC5-1ABBA60…  real         nein     3778        0
  515 │ Polygon(536 Points)   {218A12F4-424B-4179-872E-20A388E…  {E524B810-DA71-420F-9FA4-C0A3D29…  real         nein     6318        0
  516 │ Polygon(442 Points)   {DCE1138B-9D1B-4FEB-9C18-7B49C76…  {FC9DF9F8-096D-4509-8324-24729D6…  real         nein     6705        0
  517 │ Polygon(179 Points)   {470749B0-4059-4F95-872B-0383521…  {8CB89F35-05E2-458B-9B58-290037F…  real         nein     1983        0
  518 │ Polygon(303 Points)   {E6158544-AEC2-4607-8DEE-794D3E0…  {A1628378-F4E7-4D5F-97D5-30E3171…  real         nein     6373        0
  519 │ Polygon(1135 Points)  {7FC51331-FCA8-413F-A5DD-28292A0…  {255363C1-60DD-4F6A-BB37-81F39E0…  real         nein     8610        0
  520 │ Polygon(240 Points)   {61769A37-9D93-4DBD-BFFA-70F9F3D…  {8E41B978-5474-4702-B7BB-6E117FD…  real         nein     1982        0
  521 │ Polygon(460 Points)   {CC4CA377-8379-4207-9D3F-362FA4F…  {9D44EB1F-3740-4291-9F59-F0E0B71…  projektiert  nein     6543        0
  522 │ Polygon(1213 Points)  {1986854B-ADE9-44D8-AE6E-DF9AE4B…  {B165F458-E455-47D5-A7D0-E0B728E…  real         nein     8706        0
  523 │ Polygon(432 Points)   {4CB1A5B0-7CC5-4DE2-8D70-B5C4945…  {875175D0-2296-4600-BDA5-D5FA277…  real         nein     3427        0
  524 │ Polygon(1119 Points)  {42010C43-18CB-4896-AF00-0DF4896…  {26C2E9CF-EB61-4A50-99D5-E24800F…  real         nein     2603        0
  525 │ Polygon(1035 Points)  {30B98B81-ED8A-4E3B-BD91-69844F5…  {56BA12A9-E816-4EAD-9DE5-1413FD3…  real         nein     2950        0
  526 │ Polygon(576 Points)   {482AE64A-1FFD-46FD-B938-7359133…  {032FB663-65D5-4518-A4EF-3FD1C92…  real         nein     3123        0
  527 │ Polygon(243 Points)   {5BAFFE11-6AEA-49F5-BE1B-02B9B96…  {3EF9B6A6-3C97-46F7-8181-E41CC69…  real         nein     7513        2
  528 │ Polygon(814 Points)   {0BD70F32-562E-41CD-87FD-B0E2936…  {FF48F207-635D-4671-9730-05CA34B…  real         nein     1453        0
  529 │ Polygon(984 Points)   {DD701145-77FE-4123-B99F-783FD3D…  {224E40A0-B2B0-4D17-BAB8-ACD5AF1…  real         nein     1242        0
  530 │ Polygon(1872 Points)  {71ABDCCD-CFFA-4D1E-823E-C9DA697…  {F2A13981-400F-4E88-9230-E5D9951…  real         nein     8620        0
  531 │ Polygon(1295 Points)  {2A930F51-DCF9-4D71-A673-AE4F254…  {ED44490D-583C-4B3B-A4EE-8D6F5EA…  real         nein     1072        0
  532 │ Polygon(432 Points)   {7448DFD7-E8AA-4D6B-9CBF-2BDA640…  {C99EFD80-373B-42C0-8F2A-4864270…  real         nein     8892        0
  533 │ Polygon(896 Points)   {71921299-BA75-401D-A05D-3DC9893…  {1A18C14C-D10F-4D67-851D-84861DB…  real         nein     6516        0
  534 │ Polygon(759 Points)   {2CF0C33E-FE5A-40CD-A818-ABCA474…  {0D71DF0A-9D37-458B-A2AB-8319ACF…  real         nein     6018        0
  535 │ Polygon(512 Points)   {5835B310-3EF5-4CA3-B2CB-DFF62CA…  {0BF07148-3680-466C-8415-82C30A6…  real         nein     3780        0
  536 │ Polygon(606 Points)   {B141C424-8B67-4EF0-B0F7-00DB20F…  {D7718FBD-FDC7-490C-8A4B-62D56EC…  real         nein     8723        0
  537 │ Polygon(983 Points)   {56E759EB-A76A-4E5E-816A-7F72835…  {EF766832-45FC-4FB7-B2AE-811FEE8…  real         nein     8514        0
  538 │ Polygon(605 Points)   {42A227ED-5EC5-429D-8DDC-576C427…  {A3E327E6-39DD-4C03-A6F0-B096691…  real         nein     1278        0
  539 │ Polygon(698 Points)   {71D6950B-65CE-4062-B31F-779F4B9…  {4D1DCFB0-1412-4AD7-A50B-CE23C1F…  real         nein     2345        0
  540 │ Polygon(1555 Points)  {8B1B8E9F-5232-4175-B1DE-81DD16B…  {2C433113-B22D-4151-8414-5900D45…  real         nein     9103        0
  541 │ Polygon(1703 Points)  {6A917EEE-764D-4578-9C98-DEC2593…  {CE2E6D0D-33DF-4044-9EC6-46D31B8…  real         nein     6052        0
  542 │ Polygon(529 Points)   {6797968E-5C04-4988-8238-2B0A0F0…  {D9173961-D16C-4986-9DCC-B70D459…  real         nein     6523        0
  543 │ Polygon(1479 Points)  {17CB5FE9-CA01-4584-AFBB-B4D1768…  {7C218D1B-603B-4B2F-B1CF-48C6B79…  real         nein     8180        0
  544 │ Polygon(267 Points)   {716FB1A5-C455-4570-9BED-03D2881…  {96325B28-852A-4A5A-9AA1-9811581…  real         nein     2405        0
  545 │ Polygon(295 Points)   {93E64F9C-9E28-4682-825C-29D9D11…  {6F88B4B7-AE38-4991-9C68-E103E5E…  real         nein     7015        0
  546 │ Polygon(345 Points)   {DF77D40C-1637-421D-BDE0-AC11160…  {DB273397-DEAE-408B-B22B-C47DB48…  real         nein     8717        0
  547 │ Polygon(1985 Points)  {D0EFC920-C2E1-4A7D-834A-33CA11F…  {BC8BB539-1A3D-4D2C-BA91-85D7E2E…  real         nein     6125        0
  548 │ Polygon(259 Points)   {024AA93D-EA2D-4B9B-A270-414ED1D…  {C8DB5759-ACCC-4F13-96BF-C895CEF…  real         nein     8841        0
  549 │ Polygon(918 Points)   {92DDAACF-5CAE-4574-B4E2-772EC8F…  {8072A77D-601B-47FD-95AB-7B043AB…  real         nein     3182        0
  550 │ Polygon(468 Points)   {44D30BA2-3DF9-4C2E-A107-07C60DF…  {5044DDC9-ACEE-4817-8D49-C15826E…  real         nein     1714        0
  551 │ Polygon(626 Points)   {54980EAD-19BF-4790-BD62-592DB42…  {F16C8082-EDD1-42D6-9E06-8F28702…  real         nein     6331        0
  552 │ Polygon(570 Points)   {A52FD484-1533-461D-8B5A-7B5144C…  {9069C44B-C3F2-43F2-BB38-E442C64…  real         nein     6440        0
  553 │ Polygon(955 Points)   {7350417C-B75A-40AF-92A0-A883C1A…  {F35B4881-6743-46E4-A45A-140CE72…  real         nein     1619        0
  554 │ Polygon(383 Points)   {B007CD05-C6FD-4684-9EDB-06ED6B7…  {B34CDB24-783E-4611-BFDE-399DFCD…  real         nein     4716        0
  555 │ Polygon(323 Points)   {AB67E925-CC04-4D6F-BFB8-3EBCED4…  {E1E013CE-22AC-4E11-83B9-35284D8…  real         nein     7243        0
  556 │ Polygon(1603 Points)  {5880A167-8C2A-475C-8AD4-9533A26…  {FB1B7641-6CC9-4F97-9532-D4D20C7…  real         nein     8344        0
  557 │ Polygon(1820 Points)  {80246347-FCB5-412D-A8C8-D022CF5…  {B29DCFB9-F5D2-4DEC-AA1B-2E01D1E…  real         nein     1807        0
  558 │ Polygon(1064 Points)  {2E993D77-3331-4E14-A098-43A2773…  {87E20654-995A-4A56-BC1F-1EB0085…  real         nein     3776        0
  559 │ Polygon(1349 Points)  {C874759E-0150-4CC2-ACB5-B94A77D…  {3D4CC055-723A-442D-9345-B030711…  real         nein     8645        0
  560 │ Polygon(411 Points)   {9067D327-BA3B-4F3F-8483-989E03B…  {BE3E6FFC-ABA5-4411-812D-7437515…  real         nein     7128        0
  561 │ Polygon(1570 Points)  {8E58F12B-B7F4-468A-82BB-E06E842…  {F98242BC-AEB5-486C-9F57-510908D…  real         nein     6162        2
  562 │ Polygon(267 Points)   {F7A43C62-881F-4136-924F-73D5157…  {220B3476-4A2A-493E-A1D8-8EAF8E3…  real         nein     8865        0
  563 │ Polygon(395 Points)   {B8F0CE31-364A-4EF1-9573-C99C1FD…  {0DB204E5-E5D2-4E62-9E02-9CA9345…  real         nein     4438        0
  564 │ Polygon(680 Points)   {341EFDCB-2356-4631-A442-B7187E6…  {0FEA4C9C-7E64-428A-912F-E16AB06…  real         nein     3550        0
  565 │ Polygon(672 Points)   {4FABC5D5-B19E-4C24-897B-3D1F34F…  {56584108-1D78-4FA4-B709-6D19FC1…  real         nein     2807        0
  566 │ Polygon(534 Points)   {719E27E3-5B22-43FA-8CAA-524EBA7…  {792E1CD5-C5C1-4E10-8609-FB40B8E…  real         nein     1588        0
  567 │ Polygon(690 Points)   {C69B74D5-C892-48B2-8631-3C0AF0C…  {13D02F7D-F5A9-47D1-98EA-FF30BCF…  real         nein     1454        0
  568 │ Polygon(908 Points)   {9F60600F-A5B3-4074-9107-D1577FD…  {BA7E5E44-355A-46D3-88B5-6B69F74…  real         nein     1866        0
  569 │ Polygon(805 Points)   {59185924-D713-48A9-B7C9-444B1D8…  {EE5D63A4-697D-4EAB-8E81-11CF25C…  real         nein     4710        0
  570 │ Polygon(880 Points)   {90B25E33-35E9-4B66-A9B4-7D9538E…  {6DBA0EF9-F644-4068-9737-D054ADC…  real         nein     1580        0
  571 │ Polygon(172 Points)   {4D78D729-5E5C-4EB2-8177-FB3A15E…  {92668B77-F194-46E5-A3F7-53F0FA1…  projektiert  nein     7482        2
  572 │ Polygon(4418 Points)  {3D1B2E07-F6BB-4AC4-AC99-14D0B36…  {6A2F51E1-7C3E-44E5-BF12-FE67132…  real         nein     8757        0
  573 │ Polygon(367 Points)   {8B16402F-211C-4449-83F9-1A33C72…  {1DD328CB-BCB1-4411-B915-77368A8…  real         nein     1891       11
  574 │ Polygon(905 Points)   {F453B75B-F32E-4D8A-BDDD-1E5EEBC…  {41D4FFA4-F2C9-4D2E-8CFE-04D9A33…  real         nein     3534        0
  575 │ Polygon(409 Points)   {EB60615D-4950-416A-A526-16B6310…  {F2EE46BC-B203-42BF-990D-33DECCC…  real         nein     3806        0
  576 │ Polygon(261 Points)   {5D2DE836-CAD6-453A-BF97-741BE24…  {7954A2AF-8B49-4F38-AC87-623B886…  real         nein     1918        0
  577 │ Polygon(731 Points)   {459322B3-4603-4F11-8AF3-C5C7D2C…  {96A3681F-42B8-4B1E-91EE-733B299…  real         nein     8570        0
  578 │ Polygon(978 Points)   {8DE76746-F4FB-4F35-93DB-173C6ED…  {93D5982C-2ED3-4A09-A16C-73358E0…  real         nein     3812        0
  579 │ Polygon(977 Points)   {A4C527DF-DD2D-4E7C-9937-D71F690…  {4DBBA4E4-32EB-4B46-A38F-5C943B9…  real         nein     6023        0
  580 │ Polygon(1978 Points)  {931DDB78-5268-4A8C-9996-2FE3C60…  {10BD7BAB-D8F0-40EB-AB0F-42380DA…  real         nein     1863        0
  581 │ Polygon(387 Points)   {225EA8C5-4148-4350-ACF5-709CEB9…  {4C59473C-F83A-413D-8E1A-5032F92…  real         nein     4245        0
  582 │ Polygon(768 Points)   {20174DC8-B32D-44BD-8C7F-8A0BC9F…  {FD4A7F54-B2BF-496D-9D60-BB2E19F…  real         nein     9246        0
  583 │ Polygon(638 Points)   {4390E636-E7DD-4639-9C02-86D1C24…  {47F313B0-47DC-4AE3-AAE8-F4C256F…  real         nein     6557        0
  584 │ Polygon(144 Points)   {366929DB-4CE8-4F5F-AFA1-5BCE09F…  {8E7AC212-B659-4CAA-8F5F-7BBF4C5…  real         nein     3961       41
  585 │ Polygon(1009 Points)  {8728C652-1EE8-46CA-8C68-6CF4725…  {9C32587F-8D4F-4B08-90C6-D09B250…  real         nein     3400        0
  586 │ Polygon(513 Points)   {E4029548-46E1-48A0-B127-920F717…  {6C91BAC5-9339-49E7-ABB0-256A56F…  real         nein     1148        5
  587 │ Polygon(1312 Points)  {F215EA87-6E5A-46CA-B678-5636BF7…  {52B7CFB2-7C39-4E9F-A495-545C676…  real         nein     6206        0
  588 │ Polygon(750 Points)   {64911472-6D6D-4B32-8C4C-05A0638…  {35E1BA2D-ADE0-4233-A92E-1DD4DEB…  real         nein     6454        0
  589 │ Polygon(898 Points)   {250ACC9D-FFC3-49D8-AB8A-CEC7CC7…  {98614FF2-7923-4DDF-9706-BB44F4D…  real         nein     3638        0
  590 │ Polygon(632 Points)   {C8A1DCA8-8487-4B91-A757-E23894B…  {C8EA1313-1895-4AC4-8893-D3009F4…  real         nein     3713        0
  591 │ Polygon(354 Points)   {6F37F5CD-CFA4-4806-A396-00ED635…  {393836D6-53D2-496C-AEA0-4CB503F…  real         nein     3955        0
  592 │ Polygon(279 Points)   {AC6D19C2-D220-445A-9F48-94FEBDB…  {C41EC08A-59DD-43BF-80CD-E1BB984…  real         nein     6433        0
  593 │ Polygon(149 Points)   {2200D4BC-27E0-4723-8DA3-2CB5F39…  {72AD3AD7-AD66-4039-AE60-DC1511A…  real         nein     1948        0
  594 │ Polygon(519 Points)   {3C702944-FD75-4D05-8EB3-FCF5487…  {BB9D9D58-CA83-440A-BD40-1432D84…  real         nein     3995        0
  595 │ Polygon(837 Points)   {92A01B04-38F7-4865-B134-AE0FAF7…  {8F97F5AC-96B4-4972-8378-BA4FDF8…  real         nein     6066        0
  596 │ Polygon(867 Points)   {94476E83-13DF-4F4F-A669-592FDDF…  {103AA67E-805C-48C1-BB92-424908E…  real         nein     9470        0
  597 │ Polygon(556 Points)   {215B81BE-C105-45B2-B9E2-D91EF0E…  {9806F227-8471-46C6-81D2-FBE9119…  real         nein     8252        0
  598 │ Polygon(491 Points)   {C54CC3AB-7221-4C0F-A572-CE43CE1…  {95EFAB50-5F96-4CB6-9A62-7452CE1…  real         nein     4310        0
  599 │ Polygon(334 Points)   {8F4452D4-995B-46AB-8D77-34BFD85…  {7DEBD569-7FCA-4A73-971A-E5F2D5B…  real         nein     8215        0
  600 │ Polygon(313 Points)   {062D22BF-9451-4D56-AD74-52A5CEC…  {89E7BCA8-607D-4479-9FC4-37DBD24…  real         nein     6655        0
  601 │ Polygon(1809 Points)  {65F0403E-16AF-4F6C-8B6A-0121BB1…  {3F22B410-3EF2-47DF-B124-52B9725…  real         nein     1510        0
  602 │ Polygon(198 Points)   {9CDB67C5-88AC-40BB-B991-5E52231…  {359F1490-CB06-474B-9067-38EE9EE…  real         nein     4206        0
  603 │ Polygon(653 Points)   {887666E8-C0B2-483C-8F03-CAE3635…  {A21D9514-4FA5-4F9B-A68B-E135E4F…  real         nein     1860        0
  604 │ Polygon(451 Points)   {E31BFFF8-1ACD-4ECA-BE7A-0053055…  {87BF97F5-C900-4C6C-A690-4C09D41…  real         nein     1914        0
  605 │ Polygon(650 Points)   {55468AC8-003E-4D5D-8D44-55912A2…  {8C8EF781-E79A-40BC-A2CE-D3EDBB6…  real         nein     4719        0
  606 │ Polygon(1761 Points)  {0506B772-6EE9-4D31-8051-751A98D…  {C6916E77-3FF5-438B-AA03-A29542B…  real         nein     1806        0
  607 │ Polygon(862 Points)   {52EC6BE7-C4D4-4EB5-AB07-4D6809C…  {F703DDFC-049B-40EC-877D-33ADA4B…  real         nein     4934        0
  608 │ Polygon(1239 Points)  {BA2D81A3-DE3C-4D9F-86A4-D49A27E…  {E8ECEF9F-B36B-4794-9A6A-36BD426…  real         nein     3615        0
  609 │ Polygon(3776 Points)  {B8A075E0-5958-484D-9AF8-72543DE…  {6BA4E529-7589-4793-A101-98B8A0E…  real         nein     8492        0
  610 │ Polygon(508 Points)   {91443D4B-DCE4-41C1-A9F7-48658A0…  {E144D0C4-83D6-41DF-8F41-F900D4B…  real         nein     7433        4
  611 │ Polygon(1016 Points)  {C6378FD1-6F85-4E3D-B3D7-FAAED12…  {7F285D18-9E15-4A86-97A5-68EDF8E…  real         nein     3815        2
  612 │ Polygon(265 Points)   {8E4BE077-71DF-4EA4-96B6-4B6DFD4…  {713AE82E-938B-41E4-A42F-BC57693…  real         nein     8856        0
  613 │ Polygon(1081 Points)  {8CB60DF6-3119-4A65-BD81-DFB55A2…  {AB41796A-D31E-45BD-BD91-7DC14FA…  real         nein     3414        0
  614 │ Polygon(474 Points)   {52F4159C-EA83-46C7-A0EB-2A93F35…  {43343EF0-5ECB-4903-8C45-2D39E0B…  real         nein     9614        0
  615 │ Polygon(348 Points)   {ACE8234B-EB99-4273-A7EA-F5C509D…  {35DE4891-9828-4B8C-B4DB-6FDCCC8…  real         nein     1933        0
  616 │ Polygon(378 Points)   {6B41430D-52AE-4613-9C5C-CC7151C…  {80843783-3965-4237-8C35-9B80283…  real         nein     4132        0
  617 │ Polygon(312 Points)   {1DFEC9A9-1762-43D0-A097-C57192A…  {D37D0BC7-5FB3-4052-B7BD-5D0ECEC…  real         nein     3938        0
  618 │ Polygon(196 Points)   {936E68C4-A797-4545-965F-56CD425…  {7983FE3B-22AE-4DCA-9586-CC9992A…  real         nein     7226        0
  619 │ Polygon(380 Points)   {D0D33ACE-44D3-45FE-B3DC-E656CE0…  {20D1404A-F364-4391-9F11-A6FF752…  real         nein     1862        0
  620 │ Polygon(389 Points)   {9F280BBA-21DA-4BB1-BF35-DC53615…  {B9498C72-8B7D-4C95-A326-B80FACA…  projektiert  nein     6537        0
  621 │ Polygon(1313 Points)  {A06FEF8B-D575-4350-B1DC-4FF747F…  {8FAEF178-52FD-4C6F-A8B5-5EF5E72…  real         nein     8494        0
  622 │ Polygon(426 Points)   {E8E390D1-B551-404D-A6E3-B2CC34B…  {713E9CAA-75AB-41B3-AECA-DB01B69…  real         nein     7514        0
  623 │ Polygon(931 Points)   {DE8C8541-90FC-4841-988E-F602E29…  {59928C16-775F-4AC2-8953-7BC2AE4…  real         nein     6372        0
  624 │ Polygon(205 Points)   {7D916DF1-8DFD-411C-9A83-8806D1A…  {5A58CF8C-C3DD-4CB7-93CF-F5987AF…  real         nein     7743        0
  625 │ Polygon(245 Points)   {4DEC79BC-60C4-48F5-B4FB-8404D17…  {C469BED2-8FF1-4404-B81C-E23A093…  real         nein     2534        2
  626 │ Polygon(201 Points)   {E2F01CFA-63A8-4F23-BC4D-0D9B470…  {B16ECBDB-F07F-4C04-89C1-1F8C698…  real         nein     3957        0
  627 │ Polygon(482 Points)   {A8EC4917-DC88-4A47-9EA2-A97C387…  {7FEA90FE-E761-4D76-876A-EC8F2B5…  real         nein     2854        0
  628 │ Polygon(821 Points)   {21FE2436-77C2-4271-A421-D225C3C…  {80652123-3F8D-42F1-82BF-79871C9…  real         nein     7450        0
  629 │ Polygon(861 Points)   {FC16CAD1-2BD8-4FFE-8C2F-CB933DB…  {7724DDF1-DBBA-4FD9-BD2F-0573112…  real         nein     3068        0
  630 │ Polygon(375 Points)   {338303E0-1B57-4AF1-AA7E-DF29A5E…  {DE8CD097-88B5-4D62-8076-5F2ADB3…  real         nein     6675        0
  631 │ Polygon(423 Points)   {254B20CE-33A0-4456-B53E-160DB33…  {32D5D99E-0ED3-4919-9196-E719837…  real         nein     2900        0
  632 │ Polygon(218 Points)   {8D5B5959-6ED1-4A8C-BC53-5983280…  {4A7A8B41-8F87-4CF0-A7A1-AAF1D64…  real         nein     1934        1
  633 │ Polygon(933 Points)   {BE35749F-3CF1-45D6-9C38-2C3BAC3…  {7275EF71-C6F1-4C19-B7F8-10DE58F…  real         nein     2052        2
  634 │ Polygon(2601 Points)  {BB11542C-1649-4AD0-9A59-43F0589…  {331F5025-A56D-46AC-9DE1-85582DE…  real         nein     8330        0
  635 │ Polygon(824 Points)   {877DECE5-92A4-4BAA-A2DC-60CC3CB…  {79013B30-16FF-44D7-879D-A3B62C8…  real         nein     3326        0
  636 │ Polygon(476 Points)   {8CFF1890-803C-4D22-AE69-14E8D70…  {D8F2B6E7-526B-49BD-AED8-EA741D2…  real         nein     3918        0
  637 │ Polygon(884 Points)   {3B09D3AC-B64D-4A97-90F3-170CCCA…  {80E45D72-B43F-4D47-AD4C-75C27DB…  real         nein     7184        0
  638 │ Polygon(272 Points)   {9133E394-4ED4-432D-80A3-676C8A3…  {54D3D10C-6CCF-4AB6-B47C-C142550…  real         nein     7265        0
  639 │ Polygon(683 Points)   {9E558D7B-4176-4F79-A872-66C6C95…  {92F756D9-D67A-4AEB-BA1C-039AD47…  real         nein     3453        0
  640 │ Polygon(329 Points)   {818F2576-3ADC-4AA0-86A3-21244F1…  {B87BDDD4-D137-49F4-8164-092B834…  real         nein     8881        1
  641 │ Polygon(606 Points)   {2424FA44-CF9D-4180-AE2D-5123A67…  {F9B4B2EF-2B2D-4F06-87B3-E08A29D…  real         nein     3150        0
  642 │ Polygon(239 Points)   {2E7DE21A-2605-4D8D-A93C-CCAA3AF…  {937D712E-5179-414E-AC81-6704311…  real         nein     3988        2
  643 │ Polygon(849 Points)   {D1E36F37-6BD5-4FA0-B2CD-D339D37…  {1EBD23BB-8F26-4188-9242-09D948F…  real         nein     3665        0
  644 │ Polygon(774 Points)   {0F43804B-5D7A-405F-94C5-3B7CCD2…  {731FF6DE-D742-4A92-8505-C22F985…  real         nein     7428        0
  645 │ Polygon(482 Points)   {0D133BDA-1DCF-48A6-9B70-7EEF506…  {BD3E6181-B30C-4B01-BBF2-CBA04BE…  real         nein     6774        0
  646 │ Polygon(581 Points)   {24C452C3-CF8F-476F-B46A-036859D…  {FBD84866-A475-445F-A973-1593820…  real         nein     3454        0
  647 │ Polygon(590 Points)   {16906BC5-D13B-4333-B410-A888365…  {F22B8A47-E657-4A08-ABD3-52F593D…  real         nein     3800        2
  648 │ Polygon(618 Points)   {FEBB62F0-3925-438B-B9C1-ADDDAB9…  {267EABDA-38C9-4AA1-96E5-EFB4987…  real         nein     7226        0
  649 │ Polygon(717 Points)   {B564248E-4E88-42B0-B978-C09985B…  {8BB615DB-631C-424E-9B66-F8C58D0…  real         nein     3432        0
  650 │ Polygon(364 Points)   {316D4E13-C97D-4A0A-867A-12D6E9B…  {813C0323-B686-41B9-951F-FCB7925…  real         nein     2864        0
  651 │ Polygon(763 Points)   {DCC16184-5961-452F-98A8-78B7802…  {C13320D7-29E8-427E-858F-4749EA6…  real         nein     4900        0
  652 │ Polygon(540 Points)   {522EA78B-B139-4E1C-937D-02A9665…  {5C232173-DC3B-4DB5-8A10-479E502…  real         nein     4712        0
  653 │ Polygon(533 Points)   {CA6BD23E-4F74-4EFA-8B9C-6F6217C…  {3B6B3240-1C2F-4E07-81CE-2027D6B…  real         nein     2855        0
  654 │ Polygon(1235 Points)  {216C6BB8-2106-4851-9213-220E4F3…  {1FF213C0-F88F-4BC3-83ED-2A7824D…  real         nein     1462        0
  655 │ Polygon(325 Points)   {3AE8C861-EEE2-483D-B371-7C1214E…  {9876A64E-00A4-4808-8EEE-F408D50…  real         nein     3933        0
  656 │ Polygon(873 Points)   {B2BE8FD6-5019-4D78-B921-E955B5E…  {D201CFD5-9F8D-4288-ACC5-71F23E7…  real         nein     2054        2
  657 │ Polygon(340 Points)   {79A7CF5D-938F-4A83-864A-3E2A338…  {C314BC2A-F944-4F3E-B617-72EBA95…  real         nein     2610        4
  658 │ Polygon(918 Points)   {D22EBE6E-CD69-4995-9C6A-0660566…  {17720BF5-FCA5-4EE2-AD59-6928D9F…  real         nein     1562        0
  659 │ Polygon(730 Points)   {D28AE7F9-9DBE-44A8-B9DB-DABB86D…  {ECE019B0-F8A8-4D60-A309-AC4D820…  real         nein     7325        0
  660 │ Polygon(256 Points)   {6C865FF5-50EC-4C46-97A2-C2B396F…  {A593B72D-6FAD-4A76-A93A-4FF69E6…  real         nein     3925        0
  661 │ Polygon(766 Points)   {CAB04CA9-5774-463C-AABB-EAEEF1B…  {20B2312B-3165-4005-ABDD-9254946…  real         nein     2353        0
  662 │ Polygon(898 Points)   {965D0170-0550-4C67-B5DA-0C28958…  {EC1D146E-D846-4C42-8BB6-1E7F59C…  real         nein     3185        0
  663 │ Polygon(131 Points)   {E6B6E37B-F007-4D7B-9EEC-CD0633E…  {918D3C0C-DFDD-41F4-A211-12C32E4…  real         nein     1343        0
  664 │ Polygon(615 Points)   {32C469A1-A42C-419E-B39C-CDED89D…  {590FF28E-5FF8-462A-9C53-D52BEC8…  real         nein     8222        0
  665 │ Polygon(345 Points)   {C00CBFE1-5259-4808-BDB7-9476A80…  {6C855C1E-F6EE-4580-AE95-C90E03D…  real         nein     3178        0
  666 │ Polygon(501 Points)   {78A5A82B-CA3A-4B93-A33D-0A67632…  {F5057363-0C65-4B5C-8B52-0CEEF5E…  real         nein     1341        0
  667 │ Polygon(178 Points)   {B9088635-1E49-49A3-A877-5C808A6…  {1BA97E1E-8AFF-4D0A-8F6D-7B17752…  real         nein     7228        0
  668 │ Polygon(511 Points)   {83CF5F94-E6C4-4B4A-A652-F9C012F…  {5215EE5C-AC58-4665-9B77-9ADAB9C…  real         nein     7412        0
  669 │ Polygon(402 Points)   {0ADA3DC1-06C3-4048-9E8F-5911012…  {6676DAB6-3283-4E36-9210-9E561CC…  real         nein     7029        0
  670 │ Polygon(981 Points)   {C770406F-BFF4-4529-B872-C0173F4…  {BC558543-D949-4FFA-85A9-F2C4B1A…  real         nein     3533        0
  671 │ Polygon(1141 Points)  {A0D8D44B-1728-4A69-B525-9B8951A…  {051EE5A4-3C11-4649-9CE6-4EEBCE2…  real         nein     8580        0
  672 │ Polygon(875 Points)   {BF8112D8-9BC5-4D6E-8FE9-ECAA01E…  {BA9739BD-268A-456A-9663-A990067…  real         nein     6060        2
  673 │ Polygon(796 Points)   {78175657-56D6-4EF8-96A4-E10A564…  {F7657030-B7AF-496F-BB7D-A01E048…  real         nein     6313        0
  674 │ Polygon(370 Points)   {94E3ED58-5C54-4334-8048-022D6F0…  {5F0ACAFE-786C-4AD0-8233-F034EBD…  real         nein     2887        0
  675 │ Polygon(922 Points)   {484A0854-0701-4C96-BCC1-572BA43…  {230139A9-33F8-4781-8065-07EB91D…  real         nein     1530        0
  676 │ Polygon(376 Points)   {6E442F9E-66A4-4DA8-BE3A-D734946…  {85ECC25B-6DD8-472F-8744-F068B1E…  real         nein     2000        0
  677 │ Polygon(729 Points)   {519B5369-FC1B-4B38-BE13-8BCA491…  {7802645C-183E-4469-8A6F-431D472…  real         nein     5082        0
  678 │ Polygon(1456 Points)  {43C5E9BB-11F5-482C-986C-4BB6503…  {54D07813-B0AF-4425-93E6-46BB060…  real         nein     1717        0
  679 │ Polygon(218 Points)   {D985912F-CDBA-4C02-8BC3-BD6B5DB…  {ECAE36EE-246E-476A-B370-297DC8B…  real         nein     2803        0
  680 │ Polygon(1104 Points)  {3337A752-0951-436C-A950-066998B…  {FEEC50BF-B65A-4EB8-A9FF-748629A…  real         nein     3673        0
  681 │ Polygon(816 Points)   {01C9B9F0-5DA3-4E2B-9926-BD5E86D…  {7731A00E-7D16-4257-AA98-1C57F8B…  real         nein     6330        0
  682 │ Polygon(310 Points)   {5029D1BE-857B-4B2E-8971-6DB2777…  {CD32EA3E-9413-4BFA-BAB7-392878B…  real         nein     8840        0
  683 │ Polygon(447 Points)   {20944C45-1B1E-4D07-83BE-6E663BE…  {EE8CB8CF-E1AC-47F1-A6EB-C3E8D09…  real         nein     6678        2
  684 │ Polygon(1377 Points)  {B41D172D-831A-4F2D-BB01-BF2D3FD…  {B9193B47-CE08-4EBD-A756-8077FCC…  real         nein     8508        0
  685 │ Polygon(288 Points)   {DC3444F1-B3AA-4935-B79F-61DAEA0…  {7E3BCE2E-F303-49E3-B683-6F780E9…  real         nein     2915        0
  686 │ Polygon(966 Points)   {9B102B71-82FC-4E58-8B01-B516125…  {B9B0EA12-4074-435A-A6F7-13C7842…  real         nein     6122        0
  687 │ Polygon(395 Points)   {A04CB44C-34A7-4F75-9E03-EEB96FA…  {752A0DC7-955E-4C21-AC26-0A41DE1…  real         nein     3997        0
  688 │ Polygon(411 Points)   {2BA34F9E-C2A5-46F3-BAE5-C4E3845…  {E62155BA-B671-427D-B1CA-441245A…  real         nein     7074        0
  689 │ Polygon(851 Points)   {52F423D3-2A0F-4B2B-89C2-EEF965C…  {708116F0-E265-4545-B176-3E84F7E…  real         nein     6274        0
  690 │ Polygon(412 Points)   {13FF45C6-9A72-4580-8610-B2903FE…  {71E6AADD-861E-44D0-ABC8-41C0932…  real         nein     4715        0
  691 │ Polygon(1045 Points)  {47073674-7F10-4D7C-B59E-C179264…  {34B07C8F-4693-49CD-BDDD-0D6FA71…  real         nein     6156        0
  692 │ Polygon(622 Points)   {BBC46E0D-42A6-464B-BAD2-785F232…  {E7CCDFA7-DD65-49E0-8858-4C73D9A…  real         nein     2072        0
  693 │ Polygon(644 Points)   {DF676273-BD3E-4D45-80AA-EBA339D…  {892B71CB-52A3-4083-A209-AA1A59D…  real         nein     2882        0
  694 │ Polygon(540 Points)   {168268A4-D16D-48FC-8516-EF909B9…  {1861EF31-AA89-4CDE-8226-5DD1AC6…  real         nein     7159        0
  695 │ Polygon(263 Points)   {48F3D262-E2A7-4263-8C04-D5C6CF7…  {23BF8EA3-594D-4223-A740-5FBC0CF…  real         nein     3158        0
  696 │ Polygon(489 Points)   {1E0DDC10-4381-4B7D-980B-CC7C4E6…  {8B4D231C-EE15-4527-8B53-89A2918…  real         nein     3204        0
  697 │ Polygon(673 Points)   {123021B0-1D98-4F25-A074-813A9D3…  {9DAD96AF-8A6B-4215-9610-21CF382…  real         nein     6252        0
  698 │ Polygon(638 Points)   {F29D4F37-3DF9-40E9-8E43-B244B8E…  {C1517E47-D5AD-46EF-B7EE-F0C6E02…  real         nein     2944        0
  699 │ Polygon(254 Points)   {6825A3B1-BCFD-4E06-8B8E-7ADCD4D…  {5B003AB1-5ECF-4495-A84F-C26B2C8…  real         nein     3943        0
  700 │ Polygon(645 Points)   {943AE012-3EB9-4B71-8E70-310041A…  {BF801478-A620-4D04-AFFD-364E7ED…  real         nein     2058        0
  701 │ Polygon(239 Points)   {8A2C7D3B-3BC3-45AA-B2A0-EACF08F…  {55C8353E-12D4-485D-A871-2054696…  real         nein     7012        0
  702 │ Polygon(498 Points)   {15BA2C6B-327F-44F2-AAD5-150D915…  {6F341B83-03B7-4083-B39F-FD9D38C…  real         nein     7157        0
  703 │ Polygon(715 Points)   {1356E47A-26E2-4C6C-8393-1D76450…  {77292631-75B7-46FC-8C27-173FA83…  real         nein     8264        0
  704 │ Polygon(797 Points)   {036E300B-794C-4CC0-8178-A18A635…  {15D46E0E-EA50-48F8-8532-F83708D…  real         nein     2362        0
  705 │ Polygon(509 Points)   {F4F0A305-A28D-41DE-AFD3-72A6EF4…  {E08E0BA1-EA74-4185-9814-42CF1C7…  real         nein     8262        0
  706 │ Polygon(283 Points)   {9EEB0D07-C45D-4ABB-8CB5-BD022C0…  {639683DD-2E12-4B03-9838-5031CCA…  real         nein     3724        0
  707 │ Polygon(1180 Points)  {A38ED491-7C3C-4A4F-B5B1-390EC25…  {16186182-485D-4C6A-A009-0D13714…  real         nein     1715        0
  708 │ Polygon(187 Points)   {0B07B054-8804-4647-B9DA-9A17B0F…  {DAFFF179-8BA2-414B-A040-E0965AD…  real         nein     7533        0
  709 │ Polygon(1304 Points)  {FDAA64F6-03C6-456C-A18E-E9AB904…  {D07394B5-F73C-4EF7-BACB-9F4266F…  real         nein     8887        0
  710 │ Polygon(302 Points)   {EBBA0FA0-A92A-42B5-AF8C-2DC63C1…  {F25F047C-B4C0-4A1F-9AA8-56D401D…  real         nein     2605        0
  711 │ Polygon(353 Points)   {DBFC0CB0-9287-4B4A-868D-BBF223E…  {0DE3388E-0FE3-450E-8892-7311797…  real         nein     3935        0
  712 │ Polygon(630 Points)   {1080B062-D6A3-4AF2-8A4B-5F8D9E7…  {B3D00FCF-DC0D-421B-8F28-92E0A33…  real         nein     3784        0
  713 │ Polygon(217 Points)   {0483B95A-3510-44BE-8322-59C80D5…  {C8E60367-ACD8-4FA4-BC99-03EF595…  real         nein     7443        0
  714 │ Polygon(952 Points)   {AAAA8FD8-1CA7-418C-818F-D5307BE…  {522F572E-7B85-41F1-A1D6-2F10FBB…  real         nein     3065        0
  715 │ Polygon(398 Points)   {F65D0637-1964-4E51-8F9A-F5391C4…  {12B1593A-603A-440B-AED8-8B21763…  real         nein     3294        0
  716 │ Polygon(322 Points)   {620D9162-1EEE-4200-A29A-FF22FC4…  {F6DA743B-2B31-4603-ADE1-2D5D9F2…  real         nein     7403        0
  717 │ Polygon(384 Points)   {026818EA-8095-4BA2-8D0B-D163907…  {1F02B7DE-A48C-41AA-9EE0-8427768…  real         nein     7084        0
  718 │ Polygon(722 Points)   {9D4D7DFD-2149-4087-913F-CD6CFA6…  {40226122-EFB9-4E30-BF10-30BD742…  real         nein     3822        2
  719 │ Polygon(960 Points)   {DC3A3C89-C5A8-4676-A51C-4C047C6…  {811FCC60-29AF-4D68-866D-60903DC…  real         nein     6802        0
  720 │ Polygon(1898 Points)  {D6DA03A5-CD5E-40B3-9F6B-45BF0EC…  {D5D81E32-8797-4775-A9ED-741CF30…  real         nein     8867        0
  721 │ Polygon(888 Points)   {4A7D6EA4-5BAA-4093-AFB0-69CF9B5…  {A62D5470-1710-440A-9DE5-FD2B3E9…  real         nein     6221        0
  722 │ Polygon(532 Points)   {651278B2-28BD-47F3-B61C-117BF70…  {D72F3D93-42E5-4C38-AA88-FF24603…  real         nein     2852        0
  723 │ Polygon(558 Points)   {B6C5C999-FD6B-4A87-A728-6346421…  {E86D221E-F122-4B7E-A3B7-41B8C34…  real         nein     3153        0
  724 │ Polygon(425 Points)   {6979B2EF-55B7-472D-91E8-74CE23B…  {4D59768C-C6B6-474E-A9F4-266252E…  real         nein     8762        3
  725 │ Polygon(414 Points)   {CFC2B331-C243-4CE0-8C0E-35546F0…  {59482795-7032-4738-963C-F08C4CC…  real         nein     3926        0
  726 │ Polygon(584 Points)   {EEAFEADA-4A49-4BC7-BEE1-1DB8723…  {C8A71CF4-743A-44BF-A754-EB49300…  real         nein     4614        0
  727 │ Polygon(108 Points)   {98C84992-7DC4-4A8F-AFB0-E140584…  {DB9FFCD8-611C-4CA6-AA4F-0D22B67…  real         nein     3961       23
  728 │ Polygon(397 Points)   {4C912C45-D0D5-4496-B2C1-EC55053…  {07DBA8A0-1A1B-4D4F-8768-D5F245D…  real         nein     6678        0
  729 │ Polygon(445 Points)   {4BB21E14-DC32-4C61-8B14-E16FFFC…  {90E1EF2E-7F95-4057-8AD7-B7088FF…  real         nein     3716        0
  730 │ Polygon(1161 Points)  {7992118A-AA12-463A-BD5E-792017C…  {781D0B55-842F-4C19-BC8F-5299F20…  real         nein     6013        0
  731 │ Polygon(1736 Points)  {2EB892DD-FC58-4D1B-9342-B3FDFAF…  {4C4025BF-F253-4DE7-8000-F5C33BC…  real         nein     8408        0
  732 │ Polygon(548 Points)   {C514D06A-7056-44E5-8F1C-7B56240…  {279D86AD-C020-4448-BC9E-AC891C6…  real         nein     2360        0
  733 │ Polygon(598 Points)   {D91EF71C-7A8B-4EB6-A0DF-5131CF3…  {D2717FD6-CF9A-406D-93C6-D86C4C7…  real         nein     4805        0
  734 │ Polygon(456 Points)   {43D4C632-7082-422B-85CF-5256834…  {6DFB5540-3FE5-4726-AB6D-D68C0F6…  real         nein     3763        0
  735 │ Polygon(1070 Points)  {0CA41587-0FDA-4B86-A7E3-7AFC947…  {9EB1B8D3-15BC-4D1B-9DBA-AC34AE5…  real         nein     6222        0
  736 │ Polygon(1060 Points)  {F1B8347B-C498-4EA0-B74A-A4EEBF2…  {79B1534C-71BF-417C-8C7A-887D5F0…  real         nein     1148        0
  737 │ Polygon(1550 Points)  {780FB64A-EC11-4035-B31E-FA92467…  {5709B5AF-8073-4B2F-9478-D25A3A3…  real         nein     8932        0
  738 │ Polygon(373 Points)   {E877E009-B456-457D-B32E-FF641A1…  {4A1A8EF2-A682-45FA-978B-33C1D63…  real         nein     1669        2
  739 │ Polygon(201 Points)   {9AADF62C-05B3-479E-AF24-7BE59CE…  {2622AD54-47F8-44CA-8972-A349B9A…  real         nein     3989        0
  740 │ Polygon(356 Points)   {77163B03-4160-4256-9409-077F2E6…  {6DC3F0BA-A620-457E-A51D-FCFD97B…  real         nein     1669        4
  741 │ Polygon(1550 Points)  {41281044-85FE-4729-AE3E-05AFB48…  {FAC7E8E3-DA9C-4AE3-8E7E-58940B6…  real         nein     8335        0
  742 │ Polygon(581 Points)   {CFB31074-4407-480C-8AF0-2155767…  {CB5E2718-B69C-41DD-B7EC-EE639BA…  real         nein     6025        0
  743 │ Polygon(1616 Points)  {AE9C9D9C-CC2F-4B5A-B568-FE5E514…  {DC691708-0BE4-4DAC-AD75-8C94A92…  real         nein     8877        0
  744 │ Polygon(1047 Points)  {44B0849D-8B19-48A3-A248-D6E5626…  {1BE59217-3F2B-4DF2-AAFB-75EE52C…  real         nein     6032        0
  745 │ Polygon(451 Points)   {BCA069F3-FA5A-441F-95BC-367FC8C…  {CEF40DA9-26D1-462E-92B4-34EF9F3…  real         nein     2863        0
  746 │ Polygon(510 Points)   {F75C0A53-A053-4549-9AC9-31B9BC9…  {6DFDE550-34D8-4E15-BB90-576AA9F…  real         nein     4654        0
  747 │ Polygon(789 Points)   {CC8B2442-F640-4C4C-BFCD-96086AD…  {CFEFE5C0-397B-473C-A9BB-0332001…  real         nein     1143        0
  748 │ Polygon(1225 Points)  {D08CC118-7CD2-4EB4-8429-35C58A9…  {AFC22E78-CCFC-4809-BD25-C4181CE…  real         nein     8353        0
  749 │ Polygon(1645 Points)  {E1487651-5982-4B4E-8760-B6090B8…  {C830950B-E3C8-40AF-AA87-3D681C2…  real         nein     8475        0
  750 │ Polygon(272 Points)   {792D83CD-57CD-4C68-9BF8-941D013…  {2E3B52DB-E58F-49E7-8504-0CD1561…  real         nein     1899        0
  751 │ Polygon(654 Points)   {B385EBC2-11DB-4A39-A179-308AED7…  {EA6C7B4A-B157-4A0B-B2E1-81F6F23…  real         nein     2364        0
  752 │ Polygon(674 Points)   {6B396A53-4576-48AC-AD2D-8106017…  {1C9F5327-E4EC-4FF0-A0FF-C8B41DB…  real         nein     6156        2
  753 │ Polygon(568 Points)   {DC624E39-EEAF-4CBE-B544-87440E0…  {66AAF8F0-B36D-4C0C-B407-92AC199…  real         nein     4665        0
  754 │ Polygon(581 Points)   {5F669AE5-33DE-4DBB-8AA5-66B7FDF…  {A3C85C87-1141-4B3A-A5DD-C41790C…  real         nein     8217        0
  755 │ Polygon(1021 Points)  {88B5A751-50E9-41D7-B893-C538D40…  {3A3CB248-9369-4823-A9C6-C3EEED4…  real         nein     8498        0
  756 │ Polygon(320 Points)   {E59174B0-494A-4363-BEF6-EDBC7BC…  {6719DFCC-34AA-4B4A-8586-D54EB7C…  real         nein     3953        2
  757 │ Polygon(1013 Points)  {6BE3CABC-B00A-4E15-A88B-E06A8C1…  {A7A46897-F646-4B6D-A5DC-608E912…  real         nein     1233        0
  758 │ Polygon(449 Points)   {329CEE51-FC4D-4295-BC01-BC3FB10…  {9045407F-E913-4EE2-8065-93DA131…  real         nein     6810        0
  759 │ Polygon(772 Points)   {171B1E9A-F03E-40DB-AA40-958FFDD…  {F79092CB-326E-4B85-9359-C6EB8F9…  real         nein     9613        0
  760 │ Polygon(264 Points)   {2C6CF445-1512-4F89-BD04-183735E…  {49583D81-9929-4B49-ADF0-6CBCE6A…  real         nein     7534        0
  761 │ Polygon(518 Points)   {E37DD32F-2F63-4593-8316-767FB4F…  {D6040BA8-C9F7-43F5-A151-BA3EA81…  real         nein     2023        0
  762 │ Polygon(833 Points)   {6B469BC6-330E-4D28-BAAE-AB50F72…  {809521FB-D923-407C-9B56-5D8B15C…  real         nein     8810        0
  763 │ Polygon(828 Points)   {1177C844-514B-4070-B26A-9728204…  {63AD9713-5DA3-4046-9861-AE373D0…  real         nein     7556        0
  764 │ Polygon(226 Points)   {A14673D1-6818-4EDB-B746-238B825…  {3720A2D6-E8B8-441F-BCE2-43E757D…  real         nein     1969        5
  765 │ Polygon(1186 Points)  {245FD75C-4BC3-4326-9085-C770BFA…  {B6F89418-6489-42DC-B7C6-4620FCF…  real         nein     6288        0
  766 │ Polygon(1278 Points)  {8E7A0012-9BC0-4FBA-8298-641074E…  {73C57AAA-A225-432C-BFE4-B063747…  real         nein     1867        0
  767 │ Polygon(751 Points)   {C3D6F8F8-0D10-4CD9-80B9-F7402D2…  {89DBBE09-17AD-486C-A0DC-05D1805…  real         nein     5426        0
  768 │ Polygon(429 Points)   {2196BB5C-E7C4-4D7D-BB43-32656CF…  {60BBED24-1A8A-41E7-9641-516D615…  real         nein     2710        0
  769 │ Polygon(610 Points)   {001852BB-9100-467A-AD67-3F92861…  {29EEDC1C-A3D1-4E17-AD62-35E01BA…  real         nein     8460        0
  770 │ Polygon(1103 Points)  {F247DD08-2402-45A8-87D3-A7EF931…  {8738A2C1-5CF7-48B4-B686-F892029…  real         nein     6016        0
  771 │ Polygon(1042 Points)  {371F27C8-ED85-4763-9368-E02572A…  {1D4CC761-0C53-4CF4-81CF-BF01450…  real         nein     6153        0
  772 │ Polygon(307 Points)   {9B24D47E-C06C-4B4F-BA48-5056801…  {6B9B063E-5199-482E-BA8F-9FDFF5D…  real         nein     8228        0
  773 │ Polygon(238 Points)   {A8AF815B-D713-40CF-B946-72EAEC9…  {10D35F43-DC9F-4D88-A0BE-6765DA0…  real         nein     1905        0
  774 │ Polygon(514 Points)   {B5884F7B-3E5B-4530-9742-B3CAB6F…  {AE3FEA96-0223-42C2-898A-C2EFEC4…  real         nein     2853        0
  775 │ Polygon(642 Points)   {958AD9CC-B560-4CF6-BFD4-F5E067E…  {1C701A8D-1E81-41E5-9C65-AC75F2A…  real         nein     3436        0
  776 │ Polygon(872 Points)   {8FE19C9B-E5C7-4C71-B12D-BC5E76E…  {43748EED-EED8-403C-BC97-133DC91…  real         nein     7154        0
  777 │ Polygon(539 Points)   {A4F54F0A-F220-4952-AEFB-E4584C9…  {F071DC02-D021-4F03-98F1-C40A32C…  real         nein     6596        0
  778 │ Polygon(273 Points)   {5124CB2F-7FA9-4035-9A9D-0724A51…  {81F9508C-8407-44AA-B2FC-8D3EEF1…  real         nein     2606        0
  779 │ Polygon(770 Points)   {B9712E58-0CB0-4AB5-95F0-BC49ED7…  {35186A72-5FA5-4DF2-995D-0D82A92…  real         nein     9534        0
  780 │ Polygon(601 Points)   {8FCA24FB-FA9F-4EB6-81FF-FBA214D…  {00EA964D-E97B-4001-8C3E-B5E9D2C…  real         nein     5630        0
  781 │ Polygon(853 Points)   {B57E047F-9884-48CC-8521-D701E43…  {98E67E88-AFBE-46AB-B5BE-5838D7B…  real         nein     8712        0
  782 │ Polygon(330 Points)   {A6247CBA-5362-46B5-8DAD-3619F57…  {97D582A8-2DB5-4622-84D3-6A6489C…  real         nein     2414        0
  783 │ Polygon(1004 Points)  {C327DDB5-D47E-4662-AD7A-F824A93…  {D564CFE4-C668-46F3-BBBA-65B6D88…  real         nein     1880        2
  784 │ Polygon(898 Points)   {3E7363AB-902E-47FD-9EE6-4EF9925…  {51F87E17-6CF8-456E-A052-EA29727…  real         nein     3250        0
  785 │ Polygon(1421 Points)  {084FE7B5-2AFD-492D-919E-2B60881…  {98B8CC7B-3AC6-4775-B25E-41D238E…  real         nein     3096        0
  786 │ Polygon(817 Points)   {C8ED0A5A-A24D-444C-8C2C-7647140…  {4F6B4F9A-9DD4-4430-B9DA-413CD23…  real         nein     3076        0
  787 │ Polygon(1146 Points)  {3891A0B2-D7C0-4D43-B295-0669C08…  {F9980EDB-FAC0-470C-B98D-8677B89…  real         nein     3816        0
  788 │ Polygon(590 Points)   {DD05798F-56B2-4CE0-9E51-6A15BE2…  {57B893FD-2011-4E35-8F1F-13BFFB0…  real         nein     3777        0
  789 │ Polygon(515 Points)   {940588E7-AB3C-4685-93EC-89101C6…  {3FC5EE06-BB69-45FB-BCB4-0706CBC…  real         nein     2824        0
  790 │ Polygon(234 Points)   {8E148920-53FE-4429-B243-D6394A8…  {38D8A8B9-2208-4F61-936A-FEDC87D…  projektiert  nein     7419        0
  791 │ Polygon(472 Points)   {A3EAAF72-0437-4282-84C3-E3B7FC1…  {FC67A296-FD54-4D69-B45F-39C09B8…  real         nein     1188        2
  792 │ Polygon(681 Points)   {399CC233-1EF3-4896-988E-C88A3A3…  {A7737D9D-B6AA-4F4D-AE08-3F8B861…  real         nein     9655        0
  793 │ Polygon(287 Points)   {FBC650B3-843F-4C2B-A3E1-D29AD4E…  {648EC873-71D2-4527-9E9A-8DEEFF2…  real         nein     6658        0
  794 │ Polygon(501 Points)   {E0FE6144-5D63-4747-92BC-57B8146…  {19D0044C-105D-4D51-89F9-32EA65D…  real         nein     6374        0
  795 │ Polygon(248 Points)   {74807D51-F653-49B7-B418-A2095B4…  {4055E87D-DEC6-4601-8C3D-6F102B3…  real         nein     7214        0
  796 │ Polygon(456 Points)   {FAE773F0-8F01-42D8-9317-7F4C619…  {AD3B0444-576D-44A2-93B8-763E50F…  real         nein     1903        0
  797 │ Polygon(1009 Points)  {441385D8-E778-4734-84BD-A2AF358…  {5D270E8D-6541-4323-8B7A-27A25DF…  real         nein     8600        0
  798 │ Polygon(754 Points)   {306E304C-7758-411D-B8C6-024B0C5…  {E25B74C3-5BB0-489C-9F6A-27D7CE2…  real         nein     2544        0
  799 │ Polygon(1480 Points)  {9333EC27-9C59-4244-AB6F-463CCD1…  {5EB56E69-D8CB-4E5B-8CDF-757E247…  real         nein     1635        0
  800 │ Polygon(326 Points)   {374CA724-E6F3-47E8-B04B-86DEC8A…  {3A451B8F-CE06-4C2F-BFDA-3237F67…  real         nein     1938        0
  801 │ Polygon(219 Points)   {BD484DD7-01BD-4E40-B33F-B7C299C…  {95FCC3C7-C841-45F4-B556-A950C48…  real         nein     6647        0
  802 │ Polygon(192 Points)   {7178D382-D44B-4FCD-9C7B-0AD8A56…  {88FBAD7A-D436-4D14-B9FF-0D01699…  real         nein     6715        0
  803 │ Polygon(739 Points)   {A1622C67-5F8C-46B4-8A2A-651D4BE…  {546683C2-2217-4C66-B837-58A71A9…  real         nein     1680        0
  804 │ Polygon(521 Points)   {8FA283C4-39F2-4387-AAD4-1F2EB7E…  {18147E79-1327-4D47-BABF-0007123…  real         nein     1357        0
  805 │ Polygon(2708 Points)  {C8BCECAC-A12F-4881-917E-E45441B…  {25F0ABEC-A529-450B-82DF-B2483CC…  real         nein     1052        0
  806 │ Polygon(372 Points)   {185351E1-002A-4F69-AAB7-FEFC5B5…  {F85BD054-CBD6-4945-833E-F2A26F8…  real         nein     6677        1
  807 │ Polygon(439 Points)   {55F7B591-916F-46C5-856F-D645695…  {DD212BB3-E81B-4FF3-9D65-3907F29…  real         nein     8836        0
  808 │ Polygon(501 Points)   {47A6E000-DFF8-4916-A8D4-445C117…  {2795A5AA-E32A-4EEF-9BAD-E861F09…  real         nein     4702        0
  809 │ Polygon(401 Points)   {D0013C0C-F8D5-46A3-9EDD-0DD55E7…  {EDCA9F75-B9D4-4969-A4A1-0B29FBF…  real         nein     1932        0
  810 │ Polygon(720 Points)   {DFE7885C-D65A-4F28-BFE6-17250CC…  {4F8FE0DC-5DD4-4E48-A096-2E031B1…  real         nein     4950        0
  811 │ Polygon(239 Points)   {A213AAD7-A89F-4361-9603-D0952DA…  {C789365B-4B68-43D0-BC09-7D286C3…  real         nein     2802        0
  812 │ Polygon(983 Points)   {81923AEA-7853-4985-A6FE-4204F43…  {9052A61E-8436-4B41-A177-12E2FC7…  real         nein     1261       32
  813 │ Polygon(674 Points)   {A1F050E4-F19E-4EE2-9C90-E0F5008…  {9F400A50-65E2-468B-9683-7CB867A…  real         nein     6574        0
  814 │ Polygon(861 Points)   {E7872E14-6809-4B81-ADA7-ECC629B…  {A09C47AA-2626-4C4A-8214-AF00DC1…  real         nein     1400        0
  815 │ Polygon(426 Points)   {07994C69-449F-4EDB-A754-1CBAFE0…  {8CFEB281-4529-4267-8BEE-0EDF98E…  real         nein     1350        0
  816 │ Polygon(1016 Points)  {0092A595-5CCD-4697-9D53-F9DE90B…  {25EBC19D-C7B1-471D-8910-0DB0AAE…  real         nein     8153        0
  817 │ Polygon(430 Points)   {082148AD-F2CD-4495-818D-F1F5A81…  {668E861F-6BF7-42F5-A90F-82E5836…  real         nein     6763        0
  818 │ Polygon(1263 Points)  {6B36F484-DCF4-4F4B-A0E6-229E361…  {B45F6F43-7635-4946-893D-B7A6C70…  real         nein     8374        0
  819 │ Polygon(233 Points)   {E5C429BB-E2AF-4BCC-BD63-E5A9277…  {921542C0-BF8C-4F8A-AB69-09FE4E0…  real         nein     2406        3
  820 │ Polygon(311 Points)   {BF053673-0840-4B52-9FC7-126D62C…  {47A513C4-DFA1-466D-A923-1CE44D7…  real         nein     6684        0
  821 │ Polygon(903 Points)   {A8C39541-73C2-4BB7-BFA0-8D810C8…  {20923CB7-20F4-4848-8D1B-E3206C8…  real         nein     6422        0
  822 │ Polygon(179 Points)   {7AFE3FF7-E2C8-4223-B946-7F5A127…  {07A60121-6A94-4DD6-808A-50B6DAB…  real         nein     2117        0
  823 │ Polygon(188 Points)   {8D885C1F-E77E-4A91-BEC9-1A66E91…  {9B81130D-4F0F-45C2-BE29-843EC53…  real         nein     8847        0
  824 │ Polygon(356 Points)   {4DC444C4-4AC3-4BD5-9918-9C85184…  {B833D929-FF25-48E4-827A-B9816F1…  real         nein     1265        0
  825 │ Polygon(360 Points)   {2CA85F86-CAFA-4AF0-AAA4-BE9A329…  {F43CF1A3-A7D4-4785-B62C-DCBB6E5…  real         nein     3989        5
  826 │ Polygon(723 Points)   {446A9BBC-8610-4950-99B4-B35D022…  {9501010B-1042-42A1-8C48-A1BF8B6…  real         nein     9220        0
  827 │ Polygon(1432 Points)  {A5442C0F-DB29-4727-BA0E-22C8FBE…  {3134FC82-4632-407C-89C4-8DD821E…  real         nein     8143        0
  828 │ Polygon(796 Points)   {7F9EA92F-BA12-4C8E-9999-5F32DB7…  {11A0D158-5D48-4E1D-AE47-9C14179…  real         nein     4952        0
  829 │ Polygon(663 Points)   {5377D86D-F6A4-4A38-ADF4-9838F68…  {B46E71C2-8B52-4F98-9889-379B918…  real         nein     8280        0
  830 │ Polygon(329 Points)   {DBC35A57-7E70-45C6-8C41-AB21CB6…  {3963768F-26DA-4947-99C0-79E1F2C…  real         nein     7602        0
  831 │ Polygon(250 Points)   {F35F032D-3F7B-42F5-AC65-81069DD…  {20171D53-D471-48A8-B1B9-015F8FD…  real         nein     2325        0
  832 │ Polygon(393 Points)   {F00F7F73-5435-40F3-8F6F-82BA053…  {98C89193-8A76-4F0B-AAE4-9A53DC2…  real         nein     7076        0
  833 │ Polygon(800 Points)   {2A55F9D5-7D2C-4CB9-980A-25DADC2…  {FD338301-AB0D-4E34-BD2E-6169D10…  real         nein     6034        0
  834 │ Polygon(668 Points)   {1B29CFD0-F5BB-42E1-BF7B-69BCAEC…  {17B948DB-1469-4874-B185-0DFF61D…  real         nein     4242        0
  835 │ Polygon(766 Points)   {90542965-D5E6-42FA-8785-F6FCD15…  {BF9F364A-7D24-4179-86C4-E85C8E4…  real         nein     9545        0
  836 │ Polygon(567 Points)   {AD856223-C18D-48BB-986C-3D5FB22…  {65DA80BF-46BE-434F-809C-9B620CA…  real         nein     8872        0
  837 │ Polygon(574 Points)   {E4A82687-D44C-4C9E-B2A8-14C597E…  {5C5A0A70-BC00-40E5-A1A3-22C3832…  real         nein     6432        0
  838 │ Polygon(552 Points)   {E9AC7113-8C86-4047-A924-C01B0EC…  {A3021FC1-92B1-4BF9-A1EB-2F7D7BE…  real         nein     3917        0
  839 │ Polygon(542 Points)   {374C9033-5854-4EB8-80EA-842BA02…  {EAED9903-2F6B-4F2D-8EAB-37DC15D…  real         nein     2350        0
  840 │ Polygon(599 Points)   {3C5E090D-A10C-4B4D-9E94-B161D2B…  {A767F067-1D29-4531-898B-58A4D28…  real         nein     9612        0
  841 │ Polygon(409 Points)   {F5E80360-6A26-4C58-9980-D64D102…  {CA02F379-5D51-4F97-8D82-74216D1…  real         nein     2889        0
  842 │ Polygon(286 Points)   {92C0BB75-67B3-4923-A079-7873FDD…  {903DF41F-01FE-4285-8653-9F3434E…  real         nein     2932        0
  843 │ Polygon(399 Points)   {33CF28B8-9F74-4299-B67A-10ECB91…  {E5FCA7AE-814B-4228-B6C5-339552A…  real         nein     3714        3
  844 │ Polygon(814 Points)   {16F84B65-86EE-44F8-A6EC-FDB42A5…  {BD361E6B-3F9C-4022-ADC6-E3DB37A…  real         nein     8773        0
  845 │ Polygon(817 Points)   {B3AADC0D-1BB5-4FB1-90CE-93995A6…  {36218422-283E-420F-B68E-E3031D7…  real         nein     8739        0
  846 │ Polygon(1909 Points)  {4382758E-C173-49A6-8BFE-3F25D2D…  {ED0775F4-DDBB-4285-BD7A-67A1FFD…  real         nein     8354        0
  847 │ Polygon(686 Points)   {2F9DB0FC-40E5-400A-83F4-BFB2FA5…  {575B786A-23AB-43A4-A27C-D88825B…  real         nein     6693        0
  848 │ Polygon(646 Points)   {48935AA7-0E14-4EFF-800A-4D50A96…  {2D4FF541-1FD6-4055-8660-87A52DA…  real         nein     2830        0
  849 │ Polygon(1628 Points)  {AA186C59-AB09-49B6-90C2-28E4C05…  {DC540D38-0F62-4425-9A72-5E82BFB…  real         nein     1073        0
  850 │ Polygon(401 Points)   {D2C78B21-35F8-4132-832F-2CB8A35…  {BDBB384C-2F7E-4FC9-BCD8-4A26C02…  real         nein     8864        0
  851 │ Polygon(979 Points)   {A1A9EE4D-7F90-4359-BBD1-34F9AC7…  {3E1974FC-7A93-41AC-AA6B-C990C6C…  real         nein     8808        0
  852 │ Polygon(1053 Points)  {FD8841FE-4D1E-4833-A302-DE0EB24…  {DF860906-5F31-4815-BF3B-E9C1808…  real         nein     9300        0
  853 │ Polygon(570 Points)   {F80743F5-74D6-469F-A47B-41F1A19…  {B490D5C7-1576-4077-A649-9BE647C…  real         nein     7156        0
  854 │ Polygon(372 Points)   {5F8C81E7-7398-4B5D-B688-FC236D6…  {C7CC123B-57D5-4062-B451-413290C…  real         nein     4133        0
  855 │ Polygon(1604 Points)  {DA8D10B0-8E88-4A64-BA72-1CE0A76…  {B496D2D0-C50D-4CBB-81F2-FE95808…  real         nein     9633        0
  856 │ Polygon(309 Points)   {3B251B55-582D-4273-B51D-43A6DB4…  {C2C2188B-B226-47A6-8373-7D50539…  real         nein     9466        0
  857 │ Polygon(408 Points)   {112C499E-5F61-4AD7-8C21-3C8E840…  {4FF03DEC-EF0E-4F0B-B525-BA9B8DF…  real         nein     2720        2
  858 │ Polygon(1619 Points)  {A870665E-A0E8-4ED6-B8C6-CCD2ADB…  {71333CF2-F4F4-4FC9-BAF5-15D4413…  real         nein     8424        0
  859 │ Polygon(789 Points)   {3F890464-6A0D-4969-BFBA-8C2BD7A…  {FAD09E38-7A9F-457F-A93A-26F64FB…  real         nein     1254        0
  860 │ Polygon(340 Points)   {EA1A8898-ABDF-43D5-BF33-8EB0317…  {638D06EC-B55C-4562-9A99-A12F090…  real         nein     6315        0
  861 │ Polygon(583 Points)   {9B008D91-343D-46FD-BC7E-BD5BEE2…  {36ACF633-E55F-44E2-ACE2-E2D9BF1…  real         nein     9468        0
  862 │ Polygon(1134 Points)  {81454597-6F04-4304-B48A-556C0BD…  {378E5846-2AE8-4685-84C2-8796EF7…  real         nein     6154        0
  863 │ Polygon(306 Points)   {61671BBF-D47E-4922-86A5-57AD4DF…  {C2E8BD02-6599-4F58-9119-40466FF…  real         nein     1852        0
  864 │ Polygon(651 Points)   {02AFFFA0-71D3-484E-97D8-555625B…  {CBD7AD81-F8C6-4B98-A607-82A4D31…  real         nein     6500        0
  865 │ Polygon(419 Points)   {9B84C0C6-3A52-46DA-9303-4A53ED3…  {0B224505-BF8F-4940-BACB-DE37E0E…  real         nein     4312        0
  866 │ Polygon(673 Points)   {96C40B53-2C24-4216-B84B-C604EF7…  {E65B36D1-3526-457B-9FD8-E0067F2…  real         nein     3911        0
  867 │ Polygon(624 Points)   {CA5DE82E-4B5B-4D6F-A17A-17FA42B…  {D11317E5-DC39-4C51-A113-467D9AA…  real         nein     7208        0
  868 │ Polygon(459 Points)   {72A5132F-5B98-41F1-A486-88029AB…  {EF52B1E9-116A-495C-9A34-AB3A8B6…  real         nein     8854        2
  869 │ Polygon(745 Points)   {329416D5-BCE4-48E4-AE42-FCB7E50…  {7FB8D3A9-C7E9-431A-B6E0-5848883…  real         nein     9064        0
  870 │ Polygon(2930 Points)  {5878A636-FD51-4924-BE8B-E92EAF0…  {708AE5DD-BF3A-4CF7-8E66-B99289E…  real         nein     6110        0
  871 │ Polygon(649 Points)   {E18DECA3-1840-4051-AC31-5874D84…  {11D3E61C-3081-4278-9E7D-6D71BCC…  real         nein     1733        0
  872 │ Polygon(237 Points)   {87AC4D0D-5780-481D-9F81-2186254…  {807EDBC3-5AE5-42AE-B79E-710D391…  real         nein     8878        0
  873 │ Polygon(1305 Points)  {16A1BC96-077D-4501-8960-9E8D361…  {2581C46E-C564-4A05-8D47-66C707D…  real         nein     8903        0
  874 │ Polygon(468 Points)   {1D60B012-3BC4-4892-8466-2E3E7E0…  {DAD44832-E05C-4A38-AAE3-7C5FA8B…  real         nein     4852        0
  875 │ Polygon(432 Points)   {4AFA49BF-8BBA-4873-B1D2-34A4BD2…  {7C2081A0-275F-480E-B5AB-C161E4D…  real         nein     2115        0
  876 │ Polygon(2195 Points)  {76AA2BAB-71C6-48E4-B54A-5C0E06D…  {F54D1508-6B4A-4871-A154-DC65229…  real         nein     8784        0
  877 │ Polygon(828 Points)   {49609EEA-6CBF-4C92-A8F5-B0862E9…  {572C1912-671C-44DF-AD84-AAFEB11…  projektiert  nein     7493        0
  878 │ Polygon(411 Points)   {E7EE8866-FCF8-4840-A5BE-9F00112…  {721D7B1C-0949-45D9-AEAF-28FBA5D…  real         nein     6722        0
  879 │ Polygon(1054 Points)  {E94FE829-023B-468F-B888-0F9D999…  {E7C7DCDA-291D-48A2-B358-CC02996…  real         nein     5637        0
  880 │ Polygon(433 Points)   {C4D79A45-08C5-4127-BFF1-4EB7752…  {BF171339-6EA0-4E89-9CF9-AF54B57…  real         nein     3114        0
  881 │ Polygon(771 Points)   {9F734D0B-A560-4B8D-8EFD-1CB84A5…  {4DCD0D42-46A1-48D8-81DF-F71F9C8…  real         nein     5600        0
  882 │ Polygon(324 Points)   {06BF860C-333F-4464-8CC0-0E9E172…  {09756560-3232-40AF-AC0D-75EBFD5…  real         nein     3970        0
  883 │ Polygon(501 Points)   {26A1AE42-4332-4562-9E65-068CD71…  {114A6747-AA7D-48BE-ACF3-CDA5134…  real         nein     4314        0
  884 │ Polygon(505 Points)   {43B167EF-B51F-4294-83C3-AE420A1…  {792FFEFA-0F93-4444-B978-F4246A1…  real         nein     3255        0
  885 │ Polygon(410 Points)   {EB19FE7B-6DAE-4BA5-8298-F466CBF…  {A06BDEEF-AB80-439A-BD7B-4633A7E…  real         nein     8274        0
  886 │ Polygon(316 Points)   {C4E1D51F-9C53-4142-AF5B-C5061AC…  {F57926FD-A8BC-495C-89B2-F9C1D85…  real         nein     6571        0
  887 │ Polygon(822 Points)   {566A50A0-A059-4D44-A334-371E4E5…  {EAB3D5CE-ECF7-4C0B-8B9E-741C4E7…  real         nein     2316        0
  888 │ Polygon(378 Points)   {47B5E3A3-7639-4B8E-A39A-9322A47…  {7B79678B-A2B4-406D-AA42-0B1A61A…  real         nein     6207        0
  889 │ Polygon(600 Points)   {FCA881DD-5B96-4A95-A9BB-139FACE…  {4D14D6CF-A22A-4B4A-918F-DCCABBF…  real         nein     5064        0
  890 │ Polygon(475 Points)   {42B8DDD7-FF36-426F-A46F-819F944…  {010661A5-7875-4281-BCDB-A8376BD…  real         nein     3210        0
  891 │ Polygon(397 Points)   {B94F9089-E24B-4574-8F6F-8513882…  {97AE00CA-3D15-427C-AE60-4DEDFA8…  real         nein     4458        0
  892 │ Polygon(1134 Points)  {C15045DF-DB12-422D-9A93-98545B7…  {039A23EC-AD92-4AF5-A5CB-700734B…  real         nein     4600        0
  893 │ Polygon(356 Points)   {0E1031D2-D01D-4F1E-ABA5-FA33A50…  {071E31E9-AFCE-4EB3-BD13-9E6D3A0…  real         nein     2952        0
  894 │ Polygon(815 Points)   {CC728FA4-4C0B-4987-9BE1-0D77228…  {1B7C50DA-61F7-4448-9D42-3C54384…  real         nein     4954        0
  895 │ Polygon(577 Points)   {CB41CC65-6F32-40AB-962F-117AD54…  {311C39C8-D91E-4DC9-A205-ED62D3D…  real         nein     1290        0
  896 │ Polygon(643 Points)   {0ECD64E3-308D-4606-838D-6021557…  {01488BC0-9B6B-4892-BD2E-151E3A4…  real         nein     6452        2
  897 │ Polygon(399 Points)   {14BCF64E-C6ED-4E51-B86C-1691260…  {E471C292-6E60-4197-A0EB-58D9EC9…  real         nein     2718        0
  898 │ Polygon(563 Points)   {27B28D7F-FA42-4A17-A47D-AC7B02E…  {BEF955FA-7B70-4DD3-AF0E-A589ADA…  real         nein     4252        0
  899 │ Polygon(602 Points)   {E84336B9-8387-40B3-BC8E-BD1095F…  {F3207814-2BF6-4CD2-B299-676FD5D…  projektiert  nein     6542        0
  900 │ Polygon(397 Points)   {E8F304C5-1C25-4029-A051-811EE5A…  {4FAB11AF-B5F8-4AA6-AD2E-9E56E05…  real         nein     2805        0
  901 │ Polygon(1491 Points)  {00CB8ED8-8CE1-4526-A80B-1F6E3A1…  {8C122480-60F3-404C-ACC0-3ECFECC…  real         nein     8507        0
  902 │ Polygon(737 Points)   {84C3FDBA-2E42-41BF-AC95-B0407EA…  {9D90DAA9-0635-4A38-A6E6-D7E294E…  real         nein     8894        0
  903 │ Polygon(604 Points)   {9009DD62-BDFF-4ED3-89E2-8A3E5FA…  {278A56FD-8386-477B-AD14-C112EC6…  real         nein     7113        0
  904 │ Polygon(1333 Points)  {34B0E819-8D40-4C59-9B32-C9D523C…  {A4898895-AE58-4FA9-9F35-31F3257…  real         nein     1142        0
  905 │ Polygon(480 Points)   {0CA581DE-FD2D-4B10-9358-359821D…  {171AE1A3-5A52-4640-BA7C-D885DB9…  real         nein     3647        0
  906 │ Polygon(326 Points)   {11EAD0BA-1F26-4178-81FA-1B2A527…  {89338814-80CF-46D8-86EC-82075E2…  real         nein     8840        2
  907 │ Polygon(481 Points)   {C319DA77-33CF-4689-A319-5C1DBF2…  {5D4368B6-3417-4607-8781-C0A924B…  real         nein     1968        0
  908 │ Polygon(923 Points)   {73B3B11A-5DEF-4222-BFC5-4FD6EEA…  {7B75A26D-B9C9-4A41-9271-674043D…  real         nein     6460        0
  909 │ Polygon(1598 Points)  {EAE1B10F-64BD-421E-B2AB-115DBF6…  {2009020B-593C-47ED-8E3A-DE1E631…  real         nein     8425        0
  910 │ Polygon(739 Points)   {5CA916BF-3011-4827-A2E8-2B93296…  {BA936DA1-FB3A-496C-8604-EF2C848…  real         nein     5634        0
  911 │ Polygon(739 Points)   {10CFAAA4-2651-4C18-B3B2-5C56596…  {2E91DB08-2C42-4F1C-BDDC-DF75223…  real         nein     6014        0
  912 │ Polygon(639 Points)   {0F4E3464-6F96-4769-AF46-E7ADB2A…  {5B54D719-A512-468A-8288-0787FD9…  real         nein     6370        0
  913 │ Polygon(254 Points)   {DF047C06-CCBC-4D56-A66C-E9D3A22…  {8E95866F-B208-4AAC-B93F-30E1ED9…  real         nein     3984        0
  914 │ Polygon(759 Points)   {CFD9ED1E-23F9-4F71-A367-EB217A3…  {7AA56ABB-5A53-4DEE-B9AA-4196E07…  real         nein     8604        0
  915 │ Polygon(890 Points)   {525C2981-C0F1-4DED-8255-40A07DD…  {B6B8E679-BEF8-4DDF-95C0-7F50A58…  real         nein     3156        0
  916 │ Polygon(375 Points)   {C6D3D7A4-3996-400E-9D45-4CE64BA…  {B6CB3953-1657-461E-8398-766E785…  real         nein     3152        0
  917 │ Polygon(897 Points)   {2CE115DF-68CF-41B2-A7CD-33FD371…  {E5BD9A4B-70EA-4553-92D7-B39EFD5…  real         nein     3184        0
  918 │ Polygon(696 Points)   {5F9B41A5-BDED-40C0-80C4-1AB482B…  {CCC8856E-067E-4EE5-B2CC-C91A919…  real         nein     1146        0
  919 │ Polygon(1050 Points)  {206B09F2-A823-45E4-AC2B-7D79172…  {660F9988-63A6-4382-A9C3-191ABCF…  real         nein     6144        0
  920 │ Polygon(626 Points)   {90D84608-BAAF-49D2-B950-0DDC991…  {00789CFF-97EF-4DDA-B2DE-9B1C3F5…  real         nein     9607        0
  921 │ Polygon(327 Points)   {FF07EBC8-501F-419A-8308-3AA8974…  {217D7A77-20C6-44A2-A514-37EC8C0…  real         nein     3285        0
  922 │ Polygon(227 Points)   {E9BBDF5B-01E7-465B-8671-ADBDED3…  {9AA4A830-AABB-4F18-9AA9-CAA8403…  real         nein     4125        0
  923 │ Polygon(326 Points)   {70EC782B-F4D8-4050-BC25-02AA9BC…  {8B411F05-30A6-4E02-9355-D88C5BA…  real         nein     2206        0
  924 │ Polygon(625 Points)   {50063DB0-4B15-42F0-BC14-644D9A4…  {C11A0FCE-AFB6-458F-B9CE-13D2A86…  real         nein     7556        0
  925 │ Polygon(1065 Points)  {BCE4F2DA-56D6-4859-99D0-869638C…  {F1977690-2E26-4499-A5A2-39A9E3D…  real         nein     1628        0
  926 │ Polygon(545 Points)   {4CCE84B3-DA01-44A3-A144-8E1ABD1…  {DDC21394-337E-4254-81C8-E5B1C5E…  real         nein     3706        0
  927 │ Polygon(812 Points)   {FFA28FA2-E79F-4CE0-BCB4-E3D16CF…  {E19A72E4-29A4-407C-B676-34DF192…  real         nein     8824        0
  928 │ Polygon(1723 Points)  {6C631176-4925-43E4-A48A-DE57BBF…  {95957836-826F-4E4B-BA09-F5457E6…  real         nein     6434        0
  929 │ Polygon(647 Points)   {89156651-CB0B-4DF6-BBE2-8DE6468…  {B3FFCF17-37DF-496C-9FE0-1BE42F7…  real         nein     2416        0
  930 │ Polygon(79 Points)    {06E5A989-5BCC-48E2-976B-2DD9834…  {1AFA960E-4BBD-4B75-BF4F-0FF1090…  real         nein     1983        2
  931 │ Polygon(203 Points)   {052F7151-A54F-44B7-8DB3-D2D699F…  {EBD636F8-51EC-4990-ADC0-8CA8DD9…  real         nein     1897        0
  932 │ Polygon(496 Points)   {3448A9F9-36CE-44D2-AEBC-7D3D1FD…  {9394767A-485A-4D5A-BADD-6869E18…  real         nein     4467        0
  933 │ Polygon(283 Points)   {07B83035-9BE7-4076-84C6-C14DF46…  {B1760E55-F2CA-46C8-8220-99BE7B9…  real         nein     7245        0
  934 │ Polygon(191 Points)   {46EE1DB2-D76D-4F7B-9C9F-AB6E038…  {28AF9685-17E8-48E9-A7AA-8F4D888…  real         nein     7747        0
  935 │ Polygon(686 Points)   {C8635584-D95F-4749-ADDF-D24D32A…  {9B536955-89C7-4970-9E85-7BCD16E…  real         nein     6204        0
  936 │ Polygon(1425 Points)  {71CB51A8-3B9B-4C20-909A-EF79CD6…  {2D746EEC-708E-493D-B347-C490892…  real         nein     8577        0
  937 │ Polygon(503 Points)   {59CDE8D3-B853-44F9-85ED-C397EE8…  {2535DA81-0309-4379-936C-20768F5…  real         nein     4856        0
  938 │ Polygon(926 Points)   {638E4638-36A5-4291-B3C0-62F5B9A…  {C68F9085-7C10-4FFB-AE79-B0C6F57…  real         nein     9604        0
  939 │ Polygon(568 Points)   {0F6B05F5-8706-47A6-9F54-E77677F…  {4F83A366-F574-466C-B57F-2468CD8…  real         nein     6247        0
  940 │ Polygon(403 Points)   {66E5162F-3213-4B10-8AA4-D939620…  {02D1CD8C-F6C1-4A6A-810B-9B1D799…  real         nein     3036        0
  941 │ Polygon(361 Points)   {E666D0DB-2DE4-4CBB-AC6D-985F39A…  {9E6B4A42-2AF1-4F28-AB7A-E847A52…  real         nein     8231        0
  942 │ Polygon(509 Points)   {06EE3529-A24D-4F73-82D9-1D2E6D2…  {1595E07E-A71B-4FCD-B5B2-1849A2C…  real         nein     6777        0
  943 │ Polygon(460 Points)   {83A4E0E1-FB0A-4C8E-B920-C938136…  {E871D41E-7644-4729-8842-0EC6643…  real         nein     8197        0
  944 │ Polygon(646 Points)   {C50C23B2-D24E-443C-BA66-3897416…  {5C77F358-E14E-4226-8DC2-B248600…  real         nein     5234        0
  945 │ Polygon(396 Points)   {FED2A3AF-99A2-4A59-ACDA-4895A7C…  {78389A20-893B-44F3-B9F7-4D541C0…  real         nein     4416        0
  946 │ Polygon(513 Points)   {A62A8CA9-2CD3-45DE-A054-36ED7CA…  {DA286861-7B98-4AAF-B9EB-5BC1743…  real         nein     7111        0
  947 │ Polygon(615 Points)   {35BA46C3-C02A-4B86-A529-3CE5E4A…  {E06E86B6-2A58-49A5-9101-DC14089…  projektiert  nein     7562        0
  948 │ Polygon(230 Points)   {C7913AB2-5061-43CF-BCBA-1CF1F19…  {D8A8853D-DA1C-4A2A-98A7-08DED2D…  real         nein     8505        0
  949 │ Polygon(556 Points)   {5EE301F7-8B27-45C2-98D1-D4A781E…  {742B29BD-B94D-4852-ACBB-AE71745…  real         nein     2022        0
  950 │ Polygon(685 Points)   {8568891B-5CC8-42C1-A91A-8955FDD…  {94B41063-7CDB-4682-A8B2-439823E…  real         nein     1700        0
  951 │ Polygon(1273 Points)  {62D32CE1-33D4-4CE2-8C71-7C8189E…  {0FCEFBBA-E8F4-4445-A283-20A94F4…  real         nein     8874        0
  952 │ Polygon(235 Points)   {0A7B15F9-E8F2-4150-A92E-C1E3EA0…  {75C04230-60D4-48C5-AD68-F69F6A6…  real         nein     6717        1
  953 │ Polygon(209 Points)   {86015667-3244-40B9-9B7D-3241E26…  {2BDB1FAF-5FE6-4586-BAFC-56559C3…  real         nein     6405        0
  954 │ Polygon(898 Points)   {BAE350DF-64AA-43E2-9B3B-8FBEF28…  {6E2AAAA1-63BB-4379-B48F-5FBB667…  real         nein     9643        0
  955 │ Polygon(1331 Points)  {7D493695-7FCF-49EF-8E18-79BB3BC…  {D136002B-F439-40F8-AE34-F4E1E93…  real         nein     8754        0
  956 │ Polygon(501 Points)   {8E718C77-5535-426C-9D8F-CDEC088…  {51633731-B099-40FA-BAB9-1AA35A7…  real         nein     3412        0
  957 │ Polygon(268 Points)   {1395A982-CDE0-4846-8F8C-5B9F853…  {0B2B061A-E872-4E5A-BB95-DE86FE6…  real         nein     2406        0
  958 │ Polygon(541 Points)   {C8BA1B87-B29B-43DA-9C61-4B2890B…  {ABF305EB-C6FC-464E-B013-9C5398B…  real         nein     5430        0
  959 │ Polygon(1240 Points)  {CDE6E988-35CD-4529-9313-78E81D0…  {CA79BBEF-8FF2-4296-A9B8-F865A21…  real         nein     1450        0
  960 │ Polygon(1183 Points)  {ADAA4BD8-F2B8-4AC8-ABAD-C2E9984…  {6DC29A8F-73F7-45A8-B1D1-8D7F485…  real         nein     9053        0
  961 │ Polygon(531 Points)   {466DEBB1-F746-4A83-98B2-7036C3C…  {2335F114-6BE7-4C2E-A69B-A3D33AA…  real         nein     1275        0
  962 │ Polygon(1701 Points)  {5AAE37E4-9621-4FA8-BA59-919200D…  {4C4025BF-F253-4DE7-8000-F5C33BC…  real         nein     8405        0
  963 │ Polygon(403 Points)   {3AE95ACD-8FCB-44C2-93DE-64F619B…  {06C926BF-6668-4486-9888-9DE8BFD…  real         nein     2720        0
  964 │ Polygon(707 Points)   {50C3786B-E0D8-4A24-B7F6-6FB7BB3…  {72F63B0F-18BC-4BCF-AFCC-107278A…  real         nein     5034        0
  965 │ Polygon(312 Points)   {F4E42FBF-F62B-4311-A34B-A1C2194…  {710E6FDB-EEAB-4F12-995F-0A1BAA4…  real         nein     6452        0
  966 │ Polygon(430 Points)   {DD390251-1F15-4D36-9D05-B4888FB…  {6F488C14-4072-4195-A93D-5975E76…  real         nein     2942        0
  967 │ Polygon(584 Points)   {3480B92F-26E7-4627-920E-CD004C5…  {6AF49006-8316-429C-99E6-DDC450A…  real         nein     6748        0
  968 │ Polygon(558 Points)   {42B8F9CB-A83A-41FE-87D9-4834BD1…  {D690E305-B0A4-4B2E-B344-DA6A783…  real         nein     1665        0
  969 │ Polygon(760 Points)   {0EDB7D27-CB58-449D-AEA4-9DDEAF4…  {868C61F7-6695-4BE0-B414-94B6EFD…  real         nein     3280        0
  970 │ Polygon(698 Points)   {5AEFD7D0-0394-4789-909A-94F01FD…  {FDE199DE-6AFF-4768-8179-E5B0F59…  real         nein     5024        0
  971 │ Polygon(1535 Points)  {55029D85-4A6D-4D86-942D-F36E3E7…  {C4FCCE05-D595-4592-AFAF-01FA411…  real         nein     8704        0
  972 │ Polygon(609 Points)   {C4060311-0467-4F30-A1C7-7CFCFDD…  {5D84F3FC-CC16-4D5A-A210-5D8A642…  real         nein     4803        0
  973 │ Polygon(382 Points)   {0B3FAE8B-4AF5-4ACE-8F52-71C10CB…  {1F0524FB-EFD8-4326-B1DE-DF935AE…  real         nein     2516        0
  974 │ Polygon(324 Points)   {27E79A37-1C66-4BEF-8D63-1A80217…  {DAD0069E-8C36-441B-AB3F-205834F…  real         nein     7459        0
  975 │ Polygon(862 Points)   {8BDB76CE-B4C7-4B9D-AF93-36B560B…  {E41CD82A-3E7A-4F83-AAB2-7DB28C4…  real         nein     3465        0
  976 │ Polygon(330 Points)   {11987B7A-A367-4E0B-95EE-7D075B9…  {1702AD36-F9B3-4617-B0D6-52AF89C…  real         nein     7172        0
  977 │ Polygon(817 Points)   {E1867A4C-4EEC-44AC-8BF8-536105A…  {0298A64B-A7E8-4575-9E87-16249EA…  real         nein     7307        0
  978 │ Polygon(1094 Points)  {32688875-69C3-4E42-9707-BFE91A4…  {F1D7B1CA-8A6C-4BFD-9EED-92F6D11…  real         nein     6020        0
  979 │ Polygon(737 Points)   {4FBEBF8D-A5CF-4531-82A7-70BFDB8…  {A1DAA675-C9E3-4F9E-A8E1-652A84C…  real         nein     1372        0
  980 │ Polygon(356 Points)   {BA8199D0-EA37-4974-A1B3-8EC1C13…  {FA898770-DF68-49A2-94CC-8584FFC…  real         nein     3956        0
  981 │ Polygon(443 Points)   {36769654-5682-45C1-8783-A931733…  {C8149223-116B-4B8F-9F04-C2AE839…  real         nein     7424        0
  982 │ Polygon(247 Points)   {FC9CB953-1B9D-4F45-898E-2BA9998…  {3C29EA23-12AB-47D7-9A87-76E6FE6…  real         nein     7535        0
  983 │ Polygon(655 Points)   {C448CDE0-85B6-4B11-8E9E-D184A6C…  {93376A49-B81F-4DCE-9976-E0CED30…  real         nein     8536        0
  984 │ Polygon(441 Points)   {1C2E5EB1-ADBA-4658-9719-64F578B…  {553A1F51-93BA-4916-990F-CFC8283…  real         nein     6443        0
  985 │ Polygon(699 Points)   {552E1178-CB67-4D72-85EA-A36D879…  {27CB47CF-344A-4489-9327-B0B8062…  real         nein     2017        0
  986 │ Polygon(779 Points)   {BE9870FE-6176-4BDC-9202-51CD8A5…  {C1DA723F-D02D-453E-BEC7-0FFD3A6…  real         nein     3612        0
  987 │ Polygon(536 Points)   {24820BC2-E221-4EC5-946E-F503F12…  {B2ADF4D9-F88E-402F-88EF-4853BDB…  real         nein     3038        0
  988 │ Polygon(440 Points)   {2990BE49-3028-4C43-852E-62C64E5…  {B7100E77-9139-4FD7-8B60-0120248…  real         nein     8240        0
  989 │ Polygon(464 Points)   {A401AE35-70B0-4CB9-9682-4178503…  {400523BB-441A-4018-840A-3AFBFA8…  real         nein     3922        0
  990 │ Polygon(313 Points)   {92A45E8D-9F5A-4457-8062-926D0FF…  {FC50D235-D20F-48FA-BD8D-870759D…  real         nein     3753        0
  991 │ Polygon(255 Points)   {31488900-77F4-4BF0-9BD2-4A96526…  {B0CAB583-623D-4BBF-8127-98F79BA…  real         nein     6714        0
  992 │ Polygon(236 Points)   {2B0B29EB-F866-4177-81BB-C1E2525…  {F1FA3903-48A2-48AC-9FFE-21434DE…  real         nein     7306        0
  993 │ Polygon(346 Points)   {6E151372-5D88-4D9F-8C16-90759EB…  {2ACBDC81-95F5-4960-B94F-32DCE47…  real         nein     1845        0
  994 │ Polygon(380 Points)   {7C0F843B-77AC-4570-8ADD-78CEB5F…  {8BE96186-B790-47BA-A12F-88EA7D5…  real         nein     1963        0
  995 │ Polygon(699 Points)   {2428F3FF-58E2-44A6-8734-442D196…  {69A6777A-FFC7-472E-92DD-B5A8857…  real         nein     5623        0
  996 │ Polygon(462 Points)   {627F4717-1672-48BA-B6B7-C0F801D…  {AF0CF360-84B7-402E-AAEE-62DCF96…  real         nein     1344        0
  997 │ Polygon(260 Points)   {9C0EA526-3CD9-4C46-BC86-88D8AF3…  {A862C31C-E67C-4DC0-BD76-FB0C7D5…  real         nein     2722        0
  998 │ Polygon(593 Points)   {5C22E453-607D-482B-AC6D-C641B50…  {4978539B-F4CA-4768-B342-A49C244…  real         nein     9472        0
  999 │ Polygon(319 Points)   {39D988D3-EE97-4B5C-8DED-49FE8EF…  {489C2648-F25A-4CE9-9C87-FC7AAA6…  real         nein     3283        0
 1000 │ Polygon(662 Points)   {F98479E7-1CF6-47D4-8F6C-A398F87…  {6D1AEB75-C6FD-4B0A-BFBF-B665A9A…  real         nein     6968        0
 1001 │ Polygon(647 Points)   {CAC726DE-ECED-4796-B5B5-314E922…  {B3EBE528-A2E0-4851-A336-0CBB4DF…  real         nein     1347        0
 1002 │ Polygon(525 Points)   {06F68CBA-B18A-44BF-8120-F5B99E5…  {610360C9-5C10-43DA-98E3-F034938…  real         nein     5707        0
 1003 │ Polygon(610 Points)   {47204627-DD0F-406B-9248-25BD268…  {B56BB182-20A8-46B5-BEE6-91216A1…  real         nein     5610        0
 1004 │ Polygon(378 Points)   {80513C84-0749-4E2F-A7F2-3572334…  {F7AF5D2A-F80E-47DA-AB43-C87532B…  real         nein     3771        0
 1005 │ Polygon(1524 Points)  {DA808A85-9B3C-4043-8BC5-4CFF7F5…  {F4B0DBDF-7F59-47D8-931F-A70B853…  real         nein     1373        0
 1006 │ Polygon(580 Points)   {B474CD4D-75A9-44C4-9969-FF1CFD9…  {74B62FE3-D8B2-492D-9907-B9DF6D8…  real         nein     8124        0
 1007 │ Polygon(325 Points)   {23CB2514-D1EE-42CA-A4EB-E80BFD5…  {41C6865A-475A-4977-B812-E923B57…  real         nein     3297        0
 1008 │ Polygon(632 Points)   {4209E448-00FA-413B-B6AE-EF20F3B…  {6B850F4D-85D0-4957-93E6-16A9A74…  real         nein     2735        4
 1009 │ Polygon(386 Points)   {52F18BD2-4C8F-48CA-B796-C9E67BB…  {94F4D3BD-3FF6-42C3-8DDB-BD74C8B…  real         nein     6353        0
 1010 │ Polygon(895 Points)   {3D91AD45-6214-424E-9BF4-AA58508…  {EAC951E3-E997-40D5-ACEA-5794783…  real         nein     1824        0
 1011 │ Polygon(1048 Points)  {D2233024-8418-4167-A5C9-39DC0F3…  {CF7A5A37-EC94-4474-A9F3-06A5528…  real         nein     8414        0
 1012 │ Polygon(386 Points)   {54AE1EF1-D7FE-49E8-8B12-1204EA4…  {72051EC7-ACF3-49DF-965D-4A25013…  real         nein     3960        0
 1013 │ Polygon(989 Points)   {D12783D8-CCB8-4C53-995C-3F7983A…  {5FAE9E78-EE6D-4D71-81AA-1D6E1FF…  real         nein     3413        0
 1014 │ Polygon(565 Points)   {88557C9E-6D04-4A3D-B1C5-2181748…  {778923CF-396B-4203-A39B-AC04AC0…  real         nein     2504        0
 1015 │ Polygon(780 Points)   {F92EED43-E16F-4AE2-9F12-D760D85…  {B9D70789-E550-4D05-922A-158846B…  real         nein     3616        0
 1016 │ Polygon(504 Points)   {134E4340-4D95-4BE0-BF22-B081E62…  {006C64CF-EB71-44F1-9361-CDA8801…  real         nein     1636        0
 1017 │ Polygon(247 Points)   {2107007E-45CB-4F10-AE95-53F7867…  {A6679F8B-272F-46A9-B4D3-964D020…  real         nein     3904        0
 1018 │ Polygon(390 Points)   {DDE0C671-3EB5-4426-AE47-E386513…  {22AC7756-4D3E-4BD0-894A-E5EC821…  real         nein     4716        1
 1019 │ Polygon(357 Points)   {B05A135B-17C5-4784-92F6-37DF8E7…  {8293B708-D81C-4481-8E1C-16332CA…  real         nein     6805        0
 1020 │ Polygon(227 Points)   {99DC74BA-AFB6-405C-BE1A-487D040…  {65DF973A-D6B6-4389-98FE-6FDC9FE…  real         nein     6354        0
 1021 │ Polygon(1065 Points)  {DA9BD19C-DE36-4A47-AA22-076AD55…  {1E5004D3-AFFD-46F9-9AAC-EA80FD5…  real         nein     8309        0
 1022 │ Polygon(1370 Points)  {00C7299D-8EB1-42EB-91E7-01EE85B…  {AA8CAED6-2400-4430-BDF6-D9A3D95…  real         nein     9043        0
 1023 │ Polygon(1125 Points)  {70CD1717-6805-481B-8D27-445771E…  {1F38A6EC-A09A-4047-A187-0E74396…  real         nein     4917        0
 1024 │ Polygon(637 Points)   {05A15308-F995-40E9-A9A4-198E634…  {C5CD213B-9252-4341-91E6-EAE9C0D…  real         nein     4208        0
 1025 │ Polygon(756 Points)   {AB699095-B488-4DA8-B8F4-DBEB108…  {8C7CABFD-253B-4836-B89E-871B831…  real         nein     5073        0
 1026 │ Polygon(487 Points)   {CF91BEC6-7C0D-4ACA-8AC0-8312A4F…  {53CA2242-A01E-40A1-8DC9-D3ABA40…  real         nein     3661        0
 1027 │ Polygon(676 Points)   {946D6776-1DD3-4B71-8531-755BB66…  {29824D30-D17B-4628-8BA2-15091A0…  real         nein     8416        0
 1028 │ Polygon(1054 Points)  {C510CDB7-5252-4016-B659-85B1763…  {C3AE29CA-B985-4F83-AC3C-A6663CE…  real         nein     9313        0
 1029 │ Polygon(666 Points)   {083D72AA-07D8-4CFA-BC51-9934CD5…  {F49AC2F2-96B5-4A21-B574-80E8CBA…  real         nein     6026        0
 1030 │ Polygon(1911 Points)  {C8744F28-0562-409D-B9BF-95BF661…  {618AE17C-0210-470A-8E89-20D5A92…  real         nein     9050        0
 1031 │ Polygon(346 Points)   {A6301F41-9EDD-451C-966C-3282B6A…  {40E0F560-F484-4F12-98FD-3843D28…  real         nein     1648        0
 1032 │ Polygon(517 Points)   {F80EA3FC-8795-4689-B8B4-01B940B…  {DEB70D31-64F1-4F07-9D30-FFF65CB…  real         nein     4713        0
 1033 │ Polygon(718 Points)   {CAE87BEA-2938-4D4C-86F3-40C273D…  {82CAEC20-13D8-4EB3-A58B-64083FB…  real         nein     1712        0
 1034 │ Polygon(561 Points)   {AAC7852D-AEE0-4BC6-BA35-9E43982…  {1B9A9549-8954-4C63-A382-5296B73…  real         nein     4422        0
 1035 │ Polygon(422 Points)   {BB7CFB9D-2059-48E9-9600-32E91F3…  {DDC01018-8762-4DB3-8BAD-216E464…  real         nein     3273        0
 1036 │ Polygon(600 Points)   {C9FFFA86-8133-4AA0-8FB6-3782194…  {328B8556-9998-43FD-8A9B-51027BB…  real         nein     8915        0
 1037 │ Polygon(598 Points)   {8872D94B-5B32-40D5-B123-4C967A0…  {EC5B2FF5-6D30-4874-9014-8CB45A6…  real         nein     1543        0
 1038 │ Polygon(316 Points)   {2F099661-5C03-493C-B6CC-E0AD24A…  {66191856-3DA6-4185-AB22-5BB121E…  real         nein     6469        0
 1039 │ Polygon(313 Points)   {AC7ACFC2-7CFD-496F-A764-B410927…  {42EB1177-90CB-4E98-8D98-C85FF92…  real         nein     4244        0
 1040 │ Polygon(388 Points)   {617EA51F-57C0-488D-A3F1-BCB2A3A…  {7BE62A1F-C9F2-4AE7-92FF-014C1A7…  real         nein     3148        0
 1041 │ Polygon(1014 Points)  {641078D1-B1D5-41A1-9A4A-9E35831…  {09697548-FA70-432D-8474-D9E4547…  real         nein     4562        0
 1042 │ Polygon(188 Points)   {27803C32-D0BB-4413-AA1D-EAD7165…  {7C55969D-9E3E-4DAF-99CF-4E03BE5…  real         nein     2613        0
 1043 │ Polygon(356 Points)   {53544A87-BB22-4DBA-B7AE-0DA2308…  {4D3AC22C-FA3A-4EE9-B5AF-8CCEDAE…  real         nein     1149        0
 1044 │ Polygon(250 Points)   {7DAFD298-8132-43EC-B3E9-6D6126C…  {8A6A4C4B-8545-4F4B-942C-FA51C97…  real         nein     8880        0
 1045 │ Polygon(100 Points)   {53A03320-01ED-4965-B81A-F07A492…  {A685590E-2538-4964-8456-4E5ABA2…  real         nein     6548        1
 1046 │ Polygon(420 Points)   {EF98DF7E-E107-4E6C-ABDC-D9A99CC…  {9FA210C1-36C0-4695-BEC6-7297CD9…  real         nein     6724        0
 1047 │ Polygon(1151 Points)  {AEBBB9E5-1D4B-4A65-821C-E5A0E9A…  {7DC71A4A-633E-4208-A74C-9B6BFD3…  real         nein     9230        0
 1048 │ Polygon(658 Points)   {6F102365-74F3-4C47-BF00-1887479…  {0B9F0D20-ECCF-400E-A931-5EEA25E…  real         nein     3508        0
 1049 │ Polygon(791 Points)   {BD0094F1-8054-46E2-8043-ACC945F…  {5E59F452-8969-42CB-9CF5-BC31B1F…  real         nein     9113        0
 1050 │ Polygon(866 Points)   {BE52980B-A64C-4340-BB54-17BDF52…  {873C5A18-10D8-4B87-8379-E63B01B…  real         nein     5070        0
 1051 │ Polygon(1301 Points)  {81ED3F3C-7A12-4317-9C6D-0AF9EAC…  {62A905C2-867A-4E4A-9DDF-C8136EA…  real         nein     8630        0
 1052 │ Polygon(195 Points)   {8AEA5733-97CC-4872-979C-C2B3850…  {2BDA09DC-FB54-421F-BDE1-5642246…  real         nein     7517        0
 1053 │ Polygon(342 Points)   {62820ACE-D648-4680-9D7B-ABC3797…  {9101BCD2-F239-440A-98EE-9A4E529…  real         nein     6533        0
 1054 │ Polygon(321 Points)   {0281DC45-13A7-4E8D-9DD2-4BDA009…  {226BCBD5-10B6-4AAA-9A80-CE2DFA6…  real         nein     3912        0
 1055 │ Polygon(322 Points)   {A5BB5467-3F10-42B4-AC6B-28BCA3D…  {88B9FDF2-E314-4F19-8604-73E5C5A…  real         nein     7249        0
 1056 │ Polygon(275 Points)   {85E33637-DC6F-4BF8-BB21-7CAC318…  {B3ADB534-38B2-492D-A897-CF1C0C4…  real         nein     2534        0
 1057 │ Polygon(444 Points)   {4F551E77-6E62-4EF9-AF68-B26A317…  {F5FF731D-39F9-4274-A1C6-C97558D…  real         nein     2124        0
 1058 │ Polygon(558 Points)   {C3FE08D6-D612-4E21-B120-9DD9172…  {0F01D65E-EB63-4A60-B97B-B3EB73C…  real         nein     5112        0
 1059 │ Polygon(431 Points)   {B4E243CE-DE29-4A35-B525-BCF9D54…  {343C30EF-7CD0-48EA-9F24-890E436…  real         nein     7205        0
 1060 │ Polygon(594 Points)   {F34F3524-B046-4393-9B26-5B137C9…  {2CB06D29-0D5A-493D-AE0E-728F6E8…  real         nein     9050        2
 1061 │ Polygon(643 Points)   {2A08A7DE-85B5-452F-A39D-59A941B…  {900F6836-320F-458F-820F-A06BE9F…  real         nein     1669        0
 1062 │ Polygon(549 Points)   {8759D1B0-A14C-4821-BC0C-655E0B1…  {5F559DAD-0D21-4F5B-BA67-A5FFC23…  real         nein     7186        0
 1063 │ Polygon(790 Points)   {38CA4597-0EE7-450A-8161-682A703…  {BCDC2D9F-6B04-404A-AC08-D1F2316…  real         nein     9123        0
 1064 │ Polygon(467 Points)   {38694113-0450-496C-926E-F7AF86E…  {E937615C-A0F0-46A1-9D19-6E65857…  real         nein     3638        1
 1065 │ Polygon(1131 Points)  {8E8D688C-1BF5-4347-82F6-B9977F3…  {D3663386-3135-4C7D-845C-9895897…  real         nein     6436        3
 1066 │ Polygon(305 Points)   {35782D9E-0F68-4F32-981B-4E95C28…  {A72EB8A6-915C-4E5B-9C89-116AF4C…  real         nein     8855        0
 1067 │ Polygon(500 Points)   {76631484-4666-4FC4-8033-1FDFCE8…  {3777FE39-749F-44E5-AD0B-FA6AB59…  real         nein     3418        0
 1068 │ Polygon(1441 Points)  {FF486DE4-EBEE-4295-9F3D-733A608…  {C67CF12A-43AB-43F2-8876-339C315…  real         nein     8127        0
 1069 │ Polygon(531 Points)   {17AFA217-CBFE-4ADC-B6FA-0BEEC26…  {8F9E78AD-EA2E-4BD3-AFA8-A01A744…  real         nein     6775        0
 1070 │ Polygon(841 Points)   {468964CF-9A47-42B0-863B-309996D…  {C610D263-EA96-47F5-95AE-219E4B2…  real         nein     3132        0
 1071 │ Polygon(345 Points)   {27609C1B-9E59-4499-88A9-10B2987…  {9E32274C-4EE1-4C8A-A044-10F1DE8…  real         nein     5400        0
 1072 │ Polygon(955 Points)   {F308B4AF-6547-4DD2-9ABF-6BE975C…  {701FC10B-1E2D-4B1C-80BE-5983D19…  real         nein     1439        0
 1073 │ Polygon(252 Points)   {B48F02E7-CE5F-4F1E-BDFE-AA5A774…  {5CD5B37B-2EE7-4BA1-9647-FDB4259…  real         nein     1922        0
 1074 │ Polygon(320 Points)   {920BB7A4-5DC6-4092-81B0-E75D955…  {7ACE7FE9-5CF7-4AD6-81CB-E6739A5…  real         nein     6515        0
 1075 │ Polygon(355 Points)   {CB57F554-1A23-474A-83D1-4A4E711…  {7DB50374-EB1E-49BE-9FEF-E1D95F6…  real         nein     6383        3
 1076 │ Polygon(435 Points)   {ED3F6A02-6E8F-44AD-AD8A-BBCB650…  {17BCB17F-E1A0-433E-B908-7800A05…  real         nein     3953        1
 1077 │ Polygon(1060 Points)  {B3B475A6-124A-4BD4-A20E-5509EAD…  {42DFB645-A9F5-4FF4-B286-BF95803…  real         nein     8700        0
 1078 │ Polygon(740 Points)   {A0205830-991F-495D-AD48-D9D82CD…  {CD37983B-C8DB-4B4E-97C1-01480BA…  real         nein     9402        0
 1079 │ Polygon(510 Points)   {18F0984C-E02B-4902-9810-496EB62…  {47F1BF3A-C53D-418C-BEE8-68ECFF3…  real         nein     1713        0
 1080 │ Polygon(859 Points)   {EB23B5B9-4C88-4EF9-9CC0-F37FBB4…  {B21CA9A6-1CF4-4235-9D7A-6A65FDC…  real         nein     6147        0
 1081 │ Polygon(816 Points)   {286D7D8A-64A8-453B-9E31-C850C27…  {9EF9974E-EA01-4625-9638-770D1E2…  real         nein     8192        0
 1082 │ Polygon(370 Points)   {7DABC56B-5524-4016-9726-EE6AE2C…  {5AEAF1DD-6A65-4E53-82AA-B1C5625…  real         nein     2885        0
 1083 │ Polygon(924 Points)   {6A477830-83C1-4D77-9BAB-5DC921F…  {D360B8A2-3479-4831-907B-B1FACFC…  real         nein     2827        0
 1084 │ Polygon(579 Points)   {473D934E-6A74-4B7A-BCF6-7C71821…  {526AD8F8-E860-4A20-B5E2-FE55BDC…  real         nein     3930        0
 1085 │ Polygon(626 Points)   {DBB1AF69-C81A-4E9E-8D2A-146E8E9…  {D6E62B9D-F107-49BF-880F-8ADFF0F…  real         nein     2616        0
 1086 │ Polygon(344 Points)   {36A25619-6A30-4F9D-8454-4ED929B…  {60ED7AB2-FE40-496E-9B6B-5329688…  real         nein     6772        0
 1087 │ Polygon(626 Points)   {EF4439B1-2400-4375-B613-B6A1EA0…  {56974D0F-603A-48B4-82E5-005DF0B…  real         nein     5703        0
 1088 │ Polygon(224 Points)   {6FE98378-0D5A-4A29-8C38-D67245A…  {5FFE8395-B037-4B2A-ABE3-D81A874…  real         nein     4460        0
 1089 │ Polygon(594 Points)   {0CB2AF79-D669-47C0-82A2-EF08482…  {E1E184EE-6DA6-4EBA-B852-D58D3A5…  real         nein     8738        0
 1090 │ Polygon(928 Points)   {2D6C0E9B-7841-4C49-98E1-5C1175B…  {5A4B5F5A-E20F-4318-9E8F-9F418EA…  real         nein     5728        0
 1091 │ Polygon(503 Points)   {849ABCCC-A404-4CF8-B4DA-EB08021…  {AD7BD9C6-B0D1-4FC9-BEE8-04598F5…  real         nein     3043        0
 1092 │ Polygon(430 Points)   {40396E60-7279-40E0-A29C-42EDC11…  {7CAC9EF4-A047-4C2B-80D9-C5CBDF5…  real         nein     6513        0
 1093 │ Polygon(229 Points)   {E2D3621D-1DA8-44F9-BA97-65ACF36…  {2FC61642-9CA9-4A5A-B6DB-8CF09CB…  real         nein     7220        0
 1094 │ Polygon(851 Points)   {B3628F2A-D411-45B4-A998-FDF4E5F…  {D2F3CB33-6CA9-4F93-A090-223E3E6…  real         nein     4912        0
 1095 │ Polygon(377 Points)   {0E3141C4-62CB-415C-BBC3-E9D8BF5…  {4CA8F976-C886-4932-9055-3247BD4…  real         nein     3257        0
 1096 │ Polygon(797 Points)   {38ECAB0C-E645-4AC0-A96A-5B77F9B…  {D411CB3A-1D67-4827-A6A5-22C0212…  real         nein     3144        0
 1097 │ Polygon(341 Points)   {CB6DE813-3F15-4D8C-8FB1-745AA8D…  {8709FF33-4061-410E-9630-63C8BBA…  real         nein     7176        0
 1098 │ Polygon(359 Points)   {2DBD99D0-A757-46AF-BF55-95BE55C…  {FFFF92F7-9039-4EBA-8484-228508D…  real         nein     6611       16
 1099 │ Polygon(652 Points)   {8F8D83C3-F96F-4B61-AB45-8A50E84…  {2C7FD519-4F48-428F-8ADF-2CB4B8E…  real         nein     2067        0
 1100 │ Polygon(513 Points)   {ADA81B4B-4155-4D20-B21B-BC49231…  {9ECB4BEF-2DE6-454E-B127-CB48DF3…  real         nein     8187        0
 1101 │ Polygon(396 Points)   {81D353BA-AE8C-489E-8F68-FBF71C4…  {32532059-DAD4-4342-A281-E2A2544…  real         nein     2073        0
 1102 │ Polygon(799 Points)   {45FF9A5A-4B22-475E-9E6D-9382244…  {E4E61C8B-364F-454B-B79E-B29082A…  real         nein     9633        2
 1103 │ Polygon(524 Points)   {85AA10E2-CAF2-419D-90E5-68E20C9…  {553FA9E6-62A2-481C-A045-CF1A895…  real         nein     8594        0
 1104 │ Polygon(500 Points)   {F0077276-8E65-40D8-830D-4F27EA4…  {721CB413-A18D-4A51-9742-59F28CC…  real         nein     1338        0
 1105 │ Polygon(550 Points)   {FDAB284D-7CE9-4BCD-B49E-8365C2D…  {828CFB85-A5CE-475D-B0E3-967CC65…  real         nein     6276        0
 1106 │ Polygon(382 Points)   {5E357B7E-0C6D-44C7-9F85-7DCCAC2…  {7209C44C-A3A7-4401-A7D4-D3845D6…  real         nein     4457        0
 1107 │ Polygon(254 Points)   {6C230A31-172D-4256-B26D-5E810C2…  {A585679B-033F-4646-85A5-63BA8AF…  real         nein     2904        0
 1108 │ Polygon(806 Points)   {46FCA5CD-E884-45E7-9CC0-C4B2E15…  {C8AD7958-DA44-47BC-B218-73B31E1…  real         nein     6048        0
 1109 │ Polygon(880 Points)   {763410E3-1870-459D-B9A2-363056A…  {5338195C-C9D8-489F-9AB2-E08C4E0…  real         nein     9054        0
 1110 │ Polygon(250 Points)   {E7271FF1-0D46-460A-97A1-8631F25…  {AC143FBB-EAE2-49CE-8153-8585442…  real         nein     3203        0
 1111 │ Polygon(428 Points)   {BB42F419-E0CF-4D2E-80A1-9FC25DA…  {0008C3F2-A0EE-4CC0-B4F5-29AD825…  real         nein     2517        0
 1112 │ Polygon(291 Points)   {D4547393-6F71-4F69-9338-021407C…  {169B981C-9907-4B8F-84EE-8519E19…  real         nein     2610        2
 1113 │ Polygon(420 Points)   {92D3CF9B-3BEF-4622-842F-2AF4B3E…  {7F8FA464-6F96-4229-8C83-4A7989C…  real         nein     7302        0
 1114 │ Polygon(1088 Points)  {AAED9243-50E5-4480-ACB5-799016E…  {1F2C0254-8A88-420B-B7E2-4BD6440…  real         nein     5734        0
 1115 │ Polygon(661 Points)   {DD4C1CDE-22A2-469B-90C8-A0537BD…  {F9981FF2-85CA-4746-BE14-739A4BC…  real         nein     9464        0
 1116 │ Polygon(461 Points)   {F58DF745-DEAA-4F98-8E0C-38CC1C6…  {56C3AC62-BE72-4ACE-A569-D8BFD59…  real         nein     7320        0
 1117 │ Polygon(518 Points)   {A3CCF30E-B5F9-451F-B853-6CFA00B…  {F9BD0839-A4C4-453F-8FED-66EE1FA…  real         nein     1261       35
 1118 │ Polygon(898 Points)   {48E05875-A0F5-4375-B6B8-95A8008…  {33BE845C-5274-4536-8DFA-1FB1BF5…  real         nein     8816        0
 1119 │ Polygon(704 Points)   {C5737CFA-BF0C-4638-A0AB-109FCCD…  {00EB9E5F-E366-4B38-B7FC-F9DA0E1…  real         nein     5063        0
 1120 │ Polygon(648 Points)   {7E64D9B2-7469-4CA0-B3E6-B71E982…  {1E8528E0-848A-4F05-B95B-88EDB24…  real         nein     6264        0
 1121 │ Polygon(828 Points)   {4F4EAEE4-6266-443A-ACD6-2778F14…  {E56DEBFA-C827-465C-A4F2-337E8AB…  real         nein     1627        0
 1122 │ Polygon(528 Points)   {7F3EC575-62B4-4DB2-8E33-A8DCA0A…  {E086B599-B19B-4E76-BCBF-DCE28B5…  real         nein     6423        0
 1123 │ Polygon(782 Points)   {ED259F52-B486-47B0-9830-C8CB9D5…  {B44DE91B-5149-4021-8D3E-7FC7387…  real         nein     5727        0
 1124 │ Polygon(439 Points)   {C07BCDD7-9B4E-41FD-9B00-1B71DA3…  {40DDC4C0-D885-4B43-9352-60FFFD1…  real         nein     8225        0
 1125 │ Polygon(797 Points)   {465DAEAE-AAD1-4467-BA07-7A1BB22…  {2C0267E9-FC55-4C77-BF66-63FFB97…  real         nein     4955        0
 1126 │ Polygon(1464 Points)  {DE67AD15-388A-4F1B-90FF-84BB047…  {A9C3BFDB-B066-45F2-8E22-9F3FCB0…  real         nein     8320        0
 1127 │ Polygon(681 Points)   {70E5E5B6-FFA2-4971-BD47-CB7C78C…  {196B04E9-AA5C-4AC6-90A6-73EBBB8…  real         nein     4522        0
 1128 │ Polygon(466 Points)   {E472AAB8-0177-481B-8C2B-B7E1F34…  {A77F52EA-A5C0-45C7-A9FB-BDC1601…  real         nein     5303        0
 1129 │ Polygon(981 Points)   {1545AA5B-611F-49E4-B249-1095AF8…  {7670C915-C1A2-405B-B508-2090369…  real         nein     1833        0
 1130 │ Polygon(342 Points)   {C3200581-2555-4C2C-8D14-59F7D61…  {D2637EB9-9B4C-4820-B4CE-78FFC85…  real         nein     6678        3
 1131 │ Polygon(597 Points)   {99FB6EA9-774E-4176-AE1C-0F418F9…  {C8E48780-A9AA-4A2A-AB39-A19D95A…  real         nein     9063        0
 1132 │ Polygon(153 Points)   {187D1C33-1BC5-4009-AC73-32C01A5…  {E0D15863-607B-4D00-9A01-DE84D0C…  real         nein     9479        0
 1133 │ Polygon(259 Points)   {1CFBCCDB-026E-4801-977C-7484398…  {63565F37-6D91-4A88-8A79-732C35E…  real         nein     4625        0
 1134 │ Polygon(971 Points)   {EB3FC292-CD38-49E0-9CB3-FBB894C…  {04AD3AB5-80F0-4F27-8217-9231B57…  real         nein     8193        0
 1135 │ Polygon(381 Points)   {E13E7330-B028-49DB-981A-D852D50…  {7CDE28F2-6216-4EFA-BB60-AA5CA0A…  real         nein     7411        0
 1136 │ Polygon(780 Points)   {D93DE5B9-35DC-4936-ABAE-49C078D…  {D52D3530-0535-474A-BACA-4A0AF9F…  real         nein     1276        0
 1137 │ Polygon(249 Points)   {DF0BC94C-332F-4B50-847D-9D45633…  {670C1DCD-D481-4C08-B957-2509853…  projektiert  nein     6541        0
 1138 │ Polygon(160 Points)   {4E3D1C70-1F86-48E8-8F97-460A1E8…  {893A2DC5-BB86-4DBA-9474-CED6EE9…  real         nein     6663        2
 1139 │ Polygon(500 Points)   {54F27882-839F-49EC-AD88-049DD61…  {A41ED665-AA9A-4FEA-A467-397F863…  real         nein     6275        0
 1140 │ Polygon(775 Points)   {D22ACFBE-FF66-453A-B52F-3E7E4D8…  {0B462199-F082-4B09-A34A-7B23440…  real         nein     9108        3
 1141 │ Polygon(856 Points)   {9D7E5F53-F0D4-4FBD-BD68-EB36508…  {81251B92-89F3-4481-8B10-F6973F9…  real         nein     6019        0
 1142 │ Polygon(139 Points)   {4B8F7162-93A0-4CF5-9AF2-C1A0DE7…  {B51B612B-B282-4313-B44B-F4CDF7D…  real         nein     6315        2
 1143 │ Polygon(645 Points)   {CF340CA1-9003-4F77-A590-D9A781A…  {FC8C0B6A-2F5A-4932-A40A-B168F4D…  real         nein     9304        0
 1144 │ Polygon(738 Points)   {095E8FA4-84B1-4F62-9A98-9A2F23B…  {03EE15F5-4D6E-4016-B25A-EF0F302…  real         nein     7213        0
 1145 │ Polygon(265 Points)   {D830FED2-8892-4818-8F76-DF02FDF…  {3104ADFE-2C6D-43AE-8454-1155407…  real         nein     4418        0
 1146 │ Polygon(951 Points)   {0E025CEA-3BDD-40B3-BED3-EE88A9C…  {2D80975A-ADBE-4B7A-869E-E063A57…  real         nein     8634        0
 1147 │ Polygon(210 Points)   {E718E3A1-2C84-4D9E-BB43-A49EE22…  {E1AE58DD-2493-42A5-B852-0F28759…  real         nein     1868        0
 1148 │ Polygon(664 Points)   {BEB43A6F-501F-4E6A-BAA5-96F1442…  {38C1DE4E-EFEB-4E63-A4A6-1DF934F…  real         nein     8196        0
 1149 │ Polygon(490 Points)   {A9CC1E56-CF02-4966-8EA7-14EB63E…  {84436C07-E906-4098-B62C-2C96C5C…  real         nein     6518        0
 1150 │ Polygon(272 Points)   {D389D3FF-9371-4696-931B-933FE7E…  {20CC1330-A4B2-4100-A92B-4C8D1F7…  real         nein     9444        0
 1151 │ Polygon(542 Points)   {DFB7E19B-E622-4AF7-91CD-3F80956…  {969443C1-B10D-4C2E-812C-4D55F70…  real         nein     5085        0
 1152 │ Polygon(1786 Points)  {D0F449F6-0800-4CB1-9E6E-B3DCD08…  {B0BA0B24-9310-4D2E-85FD-500AC23…  real         nein     8484        0
 1153 │ Polygon(403 Points)   {E99D9256-1F99-47C4-B560-8C988B8…  {387F5505-3FCE-4A2B-8236-4CD475F…  real         nein     6424        0
 1154 │ Polygon(208 Points)   {6CF948D6-EA1E-4192-B3E8-98EDC1B…  {104B3EFE-BEBD-485A-A063-733BA08…  projektiert  nein     6556        0
 1155 │ Polygon(608 Points)   {23DA229C-D14B-429F-B358-4A52960…  {D2E05D53-820F-4310-9949-CC9315F…  real         nein     2943        0
 1156 │ Polygon(865 Points)   {7CCE70DD-B177-4DB9-9471-EF77F66…  {417C8C72-7BD4-49E8-8CF3-132ABD8…  real         nein     8164        0
 1157 │ Polygon(1009 Points)  {8F90C175-1D79-492C-B9A9-3845F57…  {5921A846-EABD-44A8-87D5-30A2A33…  real         nein     1169        0
 1158 │ Polygon(420 Points)   {78007521-0FB6-47B7-A915-BF2A919…  {7779D62D-A38A-462D-B5A2-94E01F6…  real         nein     4225        0
 1159 │ Polygon(327 Points)   {6CBD05F2-699D-488E-8A95-D056C5D…  {1CD53D97-D43C-476A-8272-AE5FEF5…  real         nein     1783        4
 1160 │ Polygon(1040 Points)  {7EEBFC56-A857-446C-B63F-F642DFE…  {3A19F72A-AA00-49B7-8E76-EFBA7F2…  real         nein     8953        0
 1161 │ Polygon(663 Points)   {F621BF7B-129F-40EB-B020-585EC2B…  {7343F952-B8FE-427E-8D76-E44245F…  real         nein     9502        0
 1162 │ Polygon(969 Points)   {FCBA9472-0FA7-48DC-A37B-D15D98E…  {85A383E9-A38B-4DD5-8157-7BEBF1D…  real         nein     8499        0
 1163 │ Polygon(197 Points)   {8AE206DE-C2E2-4191-AFB2-CFDE9A8…  {4B680B89-D316-4DB6-BEDD-1D292AB…  real         nein     1786        0
 1164 │ Polygon(315 Points)   {2BAC20AF-0905-4BF9-AE6F-2D9B127…  {32A85926-8DDE-4044-A782-90E1D19…  real         nein     2762        0
 1165 │ Polygon(973 Points)   {7EA11FC9-BB38-47D6-AF77-613E32B…  {7F65D2C7-2D31-4D62-9857-DC83FAF…  real         nein     2746        0
 1166 │ Polygon(245 Points)   {80287417-280B-4C24-B8FC-0602FE8…  {D6F6F6C8-5BED-4835-A9DD-E459DA5…  real         nein     3953        0
 1167 │ Polygon(653 Points)   {80506449-3CA1-4EBD-B255-209CDB9…  {103A5568-359E-4880-A05E-CCD2A17…  real         nein     8777        2
 1168 │ Polygon(300 Points)   {C6A83155-57B5-49AD-9411-9309851…  {EAE0575F-3F38-41C3-8D1D-D86771F…  real         nein     6661        0
 1169 │ Polygon(371 Points)   {9208E837-3F4D-49BF-93D2-7C7FE8A…  {C522CB2C-2ADE-4A28-B562-5B8945A…  real         nein     2923        0
 1170 │ Polygon(418 Points)   {F2943490-54BA-49E8-9258-D9A6A1A…  {E605877C-C224-4748-8AFF-5D95CC6…  real         nein     3972        0
 1171 │ Polygon(436 Points)   {4B57B361-113F-4A96-8FB9-4B003D1…  {3759DA1A-7919-4DDD-80D3-8D33D56…  real         nein     3700        0
 1172 │ Polygon(816 Points)   {5C734D2A-2AFB-471B-B988-AEB0A43…  {9B99C827-3CD1-47AA-9F3C-2446454…  real         nein     8303        0
 1173 │ Polygon(828 Points)   {79A82087-D4D5-46D0-B044-B6CA821…  {A050B835-3976-41DC-A707-AEBC79D…  real         nein     3531        0
 1174 │ Polygon(247 Points)   {417BB501-B0EC-4964-AFDE-E0828DA…  {7613272D-AD8D-4D6C-8164-FCA70F9…  real         nein     2926        0
 1175 │ Polygon(917 Points)   {98247C11-A024-4D38-BA74-3765CA0…  {00D0DF0F-377D-4629-9E9D-57C499D…  real         nein     5018        0
 1176 │ Polygon(535 Points)   {ADF68016-8B37-4078-A308-EF78169…  {460AAAE2-7318-4242-9F7D-F1FD293…  real         nein     8590        0
 1177 │ Polygon(266 Points)   {1CB9DD57-CE80-41AF-8FCD-EF734B9…  {2E53992B-E4D7-4F51-8349-64B801A…  real         nein     1913        0
 1178 │ Polygon(304 Points)   {A3D01736-69DA-41AC-80CC-7CCC78E…  {88BD3B28-85C2-497D-8DCA-3C7DDDD…  real         nein     3202        0
 1179 │ Polygon(311 Points)   {8B5E0675-5CA4-434E-98B7-4A0A246…  {38EB8C1E-6254-4FC4-BA3C-36BA07F…  projektiert  nein     7524        0
 1180 │ Polygon(592 Points)   {8753F69E-4CED-4F9C-8F37-3BD4CD7…  {4EDE8A39-1B1A-4B77-833C-0B97AED…  real         nein     2908        0
 1181 │ Polygon(650 Points)   {A98EB041-A936-4990-AB43-00888A1…  {936E9257-4429-44F9-AF31-87BEF94…  real         nein     9413        0
 1182 │ Polygon(1570 Points)  {2ABB298C-2AAC-48F8-B3AF-CD461A3…  {395FABDD-F0BF-4B7A-889C-45690A7…  real         nein     1418        0
 1183 │ Polygon(775 Points)   {9C9B655C-D7A8-43E1-9DE5-6F7A972…  {23EF6C08-A03C-425C-BD02-3F44275…  real         nein     8477        0
 1184 │ Polygon(906 Points)   {95AF794F-C4AB-4253-ADBB-E7EAC83…  {BFEF00BA-3DE2-4D85-9717-2E120A3…  real         nein     3087        0
 1185 │ Polygon(1040 Points)  {A8F8B5C7-7B83-4053-8DCB-5ABFE77…  {30737284-DE7A-4C1F-B638-232A47B…  real         nein     9621        0
 1186 │ Polygon(500 Points)   {34EC2491-12FD-44A3-B6F3-C01BB8F…  {8E69E6EA-CDC0-41F3-AC50-EBA151C…  real         nein     5436        0
 1187 │ Polygon(911 Points)   {854516F9-607B-4C3B-AA06-7A614C0…  {8449EF1F-CB49-4A92-A86C-CE338A0…  real         nein     4450        0
 1188 │ Polygon(335 Points)   {1E8431DB-8B18-407A-89C4-1C56997…  {DB48DD87-901F-4860-8AD6-91ADEBD…  real         nein     1347        1
 1189 │ Polygon(630 Points)   {AE8D74CD-2318-42DE-A796-6C2AD32…  {EBC32BB2-4523-45BE-8780-5FE48EF…  real         nein     6215        0
 1190 │ Polygon(69 Points)    {DC3FE823-9D04-4490-858F-4DA5A56…  {08ADFC73-C9C8-48E9-9532-B3B96D7…  real         nein     7317        3
 1191 │ Polygon(829 Points)   {160E77B7-EE84-4D17-8430-40DDC8B…  {6A98E946-6720-4717-98AA-51CFF79…  real         nein     5000        0
 1192 │ Polygon(758 Points)   {29A46459-0678-4095-98F0-FD15F37…  {6732880A-B3B0-45CE-B255-CE63C8B…  real         nein     8805        0
 1193 │ Polygon(1026 Points)  {C8FE310D-3A19-4763-BD25-3467C28…  {DDAEBEA8-8C10-49D3-B64C-8CCFB4C…  real         nein     9620        0
 1194 │ Polygon(642 Points)   {94FCB4E8-0DE8-41CC-81C9-3C1B925…  {FBC8B739-4ED5-4651-B6D2-8C53CA6…  real         nein     8462        0
 1195 │ Polygon(464 Points)   {9DA0A687-6A60-43DA-A31D-8A806C6…  {CFB3B12A-0DA3-44CA-B099-94B0520…  real         nein     7240        0
 1196 │ Polygon(724 Points)   {837069D5-A188-4BF0-BF29-B382A29…  {CFFEDA9F-E157-4CC8-83E6-1688DEF…  real         nein     3513        0
 1197 │ Polygon(789 Points)   {C7E65935-534D-4BF6-BFA5-110A330…  {1D53A41D-0D5B-4749-975D-E1767CB…  real         nein     6245        0
 1198 │ Polygon(149 Points)   {5D43B5E3-3A44-400A-B98A-FB3CCCE…  {900C568C-169B-4B84-83E6-0CCB4BA…  real         nein     2612        0
 1199 │ Polygon(438 Points)   {E503D9EF-F339-44B8-B28D-E48CC05…  {D52B7C7E-54B8-4743-9337-AE092DD…  real         nein     4123        0
 1200 │ Polygon(1658 Points)  {883C2128-B409-44FA-B445-0943337…  {4AB6C233-F7BB-4734-8DD3-9C93412…  real         nein     7056        0
 1201 │ Polygon(960 Points)   {1CF3AF80-54D9-4720-A1CE-BFAFD02…  {4F24B288-FDC5-4410-883D-B29413A…  real         nein     8627        0
 1202 │ Polygon(227 Points)   {1A8A028F-0604-45F7-A451-DECABC6…  {998B87F1-B03A-45C7-9F55-DC5BF43…  real         nein     2832        0
 1203 │ Polygon(651 Points)   {7C13DA9F-6DD7-433E-BE29-2730D00…  {ABAB90EF-6E58-452C-B8CB-71F6D5F…  real         nein     6105        0
 1204 │ Polygon(298 Points)   {BE536DAC-E786-4239-9363-0E8B349…  {36D4CE13-C467-42EE-96FF-B3B5720…  real         nein     7168        0
 1205 │ Polygon(1218 Points)  {CD8CB095-6D65-4511-931C-4CB92E6…  {743F3283-0AFF-4D38-A346-AEB2D3B…  real         nein     4463        0
 1206 │ Polygon(654 Points)   {B00504D6-2D48-455F-9639-C7B6DCE…  {CA378BDD-3349-4363-8D86-37A7926…  real         nein     8266        0
 1207 │ Polygon(203 Points)   {3C9E6E7A-40CC-4503-A2F9-FCAD332…  {50440ED1-FFC5-483D-9D1E-A6C5AB1…  real         nein     1942        0
 1208 │ Polygon(315 Points)   {533DA889-0AFC-430F-BEE9-836F73E…  {567F2B12-443A-4287-A071-1B91893…  real         nein     3858        0
 1209 │ Polygon(621 Points)   {37F327F9-4F2D-41B0-B1F3-BDA1B39…  {343C59DD-F693-48A4-8669-9456371…  real         nein     5272        0
 1210 │ Polygon(729 Points)   {2DD866A8-11CC-423B-8B97-7554EF7…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9011        0
 1211 │ Polygon(732 Points)   {2F2AA23E-BAE2-4D60-93AB-9B6870E…  {3A5B0353-334A-4614-A630-D01E55F…  real         nein     8735        2
 1212 │ Polygon(1083 Points)  {8BF27FD2-767C-41A4-B7E5-16CFC99…  {10FACB0C-CE3B-4806-8E68-0DBDADD…  real         nein     9108        0
 1213 │ Polygon(725 Points)   {D8AF3FD9-A52A-47A3-A0DF-7879D90…  {7314F7E1-51C4-4A67-B5AA-0060915…  real         nein     9204        0
 1214 │ Polygon(454 Points)   {9C4202AD-41E8-457A-B929-4BC4AD4…  {88329C98-6281-4E85-AC55-E2C80CB…  real         nein     8555        0
 1215 │ Polygon(386 Points)   {0EEF5D4E-39BB-4357-A2EB-4D323A1…  {0D849893-67D1-48EA-B13A-58E2B04…  real         nein     4800        0
 1216 │ Polygon(670 Points)   {7E3D130F-F39F-43D1-974D-EFBD724…  {DDC5394E-6452-4C30-854A-6545459…  real         nein     1642        0
 1217 │ Polygon(224 Points)   {6CC1EB16-DC61-4800-ABDB-4FBAFCD…  {C16BE78C-CC00-4BEF-85AF-6756362…  real         nein     1410        0
 1218 │ Polygon(378 Points)   {4411BDD2-A765-4EBF-BA12-D47BC9D…  {D9359A03-7563-41FE-91B4-82C6CCC…  real         nein     6616        0
 1219 │ Polygon(1077 Points)  {C5692B3E-3691-4F3D-8F88-296DD61…  {7C1C61B6-E512-4CD4-B617-EB6ECB0…  real         nein     8635        0
 1220 │ Polygon(573 Points)   {FAFE5B80-5D6D-4428-B6C0-5489F2F…  {14D2FC29-ED53-4F39-9419-885656B…  real         nein     3423        0
 1221 │ Polygon(502 Points)   {7C6CCF3C-6E40-484A-901B-3CF2822…  {577D1E58-1D30-47AE-9D08-52FCF38…  real         nein     2208        0
 1222 │ Polygon(286 Points)   {03C29F6C-258F-4C1F-9B81-D64E427…  {64CA0387-DB2E-4CEE-B0BE-0043A1C…  real         nein     3913        0
 1223 │ Polygon(390 Points)   {5B8789DE-86B8-4B5E-B8D8-6630702…  {A7B599E3-C50C-4927-9C0F-96EE864…  real         nein     1217        0
 1224 │ Polygon(1220 Points)  {BF9E6D06-85B7-4897-90D1-0C7B9A1…  {7345C3E5-FF89-4798-8E86-18D0D70…  real         nein     8135        0
 1225 │ Polygon(589 Points)   {B7F73CF3-0908-4038-A2D3-7F1D0FF…  {A7C094D6-BCF3-4477-8700-63959C3…  real         nein     3267        0
 1226 │ Polygon(584 Points)   {EDCE8F99-8099-4CEE-9BFE-E71B054…  {6FD17A6A-F461-4187-87F3-0897804…  real         nein     3086        0
 1227 │ Polygon(453 Points)   {E381B173-BE85-444A-B224-543C919…  {54A3FC46-AB45-432F-BFC8-30B1085…  real         nein     5628        0
 1228 │ Polygon(470 Points)   {AB04A0BA-A3AF-41C8-822A-CFD2B21…  {FB0B1356-24F8-41D0-9BB0-848E2D2…  real         nein     3552        0
 1229 │ Polygon(482 Points)   {DEA2EA1B-BAF9-462E-A631-36DC713…  {D56C0D42-1E8E-4A1C-9E5E-5564EEA…  real         nein     1718        0
 1230 │ Polygon(452 Points)   {71FF5322-0520-42AE-A4A4-0BC1E7C…  {F221E55A-9552-4FB0-8405-56BB54E…  real         nein     5107        0
 1231 │ Polygon(213 Points)   {24BFC7B2-6E20-426D-A3B4-AE8667B…  {297D374D-5A16-47C5-BB36-ADFFEC1…  real         nein     6611       13
 1232 │ Polygon(912 Points)   {07022753-EC6B-44A9-ACB1-F5655B3…  {C98EAC34-CCC7-4682-B9F9-B539C69…  real         nein     4937        0
 1233 │ Polygon(270 Points)   {540A0140-13E5-45EE-87A5-A3E3950…  {9F49449A-D056-4C0A-8F72-5BFA51C…  real         nein     4703        0
 1234 │ Polygon(464 Points)   {D58AD70F-17A6-46C4-95C9-291C1B5…  {02E2E46C-91A5-4DC7-B561-E1F314A…  real         nein     1426        0
 1235 │ Polygon(690 Points)   {B6E5AB42-4055-4320-A9D2-DC7681F…  {DB1AA9AB-0AD2-429B-A0D2-7F93B94…  real         nein     8253        0
 1236 │ Polygon(182 Points)   {160ACAB6-973E-461E-836F-8DF1E9B…  {DBA607B5-8611-4A1D-AF1E-02F2BB8…  real         nein     1947        5
 1237 │ Polygon(405 Points)   {3CF37677-D018-485B-8738-94C15CE…  {B9FD5BDB-8542-4B01-B728-68F449D…  real         nein     2748        0
 1238 │ Polygon(392 Points)   {B0188E90-B8BB-4AE1-B80A-58B3DA2…  {FF0A0BA5-F5B9-4817-ADAF-99F6291…  real         nein     4468        0
 1239 │ Polygon(553 Points)   {AE16E504-2185-4545-938A-AA2311A…  {7CC590A7-4BA5-40D6-8C46-4906D3C…  real         nein     8957        0
 1240 │ Polygon(1095 Points)  {E695DD7F-990D-4A4E-9440-1B6C8D4…  {24C9D7DC-DE38-4754-92F6-B175CCB…  real         nein     8608        0
 1241 │ Polygon(622 Points)   {A36CA6DE-3076-411A-BA41-991FC89…  {45C6DA0A-19B6-4482-B80B-3C03B5D…  real         nein     6234        0
 1242 │ Polygon(572 Points)   {F046021A-DBFE-4714-A315-1CD2A31…  {E680C557-2720-4EFA-AC82-12819CD…  real         nein     2354        0
 1243 │ Polygon(1639 Points)  {5AC8460B-890D-4E5A-A703-0CB1873…  {3E708B28-47DA-46D6-9059-5332F98…  real         nein     4500        0
 1244 │ Polygon(816 Points)   {5D84FC28-0731-48C9-A79D-2D26C5C…  {50043BDD-9D1A-4227-AFAF-26DD014…  real         nein     9325        0
 1245 │ Polygon(503 Points)   {F08CC970-0640-44E5-AE26-69B7074…  {5B2944B8-A7B6-4BE9-8723-60C4C34…  real         nein     3512        0
 1246 │ Polygon(353 Points)   {8B42C830-2D72-483A-A9F5-E90B370…  {C825F702-B110-466C-9A9E-96E09BF…  real         nein     7458        0
 1247 │ Polygon(555 Points)   {11F918FA-3E99-4431-BF74-8548082…  {763C6706-BEE6-496A-8551-8E06F50…  real         nein     5304        0
 1248 │ Polygon(687 Points)   {8C8E5485-BDE6-4B2C-AB3F-46CBFB5…  {5854E0A4-95EF-43E3-8732-CE68C29…  real         nein     7605        0
 1249 │ Polygon(565 Points)   {FEFB6B9F-641D-4197-8817-C92B497…  {893FE726-22DB-4C8C-B99C-F5CE182…  real         nein     6208        0
 1250 │ Polygon(616 Points)   {00369838-3FBB-4472-9881-CB0A41B…  {B55EE9E8-EAE6-4D3E-AF62-2D12BDE…  real         nein     1144        0
 1251 │ Polygon(688 Points)   {28AE257B-DC14-44A8-8424-CA2DB1B…  {DF86ED98-81AD-4A5E-93F8-3FF6A39…  real         nein     4538        0
 1252 │ Polygon(288 Points)   {4D65F333-2F52-48EA-AB6F-60AD980…  {E9C35011-DACF-4992-8EAE-5ED4320…  real         nein     2947        0
 1253 │ Polygon(788 Points)   {F6D01958-B4DC-4A58-B989-EDFC91D…  {A40C9433-48A0-4CEE-AFE5-D24A2FB…  real         nein     5015        0
 1254 │ Polygon(355 Points)   {CF555DB5-2789-41F0-AFE8-63638EC…  {B4F694CC-730B-4496-B83B-E375394…  real         nein     2747        2
 1255 │ Polygon(266 Points)   {9C88DC34-2A44-44C0-A942-8B07BF3…  {5CF9FDF1-0FF4-4362-9F72-3E155C8…  real         nein     2116        0
 1256 │ Polygon(438 Points)   {3B7A13C6-0839-4A22-ABC0-20D79B2…  {BA2C958E-0F1B-4575-BD5F-61D9A66…  real         nein     3110        0
 1257 │ Polygon(387 Points)   {FD6D5CB1-2DB3-45B6-83D4-81A5FE3…  {FA69B877-4370-48D6-B695-EC41CCB…  real         nein     8254        0
 1258 │ Polygon(535 Points)   {5FED221B-2318-43CB-97C9-24036ED…  {05CA9BBD-7C0A-4333-9883-10C74ED…  real         nein     4315        0
 1259 │ Polygon(354 Points)   {41BB3487-A083-430B-B519-ADE1DA1…  {24284165-C2EF-4924-8F8E-C75A12E…  real         nein     5742        0
 1260 │ Polygon(289 Points)   {2A0ECD7A-88A6-42A0-9030-E583B67…  {D23132BA-AF4B-47C0-8E76-5EF52F8…  real         nein     1892        2
 1261 │ Polygon(788 Points)   {7B63BF17-1207-43CC-83C1-C8C364D…  {F79217A1-8696-474B-872D-2124B53…  real         nein     9105        0
 1262 │ Polygon(557 Points)   {0E5A512E-671A-4ECF-9C72-AA3699C…  {99836387-182C-439D-9C76-F8ACDDF…  real         nein     7523        0
 1263 │ Polygon(436 Points)   {C73188D7-EBE9-4C0C-B01E-CD4C9CB…  {A234D50F-BE6E-4A34-9B6C-A9807A5…  real         nein     2103        0
 1264 │ Polygon(928 Points)   {2C1BEF18-FC3D-4ADF-B6F5-6A8C017…  {A4911606-56A4-48CC-A300-FAA85F7…  real         nein     9203        0
 1265 │ Polygon(384 Points)   {8954AEB0-814A-44AD-9D57-EC36726…  {11E4F594-93F9-4A58-BC49-CCEBC3F…  real         nein     6659        9
 1266 │ Polygon(649 Points)   {B27B5A14-BDAE-4E95-9B7A-88B2E88…  {97FE7CEF-86F6-4A88-9903-493886D…  real         nein     9548        0
 1267 │ Polygon(276 Points)   {08B15164-9A46-4F34-9FD2-FDDDBD5…  {D62F4B27-A671-43AB-8396-FA05CC9…  projektiert  nein     7082        0
 1268 │ Polygon(573 Points)   {54BEFFE4-30F5-461C-AEEF-7A08A64…  {FF3EFA77-029D-4DAA-8F14-FF6C572…  real         nein     3053        0
 1269 │ Polygon(350 Points)   {6C275DE0-BCD1-45A2-B5CA-CF79C9D…  {9DF57BB5-605C-4300-A31D-82C8DCB…  real         nein     2542        0
 1270 │ Polygon(296 Points)   {77F768FF-5075-44B7-BA71-50D73DB…  {3936F81C-EE68-4116-842C-541D355…  real         nein     4146        0
 1271 │ Polygon(274 Points)   {ECCBD7E1-5DEA-4F93-BCE8-31DD78B…  {79126BF5-2324-46F8-A7FF-23B891F…  real         nein     6657        0
 1272 │ Polygon(583 Points)   {160BF052-F4A7-40F7-A9F5-06D24C7…  {E2D7A51F-588C-401C-97DC-EE5A57C…  projektiert  nein     7416        0
 1273 │ Polygon(432 Points)   {359815F2-A2ED-4FAD-AF99-52A7D62…  {33670967-E6EA-404C-8CBF-D5BC6F2…  real         nein     7182        0
 1274 │ Polygon(649 Points)   {DC8F42D7-8A21-4EC6-9E53-84F54FA…  {24A46E11-BA7E-40ED-85CD-153386C…  real         nein     8834        0
 1275 │ Polygon(633 Points)   {8FC8F95A-298C-443A-909C-84225D2…  {64EC7EF2-4022-4D3D-9464-0DD2489…  real         nein     5612        0
 1276 │ Polygon(275 Points)   {A1C8A368-C0FB-4370-A3A6-DE1D6D2…  {EE325F30-9C37-40B1-8EA1-7C23AAC…  real         nein     6538        0
 1277 │ Polygon(386 Points)   {1FA6B6B5-7C50-485F-8E55-CBD1EC8…  {2EA788E4-6A1C-4E4E-A78A-8575D3E…  real         nein     4448        0
 1278 │ Polygon(437 Points)   {8F277F5B-1B88-4DA0-8723-6DA7CAF…  {7A1DAE5A-B106-4A74-B182-6AFEB47…  real         nein     4714        0
 1279 │ Polygon(583 Points)   {7E887957-9205-47FA-A8EF-6148477…  {55019EEE-A29B-4D26-9E4B-B208A23…  real         nein     5614        0
 1280 │ Polygon(738 Points)   {CC1EF569-EA4F-4569-AD3B-89A3D21…  {E320AA67-6125-4EAC-96D4-21384B7…  real         nein     8523        0
 1281 │ Polygon(531 Points)   {34CD3322-282E-4302-AA09-7D209A4…  {F8B31D05-670C-49C9-A84A-D20457F…  real         nein     6822        0
 1282 │ Polygon(524 Points)   {148282F3-7F1E-4137-AF9F-B9DC3E5…  {2FEF88DD-620F-4E29-82C8-201E03E…  real         nein     8413        0
 1283 │ Polygon(358 Points)   {9A6486F9-AE63-4C12-A466-C193EDA…  {9333715F-8DBA-44CB-9AC6-4A4F890…  real         nein     8218        0
 1284 │ Polygon(498 Points)   {8A1C3FAB-4E1A-4E9A-A57F-7E2BE67…  {91A8B3C4-763F-475B-B1ED-68AD3C7…  real         nein     6528        0
 1285 │ Polygon(1114 Points)  {41A7D4F6-60D7-4372-B99F-7D09396…  {A1532A89-53C1-4E5D-A9DB-3CC8091…  real         nein     5644        0
 1286 │ Polygon(193 Points)   {3E248B9C-38F8-4BA2-AE94-7FB0775…  {3F0FEF62-03DF-4647-AC9F-CE13566…  real         nein     8233        0
 1287 │ Polygon(614 Points)   {23BE0E79-BA85-4E26-AAFD-49B0E33…  {C6FB08FA-4E1B-48ED-A4F9-4210FDC…  real         nein     5425        0
 1288 │ Polygon(528 Points)   {58C6E68C-87A3-48BE-A899-403F647…  {5D0C6F0F-3815-4CA4-891A-11B675E…  real         nein     9436        0
 1289 │ Polygon(1160 Points)  {A0A45BF1-E0B5-434D-9229-46CBD15…  {A25D29B8-3429-419B-9AE7-71CB63C…  real         nein     1315        0
 1290 │ Polygon(729 Points)   {670C1356-7D05-454B-9EEB-D5FD41A…  {54C266B0-5971-4B57-B8E5-3D0A399…  real         nein     8154        0
 1291 │ Polygon(593 Points)   {AEFDD282-B60F-4035-B883-08B943C…  {0E0456EE-0B95-490A-9FA7-B16BC48…  real         nein     5026        0
 1292 │ Polygon(522 Points)   {739B5D69-6CB6-4E6B-8E8E-8F603F6…  {EAE518A4-FF65-472C-A5D5-9E85FB6…  real         nein     2745        0
 1293 │ Polygon(522 Points)   {D451E105-E4EE-4C87-A327-3B32B6F…  {30B815BD-AE5F-4FC9-8EC3-171D145…  real         nein     3536        0
 1294 │ Polygon(267 Points)   {00EF752E-83C8-4CCA-8B64-0EE635D…  {B62D5504-9216-4495-8D8A-A10D430…  real         nein     2905        0
 1295 │ Polygon(957 Points)   {E392EB76-B27C-492F-AFD2-7796D0D…  {F080785D-C6BD-4E6E-9333-AB91850…  real         nein     4147        0
 1296 │ Polygon(223 Points)   {38BE759E-BB65-4AC0-B389-E15F047…  {B035CC2C-A906-485A-AC2C-9F6EEB8…  real         nein     2610        0
 1297 │ Polygon(454 Points)   {03495A8A-C887-4575-B2AC-D9C1A38…  {57C86361-ED3A-4834-BFD9-ABCC2EF…  real         nein     1489        0
 1298 │ Polygon(330 Points)   {E5B683EA-5908-4D02-AAF0-78D495C…  {6905FAD2-0724-42F5-9169-F259483…  projektiert  nein     7106        0
 1299 │ Polygon(577 Points)   {D81059AF-223C-4570-8619-C2E6422…  {456A1560-7CE5-4F7E-978F-4648072…  real         nein     5062        0
 1300 │ Polygon(270 Points)   {2665FBF6-A790-4DEE-82E2-8CE6CEC…  {631262D0-1DED-4494-875A-8E74F2A…  real         nein     6670        0
 1301 │ Polygon(356 Points)   {954D78DC-B2F8-4DC0-9FCF-BDD3BA8…  {6E2D4452-90AE-4FDE-A365-73EB22E…  real         nein     3419        0
 1302 │ Polygon(787 Points)   {25DB1C60-E93D-490E-A974-409DF44…  {BD381091-DB49-4461-AAF8-1DE9B91…  real         nein     1660        2
 1303 │ Polygon(1132 Points)  {9E0072A3-B49D-4405-8CA1-678D7CF…  {BE377BF5-1371-42FE-BEC8-D49F49D…  real         nein     3822        0
 1304 │ Polygon(463 Points)   {29BEDD76-8434-4389-96C3-82EC018…  {2772ECCD-0713-4968-AD8E-CAA0E00…  real         nein     7433        3
 1305 │ Polygon(619 Points)   {3104A185-A76B-4160-A2CC-F4DCA97…  {EE4BDB23-62AE-4233-9E8F-656EC8C…  real         nein     9464        2
 1306 │ Polygon(631 Points)   {0809CD3E-7410-4B9A-9E24-3D17945…  {7751F9BA-6DC4-4893-B9FC-7BE34B4…  real         nein     3088        0
 1307 │ Polygon(163 Points)   {1B0D7556-FC7A-4682-8A8A-03DA13F…  {BA559337-8A5B-4B34-AD3C-9C2D85F…  real         nein     1657        0
 1308 │ Polygon(896 Points)   {CE0A39DE-695D-4F1C-A028-0B8D0B5…  {A1FA66A8-6891-4A54-A353-7E17071…  real         nein     6582        0
 1309 │ Polygon(1275 Points)  {2AEF8335-4A21-4BED-95D6-EAAFAAE…  {6B8FC079-65FB-43BB-AE64-15F7FBB…  real         nein     1862        2
 1310 │ Polygon(401 Points)   {E9856B48-F4D3-4403-A8F6-0F362CF…  {E16B3EC4-E8F4-491A-A17D-93455A8…  real         nein     6084        0
 1311 │ Polygon(438 Points)   {B6030B7A-8A0C-4C09-9969-10FAC3B…  {2AE0D68F-7A7F-4ACB-8FD3-CF37B47…  real         nein     2925        0
 1312 │ Polygon(1065 Points)  {45AE51BE-48F1-49A6-9CB9-6AB6E00…  {A8AE973B-DB19-4E74-962C-64A2359…  real         nein     6106        0
 1313 │ Polygon(644 Points)   {CBE2B1CE-827D-496F-9F76-66D4E97…  {F754470B-C243-4B56-AA71-3EDADCD…  real         nein     8835        0
 1314 │ Polygon(968 Points)   {8902489D-875D-432E-A853-4CB23F6…  {3CC884E5-210B-43C3-B49C-3DBDD55…  real         nein     3672        0
 1315 │ Polygon(1005 Points)  {D051CDEC-9765-4136-B309-FE93F5F…  {A54D62AB-83F6-4768-A67A-7D8DD5D…  real         nein     1417        0
 1316 │ Polygon(579 Points)   {44199DBD-24CA-490C-A3F4-6FC6DAE…  {75E6D2A0-268C-4A21-BC64-F8DE2F3…  real         nein     5726        0
 1317 │ Polygon(276 Points)   {E3942668-78B1-4F9F-8DCA-AE9BC9E…  {0A49352B-FAF7-4ED6-9F6E-0D6B7AD…  real         nein     7317        0
 1318 │ Polygon(552 Points)   {C5CAF4FD-1A85-47FB-AB17-F966C83…  {92CB6863-D860-4451-A58B-678EDB3…  real         nein     1867        3
 1319 │ Polygon(460 Points)   {5BEC2160-FAA2-4BA6-A255-9FD5EEE…  {750A2B90-911C-418D-9C1D-CC23519…  real         nein     4437        0
 1320 │ Polygon(789 Points)   {1613CDAF-9B90-4A82-A47D-EA80930…  {83DDB6BA-647F-4DAA-96DC-B3024B3…  real         nein     1326        0
 1321 │ Polygon(628 Points)   {089F5633-E020-4152-9250-9566DC3…  {F520A307-8DBE-4DB3-80A1-C1801E5…  real         nein     8708        0
 1322 │ Polygon(238 Points)   {2659B3E7-B91C-4911-A90C-11CEE96…  {F8B12915-9F74-4991-8A8E-7B187CE…  real         nein     9467        0
 1323 │ Polygon(849 Points)   {2422CC47-3617-400F-835A-1B81183…  {DE9674A8-0822-464F-BCC6-B0C3FAB…  real         nein     9608        0
 1324 │ Polygon(779 Points)   {78B459D5-2EB4-4F69-8285-AC4848B…  {1EFFF577-C4D5-4A3A-BF3C-33984C0…  real         nein     8726        0
 1325 │ Polygon(219 Points)   {068B97C1-79A5-42A7-841D-3A523C0…  {67BD0BA7-DD0E-424A-8A93-7EDF6ED…  real         nein     2114        0
 1326 │ Polygon(876 Points)   {1F4E9F15-C635-46F6-90DD-38F5FFD…  {B832D4E4-0B8F-4C0E-A5AB-09C18E5…  real         nein     2604        0
 1327 │ Polygon(416 Points)   {A813181A-D79A-4AF9-B990-EB23498…  {B327DEA1-A541-4DE1-9FEF-D6EFA3A…  real         nein     2732        0
 1328 │ Polygon(793 Points)   {6DBB52B3-E7F3-41A7-8855-9924C60…  {3E34CBF6-25E2-453C-B0B6-313F1DC…  real         nein     9245        0
 1329 │ Polygon(1042 Points)  {2B78EAF2-48F2-4113-B172-6F78E12…  {AA94A000-C0CE-4990-9CB3-1C1B43B…  real         nein     8352        0
 1330 │ Polygon(451 Points)   {E8435C32-B95A-46DD-A438-A7C4DCB…  {61A7D56A-1C36-41EA-AE0B-2E4EF01…  real         nein     1564        0
 1331 │ Polygon(345 Points)   {83E43F1F-37ED-4FB5-9327-108B584…  {286AD72E-DF2C-4231-9BB9-B4580F5…  real         nein     6683        2
 1332 │ Polygon(1065 Points)  {D97AB9EE-E6A3-4E62-839D-9808BDA…  {B953851E-C0EF-42A6-8B1D-9E59965…  real         nein     1082        0
 1333 │ Polygon(185 Points)   {A5EEBA39-89D8-4CA1-9DBF-2C0FD5F…  {C20A44EB-12BA-455A-9D10-9B3AF06…  real         nein     2916        0
 1334 │ Polygon(162 Points)   {373CA3C8-44D7-4507-A8FB-9DBCBCD…  {67C6E81C-B444-464F-87D3-A53CC6F…  real         nein     3722        0
 1335 │ Polygon(393 Points)   {FA157049-57C9-48FD-82C1-9DA7697…  {1125A924-4E6F-48C5-958B-55A49C4…  real         nein     2812        0
 1336 │ Polygon(149 Points)   {8ED41803-C0A3-4B11-A961-DF19B8D…  {486351CF-70E7-475D-9ED6-B88C7D4…  real         nein     1895        0
 1337 │ Polygon(758 Points)   {B708C0D8-DF5E-4527-A924-5EBB0FE…  {D3E59A42-BF8D-4B97-B4DA-714A142…  real         nein     5620        0
 1338 │ Polygon(703 Points)   {D8008B5B-EFD8-420B-9B34-569CD97…  {08CED906-A129-4550-A9FA-0C9AADC…  real         nein     6265        0
 1339 │ Polygon(746 Points)   {B04FA0F6-BFA6-4623-BE9C-FE7D2ED…  {DE5086FA-D9DC-4297-91A7-B6E7CA0…  real         nein     4658        0
 1340 │ Polygon(486 Points)   {ADE6A897-94F6-4AFB-9DB7-2861F4E…  {8AD5676E-F278-4BDF-AEC6-1D111BC…  real         nein     8212        0
 1341 │ Polygon(616 Points)   {574755CE-737A-40F7-8C99-235D049…  {BAD914A4-B64D-42B1-BF7B-B76DA46…  real         nein     8730        0
 1342 │ Polygon(696 Points)   {7720F300-DE8F-48CB-99F6-E6EBB09…  {53460A1B-AA02-4705-B189-A4A425A…  real         nein     6951       18
 1343 │ Polygon(385 Points)   {6FB22AF3-17E1-433B-9FFC-19945C0…  {FE412777-EF3D-4783-963A-CEF5C30…  real         nein     6514        0
 1344 │ Polygon(664 Points)   {17B6F2D8-754F-40F4-A823-2594B5C…  {105FCCC8-D64C-4EB5-8F48-75695F5…  real         nein     2525        0
 1345 │ Polygon(751 Points)   {417AF6A4-175B-4FE3-A193-0802E15…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9000        0
 1346 │ Polygon(409 Points)   {E1972926-775B-40EB-BB71-A4FB64F…  {B259E07F-65BD-4369-A922-33BD785…  real         nein     7324        0
 1347 │ Polygon(375 Points)   {0B00CCE5-886D-4BAB-850B-47959CF…  {C4E9F1D9-AE87-42A2-ADBE-6DFEBB3…  real         nein     4495        0
 1348 │ Polygon(548 Points)   {3D961AE1-AEDD-4C70-81BD-34665CE…  {43474EE9-159C-4E89-94AF-33373B2…  real         nein     3115        0
 1349 │ Polygon(1141 Points)  {75B85CA1-41E6-426F-B627-1649076…  {B1FABF97-2A07-4AB6-95DA-7C7C579…  real         nein     6114        0
 1350 │ Polygon(265 Points)   {6C20B504-CBA4-41FA-908A-E40EA80…  {B9A9890B-235B-4DF9-BEF9-835BC61…  real         nein     1890        1
 1351 │ Polygon(526 Points)   {59C8C02F-3551-4574-BEF7-63A1B77…  {CF80F4ED-9804-4E24-A0B2-554E3FD…  real         nein     8261        0
 1352 │ Polygon(827 Points)   {140CB619-B77A-4E3D-8FFC-AD4C424…  {81223F52-10C7-4E0A-814A-3CF7804…  real         nein     7147        0
 1353 │ Polygon(644 Points)   {A25E10FD-5AF9-429E-BB93-77763A3…  {E4F5D3BC-315C-4351-A2EF-E410FA7…  real         nein     3270        0
 1354 │ Polygon(638 Points)   {3AC25BA3-ED79-40F3-9D27-30CEC75…  {832454F5-CE18-4748-8006-F948B3C…  real         nein     8497        0
 1355 │ Polygon(1119 Points)  {4E74A932-16A5-466A-96DF-F087C7B…  {F5F77497-498B-4ECC-9432-B12433D…  real         nein     1283        1
 1356 │ Polygon(625 Points)   {F0DCD365-E9BA-44CF-9E32-BFCF379…  {BDBA3DFE-573F-4CF6-A6C6-ED5CB63…  real         nein     4104        0
 1357 │ Polygon(788 Points)   {C2E37E7D-DD6C-4156-92FD-DA9F864…  {32CBAD00-0AA2-4D43-B437-3E89BB7…  real         nein     5236        0
 1358 │ Polygon(305 Points)   {65A6267D-E003-41DF-8564-FCEB3DE…  {7BF382F2-7EE9-4A72-888F-4FCB62D…  projektiert  nein     7523        0
 1359 │ Polygon(500 Points)   {33EFC135-1335-4B85-A8ED-F912D97…  {0266B88A-F657-4E39-818A-2F512EA…  real         nein     4536        0
 1360 │ Polygon(632 Points)   {B82DCC07-8391-4FFE-8A1B-B12B0AC…  {057AB107-F2CF-4695-9196-2FBC510…  real         nein     3664        0
 1361 │ Polygon(495 Points)   {60943CC1-4902-460E-AC1F-CF99E0F…  {6C8245B9-8B6C-4E89-9C94-60E1EC0…  real         nein     2742        0
 1362 │ Polygon(1975 Points)  {734D1D2C-4620-495F-9418-CAEC942…  {947766ED-C788-4775-845D-81863D4…  real         nein     1053        0
 1363 │ Polygon(203 Points)   {970361EE-11CC-490D-A12D-66B85C4…  {96DA95FD-00A6-433E-BA9B-87BFC2E…  real         nein     3998        1
 1364 │ Polygon(2713 Points)  {B636BB6F-5840-4779-B928-AC5595F…  {C65EE13C-2277-4603-B24D-3346D60…  real         nein     2826        0
 1365 │ Polygon(605 Points)   {1D381C29-13B6-4383-820C-86ABE8F…  {79C152F0-694A-4463-B80C-D523C8F…  real         nein     8105        0
 1366 │ Polygon(803 Points)   {2610BFDE-CFC6-4FD5-9C45-0AD3F1F…  {F71E7975-DB02-4351-9D20-66E7F51…  real         nein     3322        0
 1367 │ Polygon(987 Points)   {28DAB688-738F-4D4F-837C-EE7A984…  {5D9EF367-02F0-4F7B-B42B-F35AD2C…  real         nein     4914        0
 1368 │ Polygon(257 Points)   {D435C27A-3BE0-4532-A32D-8F94FB5…  {7B85774F-B4DD-401E-B7F4-DA96E14…  real         nein     6045        0
 1369 │ Polygon(162 Points)   {F0FD11EB-05C7-4353-9A4C-C5D54FC…  {BF57BD23-A2B3-47A1-87D3-7109747…  real         nein     4417        0
 1370 │ Polygon(1062 Points)  {D39AB960-B356-4EDB-85BA-28D3ECD…  {D95FF0D3-7064-4C09-A751-1E2F204…  real         nein     8558        0
 1371 │ Polygon(390 Points)   {053C3D78-66D1-4FAE-886B-D155EAF…  {3232ABAF-CC49-4A0F-9559-D60E41C…  real         nein     2536        0
 1372 │ Polygon(730 Points)   {A60C8D7B-C160-4723-AFF8-26A4CED…  {FD5D515B-23DF-4DE8-9A79-0D992DC…  real         nein     3067        0
 1373 │ Polygon(666 Points)   {D83500EE-8F07-4ADC-85CE-8B64F6F…  {0FA67A62-DE87-4EBB-884A-A082AAC…  real         nein     3422        0
 1374 │ Polygon(212 Points)   {9DBA9C2B-DF4B-4A41-9BAA-DFFE560…  {408621E7-9361-4424-A247-FAFCDF4…  real         nein     3034        0
 1375 │ Polygon(1332 Points)  {4177A398-F653-46AC-AE35-B3A905E…  {BD83BF4F-A26E-49FF-BEC3-96717B8…  real         nein     8134        0
 1376 │ Polygon(1441 Points)  {C81B9F3F-ACC0-4722-9E12-41EECD3…  {508C8E2E-9DF0-48E9-8B58-0CF785F…  real         nein     8418        0
 1377 │ Polygon(649 Points)   {46A7418D-77A8-4F5E-8FDB-BCD0C6B…  {4810B12D-0A9F-4DFC-A379-622E569…  real         nein     6027        0
 1378 │ Polygon(690 Points)   {F2314D33-679C-4189-870B-7DE3D83…  {9ABB7EDB-07AA-4A27-A049-2273BC6…  real         nein     2828        0
 1379 │ Polygon(741 Points)   {C5A0D81B-3F33-40FA-BC1D-922F104…  {B250BA49-A617-4961-9862-4416F6C…  real         nein     3088        2
 1380 │ Polygon(581 Points)   {D0D82731-84EB-4485-892C-2557309…  {579E01AC-8C28-407B-AEA5-D2FF3DB…  real         nein     6145        0
 1381 │ Polygon(138 Points)   {52435005-4578-4F6A-BAF7-925C309…  {6A5F953E-36D9-4F6A-A50D-6A52C27…  real         nein     6317        0
 1382 │ Polygon(313 Points)   {6DBF9A5F-61F7-43FE-B41B-03D7B6D…  {2DF75DB4-8B88-418D-920B-0361C07…  real         nein     8750        0
 1383 │ Polygon(185 Points)   {4ADB20D1-4434-47F5-95A5-16D2B82…  {C54E7F89-5364-4C39-B192-71D3E22…  real         nein     6631        0
 1384 │ Polygon(654 Points)   {0BB36824-A8AF-4350-80D4-D612C05…  {44999A1E-E489-4BC6-854B-FC78D87…  real         nein     8272        0
 1385 │ Polygon(499 Points)   {629937C5-1275-4E3A-9DC2-AAF72B4…  {28813C6D-7F3F-4E9B-8763-6B575D8…  real         nein     2886        0
 1386 │ Polygon(234 Points)   {EFAA2C84-6005-4E0D-BB32-B5B7BA0…  {9D8BD5DE-97AA-47EA-B88A-A9A50FD…  real         nein     6365        0
 1387 │ Polygon(491 Points)   {5502479D-F6DD-4871-8249-662ED52…  {DDFB4603-1A90-413F-8250-32A6166…  real         nein     5276        0
 1388 │ Polygon(435 Points)   {78DC3DAA-3A96-425B-A7C0-655C5A8…  {8A1F8080-5A85-4874-AFA0-F9AC889…  real         nein     7138        0
 1389 │ Polygon(303 Points)   {886B297A-D8A7-403A-BF0C-0C64076…  {F482FD97-90A3-4312-B60E-81588C4…  real         nein     3282        0
 1390 │ Polygon(647 Points)   {1770F113-C204-44A6-9452-F762577…  {7DF5ED8C-1AAB-44F8-966F-7C76B14…  real         nein     2823        0
 1391 │ Polygon(336 Points)   {A36FD5EB-AE55-438F-9C89-0F5857A…  {52A7FB46-8633-420A-AE09-57D5239…  real         nein     7153        0
 1392 │ Polygon(450 Points)   {01C0D59D-09A4-4739-8061-EAE51C0…  {98014F35-AE37-41A8-BC5F-623E548…  real         nein     8479        0
 1393 │ Polygon(750 Points)   {FB241751-4A1A-475F-8BA9-9AED87F…  {4B205653-27E7-4B65-BE0C-590C9FB…  real         nein     8185        0
 1394 │ Polygon(360 Points)   {38BE4EE2-3AEF-4023-B229-0E637A3…  {CAAF5C26-4CAD-4D18-9437-2EF53F6…  real         nein     8713        0
 1395 │ Polygon(490 Points)   {160D9EB1-80E5-4E38-923D-04ED6F2…  {4071B1C4-341F-471C-A132-F0833F8…  real         nein     1723        0
 1396 │ Polygon(189 Points)   {921C54ED-CF3C-471E-983B-15E9571…  {3E1FC2FD-DA62-4FF3-BC42-6357EAD…  real         nein     1906        0
 1397 │ Polygon(245 Points)   {796E76AA-87EE-41D1-97E3-83A89FF…  {B754164B-0FB9-4D73-88E5-6837DB7…  real         nein     3856        0
 1398 │ Polygon(1014 Points)  {2BA85AB9-AA79-42A4-8889-576E09C…  {B3E033E1-8DDB-42F9-8C16-F9A8566…  real         nein     8617        0
 1399 │ Polygon(587 Points)   {20395681-40B5-4A52-A68A-2AA0156…  {FCECD764-62B1-416A-8E36-2FA4EC1…  real         nein     3089        0
 1400 │ Polygon(1234 Points)  {CED0DA65-2A91-4041-9781-34CE557…  {930D7E20-A946-4C93-9CA4-1C48499…  real         nein     1896        0
 1401 │ Polygon(331 Points)   {AC5D288A-545C-4C2F-8EDB-FBC6DE4…  {BB3272EF-075F-45BD-9903-912FBB8…  real         nein     3951        0
 1402 │ Polygon(523 Points)   {AA865FA8-BDAD-4D81-B1AF-579F058…  {E0500D14-7849-4F3E-99EA-2FCC6DA…  real         nein     2714        0
 1403 │ Polygon(602 Points)   {581561E4-94B1-4D8C-8133-1768AAA…  {3C54EA28-7482-4C4C-A187-793AF06…  real         nein     1678        0
 1404 │ Polygon(555 Points)   {6E387DE4-3142-4E18-B14E-14824D8…  {CBD7AD81-F8C6-4B98-A607-82A4D31…  real         nein     6503        0
 1405 │ Polygon(940 Points)   {0964145A-B22D-4B36-A330-67839F2…  {221F4D56-35AC-4E51-9FE7-A91C558…  real         nein     1176        0
 1406 │ Polygon(576 Points)   {7372D9C5-FB18-4639-8A56-41EF75B…  {6D2B603C-01B3-4449-ACDB-DDD023F…  real         nein     5053        0
 1407 │ Polygon(769 Points)   {3F061612-BBEE-40C8-B57C-DF8F979…  {8E17CE81-7A96-4DFD-8F88-CB8FF12…  real         nein     1321        0
 1408 │ Polygon(795 Points)   {D90780BB-1949-46B0-93DE-46A9BD5…  {74933ECB-D087-4D70-9487-3FC8E95…  real         nein     8902        0
 1409 │ Polygon(497 Points)   {B2D6B557-96B4-45C2-9F84-A8BFD84…  {B43AE876-4140-4F81-861E-3126AF4…  real         nein     3474        0
 1410 │ Polygon(745 Points)   {DA94BE2A-A13D-4525-8C85-F008A91…  {A7AB4894-8EFE-4F7F-A769-A853F00…  real         nein     3617        0
 1411 │ Polygon(594 Points)   {9AE45016-F542-4FB8-8178-0BCBD71…  {00A24E2E-B42A-4DC1-9F8E-0615E28…  real         nein     7423        0
 1412 │ Polygon(724 Points)   {4BA9013F-0B86-43DF-89B5-BD4F81A…  {BD544EEF-D5AC-45A9-9D8B-86F1389…  real         nein     1196        0
 1413 │ Polygon(728 Points)   {B18AD8A0-3806-4980-8F77-A953095…  {5AB59FE0-8C2A-4697-A70E-FBD3853…  real         nein     7026        0
 1414 │ Polygon(338 Points)   {672A01AD-A708-474E-AC84-B831098…  {597B35A3-7AD7-4C6B-B871-AA054A7…  real         nein     2873        0
 1415 │ Polygon(244 Points)   {C904DF49-C454-4A66-8C4F-7A0E29B…  {C46D1732-D8DE-426F-9C97-AE30952…  projektiert  nein     7303        0
 1416 │ Polygon(179 Points)   {7DC1A849-7C18-45F4-AF05-1A73507…  {79E5DCE1-9AEF-480C-BF86-9CFB9F7…  projektiert  nein     7404        0
 1417 │ Polygon(863 Points)   {0D244139-FD0B-46E5-BEB5-F8904F2…  {05D7AB01-10FE-47EA-AFB4-2CAD2F4…  real         nein     8472        0
 1418 │ Polygon(520 Points)   {8A9F59A2-7CDD-4543-B775-F083D45…  {A97700F4-19CD-4B1C-A721-B80B4E1…  real         nein     3416        0
 1419 │ Polygon(491 Points)   {6ED6651B-2580-49DA-9402-D7B37D2…  {EC3AEBE0-818B-465B-BA6C-B008FFB…  real         nein     4227        0
 1420 │ Polygon(368 Points)   {29FCC2AB-E588-4189-84DE-AD1872E…  {C37AB3A0-EFA5-40AC-B741-6D1CC6B…  real         nein     6806        0
 1421 │ Polygon(818 Points)   {69E49FCA-2425-480A-8EC9-7436283…  {D5ADAF26-AF12-4FB7-AC42-022AB1D…  real         nein     8912        0
 1422 │ Polygon(244 Points)   {C5559DDB-FED6-4B71-B8F3-D1CA47D…  {9CDB1601-5977-4591-A69F-4194324…  real         nein     2027        2
 1423 │ Polygon(821 Points)   {DF892D6D-6F16-4A1C-A775-F4FC2AA…  {03290660-0C1E-4E64-A0FF-1AD781C…  real         nein     8910        0
 1424 │ Polygon(1019 Points)  {B48C1A7E-758D-44A3-89D3-627CD96…  {3C4DC007-89BE-4D71-A8B9-85CF32E…  real         nein     9410        0
 1425 │ Polygon(223 Points)   {664C7562-EB3F-43F4-B5A9-FC95827…  {845B2D1C-B386-4C6C-BC8C-C6C05A7…  real         nein     3934        0
 1426 │ Polygon(109 Points)   {B0C1B35E-3A40-4AAA-A443-77A0B23…  {C89F7279-383D-493E-9D7E-C135662…  real         nein     1450        2
 1427 │ Polygon(814 Points)   {EB2CE138-4AC3-4F45-AEEF-1D988A4…  {46E31B57-F453-4EBC-8EC9-A5EE6C7…  real         nein     9042        0
 1428 │ Polygon(660 Points)   {950FF9E9-7B58-4F3C-93B5-52F8DAD…  {6E4ED426-ADA1-47C0-9E9D-FF9FCD6…  real         nein     4106        0
 1429 │ Polygon(382 Points)   {739EC92C-8100-4EB6-B678-256D25C…  {75807A1C-6539-41B7-8395-011714D…  real         nein     1716        0
 1430 │ Polygon(140 Points)   {A4A415A5-1DF3-4984-BDFD-5E6F0F6…  {E39EE13C-27BF-4DEC-B5D5-AE3AE19…  real         nein     9476        0
 1431 │ Polygon(638 Points)   {ECDA0645-E5FE-48BE-97B7-A74189F…  {FABD999C-D838-4F3C-9A59-0644CF0…  real         nein     1689        0
 1432 │ Polygon(133 Points)   {91AB2C65-04EB-486E-95C0-ADB5669…  {688BDB2A-3BD3-4665-9B2B-8E4153B…  real         nein     2608        0
 1433 │ Polygon(425 Points)   {31411194-FD36-4BA0-B13D-57D7020…  {16B7AD54-0FCA-4C0F-9B39-36556B9…  real         nein     3940        0
 1434 │ Polygon(243 Points)   {FC596A54-4619-43B3-9D63-709BADB…  {05826668-A5CA-4089-BA27-1FD4E2F…  real         nein     4718        0
 1435 │ Polygon(502 Points)   {75985CBA-733A-4E3D-99E9-44E6CB2…  {5EBD4A33-27DB-4EAE-BDE7-58FC756…  real         nein     6524        0
 1436 │ Polygon(675 Points)   {D0933DDA-59EC-4756-9E06-6BBB7AF…  {4E39692F-60CB-4B45-A001-EFCB61E…  real         nein     1611        0
 1437 │ Polygon(497 Points)   {3E6CCB0F-809A-4B98-B353-36CAE3D…  {7291CDA2-F12A-48AB-8B3E-2047C8C…  real         nein     3857        0
 1438 │ Polygon(448 Points)   {3F162CCD-312A-4B7C-AAF2-36BF769…  {B883F69C-872E-458F-9E7C-A56EF2E…  real         nein     3303        0
 1439 │ Polygon(273 Points)   {E4A141B6-E753-45CD-AE4E-B6C2CAA…  {F8A977E7-8A69-4E89-9C18-56D2BE6…  real         nein     2043        0
 1440 │ Polygon(245 Points)   {104F313B-8087-4080-B735-F4C9DFD…  {9AD90D51-BCC1-4E37-894C-310BA91…  real         nein     6525        0
 1441 │ Polygon(829 Points)   {196CBA86-702D-4D8C-8B81-E627D0B…  {6C5841A0-85E7-4075-876B-9F982A4…  real         nein     2822        0
 1442 │ Polygon(230 Points)   {7F1F8D5F-8BD6-40C9-B221-37F31B2…  {92FE024B-6177-40CA-BACD-0F3FA8C…  real         nein     3655        0
 1443 │ Polygon(407 Points)   {0F516DCF-87CB-43C9-8699-84A7CB5…  {C356B5EF-2F76-4D48-BB2B-E1ED79D…  projektiert  nein     7407        0
 1444 │ Polygon(474 Points)   {2D39C6C0-85B7-48BE-916A-1B4B659…  {314F4FFC-4D2E-4A3D-82F5-524B401…  real         nein     1632        0
 1445 │ Polygon(274 Points)   {FF2DFB9F-353E-40B3-88C7-2A78769…  {6DBEEC28-DD80-4747-BB51-805E610…  real         nein     9602        0
 1446 │ Polygon(449 Points)   {0EA82422-6B4C-43BD-B9B1-09FD0FD…  {1BAE8C7F-4228-4DEB-8F3C-A7BDC30…  real         nein     1616        0
 1447 │ Polygon(640 Points)   {30941886-3AF2-45C1-A993-B5C7FE6…  {371C6AEF-0C10-44BE-B3E9-DC8FF6C…  real         nein     8906        0
 1448 │ Polygon(460 Points)   {158EA10F-6CF3-439B-9B9A-B18EB9F…  {C6073587-1C77-4650-8619-5E262BB…  real         nein     5607        0
 1449 │ Polygon(656 Points)   {BFEE14CF-9604-43DA-A614-DEF71C3…  {E07FE781-F86A-418B-B221-931121B…  real         nein     7144        0
 1450 │ Polygon(1031 Points)  {2E3C8A45-DB72-46B3-97FC-590F068…  {4EF460A3-4D67-4E57-944A-75EB736…  real         nein     8308        0
 1451 │ Polygon(362 Points)   {443D80D8-C68E-405E-A381-47039D8…  {5BE231D2-F07D-45F4-AE21-D450378…  real         nein     2543        0
 1452 │ Polygon(586 Points)   {D57C5D9D-4644-4C01-A12B-E7A5993…  {96F90869-0A7B-4F11-B5C7-0C1A26B…  real         nein     5413        0
 1453 │ Polygon(173 Points)   {741A29A9-0028-40E6-AC30-5DD95C0…  {72B78AC0-5BC6-45B0-A59B-A89968E…  real         nein     1961        0
 1454 │ Polygon(538 Points)   {92761B35-4D60-4E25-938B-E9102EF…  {9BBB9D12-5A64-4BEC-9F04-58220DD…  real         nein     3707        0
 1455 │ Polygon(234 Points)   {3A8F77C4-54F6-4BB4-BD04-A4401F0…  {320E4F49-54DC-4C8E-AB95-9F7D885…  real         nein     1667        0
 1456 │ Polygon(374 Points)   {D2E0C4D9-6558-4E4F-A852-377E515…  {EAEF9A6F-CBD7-4BA9-85C2-155D8DA…  real         nein     4813        0
 1457 │ Polygon(513 Points)   {BC130BF1-3B91-4501-8505-37D1F98…  {0A420F58-62D3-46F1-B67E-A51D197…  real         nein     3983        3
 1458 │ Polygon(148 Points)   {BBE391E7-B659-45E0-838E-B69FF9F…  {9D0910B8-C3A0-46B1-882A-08C025B…  real         nein     8881        6
 1459 │ Polygon(527 Points)   {1728CFA4-54E1-4EB3-AEAC-BE49E4D…  {CD56FDA2-754D-4A73-B0AB-E7D91C1…  real         nein     6345        0
 1460 │ Polygon(369 Points)   {C025FCDE-F1B5-4BF0-AD45-19CD394…  {3EF3C18E-8C87-4D6E-8F56-34E7684…  real         nein     2735        3
 1461 │ Polygon(1456 Points)  {8713425E-2FBD-444B-A07B-6604A3D…  {396C27D5-FD1D-4A8C-BAD9-05FDFEA…  real         nein     1044        0
 1462 │ Polygon(353 Points)   {5D3CE09D-C59F-43FD-9B2E-6BE6570…  {C41864CA-B14A-41F3-BCA7-0B22866…  real         nein     4543        0
 1463 │ Polygon(732 Points)   {A1502B70-0A69-4A67-A81A-FA8721C…  {D44D2A84-55A3-4EB7-A495-116939E…  real         nein     9038        0
 1464 │ Polygon(142 Points)   {09CE2354-0A4B-45DB-B299-A4F5295…  {0EFC8AE7-83D5-4F9B-98FB-23D3D94…  real         nein     4207        0
 1465 │ Polygon(311 Points)   {4E0FF3DB-2878-49BB-BD6E-4922B58…  {C4A630C6-1782-4DEA-A7E1-3487119…  real         nein     3658        0
 1466 │ Polygon(288 Points)   {8AC2CE3E-234F-4876-992D-DB93EF4…  {347E4A22-2D6E-4A27-86A2-FD291BE…  real         nein     8524        0
 1467 │ Polygon(363 Points)   {F6852E7A-926B-45AC-804E-CBBA3DD…  {FA8EDB7F-CC01-40AD-B76E-B9047AA…  real         nein     6760        5
 1468 │ Polygon(643 Points)   {5A95CA9E-A87B-4BAD-B041-829B549…  {1A6B2D23-B267-4F24-B76E-42E3C61…  real         nein     7104        0
 1469 │ Polygon(688 Points)   {0522F048-E625-4D3A-A1A8-F3783B8…  {516E03C5-E00A-45B9-9DEA-98FB7E0…  real         nein     1182        0
 1470 │ Polygon(368 Points)   {D9880776-64DC-46E2-947B-8F89D06…  {8B39AF8E-51FE-4DDC-8AAB-0D2CC5E…  real         nein     3634        0
 1471 │ Polygon(585 Points)   {AF3A27E5-2CFB-47DC-BAD2-19FE30D…  {2BD2B4AC-068D-4C3B-B877-C46C133…  real         nein     1422        0
 1472 │ Polygon(100 Points)   {40497E39-379E-4960-BCC0-E13199F…  {87B0A3BF-B14B-4AA2-AF68-92BE542…  real         nein     3914        0
 1473 │ Polygon(486 Points)   {C4E690E4-D4A6-493C-882C-DFACBB4…  {DA9BA7D5-0643-44DB-9BA7-426C111…  real         nein     8733        0
 1474 │ Polygon(502 Points)   {192B9D36-F5D0-4CC5-933E-1823193…  {892CD807-12E7-4500-BFFD-B9882B1…  real         nein     6235        0
 1475 │ Polygon(628 Points)   {5B705FCE-6AD7-469F-B683-DA19DB9…  {7913BFC3-B877-46DB-B09E-049BA66…  real         nein     8825        0
 1476 │ Polygon(617 Points)   {B06CD6CC-43D9-4E88-81C5-7B41E53…  {5BF30DFE-F438-4F62-9CCB-EF08AE9…  real         nein     5420        0
 1477 │ Polygon(604 Points)   {3BE5B899-4C73-4655-B197-B0AE6F6…  {25F32213-0D39-4DC1-BEEC-12B793F…  real         nein     6062        0
 1478 │ Polygon(347 Points)   {E6A93922-A94D-4B6D-BEC1-B496602…  {EDB06EB0-D18E-41E7-8B06-3F20E88…  real         nein     6866        0
 1479 │ Polygon(804 Points)   {24A8BBA6-E922-46DB-A99B-2669EB8…  {C1FA1BC2-A11C-4FCF-8746-2BED7B7…  real         nein     4228        0
 1480 │ Polygon(526 Points)   {64CD24AD-1BDB-4A5A-BF51-E8D49EB…  {79487D39-16FC-46A0-A8DE-DE3D48F…  real         nein     5643        0
 1481 │ Polygon(673 Points)   {2E4310AD-48F8-4589-978D-D7EB483…  {AB2CA404-999C-421C-B2A5-3B5EFBA…  real         nein     5075        0
 1482 │ Polygon(282 Points)   {0677C2F2-638E-4554-9B2F-14C40ED…  {13EC9CAC-89F3-4C87-92C2-E71CC3F…  real         nein     6760        1
 1483 │ Polygon(225 Points)   {1AEC5121-F629-4227-810F-0AC34F2…  {DE125053-F989-46CC-AB4B-8C21F40…  real         nein     6476        0
 1484 │ Polygon(751 Points)   {6978BFC2-E77B-4B5A-BA97-8599B98…  {16425D67-E2ED-49E4-96AF-B6EFF17…  real         nein     1000       25
 1485 │ Polygon(169 Points)   {2A71259B-DF82-429D-99D7-0B7C019…  {AA493DD3-575C-45FA-B26E-309B2CD…  real         nein     6466        0
 1486 │ Polygon(361 Points)   {E2D65C8B-1117-44E0-80D4-3A76C6C…  {F2EFC839-473C-4CC7-A3D3-79BCA6E…  real         nein     1376        0
 1487 │ Polygon(337 Points)   {27588609-436B-4507-AD4E-F720CFB…  {2458E8DD-25F2-4F60-9400-ED00D79…  real         nein     7472        0
 1488 │ Polygon(816 Points)   {418484D2-FA87-4A54-B0E7-310C2BB…  {D59E8662-C577-485E-B709-975842E…  real         nein     8476        0
 1489 │ Polygon(749 Points)   {6536457C-3216-4D14-BBDE-9EB3FC4…  {7DF7AC2D-C81A-4BA0-BB3A-A886025…  real         nein     2856        0
 1490 │ Polygon(572 Points)   {DC692FBE-16B1-4262-895B-BC83B82…  {AA905E20-50F4-4DB6-AB22-646149D…  real         nein     3510        0
 1491 │ Polygon(445 Points)   {7C0B5D8D-D473-4339-ADA7-733F511…  {8438A61F-C8BD-45B0-8FB3-F3E4A29…  real         nein     6313        3
 1492 │ Polygon(327 Points)   {D7330BE2-EF9D-4385-86F2-B453267…  {B3339981-F1C2-4A13-9108-845FC3E…  real         nein     2712        0
 1493 │ Polygon(720 Points)   {9C5EE656-1E9F-4A46-BB26-77F2A68…  {6242A917-97EB-4A2A-B84C-EF2043A…  real         nein     5044        0
 1494 │ Polygon(577 Points)   {B5FC6D87-C532-45D4-88E1-309DA94…  {71BFB677-B034-4C63-97A2-4E63D71…  real         nein     1260        0
 1495 │ Polygon(395 Points)   {BEE5797F-8920-49CD-B26E-7B53D58…  {758D68DE-F2BE-4AAF-B3B8-073BAAD…  real         nein     6263        0
 1496 │ Polygon(487 Points)   {24331C7E-D757-4DE8-BF18-6ED2D1E…  {7857D2FB-6278-4918-80E5-53FD3EE…  real         nein     6874        0
 1497 │ Polygon(425 Points)   {C2C9E59C-08C9-4582-A20A-041CF4B…  {2C8EC340-6846-4597-AECB-E835C69…  real         nein     1663        4
 1498 │ Polygon(545 Points)   {5AB43F18-E989-44B5-9DB0-38C3844…  {CD3690DF-839C-4F08-91F4-61A9B3B…  real         nein     5316        0
 1499 │ Polygon(1294 Points)  {C9BA0A09-BEFB-419A-BEB3-9854B45…  {23834AAE-A7E1-4A85-AF6F-E080556…  real         nein     8625        0
 1500 │ Polygon(414 Points)   {68C43454-CB66-44EA-803D-9B59E3B…  {FE24DB9F-BDE0-4F60-859F-E6C00CE…  real         nein     4204        0
 1501 │ Polygon(231 Points)   {C83DEFA8-A86F-4D4B-97EF-E3C5592…  {E660F73C-66AF-480C-A6E5-32A723D…  real         nein     7126        0
 1502 │ Polygon(199 Points)   {0E6FBAF9-262A-4863-872D-5DD8849…  {0AEC8894-1BA3-4EEC-BA21-87043DB…  real         nein     4426        0
 1503 │ Polygon(639 Points)   {EDD8BA89-4ECF-4B18-80AF-FA55543…  {A81D9A48-2478-4550-B5D6-4497133…  real         nein     8255        0
 1504 │ Polygon(315 Points)   {A127782F-CB58-47DC-A23D-0E9509A…  {62F2A024-A96B-4AC2-AA01-D3E5BB8…  real         nein     4253        0
 1505 │ Polygon(495 Points)   {84ACD670-745F-40A5-803A-7E1D042…  {1C515D8A-36CC-4EBA-B4FC-F8A677F…  real         nein     6231        0
 1506 │ Polygon(525 Points)   {4CC86356-9FA4-42AE-9D61-9631A64…  {E04528CF-A89F-40CA-BA8C-3B37605…  real         nein     3452        0
 1507 │ Polygon(834 Points)   {7B0B58CE-84D6-4230-9F90-0F592E5…  {F9BF4F10-7F59-44A6-85BC-2F2D51E…  real         nein     6162        0
 1508 │ Polygon(525 Points)   {83C89EB8-DA03-4950-9BC0-BC17DCA…  {AE612190-0AB3-43AD-AC0F-D4C62A1…  real         nein     2747        0
 1509 │ Polygon(300 Points)   {15DD0F40-4C0B-4A72-8345-D07EE65…  {522C07CC-9941-4E1A-802F-04AC8E6…  real         nein     3253        0
 1510 │ Polygon(409 Points)   {20B52A02-C11C-4DEF-911A-A609408…  {E4D7171F-B19E-497C-9F46-2A8892D…  real         nein     2513        0
 1511 │ Polygon(578 Points)   {FB01DB0F-AF06-4591-93F0-52AA48F…  {991D028E-BF19-4BA3-B1BB-AF826C6…  real         nein     8307        0
 1512 │ Polygon(941 Points)   {D7900B3C-81A2-4EEF-B85E-11152B5…  {B940449F-164D-4789-BF7D-45889AB…  real         nein     4632        0
 1513 │ Polygon(408 Points)   {3973E58A-DD2F-47D6-AD70-60762A8…  {318FC93F-82F5-43B8-9ED0-1266E4B…  real         nein     5036        0
 1514 │ Polygon(591 Points)   {8F9D248C-8F4E-4210-95C7-B7F7282…  {AEA565D7-1948-45F4-9976-2204D64…  real         nein     4537        0
 1515 │ Polygon(351 Points)   {94FBD46F-0493-4986-B599-7C17696…  {8E0369CC-9692-4BB6-ADEB-2DE5E5A…  real         nein     8214        0
 1516 │ Polygon(834 Points)   {4AB9A503-BB17-4679-9280-7B64286…  {7DB83043-8731-4DBD-A5C8-ECB2221…  real         nein     8112        0
 1517 │ Polygon(833 Points)   {35ADB6A3-E045-4B18-B532-C49378C…  {2208ABB4-14B9-4C8D-BD0D-AE5555A…  real         nein     9125        0
 1518 │ Polygon(684 Points)   {9EF1CCE9-CAFA-4F4B-9517-60BEE87…  {79844A12-8B28-4EBE-A585-BA8444B…  real         nein     6716        2
 1519 │ Polygon(424 Points)   {6695A27A-486F-46DD-8D95-1F97B22…  {529F5E10-E11C-480C-A6F4-0D63022…  real         nein     4153        0
 1520 │ Polygon(490 Points)   {FC814082-98F0-4B99-92F8-61FBA98…  {8B933E5E-B710-411F-8987-E088362…  real         nein     6467        0
 1521 │ Polygon(340 Points)   {29FA5073-ABE9-4452-B5B0-1329133…  {59FBF489-6B6A-44BB-B431-8BA7059…  real         nein     4494        0
 1522 │ Polygon(974 Points)   {EB8703E4-EE3C-48DD-B24C-69F85A7…  {73C75AF7-2593-4A01-B497-A8F017C…  real         nein     9404        0
 1523 │ Polygon(268 Points)   {707AAC43-5660-4221-83ED-8386471…  {6B4EA73A-F7D2-4601-9C67-8354220…  real         nein     6773        0
 1524 │ Polygon(701 Points)   {EF4B8DF9-CD65-467E-895C-9973935…  {CD104EFA-3EA9-49C2-A1B4-8EBB780…  real         nein     3476        0
 1525 │ Polygon(759 Points)   {96746D92-B77C-446D-9FAC-6188AA6…  {BACB1D02-31D6-4D2E-9B19-62F97BF…  real         nein     8777        0
 1526 │ Polygon(523 Points)   {F051D092-FE14-4210-BECA-F07E9C0…  {105D8C7A-2B0E-4AA0-9196-DCE470D…  real         nein     5074        0
 1527 │ Polygon(142 Points)   {E049F0BD-EB5C-4DF2-9F23-552FD41…  {6683E66B-4B62-4628-89D8-AB326C8…  real         nein     4223        0
 1528 │ Polygon(354 Points)   {5CD4DAD9-1657-4D8B-B5FC-D89A847…  {A421EE6D-4B23-4FBF-AC95-6D5FAE5…  real         nein     7452        0
 1529 │ Polygon(424 Points)   {413DA2C0-FF45-4992-8A40-27B1EF8…  {FDEA2903-2849-436E-B905-32C9DFC…  real         nein     6024        0
 1530 │ Polygon(412 Points)   {E06BCC44-D2BA-4B4B-8A69-661A1BE…  {FA8350C7-08EF-40EE-818E-05F1B1E…  real         nein     4317        0
 1531 │ Polygon(386 Points)   {05364C5E-6559-469F-A7E8-47D88C3…  {9187786D-0BC7-4C1C-A233-557F899…  real         nein     1908        0
 1532 │ Polygon(278 Points)   {EDB35F48-1477-48EE-AF0D-4BADCB1…  {7314B9FD-DBD2-438D-A4AE-BEEE860…  real         nein     4623        0
 1533 │ Polygon(487 Points)   {D7295447-44CB-447A-970E-2B8C49D…  {6D604C3F-19C1-4580-88A2-6D9F669…  real         nein     5306        0
 1534 │ Polygon(522 Points)   {87B7CD2F-A77D-4A5D-8CA4-DABD388…  {D2D9398D-3439-4D78-883E-03470AC…  real         nein     3251        0
 1535 │ Polygon(1476 Points)  {FB8E544B-7EE4-4BBF-9AAB-69C3E1B…  {3A92063F-537B-4B2B-B5FB-9000A92…  real         nein     1040        2
 1536 │ Polygon(828 Points)   {4A85F90D-684D-4E4C-B585-7C28EA5…  {4CBBB25E-91B1-4D29-822A-9DDCED6…  real         nein     9033        0
 1537 │ Polygon(676 Points)   {EECF47DC-9F05-47EF-9E9F-5578C0B…  {3FB3C607-06C6-4727-9D78-717BDAB…  real         nein     1757        0
 1538 │ Polygon(626 Points)   {B90491A0-4B51-43FE-B19D-2352BEE…  {23B63673-0865-4C45-B019-D421228…  real         nein     1055        0
 1539 │ Polygon(461 Points)   {4523703E-75E3-401D-BDFD-70CA667…  {7C361C17-25B8-441F-9C24-4E242D4…  real         nein     6044        0
 1540 │ Polygon(583 Points)   {59FDF731-E756-49AB-A8F6-56EF2B3…  {CC30AAC0-3B45-49D0-92BA-ED171DE…  real         nein     1864        0
 1541 │ Polygon(647 Points)   {5AF978FB-710E-4E09-8DB3-99800F1…  {FC4832EA-A43F-46A9-BE25-8F2045B…  real         nein     9552        0
 1542 │ Polygon(1130 Points)  {5F188A91-AE46-4EED-858E-6F6B016…  {2E239337-5789-4845-B5A0-9C4D73C…  real         nein     8474        0
 1543 │ Polygon(444 Points)   {9702D8F4-EC0E-47E1-ACB4-946E2A3…  {10D24CF1-FF71-42E0-89EB-71E1135…  real         nein     5417        0
 1544 │ Polygon(394 Points)   {CD39DD8E-E156-441F-B12F-8FECDAA…  {9648686A-0128-447F-80AE-39FC0E6…  real         nein     7608        0
 1545 │ Polygon(627 Points)   {00794799-95F0-437B-BA96-3AE0D17…  {9E17E86D-8C92-402B-83FB-D6062B5…  real         nein     9122        2
 1546 │ Polygon(261 Points)   {A2D16E09-EC37-4B39-A80F-E49BE37…  {769B03E6-A81D-4C1E-8A7A-F16C9C8…  real         nein     3855       41
 1547 │ Polygon(449 Points)   {331A7444-D0B8-4F79-A973-C983C87…  {3228EEBD-6224-4B3E-8D49-2F3DDF3…  real         nein     1342        0
 1548 │ Polygon(873 Points)   {E0F37FC9-D5AE-4C43-9EA3-32D8974…  {532E217A-0573-499A-AC4B-81A5211…  real         nein     6163        0
 1549 │ Polygon(196 Points)   {E30D231F-DC25-49C9-97B6-38B2FDA…  {6CD92A5C-5FEC-4CC0-9EC5-C454A5B…  real         nein     1867        2
 1550 │ Polygon(510 Points)   {2E8F5140-3A0A-42A1-900C-B4521BB…  {603DF2B2-E2FC-4790-86DA-6ECF430…  real         nein     4325        0
 1551 │ Polygon(899 Points)   {0CC21D51-E293-40D1-8110-D148680…  {62AB5C58-29CB-42A8-A549-6676D7A…  real         nein     8307        2
 1552 │ Polygon(383 Points)   {D9CD70D9-5263-4825-AFDB-EE1BB7F…  {1545635F-F355-47E1-9A3B-A2E1D20…  real         nein     1523        0
 1553 │ Polygon(438 Points)   {1F97FEAD-234A-4CC9-AFE6-9EEF1A7…  {F5E7911D-7E27-4631-BC5A-D82A280…  real         nein     8588        0
 1554 │ Polygon(661 Points)   {5E461C49-66E6-45C5-A753-2B68B6D…  {868FA895-7104-43D9-88ED-D9E8443…  real         nein     1625        0
 1555 │ Polygon(410 Points)   {6CB3C944-D626-4409-A18B-5F9C60E…  {635391C0-AD98-4229-AF93-CE73958…  real         nein     5037        0
 1556 │ Polygon(1094 Points)  {BB73F7BF-DD7A-44FE-9EB2-58DC4C5…  {2AA665FE-B73D-415E-B2B5-7E3BC09…  real         nein     1268        2
 1557 │ Polygon(458 Points)   {1B252E95-9D29-4262-9FC9-D0D1250…  {52866B35-C2F1-4079-A2D9-3EAFAD7…  real         nein     4612        0
 1558 │ Polygon(280 Points)   {66E54DB0-5F0C-4C77-9B25-9BAC5D1…  {56B488CB-7C77-4EA2-9F86-4F57794…  real         nein     3814        0
 1559 │ Polygon(214 Points)   {991B6A55-BE77-43DE-A490-CBD8DE6…  {C3522C0D-53F0-4071-98AE-B493E47…  real         nein     4622        0
 1560 │ Polygon(557 Points)   {AAFC9B55-97B4-4A7F-8A18-5E8D977…  {03F01C4E-D70C-46DE-854C-8E734A9…  real         nein     1736        0
 1561 │ Polygon(105 Points)   {5E8334B8-48A7-460F-9129-0395942…  {FA214015-8759-4EE2-AF96-3CEAD9F…  real         nein     2610        3
 1562 │ Polygon(441 Points)   {79210A3E-5327-41DD-AC29-50BEE35…  {07A7EF33-ACB2-4868-B75D-ACB551F…  real         nein     3535        0
 1563 │ Polygon(1096 Points)  {EF8C6115-31C0-40D9-95B7-8636C13…  {A02FCC83-1EAE-42D3-9626-DC2256B…  real         nein     9428        0
 1564 │ Polygon(269 Points)   {6D733D5C-4F54-460A-89DE-0D0B661…  {A819A6A1-8656-4B2B-B59F-8AD578C…  real         nein     1981        0
 1565 │ Polygon(1495 Points)  {3AC2DD2C-63E0-4AC6-8371-89EA0BA…  {6C201FEF-E001-48A7-AF74-DDFA620…  real         nein     6260        2
 1566 │ Polygon(175 Points)   {1B859458-797E-4A4F-AB37-7994479…  {B52BBD86-F055-4F6B-8922-ED2ACA9…  real         nein     4466        0
 1567 │ Polygon(113 Points)   {1A1704F0-543B-4084-ABB5-2C1B1A4…  {73000B6B-9465-4EC6-B328-5B2DB7E…  real         nein     9465        0
 1568 │ Polygon(1037 Points)  {0339514D-7781-4BF4-A1B7-C9535CA…  {CE0DB427-01F1-454D-A336-F087F1B…  real         nein     1443        0
 1569 │ Polygon(390 Points)   {2CA5B58C-6F56-423A-B55A-E57739B…  {234AEEA3-C80E-4BE7-86E8-7842D08…  real         nein     3205        0
 1570 │ Polygon(591 Points)   {0A527600-B38F-4C07-A215-A6D253B…  {348D3EE7-1F25-4B78-9860-EED3DAB…  real         nein     6262        0
 1571 │ Polygon(390 Points)   {086EB6B1-F463-4710-890A-E2E7093…  {8FAB13B7-1E1E-4547-BE9F-A4027BD…  real         nein     6043        0
 1572 │ Polygon(536 Points)   {E7EB6D75-D947-451C-A319-D179A9B…  {21B8256D-703A-4090-A62A-74364D7…  real         nein     6592        0
 1573 │ Polygon(1501 Points)  {AF3450A3-E316-4A78-B1C5-E8AFA0C…  {C956E2B5-5E91-44E3-B761-C27F92E…  real         nein     4116        0
 1574 │ Polygon(486 Points)   {BB4745EB-EDF1-4F33-8000-E9790A3…  {70ED01A8-1ED3-4D0C-AB0A-013B335…  real         nein     6112        0
 1575 │ Polygon(308 Points)   {A0A74AF8-9006-4BEC-997D-EB6359D…  {81EE5540-6B4D-4829-B735-8272653…  real         nein     3272        0
 1576 │ Polygon(856 Points)   {3A560E83-6296-4789-8E2C-5E9803F…  {CC4A2CA5-75D9-4D47-B3AA-99D2593…  real         nein     4451        0
 1577 │ Polygon(487 Points)   {4AEE65B7-FCAA-4A5D-8694-CD1369F…  {0A5C9037-81F1-43AD-9A58-A8D6735…  real         nein     8560        0
 1578 │ Polygon(791 Points)   {C07CD8FD-DE93-43EB-9F8B-9EBEA01…  {DE29C008-6F14-4DC3-AE43-B435088…  real         nein     8376        2
 1579 │ Polygon(687 Points)   {0A6AC537-3894-4F82-A53E-8CFCD99…  {6D2F5290-1576-49CE-AE7E-E3E6CF4…  real         nein     9514        0
 1580 │ Polygon(996 Points)   {617537DB-3366-4F9B-865D-C142AD4…  {54A817A3-3651-431D-9B83-1845653…  real         nein     1268        0
 1581 │ Polygon(528 Points)   {857BCA0C-6609-4565-8EED-978E731…  {35CF1191-D7FA-458E-8F75-90E018E…  real         nein     9243        0
 1582 │ Polygon(536 Points)   {82A24BC6-F25F-4A4B-AF31-EEA950A…  {D9144E48-7316-42CB-9415-E856B32…  real         nein     3425        0
 1583 │ Polygon(1379 Points)  {CDFD97F0-64FE-4006-A986-C491D8A…  {A2D15143-0791-457E-9B89-557B71B…  real         nein     7028        0
 1584 │ Polygon(293 Points)   {2CDB0F8A-4F4E-485A-83AA-FEBABBD…  {C7AD4E8E-5A70-4F23-9372-6E26800…  real         nein     4144        0
 1585 │ Polygon(433 Points)   {1A913462-CB22-418C-87E1-0A8BD76…  {02A76FCB-FC9C-4472-9B2C-BE4D355…  real         nein     3113        0
 1586 │ Polygon(565 Points)   {8B4763A5-E533-496D-BC96-7F1505C…  {3A9139F4-81C1-4F49-A023-99CB17C…  real         nein     6416        0
 1587 │ Polygon(443 Points)   {971677AF-835A-46E1-90E8-8A97F35…  {3F4B4706-9257-4C8D-B1B3-2ADB705…  real         nein     5312        0
 1588 │ Polygon(118 Points)   {A1541C19-0A9C-44B7-BF28-D412098…  {72A6E11B-1AE9-40C4-B8F1-C8C0429…  real         nein     7152        0
 1589 │ Polygon(342 Points)   {9FCBCDA5-7289-4D66-B7E2-9D200F3…  {799C336B-60DC-412E-A9DA-4489870…  real         nein     2615        0
 1590 │ Polygon(454 Points)   {FF5ED878-2F3B-42A9-9C9B-5F495D3…  {C4521D8B-59CE-4BCC-8928-66D41C5…  real         nein     4316        0
 1591 │ Polygon(263 Points)   {F49D5070-9F27-4D2A-ABDD-C896E55…  {64292D07-CB79-463B-9526-A7916D0…  projektiert  nein     6544        0
 1592 │ Polygon(970 Points)   {B258F9CD-533D-46ED-A39D-E011308…  {2C98A680-731D-4E62-A3E2-3909B8A…  real         nein     1170        0
 1593 │ Polygon(524 Points)   {78BDFDE1-663C-4003-A351-79DFC0F…  {722EEA8E-6CBD-4D27-ACDE-CE30910…  real         nein     3066        0
 1594 │ Polygon(326 Points)   {A58A4D4E-29EC-430E-BEC6-A5422A1…  {1104457C-347A-40C4-AD7D-49FCF51…  real         nein     2736        0
 1595 │ Polygon(352 Points)   {5760A458-B556-4C1A-B91A-A081D3D…  {553B44FA-447D-48D4-910F-B50E3CD…  real         nein     3254        0
 1596 │ Polygon(309 Points)   {8133CEFD-2A7A-486F-91BC-48C23B1…  {3160C402-B2C3-40C0-89BB-F0C7C39…  real         nein     6677        2
 1597 │ Polygon(673 Points)   {F790492D-B78D-493C-BFEF-3E8FDA6…  {934D217C-260E-4A3F-B57B-CFAA464…  real         nein     3268        0
 1598 │ Polygon(1413 Points)  {6A9A26E4-964C-448D-96E9-18B8A88…  {16D3F698-934D-4AAC-AF2A-5461D31…  real         nein     1041       33
 1599 │ Polygon(245 Points)   {D3731546-F32B-43BE-88DC-D9AE1D8…  {8EF8B027-982F-441B-BD71-58D5A3E…  real         nein     4628        0
 1600 │ Polygon(174 Points)   {F98601ED-4023-43E9-9558-9F32E55…  {10D166AA-6203-4B2F-A838-A73DDE8…  real         nein     8715        0
 1601 │ Polygon(1024 Points)  {5391E3D1-3CC1-4456-96E4-214FCDE…  {03C38054-4083-43C4-8AE9-4A89879…  real         nein     4455        0
 1602 │ Polygon(693 Points)   {FFA1E18A-9D6C-46A7-959B-4335877…  {7F355FEA-B2C6-4A47-AA9D-B60A168…  real         nein     5079        0
 1603 │ Polygon(445 Points)   {690FA85B-ECDF-4C2B-A823-0E888FD…  {97DC32F3-3D66-40EE-8D46-12FAB77…  real         nein     3360        0
 1604 │ Polygon(438 Points)   {4888993A-C3B6-4A7B-B474-975FDA4…  {72BFAB4B-B111-4344-B3F3-36BF566…  real         nein     8224        0
 1605 │ Polygon(357 Points)   {D8D80EAD-6399-49C4-93A2-D6DBFFC…  {4A4EC082-030A-4819-9D18-F7DCE4F…  real         nein     1725        0
 1606 │ Polygon(626 Points)   {36E46FE2-20B8-40CA-BDE2-099DEA3…  {3261D10B-92C6-493C-BF0C-CEF0A69…  real         nein     5078        0
 1607 │ Polygon(565 Points)   {2ED76911-18DA-4D00-8B0E-970DCC2…  {A78E98F3-4854-4D9C-BE49-9D80998…  real         nein     1115        0
 1608 │ Polygon(362 Points)   {57F16A0F-41A1-4D8A-81B6-031C27E…  {E396EBB9-FA10-4D57-8342-ADA219A…  real         nein     2903        0
 1609 │ Polygon(797 Points)   {DFC7BB56-DFB0-4939-B8B8-37B6695…  {3182659C-95DE-4616-9F8F-8113878…  real         nein     8166        0
 1610 │ Polygon(389 Points)   {5DAB4165-E988-465A-AF84-E9141CC…  {3F5DA7B0-7833-490F-9D51-E1AC4AF…  real         nein     1890        0
 1611 │ Polygon(933 Points)   {7CC40B5C-586F-40A8-8807-DC02F4C…  {5E315B54-FF52-4B80-BE56-69DC3A5…  real         nein     6277        0
 1612 │ Polygon(805 Points)   {3821041B-539D-440D-B7CC-FEB4697…  {9A54523B-37BA-4E29-93E7-C23D8FC…  real         nein     8162        0
 1613 │ Polygon(640 Points)   {A68568CD-324D-4DE1-8482-83B0343…  {81061280-6ABB-4373-8928-29DDF16…  real         nein     9044        0
 1614 │ Polygon(897 Points)   {A00DA16B-DA05-4DF4-97FD-B52FF53…  {F623204B-9BFE-4BF0-828C-2332825…  real         nein     6203        0
 1615 │ Polygon(533 Points)   {3147EFF4-005D-48AA-A9B3-C066964…  {864A5514-015F-4B2E-8A89-35C1402…  real         nein     8727        0
 1616 │ Polygon(410 Points)   {9105B823-672D-4BE1-8F99-445E3A9…  {6F051B75-FBDD-4724-8706-C8F49AB…  real         nein     6083        0
 1617 │ Polygon(500 Points)   {51C33721-FE85-4C53-90D3-1CB2298…  {EC06CC67-37D1-4529-B1CE-692FECF…  real         nein     1304        0
 1618 │ Polygon(446 Points)   {7C14BC09-4FA0-409E-B7A6-73B03B0…  {D29A848F-4904-468C-8183-405899C…  real         nein     3045        0
 1619 │ Polygon(455 Points)   {3565C4BC-8FC6-4113-9359-6BFB78A…  {E8950BE3-1388-4A75-AA68-C88438B…  real         nein     1252        0
 1620 │ Polygon(383 Points)   {A457CD55-802F-4840-B41D-DDE55CC…  {2D3020A4-B8F3-4387-A563-BC6C457…  real         nein     7430        0
 1621 │ Polygon(1196 Points)  {B1B09A3C-0E70-45E6-BF62-D117F69…  {9BA7FEA8-9FD2-44DD-9083-8B24D07…  real         nein     8952        0
 1622 │ Polygon(557 Points)   {6E264486-8E5E-4C3C-AC7D-F40EEAB…  {D518269C-4192-4302-B259-518977B…  real         nein     4942        0
 1623 │ Polygon(777 Points)   {035704CA-48E5-43B5-A771-9E65963…  {BFB878AF-101D-4071-BB1E-4F4A8C2…  real         nein     9055        0
 1624 │ Polygon(1085 Points)  {382B401D-8A22-472E-BFD0-546107E…  {359EF63B-85C6-44AB-ADF3-086916B…  real         nein     9427        0
 1625 │ Polygon(428 Points)   {9A494BD9-59E4-4B7D-A00D-8F56769…  {CFA69DD5-F6B4-40B0-96F1-560A899…  real         nein     1148        4
 1626 │ Polygon(1112 Points)  {2089D1A9-4760-4118-990D-7E46F4D…  {965D10AF-6EC5-4407-B420-6FC2ED1…  real         nein     1853        0
 1627 │ Polygon(655 Points)   {477F9E17-BCAA-4687-99DA-4743C03…  {CCEA9E48-E36C-45CE-A218-77028AF…  real         nein     9315        0
 1628 │ Polygon(276 Points)   {764BAEC8-CC39-4793-8304-CA50309…  {424263C7-C34C-4429-8945-934D44C…  real         nein     8535        0
 1629 │ Polygon(689 Points)   {A1E2CB47-2E5C-4008-9647-FC49A7C…  {80AD2BA6-855F-4D59-87F9-1F01927…  real         nein     4243        0
 1630 │ Polygon(396 Points)   {152D5F19-1087-46B2-BD75-53E8C5D…  {7E632004-61F2-46D1-AE05-466D444…  real         nein     6682        0
 1631 │ Polygon(343 Points)   {3620EDB4-6670-4408-9D5D-C8EC2C6…  {F4429A78-E86A-4C08-BAE6-16D1E46…  real         nein     3298        0
 1632 │ Polygon(1089 Points)  {0FE99F55-2EBC-4C80-B527-9A0C9A0…  {04B568A6-12CF-4A1B-8DA4-24D8C2B…  real         nein     3324        0
 1633 │ Polygon(436 Points)   {9E607313-8808-430E-8C40-811C587…  {848A389C-29CF-4CCB-873D-495DE12…  real         nein     8595        0
 1634 │ Polygon(955 Points)   {F41CD1AA-D148-476B-BDFC-1EA0FC1…  {A9F3C3CE-BD60-4FD7-A2C3-D18B90C…  real         nein     8450        0
 1635 │ Polygon(256 Points)   {0A56F563-C2AD-4B98-B697-85F0EAC…  {93F27B23-062A-4C5D-A846-0416024…  real         nein     8552        0
 1636 │ Polygon(267 Points)   {9A51E0F8-1E70-4373-8B6F-9E320A9…  {0C65654E-46A8-4FE4-88EE-85A707D…  real         nein     3475        0
 1637 │ Polygon(593 Points)   {4009A3F4-0393-4C25-9065-429651B…  {9649794B-34E6-4C15-90A1-73EC28D…  real         nein     9622        0
 1638 │ Polygon(788 Points)   {673CD2B9-C9FB-4AEB-AA7A-BF36207…  {5B517C20-6D62-4470-B69F-05AA624…  real         nein     8542        0
 1639 │ Polygon(539 Points)   {0417D67E-496F-4DCD-9A89-9F0AD69…  {D0EEE055-173E-4C2C-8138-BA7AAA8…  real         nein     6030        0
 1640 │ Polygon(370 Points)   {C8DA7FBE-45CB-4F05-8C28-82022BD…  {918BFD55-5432-42FA-AE17-F68F239…  real         nein     3235        0
 1641 │ Polygon(299 Points)   {BCD40C1F-B569-4C91-B7EB-1EFC75F…  {43BAAD54-1ACB-41B0-AA87-E5FCE57…  real         nein     8524        2
 1642 │ Polygon(861 Points)   {96A1C662-C7BB-488C-BB87-34B27CF…  {4ADF521D-D7E2-45F8-A898-FA2E56C…  real         nein     9116        0
 1643 │ Polygon(380 Points)   {077E8D81-77DB-4319-B815-DBD6F5A…  {FC1042A4-EEFE-4E9A-8D5B-16BC110…  real         nein     3949        0
 1644 │ Polygon(730 Points)   {4C06FC4E-4D04-4B81-A777-A72FEA1…  {30BA91DC-0759-4FB8-8861-238B96E…  real         nein     6214        0
 1645 │ Polygon(1509 Points)  {D7258469-3B3C-4838-A8D7-580770B…  {6A990D76-DE27-49C2-A1C9-1B429A7…  real         nein     6315        3
 1646 │ Polygon(598 Points)   {C9D099CD-E209-4CA7-ABD3-2771592…  {C3221D50-512D-4167-A90D-BDF303B…  real         nein     1434        0
 1647 │ Polygon(341 Points)   {056B46BE-526D-430E-AE91-72043E1…  {24E8071E-39CB-4B94-832E-1A8D410…  real         nein     6749        1
 1648 │ Polygon(595 Points)   {FC33ACAE-FA56-4775-BA87-F76A633…  {A4E075CA-63E3-481F-A466-23BA738…  real         nein     1148        8
 1649 │ Polygon(451 Points)   {8A0C9CF5-EB6F-4A82-AB40-8CF0980…  {AAAD4CD5-EA8F-4EB4-93DD-109B281…  real         nein     3238        0
 1650 │ Polygon(1105 Points)  {166E212D-A915-4543-A1B2-110680A…  {3EFA9640-66B8-4CEA-9742-2BD56AF…  real         nein     8543        0
 1651 │ Polygon(171 Points)   {2FADF725-2235-41A4-924F-4CC4BF1…  {9DC65DB4-08F6-44E2-BB5D-FF56F32…  real         nein     1873        3
 1652 │ Polygon(604 Points)   {D7524D13-DAA3-43C4-93DF-97D343D…  {73461E76-7928-4BEB-9B82-51C5FCD…  real         nein     1040        0
 1653 │ Polygon(772 Points)   {928E97D2-B6B2-4252-AB56-7610513…  {8ABA0B41-F6FA-4801-8507-16EA0EA…  real         nein     2814        0
 1654 │ Polygon(367 Points)   {B59BE1AD-4514-4FD4-9C41-8939E47…  {C30FF206-610A-4322-83DE-B512B9E…  real         nein     3551        0
 1655 │ Polygon(665 Points)   {37319A5E-6483-43F8-B3C8-6EB6C9C…  {8B63E6C8-8B18-45FE-AC64-313A80B…  real         nein     6763        1
 1656 │ Polygon(214 Points)   {D31AFA86-3619-4056-B763-487ED9D…  {1D0D253E-B831-4126-A39B-553458A…  real         nein     6939        2
 1657 │ Polygon(652 Points)   {20689D2B-DB4C-490F-A24D-0CAD513…  {4126FBF5-D80E-4097-9712-EAF65C2…  real         nein     8512        0
 1658 │ Polygon(386 Points)   {8FDD1FDC-42CB-47A3-B272-331D274…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3020        0
 1659 │ Polygon(734 Points)   {F780AA64-2A98-4B4B-A443-11D5040…  {73FB20BC-07F8-40EB-98B3-257C714…  real         nein     1433        0
 1660 │ Polygon(97 Points)    {7BFDD664-C216-47EA-AAA9-EE6CDDA…  {D8FC8B5A-7276-476D-BD38-76EDB0D…  real         nein     7431        2
 1661 │ Polygon(375 Points)   {CA37AD97-4EB7-48B7-90AD-232DC41…  {A23E8CA0-368E-4B4E-A0EC-8F9BA33…  real         nein     9527        0
 1662 │ Polygon(535 Points)   {42ED9E24-17B7-4DFF-BBA7-A084CDD…  {EE298A90-B064-408D-87A7-A2CC801…  real         nein     6210        0
 1663 │ Polygon(1004 Points)  {EF754286-7CA8-4716-8586-4CBBD13…  {C0B5118D-1D96-470E-A3EA-688F1FB…  real         nein     1410        5
 1664 │ Polygon(390 Points)   {B7CBAF6B-F14B-4699-924E-1E50468…  {54D1D1E9-9BDD-45D9-B027-A0CEFF9…  real         nein     7141        0
 1665 │ Polygon(85 Points)    {7D7B990A-F124-471B-AC93-4591399…  {C0E678B0-2150-46F1-9BBB-E16DB60…  real         nein     7742        3
 1666 │ Polygon(345 Points)   {60841DDE-6EBD-4933-BA12-C00BF7E…  {A5569542-23BB-49DA-87FE-5483491…  projektiert  nein     7031        0
 1667 │ Polygon(370 Points)   {24A3784B-596E-4B77-BF0C-8A1CF38…  {54F86F17-AB3E-4653-AA84-14805E0…  real         nein     8174        0
 1668 │ Polygon(624 Points)   {94751287-EE83-40E7-B35B-607C11F…  {0E74ABF3-0BEB-48E2-AE1B-5A80D2C…  real         nein     3237        0
 1669 │ Polygon(716 Points)   {1C6C3B0A-0598-455F-9FF9-B750439…  {8E71814B-5A64-4804-8C61-9E34C41…  real         nein     6146        0
 1670 │ Polygon(574 Points)   {F9AE4D2E-47AB-4F79-8845-8A2EE06…  {3DB5F863-9538-4824-9D2A-07D5925…  real         nein     2520        0
 1671 │ Polygon(648 Points)   {DF394071-F8C4-470A-BA2E-869D5E3…  {8468BA54-1BE0-4819-B891-099EBDE…  real         nein     1551        0
 1672 │ Polygon(777 Points)   {3208EA7F-56BC-4107-95A9-8D79588…  {EB9A7FC2-355C-479C-9722-EA9A433…  real         nein     8311        0
 1673 │ Polygon(133 Points)   {5F0CB0E6-C198-44DC-81E9-6B0388E…  {2169C989-3AE6-4F10-9774-9AB02B9…  real         nein     6716        3
 1674 │ Polygon(1312 Points)  {59FBEB75-1855-4BA6-86DE-1E0A84E…  {26DF2628-419D-4A92-8DB3-A4F133D…  real         nein     3145        0
 1675 │ Polygon(585 Points)   {88E28C9F-E9B8-4479-B225-176B981…  {C03C1F4E-9104-44DB-B67C-5840A37…  real         nein     2743        0
 1676 │ Polygon(414 Points)   {716B3E42-61B3-4F91-AB24-0EA327A…  {F3A4EE83-B627-49B6-805D-05B27F1…  real         nein     3433        0
 1677 │ Polygon(606 Points)   {66D87D1C-FF8C-447F-BF13-4D8748A…  {4F0370FC-3DD5-41C6-9C23-B62CD57…  real         nein     4802        0
 1678 │ Polygon(1082 Points)  {BBFB843E-AB85-4BED-B091-4CC04F9…  {2B91F713-1088-4689-A798-14B46B5…  real         nein     8452        0
 1679 │ Polygon(380 Points)   {5FF42CA5-7144-4B15-A05E-E0645B0…  {82591E65-E1F2-4BD9-8BBC-16E47E4…  real         nein     4142        0
 1680 │ Polygon(312 Points)   {684B73A7-BE8F-436D-819D-FCF22F6…  {D1FA3DEA-393F-44DA-84B6-3765AEE…  real         nein     9114        0
 1681 │ Polygon(481 Points)   {272A2520-2FB9-4DA6-A3CB-59E4201…  {192C2E9C-9319-4434-8180-62927AF…  real         nein     3473        0
 1682 │ Polygon(143 Points)   {24E15BA8-E41A-438B-9132-FDD0674…  {C571BB60-F7F3-4FF3-B11D-5ADCBBB…  real         nein     6663        0
 1683 │ Polygon(1044 Points)  {DEEAAD84-DB1D-4D4D-BD8D-9337968…  {61C1BFD6-B220-4FD5-A17D-A2F692D…  real         nein     1085        0
 1684 │ Polygon(424 Points)   {29555B80-35D4-43AB-99C9-20E918D…  {25BEFD62-977A-45C1-804F-684F216…  real         nein     8175        0
 1685 │ Polygon(724 Points)   {8549C91F-76DD-4021-805A-FA791CC…  {CD89BF03-5E6B-4BA8-97D0-6862097…  real         nein     4938        2
 1686 │ Polygon(410 Points)   {DB153DFC-9B63-4C1D-95CC-88499D4…  {FA285734-4581-48D3-962C-0424739…  real         nein     5313        0
 1687 │ Polygon(933 Points)   {3D87AEA8-25CA-4346-94E9-0965855…  {959339C9-671F-484F-9E38-964E853…  real         nein     1406        0
 1688 │ Polygon(469 Points)   {051BF346-4E69-491C-A33C-897B5F0…  {B6B9717D-E4B8-4CD0-AF56-B6266D0…  real         nein     2806        0
 1689 │ Polygon(267 Points)   {2ECD48B0-5AEA-44DA-A726-935614F…  {597D903E-D6DF-4EAF-B1AF-D3DE93B…  real         nein     1566        0
 1690 │ Polygon(406 Points)   {A5FE41FE-8B41-4DA4-957E-1918DD4…  {69D0A74E-E350-45AD-901B-E35B4A2…  real         nein     1482        0
 1691 │ Polygon(703 Points)   {2019E870-F0CC-4685-AE16-1764C44…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8049        0
 1692 │ Polygon(217 Points)   {6B6F2746-FE95-4834-AEF0-89B5286…  {29F73275-6288-4457-B42F-0E4BCE5…  real         nein     9462        0
 1693 │ Polygon(5047 Points)  {A6A56BCE-9F9B-4E2C-B805-02B1DA6…  {9C59A0A2-620E-4274-9FDA-BE67B1F…  real         nein     4431        0
 1694 │ Polygon(559 Points)   {0B70B50E-C393-4FAC-AC51-6AD5927…  {C0D917A3-3391-4BF0-9077-70B60AC…  real         nein     8363        0
 1695 │ Polygon(135 Points)   {350E20B4-A2C2-458C-B637-1E984E6…  {D50F4171-CDBF-463B-832A-C26FFBE…  real         nein     7016        0
 1696 │ Polygon(639 Points)   {3DA7F292-7871-43E4-95D2-89A7EDA…  {1230B1C3-8C90-42BF-BD87-96092AD…  real         nein     8908        0
 1697 │ Polygon(642 Points)   {86E1C544-68FA-4415-A34E-7408BC5…  {F6D97767-BFF7-4770-A0EA-DF49323…  real         nein     6280        0
 1698 │ Polygon(296 Points)   {FD3CC5F5-11C5-491F-AED2-5FB7C8D…  {3CFCA01A-ACF9-4321-B34F-FD96378…  real         nein     3852        0
 1699 │ Polygon(337 Points)   {F4AA0343-C0F0-4DA4-9B88-5793E98…  {2CCA2417-5BA9-4AA4-AFC9-25291D0…  real         nein     5330        0
 1700 │ Polygon(482 Points)   {3BD30AE4-AD72-474D-86ED-E2FF545…  {44A08DF6-DF6A-445A-9024-1510C06…  real         nein     9430        0
 1701 │ Polygon(664 Points)   {ADE61634-BED0-4D5D-9608-0FFB249…  {8A6E4794-3B76-4DA8-908D-FEBC58B…  real         nein     1291        0
 1702 │ Polygon(458 Points)   {7EE1B404-98AA-4489-A6C6-48FFB92…  {DB5CDDB9-DE65-4B0E-8011-F65F446…  real         nein     4634        0
 1703 │ Polygon(977 Points)   {4710E05A-64F9-4908-B6CF-09CF27F…  {D0F11DED-8B4F-44BA-B655-F2D59D6…  real         nein     9032        0
 1704 │ Polygon(662 Points)   {9C642EF5-BF9E-4E28-B14F-7FDFA03…  {57C55C3E-6F48-49C1-A553-31AC01C…  real         nein     3622        0
 1705 │ Polygon(786 Points)   {BE5D12BD-1306-4FF2-A686-04AC288…  {F67101D0-0934-4B67-8A25-EAFBA46…  real         nein     8911        0
 1706 │ Polygon(1066 Points)  {1C8ECFE7-D957-4CA8-9F68-9593265…  {9867EF3D-C9E2-4C15-A5E7-A26BD9F…  real         nein     6053        0
 1707 │ Polygon(862 Points)   {C8A259C2-F4D4-42F9-BB82-A7963F8…  {8A44030F-FE21-4604-8B5A-EC117EB…  real         nein     9104        0
 1708 │ Polygon(97 Points)    {9E9446A7-FB2D-4334-AEAE-D8D2F31…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3027        0
 1709 │ Polygon(276 Points)   {61240388-48F7-45E5-A410-D503EDE…  {67B6ADC7-FD47-46D9-B3C7-672F54A…  real         nein     3295        0
 1710 │ Polygon(601 Points)   {64023476-69DA-4896-BAA5-609B58A…  {2BE213F2-CEF2-4764-BE43-F3D1A83…  real         nein     8155        0
 1711 │ Polygon(540 Points)   {8EF4CBBE-01E3-43BB-83AD-DFCA6F2…  {64439675-5388-46F6-B046-0E9FFF2…  real         nein     1239        0
 1712 │ Polygon(650 Points)   {3C0D727E-9804-46C1-9878-B646BBC…  {0DD1F7E8-5589-4B19-9908-4E0BAC1…  real         nein     3434        1
 1713 │ Polygon(269 Points)   {BBCC9CD7-65AF-44AA-9369-6B463C3…  {98AC166D-9894-42D6-8CB7-1850A2E…  real         nein     6743        0
 1714 │ Polygon(863 Points)   {1C5FD47C-AF49-422B-A642-9F3BE7A…  {36A00F8F-4DE2-41AC-A4C8-00DBD10…  real         nein     1432        0
 1715 │ Polygon(635 Points)   {CFC51302-C9CF-4A44-899D-3297FD0…  {B1B6A124-FAE6-4829-9131-FAB1AC0…  real         nein     8506        0
 1716 │ Polygon(911 Points)   {1CDF146D-F5FF-45F8-BB35-F26DD32…  {CBA7FC4C-15E7-489E-AA3F-AF60137…  real         nein     8934        0
 1717 │ Polygon(668 Points)   {CD902EAD-7B1A-4943-9042-47206C8…  {740BFA33-D35A-4425-A34E-FF2979F…  real         nein     1870        0
 1718 │ Polygon(423 Points)   {5894D784-D9A9-4BB5-A1FB-A3916BD…  {F6C3E58D-A788-43FF-9188-6854F82…  real         nein     1782        0
 1719 │ Polygon(754 Points)   {86D6E491-DB72-41A6-A5A0-B52650F…  {2E91DB08-2C42-4F1C-BDDC-DF75223…  real         nein     6006        0
 1720 │ Polygon(989 Points)   {43217951-D6D8-473A-9D4D-D7A851D…  {A18D2B98-3313-42BC-BA6A-3EDCED9…  real         nein     3052        0
 1721 │ Polygon(156 Points)   {39BEF21A-570F-4CA9-BB7E-1433D5D…  {9F7AA546-5BAA-4516-87B6-5C9A065…  real         nein     2946        0
 1722 │ Polygon(692 Points)   {E61CD8B4-3887-497B-B7BE-4FE7418…  {87EE6BEE-16BF-4674-A984-FC354EF…  real         nein     8304        0
 1723 │ Polygon(827 Points)   {E6A7ADCD-72F8-42B4-A7CF-5B009CE…  {52A18ED9-27A5-4635-B4CA-B55C538…  real         nein     6232        0
 1724 │ Polygon(432 Points)   {42B09BD6-0145-43D2-8A9C-E5ECBEC…  {E8290FC5-1BB2-46F7-BCA4-887FCFC…  real         nein     6218        0
 1725 │ Polygon(645 Points)   {F6E91058-16EC-488E-ABED-F5DDB1E…  {E39EC38B-B917-411B-8E50-DB7F2EC…  real         nein     8478        0
 1726 │ Polygon(787 Points)   {423DB085-2434-4EEE-981A-B40A07C…  {24959E32-40E6-434C-B0D7-64C2278…  real         nein     6370       41
 1727 │ Polygon(488 Points)   {FB5F1DFC-C763-4927-9E47-CE92C49…  {E434B1EC-BFA2-4606-A62C-7D4509E…  real         nein     8863        0
 1728 │ Polygon(1687 Points)  {4680FFED-CBCC-497B-9E55-64FD233…  {34483F5C-5459-40B6-AE7F-45919EA…  real         nein     1033        0
 1729 │ Polygon(389 Points)   {458EB517-F86E-44D4-B7F3-F866696…  {3A10924D-4205-4BDA-922A-F8BC7C5…  real         nein     5325        0
 1730 │ Polygon(823 Points)   {2107BF46-484A-48CD-A10C-EA05168…  {4C4025BF-F253-4DE7-8000-F5C33BC…  real         nein     8404        0
 1731 │ Polygon(596 Points)   {05625B55-C4B3-4FE2-AFE6-D0FD32F…  {AA65B350-6FCC-4894-AC75-344FCB5…  real         nein     4114        0
 1732 │ Polygon(935 Points)   {33793A32-B6F3-4DD8-B027-6FD7E6F…  {AF38A60E-7AD8-4CC9-940B-90DE374…  real         nein     5737        0
 1733 │ Polygon(601 Points)   {0E34F615-3F2A-4D2A-B756-A69816F…  {6472AC00-A0D6-4B75-8918-DDB98FF…  real         nein     1690        0
 1734 │ Polygon(957 Points)   {481558EA-A996-4154-9EC1-178E0CF…  {C66E1655-6D2B-4E92-82A4-3731A99…  real         nein     3600        0
 1735 │ Polygon(2539 Points)  {E12546B1-AE35-4E1C-9E0F-D525C18…  {ADC18089-AA9E-47A6-B274-9286FB5…  real         nein     2825        0
 1736 │ Polygon(231 Points)   {166CD8A6-D71A-496C-ADDF-406551E…  {6D191C2B-A0FC-42EF-B313-F622E30…  real         nein     3296        0
 1737 │ Polygon(225 Points)   {D10CE506-7C13-4C38-B6CD-EB098DF…  {E8794CAC-32EF-42ED-8DE3-A4112A3…  real         nein     6749        0
 1738 │ Polygon(946 Points)   {B94E1846-EEEB-427E-8FC7-B68E44B…  {014981E1-0AE3-49FE-9288-F2704A4…  real         nein     3098        0
 1739 │ Polygon(664 Points)   {6DBAC9AB-EAB9-4F8B-8437-A7BF7BE…  {FAD6BA9F-9416-4DC8-AC2A-E57C80E…  real         nein     1358        0
 1740 │ Polygon(733 Points)   {5ECBC766-A93A-4AE5-B7C3-F9BDB77…  {4C4025BF-F253-4DE7-8000-F5C33BC…  real         nein     8406        0
 1741 │ Polygon(334 Points)   {70A89295-BB2D-4701-BD4D-913447B…  {C59E1AA7-A76D-43A4-B273-253F480…  real         nein     1470        0
 1742 │ Polygon(419 Points)   {C1A23061-C15E-43BE-A1FE-0F2B86F…  {383564B6-5DF0-459B-854A-5B7BEAB…  real         nein     5503        0
 1743 │ Polygon(497 Points)   {B6D74D61-95F7-4C1E-BF6F-F8041D0…  {538F68C2-77BC-4961-94A4-174DFFB…  real         nein     3543        0
 1744 │ Polygon(289 Points)   {5F67C5BA-B698-4F25-A56C-CA1561B…  {439C96C8-A624-4766-AB06-B48A5EA…  real         nein     3264        0
 1745 │ Polygon(268 Points)   {BAD6A016-EE46-4DBE-BCED-9A24300…  {F0A4716B-CD14-4525-81E2-E38DFA4…  real         nein     4107        0
 1746 │ Polygon(642 Points)   {ACEA1B6D-05D1-46BA-8397-F8239B5…  {7D5D7716-D509-4CB3-A993-7F63D9B…  real         nein     1553        0
 1747 │ Polygon(443 Points)   {19B4FB56-7D5B-44EF-A558-078D442…  {196765FD-AB54-4B22-90AE-75CDD5B…  real         nein     7063        0
 1748 │ Polygon(660 Points)   {CACCF2C5-1C8C-442F-8288-713C89F…  {AF5B0A73-4A59-4C7E-9F88-DFFFB2C…  real         nein     1522        0
 1749 │ Polygon(425 Points)   {400D0DE4-4F37-4D35-B2A4-C11FED5…  {E321E018-B482-477D-9C0C-DA391BB…  real         nein     4553        0
 1750 │ Polygon(255 Points)   {12EB879C-FDDA-4D36-9CE9-ED55FF2…  {E823ACDF-C218-420A-860C-72B1C19…  real         nein     6809        0
 1751 │ Polygon(704 Points)   {BB558F91-0F4F-4F75-9CF0-E8DAC5E…  {25422395-E24E-468E-8505-4355B3E…  real         nein     1186        0
 1752 │ Polygon(401 Points)   {71988222-6425-4A05-9CEB-D5C3348…  {B5AABF69-956B-4E1A-A401-B2FB159…  real         nein     8714        0
 1753 │ Polygon(619 Points)   {5B410479-9772-403E-9735-AE4DABE…  {73DB1567-0729-4EA8-A4E3-AAEF65A…  real         nein     8332        0
 1754 │ Polygon(448 Points)   {179A26BD-74DF-4120-9247-C11C060…  {51BA5314-D45C-488A-9473-A1A027B…  real         nein     5040        0
 1755 │ Polygon(378 Points)   {B8ED3360-7699-4D0D-8EC6-13A89FD…  {8E45C2F7-58C3-4A53-B475-656B493…  real         nein     6213        0
 1756 │ Polygon(427 Points)   {992D6787-7F9D-41D6-AB82-BA21DA3…  {F8460D09-D54B-420C-8A93-761EE2E…  real         nein     8804        0
 1757 │ Polygon(105 Points)   {7C29FF9D-DEBF-4907-8688-EC9436C…  {5398792C-7950-40A5-99E0-8B15EB0…  real         nein     3033        0
 1758 │ Polygon(267 Points)   {C7538BDE-CC22-41DE-B8FF-A82A669…  {CA0CD681-0035-412E-90B9-25691E0…  real         nein     8893        0
 1759 │ Polygon(347 Points)   {2840DDB2-BCF4-4916-AC34-47C0F5F…  {32338685-6213-4BC6-BC48-E47FA11…  real         nein     5102        0
 1760 │ Polygon(441 Points)   {0390223A-0557-446E-8BDD-1BFC9E5…  {66106089-4A55-4FE1-8242-1F8F328…  real         nein     3704        0
 1761 │ Polygon(481 Points)   {55C36F23-9144-4400-82E7-4AD353F…  {DA9ABA08-0D1A-4214-B136-F4852D7…  real         nein     5632        0
 1762 │ Polygon(893 Points)   {548E7E92-C21C-4761-AE50-8B8CD57…  {D3D763C6-C1A5-4D6B-A2DE-0565D3F…  real         nein     4915        0
 1763 │ Polygon(768 Points)   {00814703-7B97-436C-A65E-7E7C374…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8048        0
 1764 │ Polygon(1948 Points)  {5916FA4A-2FF3-4F22-8933-45454E5…  {46F8CA5D-6D14-46E1-B46C-DEB66FB…  real         nein     8782        0
 1765 │ Polygon(1933 Points)  {9054690A-CEDE-4611-93B4-7528CA1…  {655F26F6-7012-472C-96DD-BDA4178…  real         nein     8489        0
 1766 │ Polygon(689 Points)   {5F10A074-3DA6-4070-B4F9-963B5C5…  {BB989875-6BC4-4565-A793-2FAEED2…  real         nein     8362        0
 1767 │ Polygon(620 Points)   {89BBA994-3B9F-4D75-8C6C-B3C4781…  {DB028E8F-E9E3-4E0B-A9C7-15B43E2…  real         nein     9606        0
 1768 │ Polygon(482 Points)   {3D22197B-0200-4854-88EB-050BA23…  {F6929550-115F-49F4-9243-E7E8ECC…  real         nein     6205        0
 1769 │ Polygon(331 Points)   {0C73AE78-B3EB-4B98-8CAA-BD560BF…  {89DD9481-7D2E-45FD-9D36-C04898B…  real         nein     2576        0
 1770 │ Polygon(522 Points)   {AD34D199-9208-4893-8678-9EEA423…  {ABA8AF47-FFB6-43B0-B8F4-03B9767…  real         nein     5704        0
 1771 │ Polygon(413 Points)   {E94BD615-4670-4401-BA7A-4A3D7A9…  {B30F0AEF-365A-4EFE-92F0-AECC2D6…  real         nein     4413        0
 1772 │ Polygon(412 Points)   {542337D0-B4FD-4F20-9BBC-D242B8F…  {3AF4F5CF-3280-4C32-BEBF-214B770…  real         nein     2912        2
 1773 │ Polygon(908 Points)   {4AA9ABA1-E13A-4E26-8485-9A209D2…  {90CBA614-A1C0-4BAA-A9E5-54D3481…  real         nein     8626        0
 1774 │ Polygon(374 Points)   {0CF34A1D-9EA2-44D3-BB14-08DA792…  {1B461A8E-210D-4720-87BB-D6F6F05…  real         nein     2515        0
 1775 │ Polygon(751 Points)   {05F61B83-22E5-45B6-8575-144B206…  {F3724480-E25D-4DC0-A537-703352F…  real         nein     1308        0
 1776 │ Polygon(597 Points)   {4FAF16C9-7041-4BA9-9ECE-E055D75…  {72C6E347-8293-4D2A-B912-CC27E9B…  real         nein     5027        0
 1777 │ Polygon(185 Points)   {BA2654ED-9C2E-4F00-B768-8F2F68C…  {2A293CCE-D34F-4C8B-9516-ED489EF…  real         nein     2922        0
 1778 │ Polygon(209 Points)   {2E4C36BA-CEB5-4CAA-82DD-CBD3675…  {B5E862FA-252B-474A-93CC-66F5706…  real         nein     6721        0
 1779 │ Polygon(814 Points)   {DD0E3529-5626-417C-A34E-F23608B…  {F1C5214C-843D-48F6-AAC4-A85053A…  real         nein     8756        0
 1780 │ Polygon(605 Points)   {5AD56811-E24C-49AF-8E6F-21A7E4D…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8046        0
 1781 │ Polygon(703 Points)   {EEE8250B-0A6B-4E2F-B3BA-AE09B70…  {262F78F3-5B19-421D-877E-B9428BE…  real         nein     4932        0
 1782 │ Polygon(395 Points)   {4638DC65-F73C-40E9-AC13-51B609A…  {A766F01D-C22A-4D70-BD91-5CD9917…  real         nein     1696        0
 1783 │ Polygon(740 Points)   {75DFC50F-52B0-4E7B-A557-E41E554…  {2E91DB08-2C42-4F1C-BDDC-DF75223…  real         nein     6005        0
 1784 │ Polygon(414 Points)   {0958413C-0478-42B6-A274-5B7EDDE…  {8CE99ED9-79A3-4B98-81E3-12E5356…  real         nein     3216        0
 1785 │ Polygon(317 Points)   {A62E4FD8-6AD4-4B1E-861D-E3946BA…  {E6CE8606-612F-496A-92A9-CDCA0FE…  real         nein     6123        0
 1786 │ Polygon(518 Points)   {50309F94-E21D-480E-954B-74BCF24…  {41217311-3E76-4CA9-8D46-F23A07A…  real         nein     2065        0
 1787 │ Polygon(315 Points)   {C6C8F030-0011-4238-9299-25A09FD…  {4D6893DB-705A-48C8-A23C-E1F60A7…  real         nein     2316        2
 1788 │ Polygon(787 Points)   {F2C5C18B-0E09-4B10-98C0-3D3C926…  {8B41A048-DF62-48D4-AFBC-4C3D366…  real         nein     1535        0
 1789 │ Polygon(507 Points)   {0719AD11-0C03-4214-843F-C22EF0C…  {E4D21520-7839-4309-8AD4-642058D…  real         nein     1324        0
 1790 │ Polygon(138 Points)   {C4140303-5D4E-44FE-89C0-7A6EF3D…  {040DBE51-52C4-4C10-96E2-E048572…  real         nein     7314        0
 1791 │ Polygon(786 Points)   {4749723C-9FCD-476C-ADC6-C4806F6…  {2ABFDDDC-7FF2-4042-A273-2A71534…  real         nein     8618        0
 1792 │ Polygon(415 Points)   {F951A991-BBED-44C5-9D10-CF64563…  {F43772A9-DBFC-4A56-95B8-74FB8C3…  real         nein     6217        0
 1793 │ Polygon(112 Points)   {C4F12994-AD72-46DA-9310-F3C0A14…  {36087C41-5DE4-4604-9C42-CC87576…  real         nein     7220        0
 1794 │ Polygon(515 Points)   {B0450545-541B-46EE-8246-E8B26F4…  {5D93943A-2078-4071-9CA4-C57E85E…  real         nein     1732        0
 1795 │ Polygon(1228 Points)  {1A226F19-B132-406D-B362-1AB6411…  {83F51065-AB71-426A-B06F-E41E9CE…  real         nein     9030        0
 1796 │ Polygon(784 Points)   {8261B362-FA70-4380-9DFE-F8E4599…  {DA9E664E-A4C9-4AB0-A1CC-934AD41…  real         nein     3072        0
 1797 │ Polygon(358 Points)   {839A1BA7-387E-466A-A92F-8754EA2…  {82F95384-CB8C-4F8E-BB2A-E206C11…  real         nein     3308        0
 1798 │ Polygon(494 Points)   {025568B5-65BE-4ACF-948F-71A6947…  {4996E5ED-1BF0-4C76-B63B-2758746…  real         nein     3116        0
 1799 │ Polygon(652 Points)   {47E42430-086C-45B3-93C8-EA6B92B…  {DB6ECBFC-F1E4-42D1-AF4B-71BD2D8…  real         nein     3421        0
 1800 │ Polygon(224 Points)   {E2E84C2C-541C-45D4-8FC3-9228D2E…  {2705416E-1BE1-432F-BB7D-289AE6A…  real         nein     4434        0
 1801 │ Polygon(301 Points)   {DF0E7BDE-DDD1-4010-B1B9-C984B97…  {C432B81D-2F2A-446B-8E83-2951FED…  real         nein     8260        0
 1802 │ Polygon(583 Points)   {E07A0938-4FF0-4824-B66C-6B7B9C6…  {A3EFCE4C-632A-4E8E-87FF-41B3D79…  real         nein     6142        0
 1803 │ Polygon(927 Points)   {643B8925-480E-41F8-A702-C47633B…  {29C43675-F95D-442B-BF69-3E5F152…  real         nein     4515        1
 1804 │ Polygon(554 Points)   {9A6CA0E6-FA85-46F2-BBA1-AEC0148…  {347C696A-98A9-41E9-BFF7-612FE19…  real         nein     1197        0
 1805 │ Polygon(320 Points)   {481DF0E6-0C30-44D6-B03F-5B5AC96…  {866A79FA-2A87-47DE-AE52-A8324B6…  real         nein     8216        0
 1806 │ Polygon(573 Points)   {BED58231-A34B-48F0-BC0B-C566105…  {D3327484-7350-4E5E-9246-1258F37…  real         nein     3173        0
 1807 │ Polygon(747 Points)   {BC829F28-C3D2-43C9-BD15-AA1A88F…  {906B2434-A618-47F0-9992-509C173…  real         nein     8800        0
 1808 │ Polygon(149 Points)   {EBC982F1-422F-4731-A3C0-0FB6BD9…  {4E7CA77F-3D93-4BB5-90B5-5806559…  real         nein     1651        0
 1809 │ Polygon(116 Points)   {580163F8-3DFA-44F8-8621-6BE8316…  {3E067559-B06C-414E-A34A-D7B6D54…  real         nein     6611       17
 1810 │ Polygon(558 Points)   {067F3EF5-F829-48F2-AC35-8F008A2…  {B1CC115D-F28C-4FD6-8508-A1B42B4…  real         nein     1633        0
 1811 │ Polygon(280 Points)   {9848CD12-8B78-4DAF-A2EE-5B3D535…  {F15B9321-43DF-4364-A1B9-482A28C…  real         nein     1870        0
 1812 │ Polygon(406 Points)   {D1DA1198-E5E3-47F2-9CDC-41E3FAC…  {4718FB72-56B8-47A2-A558-E43F378…  real         nein     3438        0
 1813 │ Polygon(440 Points)   {46A14443-B40F-4B6F-B664-3441809…  {50FD7002-BAA4-45B2-A119-380EEA2…  real         nein     6246        0
 1814 │ Polygon(914 Points)   {1D8816A8-72F0-44AD-95FF-3906D91…  {9EE99FE7-0BA1-443A-9CD4-447CAE5…  real         nein     9050        5
 1815 │ Polygon(1143 Points)  {5D504ED0-85DB-401E-93A0-E2D5900…  {F11A57ED-EC6C-43B5-92AA-E405463…  real         nein     1323        0
 1816 │ Polygon(562 Points)   {6CB14561-F2E2-4CA8-9C84-36F95C5…  {A8338046-984D-4579-9396-F2DD340…  real         nein     9512        0
 1817 │ Polygon(397 Points)   {05EC176D-BFA2-4417-B948-6B7CA6A…  {C8E2FA7C-13A5-4D16-BB95-B42FBCB…  real         nein     5745        0
 1818 │ Polygon(518 Points)   {C5583B97-2ABE-4167-BAA5-6B1875A…  {F31382CC-375E-46F1-B43C-4FFED8D…  real         nein     4145        0
 1819 │ Polygon(576 Points)   {B441A513-19BB-4509-80B9-963261F…  {4CED1303-1E85-4359-9F9D-ACA7B86…  real         nein     5724        0
 1820 │ Polygon(281 Points)   {33D1CB36-B01D-4DF9-931B-5769B8E…  {714669D5-0971-42CE-A4F1-992E859…  real         nein     7512        0
 1821 │ Polygon(343 Points)   {D776A850-81CD-4E58-B85C-19E8B9D…  {4C75C0F6-F8B7-4551-A68D-1EA7D88…  real         nein     3415        1
 1822 │ Polygon(327 Points)   {B60F1741-A21B-4366-A828-F20B35F…  {FF4FBAC8-D430-43ED-95A5-804427B…  real         nein     4655        0
 1823 │ Polygon(273 Points)   {8FFD13D9-E289-4C4C-BAD2-2865328…  {DE876C3A-F1FA-4E16-9FEB-14BBF82…  real         nein     2714        2
 1824 │ Polygon(777 Points)   {340C8C29-EB7A-4828-B36B-4B00DD6…  {EF4387ED-D25A-48BC-95BD-EA57CF3…  real         nein     6723        0
 1825 │ Polygon(249 Points)   {451B9641-27F6-4AEB-8C4A-0BE222A…  {B2061153-BA18-4377-A87E-AAB136F…  real         nein     3758        0
 1826 │ Polygon(448 Points)   {473C6426-8018-442A-9414-11F03D9…  {CC7A6C0A-76D0-4386-95A8-E52BAF0…  real         nein     3312        0
 1827 │ Polygon(843 Points)   {A4241C83-DF92-4F12-9240-85AC391…  {91CEDD80-DC15-46FF-B8B3-DCD9808…  real         nein     1162        0
 1828 │ Polygon(405 Points)   {3BD39698-7B3E-4CBE-96E1-6E3B669…  {B49E7CF5-6C2B-4376-92E3-2EBF5BB…  real         nein     8716        0
 1829 │ Polygon(376 Points)   {273446F7-7C54-4661-A31C-CDA3B30…  {B8A901CB-4821-42FF-AD4F-90363CD…  real         nein     4493        0
 1830 │ Polygon(502 Points)   {40220C67-9BA1-4AF7-A82D-5F45698…  {FD4ADD3F-4F78-4BF9-AE92-D59B973…  real         nein     2057        0
 1831 │ Polygon(306 Points)   {6BA35D8A-C206-4230-9A5E-165F4C7…  {4B6D5425-7434-467E-9944-D2630FC…  real         nein     8526        0
 1832 │ Polygon(830 Points)   {1EBD4381-73A5-42C8-8F6E-4266CBB…  {B6290B76-A071-4EDB-9BF0-3562876…  real         nein     1742        0
 1833 │ Polygon(136 Points)   {0A50750C-0F67-4BC4-905C-25AE5C7…  {7DD49231-45ED-4B5D-AD36-B3924EC…  real         nein     7515        0
 1834 │ Polygon(1510 Points)  {332F6A09-9DCC-4D84-9108-DA9270F…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8053        0
 1835 │ Polygon(370 Points)   {B348AE41-2435-4467-8B32-E6E98F8…  {E3AEA0D9-8CDC-45CC-81D1-72B0FD8…  real         nein     5642        0
 1836 │ Polygon(1264 Points)  {D33D2B6D-E952-42D1-8026-C75E4E1…  {D9A7A184-75CD-4875-9077-2945475…  real         nein     8493        0
 1837 │ Polygon(260 Points)   {CAE7E012-B37D-4B97-B4E1-1376C66…  {FB730214-BEDE-45CE-AFE4-AD63B9C…  real         nein     3939        0
 1838 │ Polygon(385 Points)   {70D5461F-BBC9-4C3C-AD9D-411EAB3…  {EE0A1782-1946-4169-A4DD-A3945B8…  real         nein     6826        0
 1839 │ Polygon(545 Points)   {6791AE79-4564-4738-AFED-689FA0D…  {A6628FA1-DD07-48E0-A677-C604A36…  real         nein     1073        2
 1840 │ Polygon(317 Points)   {A43959DD-7F76-43AB-BD31-A1087A9…  {0F08FE5C-6650-4A14-AC4F-D8B07A0…  real         nein     1684        0
 1841 │ Polygon(276 Points)   {F1963FC3-09A2-47DF-B6B0-C0FEF18…  {0ABC2D05-BCFB-4F25-965C-092541C…  real         nein     6662        0
 1842 │ Polygon(375 Points)   {CA741C97-6F7D-42B4-88ED-2B1485A…  {1DB09805-C553-45BE-A9C3-8D62EFE…  real         nein     4922        2
 1843 │ Polygon(518 Points)   {46A0DED9-8E7E-46DE-B3EE-0B91341…  {6D0AE507-2594-46AB-AAA7-D8511DE…  real         nein     5213        0
 1844 │ Polygon(237 Points)   {21B46A7B-E04F-4C42-9DA4-2DC5B0A…  {75D843F2-EC32-4772-8AD8-F555BE3…  real         nein     3989        3
 1845 │ Polygon(1008 Points)  {DDD87964-1BBE-48AE-95D2-8317B5E…  {328D94A1-DF72-4574-A533-A4CAC9B…  real         nein     8442        0
 1846 │ Polygon(641 Points)   {4DD4E855-8402-48D1-A8EC-54623F0…  {55D4AC72-CF4A-42F1-B9AC-07CA052…  real         nein     1617        0
 1847 │ Polygon(391 Points)   {A71A9FD2-B40F-46FD-82E5-AECA42E…  {2BE0A65F-DEB3-4B0D-AAB1-D174FE0…  real         nein     3315        0
 1848 │ Polygon(578 Points)   {DB7B88FF-7FB2-4D10-A329-1C3BEBD…  {778923CF-396B-4203-A39B-AC04AC0…  real         nein     2502        0
 1849 │ Polygon(285 Points)   {0592FB13-36E1-40B7-980D-DC862BA…  {2747119D-58DA-4006-976E-A70CC2E…  real         nein     6742        0
 1850 │ Polygon(360 Points)   {82819918-9307-4091-A2EE-C49C76A…  {17E8DA82-7DAF-460E-88A4-90A2AEB…  real         nein     7115        0
 1851 │ Polygon(115 Points)   {3E0B24BC-8597-456B-A16E-39F422B…  {8828A903-46DE-4CB4-87E3-9C4B1CC…  real         nein     8574        3
 1852 │ Polygon(730 Points)   {BE0A9DD0-69C4-44A0-AFB4-039FC79…  {7675529D-8475-49EB-AB42-E43A707…  real         nein     1377        0
 1853 │ Polygon(1184 Points)  {36894255-6496-4E9E-96E8-BB1861D…  {A6D1BAB5-86CA-4622-A2E6-3B7952C…  real         nein     8314        0
 1854 │ Polygon(745 Points)   {97E2F54D-3B5F-4485-BBD5-B0887FF…  {D4074EC1-2741-4537-89D4-44E04EB…  real         nein     8157        0
 1855 │ Polygon(841 Points)   {C3DAF248-F36B-4C02-B7AD-2A5549A…  {E20D9B75-C5E3-43C9-9627-F5EA3B2…  real         nein     8182        0
 1856 │ Polygon(347 Points)   {E51D9400-751B-4FF1-9E38-A283F40…  {14A543D6-D13C-4C92-A567-071E324…  real         nein     2338        0
 1857 │ Polygon(507 Points)   {995C58C6-9E01-4677-81CE-4D627D7…  {6BCD0B04-FA30-46E7-B3DF-D086C4C…  real         nein     8962        0
 1858 │ Polygon(941 Points)   {E422435F-6D0C-46BE-AA95-30FB61C…  {27BC785B-681D-472A-A019-928F733…  real         nein     9308        0
 1859 │ Polygon(679 Points)   {F95EEFCF-CBA1-4B1B-852E-2027FF7…  {20B60331-01B3-416D-8A2C-4477A6E…  real         nein     8107        0
 1860 │ Polygon(1223 Points)  {EB2E3CE4-6655-41B2-B69B-F92DA95…  {52E9A93A-B8AD-4BA7-9212-D2951A6…  real         nein     8132        0
 1861 │ Polygon(1212 Points)  {5E1FB31D-3F7A-4967-ACF0-2D4C01F…  {77618414-3A7F-4E1B-9257-8B46C21…  real         nein     4412        0
 1862 │ Polygon(190 Points)   {25FD8059-3401-421B-A385-7F07285…  {32DDFAE1-751A-4664-A00F-4BCE713…  real         nein     8239        0
 1863 │ Polygon(717 Points)   {2B4D6BD2-D211-4C4A-BFD2-7678884…  {7B80215D-92B9-45D3-851A-6DE0DF1…  real         nein     8360        0
 1864 │ Polygon(756 Points)   {83F13990-531C-41D9-B720-3DC9C0F…  {4A6F3828-E135-494A-81CF-E3BF7BD…  real         nein     5057        0
 1865 │ Polygon(194 Points)   {53017954-00B2-4B03-8EDA-3AFB1E8…  {6F4F7813-D940-4BFF-9877-F2AE9A4…  real         nein     3983        2
 1866 │ Polygon(597 Points)   {2ED31AC3-1A9F-442C-823A-D92ACCE…  {8749D578-99FF-4F75-9A6D-7422460…  real         nein     1312        0
 1867 │ Polygon(690 Points)   {1EA55519-BB0F-4954-A8C3-21C7622…  {3D4E45C1-29FD-46D8-9471-9B9360F…  real         nein     3623        0
 1868 │ Polygon(678 Points)   {6FE3A49C-3EAF-44FE-A8D4-AD421E9…  {BDE5D00C-89CD-4934-A752-3FF6EC7…  real         nein     5732        0
 1869 │ Polygon(430 Points)   {92C603EA-8AA6-4E74-9D7F-DDF1375…  {FC94D812-F4E9-4B43-B6EF-9C32957…  real         nein     2924        0
 1870 │ Polygon(150 Points)   {26648B1E-48E5-4111-9972-CFB42D3…  {36399CEF-1147-4157-A01F-9D40AD1…  real         nein     1904        0
 1871 │ Polygon(5130 Points)  {4E99E243-6AF4-4167-A82A-2735EB6…  {1AC6A720-9CA2-40C0-9ACB-A971627…  real         nein     4436        0
 1872 │ Polygon(759 Points)   {386A5897-7062-46A9-BB35-DBD8AE5…  {B536C713-981B-4BAB-A189-BB73E2D…  real         nein     4143        0
 1873 │ Polygon(526 Points)   {00BD3B96-447D-4046-B0FD-5E0F27F…  {756037CC-376B-4925-A1FE-CF04B7C…  real         nein     8370        0
 1874 │ Polygon(263 Points)   {E0386319-5E80-4203-894D-CC977B5…  {8F508CAF-78DB-4521-B03F-3F56725…  real         nein     8583        0
 1875 │ Polygon(555 Points)   {4F819D8E-8DCC-4AF8-89B4-6804CC4…  {D4959081-4014-46AC-AC4D-2D9DE31…  real         nein     5467        0
 1876 │ Polygon(380 Points)   {38C3AF13-AC40-4633-BC43-55F4974…  {F2FFE015-C600-47FA-8C85-8D3E7C4…  real         nein     5712        0
 1877 │ Polygon(145 Points)   {4B8CDE08-923D-4BD1-9FD6-2150B28…  {5904BF66-469E-4541-A04D-033FA72…  real         nein     6474        0
 1878 │ Polygon(576 Points)   {2B7A505A-7D19-4D6F-8A57-0385F34…  {734D7ACF-031D-4419-8436-A1F3496…  real         nein     1801        0
 1879 │ Polygon(389 Points)   {051E304D-8D62-420F-9253-F1EDD4B…  {35FE358D-231B-440C-931E-CE79E75…  real         nein     6937        0
 1880 │ Polygon(754 Points)   {983C07CE-8608-474A-9070-BBB2E90…  {C933E451-AF7A-41AF-BA00-464D626…  real         nein     1270        0
 1881 │ Polygon(334 Points)   {6FEB0E90-0FDC-4DEE-B740-211CDB9…  {9CBF7A6F-24D8-4EBF-A00B-D184F11…  real         nein     2538        0
 1882 │ Polygon(566 Points)   {1D03D0EE-8E0F-4D50-974E-1E92611…  {A3BE0A80-B5AA-4A28-9E2E-4E6215C…  real         nein     6012        0
 1883 │ Polygon(835 Points)   {770D0E0C-C8A1-41BF-B088-4A4E2F8…  {7084803A-7907-4937-B3E0-8CE9278…  real         nein     1416        0
 1884 │ Polygon(178 Points)   {BD6135E8-25D2-4E6D-8B00-E9BF1C9…  {406ECA6E-13F8-4FE7-91DB-6595A79…  real         nein     3903        1
 1885 │ Polygon(585 Points)   {68CCAA1D-E531-43F1-984E-B1D52BA…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8044        0
 1886 │ Polygon(277 Points)   {5694D4E2-8B18-4587-B5F8-4A439E4…  {7E278A4F-20E8-4FB9-A0B0-5C7CBAB…  real         nein     2723        0
 1887 │ Polygon(348 Points)   {04AF2010-D9E1-4EAC-A633-0402AD7…  {C768F9D6-3982-4DC8-A954-FC0A10B…  real         nein     4514        0
 1888 │ Polygon(1241 Points)  {FE753280-893A-4884-B2B9-26DE151…  {D5B8A1E1-B95A-4BAA-98FE-99FCFCE…  real         nein     1032        0
 1889 │ Polygon(557 Points)   {4B2D453E-E4E2-43B0-A4BA-56BF5C9…  {2473A42C-B767-40AC-B830-4509FFC…  real         nein     1536        0
 1890 │ Polygon(650 Points)   {4DF2D02E-3349-4FDA-B93A-91C0A09…  {7A92BEBD-D347-457D-9E37-A980E57…  real         nein     3368        0
 1891 │ Polygon(843 Points)   {02C8F45C-DDCD-4E2C-BFDE-BEB2218…  {CBBB4A67-B978-4E75-9D0B-E9BF760…  real         nein     8248        0
 1892 │ Polygon(88 Points)    {15B3CE1E-30E8-4403-9F3C-964D776…  {7A85044C-D1EC-45CD-A63B-87E0CDA…  real         nein     1928        0
 1893 │ Polygon(346 Points)   {8899B7DC-2DF6-4CD7-8D56-3136222…  {705CB726-EB8C-4AC1-8580-FED88B3…  real         nein     8916        0
 1894 │ Polygon(334 Points)   {2FEFDB39-FC54-4FC9-968B-99616D3…  {5E6F3ACF-EDE9-4D55-B227-54E8720…  real         nein     6838        2
 1895 │ Polygon(166 Points)   {27259D57-BCC7-47B5-A5BD-BAD3863…  {61795A10-34AC-4E78-A957-6FABEDF…  real         nein     1871        2
 1896 │ Polygon(286 Points)   {5C5F31BD-0EEC-470D-9A1F-120A92B…  {C9D2CCCF-B51A-43A9-A179-DD714BF…  real         nein     5105        0
 1897 │ Polygon(426 Points)   {6E555219-314E-4DD6-AD02-CACFFFA…  {D2D39FB4-341E-4F7E-9B5E-838D2D8…  real         nein     2735        2
 1898 │ Polygon(765 Points)   {AA445604-5BF5-432A-BEB9-89FE83C…  {305CD817-3A29-4E98-8BB5-7BE3438…  real         nein     8165        3
 1899 │ Polygon(1445 Points)  {889542C6-89C1-4DFC-91C0-D3E3E0E…  {16AA110A-BE52-460F-B93B-D80D28C…  real         nein     1375        0
 1900 │ Polygon(557 Points)   {9CB1F473-3CA9-4E22-83E7-CD70BCA…  {994E9561-88F3-4AC9-B45D-85D7151…  real         nein     1117        0
 1901 │ Polygon(414 Points)   {AE9805EB-BE6F-4DDA-B33B-0599469…  {C218EDF6-1CEB-49F5-8DE9-5B81738…  real         nein     6294        0
 1902 │ Polygon(429 Points)   {7A3FBD42-E75F-4FE0-AC08-6B13D65…  {31DF64E2-9602-4EF7-A5F5-37A469E…  real         nein     2716        0
 1903 │ Polygon(323 Points)   {7DA2130F-7853-4843-B3EA-44B16CF…  {44B19705-4481-4D7B-AEC8-407ED5E…  real         nein     7451        0
 1904 │ Polygon(187 Points)   {B6AA7C26-D8A5-4AC1-ADF1-6D3AEB1…  {B7F357C4-D908-42B8-B645-6FC049A…  real         nein     6781        1
 1905 │ Polygon(404 Points)   {8C8AEA14-1BCB-4784-9C9C-D2AD1CE…  {33283AA4-67D6-46CE-A022-22CEE20…  real         nein     7143        0
 1906 │ Polygon(649 Points)   {5CC85490-F59C-45E0-A23F-EB7B037…  {0BE2714B-1CFF-4A28-B657-1D8B5BA…  real         nein     4552        0
 1907 │ Polygon(194 Points)   {EA2177B7-2BA8-4AAA-B91E-9A51618…  {EC07BF4C-EDE0-4359-A454-F5519A6…  real         nein     2607        0
 1908 │ Polygon(483 Points)   {CADA8FCA-D20C-4108-8CD0-EEF4884…  {C2630849-90DA-4E4B-A42C-EF06427…  real         nein     1438        0
 1909 │ Polygon(640 Points)   {5FB90176-1D36-48FE-9BDD-963F365…  {A61620F1-8E90-4EF9-8D25-8B00656…  real         nein     8463        0
 1910 │ Polygon(533 Points)   {42892280-2C12-4AB4-93A6-7151892…  {EA072E97-42D8-4D4E-A437-5FE3603…  real         nein     8572        0
 1911 │ Polygon(401 Points)   {56335104-305F-44B9-B8C3-2D55EEF…  {ABECC4D5-3AE8-4A71-AF99-DD63B24…  real         nein     2933        2
 1912 │ Polygon(293 Points)   {94D8D476-A592-46F3-A5A6-F6B87B5…  {208E6192-BED3-4971-8DD7-109431A…  real         nein     8888        0
 1913 │ Polygon(299 Points)   {5E90B1B8-C460-471C-A13E-F8F3178…  {075FBB25-05C8-4BE3-865A-DC6F812…  real         nein     1425        0
 1914 │ Polygon(435 Points)   {59D78168-0D7A-4A68-BE03-8D8D63B…  {1E849873-87F0-46EC-842C-FDC16D7…  real         nein     3302        0
 1915 │ Polygon(955 Points)   {1765FD23-7679-4028-8D56-40733B2…  {F89E034F-E195-4A16-806A-3036FAB…  real         nein     8486        0
 1916 │ Polygon(441 Points)   {A0C94737-49F8-41C5-804B-B586234…  {3A109650-8111-4508-973D-9C12008…  real         nein     9507        0
 1917 │ Polygon(130 Points)   {C8E197C7-FFB2-48CD-8C4C-DA1504A…  {4308CF1A-9ED2-4B63-9D47-324918C…  real         nein     6612        0
 1918 │ Polygon(526 Points)   {BE4E1A0A-AAB3-42C2-AEF9-1D6061E…  {DEB678E1-6B0E-44B9-BA23-1FE12D1…  real         nein     6037        0
 1919 │ Polygon(282 Points)   {7A4A3DC5-5CB4-42C6-A8FF-CE615B1…  {E53489C3-BE14-4B63-A79C-652BBE0…  real         nein     2553        0
 1920 │ Polygon(860 Points)   {8D74DE5A-6B65-4596-B2F0-2F33C15…  {06FAACD8-CD04-4A0E-ACAE-572A15C…  real         nein     1405        0
 1921 │ Polygon(605 Points)   {D0BED1EF-426C-41C5-9E66-47FC6D6…  {DEC293E2-C7F3-437C-A7A4-A3DE8F7…  real         nein     6332        0
 1922 │ Polygon(498 Points)   {259F4C80-D075-4E24-B3D7-079592B…  {E32BF850-CFEA-497B-95F7-9B0CC46…  real         nein     1731        0
 1923 │ Polygon(875 Points)   {538E036E-6CC4-4D36-850E-B4F75B5…  {A7372E87-5290-4526-8A18-C09342D…  real         nein     6438        0
 1924 │ Polygon(224 Points)   {79220948-F497-4D47-853B-F408EDC…  {F9862221-24E2-4182-95FE-FB7D223…  real         nein     4853        2
 1925 │ Polygon(517 Points)   {F4E03CA4-78C8-406D-9F3F-22C1ED9…  {3562499C-F117-4C6E-A562-D3E888E…  real         nein     1486        0
 1926 │ Polygon(652 Points)   {A61B51C9-E723-4ACC-B675-CF9C53E…  {3CFE0DBC-1616-4CFE-B1C5-3301C43…  real         nein     9524        0
 1927 │ Polygon(803 Points)   {29F5EC91-B88C-433A-9DD7-BD63F06…  {7DA887E8-99E7-48C4-9FBE-691354F…  real         nein     8426        0
 1928 │ Polygon(508 Points)   {9A3D4434-6D43-4457-BD51-2A19A6A…  {53C0C7F0-7219-4825-9FE3-F93CAD5…  real         nein     8602        0
 1929 │ Polygon(647 Points)   {6CFDA772-9A63-49A4-A13A-73CA168…  {D0F7EA40-9219-475D-8592-E2CC9B5…  real         nein     8702        0
 1930 │ Polygon(171 Points)   {21702C07-DDC4-4C11-9A50-791A3D3…  {81827115-D905-4348-BAFD-9588165…  real         nein     4415        0
 1931 │ Polygon(554 Points)   {577C3CEA-E8FA-4E94-AC2A-99EEF23…  {E87202A8-3352-44EA-A0FC-CB6EE62…  real         nein     1228        0
 1932 │ Polygon(1005 Points)  {8AE17215-800A-4A62-9504-0B8CFD9…  {3D1A7A41-D6DD-4E82-8CFE-C6C5496…  real         nein     9322        0
 1933 │ Polygon(706 Points)   {AEEF6F73-79DA-49DC-BB6F-6C9F98E…  {BDCE55B4-92F6-46F3-9239-97D0514…  real         nein     6960        0
 1934 │ Polygon(369 Points)   {8E47A868-977B-4151-ABF3-938B580…  {C43BFE5A-10E2-4017-89C9-66C0179…  real         nein     3212        0
 1935 │ Polygon(476 Points)   {C1448FDD-F571-4990-9A7B-9C9F9BF…  {01FAE7B9-6F12-4B0D-AD84-E8E3568…  real         nein     1773        0
 1936 │ Polygon(670 Points)   {3711CFD4-56BC-4CDB-9E27-4CE4C4E…  {87201CEE-3711-4DAF-87F9-89A0194…  real         nein     3625        0
 1937 │ Polygon(683 Points)   {8A0215A6-C227-4400-AC21-B92B096…  {0E2A353D-436E-4F1A-8BE0-C4C7000…  real         nein     5200        0
 1938 │ Polygon(203 Points)   {21A265AB-CFE5-42E0-8823-7EBEC30…  {43FDB7D4-7381-4881-949B-BCB9A55…  real         nein     2827        2
 1939 │ Polygon(205 Points)   {7AAB3DC2-3C31-42CB-94A9-F9CF961…  {2615F291-4C3D-4281-AEA6-7EFDB4D…  real         nein     2615        2
 1940 │ Polygon(720 Points)   {C2F29F16-74EE-4987-A685-BFC46B5…  {0B38EEF3-33DE-4A00-A5E0-06AFB02…  real         nein     8458        0
 1941 │ Polygon(444 Points)   {00896554-56B9-4EC4-910F-1C4FD4A…  {91557D6B-022E-4835-BA56-9C487D0…  real         nein     3503        0
 1942 │ Polygon(634 Points)   {C52B01DE-F856-4649-BCC2-8417E2B…  {D0338E3D-04AC-4D67-B6FD-CF6B1D4…  real         nein     8580        7
 1943 │ Polygon(368 Points)   {3A0D23B3-EFCC-4674-A206-86485DC…  {41D349A1-3E73-4A7E-883F-1DE0DD9…  real         nein     4953        0
 1944 │ Polygon(659 Points)   {A090EAE4-74AC-48B2-97FB-1128FC1…  {0D45B4A0-7F27-4BFD-ABD4-261F2FE…  real         nein     2813        0
 1945 │ Polygon(1048 Points)  {7A91F8B7-E4CB-4772-9B49-33EA07A…  {0A97E1F8-DF5F-433F-B2F4-F17171D…  real         nein     1306        0
 1946 │ Polygon(461 Points)   {F3008549-C944-4A05-8757-9426D1C…  {9D32D2FF-BAD7-46DF-9A1F-BDF2CA8…  real         nein     5318        0
 1947 │ Polygon(525 Points)   {5FC12BE5-FACB-455A-9E6A-95F1304…  {5B3EED66-C114-48A9-93E0-016D458…  real         nein     6821        0
 1948 │ Polygon(451 Points)   {9C109BEF-2037-46FC-AB3C-9B1DEB2…  {7AFB2EE4-55FD-4D69-858C-035775C…  real         nein     5708        0
 1949 │ Polygon(600 Points)   {754DFBAF-44A0-449B-A9C2-7159DEF…  {DFC55E78-15F4-4606-AA42-C9E018C…  real         nein     1740        0
 1950 │ Polygon(354 Points)   {D6849FCE-6302-474A-835A-CE2F251…  {DED30784-694A-4369-85C6-159BC02…  real         nein     8575        0
 1951 │ Polygon(269 Points)   {5FB20175-D0A6-4F0B-9F3B-DFE09BC…  {B684548C-19D2-4B21-BD33-63A26C4…  real         nein     3816        1
 1952 │ Polygon(879 Points)   {C71A6DD0-DBA4-4EF6-BA82-7400F2E…  {5A1203B8-3621-48C1-AD1A-C5FC056…  real         nein     1084        0
 1953 │ Polygon(355 Points)   {8616F2FF-673C-4A9E-A4D9-06E5DE5…  {EF7F68B3-00B0-49F0-B68F-F19E5E0…  real         nein     1649        0
 1954 │ Polygon(677 Points)   {FAACE75C-7307-40A5-8683-EBD72E0…  {32264208-A9F7-4BD0-8199-5A415CE…  real         nein     5462        0
 1955 │ Polygon(222 Points)   {34C72868-0AAD-42F8-B09A-AD6817F…  {6EF5CEE4-242E-4CEF-AB93-5EC2B68…  real         nein     2577        0
 1956 │ Polygon(196 Points)   {DC2CB05A-F832-444D-AA46-594D6C0…  {18387A08-56AB-495E-B591-9CA1D3D…  real         nein     4624        0
 1957 │ Polygon(215 Points)   {D5C8164C-4694-427C-865C-E09B62D…  {A2963A84-4222-4D68-B7A0-7681534…  real         nein     4626        0
 1958 │ Polygon(512 Points)   {4818C42D-056F-4815-A1F6-7CEC3D6…  {6533C375-AB42-41BA-900E-40391B4…  real         nein     7130        0
 1959 │ Polygon(572 Points)   {4E95761A-509E-47C9-8613-CFED779…  {D3BA8890-FFCD-410E-99E2-3211FF6…  real         nein     8455        0
 1960 │ Polygon(486 Points)   {67958CEC-3001-44EB-9A41-04C8F42…  {F1CB26CF-9D44-4DE1-AD16-5B2DB0F…  real         nein     1892        0
 1961 │ Polygon(232 Points)   {9286715B-D8E7-4565-89D9-75026AF…  {E5423A21-CED0-4496-BD0D-DFCE959…  real         nein     3632        2
 1962 │ Polygon(762 Points)   {C8ACAB9C-4028-4787-9966-62AD58A…  {5B73E025-CA67-4088-AE65-A1CAFE8…  real         nein     1415        0
 1963 │ Polygon(646 Points)   {43E6AD1C-6C6A-4057-A0C9-04467BF…  {119AB990-B3E9-4257-9874-D59852E…  real         nein     1284        0
 1964 │ Polygon(1448 Points)  {742A1483-BF37-4B95-8F1B-6740F29…  {161BA1B6-540D-411D-AD37-633AA83…  real         nein     1374        0
 1965 │ Polygon(568 Points)   {8BFB400F-49B5-4363-B7B6-1F4751B…  {4D956253-38E7-489E-8644-80907D9…  real         nein     8173        0
 1966 │ Polygon(1054 Points)  {0F70FCD3-CA08-49B2-8775-751AE0F…  {D839FEBB-634F-4856-A9E2-DFE0160…  real         nein     8126        0
 1967 │ Polygon(420 Points)   {7F810AAD-B1C2-42A8-BA10-33A4F1C…  {5051C8FF-2D53-4D41-97C7-0CDD788…  real         nein     1752        0
 1968 │ Polygon(323 Points)   {E8F448BA-6011-4D4A-90AE-3615F9D…  {A7C99AF9-9B67-4F70-A744-CCB6DFB…  real         nein     6654        0
 1969 │ Polygon(503 Points)   {07C56B3A-FF0D-408C-9940-6CA6053…  {83130E87-DBC9-413B-8676-373EE93…  real         nein     6313        2
 1970 │ Polygon(444 Points)   {ABA0D64C-31F6-407C-A047-52D6A64…  {4F612E96-B02A-45FC-8914-6F557A6…  real         nein     1352        0
 1971 │ Polygon(308 Points)   {84366793-D348-4D9D-B684-284C16E…  {92161644-2402-43D2-9F24-6EDFA37…  real         nein     3365        0
 1972 │ Polygon(246 Points)   {9188D539-D315-4B4F-B870-9DFFB9F…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3019        0
 1973 │ Polygon(158 Points)   {D326D3A6-69D7-49D4-9A93-39911D6…  {96C71435-89CC-4470-AAE6-9AF2AF6…  real         nein     7019        0
 1974 │ Polygon(460 Points)   {57BB6341-EB9E-4412-A11D-40160F1…  {EC81569B-A45B-4A66-B420-D9C6A2C…  real         nein     1329        0
 1975 │ Polygon(469 Points)   {6B09D9BB-8F6D-437A-8C09-0055F27…  {E7981B40-FF61-435A-AA96-5E1589A…  real         nein     3124        0
 1976 │ Polygon(1143 Points)  {38C255B8-D296-4156-96B6-596C2E1…  {A6E3C7FF-24EB-4A14-A006-CB5F2EA…  real         nein     1124        0
 1977 │ Polygon(184 Points)   {C211F6AF-D23D-4679-87A6-E392C4E…  {56B51C92-BF79-4DA7-8D08-8021A7B…  real         nein     8135        3
 1978 │ Polygon(534 Points)   {760791E3-53A2-4181-85E8-BDC2379…  {0970D2C1-F372-443A-A37B-F8612F4…  real         nein     6344        0
 1979 │ Polygon(720 Points)   {81A149BE-CFE3-46B3-8595-38DC7D1…  {8E35FFD1-7808-43CF-A3DD-B06C1FF…  real         nein     9442        0
 1980 │ Polygon(409 Points)   {98513FDB-11A2-4F38-9B2A-BD77382…  {7FAA8FA1-BF12-45DF-95B6-941E138…  real         nein     3437        0
 1981 │ Polygon(508 Points)   {CDFF30AC-3D30-454A-8D78-F050453…  {4C827D15-D0B3-470B-8AA2-5086E9B…  real         nein     7027        0
 1982 │ Polygon(531 Points)   {1DE1ACD7-6BA3-4418-BC84-3BD0B98…  {3F28A034-ED2F-44D6-8037-95F0DC6…  real         nein     6233        0
 1983 │ Polygon(473 Points)   {10F4394D-5798-4554-996C-D2B70BE…  {85317763-67EA-4C28-AC10-E4E441E…  real         nein     3504        0
 1984 │ Polygon(1310 Points)  {3333B151-0785-4CE8-88DF-0709C0D…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9015        0
 1985 │ Polygon(743 Points)   {25CB668B-48EE-43AE-ABDD-D66DEB1…  {F4B8E44F-6F8E-4573-B728-BD76B52…  real         nein     1691        0
 1986 │ Polygon(251 Points)   {1F986957-2A82-4328-B029-8D1BD5A…  {C1278241-7B5B-4A66-B222-8855A98…  real         nein     3439        0
 1987 │ Polygon(505 Points)   {7E62B015-1069-4C1B-A690-F7DC4EE…  {E390D31A-44C2-41B8-987D-B8683B9…  real         nein     1772        0
 1988 │ Polygon(283 Points)   {614B934C-8C50-450F-95AE-868C8A4…  {2CF6DE26-0413-4BC1-ADFF-6AF3A8C…  real         nein     5432        0
 1989 │ Polygon(392 Points)   {83D2E6E2-6150-404C-BA79-936FFF0…  {9BA762DD-677B-4911-AF0A-CAE0BCB…  real         nein     5317        0
 1990 │ Polygon(614 Points)   {75C076D3-7189-4823-A291-A070836…  {FA2421C6-09FD-424B-983E-108E545…  real         nein     3532        0
 1991 │ Polygon(532 Points)   {26AA90D0-82CD-47A5-B4BA-F5D7DB4…  {733EC552-C595-4BF4-B175-C2D42DE…  real         nein     8965        0
 1992 │ Polygon(279 Points)   {7118A78C-C31B-4CFA-9269-5A8D023…  {F75E7CBD-008E-4207-BB0E-5F5BD82…  real         nein     1969        4
 1993 │ Polygon(364 Points)   {B3B2521D-48BD-4160-8928-B4E2019…  {A28FB61D-2501-4070-A7F6-073394F…  real         nein     2537        0
 1994 │ Polygon(195 Points)   {ED15B4DB-4C61-4617-8A18-CEECB04…  {80837B0C-985E-4616-B61C-994991A…  real         nein     4246        0
 1995 │ Polygon(484 Points)   {9F934616-B693-457E-B2F1-47D63F1…  {6172F1EA-D545-4725-8B6D-F1A74BB…  real         nein     3125        0
 1996 │ Polygon(108 Points)   {7077A96E-0F48-4658-B33C-9301198…  {AEFF5B78-452E-43EC-9AFE-F3BF858…  real         nein     4118        0
 1997 │ Polygon(572 Points)   {811B9B4D-948A-4B34-AE78-FC5A5ED…  {2CC0441F-EA85-4624-8DB5-A26832B…  real         nein     8966        0
 1998 │ Polygon(427 Points)   {AA0D9441-12D6-48E5-8BA7-340AED3…  {51077EDA-FCED-4E21-AF56-F8BBE12…  real         nein     9443        0
 1999 │ Polygon(1378 Points)  {CBC89BA9-6C36-4BEA-BDEB-3A509CE…  {C15F5A6E-FA89-4FD9-B30E-26CA167…  real         nein     6110        2
 2000 │ Polygon(393 Points)   {ACADAB7F-7B9F-43E8-9DB1-06F9E36…  {99029CE8-C79C-4981-A02A-5909BE6…  real         nein     3380        0
 2001 │ Polygon(137 Points)   {D48795C2-54B5-49BB-87BD-528CE91…  {1FCF62DE-F20A-47CB-B6D0-6513B47…  real         nein     3995        4
 2002 │ Polygon(1022 Points)  {1B030E0D-AB34-4A49-8D46-49D0A79…  {DE17FE53-7E70-45B1-B871-A708DED…  real         nein     1042        0
 2003 │ Polygon(971 Points)   {79BA64E3-EFD8-4325-A104-08BE090…  {E90BE35D-2B5B-42CC-A773-34F9CA7…  real         nein     6060        0
 2004 │ Polygon(197 Points)   {E4C85712-7A1A-4AA3-801E-81C2775…  {919BB6E4-64F4-4752-A0B3-5511A41…  real         nein     8885        0
 2005 │ Polygon(388 Points)   {DFD1D57A-6321-4C4A-AE6C-39759D7…  {83F23CF1-77F4-481A-BFE9-03FE2C0…  real         nein     1735        0
 2006 │ Polygon(547 Points)   {C575FE58-905C-4E0B-9469-D2C6C35…  {017E5C83-4C42-4C36-B1D7-1CB42C6…  real         nein     5033        0
 2007 │ Polygon(523 Points)   {ABEFA844-C2AF-4F11-A440-6522DC1…  {159263A8-8DC0-4C02-AD7D-1328594…  real         nein     1716        2
 2008 │ Polygon(219 Points)   {E49902B2-03D9-4E26-AD11-058B02D…  {4403ECDB-C99C-48E3-AB06-CFE1E47…  real         nein     2843        0
 2009 │ Polygon(582 Points)   {96B5BFD1-117E-4002-8029-32D0432…  {0ED0C906-E2A8-4E97-86E7-4DEF98F…  real         nein     1663        3
 2010 │ Polygon(305 Points)   {A3A0A4FC-CF2B-4EC4-A2DE-E951147…  {F656048E-2072-4256-8EAB-B92BCAF…  real         nein     5103        2
 2011 │ Polygon(252 Points)   {44A57F35-F226-40E2-AB79-F1C788D…  {E7F56EC2-B5B0-4583-819C-7E526EB…  real         nein     1728        0
 2012 │ Polygon(722 Points)   {3DBB1DE1-BCB5-4C5E-B98D-E1DD8EE…  {245FA856-D68D-4513-AB40-8A86AFB…  real         nein     1452        0
 2013 │ Polygon(229 Points)   {AB6B18B0-A3A6-4BCD-97DF-EB1F7A0…  {26D4D709-6103-44B7-89B9-E7F255E…  real         nein     4254        0
 2014 │ Polygon(93 Points)    {E713F8D4-C7DD-4E2A-A099-A7C54D4…  {A4B84B5C-32F1-4EE9-B010-46D87F4…  real         nein     7077        0
 2015 │ Polygon(110 Points)   {F3E88A0D-03F1-4260-9783-041A4D6…  {52077D94-058D-4BB6-9297-1D30CBD…  real         nein     9451        0
 2016 │ Polygon(540 Points)   {C5D10E2E-2987-4C1A-B801-4E34FB5…  {A56D88E7-E3B4-4A3C-AA95-26EA1A0…  real         nein     6575        1
 2017 │ Polygon(267 Points)   {95584A06-02F2-4A07-8116-1DF9CB7…  {28ADCC21-F7CD-473B-B957-4232B78…  real         nein     5106        0
 2018 │ Polygon(682 Points)   {47D2C40A-D4D7-4FD3-9047-E05C19D…  {B587414F-7985-42AB-B4CD-879C986…  real         nein     1302        0
 2019 │ Polygon(1271 Points)  {278CB113-2603-404E-B989-39251C0…  {73B00532-67F9-4547-A0E1-8DE7C1B…  real         nein     8105        2
 2020 │ Polygon(590 Points)   {DAB0540C-9E9C-4F8B-B2C7-CAFFDBC…  {5919B8C5-DBD8-4A55-B67E-87CA363…  real         nein     1429        0
 2021 │ Polygon(655 Points)   {C4480AEE-DA75-4EC9-A72D-D63C660…  {835BB51A-38BA-4DB9-843B-FA8AED0…  real         nein     1114        0
 2022 │ Polygon(533 Points)   {9810E470-F66F-4741-98C4-2C790ED…  {D5F28B46-491E-4E06-81AD-B066974…  real         nein     6382        0
 2023 │ Polygon(500 Points)   {4C9B16D5-2D03-4010-A0E5-1ECEA95…  {EC85E9CE-6542-46B4-A0A0-147AAE9…  real         nein     1552        0
 2024 │ Polygon(489 Points)   {624D035D-A042-466E-9635-1236F63…  {EF8B765B-1018-4D4C-A3EA-CAC7657…  real         nein     6959        4
 2025 │ Polygon(172 Points)   {4A3E4478-A3D7-4A34-9653-029D327…  {09A27E8A-D394-4261-859D-1AD414F…  real         nein     7604        0
 2026 │ Polygon(766 Points)   {128C5D3B-B612-42E3-B638-60F37BB…  {9A08D6ED-9BA8-42F3-BD51-01BB8C4…  real         nein     1625        2
 2027 │ Polygon(366 Points)   {DD0FB5DA-360C-4A1D-8ABD-42943DA…  {AEB3A982-41E0-4E91-9111-71CFD05…  real         nein     6383        2
 2028 │ Polygon(492 Points)   {E9C4E2C3-0A5B-40BB-B716-D6ACBE2…  {824FED83-ECC1-4A00-AC41-6237B62…  real         nein     8117        0
 2029 │ Polygon(381 Points)   {9D4F89ED-2636-4D2B-8412-A03DD84…  {A1191987-847D-4B03-A8BD-C336C21…  real         nein     1869        0
 2030 │ Polygon(305 Points)   {134D698A-2D37-4B62-AD89-D2191D1…  {9451B52D-C357-48C3-AE73-A3E9F59…  real         nein     2954        0
 2031 │ Polygon(444 Points)   {256B3BC8-0BE5-423C-8DF2-BE82A9F…  {FF95E41C-C1C5-4283-9927-01F9A66…  real         nein     2857        0
 2032 │ Polygon(532 Points)   {B66B5258-5840-42BD-954F-FFD83F4…  {DED5E332-2BFF-4E7A-81E3-44C81A4…  real         nein     3504        2
 2033 │ Polygon(266 Points)   {4346AE21-3738-4615-A4EF-AE39C36…  {467FF555-E0AB-4807-BC3B-047C7E3…  real         nein     4202        0
 2034 │ Polygon(252 Points)   {CD57A4D6-B2C9-4047-95C7-2A5D2B0…  {597E7D68-FF79-4896-A5E4-EB8B8FD…  real         nein     1789        0
 2035 │ Polygon(277 Points)   {F3692D00-E0E9-4A21-A4B1-EA094DF…  {1569BBB3-820B-4D4D-98C6-FCAACF9…  real         nein     3946        0
 2036 │ Polygon(374 Points)   {037AEA7C-2334-4979-AE61-D9898D9…  {5CCF31B5-2C36-4F03-84B4-A3A2F7D…  real         nein     4226        0
 2037 │ Polygon(830 Points)   {7F5F8F11-76E5-4237-826E-0B18E27…  {DF7FD8A1-D96A-481E-A3E1-F81CD31…  real         nein     1445        0
 2038 │ Polygon(590 Points)   {BE60DB78-EC14-4205-8066-9BC5156…  {77E18D5F-61D0-40E3-97ED-D2524A6…  real         nein     8904        0
 2039 │ Polygon(683 Points)   {C4A9D100-D840-4B9B-9034-04CA517…  {704E217E-2351-492A-A4C4-611181F…  real         nein     9525        0
 2040 │ Polygon(836 Points)   {C5390B3D-E5EA-4E39-89B4-D9A0E86…  {8D199199-6B23-402C-AE3B-4BA8F3C…  real         nein     1285        0
 2041 │ Polygon(470 Points)   {9019975B-73FF-41E4-B492-B3BFC92…  {15D57A31-6707-41F8-9F0E-170068E…  real         nein     3462        0
 2042 │ Polygon(660 Points)   {18F9C085-D87B-4B81-9EED-0377A53…  {5AF0B95E-A3B9-4D54-82EE-584968C…  real         nein     6512        0
 2043 │ Polygon(905 Points)   {53CEE495-1B4E-4B4C-BA3F-878D403…  {1AB001D0-84B9-4DF5-A2BA-1D51701…  real         nein     1023        0
 2044 │ Polygon(396 Points)   {67A4900B-B737-4EC6-A0D8-F0AA6F4…  {A9A5AF41-26BC-4208-A4E7-706F127…  real         nein     1730        0
 2045 │ Polygon(1351 Points)  {2815DBF8-8385-414B-AE02-1B56541…  {7E4DB680-179A-4B63-8849-4BC5826…  real         nein     4528        0
 2046 │ Polygon(794 Points)   {EDA9F788-073E-43E5-9612-8670E0A…  {F0D23DB8-DB90-4CF1-9702-0D21CC7…  real         nein     9050        6
 2047 │ Polygon(489 Points)   {B78BA4B1-6FE9-4DFE-9D1A-9779E04…  {BD00E043-4567-403E-B77B-F08A106…  real         nein     1746        0
 2048 │ Polygon(592 Points)   {3D0A0E0D-D891-4A66-831F-86EA454…  {62218894-508D-4993-BC57-D5C6729…  real         nein     7028        1
 2049 │ Polygon(346 Points)   {066FA48E-44B8-4EF4-8088-387626F…  {21ED34E1-B213-48E8-8221-D60F5B0…  real         nein     6253        0
 2050 │ Polygon(734 Points)   {A2E3D222-ABEC-42D1-BCCA-00ACFF8…  {C9606E6E-4341-4118-8035-3EC0571…  real         nein     9515        0
 2051 │ Polygon(684 Points)   {CC13301C-21DF-43FA-A739-A86DBC9…  {C51BB41B-7915-4AE6-8939-1D4F63F…  real         nein     4633        0
 2052 │ Polygon(573 Points)   {36C381D2-3572-43A8-A8CB-D80BD3A…  {90FFCE30-33A5-466D-B6D2-899A5F8…  real         nein     1661        0
 2053 │ Polygon(277 Points)   {E8F5B388-6235-4675-ABA0-C00BE2F…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3018        0
 2054 │ Polygon(421 Points)   {F2C8A8B8-E1CA-48B3-863B-96DDA8D…  {297F604C-3C02-4983-A12B-50C09DF…  real         nein     4616        0
 2055 │ Polygon(958 Points)   {00C90B14-2668-42B5-8EB5-B0C19F9…  {CA2005F2-8D7D-476B-B721-5D0A009…  real         nein     1400        5
 2056 │ Polygon(509 Points)   {F1BD00D3-9EBE-4B94-A93C-ACD6EB3…  {CE43D26F-42F4-4C57-953F-C89C383…  real         nein     3614        0
 2057 │ Polygon(644 Points)   {D647E793-7765-4F25-9B0F-F74F6E1…  {B5549D92-02A9-47A8-8DE2-B8E2594…  real         nein     2056        0
 2058 │ Polygon(286 Points)   {ACEA3E47-FBDA-44E9-A00F-7FFDABD…  {88F71FDE-9F04-4A8A-A607-F244E24…  real         nein     2322        0
 2059 │ Polygon(500 Points)   {0DA98386-D4EE-472F-8A0F-0D0C213…  {E3885361-6EC0-49B4-9277-4AB07D7…  real         nein     3226        0
 2060 │ Polygon(438 Points)   {D6F0B1F1-FA83-4395-9C0C-1327027…  {BD50193F-C166-4238-A42C-082E248…  real         nein     1749        0
 2061 │ Polygon(371 Points)   {ABABFD62-0C16-4307-AD1E-E6E41CD…  {02EB89DD-AA40-4D2C-BF42-A790A67…  real         nein     1468        0
 2062 │ Polygon(1544 Points)  {65D168A5-7134-4DAF-94DE-B0ABA52…  {37716545-C094-4B2A-B512-8F3F7D7…  real         nein     8895        0
 2063 │ Polygon(93 Points)    {1ADD2084-6057-4457-B17D-E9CA1CA…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3012        0
 2064 │ Polygon(566 Points)   {BE9BBA94-55B0-4AB2-8F7F-A69B706…  {68982531-D64E-42A0-9435-FBEF1E7…  real         nein     5605        0
 2065 │ Polygon(585 Points)   {2D25EB17-ED9A-4182-A58C-862FA97…  {E2046FD6-981F-458A-94E1-EDB381B…  real         nein     5242        2
 2066 │ Polygon(634 Points)   {F2540DC0-7061-40E4-9E10-181E4A5…  {29FE02F4-BD8A-4090-A21B-E1BEB3B…  real         nein     9615        0
 2067 │ Polygon(356 Points)   {8A7AC608-9B25-43A1-9557-9776D47…  {4E9BA532-4AE2-4E16-B00A-FFAAFF1…  real         nein     3974        0
 2068 │ Polygon(482 Points)   {B5424F22-9399-44E9-AE71-0C7D949…  {E0E5B28D-0F08-42C9-929B-4962839…  real         nein     6593        0
 2069 │ Polygon(236 Points)   {FF267EEA-39DC-489D-9AB5-71C2D09…  {C3C2AB71-7AB6-4C9A-8596-F61950F…  real         nein     1948        2
 2070 │ Polygon(701 Points)   {8E131757-744D-4A87-8F92-158F886…  {4578EBCC-8B6F-4727-A9FB-96D9989…  real         nein     1529        0
 2071 │ Polygon(500 Points)   {E7372012-90E5-4976-8147-BDA5477…  {6A082398-D2FF-4906-B240-31E2300…  real         nein     4539        0
 2072 │ Polygon(667 Points)   {D569F448-93F2-44C4-9E99-1B8888E…  {BCA6BDC4-0E18-41A4-8758-D57F969…  real         nein     7027        3
 2073 │ Polygon(525 Points)   {5F922DFD-31C4-4272-BA8C-DC3D2A1…  {EB1CA6C2-E152-4C59-8507-539BD39…  real         nein     6986        2
 2074 │ Polygon(414 Points)   {2E19D2BC-A9EA-4688-A4AF-358885C…  {E3818F03-3866-4083-9622-17F0F05…  real         nein     3977        0
 2075 │ Polygon(257 Points)   {8FEDD8E1-F3F1-4933-86A8-33A3B30…  {CF26F049-D5CF-434D-A428-DC434F1…  real         nein     1148        6
 2076 │ Polygon(701 Points)   {47A84C57-517E-4CE4-BBF5-DAF0E49…  {DFD74758-588B-492D-A541-6469D70…  real         nein     1724        8
 2077 │ Polygon(771 Points)   {A19ED650-4518-40F7-9408-E273FA0…  {C9ADE0B3-FDC9-4439-A02A-A86C97C…  real         nein     6855        0
 2078 │ Polygon(221 Points)   {5B97AB7D-CC87-49F9-AB78-8AEC1A1…  {12F018E6-21E8-4724-A372-8A8DE85…  real         nein     7155        0
 2079 │ Polygon(790 Points)   {292AD541-9F49-44CA-9A2F-AE3B0FA…  {90E8A6BF-1DE6-4053-A2DF-68300D6…  real         nein     9127        0
 2080 │ Polygon(239 Points)   {A2B9E510-69D9-470A-85F9-30339C9…  {70279286-38E1-494A-9A01-79017CA…  real         nein     2888        0
 2081 │ Polygon(447 Points)   {B3B9317F-FAFB-4063-A1F0-742A82C…  {2880908E-BACC-4085-9904-D0E4694…  real         nein     3627        0
 2082 │ Polygon(524 Points)   {16BCF42C-AF54-4C1B-A605-7CD2631…  {56FD344D-EAAC-4CF1-B823-8A7F058…  real         nein     6042        0
 2083 │ Polygon(373 Points)   {907CC55C-899C-4490-9173-5B2F9CD…  {C51A2DA0-6724-4D18-B2CC-AC78BCD…  real         nein     2933        3
 2084 │ Polygon(379 Points)   {A138E5A9-1949-4579-B66C-0210670…  {20173F6B-716B-40F8-BD15-A3B1F52…  real         nein     4814        0
 2085 │ Polygon(851 Points)   {3C10ED85-B784-456B-9E0A-91EC466…  {B854397C-DDAD-414F-8758-A8F3071…  real         nein     4512        0
 2086 │ Polygon(475 Points)   {F239532D-6A0C-4256-8514-A289257…  {19BA5AA6-DFD3-40AB-B5FE-66B9FBD…  real         nein     5028        0
 2087 │ Polygon(408 Points)   {32AA79D7-E35F-432C-AD14-AA65F5F…  {2E542ABB-1E76-4211-8263-5109A17…  real         nein     2935        0
 2088 │ Polygon(470 Points)   {76FEFD20-9346-4D0B-A41F-30D5963…  {5ADC3B73-2C4C-494E-929D-86FD64D…  real         nein     1745        0
 2089 │ Polygon(440 Points)   {9B8A5EB7-E8DA-4247-8CF9-907D1DD…  {24E3AB2F-E49F-401C-BA01-C676BAD…  real         nein     6280        2
 2090 │ Polygon(507 Points)   {2EEA3A0D-EAA3-4D4C-8CA6-B384621…  {2DA55C97-4326-45A0-9573-FE8B324…  real         nein     3367        2
 2091 │ Polygon(883 Points)   {6AE07BBD-89D5-4CA7-B871-4144A7D…  {4313D527-CDF9-4253-AA11-46E0F5D…  real         nein     9034        0
 2092 │ Polygon(437 Points)   {C30CCE89-0B02-433E-BAF9-141C58F…  {0B53827E-73AB-4324-BD78-A9F999C…  real         nein     8355        0
 2093 │ Polygon(420 Points)   {90CC5B9C-36F2-4B5C-87B7-F3853C4…  {9700EEAE-2F1D-4164-8867-24C8720…  real         nein     4464        0
 2094 │ Polygon(461 Points)   {66CA630C-09FC-455F-B6AB-35D1952…  {F3FEF8E7-A6DF-46B0-9F63-D5F06B1…  real         nein     9248        0
 2095 │ Polygon(520 Points)   {0C1C4917-0767-46F2-BD55-9A4B6BD…  {6BD8BADC-1978-4073-A064-2BB58E1…  real         nein     6167        0
 2096 │ Polygon(211 Points)   {D86317C0-75C1-4FA4-8984-C9A61E5…  {04D91DA6-E940-4F5C-946E-9BF6CC2…  real         nein     6661        3
 2097 │ Polygon(466 Points)   {EA790C9F-E3E9-4100-BDDE-189480A…  {421DD291-7D47-4EF6-8143-ED06425…  real         nein     1041       31
 2098 │ Polygon(758 Points)   {FEB9B118-1F74-4FF7-A20C-78CF904…  {01431876-5BCA-4FFF-BB14-31CE1AB…  real         nein     6287        0
 2099 │ Polygon(344 Points)   {930BAB5B-8E73-452F-9663-4BB9EE0…  {6ABA166C-85DC-4FE3-B0FB-028A5DC…  real         nein     3305        0
 2100 │ Polygon(490 Points)   {252A1E05-B5AB-43DF-9244-7001BB4…  {D94A00EC-62F1-49CE-A27F-20A09AA…  real         nein     4542        0
 2101 │ Polygon(319 Points)   {AEB26D90-82C9-49F1-9786-99D9D77…  {F9F5D401-C9AD-4078-B3CE-DD97EB9…  real         nein     1723        4
 2102 │ Polygon(605 Points)   {6A436207-4527-40FC-8558-3AD7901…  {012F22D4-5F80-463E-B746-EB6AA54…  real         nein     9223        0
 2103 │ Polygon(357 Points)   {2A002AB4-CDCC-41CF-A28A-7E02091…  {4E91D9D1-E0DC-4A73-83FC-6EE9E31…  real         nein     5442        0
 2104 │ Polygon(446 Points)   {F6A878C1-B9DB-4BE8-B70F-D79AE87…  {C5BF7045-910D-44C7-BF23-03AF870…  real         nein     5242        1
 2105 │ Polygon(257 Points)   {785DE46C-4450-4719-8AC6-491E77D…  {7845DAE7-666C-4CD0-BA4E-43AF920…  real         nein     2914        0
 2106 │ Polygon(720 Points)   {37E126A4-4DCB-4910-931A-8D41A73…  {D1F9C4EE-6E1A-4C97-8CA2-65DE340…  real         nein     1272        0
 2107 │ Polygon(642 Points)   {13565385-49E2-43F0-8327-5343976…  {8C26ACC0-FEBD-4228-A2E0-4DE942E…  real         nein     1484        0
 2108 │ Polygon(378 Points)   {76FD24EA-DEDC-40B0-B429-E3E35A3…  {3568A8C9-3690-4AB6-9C07-5645491…  real         nein     2054        0
 2109 │ Polygon(393 Points)   {63836B22-7390-48E9-912E-541704C…  {1CB72D0B-B638-44E3-BABA-94121F8…  real         nein     4324        0
 2110 │ Polygon(248 Points)   {0AA7203F-4656-4EE6-B2E8-CA1ADA5…  {7E1C09B4-2B46-4C8B-8181-22136AF…  real         nein     6655        2
 2111 │ Polygon(374 Points)   {BE563501-04CA-4C4B-8717-B8D1AD4…  {EE6710EA-E008-459C-8FFD-CA2D6CB…  real         nein     8913        0
 2112 │ Polygon(201 Points)   {6F9998DE-5FF1-44C4-A617-7BCD1FE…  {42D582A8-7AA2-4B49-B155-EDDBA2F…  real         nein     3961       21
 2113 │ Polygon(780 Points)   {BAF6CF5D-3ED7-4D4C-9032-00D78AC…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3006        0
 2114 │ Polygon(505 Points)   {2E4C0BD6-EAC1-454A-8C07-458E283…  {DB84B334-3225-4A8A-828D-49EB503…  real         nein     8548        0
 2115 │ Polygon(360 Points)   {450D405D-CA46-4508-B44C-4D2A7AC…  {F57543A7-9246-4A71-96D3-DED848E…  real         nein     1214        0
 2116 │ Polygon(127 Points)   {C54E0806-1CF2-4F54-BE57-56607E9…  {B18E0970-A815-4963-A246-F77167A…  real         nein     3994        0
 2117 │ Polygon(346 Points)   {57CCBA31-C321-4093-B6B5-059C9E0…  {0638BF0A-8C0D-4387-B1E0-B4DB06B…  real         nein     3464        0
 2118 │ Polygon(581 Points)   {48D7154F-647B-4F39-83A2-5FE24FF…  {D7663FAB-2415-4ED5-8E10-EA6EFC0…  real         nein     1748        0
 2119 │ Polygon(205 Points)   {F341ECC1-3292-47E3-8A8A-2ECAB09…  {4CFCE3F2-100C-45B7-BFE3-3A8F46E…  real         nein     1475        2
 2120 │ Polygon(899 Points)   {EBA8FD6C-8FA2-4221-83C9-5792B35…  {1A80AABD-2FFC-4119-8154-1A7D04D…  real         nein     1041       32
 2121 │ Polygon(910 Points)   {3488E993-A519-42E4-A8C7-98B1090…  {EFD8179F-7416-450B-91B6-1CCE16F…  real         nein     1058        0
 2122 │ Polygon(806 Points)   {3059F683-CB8A-4100-ABEB-B669FFB…  {72D38B5A-3D5F-43FB-9B8F-FAF1EA8…  real         nein     6073        0
 2123 │ Polygon(420 Points)   {FC05D72B-BFEB-42AD-BB1D-1F4C98D…  {CB9E9856-4F16-41B7-8622-BA9F912…  real         nein     8815        0
 2124 │ Polygon(492 Points)   {6377C97E-E521-4D03-A04C-F0FCB13…  {4AED03E5-5AC3-4755-B48E-76B0D4D…  real         nein     5647        0
 2125 │ Polygon(465 Points)   {1869BBEA-2327-4DCB-875F-B991F4F…  {F81144FB-1193-47B4-8F00-AD2F7BD…  real         nein     2149        0
 2126 │ Polygon(452 Points)   {CEA0233E-2CEC-4695-9FB3-354ABE3…  {46F52705-B05B-4976-B91D-F0A2990…  real         nein     8422        0
 2127 │ Polygon(575 Points)   {6C6C772B-111B-4A93-A6BA-B00BEC3…  {EAC7F266-098F-4AFB-8074-B4D0F6A…  real         nein     5615        0
 2128 │ Polygon(412 Points)   {113F779D-1C88-4C43-BFB8-51C822C…  {5A62323A-ABB7-4D93-84A9-4A8DA3C…  real         nein     3157        0
 2129 │ Polygon(212 Points)   {72297FC9-213A-43B0-82C2-CFA492C…  {AECF6E4C-6FDC-4B42-A3B4-0EBF23B…  real         nein     3754        0
 2130 │ Polygon(1232 Points)  {26F81724-EA53-4F54-B706-AB9177B…  {94D1B6E3-9B06-4F4B-B4C1-34E7F59…  real         nein     1024        0
 2131 │ Polygon(391 Points)   {790E570A-51B7-4EB9-BE72-B39BBBA…  {F69E5E7E-D5DD-422E-B62B-123FA0B…  real         nein     5412        0
 2132 │ Polygon(331 Points)   {09CB4602-CDFD-4EEA-A622-5B8E9CF…  {780DABF0-CD10-446B-A3AB-97CDE09…  real         nein     8537        0
 2133 │ Polygon(465 Points)   {512992D0-D95C-4D90-AE1B-29C058A…  {B6312DE2-9E06-4A15-912C-DAF029B…  real         nein     1741        0
 2134 │ Polygon(784 Points)   {8C513B34-D84B-4302-A7D1-49EB849…  {C742907D-00AB-4904-974C-4DD5E5C…  real         nein     1521        0
 2135 │ Polygon(247 Points)   {9EE1B4C0-0172-4DB3-9E9B-333AA51…  {D34B4E7C-1858-459B-9F85-87812C2…  real         nein     9506        0
 2136 │ Polygon(510 Points)   {6A3AD267-4806-44B5-AD81-133992C…  {01A683B1-0D45-4713-B961-0A3400A…  real         nein     1174        0
 2137 │ Polygon(542 Points)   {EF268ADE-AF98-4BB6-A5D0-1182342…  {1F437873-2371-4E18-A908-070EDD3…  real         nein     4923        0
 2138 │ Polygon(616 Points)   {B58F6FA5-F2AA-44B1-8280-BF1CD5A…  {AD89C600-18C5-4995-9873-1CB4729…  real         nein     9517        0
 2139 │ Polygon(827 Points)   {48CA7905-28DE-432D-A412-AF76C02…  {4274445E-273B-4B2F-92F2-834507F…  real         nein     8802        0
 2140 │ Polygon(747 Points)   {C65371F8-786C-4858-86A7-B10D8FB…  {941BA9D6-5141-473D-90E4-41B2AED…  real         nein     3672        2
 2141 │ Polygon(549 Points)   {19A67FF1-2E36-4978-BD0A-21C19DD…  {0C404850-959F-4EBB-A8F6-10B168B…  real         nein     1257        0
 2142 │ Polygon(439 Points)   {F4CE6082-C85E-4F67-BB58-29E8E84…  {BB140B06-4C96-4546-AC98-B19D89B…  real         nein     1281        0
 2143 │ Polygon(143 Points)   {D1B5EB80-F96C-41DE-AD5B-8F338DF…  {9A3313B2-580B-43EA-B722-2D7EBEC…  real         nein     4497        0
 2144 │ Polygon(975 Points)   {1B9E2687-61C5-48B4-A8BE-56EADBC…  {E130B51F-BC38-4009-BFD5-492E373…  real         nein     1774        0
 2145 │ Polygon(310 Points)   {34118E54-5CF6-40BF-A5FC-B5AF5D8…  {50B26078-DC94-4C31-B83E-9BA7F0E…  real         nein     5454        0
 2146 │ Polygon(590 Points)   {87248AB7-8C6A-4B90-AA44-AC2C300…  {E88E3113-7984-4C6B-BD1E-343E7C2…  real         nein     8454        0
 2147 │ Polygon(437 Points)   {2E76D220-523B-472F-B698-DA77DFD…  {47CCC8FD-9C65-4551-9147-EA5EC7A…  real         nein     5524        0
 2148 │ Polygon(570 Points)   {C2BE88ED-B9C7-47FD-9DE5-25616C9…  {7D5FC05F-189C-44EB-BC8F-A51631D…  real         nein     8512        2
 2149 │ Polygon(642 Points)   {61A26C3A-94FC-491E-B82C-D183C3B…  {1CDAB6C6-B97A-466E-91CB-E69CFEA…  real         nein     1163        0
 2150 │ Polygon(318 Points)   {CCEB9097-1475-45FC-A73B-76B3417…  {77276A8C-E286-4345-BB4D-9EC204B…  real         nein     1647        0
 2151 │ Polygon(1092 Points)  {FF1303F4-56D5-4FBA-BD48-5DF0F83…  {AF7F763B-294F-45FF-BCC4-6045AFE…  real         nein     4515        0
 2152 │ Polygon(358 Points)   {2ABB0A91-90F8-44DC-AC02-26F5F5C…  {59E7A8BB-44D6-46B0-A274-1550207…  real         nein     8964        0
 2153 │ Polygon(1368 Points)  {26133392-B07F-43EE-A32F-6473EE1…  {546406CD-0096-4CF9-9D74-A0DE424…  real         nein     8156        0
 2154 │ Polygon(320 Points)   {4AF10F75-1BDC-4469-B726-22D2C26…  {53FF3F4F-F6EA-4A3D-B1B8-3E70C89…  real         nein     3633        0
 2155 │ Polygon(562 Points)   {E85D9494-CBC0-4170-90E4-31F1656…  {62196104-F137-400F-9840-688C536…  real         nein     1322        0
 2156 │ Polygon(439 Points)   {4012BE78-7040-42E6-9A60-87D9A0E…  {2B1E4796-3B2F-476E-B473-CCFB99D…  real         nein     4806        0
 2157 │ Polygon(689 Points)   {2D524C11-85FB-469C-AA10-0F4DA07…  {183F3EB6-132C-4B29-B381-D4DF754…  real         nein     5210        0
 2158 │ Polygon(402 Points)   {46070948-7B22-480E-8B66-91BFFC6…  {5E5907C2-6A25-434B-999D-7476B07…  real         nein     5444        0
 2159 │ Polygon(180 Points)   {DCE2FF5E-1B99-4173-9DB3-3E29E58…  {01A59BB1-DB1E-454A-91B2-01C6D28…  real         nein     7231        0
 2160 │ Polygon(258 Points)   {12CD3064-2FC8-424A-BD3B-FA41474…  {56DCFC82-67DE-4CC3-91C1-4D59742…  real         nein     3155        0
 2161 │ Polygon(347 Points)   {ABCBA2C7-E913-4080-A987-4FEBFEA…  {01AF059F-2C22-4EA6-A942-D28D812…  real         nein     4533        0
 2162 │ Polygon(402 Points)   {D2A6424C-3A2C-4FC8-AC93-071A16B…  {3F4E1277-E7DC-47CF-AD56-2ECD4EB…  real         nein     8235        0
 2163 │ Polygon(589 Points)   {E80B3BBE-EE95-4BB7-8CE4-0D47C4C…  {52DC6A94-4B65-4E9E-9D1B-0176BF2…  real         nein     1673        4
 2164 │ Polygon(580 Points)   {DA964C94-1634-407A-A215-E0A0E87…  {3813D2AA-FA25-4BC8-96E8-0DFF59F…  real         nein     4303        0
 2165 │ Polygon(278 Points)   {82EAAD48-BB47-4008-8ADA-A8EB9D9…  {D99553E2-685E-4B5C-9101-A6DA862…  real         nein     3225        0
 2166 │ Polygon(132 Points)   {0B8962C9-5332-4EBD-9E28-6FCCEEE…  {3292D2B4-B9F9-475E-9D9B-AA7B0BA…  real         nein     7313        0
 2167 │ Polygon(302 Points)   {395C1269-49E7-4FAF-BAFF-F140BB6…  {F4105B70-16D9-4A2C-8C1E-378F592…  real         nein     6838        0
 2168 │ Polygon(341 Points)   {A9842A5D-4720-4748-BA27-86E3AB9…  {168B7601-1913-461A-8043-D1CA8EE…  real         nein     8451        0
 2169 │ Polygon(445 Points)   {CDA2E00E-D87F-4C73-9BF6-5C33651…  {D008E875-626D-48AF-A806-F1102FF…  real         nein     5507        0
 2170 │ Polygon(1356 Points)  {38D205BE-F207-4CAB-8820-6220426…  {F1911C30-0E2E-4380-9979-EE6A746…  real         nein     8896        0
 2171 │ Polygon(421 Points)   {31A0DAA8-4F53-4BC4-8A05-EC4ECD8…  {6DACB878-D8E5-413C-968C-3C60923…  real         nein     3082        0
 2172 │ Polygon(343 Points)   {4B83B34E-7DF0-4E8E-8F33-6088495…  {F937A427-BC8D-46EF-B605-8447D69…  real         nein     3325        0
 2173 │ Polygon(708 Points)   {02E14101-884C-4EC1-8B21-E2A7434…  {9AA3FE2C-6BA3-4431-9B67-BBEC352…  real         nein     8561        0
 2174 │ Polygon(495 Points)   {28F933EC-2A5C-46BF-955F-F3006E4…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8008        0
 2175 │ Polygon(512 Points)   {4663E9A4-7543-491F-A284-E0F49E3…  {798CFAAD-93F8-47DF-A4A0-2A4DE8C…  real         nein     1955        5
 2176 │ Polygon(223 Points)   {C32E0422-BBFA-4C91-931E-2EF5ACC…  {8F0A0CB7-AC8F-4FF5-BA7C-99CC90C…  real         nein     3645        0
 2177 │ Polygon(280 Points)   {3B031B2F-60C1-4432-9960-B0752F1…  {F62DA740-CD4F-459D-B142-E26CA90…  real         nein     8415        0
 2178 │ Polygon(622 Points)   {CCD94838-420A-4833-A8E2-7DF9BAE…  {DFBCE03F-9B6F-4988-A1FE-7734FC4…  real         nein     6362        0
 2179 │ Polygon(325 Points)   {F24F078B-30CD-4AB6-AE1C-60D09D2…  {A3FA51C0-1F27-40A0-9D67-6EE1BB6…  real         nein     3629        0
 2180 │ Polygon(699 Points)   {D9F57B74-CE52-456B-BB5A-42DF590…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9016        0
 2181 │ Polygon(954 Points)   {3D32D044-353E-40EF-8EF7-984FB50…  {C81F0C26-0F7A-4975-AADC-EEE7102…  real         nein     9108        2
 2182 │ Polygon(510 Points)   {038066D9-A4A6-4B83-84B9-4FB4A91…  {4941864E-162B-468E-A880-9B9DD57…  real         nein     5046        1
 2183 │ Polygon(297 Points)   {EADCBA35-5143-48B1-A891-7E6651C…  {A1A95B42-A299-4A6F-803A-A145FC6…  real         nein     2088        0
 2184 │ Polygon(229 Points)   {13E060E8-A242-44C6-AA98-4EF7636…  {469BA845-1396-4EF6-9E65-064ABB7…  real         nein     7116        0
 2185 │ Polygon(501 Points)   {245FECE8-2782-41FF-822B-E90D459…  {C5029DED-A5F4-4181-8F3C-A4CB334…  real         nein     1063        0
 2186 │ Polygon(877 Points)   {06732A13-6591-444D-9EC8-CF82A72…  {483F6D7B-49C7-463F-9EBC-1C09B8F…  real         nein     1030        0
 2187 │ Polygon(493 Points)   {17667204-1E54-48E3-A540-4FEFC2D…  {2080735B-D277-4A08-9CA7-3D38C87…  real         nein     4524        0
 2188 │ Polygon(320 Points)   {B8F481F6-514C-4D03-A0F8-121D4C4…  {6CECE4BE-A148-4036-AE2D-1E69741…  real         nein     1607        1
 2189 │ Polygon(432 Points)   {954A5A0E-594C-47F7-B1EE-D9C8B10…  {171E2E2C-5021-4035-A5CD-69DF9B6…  real         nein     4573        0
 2190 │ Polygon(358 Points)   {B2942C94-B0AF-4C81-A911-4D1D083…  {033D5481-BC8E-47EB-A71A-36FF39C…  real         nein     5324        0
 2191 │ Polygon(720 Points)   {1CE4C5BD-456E-48C9-BCD7-271FC1E…  {79070962-09D5-4727-8A0C-EF66EE5…  real         nein     6645        0
 2192 │ Polygon(665 Points)   {A8F60314-707C-4085-9CB0-5EDC345…  {8C8DF594-EB73-45D3-92E5-AB179C0…  real         nein     5621        0
 2193 │ Polygon(263 Points)   {110AC3A2-DE59-44D1-A722-6C2CD85…  {2CC32087-67E0-4EDC-82AE-5C8AEC7…  real         nein     2555        0
 2194 │ Polygon(342 Points)   {D0FB8543-5B0F-4506-A821-F668D3B…  {C99E9E35-F826-4FC8-8EB4-F1C84B7…  real         nein     1297        0
 2195 │ Polygon(268 Points)   {D6501568-EC8B-4412-A008-F6E881B…  {A4EAF9DD-27CF-4AB4-A707-7CCDA2D…  real         nein     8868        0
 2196 │ Polygon(684 Points)   {7EADE46F-B1A8-4E1C-8559-9DAB0EC…  {23F46FF2-5BE7-4504-81A0-B349067…  real         nein     8181        0
 2197 │ Polygon(615 Points)   {206BE97A-E2F8-412E-8235-F094F7C…  {706D8DB5-17AC-4EED-9474-EC611FC…  real         nein     8194        0
 2198 │ Polygon(710 Points)   {39DE77B9-3A4C-4633-B845-99900F2…  {7999B767-35D1-460A-AC7F-3CA5C96…  real         nein     6383        0
 2199 │ Polygon(887 Points)   {4627F2CB-6420-4F97-815F-BD1C631…  {6A18ACBE-57D2-4BD9-BD91-48FDFE9…  real         nein     1513        0
 2200 │ Polygon(545 Points)   {D38CA096-225C-4209-92C8-981B007…  {FF884EAC-96D5-4045-A54A-6C6AE01…  real         nein     8585        4
 2201 │ Polygon(299 Points)   {3840D5D6-F7F9-4F53-9774-599E4F8…  {71A465A2-03FC-4116-8A27-9D0210B…  real         nein     4574        0
 2202 │ Polygon(313 Points)   {E3F32299-F549-4097-84E7-68CB5A5…  {D4DB8431-50F6-4339-B263-F58181B…  real         nein     4913        0
 2203 │ Polygon(353 Points)   {C5F3D653-1AA1-4D39-8088-8245F09…  {90252F9A-D857-4AFB-B5A9-8BFAD37…  real         nein     5223        0
 2204 │ Polygon(319 Points)   {5B310A8C-5892-4AEF-98DB-F7BB208…  {CE3B3239-E963-47C6-828A-6E30B66…  real         nein     2748        2
 2205 │ Polygon(324 Points)   {4AA9487E-597E-4A74-9B0D-F0BB594…  {92E1463D-588C-49E3-9F0D-AB9C753…  real         nein     1646        0
 2206 │ Polygon(798 Points)   {8F26156C-3E4E-4B62-A800-FC21ECD…  {DDD7D4DB-856D-44A3-811E-980242D…  real         nein     3174        0
 2207 │ Polygon(760 Points)   {F15B75F8-AB74-45E4-A12B-C67B5A9…  {1C6D9C4B-DD70-44DA-8914-70196DA…  real         nein     1583        0
 2208 │ Polygon(574 Points)   {690E8650-8D4C-4ABC-A3EE-A5240A3…  {464C5831-4043-44D5-BC8E-6C8FA64…  real         nein     1808        0
 2209 │ Polygon(442 Points)   {81B88A3B-27D6-4719-B848-11029B2…  {45CE351C-7B70-4C98-9AC4-7CB5B2E…  real         nein     6312        0
 2210 │ Polygon(470 Points)   {2BBED57D-09CE-4F83-9B2D-C04B15D…  {4644B3EF-19AB-43C8-A36A-8AA7E9B…  real         nein     4657        0
 2211 │ Polygon(500 Points)   {C6875124-FAEE-40AE-8A96-B8CAC1F…  {013EEFA7-28C0-43C3-852D-0FAFDA2…  real         nein     3179        0
 2212 │ Polygon(476 Points)   {FCA2CAEF-4E12-4B6E-8742-37503FD…  {287A11BC-1AC5-46E1-9164-E9CF698…  real         nein     4233        0
 2213 │ Polygon(91 Points)    {61E28B91-AC90-42AA-B1B3-B5214C0…  {9DF9017B-5422-4F84-96E6-F290522…  real         nein     2406        2
 2214 │ Polygon(222 Points)   {E5ACA21D-8F07-4634-995D-0529106…  {4452A208-C338-4854-B868-536F57D…  real         nein     1563        0
 2215 │ Polygon(256 Points)   {83C1EA1F-1FA9-4CA3-8AC9-03D533E…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4058        0
 2216 │ Polygon(477 Points)   {7281E01E-6CE8-4529-AC13-7A6F97E…  {9AB62750-5ADA-40C7-93EF-FAF40F7…  real         nein     9546        0
 2217 │ Polygon(817 Points)   {4EAA9F16-C918-42B8-95AC-573B35A…  {7FB3F891-77ED-4BA3-BFBA-9660878…  real         nein     1454        2
 2218 │ Polygon(324 Points)   {76719F2E-4555-4EF2-95D3-360C9BD…  {0F82590B-57BE-411B-BE0E-C5293FA…  real         nein     5504        0
 2219 │ Polygon(535 Points)   {67F439B1-5450-4A7E-9CFF-509B232…  {D6F5FDE2-430F-4B8C-9656-387B23B…  real         nein     1243        0
 2220 │ Polygon(431 Points)   {6E6F34E8-792A-4B22-B230-B300287…  {B7A70127-3D98-4DBF-BC6D-101ADDF…  real         nein     6622        0
 2221 │ Polygon(328 Points)   {C6ED17E5-F928-492D-9F66-6B23834…  {7F300FDF-2FC5-48A5-910F-CAC0D89…  real         nein     8234        0
 2222 │ Polygon(471 Points)   {DFAF8A9F-D96E-4024-9687-9A83C89…  {E933AA8B-9DCC-4FAD-A644-545B781…  real         nein     4456        0
 2223 │ Polygon(639 Points)   {73C90FED-2507-40F2-81FA-31420CB…  {61FC7AD5-EDF8-4F12-8CD5-ADF10AE…  real         nein     9562        0
 2224 │ Polygon(141 Points)   {2F0722E7-0586-49E6-AC6F-83754AA…  {DF9463BC-1AE1-4543-8873-AE90002…  real         nein     1992        1
 2225 │ Polygon(407 Points)   {7D857C51-42CD-482F-A154-5F44E84…  {909C4A46-7769-4935-A330-54A28DD…  real         nein     8933        0
 2226 │ Polygon(585 Points)   {5F52A98B-F578-40F0-A652-F815CF4…  {C0AF4FBA-F494-4070-A841-D69FBFC…  real         nein     6914        0
 2227 │ Polygon(427 Points)   {1C853E53-0FA8-4EA2-AB6B-3E2A593…  {458C84DF-ECA7-41FA-BE0C-62653EA…  real         nein     2732        4
 2228 │ Polygon(176 Points)   {E39251D8-5103-4743-8098-D3C9DD3…  {533C79FC-57C6-4540-9379-E5E4F13…  real         nein     3989        4
 2229 │ Polygon(1125 Points)  {940191D5-4CE8-4B78-81A0-378D6AA…  {002D2686-13EF-4702-8E83-28B3FDD…  real         nein     1071        0
 2230 │ Polygon(692 Points)   {2E00ECD6-7F8B-4A46-8954-29E1888…  {EC297654-D716-4F29-821D-20FF199…  real         nein     9403        0
 2231 │ Polygon(348 Points)   {CE53AB49-8F10-4FCC-898D-1AB8643…  {52B5CF53-C4FB-4FE1-98D4-46A44CE…  real         nein     6211        1
 2232 │ Polygon(339 Points)   {29B6AA5A-6411-4E3E-A181-44DECE4…  {70DC1625-A6C0-48DF-ADE0-C9B81B8…  real         nein     3507        0
 2233 │ Polygon(1327 Points)  {E3E61939-2EAC-4788-93B2-62F0634…  {4CF879AC-5F45-405B-8BE2-9185CC1…  real         nein     1088        0
 2234 │ Polygon(259 Points)   {32FE9432-E756-4540-9CC1-BD23A12…  {537438C0-F2DD-4064-B702-DD2BCB0…  real         nein     2363        0
 2235 │ Polygon(296 Points)   {EACF9DA8-5F59-469C-9E70-A16E7D0…  {66DF3E28-73B1-4AE9-9150-920A8A2…  real         nein     8890        0
 2236 │ Polygon(402 Points)   {6F17249F-6377-4CA4-A985-8E51A52…  {E46D4040-2D82-42C9-A104-3FB936D…  real         nein     1897        3
 2237 │ Polygon(358 Points)   {73CA8F22-54CB-4950-9D83-0F7C541…  {544A5331-37A7-4007-8639-0277B57…  real         nein     8428        0
 2238 │ Polygon(1004 Points)  {5A9338A9-63FF-4A95-A79E-7610308…  {8D0ED726-C069-402C-B37D-B7F505D…  real         nein     8703        0
 2239 │ Polygon(1162 Points)  {A1A3E6A3-DA56-4658-9F9C-A96E9F7…  {8B4C9AC9-FED9-41E5-9B4D-931D409…  real         nein     8832        0
 2240 │ Polygon(259 Points)   {84F44531-FF61-4477-9FFD-E8FF9CF…  {09E79E8D-358F-4B9A-B2C1-87DC250…  real         nein     4435        0
 2241 │ Polygon(366 Points)   {DE9F01A8-44B1-41FC-8028-30FAB96…  {AFD8287E-8D16-4C4C-8D89-CB68E51…  real         nein     3703        0
 2242 │ Polygon(620 Points)   {F469DF3D-ECCF-4979-A249-1C90439…  {19614ED2-B11C-4DBA-B156-7289FC5…  real         nein     3631        0
 2243 │ Polygon(100 Points)   {92B0BFBF-537A-4D4C-BF14-A76F8E1…  {5EF99C00-8054-4634-A298-2AD4941…  real         nein     9469        0
 2244 │ Polygon(336 Points)   {2ECCEE45-C547-4063-A824-B4094C9…  {0168DBFD-8AB7-41B0-BB92-BD3D72A…  real         nein     6818        0
 2245 │ Polygon(513 Points)   {285E7571-3281-479E-81FE-1D01272…  {9B067E34-8042-45E5-9A32-66198D2…  real         nein     4938        0
 2246 │ Polygon(496 Points)   {B8F99EE1-2701-46F4-93F2-60A13E1…  {7191C61C-DA99-4122-9559-D5B9DA0…  real         nein     4414        0
 2247 │ Polygon(445 Points)   {D5631D7D-68A0-4F16-8B5E-72EBCF8…  {A345D2BF-6BFD-47A0-B5F2-4169F97…  real         nein     1474        0
 2248 │ Polygon(735 Points)   {B98F0ED3-DD93-4384-A8D4-F686FE9…  {39B80755-8089-4D2A-A45A-CB46B71…  real         nein     5014        0
 2249 │ Polygon(385 Points)   {D0A728DD-DEB9-49E2-8CA6-0418437…  {43613A5E-5098-4292-8F0C-F53F533…  real         nein     3234        0
 2250 │ Polygon(819 Points)   {5E732D1A-1020-48DB-85EA-001CC89…  {79FEB7C2-93DC-4447-A0A0-394F2B6…  real         nein     6056        0
 2251 │ Polygon(65 Points)    {EF3DC814-F948-4A09-8A5F-28CDA90…  {D12CE6FD-289B-4389-8B9A-F7650C9…  real         nein     1969        3
 2252 │ Polygon(273 Points)   {0A087902-0096-466B-BDA3-BBB3FB4…  {D262B217-859E-409E-A04E-C9C3F19…  real         nein     4148        0
 2253 │ Polygon(647 Points)   {358AD90A-29B5-4C8A-B5FF-89D154D…  {4B60A5B8-2251-49A6-B772-E1A1B37…  real         nein     4222        0
 2254 │ Polygon(291 Points)   {083A403B-BB66-47F4-998C-1759507…  {AA6CEC90-7A5E-4D8D-B2F7-99285F2…  real         nein     3207        0
 2255 │ Polygon(579 Points)   {DBC07E08-44CC-4097-A24C-FCB3CCF…  {B4D3B5DA-0181-4055-83BC-EC9FEF2…  real         nein     7417        0
 2256 │ Polygon(903 Points)   {9ED27709-F472-4CCE-9190-DAD65F3…  {2E13044B-D1EE-4914-9F92-AA938AF…  real         nein     8565        0
 2257 │ Polygon(354 Points)   {9A815782-B11F-4D35-A5C0-0C4D311…  {E9EC06FB-8642-4344-8D49-9F20DF8…  real         nein     2565        0
 2258 │ Polygon(411 Points)   {9229BE7F-926F-4AAA-8ECC-BDE8176…  {7B952B37-9F08-4220-A781-2E10C20…  real         nein     9445        0
 2259 │ Polygon(628 Points)   {FDB5723D-CA7E-4C12-A905-95327D8…  {1165CC10-8058-4E21-A8D1-4D2A8F3…  real         nein     8142        0
 2260 │ Polygon(764 Points)   {C60C9BA5-216D-4FD4-9EED-714711A…  {41AECFB9-8EC1-4422-B018-823AE93…  real         nein     1236        0
 2261 │ Polygon(1557 Points)  {614397EC-F008-4E59-A555-8AA4256…  {E55EDC6F-AD9E-4DEC-9CBF-2689476…  real         nein     1066        0
 2262 │ Polygon(944 Points)   {5EA3EBC7-7AF0-45B5-AE49-B6113E2…  {F9FCD817-4302-441A-B54F-DC526E5…  real         nein     1614        0
 2263 │ Polygon(540 Points)   {C4676A6B-9A8A-470B-BB69-9278CF6…  {7C891583-00E9-4FB4-BD49-BC39547…  real         nein     1404        0
 2264 │ Polygon(562 Points)   {F5656614-8BEC-436D-B6A5-BE69554…  {C9D273B4-E4AA-4388-B1E9-F3771CF…  real         nein     1512        0
 2265 │ Polygon(223 Points)   {55FF555D-80D5-4018-99AA-A024661…  {25179E3F-9EC3-463D-946F-A865A50…  real         nein     2112        0
 2266 │ Polygon(483 Points)   {3E9BE491-4BF2-4D12-BF7D-DE32B0C…  {ED1BF74A-4950-464D-BBBF-E81A331…  real         nein     5622        0
 2267 │ Polygon(168 Points)   {24DDD01A-BD19-4556-BC91-B8B2A9A…  {7D0B9273-3483-4724-A592-48BC905…  real         nein     3853        0
 2268 │ Polygon(192 Points)   {7F459642-4AC8-43CA-AD51-D6D1C49…  {55CB40C8-004E-4333-98B6-56A65C2…  real         nein     2713        0
 2269 │ Polygon(272 Points)   {69FED1DC-7E98-485A-A196-CE3F3DE…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8051        0
 2270 │ Polygon(798 Points)   {1DF79EF2-B340-48D7-8FFA-1FD2B82…  {450219F2-9178-4695-9FE4-7F2FA22…  real         nein     3147        0
 2271 │ Polygon(408 Points)   {FFDFAC7E-52E7-433E-B322-EF8CAEB…  {4FE36CB5-5C31-49F8-BA97-0471197…  real         nein     1356        0
 2272 │ Polygon(364 Points)   {BE5DE14E-47AB-48B9-B3DC-69672F5…  {852DE398-3652-4D03-BE71-BEDABE6…  real         nein     1222        0
 2273 │ Polygon(375 Points)   {D7D386CB-EB1C-4806-85C5-F9E0DDF…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8041        0
 2274 │ Polygon(604 Points)   {0BBE04DA-0FDF-437B-B21D-8D62D4D…  {96CF2709-2836-4AD0-BC87-DF6EB63…  real         nein     3122        0
 2275 │ Polygon(191 Points)   {10AB3DDF-E0F1-465B-85EC-E7F1EFD…  {78695587-4599-49B2-9768-5949754…  real         nein     5314        0
 2276 │ Polygon(294 Points)   {24F94CCC-5ACC-4BC7-B65F-3B0226F…  {3F77F673-B35A-49DE-85CF-0AB8851…  real         nein     3075        0
 2277 │ Polygon(245 Points)   {A83971A4-D896-4DFC-975A-642C80E…  {460BDC94-E306-4097-BE18-62946F7…  real         nein     4323        0
 2278 │ Polygon(421 Points)   {604F3057-BB41-4C1A-97F7-F046996…  {1EF09E65-3056-4383-A42C-47C67C7…  real         nein     9555        0
 2279 │ Polygon(405 Points)   {D6897E90-2B00-4DE4-9231-E56054F…  {F1DE57E9-AB87-4E7A-B823-0A861DE…  real         nein     1059        0
 2280 │ Polygon(606 Points)   {04469F39-923A-49BB-A78A-BE473C7…  {B308290C-B5A2-48AD-8E29-9B84700…  real         nein     6965        0
 2281 │ Polygon(735 Points)   {656C4D55-0153-4EF1-AA04-E38F010…  {3DF8865B-6721-4DCE-9F55-D98ABBC…  real         nein     7146        0
 2282 │ Polygon(515 Points)   {756E795D-0D8C-4FCB-98E9-97781A7…  {ED6781F0-243C-458F-BDBE-B7A8160…  real         nein     3663        0
 2283 │ Polygon(400 Points)   {CE0A9784-78E2-489F-B0DA-A4145A9…  {4C248EB9-97CB-4AC1-B2A7-8BD0979…  real         nein     3283        2
 2284 │ Polygon(477 Points)   {858DB138-A7E7-4690-8F12-44057A1…  {08D35D0E-2E29-4C72-B4CC-D9EBDD3…  real         nein     2037        0
 2285 │ Polygon(483 Points)   {F6023BA4-5B0C-4C6B-8A60-66588E5…  {73EFC038-0284-4DE0-A55D-9B93AF3…  real         nein     6803        0
 2286 │ Polygon(301 Points)   {A1C5CDC3-508F-4274-AB3A-4337812…  {F856A0F5-3230-4CEF-A6BA-A142FA2…  real         nein     8108        0
 2287 │ Polygon(461 Points)   {DAC8BB4F-D6C0-415C-BC3F-FC26224…  {381CE3A4-EFC8-45D1-94D3-998CDA1…  real         nein     8545        0
 2288 │ Polygon(142 Points)   {AD8E563E-388C-460C-B1B0-4669A0E…  {8CC74763-D75E-4778-9E0F-C4FE3B7…  real         nein     3995        2
 2289 │ Polygon(702 Points)   {AE64A2EE-6B71-4A08-B175-D1B5CD9…  {3F8CB726-6800-41BC-97CF-699FBF9…  real         nein     6883        0
 2290 │ Polygon(686 Points)   {98ED510E-3C04-432A-86C7-80B70C8…  {A388FAB4-0E8F-4AE5-B8B6-7026501…  real         nein     8918        0
 2291 │ Polygon(510 Points)   {0350E2A6-80B6-409D-9B8E-DC1DA19…  {293892CA-701A-401F-8A88-81DB148…  real         nein     9323        0
 2292 │ Polygon(302 Points)   {062AE43D-BAB5-4AE0-B5DE-4075A2A…  {6C33D7B3-C666-477A-9AC2-202AE8F…  real         nein     8919        0
 2293 │ Polygon(173 Points)   {427A4B80-3DAD-4A54-903A-197C082…  {B84335D5-7BC5-4DBE-819F-5A217D6…  real         nein     4629        0
 2294 │ Polygon(491 Points)   {F333D645-A613-47BA-8911-CDB816B…  {15F88389-59D5-4BD9-81B5-47FED37…  real         nein     3159        0
 2295 │ Polygon(377 Points)   {4D0CC22A-05CC-4C71-B535-2172C9F…  {4EA14978-EFE4-4CEB-A0FD-A2042B6…  real         nein     1676        0
 2296 │ Polygon(378 Points)   {95733010-0927-4B09-B113-2066391…  {927822D5-429B-445B-9604-60E444B…  real         nein     4402        0
 2297 │ Polygon(339 Points)   {E7EF890F-9CB5-41A5-B80E-5F9B2C3…  {F240DDD3-291E-4936-8559-1C9797E…  real         nein     8593        0
 2298 │ Polygon(411 Points)   {2C720966-FE90-44DA-948B-EDB0009…  {FCFD658F-C78E-4BA9-B6FD-51FE001…  real         nein     5746        0
 2299 │ Polygon(229 Points)   {9278BF45-2475-4CF3-924F-EA9BB7B…  {880F027E-9829-4559-9954-94B12DE…  real         nein     8223        0
 2300 │ Polygon(478 Points)   {FA3B78E4-4A09-4A32-9E07-C8D2658…  {37161BCD-AD59-4AA5-93DB-2195742…  real         nein     3177        0
 2301 │ Polygon(664 Points)   {C704A9C8-48C1-4C0E-B4EC-2257B42…  {2F434F1D-B671-4D56-8505-245DCEB…  real         nein     6143        0
 2302 │ Polygon(719 Points)   {A45C3E84-C43B-4994-B938-968A486…  {E231272E-C842-4762-860B-F0D6706…  real         nein     6850        0
 2303 │ Polygon(143 Points)   {F29A232A-D699-409C-8552-464A50B…  {A2C04B29-301C-4EE1-A4F7-90E328D…  real         nein     3463        0
 2304 │ Polygon(357 Points)   {BC04CFB8-CEDD-4E76-9607-43169D3…  {C0DC249D-B688-4F53-8BF3-2EF5F1A…  real         nein     2907        0
 2305 │ Polygon(161 Points)   {B1B43B66-BA6F-4E62-95C3-9A63EB2…  {9CFAD205-95D9-42FC-B104-6A2419E…  real         nein     3049        0
 2306 │ Polygon(337 Points)   {059D6BE1-7F76-4723-94CC-39C546C…  {B0A2725A-F95B-43E0-BDEA-71C0C19…  real         nein     7142        0
 2307 │ Polygon(545 Points)   {5C8A8EC7-D46F-4ADA-AE02-752E649…  {8BD43B34-6969-40B3-A164-2FD1CF1…  real         nein     3084        0
 2308 │ Polygon(344 Points)   {D4BB2344-1246-4CF6-B4D2-7DA4D81…  {669C0379-8349-44FD-800B-5121293…  real         nein     8853        0
 2309 │ Polygon(564 Points)   {B26C7A29-D9A6-4F66-AE23-F41E259…  {94CC6795-F8A4-4F83-BC89-EAD0F25…  real         nein     4935        0
 2310 │ Polygon(638 Points)   {CA8017C5-9C22-4BC8-A5ED-9B5E8F6…  {0760CF22-27A5-482F-B273-59FEBC3…  real         nein     1318        0
 2311 │ Polygon(127 Points)   {3F29C99F-1AC5-4CC0-BAF8-9AFD20B…  {70EA4B2D-1829-4CF2-9384-2878B77…  real         nein     1927        0
 2312 │ Polygon(305 Points)   {B084729D-618E-427E-A520-34832C5…  {E4291F75-79FF-4C81-9544-53073CB…  real         nein     3317        0
 2313 │ Polygon(612 Points)   {5B5B24E6-6515-42DC-8961-03B3701…  {02F34551-48E6-484B-8F21-9EC839C…  real         nein     3367        0
 2314 │ Polygon(366 Points)   {871FD19E-C30A-4468-9258-D18E455…  {A21E0091-67CD-4705-9461-61E72DC…  real         nein     3424        0
 2315 │ Polygon(430 Points)   {706C85A7-2C8D-45E5-A7AA-5747151…  {46D23DD0-4032-4060-A101-9F68F38…  real         nein     9437        0
 2316 │ Polygon(491 Points)   {9B26274C-9577-4CED-AA6B-04387C7…  {6C9458E8-C480-4235-AC90-F3181E8…  real         nein     1090        0
 2317 │ Polygon(314 Points)   {67D8F5D8-115E-4DAA-8BF7-64FB9B6…  {FA77A612-31E2-4A63-B29F-8DF9866…  real         nein     3635        0
 2318 │ Polygon(316 Points)   {96A1CEBD-0D1C-4478-A676-A6B7DD5…  {050AC660-3B45-4349-85B7-29C4DCD…  real         nein     6242        0
 2319 │ Polygon(549 Points)   {9C5ADBCC-87FB-447C-89B9-328F398…  {0F52B8C3-9DD9-4FAA-B583-8615819…  real         nein     5025        0
 2320 │ Polygon(708 Points)   {6247F6C5-20EF-444A-BE7B-882402B…  {081A4F17-3C5D-4EC5-9FB4-A2DFA03…  real         nein     1697        0
 2321 │ Polygon(582 Points)   {2ECD0726-F911-4C8C-8DED-193D5D4…  {0C43CC83-1DE5-4F05-A357-30C2490…  real         nein     3073        0
 2322 │ Polygon(315 Points)   {854C22E5-5A20-47EF-B780-A66A243…  {95CE6148-6817-4902-B312-CC6148A…  real         nein     5608        0
 2323 │ Polygon(638 Points)   {6F925063-4FDD-40FD-8851-965FED6…  {4B7F5BFA-3560-4DA7-A5DF-8EAB552…  real         nein     8467        0
 2324 │ Polygon(857 Points)   {5B2CC048-B355-4EF6-BEC3-E4361BC…  {9C067E90-41C7-48F9-98F9-B6E619B…  real         nein     4663        0
 2325 │ Polygon(263 Points)   {C946F3CC-9747-44DB-A916-07AAACF…  {1EE1B360-E9DE-4702-AF10-5A9BE36…  real         nein     4102        0
 2326 │ Polygon(459 Points)   {440B7E45-EAD0-4D29-A5C2-F22ECD4…  {6E6226C2-5242-4A76-AF42-F3148AD…  real         nein     3506        0
 2327 │ Polygon(569 Points)   {E9B05971-F46C-43C0-B7D4-A534C56…  {3906B7C5-19EA-4DFA-8938-9D279BF…  real         nein     8104        0
 2328 │ Polygon(610 Points)   {04CEB5AF-077C-42B3-A02A-4AC84A8…  {191AA991-80A5-4977-94C8-E76FDDA…  real         nein     9112        0
 2329 │ Polygon(230 Points)   {E48A697B-D4A1-4773-978F-40C7689…  {59223666-2E91-440B-A631-656AF5E…  real         nein     2554        0
 2330 │ Polygon(615 Points)   {4AD9A0F5-48EE-4058-BC8E-284FC67…  {8A1BCC01-091A-49A6-91E6-6EA97AC…  real         nein     6216        0
 2331 │ Polygon(261 Points)   {7626EE4B-F2BD-48DE-BC4D-D60BB59…  {EA9A3A8E-9E43-4210-9164-F228920…  real         nein     1644        0
 2332 │ Polygon(945 Points)   {E1DD5405-7B45-4B96-AB3E-C596053…  {875382D3-F27C-48B1-9B8C-1DC4171…  real         nein     8427        3
 2333 │ Polygon(524 Points)   {A392BD35-2273-4219-B9E5-4B77851…  {27D2ACC6-87A2-4960-94CA-F5F35EE…  real         nein     6289        0
 2334 │ Polygon(490 Points)   {871C8888-39BC-46D2-AB67-1102F11…  {34A4800F-E5E4-41EF-B6AE-0F96893…  real         nein     1533        0
 2335 │ Polygon(177 Points)   {E459D9B6-2892-4D6A-A4CF-DD4885D…  {06BE692B-572F-4A7D-8EF0-FF32FF4…  real         nein     6946        0
 2336 │ Polygon(198 Points)   {53C8B793-0034-41B8-BF04-3F71408…  {1FE8A9CE-8165-4971-80C1-CF64CC9…  real         nein     7426        0
 2337 │ Polygon(811 Points)   {93B9B09C-9FC9-4741-A5A1-6A1C3C7…  {38FCFE1B-2DEA-4D8E-ACE0-7BD4890…  real         nein     1316        0
 2338 │ Polygon(712 Points)   {2B11CA55-B8E9-4D69-A47C-CA73A31…  {B353B539-F961-47CB-A903-9172F51…  real         nein     1062        0
 2339 │ Polygon(296 Points)   {BF8F2973-6DA8-4142-94B9-4B07493…  {1C263F30-A6A5-4AF2-AEEC-501413F…  real         nein     1317        0
 2340 │ Polygon(1007 Points)  {90C36AB8-377F-47A4-895B-BD42BE1…  {601179DE-B71A-4F03-BBFE-49A267A…  real         nein     8803        0
 2341 │ Polygon(571 Points)   {0F70BC3A-F08E-491E-A3AA-7C0F1C7…  {4FE55479-A40B-4AF1-B527-4F8E171…  real         nein     4943        0
 2342 │ Polygon(308 Points)   {D33272C6-CFF0-4285-ABD2-82D7B77…  {B605B313-9854-4091-A83F-43F57BA…  real         nein     1293        0
 2343 │ Polygon(498 Points)   {CFD04361-BBC8-4639-8B5C-34CB602…  {59229217-4390-4896-B717-3534149…  real         nein     5054        1
 2344 │ Polygon(339 Points)   {5809FA60-A99A-4741-99CE-486C4CF…  {C981FE09-4D66-4124-85CD-E3B6D9C…  real         nein     1545        0
 2345 │ Polygon(489 Points)   {766E846A-B49F-4FDE-84EB-59D7A43…  {56DCCD88-F182-4381-B62B-157EC06…  real         nein     1223        0
 2346 │ Polygon(604 Points)   {16C6357B-C50B-4F83-A29C-3379265…  {928F2B63-B5B3-45AE-A54C-51BF9DE…  real         nein     3800        0
 2347 │ Polygon(549 Points)   {1AFFD6AB-554E-484A-AA06-FDAC5AA…  {0E56E8FB-A5EA-401C-A3CB-2559F57…  real         nein     8942        0
 2348 │ Polygon(265 Points)   {B95C8BF9-F8D1-489D-BB21-1D3B75E…  {D33F9CC2-9881-410B-8307-55874F6…  real         nein     3434        0
 2349 │ Polygon(645 Points)   {BCC37A50-3651-46EE-9248-9227F12…  {EFCE15CC-3AB6-499C-971D-43B67B0…  real         nein     8926        0
 2350 │ Polygon(260 Points)   {C4E7016D-0BB5-4F8F-9CB1-EC09FB0…  {E7A284A3-FAEB-4997-B729-C6E74DB…  real         nein     7062        0
 2351 │ Polygon(693 Points)   {E085E7B9-60CE-42E2-9B60-0BF0396…  {BDADE128-3C6D-414F-BBE3-5CB1BBD…  real         nein     1180        0
 2352 │ Polygon(529 Points)   {7ACAC88F-1F6D-4D2C-BE82-4AA30EC…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8055        0
 2353 │ Polygon(267 Points)   {3747B25A-BC66-4B9E-8649-8D972AB…  {E2DB14D2-B2BD-4F93-91C6-5B916D2…  real         nein     5616        0
 2354 │ Polygon(1111 Points)  {92CFC18B-1144-4FE9-8BFB-88AC550…  {CC587EA1-C5AE-4D21-8FA7-BF44C26…  real         nein     8707        0
 2355 │ Polygon(260 Points)   {D4F215EB-4138-40FB-9F91-AD45DFD…  {A3ABD321-1041-425E-87F9-E5B32AE…  real         nein     1091        0
 2356 │ Polygon(314 Points)   {0E626071-78D5-466B-8799-4602B43…  {73C9AA97-6167-45D5-90D8-4931AC7…  real         nein     3271        0
 2357 │ Polygon(365 Points)   {62FD2323-F007-46FC-ACCC-1BC2DF6…  {2363FD52-BFAE-4F34-8364-8FA387E…  real         nein     5072        0
 2358 │ Polygon(235 Points)   {7D05328B-0653-47C3-8FDD-ADA1B2A…  {453FF2EB-50FF-428D-B300-399847C…  real         nein     7427        0
 2359 │ Polygon(230 Points)   {AD6741C0-E73A-4160-BC2B-4E6B6CB…  {BD2292B8-C482-4376-B1BB-73103E9…  real         nein     8606        2
 2360 │ Polygon(518 Points)   {36A21D65-4A7F-4B38-B951-780D093…  {32125AB9-C658-4E55-93AF-19DE1E5…  real         nein     3266        0
 2361 │ Polygon(734 Points)   {7D28FD1A-497B-4BEB-8363-47237D4…  {E46E11A2-882A-4BF0-85C4-A544976…  real         nein     6573        0
 2362 │ Polygon(737 Points)   {ECBB9C55-A94A-43CF-895A-6625204…  {A2C167B2-E0B7-4BF7-BB55-05C6377…  real         nein     8184        0
 2363 │ Polygon(588 Points)   {F7C7CA8A-09D1-4601-8DB6-5A16CAA…  {92B9BBB4-F9C2-4F99-8F53-1C05B4D…  real         nein     6986        0
 2364 │ Polygon(327 Points)   {1A0AA130-0457-4C28-9FE0-E62ABAF…  {68E55F6C-177D-4135-86BF-220E9EE…  real         nein     8592        0
 2365 │ Polygon(625 Points)   {47ADFB56-BADA-4B5D-A8B4-1A5F9A7…  {7DF8832B-BB1C-4862-8296-9DE0968…  real         nein     9526        0
 2366 │ Polygon(842 Points)   {1F0D7362-1160-4F75-9FC8-16824F0…  {9E310388-A797-4B88-894B-B6D966E…  real         nein     1613        0
 2367 │ Polygon(414 Points)   {86456C60-353C-4F0E-9337-DA0DB39…  {F4A59A4B-3A5D-4359-BDF6-AC41ED9…  real         nein     3183        0
 2368 │ Polygon(387 Points)   {B12FC74A-D39B-4A8A-8DD9-B6406A1…  {5C5B29E1-A75A-469F-B79D-A338947…  real         nein     5452        0
 2369 │ Polygon(210 Points)   {B4F082C1-B95D-4BEE-A827-410ED60…  {B3064E11-6C01-45AA-84F3-172B1C8…  real         nein     3256        0
 2370 │ Polygon(461 Points)   {3DA9F56D-57C4-4ECA-AAD3-E713FFF…  {4E9BF9F9-37B8-4BE4-9A64-BBFF352…  real         nein     8606        0
 2371 │ Polygon(392 Points)   {00CC6EE4-2D0E-4184-A31C-6E9D83A…  {4F2C1BB7-A563-42D2-AD0E-C0560BD…  real         nein     1793        0
 2372 │ Polygon(1201 Points)  {771D40E6-14B0-41B6-8FB0-E88D13D…  {D0350453-7F55-4363-B340-78B5674…  real         nein     1038        0
 2373 │ Polygon(435 Points)   {68B987EB-E504-4B19-AB80-F99FD0D…  {1756EF1C-7D09-4DC0-B9ED-0F3468B…  real         nein     1299        0
 2374 │ Polygon(601 Points)   {F550C8DE-8270-4FAF-92FA-DF688B6…  {03EB7471-E8EA-4BF3-8FB8-8B2E6B0…  real         nein     2013        0
 2375 │ Polygon(362 Points)   {2D947E66-C2C8-4FB4-B414-98140A6…  {33A98EFB-EE0D-44BC-A88E-120042F…  real         nein     2732        3
 2376 │ Polygon(346 Points)   {342CB0C6-DD75-418B-AF27-606D357…  {94F64DC9-57A5-4121-8097-0C4EBC7…  real         nein     8573        0
 2377 │ Polygon(330 Points)   {0350A5DB-C2D0-4428-A76D-0193917…  {6E2A02B7-BF6D-45D1-91CA-51F55CF…  real         nein     5013        0
 2378 │ Polygon(575 Points)   {D8C10F00-B09F-49A7-AF94-38AF1C8…  {AFE9C35F-E36A-48B8-8C6E-8A0C4D5…  real         nein     8525        0
 2379 │ Polygon(684 Points)   {6225A6E8-29D3-4A7B-8BE4-983808B…  {24F876F2-48EE-4326-8DD0-C070CCB…  real         nein     1415        2
 2380 │ Polygon(712 Points)   {A1B7B417-94AC-4073-9398-77E7727…  {44334E12-4717-48BE-8B08-81A2C0F…  real         nein     6958        0
 2381 │ Polygon(402 Points)   {51A8F8A2-0AD8-4973-A57A-A32A624…  {D52636F7-14A2-4CCD-922C-B9F5860…  real         nein     1753        0
 2382 │ Polygon(464 Points)   {921A6FE1-15D4-4307-A815-A7AB128…  {DB3F61B3-A307-4648-A40B-5F3C1CB…  real         nein     2035        0
 2383 │ Polygon(256 Points)   {DCCBA9B5-DD91-4136-B557-0478AB8…  {EEFF45E4-1781-4779-873C-5280875…  real         nein     7151        0
 2384 │ Polygon(560 Points)   {8153F69A-EDDC-44F0-A62B-333D158…  {A821F27E-FA49-4F33-B423-F308D0A…  real         nein     8376        0
 2385 │ Polygon(616 Points)   {0E3D6E90-BDC9-4EF2-8A8F-17778BD…  {3341C9C3-0B2C-4002-8037-CBE92EB…  real         nein     4305        0
 2386 │ Polygon(339 Points)   {39868C03-132D-45C5-9647-768B7C1…  {48FF3846-CA6C-437C-AC65-7F006ED…  real         nein     1720        0
 2387 │ Polygon(145 Points)   {3EF2D983-66E4-4A2E-BFBB-134F4C3…  {95F1E461-E312-45B7-9882-C98EA01…  real         nein     7228        1
 2388 │ Polygon(285 Points)   {FE4DFD9E-78C6-4807-9245-229E4FA…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8038        0
 2389 │ Polygon(287 Points)   {737BD128-1FDB-4E01-9332-7D9EC66…  {76A2F53F-362E-40A9-A035-9E29C0C…  real         nein     7127        0
 2390 │ Polygon(516 Points)   {5B7BEC38-4AA1-4100-A801-766E2D8…  {6C2B3840-952E-45AE-8C83-419555C…  real         nein     1692        0
 2391 │ Polygon(400 Points)   {8C0AB568-1E11-405D-93D6-5D8C7FF…  {C81F4758-3BFE-43B0-BE2B-0C39879…  real         nein     5512        0
 2392 │ Polygon(1159 Points)  {30FE7718-E3B4-4F15-869C-65B4247…  {13EFE38A-8D0D-4406-909E-55879C3…  real         nein     8132        2
 2393 │ Polygon(390 Points)   {ED07EAF9-54F9-45DA-8FAF-22030ED…  {856A9274-9188-44A9-A1AF-A7BA2A1…  real         nein     6595        0
 2394 │ Polygon(346 Points)   {D6660D4C-2659-4FAE-A6BA-A925D73…  {422B2B44-370A-4C08-ACA7-6F666FC…  real         nein     5235        0
 2395 │ Polygon(284 Points)   {A414F5BF-01DB-4F19-AA06-8337556…  {3EFD7C7E-FEFC-47A4-A8D8-15B16CC…  real         nein     8646        0
 2396 │ Polygon(370 Points)   {48C44ED4-B7AD-4779-9F61-E159EBF…  {B54C6B4F-6748-46A3-8413-EA85B14…  real         nein     5322        0
 2397 │ Polygon(316 Points)   {88C64895-18F5-4770-AACA-348D502…  {174AA036-A680-4BCC-A2BD-87B9DDD…  real         nein     1638        0
 2398 │ Polygon(717 Points)   {81609786-A036-4330-B8D8-8BB4E97…  {D284CA0C-A8D7-4983-9A6E-8C2AD0A…  real         nein     9217        0
 2399 │ Polygon(580 Points)   {1EB98209-1F63-4CC0-B707-6A0D9A3…  {66E4A6AF-C4A7-47DF-8BDA-FEBF021…  real         nein     6872        1
 2400 │ Polygon(445 Points)   {9AF0BDD0-046C-4AA0-B320-BA225E5…  {AD50A7D5-FBE3-4F0D-AC22-3A7EEC6…  real         nein     8357        0
 2401 │ Polygon(339 Points)   {6AE40FF8-86A8-499E-96BD-8F9CF52…  {AE2D5DCB-1BB2-4129-9447-A7E256D…  real         nein     6538        0
 2402 │ Polygon(255 Points)   {825A2442-2FA7-4252-9605-CD6E96C…  {4B66805E-95A6-461F-9277-3544AAF…  real         nein     5077        0
 2403 │ Polygon(948 Points)   {BFE85B0A-91A3-4E4B-BA0A-68038DB…  {B0BA3FF3-3E3F-47B4-B8CB-C6E33E1…  real         nein     1413        0
 2404 │ Polygon(188 Points)   {5E73EABD-606A-4136-825C-1CB50AA…  {B42DEB2B-08C2-4D55-ADBC-5EA6524…  real         nein     7174        0
 2405 │ Polygon(502 Points)   {2B9F0721-6BE9-4F31-A9F6-E4F0DD0…  {10A609C7-F2B8-4F76-82F5-D2A22C9…  real         nein     5237        0
 2406 │ Polygon(402 Points)   {71F728D5-EF31-466B-8E3C-C523B21…  {884AB832-3FDA-4F38-81AE-1D1CA2D…  real         nein     8580        3
 2407 │ Polygon(942 Points)   {3AD25A8E-90F1-4CB9-933B-D002B5F…  {CEECC47F-90CD-43B7-8697-C71CFB9…  real         nein     6260        0
 2408 │ Polygon(299 Points)   {50C939D0-0086-461D-84D0-C4736FD…  {FAF4301A-E679-457F-9866-034C392…  real         nein     2207        0
 2409 │ Polygon(1038 Points)  {E5444031-BF37-4ECD-BA88-31257C1…  {A3C4D91A-A2D8-454F-AE16-40A155A…  real         nein     8133        0
 2410 │ Polygon(607 Points)   {1522802E-3A9A-4A5E-95AC-0E54340…  {E0956B25-288F-4C4F-BBE9-B3EBA04…  real         nein     1353        0
 2411 │ Polygon(197 Points)   {B09946E3-48D3-43A0-BC67-9557D7A…  {C7C1B376-B19A-4B9A-B97A-A89FBF9…  real         nein     6951       19
 2412 │ Polygon(249 Points)   {07DCB288-682A-451F-BDEC-7C00C43…  {40FE345F-85E6-4814-8C81-0452F69…  real         nein     1584        0
 2413 │ Polygon(722 Points)   {D4948AC2-D642-4C96-A86F-D5CC338…  {7967A4B8-7170-46CD-A9E3-AEF6F62…  real         nein     1515        0
 2414 │ Polygon(457 Points)   {92B49436-1DDA-466B-9D08-C7F18E0…  {93C770E6-61FE-414B-BCFD-3113744…  real         nein     8207        0
 2415 │ Polygon(612 Points)   {58260E2C-B292-4820-A63A-238C489…  {42F76BCB-49EE-409D-B974-5142757…  real         nein     8466        0
 2416 │ Polygon(497 Points)   {994D4152-3524-48CA-8CF8-0EB3350…  {D7234427-6487-4F36-80AF-B92FEE6…  real         nein     2024        0
 2417 │ Polygon(549 Points)   {0D6B5ECF-042E-41E8-AB50-6C21D99…  {910F9A14-7228-4666-BE2D-67965C3…  real         nein     9425        0
 2418 │ Polygon(400 Points)   {F76C89AF-7EE0-4C1B-AFF9-44C65A9…  {6DC3A813-2612-416E-86C5-D67B62F…  real         nein     5645        2
 2419 │ Polygon(386 Points)   {BCA036CE-98CD-4EF1-B5B3-DD178FF…  {A403996C-614F-4375-9EDF-C64F650…  real         nein     1785        0
 2420 │ Polygon(343 Points)   {4A2F3C09-6B4A-4A16-9664-513D603…  {5320E146-1248-4D14-8313-9722899…  real         nein     1677        0
 2421 │ Polygon(491 Points)   {92CB2FC6-AF32-40CB-9970-94428EE…  {24EEC483-210C-42B0-895C-53D0CAD…  real         nein     6804        0
 2422 │ Polygon(572 Points)   {E4C14823-25BF-4012-9250-B5D5CE4…  {4A3B1CF0-1965-442E-8CC6-C07BB68…  real         nein     5277        0
 2423 │ Polygon(412 Points)   {8D27DD3F-3125-4812-AB98-75D4F67…  {3BCD8EC2-C97B-437D-9ADA-B625574…  real         nein     1663        2
 2424 │ Polygon(437 Points)   {1BFA88F0-F933-4B1E-B84E-DD05895…  {4F60F526-945F-4D52-9D19-062232B…  real         nein     1694        0
 2425 │ Polygon(270 Points)   {324C29AB-C689-4DF5-BB62-366EF26…  {7D822471-53FC-4224-9CCD-5997F1F…  real         nein     8556        0
 2426 │ Polygon(258 Points)   {A6D25BC7-C8BC-4CCB-A37B-1842255…  {96533C55-639C-4EED-B9B5-DBDD2D9…  real         nein     4585        0
 2427 │ Polygon(213 Points)   {0C765436-A89B-4966-9531-F13DC5A…  {2F563154-734E-4F31-8807-2F7761B…  real         nein     2556        2
 2428 │ Polygon(488 Points)   {7F164F55-E44E-4535-94BF-A781459…  {B0429CA8-7B81-40EE-99E8-EA54D0C…  real         nein     5646        0
 2429 │ Polygon(380 Points)   {5875A7C9-9A04-4FEF-99A4-2838058…  {22DF51DA-EC5E-4E1D-ABA1-328DE84…  real         nein     5723        0
 2430 │ Polygon(217 Points)   {4AF66536-EDB3-4E32-A81F-996A8C6…  {D680CD92-DAAB-47E8-A656-52D7004…  real         nein     9216        2
 2431 │ Polygon(532 Points)   {33415F36-B1E7-49E2-99D0-6CCC003…  {0D6E5E7C-64E7-44E9-9011-BE21711…  real         nein     5643        2
 2432 │ Polygon(189 Points)   {9FDE8819-B83A-4C81-8BFF-7EC3E30…  {6C6EAC7F-1E6A-4DD1-B2C8-9E10AE1…  real         nein     8219        0
 2433 │ Polygon(256 Points)   {D57E22C8-989B-4004-B3F0-AB9772D…  {0CC308EF-265F-406F-90CE-2003D7D…  real         nein     3632        3
 2434 │ Polygon(351 Points)   {3D6C74D8-380D-4109-AACE-CD3F38A…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8045        0
 2435 │ Polygon(517 Points)   {BE945701-7034-42FE-873E-CC9CF83…  {D4CDFDE7-13B2-48C5-B3AC-FD47E09…  real         nein     1040        3
 2436 │ Polygon(355 Points)   {393ADE67-B4BB-46BD-80D5-A63011F…  {1A58E50A-3E09-4A38-9B58-8756046…  real         nein     8532        2
 2437 │ Polygon(369 Points)   {EA5C7F1D-295E-4016-98D9-A5BA879…  {1FFB7BDD-4CCD-4740-A614-439683D…  real         nein     4105        0
 2438 │ Polygon(1142 Points)  {43FD68B8-010B-4DE8-9E42-667AEE3…  {633667B9-33FD-41BD-B4AE-2A81AA7…  real         nein     1081        0
 2439 │ Polygon(171 Points)   {416A2986-1B0E-4A8B-A2E5-F17DC11…  {C66E1655-6D2B-4E92-82A4-3731A99…  real         nein     3608        0
 2440 │ Polygon(1109 Points)  {015F48A0-BF55-4341-B68C-D156970…  {332A410B-4477-4BEF-B2D6-7163E63…  real         nein     9320        0
 2441 │ Polygon(421 Points)   {E5C61C17-8509-484B-9D84-5751936…  {0C0FF059-CA47-4687-8214-8557202…  real         nein     7312        0
 2442 │ Polygon(1049 Points)  {C9CD2828-772E-4DF6-9D52-8494118…  {52F4EED9-39E4-40FC-BFCA-A5F446C…  real         nein     8640        0
 2443 │ Polygon(230 Points)   {FCBD65AD-9CC6-4FEB-B9BB-825350B…  {83699BD3-DE4E-47D0-9046-2FEE926…  real         nein     1721        5
 2444 │ Polygon(415 Points)   {54C20E28-C366-48CA-AFE4-83A4406…  {E612247D-0AE8-4705-87B0-B16E363…  real         nein     5023        0
 2445 │ Polygon(441 Points)   {8D31F7BB-4304-432E-9264-F569829…  {65E5E336-E9C0-40FD-9C82-9DCC801…  real         nein     1423        2
 2446 │ Polygon(538 Points)   {1F073E10-089C-488F-B884-51CB19F…  {6D53A696-D091-4B8B-A66C-1FB14F7…  real         nein     8305        0
 2447 │ Polygon(602 Points)   {BFEB7404-89E5-4673-B5EF-1B40E88…  {01EEE030-B236-48EE-8F1E-0F576A0…  real         nein     8607        0
 2448 │ Polygon(435 Points)   {D477764B-5845-4839-99DC-A6D41B4…  {8AF4D8C0-8BE9-485D-86A2-E178625…  real         nein     3172        0
 2449 │ Polygon(413 Points)   {6CBD0E0B-EF70-496D-BAD2-D0B32AF…  {AEF04BD4-B485-4DE7-B907-41C7923…  real         nein     3417        0
 2450 │ Polygon(105 Points)   {F8C074E5-F37D-4647-ABA2-0C223D7…  {D1E149AF-5669-4028-B03F-7962831…  real         nein     8553        3
 2451 │ Polygon(199 Points)   {44DB96F5-CF62-4BE1-A42B-3CFDC6A…  {D88C45E6-239F-498B-94BD-CE4A4E6…  real         nein     1955        0
 2452 │ Polygon(420 Points)   {2B1FE63B-D996-43CC-BF33-95395F4…  {7FF30F1C-7131-4705-B874-3C74BC4…  real         nein     8914        2
 2453 │ Polygon(360 Points)   {3DF857E4-E3E8-455F-B037-F692A4E…  {55D702DE-AA3E-4540-86D9-80800B4…  real         nein     4944        0
 2454 │ Polygon(335 Points)   {B41AD560-F2D1-4367-A0B9-0B46EC2…  {51F50B68-431E-4BF9-8CA0-7A77312…  real         nein     1426        1
 2455 │ Polygon(887 Points)   {D88EDFF7-A586-4896-A74F-20A57FC…  {CAF0B749-5C73-44A7-98BE-68D07AB…  real         nein     1077        0
 2456 │ Polygon(474 Points)   {0F0016FA-82A4-4EDD-B109-C1DA1CC…  {C8110534-A848-4402-AD81-89956FE…  real         nein     1427        0
 2457 │ Polygon(570 Points)   {71D2B4D0-1726-4727-9FE2-9C805E4…  {2545B791-2C8B-40E8-B2CD-D58F8D2…  real         nein     9542        0
 2458 │ Polygon(382 Points)   {A8EFBDD1-DE59-4C5B-AD1C-CC6FD6A…  {150006C5-7BC1-463B-8F53-84140F8…  real         nein     1687        0
 2459 │ Polygon(313 Points)   {47D94743-3701-48FB-B126-A010E46…  {F60CEB21-1152-432A-A859-E9E02B0…  real         nein     7408        0
 2460 │ Polygon(287 Points)   {D74826C1-DB79-4F2F-B242-1F353E0…  {AF67C59F-4650-4BBD-A9CB-915758A…  real         nein     1690        2
 2461 │ Polygon(802 Points)   {F03C3404-439C-4D01-A14E-A6CC5FF…  {CCCEEDC2-1FC5-4D47-8BF6-659AB35…  real         nein     8342        0
 2462 │ Polygon(115 Points)   {B6B9BDF3-D112-42EF-B1EA-50127CF…  {6A46AFC7-31AB-4C56-A5EE-F75E127…  real         nein     3966        1
 2463 │ Polygon(391 Points)   {6A57BB67-D3B8-46F0-A6B0-CAA08A1…  {B62AA737-9C1B-4306-87DE-05743A8…  real         nein     6244        0
 2464 │ Polygon(817 Points)   {6B4CAA4E-DA12-4247-A7F8-A321685…  {4358693C-1EC0-4379-AEAF-037A01A…  real         nein     1237        0
 2465 │ Polygon(89 Points)    {B132FFE7-8922-4005-8507-1ABD2EC…  {A35E9660-C275-4AA8-9EF8-F8B2109…  real         nein     3032        0
 2466 │ Polygon(502 Points)   {34614ED8-7350-4ABF-8645-743BB9D…  {A0545F3E-A081-4747-A7F5-BA01F75…  real         nein     8374        2
 2467 │ Polygon(273 Points)   {5291432B-27DB-46D1-A218-003A3E6…  {B38C61AB-42CA-4779-B61F-0DF89B7…  real         nein     4922        0
 2468 │ Polygon(480 Points)   {A3A3E3B9-5607-4C5D-A908-720C4EC…  {914FECC1-608F-4FED-AF71-A703053…  real         nein     2345        3
 2469 │ Polygon(224 Points)   {42646DEC-B805-431F-88FE-14A5A6A…  {AFFDDF0F-75F7-4FF5-AAF8-EF20B15…  real         nein     3705        0
 2470 │ Polygon(130 Points)   {22DC19E2-9BF4-4942-94B9-DC676AF…  {013452D8-2E2B-4888-979F-8E3E040…  real         nein     1967        0
 2471 │ Polygon(652 Points)   {196F3C8C-BCB6-453E-B7BF-7F7A6BD…  {E93D1523-E3E6-4044-8AD7-B9F38AA…  real         nein     1555        0
 2472 │ Polygon(701 Points)   {16CB5B73-134A-4094-B172-7378532…  {7D8ECA57-F2D6-4D2E-93E5-1C489C1…  real         nein     8483        0
 2473 │ Polygon(340 Points)   {4E69F2D5-ACFA-41B3-867A-4C8EFD6…  {AFCF4711-AF5A-4A74-B82A-4AE5492…  real         nein     8532        0
 2474 │ Polygon(1143 Points)  {076847D2-FC3E-4FCC-9680-BA9D74C…  {20998836-D05E-47C2-9763-A2B6BEA…  real         nein     6284        0
 2475 │ Polygon(421 Points)   {B3706876-D0F6-4128-A072-BC95613…  {B6E71797-E578-40B1-B924-6FC4CE2…  real         nein     1645        0
 2476 │ Polygon(345 Points)   {222310FE-FB64-4C8B-B31D-9431D4F…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8052        0
 2477 │ Polygon(681 Points)   {C72EAEE6-5A80-42CE-A3C0-C5D7F34…  {6B0D3901-F6BA-415A-BB23-2A43FA2…  real         nein     1430        0
 2478 │ Polygon(321 Points)   {F264AC7D-D7B1-486D-92D2-6A51739…  {C4754D2A-1FE5-4938-AC22-3E0BD5D…  real         nein     6243        0
 2479 │ Polygon(275 Points)   {2BC659E8-FE08-42DD-AF3A-5A91C9E…  {ED722735-D51D-46DF-B079-8F0F739…  real         nein     8236        0
 2480 │ Polygon(363 Points)   {A41314D8-535F-4D3F-8586-ADDC687…  {22C9DC61-C3ED-44AD-A0DB-32A6FCF…  real         nein     8833        0
 2481 │ Polygon(661 Points)   {C2137475-A19C-4553-8033-DDACA58…  {0273D426-B887-450C-A536-40028CC…  real         nein     8165        0
 2482 │ Polygon(522 Points)   {BC661BDB-57CF-4405-9354-C4D4EEF…  {DF49DAA3-EF9F-42F8-A9B0-EB22653…  real         nein     6402        0
 2483 │ Polygon(431 Points)   {2B79CA16-5AEA-4EF0-8397-AA1C8DA…  {C4C10AA0-B3F3-452F-BED5-6E296EE…  real         nein     1615        0
 2484 │ Polygon(788 Points)   {C6F4EFE6-4BC9-45C1-86FF-F1EDA7E…  {5286BF96-3EC9-431D-9ADE-FF4F064…  real         nein     1407        4
 2485 │ Polygon(905 Points)   {209A49C8-B875-4A5A-BBB1-8C22C5F…  {D165A7B4-CB7F-4F5C-8C91-51CEE25…  real         nein     1846        0
 2486 │ Polygon(149 Points)   {1B0875CE-67D3-45C7-BABA-06BF899…  {3BA5E4DF-2C5B-487E-A617-A7AF707…  real         nein     1978        0
 2487 │ Polygon(543 Points)   {F5D69F27-E089-4CEC-B443-AC65519…  {7DE2CD6F-83FD-4A70-B029-4983FAE…  real         nein     1464        0
 2488 │ Polygon(511 Points)   {692E914B-38DB-463F-921E-DC24066…  {A81EB90C-B33A-4339-8531-C67C513…  real         nein     5423        0
 2489 │ Polygon(363 Points)   {6B765E63-95D9-41E5-AC5B-FB303D4…  {7C85D556-D013-4973-97D6-011C305…  real         nein     1673        5
 2490 │ Polygon(474 Points)   {46EFBE0B-AA3B-494B-A7AC-862DF54…  {50EC0345-F3D1-4D57-91A7-E7C37A4…  real         nein     1253        0
 2491 │ Polygon(253 Points)   {6D5FC41F-D609-4FC1-8852-3E465C9…  {46E16B74-F5A7-45E2-9569-A42D076…  real         nein     1763        0
 2492 │ Polygon(96 Points)    {EF400DD6-FE23-456A-A65E-D42E33C…  {556B341F-2B77-4987-ABE9-3684CEE…  real         nein     4432        0
 2493 │ Polygon(518 Points)   {12F50B5A-A969-4EE1-9794-D816A07…  {0B66B6D3-D4AA-4AC4-B05F-7623208…  real         nein     1485        0
 2494 │ Polygon(513 Points)   {CF182ECE-4DC6-4575-8F48-F8E6787…  {D24CEDFF-1CD7-4389-B323-942E5D3…  real         nein     4933        0
 2495 │ Polygon(422 Points)   {F3DBB231-219D-43F8-9B88-9BD0451…  {43DE4F8A-CA71-4A63-97AF-AF33AAC…  real         nein     6283        0
 2496 │ Polygon(385 Points)   {14A3B253-59A7-40CB-8F31-E51A7A4…  {AEB65447-6F89-44C0-9428-1B0AA1F…  real         nein     1175        0
 2497 │ Polygon(232 Points)   {3BAC4D2E-A80F-4509-B9FE-B01B831…  {EB49C212-B44F-444B-ACE7-CDC5E7E…  real         nein     2552        0
 2498 │ Polygon(74 Points)    {38DB25A2-48F9-4020-925B-0B6ECFC…  {3AF4679E-4618-4E70-A817-A4F507A…  real         nein     7018        0
 2499 │ Polygon(167 Points)   {7D60E01B-B674-4C56-BA2F-5BF892D…  {E28E1AED-7415-4C78-B520-9908EEB…  real         nein     3902        0
 2500 │ Polygon(427 Points)   {734A64A2-E95C-46C9-A391-EABE9EE…  {7B115A6E-12C2-4ACE-B779-F825563…  real         nein     8564        2
 2501 │ Polygon(204 Points)   {1D69F43F-C1C1-4218-B89B-7D8A195…  {35AD0C58-D66A-4205-8544-E7EBB5D…  real         nein     2046        0
 2502 │ Polygon(594 Points)   {50EC6C3C-5C60-49D8-9544-BE921E3…  {929018FC-3795-4277-B326-9A6485B…  real         nein     8113        0
 2503 │ Polygon(495 Points)   {27B60BCC-3188-4F7C-8F7F-F7B78AF…  {02F16BC7-777F-48A3-8CAE-97D6FA2…  real         nein     1247        0
 2504 │ Polygon(386 Points)   {62696E48-24EE-480E-84B7-51D7336…  {05E93770-C370-45A6-9A58-CA4D8F5…  real         nein     1304        4
 2505 │ Polygon(842 Points)   {4DB6B451-6950-4B2B-A998-93EC0D1…  {051F83F7-72BB-4496-B395-FADFE1F…  real         nein     1271        0
 2506 │ Polygon(469 Points)   {FAFE956C-0FF7-4B5E-816A-14EC2D6…  {38BCC1DB-BE0B-4BA3-9E76-DF28574…  real         nein     8889        0
 2507 │ Polygon(269 Points)   {893B610E-3536-4FB7-B58D-AEA82AB…  {E1470B53-22C1-49A7-9BFD-145A8C5…  real         nein     4469        0
 2508 │ Polygon(383 Points)   {23113A2A-0702-4EE3-A588-98B7786…  {6FFA4A1F-B6E7-4B89-967B-9594D4C…  real         nein     5076        0
 2509 │ Polygon(276 Points)   {A9A73F08-2CB0-451C-AFC6-2DB17F5…  {6BDBE76C-3914-42BE-8278-547A9FA…  real         nein     1694        3
 2510 │ Polygon(271 Points)   {5828BEBD-DCCA-4EA3-9E77-5518305…  {FD70AD49-C0CF-433E-AB72-D91EC20…  real         nein     6954        0
 2511 │ Polygon(435 Points)   {B1B14D6C-EAAD-471E-ABF9-079C1AA…  {ABFD95B4-33ED-4D5F-84C1-1974D91…  real         nein     1744        0
 2512 │ Polygon(1016 Points)  {7A4D1728-4486-4D01-AAA8-519254F…  {0F53C41E-B95B-49EA-A2E8-625A24C…  real         nein     6900        0
 2513 │ Polygon(358 Points)   {5EC60F07-D2F4-4BB6-B7AA-79520CE…  {4BFB7C1A-C879-42A6-B167-FD10783…  real         nein     6033        0
 2514 │ Polygon(382 Points)   {A2745A6F-9EE4-466B-B0B2-5D645E9…  {82006056-2EE2-42C6-9AB0-8D2924A…  real         nein     1756        0
 2515 │ Polygon(297 Points)   {1468355B-754A-41AD-8AB5-7DC306E…  {787C5232-FB6F-4FAF-907E-6AC8DA2…  real         nein     1589        0
 2516 │ Polygon(297 Points)   {2220CC7F-EB06-495B-B458-8BD55E5…  {D5AEA87E-B61E-42C4-87C2-7A95786…  real         nein     5323        0
 2517 │ Polygon(421 Points)   {4ADA5B8B-6E61-455D-A5E7-B88F98F…  {13127C5B-E033-404C-B2DC-DDD4E75…  real         nein     8522        0
 2518 │ Polygon(1109 Points)  {54AEA718-95F9-49D3-8AFD-4A0AF2F…  {FD0AB8AE-26B9-47CF-AB27-250E647…  real         nein     4525        0
 2519 │ Polygon(505 Points)   {3243497D-FD2E-4D68-B57D-3E1F310…  {467F1074-4433-4BB5-9953-FE4261E…  real         nein     1424        0
 2520 │ Polygon(388 Points)   {8791D850-4206-4700-83CA-51C0E8E…  {81352942-7B21-467F-A17D-13F8A53…  real         nein     2572        0
 2521 │ Polygon(260 Points)   {AA5ABA0E-FEE0-4AC9-B659-3347250…  {C718ECB4-C694-4776-A616-DFD9FC1…  real         nein     1958        0
 2522 │ Polygon(702 Points)   {A5CD3955-2913-4836-8EEB-773A112…  {545D4ADD-DFE6-4EF8-88DA-BF33DDD…  real         nein     9115        0
 2523 │ Polygon(1210 Points)  {E1F34FC0-14E1-4C21-B28E-D6BBDFB…  {356F5076-F194-4989-9698-4B18879…  real         nein     1036        0
 2524 │ Polygon(790 Points)   {E70C95B4-66F1-491D-8D51-409B7B2…  {C108DEF5-EB65-415C-BBE2-0A19AB5…  real         nein     1035        0
 2525 │ Polygon(350 Points)   {A60890C3-6E49-43BA-B2EF-839E24C…  {D4FFD617-5083-417D-AB8B-CB449E5…  real         nein     6936        0
 2526 │ Polygon(479 Points)   {EF351DD7-FA80-4ABF-BEB7-29116DE…  {0E7CE130-95BB-4CF2-A175-5129014…  real         nein     4924        0
 2527 │ Polygon(232 Points)   {8F190A1B-CA32-41F4-8482-413BB03…  {EDB1BABE-1E8E-44D9-B781-AAEB6B0…  real         nein     1966        2
 2528 │ Polygon(94 Points)    {9756BBA1-C25C-45E0-9677-B113AB8…  {EE7C3602-A707-4B29-BC3B-E2D7015…  real         nein     1941        0
 2529 │ Polygon(286 Points)   {A8A9D507-9FC1-42A6-AED6-E1A8640…  {1440470F-4996-4E48-8A3D-D8A9578…  real         nein     5046        2
 2530 │ Polygon(569 Points)   {81BF2DAE-AF54-46FF-91B7-11130B5…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8050        0
 2531 │ Polygon(309 Points)   {27975919-EECC-423D-AB97-1DB8E74…  {50816A4A-C547-446E-8BF5-4EFF91C…  real         nein     6808        0
 2532 │ Polygon(884 Points)   {2D9D76B2-897B-4422-AC4A-7AA4299…  {57A5C2FB-2E85-45C2-A6DF-DBAA962…  real         nein     1123        0
 2533 │ Polygon(809 Points)   {E142BC5A-04BD-4A84-9DE8-7194198…  {6817E634-4668-4CA9-BDE9-854F996…  real         nein     9413        0
 2534 │ Polygon(478 Points)   {8AE36AD4-8872-4667-85EC-F902D75…  {F697EF34-966D-4CB1-90C5-542DA7C…  real         nein     8735        0
 2535 │ Polygon(476 Points)   {70403CA0-4DDE-4709-967B-B78738E…  {4C116879-9281-4233-BF2A-878D48A…  real         nein     5083        0
 2536 │ Polygon(412 Points)   {0999F1ED-98C7-40AF-9EB2-6EEC383…  {583749E2-4E82-4B26-9970-59BEA7B…  real         nein     5453        0
 2537 │ Polygon(787 Points)   {1C3709E2-8462-46C6-A5B6-0F542A1…  {98B82C91-4C60-4144-B1AE-491AA90…  real         nein     1609        3
 2538 │ Polygon(685 Points)   {FBF4E6A5-7B71-4633-9EF4-26DCD92…  {89C69838-B80F-49CC-A66D-8130712…  real         nein     8165        2
 2539 │ Polygon(717 Points)   {F49CA3EF-7610-4D70-864B-43DB977…  {11B56925-9FB1-4191-B476-5EEF09E…  real         nein     1305        0
 2540 │ Polygon(1025 Points)  {00B61AC0-A156-461A-900F-6F8092C…  {13BE26F9-9175-4107-98DB-DC45F05…  real         nein     1027        0
 2541 │ Polygon(140 Points)   {476F75B8-A17C-469B-91D0-08A063D…  {DFDE6CB3-6C2B-4126-8DBA-316377A…  real         nein     3995        3
 2542 │ Polygon(416 Points)   {6626F9B3-36AE-45F6-9C61-D5697B2…  {C583D20F-5050-4161-B146-AD1F8E9…  real         nein     9216        0
 2543 │ Polygon(835 Points)   {5DA67C03-40B7-43B9-AE56-B8EA5CC…  {53945C8C-796A-46DC-9E9B-6D94178…  real         nein     1185        0
 2544 │ Polygon(392 Points)   {67ED5506-9722-477E-8714-7F46369…  {C508AEEF-CA27-41A3-8097-7E24E1D…  real         nein     3213        0
 2545 │ Polygon(406 Points)   {6E330120-B739-4262-81FF-B27B1D5…  {83F9FF4D-28EF-4EB4-A2D6-77ADCD7…  real         nein     8259        0
 2546 │ Polygon(288 Points)   {0ACB810B-2F98-400C-AFD3-17EA94D…  {C9F55664-C4DE-455D-B8A5-CBFBFA9…  real         nein     6979        0
 2547 │ Polygon(716 Points)   {A72125AD-0407-40FB-AFBD-4A57E6F…  {44E7A5BE-8F29-42DA-85B7-96C53CE…  real         nein     6284        2
 2548 │ Polygon(601 Points)   {85D6585B-F7B6-4FC9-B2B3-BEF85BE…  {C4D4B06D-FBF9-4653-9526-9105024…  real         nein     1774        2
 2549 │ Polygon(522 Points)   {080E42D7-DDA2-4C3C-AE33-1DB65A4…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1007        0
 2550 │ Polygon(553 Points)   {C0261CAF-FA1A-4D2A-9629-095ED66…  {734641CD-0E14-4B02-B409-598E6CB…  real         nein     8312        0
 2551 │ Polygon(379 Points)   {51032FC9-6904-47BF-96A2-DA1DE6C…  {7747CB29-9533-440C-B5F6-804FBED…  real         nein     9553        0
 2552 │ Polygon(883 Points)   {5554035E-0F0F-498A-98F9-B4F5F2F…  {3E91DE4C-A61B-44B4-BD1E-670682E…  real         nein     8566        2
 2553 │ Polygon(560 Points)   {0D40D141-0FAC-4D74-AB4A-19C84AF…  {44673E98-CA7C-413B-8006-EB3D4C2…  real         nein     1532        0
 2554 │ Polygon(610 Points)   {E8B3B4BB-694D-4CB9-9FC1-E513FC1…  {EF5E6593-8871-45D2-AA0D-12CF764…  real         nein     6363        0
 2555 │ Polygon(556 Points)   {9B8EB3C8-4FA1-44E2-BA45-EF39567…  {C28819D5-0256-4515-93C3-B76488A…  real         nein     3800        3
 2556 │ Polygon(239 Points)   {148AC639-68D3-41E0-B76B-6CE62BD…  {DD2ADB64-24D5-46C5-8679-4BC3614…  real         nein     3415        2
 2557 │ Polygon(605 Points)   {4FBEDB29-F7BC-4FCA-82DF-80077DF…  {36B11E8A-9AC7-4362-8A78-9E93A61…  real         nein     1110        0
 2558 │ Polygon(347 Points)   {25D22598-3DBA-4A0B-89AA-2CD8A08…  {379B2692-BDC6-45F9-97F0-72BB07C…  real         nein     8468        2
 2559 │ Polygon(470 Points)   {FDDA0B16-742F-4765-9FA5-BC71F5C…  {ACA30C76-2534-4D6B-BADB-602CF87…  real         nein     6579        0
 2560 │ Polygon(509 Points)   {52CADE44-3697-4EE6-A04D-ACDD7FC…  {4BD8B96F-2560-43F8-94A8-5675361…  real         nein     8586        2
 2561 │ Polygon(362 Points)   {8FA63EEE-FCEC-4C02-98ED-DE197BB…  {7CBDB11E-0341-4D55-B223-A97AE9B…  real         nein     8566        0
 2562 │ Polygon(634 Points)   {6F640286-36B2-435D-A227-0BC19CB…  {ECFADABA-ABC1-42A3-A687-038F074…  real         nein     1626        0
 2563 │ Polygon(439 Points)   {9D37D285-9896-4FA9-B09A-8F20341…  {8996A659-333B-43A0-89DA-1A5F46B…  real         nein     1355        0
 2564 │ Polygon(755 Points)   {1EF8A218-D991-4680-94F8-6195E46…  {779E66DF-7F60-4E7C-B761-90C90F2…  real         nein     6285        0
 2565 │ Polygon(363 Points)   {C59D428A-09E5-47F9-A20F-1A8FECD…  {9AAB54A1-4CA5-45E5-8A5E-B132D5C…  real         nein     8914        0
 2566 │ Polygon(433 Points)   {E46396B9-6495-4C2E-941F-EB56762…  {80132ECC-E1E4-4C21-887F-89099A5…  real         nein     3112        0
 2567 │ Polygon(556 Points)   {22A6C5D7-5D30-4556-ADED-099B4B2…  {A98C9157-2BA6-46A2-9F19-4901709…  real         nein     1683        0
 2568 │ Polygon(557 Points)   {5E68F498-B901-4211-86F1-A299931…  {38665E50-E031-4A16-A014-CA26F6D…  real         nein     1303        0
 2569 │ Polygon(217 Points)   {2E54ED09-1EC6-4558-9E3E-C73AA79…  {20CA731F-2715-4B65-8761-DC2FB26…  real         nein     1871        0
 2570 │ Polygon(316 Points)   {7B335A10-8D5D-41D7-940F-C7A517E…  {6852294E-9865-4179-80DD-A7E9305…  real         nein     9453        0
 2571 │ Polygon(322 Points)   {44BF5EBE-CEA8-4EC5-AA90-F03A1BD…  {83251F69-25A4-465C-B825-CDE92AB…  real         nein     1568        0
 2572 │ Polygon(181 Points)   {45C178C1-34B5-4D35-96CE-C29F9B8…  {338D0F3A-7510-47E8-9165-6CDB569…  real         nein     3317        1
 2573 │ Polygon(376 Points)   {53AE133A-E596-43DA-B1DA-8EFFAA4…  {2D8FBC12-A066-4BDC-83E1-506FDFA…  real         nein     9306        0
 2574 │ Polygon(284 Points)   {60BFBECD-9BCE-4A60-8584-C6403C1…  {50C9A7C6-9509-474C-9360-65D644D…  real         nein     2744        0
 2575 │ Polygon(422 Points)   {438F6B57-50DF-41C3-97AE-B0D3C75…  {C6B46962-BE18-402D-99F9-FBD2001…  real         nein     7164        0
 2576 │ Polygon(458 Points)   {92185A3C-A3AC-421A-9CE3-846FED9…  {D59FFACC-285E-40CF-BDA2-081A8D4…  real         nein     8427        2
 2577 │ Polygon(335 Points)   {86C13887-2EDC-4B23-9D24-6BD1F91…  {C51A33A3-E1BC-46B9-8EAC-D47D8A7…  real         nein     5054        2
 2578 │ Polygon(222 Points)   {F615A3AF-0CF6-46EB-9594-C361894…  {4D82A478-2A4C-4C99-8801-67F68F1…  real         nein     1794        0
 2579 │ Polygon(261 Points)   {38118405-A41E-454A-88C7-6402CC7…  {F65AE3FE-CB0D-4E95-AF3F-1669BF9…  real         nein     1287        0
 2580 │ Polygon(266 Points)   {D9CA2963-20F1-4E37-849E-5F52958…  {2830DA7B-CFA7-4562-8897-D407B59…  projektiert  nein     6540        0
 2581 │ Polygon(397 Points)   {A809F254-0849-4C51-AE59-1EFADD5…  {EBACDF30-9BD4-4663-A963-647BCDB…  real         nein     4911        0
 2582 │ Polygon(488 Points)   {BD3EADCD-6937-42B1-B7E5-C41EEC0…  {EA474239-298D-4ADE-A246-EEA230C…  real         nein     1699        3
 2583 │ Polygon(264 Points)   {9A87F3D8-109C-4FC6-AEB4-4699275…  {9A4A18EA-8223-4CEC-9179-5C7BDFB…  real         nein     3428        0
 2584 │ Polygon(173 Points)   {82AA01E9-01C3-4161-9FF4-FDB741A…  {1C86411E-1414-439F-820A-B77F6F1…  real         nein     8195        0
 2585 │ Polygon(213 Points)   {CDE4D616-6185-4453-9F02-95BE7C0…  {7B12619B-8DAC-4D2F-9695-9239081…  real         nein     1113        0
 2586 │ Polygon(453 Points)   {6F5B6440-0CB2-4ACE-A7C1-248E520…  {57784CC2-6AED-4E3B-97B4-41CB260…  real         nein     1410        3
 2587 │ Polygon(273 Points)   {04A99817-5E24-4B9C-989E-A96EDCB…  {C422A6A9-786D-4FAE-9D4F-A7CDBE3…  real         nein     2300        8
 2588 │ Polygon(183 Points)   {8E0C6405-72C5-469B-A471-F630C08…  {829BA4CE-A477-4EF4-A98B-AD67735…  real         nein     8263        0
 2589 │ Polygon(364 Points)   {AFE42560-9411-4E2A-A9C4-66EEAEE…  {632640F2-F505-47AD-BD74-699398A…  real         nein     8883        0
 2590 │ Polygon(359 Points)   {9DE8BAFD-D912-40E3-BBA9-F8E1D24…  {7C1610DA-11E9-49D3-8579-F7561BE…  real         nein     6999        0
 2591 │ Polygon(458 Points)   {69D8E786-5FCB-42C0-8CD2-13A8BCA…  {12B2152B-EC8F-47A2-A26F-2BD9BC2…  real         nein     1037        0
 2592 │ Polygon(641 Points)   {ED1005D8-3E09-46DE-AABC-C77D980…  {454979F9-973F-412F-9A8E-5654278…  real         nein     3322        1
 2593 │ Polygon(370 Points)   {59854632-AFF8-4A45-8D28-2BF73D6…  {2BBCD5D0-FBBD-4FB6-B597-A7F4118…  real         nein     1609        0
 2594 │ Polygon(579 Points)   {0DDFE392-5F96-4F56-9D21-2388399…  {1E4CDAC9-D58A-4CAD-9E7F-1A70D49…  real         nein     1612        0
 2595 │ Polygon(443 Points)   {A526784F-A4E6-4D32-8061-5ECBE57…  {2486E557-1774-40D0-B4EC-03D89CD…  real         nein     5618        0
 2596 │ Polygon(543 Points)   {75A1E58F-70F0-4175-ACD3-91613B5…  {0AB7AA76-D923-475C-8E84-2BCDE75…  real         nein     8308        2
 2597 │ Polygon(1072 Points)  {EA4F403C-01CB-4A8B-922A-49F6C87…  {C399433F-F3F0-4778-BD08-AF9A36E…  real         nein     8907        0
 2598 │ Polygon(700 Points)   {57F98D14-76D0-4964-ABFF-070F020…  {4BC4C80D-BE11-4DCE-A58A-8EB2DCC…  real         nein     6126        0
 2599 │ Polygon(841 Points)   {E9F056CF-8A18-4E6C-B57D-B48D018…  {636A9851-1DAB-42A9-B823-D7C6953…  real         nein     1776        0
 2600 │ Polygon(623 Points)   {4C3A4E3D-0EE8-41EC-A671-3C38662…  {5F876587-C018-4A6A-9446-DD8555E…  real         nein     1407        0
 2601 │ Polygon(308 Points)   {0564B536-5A62-4543-AD43-A8FFA88…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9014        0
 2602 │ Polygon(273 Points)   {4CD75E99-66AC-4F37-9F81-BADAE25…  {41E3AB03-FB1F-4DE3-A0CD-0B8ADBC…  real         nein     9536        0
 2603 │ Polygon(154 Points)   {0F482567-0A85-4FBB-A22C-3F7689E…  {93E3680D-7042-4F34-BD5D-20EC6CE…  real         nein     1666        2
 2604 │ Polygon(673 Points)   {82C08967-C956-4CD0-BE39-0467521…  {BD76C9E7-16E1-47E7-9226-AC13AC8…  real         nein     1880        5
 2605 │ Polygon(324 Points)   {BDEC1C3E-D126-4105-82A4-0CD61C0…  {053EC906-E2D6-4E02-B41A-DF673E6…  real         nein     2042        0
 2606 │ Polygon(472 Points)   {8DF5785C-E6B7-48F5-A1FD-6EEC414…  {C453F2BA-6981-49F8-AA7E-327FD91…  real         nein     5725        0
 2607 │ Polygon(502 Points)   {ABCA8720-9F6B-46BF-9859-E3A9B34…  {E67CD3DC-BE31-4783-90EB-9FE49D7…  real         nein     5463        0
 2608 │ Polygon(358 Points)   {4B60E3FB-BD78-462F-86FC-36328BE…  {A7DEE951-EE9A-4112-A3B1-2609AC6…  real         nein     1307        0
 2609 │ Polygon(578 Points)   {6CB15109-C61A-46A9-949B-8092AC3…  {C6CA2E56-B62F-469B-854F-C8A597A…  real         nein     9036        0
 2610 │ Polygon(495 Points)   {F2B85676-D5F6-4CDD-B974-2C58DFD…  {D67188B2-5217-40D7-9DA8-5ECE8C4…  real         nein     5606        0
 2611 │ Polygon(361 Points)   {8A2E209D-5FCB-40CB-827F-3ABCB1A…  {8F9B8312-F74F-4677-81A2-91014A5…  real         nein     2016        0
 2612 │ Polygon(398 Points)   {C011DB2D-A9DA-46A9-B9C7-B21DCE4…  {B32BB99A-A62F-46D5-B24C-5F58ED8…  real         nein     3111        0
 2613 │ Polygon(491 Points)   {D4798FA2-4569-4B67-AEE7-43BDF89…  {131605E5-C4F6-4486-AB34-4256E21…  real         nein     4445        0
 2614 │ Polygon(387 Points)   {12128B1F-B5B8-4E22-9C31-2288E34…  {E9F696FE-F9F0-4967-89EB-B19C5C2…  real         nein     6760        0
 2615 │ Polygon(513 Points)   {6CC475BC-9EB7-4428-A4D7-B7C84B3…  {2654D416-702C-4D3A-8843-7D3C174…  real         nein     8615        0
 2616 │ Polygon(237 Points)   {71379678-88B5-42B6-8A72-E480A9A…  {764FD965-B649-499E-BBAC-62D9B80…  real         nein     1541        0
 2617 │ Polygon(823 Points)   {750BE649-74E2-4C0D-8497-6C5F91E…  {4C1556D4-57AB-4D79-A515-64CA516…  real         nein     1026        3
 2618 │ Polygon(439 Points)   {334D0D83-14B5-4EC2-B3BA-5FF4B93…  {2C57E727-95E5-4173-8EDF-47F02FC…  real         nein     5012        0
 2619 │ Polygon(541 Points)   {F8E59B33-1E3D-4CCF-B243-82A2E27…  {AC715080-38EB-4100-AD6B-E219DF6…  real         nein     9631        0
 2620 │ Polygon(643 Points)   {FEE5DB21-A7CA-46D5-AEE6-FAFD00E…  {F96773CE-7F90-4424-AED1-FC77F21…  real         nein     1042        4
 2621 │ Polygon(146 Points)   {6229C1F2-3DCA-4E9B-B319-285A680…  {F622F142-BA82-4B78-955B-7732A4A…  real         nein     3989        2
 2622 │ Polygon(201 Points)   {39606256-5A23-400B-9B07-C417246…  {0B11B67E-B79B-4D9C-889B-4E447FB…  real         nein     2338        2
 2623 │ Polygon(85 Points)    {274361C8-A671-468F-A9D3-E2E0C5A…  {AED4E3A1-3D5D-46C1-9D6A-20F0AE0…  real         nein     4425        0
 2624 │ Polygon(554 Points)   {1E61713F-A6DA-4455-9DFC-292E9B7…  {0A9F8610-7D87-461A-B1B9-7EE3DB3…  real         nein     1189        0
 2625 │ Polygon(551 Points)   {F6CA24A7-5972-49D2-90D4-A0BC451…  {DEED5C6C-39A6-4305-ADDF-A9547F2…  real         nein     5415        0
 2626 │ Polygon(457 Points)   {EA5F78F3-0910-456C-AF1A-8F922E8…  {7EBCB0D5-A8BB-4F3C-AB9B-1A13EA2…  real         nein     1525        2
 2627 │ Polygon(342 Points)   {E1EB28CC-F53F-4D09-94FB-6AFC4CA…  {2F5AAA87-B266-482F-A8CB-CCB7011…  real         nein     6594        0
 2628 │ Polygon(218 Points)   {4AB99521-3B7A-4924-8830-E48D577…  {F8C13E7A-ED3A-43A0-9244-84CAC86…  real         nein     2087        0
 2629 │ Polygon(227 Points)   {91FD8ED4-F494-460C-9B81-B5DDA52…  {BE68DC88-5180-4375-BDB7-64FD880…  real         nein     2345        2
 2630 │ Polygon(709 Points)   {E85FD5DE-DFA2-4FC5-B8D1-0FBCCE5…  {1D5D4A57-C7FA-4521-8E13-0BFDAE3…  real         nein     1784        3
 2631 │ Polygon(1088 Points)  {CBD3A896-1B0A-40FF-8978-9678836…  {9065398E-CDA0-494C-BEF6-17DF2B1…  real         nein     1226        0
 2632 │ Polygon(616 Points)   {3F9B477F-F0FC-41D9-8589-57E021B…  {970F1339-7060-4657-A076-5A2FC15…  real         nein     1266        0
 2633 │ Polygon(507 Points)   {5B3CD289-9AD8-4122-915B-874363E…  {24A9F671-F2A4-49B2-BF04-F721EEB…  real         nein     1772        2
 2634 │ Polygon(205 Points)   {ACF09458-85E2-404B-8832-77F0040…  {814E66D6-E455-49D8-9E3A-1749FFD…  real         nein     3966        0
 2635 │ Polygon(503 Points)   {C01F5293-03E3-4735-A786-C6BF248…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3008        0
 2636 │ Polygon(430 Points)   {5BCFFFAB-44EC-4FA9-933B-0EFE6BB…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1202        0
 2637 │ Polygon(334 Points)   {78E1065F-5E50-48D1-B679-B1CB1EF…  {7E6EC39B-27DA-4E34-A88F-1CA796F…  real         nein     4539        2
 2638 │ Polygon(406 Points)   {58F18895-617F-471A-90DD-B36D693…  {03E1AC6D-C3DD-4BF7-A217-B90FDE7…  real         nein     3315        1
 2639 │ Polygon(869 Points)   {3C8F2567-24E2-4CB8-8B63-C2454A0…  {130162EE-900D-4294-8107-9DFA680…  real         nein     8457        0
 2640 │ Polygon(298 Points)   {3A4B18D7-F914-4CDF-8FDB-80355AE…  {CE967747-FF6E-4361-B361-B1EFC85…  real         nein     9312        0
 2641 │ Polygon(211 Points)   {FD19E415-23EA-4804-BFFB-CF9C312…  {D5B8BF6F-102F-4978-8654-DBE458A…  real         nein     2113        0
 2642 │ Polygon(249 Points)   {4FDFD671-AF20-4313-90F9-9800B4D…  {2EA2FDBC-FE45-48AA-86EE-788E3F8…  real         nein     6938        0
 2643 │ Polygon(1096 Points)  {A503DED1-5348-4171-88A2-C4A15BB…  {FF38FF6C-54CA-49EE-9110-94C30D9…  real         nein     1054        0
 2644 │ Polygon(344 Points)   {8D9F1FAA-6BC3-4CE5-A8AE-AFB1943…  {30E34BBD-0E2C-4293-97B4-FB3C8DD…  real         nein     3309        2
 2645 │ Polygon(160 Points)   {10E01B88-7D19-4647-9662-656A36D…  {64A29893-80AF-458A-A9FB-608022E…  real         nein     4224        0
 2646 │ Polygon(727 Points)   {46775CA2-4DC0-4FF4-AEBF-6930958…  {CFE29CD9-802D-4099-96FF-E178BC0…  real         nein     6277        2
 2647 │ Polygon(186 Points)   {22725D5B-0933-4B1F-964F-6B0261C…  {A1C82A54-8F01-4A2A-B433-A92F692…  real         nein     7425        0
 2648 │ Polygon(963 Points)   {11831848-8FC5-4866-A301-8B17205…  {DDF5734B-6627-46FA-B838-B031560…  real         nein     9035        0
 2649 │ Polygon(373 Points)   {F26A4766-D362-4CB4-967B-706467D…  {65FDB2DE-1AC1-4FDE-8071-B27F7DE…  real         nein     9225        1
 2650 │ Polygon(1114 Points)  {A21BEC01-9E39-462B-A84C-EEAF2FA…  {337EC956-A4C7-4C46-880F-6984B1E…  real         nein     1009        0
 2651 │ Polygon(1130 Points)  {526B4100-0178-49A2-A4DE-FF2CBAF…  {A4BAA3BF-313C-4B4E-9834-785A103…  real         nein     1047        0
 2652 │ Polygon(316 Points)   {887F0ADA-63F6-4AE4-8F31-54E6C33…  {3831703E-0767-4481-9307-75472C2…  real         nein     9508        0
 2653 │ Polygon(341 Points)   {8A83FE73-9B0C-4A99-9147-3A59A4A…  {C136AE9F-06F7-4D31-A670-4D0BE4E…  real         nein     2902        0
 2654 │ Polygon(865 Points)   {D7933671-1F1B-4374-AA3E-DD5AABA…  {45474AA1-9322-4F48-A8F5-F77E393…  real         nein     9050        7
 2655 │ Polygon(488 Points)   {8B02C4D3-5C1A-4CAF-A040-D58B800…  {0FFB3ACD-6B99-435B-B1A5-23B715B…  real         nein     1234        0
 2656 │ Polygon(421 Points)   {35566267-A6A6-4A6D-8DAF-8A219BC…  {48E35FF7-2C18-43AC-B6D8-5E3462E…  real         nein     3083        0
 2657 │ Polygon(179 Points)   {F7847153-7CB9-490F-9797-766796A…  {EE02DD21-9459-4A05-9E2B-40217D8…  real         nein     1912        0
 2658 │ Polygon(96 Points)    {C74FFA52-9F39-495E-9ACB-C79C6CD…  {2485F86E-ACE5-4250-94BE-A4C62B0…  real         nein     1873        2
 2659 │ Polygon(816 Points)   {3C54627E-5AC4-45EA-8AE1-55410E8…  {FAF4A2E0-98D7-4910-AC3B-8CEA551…  real         nein     8125        0
 2660 │ Polygon(290 Points)   {DC62E800-E10A-47B1-B24E-106A740…  {08B8A3ED-BCF3-40F8-B4B8-1F72090…  real         nein     5506        0
 2661 │ Polygon(211 Points)   {48EE0FCF-0AB2-4A6E-8E8B-C8FD64A…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4057        0
 2662 │ Polygon(324 Points)   {98AA94FB-3589-44E4-9D33-5AADD91…  {EA61FDCA-4A1C-4BF8-A291-F86B73C…  real         nein     1435        0
 2663 │ Polygon(1361 Points)  {C9064287-3B5A-470C-84A1-134DEA9…  {7486FF02-5F5D-4832-B8AC-801F7E0…  real         nein     3946        2
 2664 │ Polygon(490 Points)   {34805C54-DA2B-4B09-A977-AEDB9B1…  {27FC0855-7B55-4C09-BA87-8138C8B…  real         nein     4653        0
 2665 │ Polygon(233 Points)   {0EA007B1-450D-40B0-BF5F-B06F5E5…  {B2BAFA8A-A094-4588-A234-538E3BA…  real         nein     2123        0
 2666 │ Polygon(832 Points)   {F7EFC22A-C405-44D9-B7E7-E2EC98F…  {721ED3C5-F062-48DE-9F02-E1CB7C3…  real         nein     8322        2
 2667 │ Polygon(466 Points)   {4FF7ABC2-8AAC-4140-9E84-9378063…  {74BEA23A-5067-41A2-A73A-4C52C64…  real         nein     1734        0
 2668 │ Polygon(273 Points)   {7A9D6BD5-1BB6-46E0-9D70-AB9C210…  {52FF505B-F21A-42E4-9F7D-3440B4E…  real         nein     3263        0
 2669 │ Polygon(561 Points)   {E0D595D8-8BC9-443F-8472-D78F599…  {987A2C48-895A-40E1-9285-FC892E3…  real         nein     8172        0
 2670 │ Polygon(311 Points)   {72FEDE50-6A87-4285-8097-E18859C…  {E6CF2DBC-BEB7-4CB0-98DA-C94D520…  real         nein     6234        1
 2671 │ Polygon(279 Points)   {838BF8FF-7032-4CCF-BD7C-72311FD…  {ED5948D3-FE65-4B57-9752-D21ED70…  real         nein     9213        0
 2672 │ Polygon(261 Points)   {A06CA510-BECF-4E7D-ADB4-A7C0431…  {06B54043-02A8-4DE3-BC5B-C078C91…  real         nein     1726        0
 2673 │ Polygon(399 Points)   {196D82AE-01C0-4F82-97F7-FDE34D3…  {2E9BFF03-073B-4DD9-AEB9-5B2CBA3…  real         nein     6248        0
 2674 │ Polygon(350 Points)   {5773A2AC-C32C-4012-B4CD-3DFA952…  {C140EDCB-84B5-407C-B842-D44E2BA…  real         nein     5624        0
 2675 │ Polygon(247 Points)   {03A111DB-1FCB-466D-97C8-5307DE1…  {B2625511-1884-423C-8ADE-32F9BC6…  real         nein     9601        0
 2676 │ Polygon(450 Points)   {1E0A35B7-BCB3-4D33-8081-98F4DF5…  {21A6E960-A7C9-4AF6-868B-967FE22…  real         nein     4234        0
 2677 │ Polygon(450 Points)   {8ED2A27F-6DEA-4DE1-A557-929814B…  {698A57B0-BB44-432A-85AE-2478A0F…  real         nein     6718        1
 2678 │ Polygon(156 Points)   {F369A63D-AC8C-4372-AAED-AE93723…  {A37114B3-8F16-4261-8129-5AE6C93…  real         nein     8575        1
 2679 │ Polygon(353 Points)   {D7E37A0F-CA9C-4CAA-A104-950BC67…  {BFA6BA7C-22B2-4C87-A7AD-BBF84CE…  real         nein     4617        0
 2680 │ Polygon(331 Points)   {ECF2924F-7AB2-4081-8276-E106F0E…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4052        0
 2681 │ Polygon(429 Points)   {7E9BD8AA-826A-40C5-83BE-16768DB…  {73A78C33-E243-4682-917C-DD555EB…  real         nein     1643        0
 2682 │ Polygon(479 Points)   {EB971368-01F1-4DA9-9FFB-C04BA8B…  {4316566C-C700-453F-BF58-03D0AAB…  real         nein     1885        0
 2683 │ Polygon(244 Points)   {4AE591AE-A4B3-4A01-8D8E-3849CC4…  {9B4D9A3E-163E-4E0F-8980-AFD5724…  real         nein     2575        0
 2684 │ Polygon(287 Points)   {3F5E2B8D-C697-46CD-B4F9-B5EA82B…  {6BC940D1-E1D2-4F24-B91B-E8D7D2F…  real         nein     3086        2
 2685 │ Polygon(316 Points)   {AF042FC7-0009-4204-9982-4F0BB56…  {A8D8EAAA-3860-436E-9331-CC1EB47…  real         nein     8267        0
 2686 │ Polygon(422 Points)   {EE7A18B5-BEA8-4B52-A0E0-A2B3732…  {8E210C5F-6C14-4372-BFEA-9621B63…  real         nein     3662        0
 2687 │ Polygon(231 Points)   {4F7FAB06-C925-475E-84FB-0A8B7C3…  {F48D5C8E-CA39-4455-8E61-A918E5B…  real         nein     5522        0
 2688 │ Polygon(318 Points)   {43DFD0B4-48CE-4C71-B85E-B3884AE…  {480E7CAD-6BFD-43F1-A9DA-20EA810…  real         nein     6939        1
 2689 │ Polygon(387 Points)   {3A39F0BB-65F1-42C2-9FC3-4DD5D0A…  {9354C51D-1119-4BC0-81F8-2E3990A…  real         nein     5603        0
 2690 │ Polygon(229 Points)   {1603AF57-E820-41E0-898C-7DF34AA…  {BA509D82-238D-48DB-9668-7F76936…  real         nein     2577        2
 2691 │ Polygon(369 Points)   {B387F389-4CE5-4355-91A7-DC6A2F8…  {23554C64-2F62-4E63-A594-BFAD72F…  real         nein     5416        0
 2692 │ Polygon(309 Points)   {D593AB1C-03C3-4EA0-A583-77C5102…  {4A0AFBDB-FCFA-4416-86DC-9AB1A55…  real         nein     4411        0
 2693 │ Polygon(260 Points)   {447C5A67-3957-4F81-8ABB-4F677EF…  {8602A475-8E2A-457C-AB2E-A8BD97F…  real         nein     8468        0
 2694 │ Polygon(338 Points)   {17C0857A-BF84-4FB7-9083-57DB3EB…  {B8CEA2CD-7E57-48F0-A84A-226C6A2…  real         nein     9452        0
 2695 │ Polygon(466 Points)   {5E88F81F-92C2-4872-8F2A-EC99922…  {08B5ACEA-5B62-4745-B745-F824629…  real         nein     9434        0
 2696 │ Polygon(756 Points)   {52FAA8E5-811E-4E5C-AFC7-DB929A2…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1018        0
 2697 │ Polygon(299 Points)   {3C265417-550B-43E7-AE4A-6B9F4EC…  {83697145-183A-4B03-B13F-6BA9361…  real         nein     2400        2
 2698 │ Polygon(359 Points)   {3E9808B2-0E67-41E0-929B-9FA87EB…  {07C9E504-28C8-4114-BCF8-ED258DE…  real         nein     9556        0
 2699 │ Polygon(504 Points)   {96F73ECF-3F22-4440-83A6-D8926DC…  {32E4133C-D743-461C-82B4-A845F00…  real         nein     9242        0
 2700 │ Polygon(314 Points)   {E91FD10B-C7C9-478F-9BDB-A31D1EF…  {AA1571F0-F2BC-4694-9186-D1A65EF…  real         nein     1964        0
 2701 │ Polygon(204 Points)   {F4A8EECF-E1D4-43C5-86E7-EDC169B…  {47675E09-FC72-4295-AF91-667A600…  real         nein     2717        2
 2702 │ Polygon(442 Points)   {5C99681D-6380-45FD-8203-A638AB0…  {EA039FFB-DAEA-4100-80C5-BB570BB…  real         nein     1699        0
 2703 │ Polygon(391 Points)   {56414D0F-7F12-4288-AE75-2E93215…  {DEE8ABDF-4DB9-4AD5-B592-C14DD5A…  real         nein     5604        0
 2704 │ Polygon(660 Points)   {A7A74FF4-CEF5-474D-B2FD-71958C9…  {D0AEAAC7-C2AC-4B25-BC26-98714E2…  real         nein     9240        2
 2705 │ Polygon(88 Points)    {7D5E5025-254B-4692-A3CC-6071D72…  {49D1162E-55B1-4208-A99F-18F50CD…  real         nein     8807        0
 2706 │ Polygon(232 Points)   {922C8668-2C73-494F-8D1F-D103A6D…  {9A51C1FB-8C2E-4574-B314-9FE76D8…  real         nein     8723        2
 2707 │ Polygon(533 Points)   {5709B5EF-1323-4B9E-AF25-A5950A8…  {E134A1BF-9213-49C9-B522-1FE30ED…  real         nein     6260        3
 2708 │ Polygon(346 Points)   {2AEE2E0D-766C-4246-BF3A-E81954F…  {2E99A962-F886-4EE2-8BE4-31F791A…  real         nein     5042        0
 2709 │ Polygon(792 Points)   {46639A62-C41C-422B-B116-860BA1D…  {C0D4EE57-0877-4A00-8CBF-92FC86E…  real         nein     1515        1
 2710 │ Polygon(626 Points)   {C5B7034B-13F2-4AAE-BC21-9ED2E4E…  {403A96CC-9B5C-49B6-881B-8C3241A…  real         nein     8317        0
 2711 │ Polygon(838 Points)   {7BF01C38-0866-4C9C-B327-8AFC4AA…  {BB8CE305-9047-46BC-ADB4-43F48DC…  real         nein     4465        0
 2712 │ Polygon(806 Points)   {250992A2-5AB3-4A0B-9DF9-5B73A14…  {C50B243C-6A0E-43EB-8CD0-6207730…  real         nein     1803        0
 2713 │ Polygon(353 Points)   {44FB5BB4-381A-4F23-9605-8578498…  {6B9F90C0-8957-4781-8BB1-4E87755…  real         nein     1565        2
 2714 │ Polygon(699 Points)   {2372C7C4-E20E-4065-A5CF-E195D69…  {CAC5701D-BD43-40E4-A26B-31F92F8…  real         nein     6837        0
 2715 │ Polygon(511 Points)   {8E484D0A-BB70-4256-9391-7DE5BA1…  {4C5D50CD-8074-44EC-970C-78A7DF7…  real         nein     2564        0
 2716 │ Polygon(515 Points)   {5E735C2A-F8E7-47FD-8EFB-5DF9710…  {56776BC3-FEE6-4DAC-8B8A-A4EB9E5…  real         nein     6404        0
 2717 │ Polygon(119 Points)   {4B426FE9-6417-4643-98BA-A95DD5E…  {10F7C382-A1CD-4B78-8926-498AE05…  real         nein     8553        4
 2718 │ Polygon(535 Points)   {E2E060E4-8DF8-431F-978B-0CA3352…  {F3278D09-E6DB-4C18-AAA7-8986B20…  real         nein     9122        0
 2719 │ Polygon(315 Points)   {1AEC8B41-308C-4C87-B41F-8739289…  {ABA570CE-2FF5-4F27-967E-8D9D838…  real         nein     9547        0
 2720 │ Polygon(478 Points)   {7399ABDB-AFC2-4CC7-A826-209B468…  {29876527-3428-45F2-BE8C-7953F15…  real         nein     2912        3
 2721 │ Polygon(713 Points)   {9F4DCA11-421B-4A53-95F3-0ED5473…  {522667E3-04AC-4117-8CDB-60A6710…  real         nein     7027        1
 2722 │ Polygon(225 Points)   {960D4C0F-BDD7-4111-B2A0-D6BA10C…  {108AECE9-ED1A-4CCF-BD61-8830290…  real         nein     2953        2
 2723 │ Polygon(140 Points)   {A7E83576-601B-46F8-8D40-7CBE54B…  {BA52C579-2644-44CB-931B-C8F8370…  real         nein     4424        0
 2724 │ Polygon(591 Points)   {523BADA8-7933-4B16-BF55-45DBDD2…  {167B3270-1B88-4213-9095-506E834…  real         nein     1083        0
 2725 │ Polygon(390 Points)   {CE3B0F75-A8EF-4F51-92A7-F40BE99…  {59C1749B-4130-4BC9-84FF-5006DDB…  real         nein     1595        0
 2726 │ Polygon(153 Points)   {0C5B2C2A-46D0-426A-A082-69FA610…  {89F7D650-27D5-4E3C-95C8-1205EB5…  real         nein     7473        0
 2727 │ Polygon(399 Points)   {BAD00E47-CE6C-4A38-BAE0-BFAA718…  {A420A8E9-0B97-4AF1-9C72-73908C0…  real         nein     6212        0
 2728 │ Polygon(448 Points)   {57AE7FE7-66F7-4590-9718-5AA3BB3…  {99B4FC0B-CBEA-45C6-8237-8548679…  real         nein     1256        0
 2729 │ Polygon(752 Points)   {DCE4F3EB-583B-4856-8B37-DAE6883…  {0C21E09B-C1CE-4D32-B5D6-0C65D47…  real         nein     1045        0
 2730 │ Polygon(499 Points)   {ED2BB713-FC39-4D0E-B560-E908218…  {08793E53-B78E-4F4F-8757-DEC3EEF…  real         nein     6997        0
 2731 │ Polygon(647 Points)   {D08D8BCA-0C39-43EF-A79D-D657C2C…  {56B4C557-8C83-48B5-B3F5-529B43A…  real         nein     8762        2
 2732 │ Polygon(704 Points)   {209B1CEB-B54D-42FF-A25E-12D44AF…  {4BB47F61-0106-4DDD-A2D6-E103354…  real         nein     1682        2
 2733 │ Polygon(504 Points)   {9EE74E8B-655E-48D1-8AB0-EE20FB6…  {95DE070B-6DBA-4F04-B8CD-46E014C…  real         nein     6152        0
 2734 │ Polygon(391 Points)   {5C14DBEE-FAC1-4DFF-B295-5EB4178…  {1E249DF5-16CE-46E1-9FFF-CA985A3…  real         nein     3303        3
 2735 │ Polygon(497 Points)   {E6F8DAF0-0F61-485F-95FC-6CF5BEE…  {6ECF3C5E-04F6-44B0-B5C9-60273DA…  real         nein     3674        0
 2736 │ Polygon(432 Points)   {DE6E6C8D-A8BC-4D5C-8549-43E24B8…  {86A77FF5-89A4-4988-A32C-B709EC2…  real         nein     6289        2
 2737 │ Polygon(254 Points)   {C1CBBAF9-436A-4D99-A28F-5B9DC01…  {B9D42827-A333-49E9-8CFB-54A25CF…  real         nein     1762        0
 2738 │ Polygon(371 Points)   {A9A3A701-0692-4F72-90F4-09FFEEC…  {416C7D3C-A19F-40C9-8165-C920DEB…  real         nein     3126        2
 2739 │ Polygon(423 Points)   {60FEA28D-FEAE-4F8D-A633-A1F7943…  {0C5330B8-A36F-4266-B116-245BDB1…  real         nein     5305        0
 2740 │ Polygon(39 Points)    {71D9D90F-B5C8-4808-8603-D8C501B…  {90F0CFC8-4A6D-45A6-ADF9-9A1C704…  real         nein     1945       10
 2741 │ Polygon(508 Points)   {CCE63895-D94F-4CBB-9D39-3F394D6…  {2AF9EAD9-57DC-4429-863F-4469EA0…  real         nein     9212        0
 2742 │ Polygon(253 Points)   {2F314D69-137A-4D6F-B0CE-0E91B7B…  {761F25D0-1D2A-4F81-9A9F-A134736…  real         nein     7405        0
 2743 │ Polygon(487 Points)   {C8BD789E-7213-4735-A935-B034F10…  {11B11ACC-0A61-4C7A-8F22-B7E6370…  real         nein     1295        1
 2744 │ Polygon(302 Points)   {52765BA8-0A92-435B-99A7-00C21C4…  {4D5063AE-2A06-49A7-B841-DFBBBE5…  real         nein     3293        0
 2745 │ Polygon(474 Points)   {F082B0CB-E8D3-4008-A6CA-9FC55BF…  {B8FF76AF-2D88-4B1B-9D10-EB96701…  real         nein     1747        0
 2746 │ Polygon(118 Points)   {F5228B09-B05F-419C-A797-CBBAC5D…  {1BDA7A01-B740-4796-A157-A0157D3…  real         nein     9225        0
 2747 │ Polygon(239 Points)   {1E9CD41E-EB76-4F48-9BD1-6DBEAF9…  {52DC4AAA-9A4A-494C-9491-EFAA5DA…  real         nein     4127        0
 2748 │ Polygon(205 Points)   {A8B84EC9-8045-4B22-8BB0-1C7E036…  {B77A1BD6-5AD0-4C0D-9EB3-28A6ABF…  real         nein     3274        0
 2749 │ Polygon(366 Points)   {A126D8DF-2320-4BEF-ACD0-83E7CFA…  {8BE5FB58-C521-41EA-834E-621C219…  real         nein     8725        0
 2750 │ Polygon(1192 Points)  {A37D6D0C-3678-4088-9DCC-0DF523A…  {77B2DD2B-DDD6-4717-9046-E562759…  real         nein     1063        3
 2751 │ Polygon(438 Points)   {CB1A9523-75BA-42E5-97C8-E25B00E…  {B9BBE3E6-B4CE-403A-AA7D-CA81D87…  real         nein     7423        2
 2752 │ Polygon(505 Points)   {2A3AC854-B3D3-4BF3-AA9E-B7A7A51…  {9C69C6E2-3701-4AAC-B6B7-8A990ED…  real         nein     3098        1
 2753 │ Polygon(130 Points)   {2EA30540-01D2-4EE4-84DE-CAA2929…  {BF3FCB77-4639-4D51-8440-9604B1C…  real         nein     3930        2
 2754 │ Polygon(340 Points)   {999F19D6-10CA-4DD3-A1BE-E1EDA64…  {2F53EAE7-FBAE-4B7B-8FC5-787AB43…  real         nein     3272        2
 2755 │ Polygon(315 Points)   {14CC1CC6-C839-47CA-B9D9-D4C7906…  {647BFB52-A5D3-4A87-8EDA-33ADE8E…  real         nein     1292        0
 2756 │ Polygon(473 Points)   {E3AD4A60-49AE-4CE9-906E-B656361…  {B73B4D66-1359-4C5F-AC93-78BD15F…  real         nein     1795        0
 2757 │ Polygon(509 Points)   {9F15DE19-EEDF-4423-BC61-A4C9929…  {9C5C7515-2DE7-4E64-8CD3-16E11A7…  real         nein     9315        2
 2758 │ Polygon(290 Points)   {388F1B8E-C08E-43B6-BBB8-4DED598…  {D35E1B2F-795B-4371-A383-29DD9A1…  real         nein     3313        0
 2759 │ Polygon(227 Points)   {46963424-7D12-4738-A56B-94A25C3…  {7FD33D1B-0E2E-45C2-97D4-0DCFA00…  real         nein     1567        0
 2760 │ Polygon(413 Points)   {C5B76F9E-B6D6-4665-B40B-10D2BE7…  {1ACD0997-1DDB-4AD4-B0E5-FB2831D…  real         nein     3629        2
 2761 │ Polygon(350 Points)   {EE6E1BEC-C4F6-4F01-A95D-C574D05…  {41384041-F540-406C-99FF-ED10C06…  real         nein     2034        0
 2762 │ Polygon(439 Points)   {88D774DE-53E4-4A03-9725-0BED39D…  {7D97C39A-21A8-4F73-9605-6E77D1A…  real         nein     1724        0
 2763 │ Polygon(363 Points)   {AA7888BD-7C23-428C-8EE3-28C370A…  {D52E6ED3-5E49-4860-8ECF-309DDF4…  real         nein     9523        0
 2764 │ Polygon(752 Points)   {9AE78A4A-134B-491A-906B-665D6FB…  {B3B0B834-742A-4918-A177-0F6212C…  real         nein     1442        0
 2765 │ Polygon(274 Points)   {4C97F119-2849-4EF2-8427-91CB5FF…  {CA8DEA01-E8FD-41E9-8E01-D80D615…  real         nein     3978        0
 2766 │ Polygon(439 Points)   {1F877D14-1448-425E-8280-32EC3FB…  {040495B2-B51B-47D4-B225-9F0B786…  real         nein     8905        3
 2767 │ Polygon(375 Points)   {540087C6-C0A8-4F0F-9B0F-417B34D…  {46BD1F1E-53CA-4FA1-AF8B-7AA57B3…  real         nein     3375        0
 2768 │ Polygon(318 Points)   {0CA73FE8-5943-42F1-8333-CCC51BE…  {F5E58382-F920-45C2-A3DE-5DB0926…  real         nein     2715        2
 2769 │ Polygon(286 Points)   {DAF413AA-FDBB-4253-A32C-1DE527B…  {5D7957FA-5A73-4D45-AA9D-DAD415D…  real         nein     5108        0
 2770 │ Polygon(620 Points)   {76ED7EE1-C701-48AB-BDDE-D8A2626…  {66E88364-45AC-4FE2-BA14-F1C6EB1…  real         nein     1251        0
 2771 │ Polygon(707 Points)   {2FCB2DA7-B4D9-4FAD-9AA3-BACC633…  {7B4313C2-7A0E-4516-9289-C4A0F9A…  real         nein     4554        0
 2772 │ Polygon(372 Points)   {80BE6BB9-7297-4C36-8DB6-B7B1742…  {063EBB60-E25F-4E5B-B5F4-90DB53C…  real         nein     9652        0
 2773 │ Polygon(245 Points)   {8022F868-6C22-47D6-99BA-BF3D8E4…  {4354BD2A-3705-4276-A069-2B7294A…  real         nein     3035        0
 2774 │ Polygon(265 Points)   {A5CEC492-1683-4E37-AF20-F87A6E4…  {5E7E481B-4D5C-4D56-8660-35EF851…  real         nein     4565        0
 2775 │ Polygon(410 Points)   {8E1C30EA-EC18-4A8A-884E-DB80D41…  {CA8A750C-52A5-4C98-B50F-3B2E68C…  real         nein     3233        0
 2776 │ Polygon(180 Points)   {5A737115-C7FA-4F9F-9E96-FEBDF8A…  {EDDF6AFD-687A-47D9-9735-557BA3E…  real         nein     8554        3
 2777 │ Polygon(403 Points)   {AFB6D5E7-9FC2-41D8-8C7B-2F85880…  {9E8125D5-1A58-4FB1-BF3E-0766899…  real         nein     1412        2
 2778 │ Polygon(374 Points)   {B7E006AE-222C-4A54-9303-DAAB935…  {C4F9A44B-A27C-4076-A9D8-42940A4…  real         nein     8734        0
 2779 │ Polygon(373 Points)   {D38AE1BE-705D-4406-A887-17E8A1B…  {E3BC360E-EE27-485A-A2C1-1130E16…  real         nein     9602        2
 2780 │ Polygon(155 Points)   {80ECD187-04F1-466A-8F69-31D2A47…  {C600EE10-2B7D-45BD-B3D7-71B4897…  real         nein     3365        2
 2781 │ Polygon(234 Points)   {20C24119-0287-404A-BA98-7B1CC8A…  {6F04E6B0-F4AC-4758-9F52-8B5EDFE…  real         nein     5626        0
 2782 │ Polygon(37 Points)    {E3C13A9C-8F99-4E59-8741-5673F0B…  {6896BF37-A116-41E9-90EF-B5ABDF7…  real         nein     6410        2
 2783 │ Polygon(1139 Points)  {6DBD6AFA-5454-45BB-AA9C-5659F30…  {550FCAB7-D6FC-4957-A6BC-851907F…  real         nein     1823        0
 2784 │ Polygon(315 Points)   {A3975A01-10DA-48D2-A700-383DBF1…  {2F9EC4F9-C29E-4592-A34D-14F9BBD…  real         nein     1483        3
 2785 │ Polygon(444 Points)   {2597C3C0-396B-4206-A23C-16126CB…  {E1522D26-F3DF-4F97-A500-0F69FF3…  real         nein     1754        4
 2786 │ Polygon(289 Points)   {6FCD0BF7-200D-4EBE-8FBD-9B6A813…  {6A08A345-2E8E-406D-B87D-49B93C8…  real         nein     4203        0
 2787 │ Polygon(326 Points)   {1E8A23A6-CEC3-47D7-AFC2-297D352…  {0C7ACBED-0F26-4CF5-B310-FC33130…  real         nein     8487        0
 2788 │ Polygon(461 Points)   {79495360-0917-4351-9C90-6C00FD4…  {66A66F94-D917-436F-BB11-F64F8F6…  real         nein     5443        0
 2789 │ Polygon(604 Points)   {FBB0293B-6DF0-4F52-9628-113CF63…  {E6DBDAF5-2F7E-4C41-9E05-E03DE66…  real         nein     3309        0
 2790 │ Polygon(365 Points)   {459C0B75-3FCB-42E9-B5A5-0879509…  {D49728BD-9784-4969-B272-DC5CC5F…  real         nein     3510        9
 2791 │ Polygon(549 Points)   {E6BDC0FF-E188-4EE0-BE01-3BA7D64…  {86DA7D02-3A6E-45F3-A515-7E71D7B…  real         nein     8547        0
 2792 │ Polygon(585 Points)   {F41189DA-7D47-4A4C-BF70-29AD89F…  {BF151181-8202-4A14-9FFD-1D68D9D…  real         nein     1724        4
 2793 │ Polygon(117 Points)   {353617F4-7047-4E1B-948F-881DE05…  {3E6BC22A-40BD-426C-AB51-53C549D…  real         nein     7431        1
 2794 │ Polygon(455 Points)   {AC460156-F96C-4CB6-A99F-31F757A…  {C47E99E3-6553-41B4-A5FF-9B73504…  real         nein     9411        0
 2795 │ Polygon(375 Points)   {95AFF570-00FE-4819-AF45-A041256…  {E30A54D6-9472-4117-8F57-967C013…  real         nein     3128        2
 2796 │ Polygon(488 Points)   {5EB4A24B-57A1-46DA-AF7B-EF79F7A…  {F3D3F43C-8A05-470C-9898-8441F9D…  real         nein     1694        4
 2797 │ Polygon(589 Points)   {546F11AC-D2C3-4243-9BB9-2E16D06…  {984253F6-6BC8-4B49-ABFC-8CA7247…  real         nein     1686        0
 2798 │ Polygon(312 Points)   {179307D4-FE25-435C-B8A0-BEF26E3…  {1E1AD766-A07E-4E1C-AB2E-7169F05…  real         nein     5246        0
 2799 │ Polygon(466 Points)   {384020CC-0021-4062-8057-72816B8…  {19B901C0-BAF7-4F9C-98D6-145C9C5…  real         nein     5637        2
 2800 │ Polygon(390 Points)   {2C521D0C-F6FB-41D2-841F-2ADD471…  {70029226-6AE0-4685-8C4C-1D3EDC3…  real         nein     6572        0
 2801 │ Polygon(296 Points)   {F3D0FE4D-BBB2-4618-B25E-AAA80A0…  {6F90A85E-AB7B-4040-803D-0DD0254…  real         nein     5032        0
 2802 │ Polygon(227 Points)   {9F24037E-5998-40D4-8FF3-3279F3F…  {D98D9467-E7C9-45A7-B7DA-3B9A36A…  real         nein     1135        0
 2803 │ Polygon(240 Points)   {0B57BCB7-4E5A-49AD-AAD7-AF1D402…  {82527F9C-989D-4D27-BDD6-FA5A13C…  real         nein     6764        0
 2804 │ Polygon(364 Points)   {4C0E46E0-5004-4034-B219-E82996A…  {F6E23EF5-D3D7-4CC8-9B51-C4895D7…  real         nein     5274        0
 2805 │ Polygon(317 Points)   {599138B0-1B59-47CB-AC27-03906D7…  {E6C10979-318F-450F-8579-192A46F…  real         nein     3711        2
 2806 │ Polygon(664 Points)   {BA2E0709-02E5-44C2-9690-7C9999C…  {C780B11D-B22C-47B0-81E1-51E635C…  real         nein     3063        0
 2807 │ Polygon(617 Points)   {686A2791-6B67-480A-AF4D-C4E2109…  {EBE736F6-6E6C-4681-8C5B-E03148D…  real         nein     4556        0
 2808 │ Polygon(338 Points)   {F320FCC4-9F74-4641-ACC7-A90CB3A…  {5881520E-907E-46D3-A41F-E7B2A07…  real         nein     9422        0
 2809 │ Polygon(336 Points)   {542FF7C2-7A2E-4A3C-AA6A-FEC2770…  {8A16A098-1C06-49DC-A756-CC4D4A7…  real         nein     4583        0
 2810 │ Polygon(641 Points)   {A3CD826B-3E83-4490-B981-398F084…  {3976A1AD-27AA-4445-AAEB-137CCFA…  real         nein     1509        0
 2811 │ Polygon(201 Points)   {E12063D7-2438-4BAA-A528-F848B6D…  {FF378DD7-5D42-408F-BBF3-0EB38F9…  real         nein     5275        0
 2812 │ Polygon(229 Points)   {148FFC62-3211-44DE-A716-8C7DBD0…  {69E086CC-F8FE-44C1-A466-8872156…  real         nein     6655        3
 2813 │ Polygon(199 Points)   {FB9450BC-D6C7-4A38-85CD-0D3927D…  {79F54715-3BAF-41D4-8A8A-1262827…  real         nein     6723        2
 2814 │ Polygon(280 Points)   {F78AA584-18E7-4DA8-BCFB-1020C31…  {C46F1DA5-3F3C-457F-869F-A3D36EC…  real         nein     5502        0
 2815 │ Polygon(266 Points)   {F56570AD-804E-40D7-B58B-1C75DD9…  {A3E6190E-EB12-43C6-AE6F-29A4D50…  real         nein     6215        2
 2816 │ Polygon(332 Points)   {312D64BC-C273-4C1F-88B6-728F1C6…  {3B9C59B6-2661-4CFE-B357-07B5006…  real         nein     1688        0
 2817 │ Polygon(150 Points)   {6FEEA678-6ACC-46F3-98FA-16B21C6…  {17AB379E-B6AE-4B3E-9D4E-4E06768…  real         nein     2512        0
 2818 │ Polygon(323 Points)   {421A82AA-9B40-467C-BB67-EA84766…  {099991D3-82B3-44EF-9019-7A632F3…  real         nein     1719        0
 2819 │ Polygon(495 Points)   {CB30B1ED-1374-4D27-A2FA-B63D4C7…  {EECE2FF2-B5E4-446B-97EB-D112C7F…  real         nein     1534        0
 2820 │ Polygon(433 Points)   {7FF88DDC-026D-4D37-B78F-842659D…  {3237D981-AB8E-40B5-8121-98CC2A1…  real         nein     8917        0
 2821 │ Polygon(342 Points)   {1CA0E176-9E0E-437A-8549-17BE57C…  {460B48D0-2BF5-4D48-A2E5-D9F5D99…  real         nein     1694        2
 2822 │ Polygon(642 Points)   {27EB4442-D307-4174-BC26-CDC8CB9…  {7D25956B-B705-4319-BB91-5F46A06…  real         nein     1814        0
 2823 │ Polygon(315 Points)   {25504424-BEEA-4954-B81E-ED48FF1…  {14B6E4FC-9854-433A-B963-A3A311F…  real         nein     8587        0
 2824 │ Polygon(243 Points)   {7FEB2A05-E69A-40D4-AF97-D76A0BC…  {D270E83C-5409-4AEF-9ED0-E902C34…  real         nein     1527        0
 2825 │ Polygon(594 Points)   {7523EA31-AE64-4300-8852-E3BE156…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8032        0
 2826 │ Polygon(236 Points)   {B525D4AD-2F6F-4A30-89EF-61F30EC…  {DF3353C5-18C5-4668-9967-437CB7A…  real         nein     6746        1
 2827 │ Polygon(619 Points)   {4A2798CA-A53C-4B1C-A307-90AB480…  {A69257B5-13D4-4FAF-80FA-BC51579…  real         nein     1227        0
 2828 │ Polygon(208 Points)   {C5EAAAA9-080D-4AE0-B682-E3AF061…  {370AFF77-7D6E-4737-B1EA-A4654AF…  real         nein     2074        0
 2829 │ Polygon(325 Points)   {1856A53E-338B-4156-AA2F-B655427…  {CD2A307C-AA08-4EE3-9C0E-277D9A8…  real         nein     1685        0
 2830 │ Polygon(179 Points)   {E313E893-AF28-4A03-9704-0A403D9…  {E3F2851C-C8A8-487F-9630-54E05A6…  real         nein     1727        0
 2831 │ Polygon(257 Points)   {8E431515-885E-43ED-AD70-5684D93…  {F75119D2-7D06-49C5-B702-6CA5FBD…  real         nein     6577        0
 2832 │ Polygon(564 Points)   {65066E69-293C-4C41-AB4A-FEB416C…  {BE818386-70F5-46E8-9BCA-16ACD86…  real         nein     7418        0
 2833 │ Polygon(457 Points)   {6545BBD1-9711-4E00-992A-7E3251A…  {DF6510B7-46A1-4E70-BAA6-08BD5E1…  real         nein     1682        3
 2834 │ Polygon(203 Points)   {ED94D44D-7879-4C10-B440-B091B39…  {0DFC237E-5003-4C03-9B0C-C81FAD4…  real         nein     1542        0
 2835 │ Polygon(272 Points)   {2527F87F-DE09-4010-9CBA-B567B30…  {99F229C7-3727-44EA-9384-C525519…  real         nein     1437        0
 2836 │ Polygon(381 Points)   {7BE1BAE3-A3BB-4703-8783-31BF88A…  {C823158A-0CCC-44CD-B47B-71F6655…  real         nein     8356        0
 2837 │ Polygon(403 Points)   {6820A97B-0E5E-427B-A2C6-5FF3F5E…  {1D318EC6-FC05-4FCC-BEDA-77D2111…  real         nein     1796        0
 2838 │ Polygon(332 Points)   {EA5D304C-A0E0-4740-974B-271A695…  {12D83887-D391-4626-A2D0-1905381…  real         nein     5212        0
 2839 │ Polygon(530 Points)   {B54BC1B3-3482-4300-8334-EF9E7DE…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8057        0
 2840 │ Polygon(796 Points)   {1B7992E6-FDBE-48B6-9F77-DE3889C…  {5528922E-8526-4293-AC6E-27C6DA7…  real         nein     9050        3
 2841 │ Polygon(311 Points)   {2723EF2E-3DB6-4396-8B1F-C7D57F2…  {BA2A0353-FCA0-43DD-8CE9-726AD39…  real         nein     5702        0
 2842 │ Polygon(514 Points)   {39EBE55D-1555-46EC-95C7-F501909…  {310B85EA-F8E4-4F21-A8F3-23BBD59…  real         nein     8459        0
 2843 │ Polygon(268 Points)   {1CE8BCF8-94E2-4063-A2C6-3DA2C34…  {E0D2ADF2-76E0-43D5-8580-3012417…  real         nein     1773        3
 2844 │ Polygon(525 Points)   {312E3007-0025-47AF-BE33-7FB9C8F…  {C20AC7BB-1964-4015-B686-7B7C8FD…  real         nein     3074        0
 2845 │ Polygon(280 Points)   {C4E7839A-04C1-43EE-8724-1AA28E1…  {F7C52834-9F8B-40DA-B35E-968235B…  real         nein     4574        1
 2846 │ Polygon(510 Points)   {2926A889-E592-46B0-B1F1-F909702…  {56B9B866-B54D-41C4-8914-75083B6…  real         nein     1463        0
 2847 │ Polygon(552 Points)   {E7A052FE-7A75-4CDD-A0F9-0867546…  {1C24596A-98C5-4B59-AE67-60D0316…  real         nein     7162        0
 2848 │ Polygon(295 Points)   {4D2CEA59-20BD-460F-923E-7671802…  {A363F7BF-E10D-4587-B2F2-A938021…  real         nein     4652        0
 2849 │ Polygon(285 Points)   {BE59001C-7DF6-4256-BA8C-2C77829…  {5FE8253D-BA47-4620-A3EC-92E8A6C…  real         nein     8882        0
 2850 │ Polygon(312 Points)   {562BE33A-1E4A-494C-9BE0-0E40098…  {36B19E82-7D8C-41F1-9A9C-00A9114…  real         nein     5600        3
 2851 │ Polygon(294 Points)   {E636890E-AC66-4EC3-837A-C04CCA6…  {DDE3A771-35B5-4DAF-8500-89C1D8B…  real         nein     8775        2
 2852 │ Polygon(319 Points)   {F41F0CED-26ED-4137-AEDE-A6F239A…  {0D1FEDF4-135A-4115-B573-30311F3…  real         nein     8404        2
 2853 │ Polygon(358 Points)   {C08606E8-C95E-4759-A728-C1ADF28…  {D5DF7717-8D46-42F3-8633-ADAEDA5…  real         nein     3373        2
 2854 │ Polygon(451 Points)   {93CBAC26-327E-4133-8358-17F4531…  {778923CF-396B-4203-A39B-AC04AC0…  real         nein     2503        0
 2855 │ Polygon(324 Points)   {8D13BC83-1B5F-4FCD-B575-DA5C3D1…  {7CA97D7E-F777-4530-8B63-2C18306…  real         nein     8265        0
 2856 │ Polygon(574 Points)   {272933A3-61EF-4ECF-BC85-66B63C5…  {C64D66B2-06DD-45D6-A77E-9A1858D…  real         nein     9314        0
 2857 │ Polygon(321 Points)   {64A8629C-A96B-4163-A2F6-8969E07…  {6664E7DE-A90B-42C9-990C-B649CCA…  real         nein     6078        2
 2858 │ Polygon(610 Points)   {B9153E20-C402-4334-83D6-38CD50D…  {30C12D78-E518-48D8-844F-AA6B8AD…  real         nein     1675        3
 2859 │ Polygon(363 Points)   {9B4B428B-8D56-435D-A703-0552212…  {B8DE3C87-3160-45D4-82E9-C349213…  real         nein     5645        0
 2860 │ Polygon(425 Points)   {C0528D45-1285-418E-BA43-3772155…  {E869C75A-FFD1-4888-B835-D71E7B5…  real         nein     1679        0
 2861 │ Polygon(275 Points)   {CD1CB352-89BD-4DAA-BE95-D4D2916…  {9979B75E-B659-4DCD-8AEB-D7D537D…  real         nein     1682        4
 2862 │ Polygon(375 Points)   {78C1F4A9-1E90-4AC7-801B-053CFAA…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9010        0
 2863 │ Polygon(349 Points)   {E83359C8-47FA-49C5-BDAF-B0BBDE7…  {EF50DF68-594C-4146-8479-4214EE4…  real         nein     3376        0
 2864 │ Polygon(288 Points)   {46905D69-0C10-4C7E-8A96-9662F8E…  {8DCCB580-17EB-42B4-9DED-D846103…  real         nein     1034        0
 2865 │ Polygon(199 Points)   {51B699DD-5BBA-4A8B-8ECB-6215B72…  {EE31829E-BABD-4FCF-BCE9-6B02CB5…  real         nein     5243        0
 2866 │ Polygon(614 Points)   {3EED423A-38FC-4994-BAFF-F4C032C…  {7F1D79B0-5B53-4514-BFFC-9A1749E…  real         nein     1313        0
 2867 │ Polygon(386 Points)   {EC308969-A346-49CA-A400-A710EFF…  {7DB6D1A9-AC50-469A-8B6F-673C5E0…  real         nein     5273        0
 2868 │ Polygon(257 Points)   {D014A6AA-BB26-44DE-811F-004D4DF…  {E5B1B7C2-E2CC-4A83-ABE4-62C3FB4…  real         nein     6599        0
 2869 │ Polygon(531 Points)   {45AE34A0-2843-4063-97E2-CBC980D…  {413AF6D1-40C7-4BA3-B6C3-0F3E161…  real         nein     8633        0
 2870 │ Polygon(321 Points)   {B3C3EF6A-4946-452D-9568-C8D5578…  {C72FB3BC-2252-4864-8ED5-18B2D50…  real         nein     1792        0
 2871 │ Polygon(388 Points)   {4FD07EBE-04D1-4998-8942-1B09C21…  {4CA37AAA-4D94-4D1D-BFF5-D349869…  real         nein     1773        2
 2872 │ Polygon(903 Points)   {C67BCA9D-624B-41EA-8231-6ABE2F9…  {E46788CA-5E91-4EA2-977E-D4BB8C6…  real         nein     8269        0
 2873 │ Polygon(236 Points)   {45ABA6B8-DB86-4CB0-B55E-BCECD20…  {3F7D3758-03A9-4ABA-8719-CF8B07B…  real         nein     6578        0
 2874 │ Polygon(217 Points)   {EA34E176-F9F1-4CB1-B5BE-CEFA60E…  {E7F13F9B-83D7-4E64-BD73-7130689…  real         nein     3284        0
 2875 │ Polygon(451 Points)   {21AF4F16-8B49-4A60-9CF2-98FCB31…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3014        0
 2876 │ Polygon(372 Points)   {6E38B168-E494-480B-9F06-7AC0DA2…  {C4EC5137-2209-45A1-AE20-0D5A0FB…  real         nein     1042        3
 2877 │ Polygon(184 Points)   {A53D2E65-A811-45ED-B1A1-90E9132…  {553E2EB8-12B1-4C52-BCA3-2C470E5…  real         nein     8925        0
 2878 │ Polygon(424 Points)   {0289C70E-85CD-4730-BCCC-E573829…  {130746C7-1ECA-48B2-BBE2-56FCE09…  real         nein     1244        0
 2879 │ Polygon(265 Points)   {F56AA5D7-64FC-4FA3-9A61-38C2B38…  {BE5B36AC-0C6C-4AE6-9A9F-1AF97C8…  real         nein     1565        0
 2880 │ Polygon(180 Points)   {AD4FE49E-2C40-4333-ADEE-EEA590F…  {F36ACC69-EE48-416C-8FD8-0422D1B…  real         nein     4419        0
 2881 │ Polygon(1829 Points)  {5FC30D38-8308-406D-8FE0-6908E7C…  {DFD2D9B1-140D-4D8E-8EBB-40F6E00…  real         nein     1261       33
 2882 │ Polygon(761 Points)   {8C49E2A9-77C5-4E14-8E4D-4A3B871…  {160FDAA8-9E67-4730-B050-651805A…  real         nein     1514        0
 2883 │ Polygon(317 Points)   {9C76DFDD-11F8-4AA2-89D0-F3D9BE9…  {4C8906B7-956E-41AB-AA2E-0C72444…  real         nein     1610        0
 2884 │ Polygon(289 Points)   {CAC7AFA3-4123-40BB-92BC-7D8EE8A…  {4AAC85B2-5455-49F1-85CB-C2B58DF…  real         nein     4322        0
 2885 │ Polygon(253 Points)   {BBEFFF9D-18BF-4EA8-8217-622699B…  {A4786609-E1ED-4B05-AFE8-84C9278…  real         nein     5332        0
 2886 │ Polygon(417 Points)   {9DB1D5E4-B762-4C19-A5CE-E66E1C0…  {F7DB547A-9925-4CBC-A225-B9AF6F2…  real         nein     8453        0
 2887 │ Polygon(391 Points)   {F7516576-7A19-49A6-8165-BEE87EF…  {3541C19B-597A-4ADB-8A55-34DA405…  real         nein     9052        0
 2888 │ Polygon(167 Points)   {2A4379A4-609C-4919-A3DA-283D63B…  {03ACD46C-2493-43FB-959C-78262EC…  real         nein     1976        2
 2889 │ Polygon(337 Points)   {A1F6F965-E0AC-42C6-B76F-415FFF4…  {7B2424F2-8F60-42A0-B27D-CF622EE…  real         nein     1971        0
 2890 │ Polygon(142 Points)   {A65BF468-C1C3-41BC-B7EA-DE66538…  {B95445AB-B534-42AE-9FA5-231DE83…  real         nein     4452        0
 2891 │ Polygon(249 Points)   {575F2CA9-084E-4938-8EB4-7861FA2…  {24BFB226-06F0-4DCC-A88C-2C6A7A4…  real         nein     4247        0
 2892 │ Polygon(131 Points)   {BCD4D3F8-CCB4-4047-862D-9F77FFD…  {78930107-9209-4C1F-BE48-D0430E5…  real         nein     1294        0
 2893 │ Polygon(353 Points)   {C07F049A-8CB4-41BF-BF25-06F8B57…  {8CCE138C-8DA9-41CA-8DBD-F843E7B…  real         nein     1792        2
 2894 │ Polygon(387 Points)   {57E8BF27-9C00-47ED-84A2-C91E428…  {08C033BC-4A69-44E0-8347-A1031D5…  real         nein     8909        0
 2895 │ Polygon(943 Points)   {F457B059-E0B5-4A9F-A674-C6B6850…  {919619E1-FBA7-40B6-8867-C0A29F1…  real         nein     1412        0
 2896 │ Polygon(276 Points)   {8E7CDA58-4D32-4EA0-8429-653DFE6…  {FA833EE4-51CB-4B7D-BD85-F1AB744…  real         nein     1354        0
 2897 │ Polygon(499 Points)   {6A1B0AAC-1CBD-426C-93CA-E96A3B9…  {B4B16FC1-9A26-4E72-B83E-FD429D9…  real         nein     1538        0
 2898 │ Polygon(623 Points)   {A8924DFC-B3F2-4365-BC4D-354A3B7…  {BC22C7E8-E653-4A56-880C-7B312BB…  real         nein     8404        3
 2899 │ Polygon(360 Points)   {8C9EA11D-F718-4BD9-A7D2-720F3D2…  {6C9C5E83-0B95-4124-A26E-1663EE1…  real         nein     8315        0
 2900 │ Polygon(525 Points)   {BB6A304D-DC7F-42E5-9541-B8085DB…  {D9C7A52D-A92B-47D7-BB6F-77EB03D…  real         nein     5525        0
 2901 │ Polygon(317 Points)   {B0C42859-2143-4695-938B-202A85B…  {7C7BFF53-66D5-4D74-AB54-F536517…  real         nein     3377        0
 2902 │ Polygon(203 Points)   {FADB79E2-F562-465B-875D-72BC78D…  {045F20CE-5D29-47C3-8E5D-7CE1054…  real         nein     3628        0
 2903 │ Polygon(846 Points)   {392DBAED-60E6-48FD-BE71-28D9BC0…  {6E2515AA-B7E2-4184-AFB2-EEA8084…  real         nein     8447        0
 2904 │ Polygon(222 Points)   {AF46A14D-076E-4FA4-B52C-F845FE0…  {2BA1F0ED-8FCC-419E-870B-34C553B…  real         nein     9247        0
 2905 │ Polygon(421 Points)   {12DA413A-487C-4E2A-81B3-056A9FB…  {C1C185BF-5FE8-45C4-A5C0-36C1865…  real         nein     1095        0
 2906 │ Polygon(296 Points)   {A55C20F7-4315-482E-8FE1-01C0288…  {8930BF58-E691-41DB-BE2D-E160760…  real         nein     3653        0
 2907 │ Polygon(470 Points)   {9375A158-74D5-4878-8C62-5A4C0F2…  {F5E6D07A-AA44-4C38-BE59-A3257EC…  real         nein     1431        0
 2908 │ Polygon(708 Points)   {31B79526-DBEB-41B8-8481-A3C2CBC…  {429302A7-020C-47E7-B35D-6FD66AD…  real         nein     1136        0
 2909 │ Polygon(635 Points)   {245B5765-4336-4AF4-806B-DCB1A34…  {965BF802-461C-4E53-9073-DC35241…  real         nein     1537        0
 2910 │ Polygon(519 Points)   {83FA41AA-DDAD-411B-AA22-AB1AB86…  {A91A8B89-1C3D-480E-B3AB-091CC40…  real         nein     9450        2
 2911 │ Polygon(512 Points)   {BE6C3200-DBB1-4C0E-BE38-CF09C5D…  {23F09F32-FDC6-4FDA-9619-AA124F8…  real         nein     1187        0
 2912 │ Polygon(125 Points)   {6D4375F7-D0E8-4668-8444-F73B55D…  {BFF3EF7D-0115-4971-A4FB-335E53C…  real         nein     1587        1
 2913 │ Polygon(193 Points)   {B4244072-7095-4D4F-8A83-419B79A…  {514E23BE-4F4F-4C39-9CE0-317488B…  real         nein     3292        0
 2914 │ Polygon(217 Points)   {2FCD2A57-F8CD-41A1-9CD6-3EE90C0…  {55E0F863-B51E-47F2-818E-923F6D8…  real         nein     4443        0
 2915 │ Polygon(413 Points)   {DDB1289A-8E56-4A54-A960-ABFAEA9…  {CEFA5F22-091F-4F28-BEC7-10DDBEE…  real         nein     3624        0
 2916 │ Polygon(459 Points)   {64AD5A3C-FA96-4D8D-80C5-4D71CF8…  {0590BA93-5DB6-4EA8-B891-3ACCE6E…  real         nein     1304        2
 2917 │ Polygon(143 Points)   {F82DABA7-2C9A-41F6-991A-AAB3B8E…  {23B3DD5C-A008-4A7E-9E62-65CAD0E…  real         nein     8243        0
 2918 │ Polygon(235 Points)   {8A2614EB-7B6B-4BDA-A017-BDB0C9C…  {8304CA95-E39F-4BD6-837B-6643E55…  real         nein     3206        0
 2919 │ Polygon(482 Points)   {9E2F980F-AA14-4010-A361-41F24BF…  {CEE17484-3752-4841-8AA7-9A059CB…  real         nein     8412        2
 2920 │ Polygon(684 Points)   {4B0254F0-3E1F-4EE8-BEE7-B0D9F5A…  {EF929CC6-9730-4E14-8095-17254A1…  real         nein     8444        0
 2921 │ Polygon(388 Points)   {0D0D6798-DDDF-4034-A64A-9EA6A1F…  {B6880CBF-9C60-4E60-94D9-CFCDD91…  real         nein     8372        0
 2922 │ Polygon(1115 Points)  {C0F476A1-FA53-4652-9605-9E245B2…  {49586BA0-ADF3-4615-B7C1-C231F6E…  real         nein     1000       26
 2923 │ Polygon(333 Points)   {ADFD5114-27EB-4387-9E6F-4493AAE…  {B419EFEF-50CA-443C-AEE0-94BA4F7…  real         nein     2149        3
 2924 │ Polygon(906 Points)   {476B38F3-D7DB-4F6F-B617-CC89EF9…  {62DCA94A-0FA1-4AEF-80AF-E557977…  real         nein     4232        0
 2925 │ Polygon(463 Points)   {720FA8EB-9357-4FA2-B9A1-FD65FAB…  {4BD405B5-F542-42ED-AFE2-80935A2…  real         nein     6984        0
 2926 │ Polygon(612 Points)   {5161A2E0-5FE3-4CCE-BBCA-255044E…  {20041C94-7516-4D9A-A9FB-577308C…  real         nein     8605        0
 2927 │ Polygon(117 Points)   {5933ADF0-1155-4874-B9EC-02E3CD7…  {EE7438E4-6462-4F70-B9BC-D8F7A35…  real         nein     5084        0
 2928 │ Polygon(472 Points)   {EA341424-1423-4D81-9E2E-B522DFE…  {1DBC107D-2009-4A49-9373-EF9255E…  real         nein     1695        0
 2929 │ Polygon(525 Points)   {0F7F2500-1E06-466C-AC42-9A83B79…  {A14E5146-905E-44D9-9771-D1DEDDB…  real         nein     9037        0
 2930 │ Polygon(364 Points)   {5D69C53D-BD7B-44CF-9279-4B4D72C…  {1D5BE6AC-81D5-40A4-88FF-F4952D4…  real         nein     8574        1
 2931 │ Polygon(226 Points)   {675EEE7B-D8E7-4893-8BBD-59B8BA9…  {FE73787D-D8FA-43C5-BD98-57A33CF…  real         nein     3213        2
 2932 │ Polygon(213 Points)   {57AADC47-15F1-4B20-BBED-82D6A60…  {7B7215A4-8671-478F-9289-DBD083C…  real         nein     6760        4
 2933 │ Polygon(91 Points)    {B2665898-A49B-4E4F-815D-DB7B274…  {EE152998-606F-4BDA-8DC8-E4EAE1C…  real         nein     3994        2
 2934 │ Polygon(223 Points)   {B635A488-97F9-4AD4-BDE7-29C208E…  {1D457AF4-F0B3-440E-99A4-3BC7BF9…  real         nein     4578        0
 2935 │ Polygon(374 Points)   {ECCFEBDB-971D-424A-A67D-2970679…  {28740B1B-545B-47FB-B3A0-041B19F…  real         nein     1544        0
 2936 │ Polygon(205 Points)   {2050FEAC-9FEC-40E8-9582-58ACCDA…  {A1A4831F-4DAE-4FB4-AE6B-0628669…  real         nein     9554        0
 2937 │ Polygon(261 Points)   {677266B2-0D11-4AD5-BDDD-F2765CB…  {DDA9882E-6CA1-4DC4-99C8-44773F6…  real         nein     6653        0
 2938 │ Polygon(261 Points)   {E1255EAE-BDD2-4B82-A6C1-AB077E6…  {4C15126B-B17F-4245-8F8A-EEA6033…  real         nein     3252        0
 2939 │ Polygon(134 Points)   {FFCAE6B9-65B0-46B2-A761-56CA699…  {C8A5DAE9-4664-457D-AE18-1E0BD4A…  real         nein     6661        2
 2940 │ Polygon(282 Points)   {B85FE734-9BE6-4985-AE09-936912A…  {3C625BE1-00CD-45B5-8082-285CDE3…  real         nein     5244        0
 2941 │ Polygon(342 Points)   {D7107A84-F5FB-4CF3-AA88-DD47EF6…  {830218B6-C615-4470-8490-F5E4A60…  real         nein     3207        2
 2942 │ Polygon(431 Points)   {FD5063A9-AB91-43F5-8F45-76D7C9F…  {B6D18BA6-BEA8-46BD-93D5-2797F82…  real         nein     8596        0
 2943 │ Polygon(256 Points)   {2DC559E1-3D2B-4DFD-987A-7BE0C4C…  {035B94B2-0413-4202-9EC6-2985C85…  real         nein     1680        2
 2944 │ Polygon(175 Points)   {E53AD23F-C233-41DF-B523-30A4FAA…  {79513CEA-DC6B-47DB-9D3B-5662DDD…  real         nein     3274        2
 2945 │ Polygon(423 Points)   {7287747B-6A6E-4E7D-A73D-BAABBD8…  {EC47533F-9300-4606-8CE0-04EF166…  real         nein     1724        5
 2946 │ Polygon(289 Points)   {208A724D-132F-4C4C-84A0-00F34AD…  {0FB7A388-8831-43BF-8CF6-E9325C9…  real         nein     8259        3
 2947 │ Polygon(431 Points)   {84481901-B8FB-456A-905E-86ED758…  {477136D5-659E-4831-A04A-55CB5CA…  real         nein     3363        0
 2948 │ Polygon(313 Points)   {7D78092E-4CA8-4C43-B495-93BFD71…  {7B2285C7-F6A2-4314-9437-C3643DF…  real         nein     1218        0
 2949 │ Polygon(487 Points)   {D78520E9-8962-4D24-8514-2B15FFA…  {C132D77E-5413-43CC-A0D1-AD39E3C…  real         nein     3510        8
 2950 │ Polygon(395 Points)   {8E52B075-521A-46B9-AEE3-169C965…  {6711C2B0-090D-45AC-963A-702EB14…  real         nein     9244        0
 2951 │ Polygon(243 Points)   {65662B66-28B5-4BDB-8F8E-04403C9…  {01FA9C80-5CA0-4CC2-A75A-D57B2CD…  real         nein     6576        0
 2952 │ Polygon(706 Points)   {6A3DFAF8-6C25-47DB-A1E2-41B2122…  {ADC7CEC2-3F2E-46A4-99EA-1399548…  projektiert  nein     7433        0
 2953 │ Polygon(211 Points)   {096844FA-7C65-4B4C-9B16-7BF8C8A…  {0A6EE909-2102-4597-BD58-E70510E…  real         nein     8586        0
 2954 │ Polygon(327 Points)   {6E00607B-73EE-47A6-8D42-61DBB18…  {1476421C-55B2-4EBE-ADEA-583086C…  real         nein     4103        0
 2955 │ Polygon(838 Points)   {1E192470-72AD-4DAB-8B15-C0034D2…  {C7E345D5-9B28-462F-A57B-B7B0D3A…  real         nein     1166        0
 2956 │ Polygon(313 Points)   {E9DA7CBB-62C1-450D-9118-0A8F418…  {93C770E6-61FE-414B-BCFD-3113744…  real         nein     8203        0
 2957 │ Polygon(413 Points)   {9FF4D56B-6B4D-47C2-B9BF-97D1858…  {BB1A4C11-F2A7-4D1A-B8C4-808577C…  real         nein     1286        0
 2958 │ Polygon(838 Points)   {CFC9ED05-A008-4926-8C14-5DB839F…  {783D9125-55AA-4F4C-838A-60BFD50…  real         nein     4462        0
 2959 │ Polygon(684 Points)   {60F7411A-4A3F-455C-B122-C2E710D…  {E171197F-ECC5-47C1-8B81-8389602…  real         nein     1041       21
 2960 │ Polygon(812 Points)   {6B7176A0-35E3-4AFA-BCC7-C7E4509…  {9EF6FEB3-87F5-46CB-8246-FDA6C36…  real         nein     6285        2
 2961 │ Polygon(355 Points)   {6168C933-CBC9-48BD-98BE-3BAB6FC…  {66CFCB7A-89AF-428E-B4D3-7A09545…  real         nein     9215        2
 2962 │ Polygon(338 Points)   {C4A7E591-D4D7-4BB0-8BB0-91FB86A…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8047        0
 2963 │ Polygon(498 Points)   {1377A268-CDB5-472B-A54F-4C6CC1C…  {C66E1655-6D2B-4E92-82A4-3731A99…  real         nein     3604        0
 2964 │ Polygon(726 Points)   {03BF528A-CF04-45E3-B191-10E2403…  {96E1FED8-1B15-49BE-9946-E701443…  real         nein     1020        0
 2965 │ Polygon(336 Points)   {B726F710-F3CB-4C34-A750-D0EA7B1…  {D5F8428A-A522-4739-8236-A25F016…  real         nein     1288        0
 2966 │ Polygon(276 Points)   {A7AD7DED-75DF-4AA3-BFA3-F201223…  {8F3300A3-B3E4-4801-9BF8-9B6CE2A…  real         nein     3374        0
 2967 │ Polygon(375 Points)   {2406635E-61F9-4BDA-BB98-37DFE14…  {0A4287F3-1FF1-41E8-91C3-0C2E26B…  real         nein     3127        0
 2968 │ Polygon(492 Points)   {A1592DD3-8EAB-4828-88F2-27147E4…  {C2087556-028A-4A3C-B586-2C1BE14…  real         nein     1031        0
 2969 │ Polygon(521 Points)   {1F3D55E3-9344-4242-94A1-DF9EB18…  {B0D55400-C9F9-43E8-A1B6-B5EB19D…  projektiert  nein     6545        0
 2970 │ Polygon(410 Points)   {450C2DE6-9785-4788-A11E-131BD38…  {FEAD0BCC-20E5-4542-A3C9-8B5C5E2…  real         nein     1121        0
 2971 │ Polygon(351 Points)   {C6A74807-CC61-4673-8A2E-35E7EFF…  {217A8EEB-CE6A-4507-A27B-27B7B11…  real         nein     5464        0
 2972 │ Polygon(300 Points)   {F041301E-59FD-40CE-9115-A92D7E8…  {D7D27017-7997-4DE5-9E5E-2C8D3A3…  real         nein     6286        0
 2973 │ Polygon(762 Points)   {18326F36-5CA1-4763-9A99-6F82B53…  {A3ADF68F-554C-442A-B7C9-9AE0A90…  real         nein     1832        0
 2974 │ Polygon(235 Points)   {5EEE9F9D-D273-46CB-BE54-A056375…  {693BDF30-351F-48F9-82C9-48A4128…  real         nein     6652        0
 2975 │ Polygon(607 Points)   {CB60F7BC-A5F2-4315-A2EF-E35E16F…  {60C7E74B-CE2E-4B84-903F-ADADFC0…  real         nein     8322        0
 2976 │ Polygon(391 Points)   {E92A387B-D5E4-4FFA-9F44-D4F78AF…  {5B4E1910-884A-4266-B03C-03E4915…  real         nein     8421        0
 2977 │ Polygon(352 Points)   {E34DE41D-3BF7-4C00-A53B-2A595DB…  {8D1116CB-3AD3-4AAE-A540-A78E133…  real         nein     5035        0
 2978 │ Polygon(284 Points)   {C500EC03-7459-4ABB-9D39-5240635…  {F953CF7B-3D39-43A8-9ADB-7227AA3…  real         nein     5315        0
 2979 │ Polygon(216 Points)   {FC5AD81D-CAD5-49F1-B183-1B35161…  {93B6D42B-ABEC-4B4B-BF60-5ECC77E…  real         nein     6600        0
 2980 │ Polygon(200 Points)   {03370E84-5CA6-4C3A-B8F2-5694792…  {90F3BFE2-68B0-4BE8-9FC5-74788F0…  real         nein     6809        0
 2981 │ Polygon(494 Points)   {BD925C3E-06DD-400F-AC4E-579D9E3…  {2067FC3D-C40C-440B-AC1A-112E856…  real         nein     4936        0
 2982 │ Polygon(205 Points)   {972A66C4-69C9-48A5-9EFC-28F76AE…  {2E80133B-5A65-4905-90C6-AF5C9A7…  real         nein     8465        0
 2983 │ Polygon(1520 Points)  {7E57F54D-9922-4BA2-87B4-3F42A26…  {88DAB625-F196-4D83-A77E-1BD0D68…  real         nein     1053        2
 2984 │ Polygon(101 Points)   {6F811071-B4D0-4FDA-945E-DF3646A…  {0D3A0931-109A-478B-B6A2-CCE8AD3…  real         nein     3646        0
 2985 │ Polygon(248 Points)   {610DF27B-38FA-43F8-A954-F731F09…  {A63B6142-82EE-4A2F-A9BD-0F74B4E…  real         nein     6236        0
 2986 │ Polygon(98 Points)    {FB05811B-2B4F-4B96-A5C3-806736C…  {356985F0-1818-4CD1-9A9D-7E9D185…  real         nein     1255        0
 2987 │ Polygon(334 Points)   {3AFCBB1C-8452-4194-9DC5-512B66F…  {0112A523-9BCA-462C-B2A9-F48DB84…  real         nein     3324        2
 2988 │ Polygon(284 Points)   {123B0614-32AD-42C4-A841-E423C18…  {B9ABB5F9-9655-46FF-88AC-055265A…  real         nein     8114        0
 2989 │ Polygon(474 Points)   {15B28074-0AC1-4A2B-A0B4-26CFD4D…  {C678F114-FAE3-4AF2-8B8A-4FB1273…  real         nein     6028        0
 2990 │ Polygon(486 Points)   {881D6621-50AA-4687-B909-0A6B42A…  {C5820B30-A415-4C2C-AA15-B137C43…  real         nein     5706        0
 2991 │ Polygon(287 Points)   {7AD31630-A369-4584-B598-9A44B1C…  {A848ABF2-69F7-4522-9477-8D852D5…  real         nein     1436        2
 2992 │ Polygon(665 Points)   {95051D31-415B-4082-9E46-CC0182C…  {95DE7E4C-C7AC-4E7C-91E6-E8FCF05…  real         nein     9240        0
 2993 │ Polygon(290 Points)   {B452F33B-F11E-4710-8F1D-03E7D16…  {E39AD3ED-D8F4-4231-8831-C0C25C6…  real         nein     5043        0
 2994 │ Polygon(395 Points)   {8D818EEA-B7EC-4597-B88F-E9B7DE9…  {3522CBBA-D51D-4578-AD71-56448B7…  real         nein     1669        3
 2995 │ Polygon(428 Points)   {A8704AA6-47BE-4F70-A7EB-4BDF200…  {425B87D5-CBD5-4138-AEA1-7EF9944…  real         nein     3053        3
 2996 │ Polygon(79 Points)    {0DA193A5-68F9-4C11-81A1-DFD330C…  {0A5C88E2-C6F9-4F3A-BC03-B559E12…  real         nein     1945       12
 2997 │ Polygon(331 Points)   {E9455959-B059-4E59-831B-D83A4CC…  {5A2C1A01-00AB-4FA3-B1A6-3966514…  real         nein     4917        2
 2998 │ Polygon(839 Points)   {BFBC2280-EA0F-4CA9-B64D-2F5B9D5…  {FEBA8E2E-ECBF-42E3-9587-E782BF0…  real         nein     1820        6
 2999 │ Polygon(391 Points)   {BE80FE93-DBCC-44DA-B2C2-5AC4C63…  {05A93CC2-A304-46EE-B8E5-1E64D8B…  real         nein     6837        2
 3000 │ Polygon(337 Points)   {DD0B2199-5D7E-4749-A495-7CF335F…  {8E9F3F23-5CA4-4A0D-8879-8481627…  real         nein     1483        0
 3001 │ Polygon(331 Points)   {32EC18AE-2D9D-4F75-AA05-02EC238…  {A54252DA-729C-4133-A5AC-04B9B0D…  real         nein     1279        0
 3002 │ Polygon(54 Points)    {FC6E181B-EB09-469C-9D1C-14F1B40…  {044A365E-48FA-4E52-8050-1F6472E…  real         nein     1933        2
 3003 │ Polygon(450 Points)   {8A496AAF-5469-4F93-A29C-3064A87…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8006        0
 3004 │ Polygon(157 Points)   {4D7B1364-9DA9-4F8F-A908-98807FF…  {C3720992-EB2C-4AED-A809-929A52C…  real         nein     1258        0
 3005 │ Polygon(541 Points)   {4E9037F6-310B-4E75-B413-449AFE1…  {AAD37534-2241-4124-A83E-FAF6883…  real         nein     6827        0
 3006 │ Polygon(321 Points)   {D844E4F6-BF59-41AA-B983-60F4C13…  {0566E8E2-C00A-40B9-9932-5CA2AA0…  real         nein     1784        0
 3007 │ Polygon(391 Points)   {75C23267-013A-44B1-92D6-624328C…  {78A78E35-CB34-4B6D-8B11-D7D1F3B…  real         nein     3214        0
 3008 │ Polygon(632 Points)   {1F0FA4AA-AE8A-45B0-92CD-86E593E…  {11AD09E9-268E-40EA-9610-60163B3…  real         nein     4916        0
 3009 │ Polygon(90 Points)    {C2AD5391-EE30-42AB-B582-1C4B9BF…  {F3CBF79B-EC1B-4F3D-9C7A-6E89A67…  real         nein     6534        0
 3010 │ Polygon(108 Points)   {360821A6-5FCF-44CA-AF68-2E2C0C3…  {E2630401-DB58-489B-9B97-A9D709E…  real         nein     1962        0
 3011 │ Polygon(618 Points)   {3D6B3CC8-66BD-4DA1-9667-BA38335…  {B44A4F42-15CC-4ED5-81C0-8CA1986…  real         nein     1658        2
 3012 │ Polygon(464 Points)   {AAD3235F-0F72-4E45-86C8-60812D7…  {38092170-78BB-4101-9910-D06F421…  real         nein     1526        0
 3013 │ Polygon(84 Points)    {3E4F0E7A-BFCE-4372-8DC0-DC4C722…  {3DE2A6CD-AFBD-4525-B88B-017DBEB…  real         nein     4117        0
 3014 │ Polygon(155 Points)   {B2FC0A47-E69E-4355-8578-C7A44FE…  {776CA3AB-A4B7-4B4D-8590-9FEE804…  real         nein     1721        2
 3015 │ Polygon(288 Points)   {F04E8E03-AD79-4AE9-A07D-BEE6EBD…  {1C419FD9-3281-4D2C-B4B4-B40777C…  real         nein     5333        0
 3016 │ Polygon(618 Points)   {AF301200-CE8C-416C-A553-F2728F9…  {9400E28D-94A5-4FA6-8894-3452FA6…  real         nein     8331        0
 3017 │ Polygon(355 Points)   {55BB2BB5-BEB8-4C84-B3EE-89E1542…  {00E7FB3D-7DCA-438E-A6AF-B17B005…  real         nein     5619        0
 3018 │ Polygon(293 Points)   {1DA510A6-0676-4250-B408-DC08336…  {409137E4-925E-46E3-A01B-3EEBB43…  real         nein     4332        0
 3019 │ Polygon(89 Points)    {1B1A0C77-D41D-454E-A789-846297A…  {3F6335EA-FF90-4AC4-BC5B-2CA7B95…  real         nein     1923        2
 3020 │ Polygon(351 Points)   {DBE0B225-61A6-44AF-8A97-AE2634D…  {EECF1F63-F026-42B0-AEE2-DA45308…  real         nein     6987        0
 3021 │ Polygon(146 Points)   {B79F6186-AA73-4FCE-BF3A-DADED45…  {4519B982-330E-44B6-8E29-E609B46…  real         nein     6035        0
 3022 │ Polygon(223 Points)   {F48D1E70-ACD2-4E1C-922B-C9C42EA…  {100FF52C-215D-4CB1-8AA1-501BC02…  real         nein     3306        0
 3023 │ Polygon(221 Points)   {D0847E47-3A6D-4A27-B0F6-E9DA77C…  {8C69BF82-DD2A-4436-B0A2-E84E19F…  real         nein     5326        0
 3024 │ Polygon(1027 Points)  {B619DE8B-6866-4969-AD3D-7279D75…  {5CC514A2-4059-4DCF-8627-FF50222…  real         nein     8268        2
 3025 │ Polygon(375 Points)   {9101778D-B46D-4B69-AA05-3CC887A…  {542BA570-1817-447B-9CCB-11FEA80…  real         nein     6922        0
 3026 │ Polygon(625 Points)   {712E7E4C-0556-44E8-A6D2-3D1056B…  {464B81EF-CF37-4365-935E-A8671A9…  real         nein     3362        0
 3027 │ Polygon(200 Points)   {9E96B0A1-310B-4DD9-A3BD-DB7BC78…  {27005183-ED4B-43AE-8664-2E28FF1…  real         nein     6864        0
 3028 │ Polygon(532 Points)   {E5A8A5CA-7A56-4F0F-B7A1-4007CD5…  {2BFA6DF2-E570-4537-A088-52A72E6…  real         nein     2063        2
 3029 │ Polygon(300 Points)   {FD5767C8-E39E-45C1-AF78-72218B6…  {E5951E37-7BFD-444A-ABB8-C8F4BAE…  real         nein     6036        0
 3030 │ Polygon(130 Points)   {2CE72F1F-72BD-4900-8718-F5861DA…  {610F5DCD-08D3-458A-A0D2-FB0ECAD…  real         nein     1586        0
 3031 │ Polygon(478 Points)   {BE634F53-C81B-4BB0-ABCE-7049E18…  {B0E2D085-3544-46D0-9D63-B7A1DF9…  real         nein     4618        0
 3032 │ Polygon(238 Points)   {AE6FCFAD-0114-46E9-9838-7154CB4…  {F784F2C9-09E0-42A3-8D33-C5B7D25…  real         nein     8537        2
 3033 │ Polygon(339 Points)   {508A75F2-BC22-42EF-8055-DB2DB3F…  {68FCC8E0-A9EB-4976-AA90-BAF2F23…  real         nein     8603        0
 3034 │ Polygon(717 Points)   {C567C564-812B-4CC9-938A-85AF12E…  {E5989EE0-8DC5-417B-9FF8-F818E58…  real         nein     1607        4
 3035 │ Polygon(222 Points)   {7065CFF7-4891-4470-B658-4447466…  {3595310A-D24E-4DB1-A82A-BF48985…  real         nein     7463        0
 3036 │ Polygon(305 Points)   {CA0E3741-51BE-44D8-ACCE-93229D1…  {546C185C-809E-480E-845C-B4E63A7…  real         nein     5611        0
 3037 │ Polygon(429 Points)   {4836288D-0057-4C74-B553-007FEBB…  {F6A96C25-4B8F-4407-9454-87E9E58…  real         nein     1687        3
 3038 │ Polygon(357 Points)   {ED2DF5B3-5646-40DC-A685-2242D34…  {819EA2DB-1E4C-4B25-AA94-56BB300…  real         nein     8732        0
 3039 │ Polygon(484 Points)   {CCC498EB-7084-467E-AD95-B801039…  {FD321BB0-87C9-4505-A730-EC43499…  real         nein     9305        0
 3040 │ Polygon(387 Points)   {695B7EF3-18A0-4886-9E97-143318E…  {538EA391-D1E6-4521-945B-3337AF5…  real         nein     1213        0
 3041 │ Polygon(495 Points)   {640D3C82-D24B-4CC0-B36A-395504B…  {46C1269B-E97F-40A8-ABB0-273BEB2…  real         nein     8955        0
 3042 │ Polygon(448 Points)   {B8BA48CA-07F8-4B81-899B-F82AFC1…  {4884372E-27C7-4BB8-96EB-946B310…  real         nein     1246        0
 3043 │ Polygon(190 Points)   {C9C56B4A-A686-4B11-995A-D76D99A…  {9529C555-112C-458D-84F1-4BEF9C7…  real         nein     6692        1
 3044 │ Polygon(233 Points)   {DCC38E03-037C-42F9-B795-039B4CB…  {E31EE57D-68FC-47B2-B5DA-0423723…  real         nein     4534        0
 3045 │ Polygon(492 Points)   {28840B2A-D438-4693-B393-EC78D04…  {4B020AA9-6BA8-4F1D-A952-0CD82A4…  real         nein     3671        2
 3046 │ Polygon(369 Points)   {C76669AA-ABA5-4A0C-B07F-DF9CEC4…  {1A1BD601-FB34-4E6B-85E5-AC5750F…  real         nein     4613        0
 3047 │ Polygon(176 Points)   {75CDCC07-68A1-4706-A9BE-0F41C1E…  {E32BFE74-6287-4E4E-B25E-D30F6BB…  real         nein     6319        0
 3048 │ Polygon(374 Points)   {8287F3D2-5F4D-4020-8A4D-3E176D1…  {685FB1F5-D998-4999-96F6-81ECD48…  real         nein     1695        2
 3049 │ Polygon(218 Points)   {F66E744D-E87E-463A-8593-A0A3A6F…  {D996ED07-F51F-4E54-BE90-075EE0A…  real         nein     8273        0
 3050 │ Polygon(524 Points)   {A3D1DFEE-7BCF-4300-951F-2928283…  {84294B1C-5479-4769-9207-A44A571…  real         nein     8512        3
 3051 │ Polygon(259 Points)   {2DA4AEF2-A3CB-4C83-950B-65603D5…  {EE903FA7-3B67-456C-9BFE-219E3C1…  real         nein     2557        0
 3052 │ Polygon(601 Points)   {9933028C-2B07-4889-90F6-8C6C02B…  {6B6EBBA3-41E4-4AC2-A87F-45C8C1C…  real         nein     6926        0
 3053 │ Polygon(228 Points)   {3524985B-7E44-4418-B902-5E21869…  {96E20A1C-D395-487E-8ECB-A70339B…  real         nein     2053        0
 3054 │ Polygon(372 Points)   {DCFFA732-FEDE-4CED-8549-64F5767…  {812EB0B4-EE28-4E18-8699-46C3A2E…  real         nein     3116        3
 3055 │ Polygon(347 Points)   {D1A62A7A-942B-4854-B751-E0FEFE5…  {81B25B35-661B-4CD8-B8F3-362E4B1…  real         nein     3323        0
 3056 │ Polygon(350 Points)   {08C57DCB-2B5C-4807-BDB2-B135F43…  {B1286580-385E-4BBB-BF0C-0514FC3…  real         nein     3262        0
 3057 │ Polygon(185 Points)   {0659C540-E4FA-44F1-B9CB-072450A…  {F4DAF96A-4491-44ED-904D-DD23E9D…  real         nein     3077        0
 3058 │ Polygon(143 Points)   {C5A5EB5F-22EC-4E2C-86BF-63310E6…  {B36165E1-DAE8-4549-8A2C-FD9D0A9…  real         nein     3257        1
 3059 │ Polygon(882 Points)   {244934A6-75E8-412D-9F04-F8D9035…  {2AC40700-14FE-404A-8865-D512DAB…  real         nein     6835        0
 3060 │ Polygon(158 Points)   {84D805ED-1FA8-4392-8A08-951D6E6…  {989FDE23-4C32-45DE-921D-7883CAD…  real         nein     3960        4
 3061 │ Polygon(412 Points)   {948C3C54-024B-4138-9B11-8CEF183…  {EB427A8B-8AC7-4167-9470-E460254…  real         nein     1421        2
 3062 │ Polygon(203 Points)   {12D44D42-C47F-4331-936C-58974B2…  {EABF7C9F-55E1-4762-81F5-E76E681…  real         nein     1958        2
 3063 │ Polygon(415 Points)   {D9C3ED30-D249-4500-849D-29BA01E…  {C4070736-917E-48C2-9129-88F08BC…  real         nein     2733        0
 3064 │ Polygon(201 Points)   {E215DE40-7D1E-482E-B3A9-9905EFB…  {769EC509-7D6F-45DF-9662-0A4195D…  real         nein     6959        2
 3065 │ Polygon(195 Points)   {A197DCF8-FA88-450C-9193-0F57132…  {993D697D-41D0-4060-9FE9-9102AC9…  real         nein     1726        2
 3066 │ Polygon(716 Points)   {EC8414FC-5110-4197-9CA9-33E0D20…  {97426EF0-E81F-46AA-A0CC-20EC836…  real         nein     1832        2
 3067 │ Polygon(243 Points)   {B792918D-290C-45FC-9A3C-30B4DCD…  {0D3C6FFB-EDB7-4B02-A240-287FE10…  real         nein     5465        0
 3068 │ Polygon(464 Points)   {B6F7560C-773C-4EBB-B971-EF1A330…  {F71A6702-0811-4E10-A320-1A939B0…  real         nein     8967        0
 3069 │ Polygon(845 Points)   {3346A4D6-A531-4656-BE70-C86DADE…  {4C4025BF-F253-4DE7-8000-F5C33BC…  real         nein     8409        0
 3070 │ Polygon(123 Points)   {88D5F92C-6E63-42EF-AC90-93B9E7D…  {DD140B19-5321-430E-B966-2CF9DF5…  real         nein     1215        0
 3071 │ Polygon(597 Points)   {03CD98DC-73C3-4D11-A47B-85B5261…  {48F49B01-24B6-4E29-848D-5C47520…  real         nein     3623        3
 3072 │ Polygon(435 Points)   {C82BCED1-B54B-4085-8E0B-C197D48…  {3BD4F7FE-0A15-4160-9B65-BB4231B…  real         nein     1675        2
 3073 │ Polygon(290 Points)   {19A00A88-7413-4CA1-9B65-278EAB3…  {043559B3-D3E2-43A2-BABC-41F6D59…  real         nein     4571        1
 3074 │ Polygon(439 Points)   {D1D82770-8B31-4526-B17C-4F1EF96…  {A2DF7EE9-F136-4AB2-BF54-37BCCDC…  real         nein     1232        0
 3075 │ Polygon(530 Points)   {360FEB9F-DCA6-477A-9E0E-427D335…  {3A230A97-E8D9-44BC-AD56-154C128…  real         nein     1148        7
 3076 │ Polygon(354 Points)   {E1BB362C-F041-4745-AD14-D9073B3…  {A9E727E7-BFF6-4483-9667-915EDFE…  real         nein     9249        0
 3077 │ Polygon(576 Points)   {7D3B5384-D3F1-4A4D-9319-C60F356…  {8ED51951-9EC7-4E56-8F34-F2EA09D…  real         nein     1267        2
 3078 │ Polygon(269 Points)   {0E3E878E-3DE9-4C44-8D19-63DADCF…  {61ED7058-092A-4EDC-B11D-21CBFE1…  real         nein     8259        2
 3079 │ Polygon(214 Points)   {A2CD1FD3-467B-4D63-99DD-0DE26D7…  {ACCA5526-5AFB-469A-A040-5396A18…  real         nein     1043        0
 3080 │ Polygon(645 Points)   {F2ED644C-6FFD-4A4D-AA2A-5A3DB92…  {BE72D81F-7AF1-48D6-A01C-B2F289B…  real         nein     5625        0
 3081 │ Polygon(230 Points)   {EDFA7FBD-4FD7-4AE0-9BBA-8834BA0…  {E115BAED-BDA1-4847-9613-A8F5808…  real         nein     8465        1
 3082 │ Polygon(552 Points)   {D4E936DD-7F08-41EF-93D5-54D3643…  {765127B8-F84E-433E-B278-57F0FEE…  real         nein     1695        3
 3083 │ Polygon(281 Points)   {34EA233A-41B6-4B40-B135-9AA8C2A…  {A1818EFD-E570-4781-A7FB-225E50C…  real         nein     8162        1
 3084 │ Polygon(510 Points)   {F355EBD9-6CF5-432D-BB95-B7E4291…  {5BB573E6-B3DE-4DCA-B274-F2C2F4E…  real         nein     1213        3
 3085 │ Polygon(1049 Points)  {506E4605-3595-440B-857C-DF100BC…  {C83B682F-CD57-4A86-9A48-F97FB23…  real         nein     1092        0
 3086 │ Polygon(388 Points)   {8851954A-21F0-418A-A1D5-A8DE365…  {961C3626-8D11-4608-A925-3B85817…  real         nein     8103        0
 3087 │ Polygon(206 Points)   {D16C88CD-5180-41DA-A4A5-45D14E8…  {A625E4FF-ABA4-44BA-82C9-BD1A2F0…  real         nein     8585        5
 3088 │ Polygon(319 Points)   {D54CC445-C84F-4ABA-BAAA-5357909…  {5FC19E9D-33B6-4245-B9D0-4160BF1…  real         nein     1554        0
 3089 │ Polygon(539 Points)   {7D3A213F-42EE-40A8-AFC4-36100C5…  {F1CFF272-7CAE-4E19-AD56-A3BBF1A…  real         nein     1173        0
 3090 │ Polygon(450 Points)   {8D494738-ABC0-468F-965A-AC74B5D…  {FD80B10C-F0D8-46E5-93C1-20833D6…  real         nein     8152        1
 3091 │ Polygon(271 Points)   {B9430443-832E-45B4-B7AE-15767F4…  {058ADD6C-CAA2-4FF1-B05C-7BBA994…  real         nein     3636        0
 3092 │ Polygon(204 Points)   {38FCBFED-B07A-49A3-BEF0-5DB790B…  {6C6053B9-4CFF-4AA8-98B4-C4CCCAD…  real         nein     8616        0
 3093 │ Polygon(274 Points)   {8F88F249-CEFC-4298-9D2F-6497FEE…  {47D21D61-455E-437A-BC54-9A5EED2…  real         nein     1681        2
 3094 │ Polygon(202 Points)   {2399BB8F-C1F9-414E-BBDF-0B00694…  {E45D3923-CE6D-4B40-B557-D6BE1A5…  real         nein     3711        0
 3095 │ Polygon(341 Points)   {63D0FEDB-B546-474C-B65F-7DF93F6…  {BC9DC95E-110B-4089-B77C-328D039…  real         nein     4557        0
 3096 │ Polygon(265 Points)   {88A91DE5-458F-41EB-9684-B9EFA84…  {CA59C6BC-97A9-4CE4-99BF-346B224…  real         nein     3429        2
 3097 │ Polygon(120 Points)   {BD13511C-A647-4DBC-BC08-E14661C…  {0C5E676B-8ACA-42DA-B3CC-2F0F938…  real         nein     7223        0
 3098 │ Polygon(211 Points)   {99D6C674-1307-44C4-99F2-CDAD47D…  {10CB6B88-1E42-45E2-A3AC-26A53CA…  real         nein     2715        1
 3099 │ Polygon(667 Points)   {51616F3A-BBCD-42A7-94C5-253967B…  {7D70D7D4-6C0A-402D-87F1-029FB48…  real         nein     6934        0
 3100 │ Polygon(405 Points)   {302A1FD1-71E5-4E8B-BC6E-749623C…  {B68C1477-3754-4279-823C-DA17B8A…  real         nein     3472        2
 3101 │ Polygon(567 Points)   {07BE37A6-D2FD-489C-83EE-05D1E5E…  {56502F26-7ABD-414E-ACC2-BB78E7E…  real         nein     3973        0
 3102 │ Polygon(418 Points)   {D1DB4049-7B3B-4D60-89FD-AAED3A0…  {98E68CC7-A906-4DCF-A263-67E249C…  real         nein     1775        3
 3103 │ Polygon(484 Points)   {0827024E-562F-4126-B01E-645F9EF…  {C14B8645-2BF8-49F9-AB08-BC72B6E…  real         nein     1525        0
 3104 │ Polygon(265 Points)   {B9C1DCEF-6CEF-4086-903B-4F9E01B…  {D7108DF6-51DB-4140-8C8D-5E8454F…  real         nein     8564        4
 3105 │ Polygon(239 Points)   {7F987AE1-BFE3-4C54-A26D-A47DDEF…  {557B049D-7AEE-4995-BD28-AB3A50D…  real         nein     7206        0
 3106 │ Polygon(519 Points)   {53685133-83D2-422B-B04A-11E492A…  {784F0015-8DEF-482B-9665-9C34C75…  real         nein     8543        1
 3107 │ Polygon(442 Points)   {98597B10-62AB-40FF-B709-093377E…  {B5A98C4E-F4EF-4213-A87C-1DBEEA9…  real         nein     1165        0
 3108 │ Polygon(577 Points)   {D053EF13-7292-4C68-932F-50A41BB…  {10AA1E4E-9173-4D58-A83C-C954404…  real         nein     4108        0
 3109 │ Polygon(271 Points)   {8B5DD0CC-2BE0-43D0-BDA0-8FA8783…  {2379676A-812F-467C-860F-8D99242…  real         nein     5334        0
 3110 │ Polygon(598 Points)   {3A5E155A-141A-4CC6-9B9E-CBD0735…  {A2CF3C7D-E92C-4D0B-AA91-85EED94…  real         nein     8586        3
 3111 │ Polygon(365 Points)   {399B656D-ABD6-4322-8398-7EF8D61…  {E4F6F373-B645-40B7-ABD0-F86C172…  real         nein     2014        0
 3112 │ Polygon(807 Points)   {DEEEBAE6-8BCA-47FF-A5E1-C14CF66…  {36FDEC6D-2E1B-4BE5-8E1E-180B362…  real         nein     1063        4
 3113 │ Polygon(316 Points)   {AD11C31B-E3FC-44B9-AEDC-C82AD20…  {A6693BD5-A811-4470-954B-485F4AB…  real         nein     1112        0
 3114 │ Polygon(257 Points)   {FE3E1D09-1F87-42F0-8FBF-DB683E2…  {24F2EF0F-852D-41CC-8D5D-A2E8922…  real         nein     8926        3
 3115 │ Polygon(628 Points)   {5B9481BD-3588-46ED-B3BB-6DC6726…  {2D4DFF7F-17AB-4C77-8E00-DFD27EA…  real         nein     8772        0
 3116 │ Polygon(256 Points)   {810B721F-BB65-463A-BFC5-E8D22AB…  {065B8819-8A8C-4C82-952A-F299CAF…  real         nein     1775        2
 3117 │ Polygon(210 Points)   {43E2D6A3-1DC6-421F-A929-59FDD03…  {7593F439-B4DD-499F-A181-8997F23…  real         nein     1274        3
 3118 │ Polygon(267 Points)   {30AC13CA-6A3B-4521-950E-5352F9D…  {1A626989-B8AD-40F0-B14B-19B9926…  real         nein     5080        0
 3119 │ Polygon(182 Points)   {9F0AC6A9-F20F-403B-88E5-E011807…  {17A29974-8EC8-4826-B1C1-75B01E3…  real         nein     4812        0
 3120 │ Polygon(333 Points)   {CB8FAC45-EB7D-4901-8CA9-92BCC9C…  {777385AE-F473-48FC-A9C2-8F734C8…  real         nein     1528        0
 3121 │ Polygon(259 Points)   {A9FBFAAF-43F8-4A0F-988B-647E0E9…  {9EB5F8F9-3F8D-49F9-97F4-C06B1F0…  real         nein     9565        0
 3122 │ Polygon(257 Points)   {8B079695-99A4-489D-A3A0-7E3C7F5…  {6CE4C42F-18D6-4781-88E2-EEC58D4…  real         nein     4587        0
 3123 │ Polygon(237 Points)   {B65DAB0B-469C-4282-BADD-91D383B…  {9D6FFEAB-5D63-4D44-908E-E71FD6B…  real         nein     3805        0
 3124 │ Polygon(438 Points)   {6528FFB9-73EE-4A96-ACE9-4BAA103…  {712936FB-015D-43DA-A397-0FA4064…  real         nein     6994        0
 3125 │ Polygon(455 Points)   {31C9F154-8079-4A8E-83E9-1C8DDD5…  {76FA76CF-23C6-4226-A049-8DBA979…  real         nein     6828        0
 3126 │ Polygon(251 Points)   {D3385571-3A54-4D82-972E-C8B033A…  {303B3423-8CBA-4895-8472-935C46D…  real         nein     6823        0
 3127 │ Polygon(333 Points)   {2F116677-32D9-4B41-886E-F1992BD…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4056        0
 3128 │ Polygon(99 Points)    {8B37FF1F-D5BA-4350-98C7-BCEC47B…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3004        0
 3129 │ Polygon(138 Points)   {F4DCFFE4-00CA-44DD-B000-0E36A44…  {BCFD9331-4005-47DC-8BE6-DF267F6…  real         nein     1245        0
 3130 │ Polygon(478 Points)   {CFCD096B-12B2-46CD-B59A-B96BD22…  {F3160F50-DA8E-4091-9558-3EC43F6…  real         nein     4444        0
 3131 │ Polygon(356 Points)   {E17E1794-F25C-4360-A407-2997270…  {43C33CE8-F942-4F90-B86F-0E236DE…  real         nein     1996        0
 3132 │ Polygon(178 Points)   {D5161E75-1CA1-4FE2-8934-858E598…  {C207A06C-E4DE-49F9-A1D9-F4BA110…  real         nein     6532        0
 3133 │ Polygon(73 Points)    {02264FF1-61D4-430E-B982-2007421…  {EE171A77-C666-485B-B211-BF4F707…  real         nein     1988        1
 3134 │ Polygon(650 Points)   {28D92AE3-13BE-4189-A087-97768D2…  {57A0A696-CFDD-4D8C-BAB4-60A0A2E…  real         nein     4532        0
 3135 │ Polygon(281 Points)   {43130F77-5634-48BC-BECB-5442BF1…  {D7AD8F83-4FE2-496D-8610-7BC5FCE…  real         nein     8192        1
 3136 │ Polygon(210 Points)   {1D2C9E9D-0079-47E8-AEA2-A417F5F…  {855B3C94-2B8D-44F8-9B32-C87AA23…  real         nein     5405        2
 3137 │ Polygon(183 Points)   {40AB9B76-3929-4871-AD3E-D1E567A…  {850EF094-14B3-405F-90C4-9958FBE…  real         nein     5617        0
 3138 │ Polygon(449 Points)   {214355E3-FF90-4015-9CB3-981DE61…  {2EE52E97-516D-409F-980E-5B6F00D…  real         nein     1241        0
 3139 │ Polygon(463 Points)   {2B88EFC0-D5F4-4137-8A44-12AD0A0…  {441DFDC0-2B2E-418D-A94A-31D658D…  real         nein     9424        0
 3140 │ Polygon(657 Points)   {7E97E1E0-3A50-4F92-8759-4C25BA1…  {A4658AF7-F280-49E0-BA91-7D808BF…  real         nein     1510        2
 3141 │ Polygon(191 Points)   {745D97F1-406A-43FD-BA13-789788C…  {DACE80DA-AC4E-47FD-8763-3BA91FC…  real         nein     4334        0
 3142 │ Polygon(126 Points)   {44B1CF55-5AC7-47B5-8E0C-39B8DF0…  {17D21947-4C2A-46BA-8D90-DCCC073…  real         nein     7442        0
 3143 │ Polygon(54 Points)    {1CD6398D-7E99-4A3F-BE3B-A14AD32…  {5968688F-2AC5-43E3-BEFB-1F78698…  real         nein     1991        0
 3144 │ Polygon(184 Points)   {E11C33FA-B8F5-443B-98CE-AC2F4C7…  {85029050-7198-46A2-8C9B-22074E3…  real         nein     1541        2
 3145 │ Polygon(512 Points)   {7E546420-861D-4179-B72F-F362564…  {2DBEB0B5-4BD4-4D12-81F5-41A0E63…  real         nein     1673        0
 3146 │ Polygon(370 Points)   {3F497F96-35CE-4C01-B24A-F5DF0FB…  {92B55018-0D34-4D84-9A49-07AF505…  real         nein     8371        0
 3147 │ Polygon(545 Points)   {A4540F46-CD7D-4E26-831B-F02970E…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1010        0
 3148 │ Polygon(201 Points)   {5DE3DFA2-29A7-41AA-AAE1-261C0F8…  {4B31624A-955B-4B39-A8A1-F824476…  real         nein     9565        5
 3149 │ Polygon(491 Points)   {2575573A-0CA2-4622-B1B2-02AEDE7…  {337259AE-3546-40DE-8362-C32D0E1…  real         nein     8152        0
 3150 │ Polygon(141 Points)   {E3E8B492-3E79-4725-9065-0221E58…  {2E2B2740-4F5C-4948-8671-A60C8BA…  real         nein     1356        2
 3151 │ Polygon(396 Points)   {E06553BF-1C1D-49D9-AEE0-A32B92F…  {15F4C70F-761C-43A1-9C87-0DEBFC5…  real         nein     5735        0
 3152 │ Polygon(518 Points)   {767F475B-B7E1-49F8-AEFD-6AA02F6…  {7E693FF5-D78E-4273-90E6-3E771D0…  real         nein     6964        0
 3153 │ Polygon(198 Points)   {F6C6CDDB-8561-4A6A-920C-027651B…  {F80068D7-FBD6-41FC-8690-4D4DA01…  real         nein     8597        0
 3154 │ Polygon(637 Points)   {364A9306-A661-4AC9-B68E-3605821…  {2E91DB08-2C42-4F1C-BDDC-DF75223…  real         nein     6003        0
 3155 │ Polygon(237 Points)   {B24030ED-E828-4297-A5B2-824F99D…  {18CA4BDE-3E00-4318-B74E-AB7D358…  real         nein     1797        0
 3156 │ Polygon(218 Points)   {AD840707-55F1-4C02-9562-D61C2C3…  {5B93DDEC-C740-4F9E-AD18-F2BB689…  real         nein     2362        2
 3157 │ Polygon(203 Points)   {34AB196A-432D-44EE-8929-D59A1DB…  {691B4CB7-18E5-4914-860F-5EE87ED…  real         nein     8898        0
 3158 │ Polygon(628 Points)   {9BD15794-55EA-479E-946F-6E88A83…  {4ACF0A24-66A5-4D44-9F12-2CF4AE2…  real         nein     6832        0
 3159 │ Polygon(290 Points)   {6AE877E3-B844-4181-BB8C-D9DCC4A…  {9D773179-C8C6-4741-A573-06ED803…  real         nein     1724        2
 3160 │ Polygon(215 Points)   {6F2104BF-ADA0-4119-B64E-698E1FC…  {14931621-AEB0-4416-A1F3-B15FE5E…  real         nein     3965        0
 3161 │ Polygon(408 Points)   {04A859DC-9B77-4518-A25A-8A4B5EF…  {310B69E6-6E2D-4064-9AF5-0B308E9…  real         nein     1420        0
 3162 │ Polygon(594 Points)   {AC016C84-2403-4FB0-83B5-11AAF3E…  {1DAF39C8-1D06-46A2-8786-E3C5C31…  real         nein     8585        9
 3163 │ Polygon(562 Points)   {2B8477ED-4CF1-47F8-B480-C2DB166…  {0F498A58-26E3-4D93-9722-0DCF1E0…  real         nein     5445        0
 3164 │ Polygon(487 Points)   {2D6EE207-AC41-42E9-9783-48944D9…  {B429ECC5-5359-45F5-9DD3-087D3D8…  real         nein     8624        0
 3165 │ Polygon(402 Points)   {F8ECF1C6-6089-40C6-A7DF-FE235A3…  {3A6E53BF-7BC9-4189-9ABD-0D45998…  real         nein     8500        4
 3166 │ Polygon(353 Points)   {5406FE44-6821-4A92-AFE7-46D4655…  {AFA0F640-93DE-4C99-8181-057EC2F…  real         nein     4333        0
 3167 │ Polygon(347 Points)   {34773AE5-1B2D-4006-BA65-D4C0657…  {126D7288-1D4D-49A7-A131-7E46B5B…  real         nein     5636        0
 3168 │ Polygon(598 Points)   {9BEE154A-AE21-466C-A179-72E1A1C…  {E1FBFF22-7A7E-4A4C-B0D5-CA37F7C…  real         nein     1184        0
 3169 │ Polygon(116 Points)   {01440EE3-81CC-4363-B0A9-C4A753C…  {F2C7BC80-143E-4A76-BC3D-E3393A1…  real         nein     3044        2
 3170 │ Polygon(336 Points)   {7185CC55-5F67-496E-B326-D7A9DB5…  {6F739C29-4712-49E9-A8AB-B7137A6…  real         nein     4704        2
 3171 │ Polygon(195 Points)   {D3E0A7C6-8DB0-4B0C-AD41-A90266B…  {0C0353DA-DE3C-471F-8506-D9FFA07…  real         nein     3656        2
 3172 │ Polygon(417 Points)   {DB1D1C89-2477-4CAA-8DC7-1C4A13E…  {23B590EB-E5F6-4A33-BE64-2365562…  real         nein     6877        0
 3173 │ Polygon(327 Points)   {64361378-9191-455F-9E6B-A4C5B29…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8037        0
 3174 │ Polygon(232 Points)   {700F8085-CE9F-4E71-A748-85C3783…  {E409BF85-48BB-4A88-848A-619E9B7…  real         nein     2884        0
 3175 │ Polygon(301 Points)   {5F9DE78C-8811-4976-9659-948D60D…  {876784CE-7ABB-4F7D-88CA-87B084E…  real         nein     3645        2
 3176 │ Polygon(430 Points)   {452A3D18-F3FB-4CC6-B3DB-24D1BE9…  {38115A3A-8153-4859-9F71-E1C519D…  real         nein     5619        2
 3177 │ Polygon(560 Points)   {89425671-DE08-4333-ADE8-CC8C06A…  {7C70DB85-B697-45E1-8153-A24FF5D…  real         nein     1884        3
 3178 │ Polygon(46 Points)    {C9A73D30-9BD5-49A3-B0F1-29CD8B2…  {E7D49BF1-7742-4F70-9E38-F528EC6…  real         nein     3960        3
 3179 │ Polygon(293 Points)   {88AD3CDD-DC97-40E9-9EF7-B1EE00A…  {34ED070E-589D-4DA7-8DC0-3704664…  real         nein     8956        0
 3180 │ Polygon(359 Points)   {CCA05079-4855-4AFE-BEBC-E52E4B8…  {2C82D931-2DB7-48E6-932F-7D37B9B…  real         nein     8123        0
 3181 │ Polygon(412 Points)   {9C431229-DF3E-4DED-A7F3-BAA01C7…  {01903B8A-4A5D-4DB2-8210-01C4CBC…  real         nein     8598        0
 3182 │ Polygon(56 Points)    {D8EDD007-A5AC-4F2B-AE97-3DCA6C8…  {FB734137-5EBA-4694-8A50-E080796…  real         nein     3945        1
 3183 │ Polygon(453 Points)   {75F29F9C-B5EB-479B-8589-AA3030A…  {FC8A24A4-769C-4A83-A3BC-88CC31A…  real         nein     6760        3
 3184 │ Polygon(216 Points)   {9F270AEA-76D9-42BA-A911-548B39A…  {C96D70A8-93A4-4891-A148-1B3153D…  real         nein     6938        1
 3185 │ Polygon(273 Points)   {BB6E4806-218B-44AB-B3B9-3D2F990…  {053A93B1-B9ED-4A14-BC86-44F4BA4…  real         nein     8247        0
 3186 │ Polygon(632 Points)   {C99CB25C-5AA6-41A7-91C8-8AACC2A…  {AE4AA707-69DF-43FB-9ACA-7CE13AA…  real         nein     9126        0
 3187 │ Polygon(275 Points)   {E76A2B79-86A1-40F8-925C-9259337…  {DE4FBB3B-F68B-4987-81EE-963D780…  real         nein     4655        2
 3188 │ Polygon(208 Points)   {4B1A40E2-BE20-4395-AA47-827C9A5…  {F7B2E3F8-0F07-4DBC-ABF9-52A1B3A…  real         nein     3046        0
 3189 │ Polygon(474 Points)   {54427B50-590A-486E-9DD5-92B86C8…  {AA7A849B-6912-4436-B89E-AB1353B…  real         nein     9535        0
 3190 │ Polygon(348 Points)   {62CDF1DB-23BB-4247-B5A1-684AA69…  {BE6235F4-A3F6-4B8F-B96E-4490B9D…  real         nein     8412        0
 3191 │ Polygon(398 Points)   {F67CC8D7-B0A9-420E-8A94-A9C7011…  {E0170143-1D61-4848-A423-E5A89C7…  real         nein     1782        2
 3192 │ Polygon(622 Points)   {967A5445-DC8B-4F23-A2FC-D2C6D3B…  {8ABBA193-0E14-4C1C-8C25-005F107…  real         nein     8345        0
 3193 │ Polygon(202 Points)   {2F8548CE-041F-49A4-BB97-502D081…  {FC20711D-C820-4AF9-8E0D-D86BF11…  real         nein     6875        0
 3194 │ Polygon(151 Points)   {1D82A427-8F28-4629-9E32-D95A872…  {40904D77-7B98-4681-B74D-ABE8420…  real         nein     1988        2
 3195 │ Polygon(807 Points)   {3A58AC9F-0BB1-4B30-BCD4-2D19695…  {6A37EAF3-B5A0-4FD6-BEB5-472553E…  real         nein     3303        2
 3196 │ Polygon(181 Points)   {5BDC2875-7CC3-46AA-97C6-0843C74…  {778923CF-396B-4203-A39B-AC04AC0…  real         nein     2505        0
 3197 │ Polygon(479 Points)   {B9BB615A-0403-4FE4-A90C-059595C…  {F07499A2-0384-49FE-BF1A-DC4D624…  real         nein     1428        2
 3198 │ Polygon(781 Points)   {34DEB910-A1ED-4148-9B79-4EE3F64…  {9D24086B-FB96-4302-94D6-6F994B2…  real         nein     1183        0
 3199 │ Polygon(398 Points)   {194893D1-109D-4AAF-ADB7-8058A74…  {7C2BBFB5-5F3E-4F22-B850-8486D3D…  real         nein     8737        0
 3200 │ Polygon(1159 Points)  {CF72395E-8F99-474E-B546-2C6E121…  {0F9A0A1D-95FA-46D2-B28B-6832799…  real         nein     1800        0
 3201 │ Polygon(423 Points)   {51E4241C-41A8-4E6C-B958-F0729D8…  {7F4A628C-4777-4E55-A68D-0FAD34B…  real         nein     4566        3
 3202 │ Polygon(334 Points)   {4239B730-1236-4879-969E-4D29826…  {46B607B1-015F-41B4-A4B3-D9E3C08…  real         nein     1675        0
 3203 │ Polygon(537 Points)   {E400A2D7-EC91-4BA7-825F-19CE43A…  {5FF26B03-A6DE-4A24-A7FA-BA06383…  real         nein     1408        0
 3204 │ Polygon(666 Points)   {21D4C2B4-0C2A-4A83-A346-546690D…  {0FE986DC-E5A9-44B5-91B9-F73E346…  real         nein     1224        0
 3205 │ Polygon(143 Points)   {431E2F1E-394C-4DA1-A627-4F0B530…  {79FD596A-5433-4251-B0A4-180F268…  real         nein     1585        0
 3206 │ Polygon(616 Points)   {3620CE27-A9C3-44F3-82A1-6D03DBE…  {7C8A5741-5EB0-4E18-960D-B831D8D…  real         nein     1262        0
 3207 │ Polygon(227 Points)   {F4F62086-94CA-4EE7-9532-0BC2C72…  {BA7111DD-1A29-45F1-93F2-6B5F03D…  real         nein     5627        0
 3208 │ Polygon(296 Points)   {FBA7C487-7C42-4E02-87BE-0CC840E…  {9BD08149-2B5F-4392-A9FD-669BBE2…  real         nein     6928        0
 3209 │ Polygon(77 Points)    {F6837226-30B9-4FC1-B6D9-00C4F19…  {85E515DF-36C0-40A7-B19F-BB8D02F…  real         nein     1652        2
 3210 │ Polygon(167 Points)   {F9E59568-E19E-47A4-9022-C0C1C58…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8004        0
 3211 │ Polygon(376 Points)   {BB865296-174B-4474-98D0-76D1130…  {74F4DAE7-6C28-4E4F-9098-8491EF2…  real         nein     8573        2
 3212 │ Polygon(297 Points)   {13EB77A5-1558-4E6C-BD58-D74E5E7…  {227E57CD-49B7-4364-B585-A22D167…  real         nein     6047        0
 3213 │ Polygon(191 Points)   {39B02F72-0617-40DE-A906-9A9F35A…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8002        0
 3214 │ Polygon(255 Points)   {88AB3153-B632-4DF5-AAD2-D1F6F5D…  {D55C58DC-B574-4DBF-85AE-36CDFB5…  real         nein     2562        0
 3215 │ Polygon(185 Points)   {A349C071-CE6E-4100-A6F1-72E42D6…  {C8211AC6-27E8-402E-B970-3C6A8D6…  real         nein     6695        0
 3216 │ Polygon(332 Points)   {FF9FA85A-202F-4841-B4B6-32E142F…  {1086EFEE-B860-4FA4-B457-08AC837…  real         nein     8505        2
 3217 │ Polygon(349 Points)   {2E6CE663-E4C6-44A8-AF70-8C91159…  {34206860-A6AA-4EBD-AA1D-47F7F0E…  real         nein     8158        0
 3218 │ Polygon(312 Points)   {7BA78EB2-D0ED-4F10-9C6B-576D155…  {F182452A-27D9-42A8-AF09-B03B12D…  real         nein     6356        0
 3219 │ Polygon(756 Points)   {53DAB9EE-720D-42B4-A2C8-6D04609…  {D6A34918-596D-464A-B56C-349F487…  real         nein     1141        0
 3220 │ Polygon(339 Points)   {78D61436-1DC6-46E7-8356-203DA36…  {FE4159BE-DEE4-4141-88E2-9C6D7DC…  real         nein     1624        2
 3221 │ Polygon(215 Points)   {3330368B-33EE-4921-BA31-B89EA21…  {A20638DA-7C53-45C2-A457-102E14A…  real         nein     4492        0
 3222 │ Polygon(675 Points)   {0B33467D-9F34-42C1-96D0-3ACB1DE…  {9A3B4AA2-CD57-48CF-9992-65CD412…  real         nein     1116        0
 3223 │ Polygon(752 Points)   {7CD21161-EE6A-432B-AB18-83A9F3D…  {E832C141-FE2A-49A9-B0F1-09812F9…  real         nein     8495        0
 3224 │ Polygon(888 Points)   {5BAE571E-D0A1-403B-BE01-96433FE…  {2445C7E2-AA08-47CF-AAD6-B992B10…  real         nein     1167        0
 3225 │ Polygon(483 Points)   {86427129-795B-4C36-A003-A1BE969…  {8E81D7E6-F006-4CBE-974B-4F548C7…  real         nein     8951        0
 3226 │ Polygon(425 Points)   {95D46596-B21E-40C5-AE36-0DE5C40…  {2B015048-227C-4D6E-B1BB-34F230F…  real         nein     3532        2
 3227 │ Polygon(171 Points)   {E30124B2-0243-472D-8018-BD8DE0C…  {DCB0ABB6-A6CD-482B-951B-A7C6C70…  real         nein     1541        3
 3228 │ Polygon(234 Points)   {F500F71A-2DC1-40E6-A100-F457EDB…  {8DDEB929-C641-45B9-A721-022C817…  real         nein     8306        0
 3229 │ Polygon(162 Points)   {9CAA3C7F-69A8-4D81-A3F8-8F1943E…  {3A1CCFBD-AB89-4B96-AFDA-E5D077C…  real         nein     3982        0
 3230 │ Polygon(263 Points)   {20D118E6-4BD0-4A64-8352-9B311C1…  {4C5A1714-E9F1-4050-98B8-9BCBF79…  real         nein     8461        0
 3231 │ Polygon(173 Points)   {FCEAC818-DAF9-4150-8ADE-CEA95D0…  {E693966B-2B81-4964-9F43-F90A723…  real         nein     5113        0
 3232 │ Polygon(289 Points)   {9EADC5C1-3C58-4F06-95E7-1E4D28E…  {E9376EF9-D755-47C7-B8CE-1D93FF7…  real         nein     9573        0
 3233 │ Polygon(171 Points)   {6CE819A2-8D4D-48AE-BA74-DA8F095…  {2C419A85-51D4-4566-B610-B374514…  real         nein     1996        1
 3234 │ Polygon(393 Points)   {E4376FBA-FC3A-4DD2-9863-1C47645…  {B12459F3-C2A5-4D7F-A48F-F0848CC…  real         nein     1721        1
 3235 │ Polygon(400 Points)   {F6203C54-B82A-4E73-9178-ED53B41…  {1DAC379B-53B3-4406-AB32-82181D0…  real         nein     3215        3
 3236 │ Polygon(500 Points)   {D79BE756-0207-4507-AC3F-3EA043E…  {7EE1386D-3561-4841-A865-9230C25…  real         nein     1674        0
 3237 │ Polygon(262 Points)   {506CA351-4468-4105-96AC-712D1DB…  {D0AD5449-BA33-4D91-8C1C-7D33255…  real         nein     8259        4
 3238 │ Polygon(664 Points)   {A2E6BB9F-95EB-45F5-97F7-C0E82B1…  {99D48BE9-42B1-40A1-B191-4DF6A3E…  real         nein     6862        0
 3239 │ Polygon(777 Points)   {23A437A8-565E-42E3-8932-0565BE0…  {42C2068B-EEDD-4804-84BB-049A71D…  real         nein     8310        0
 3240 │ Polygon(294 Points)   {1C876068-F02A-4E76-9E20-503910C…  {5D28B225-E2B9-44A3-924F-79BA2F4…  real         nein     1782        4
 3241 │ Polygon(302 Points)   {D23E4915-C6AB-4799-AD6B-3DB9873…  {36146110-F889-4206-A782-E875892…  real         nein     1633        2
 3242 │ Polygon(669 Points)   {EC9F5784-2379-4E3C-A0EC-9501418…  {C15CC1DF-705E-4230-9050-925C1F6…  real         nein     8599        0
 3243 │ Polygon(126 Points)   {7CEA4722-E390-4CF5-8C62-C846FED…  {386CBCF6-7E6A-4033-861B-C387CBA…  real         nein     1607        3
 3244 │ Polygon(145 Points)   {03310DE0-B7E7-4DF7-8345-B920003…  {804D5264-323C-4EB2-9593-43DECDC…  real         nein     2532        0
 3245 │ Polygon(466 Points)   {D57FFF96-E1E1-4686-9A0A-3835543…  {C1DA723F-D02D-453E-BEC7-0FFD3A6…  real         nein     3613        0
 3246 │ Polygon(304 Points)   {F361F28B-AC8D-4759-AC3E-F9F6351…  {C615787C-3E7F-4753-A8FC-BF25C6A…  real         nein     1670        3
 3247 │ Polygon(221 Points)   {AD7D49C9-FCD8-4EC0-B534-9A6C950…  {031611FC-8C24-4219-8547-D0F1F44…  real         nein     3274        3
 3248 │ Polygon(978 Points)   {F74C9BF9-639A-433B-B648-5C43439…  {EEBC2D3D-B15C-4A19-8B0B-E7188EE…  real         nein     1441        0
 3249 │ Polygon(506 Points)   {15F3C2AE-1C99-402A-A118-9EDD1E8…  {EC608DF6-082C-4694-84CE-08AAB00…  real         nein     8640        3
 3250 │ Polygon(480 Points)   {8C8DB762-6DBC-483D-B817-ADE0E6B…  {DBFCB9D1-D248-40DD-8FCE-2D5A53A…  real         nein     6834        0
 3251 │ Polygon(173 Points)   {21A14522-3CB2-470B-B6BE-044E952…  {1347A33B-F312-471E-A126-A63C2D7…  real         nein     2718        2
 3252 │ Polygon(92 Points)    {CCA61197-829E-4E11-9F43-7B084C4…  {EC738895-0CDC-4F85-91AF-29472FE…  real         nein     4461        0
 3253 │ Polygon(377 Points)   {EF366B0E-812E-4342-96C4-CE0497E…  {AC1848E2-D656-4ADE-939B-6BA65D7…  real         nein     6932        0
 3254 │ Polygon(357 Points)   {10C2EB84-81E2-4737-A84A-E5DFE6B…  {5FDEBC2A-D0FA-4425-8340-2606AF1…  real         nein     4523        0
 3255 │ Polygon(270 Points)   {A1226EA4-65DB-48AB-9C54-77BB226…  {8E3C1547-AAF8-420A-820E-000AD75…  real         nein     1670        0
 3256 │ Polygon(651 Points)   {CE7E39A5-6516-4C17-B273-54C2CD1…  {6D634730-756F-42F2-B185-D3F8EC6…  real         nein     6963        0
 3257 │ Polygon(558 Points)   {32AFB9D7-D3B2-4361-901E-EDE1EB2…  {AD46B9F7-0C23-4084-8ED0-2CDF4BD…  real         nein     8566        4
 3258 │ Polygon(143 Points)   {7F3E9353-B169-445E-B82A-569CFCF…  {C422A6A9-786D-4FAE-9D4F-A7CDBE3…  real         nein     2616        2
 3259 │ Polygon(94 Points)    {96B4A129-C0E6-4A5C-9E9E-F163581…  {32884D64-9597-44B0-B36F-8A3E868…  real         nein     3986        0
 3260 │ Polygon(507 Points)   {90125CD6-2B7C-405D-B91D-38AF46E…  {4DC9CC99-5A27-47F9-B15D-9086506…  real         nein     1681        0
 3261 │ Polygon(394 Points)   {8DE6E298-70AA-429A-BFCA-1983DBA…  {E9395B6D-BA26-4C9B-97D4-E0504FB…  real         nein     1524        0
 3262 │ Polygon(343 Points)   {18D306FE-76CB-4FD7-B9DA-8F4D6E0…  {E10513B1-0951-4500-B8DD-22C6FD2…  real         nein     3937        0
 3263 │ Polygon(183 Points)   {938DEF25-0CF3-495F-A8DE-6A9541A…  {E98AFCB2-DEBB-4E97-80A0-596FEC6…  real         nein     1410        2
 3264 │ Polygon(266 Points)   {204AFA4D-644D-418E-9219-010C08A…  {041BE5AA-B62F-474F-9E54-2C19B45…  real         nein     4577        0
 3265 │ Polygon(605 Points)   {7C91E1E5-984A-4D43-BDDF-1751D3E…  {072061EC-A884-4CCF-8D61-EA828E6…  real         nein     1421        0
 3266 │ Polygon(571 Points)   {7D27620B-F509-408D-BBC6-AFBBCF1…  {D723580B-FB43-4D0A-B644-AED9F3C…  real         nein     1080        0
 3267 │ Polygon(131 Points)   {66771E3C-9E35-4C9D-B455-6FF557F…  {8BC5C062-3F48-4532-9269-BC51B01…  real         nein     6343        3
 3268 │ Polygon(241 Points)   {952F4383-24AE-4294-9F17-8A3ED21…  {4E5A10E9-9433-47A7-A647-5F359C5…  real         nein     1528        2
 3269 │ Polygon(139 Points)   {31538CEB-BD1D-4E13-9F01-2BF456E…  {907DF60F-2D9B-4A10-BF07-AB201CF…  real         nein     3078        0
 3270 │ Polygon(505 Points)   {EACC2A20-C4B6-4EA7-9B01-E775056…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1004        0
 3271 │ Polygon(91 Points)    {E4A4B896-C621-4ED2-977B-685E8D0…  {7F0B18B3-DCAA-47FB-A30E-99B7B32…  real         nein     7244        0
 3272 │ Polygon(273 Points)   {D260735F-63F2-4F90-9895-97F7498…  {37FFBE0D-E073-449D-BA69-9112E95…  real         nein     4433        0
 3273 │ Polygon(60 Points)    {6E1928B1-1420-41A3-9EA9-C58B7CB…  {A6F506D1-9C61-4322-8084-09712FA…  real         nein     4441        0
 3274 │ Polygon(265 Points)   {DB36555E-1F80-4319-B6AA-CB6DC7A…  {8B0265DE-CCAB-4C1D-9A36-FC398CB…  real         nein     2572        2
 3275 │ Polygon(282 Points)   {24828305-B7A8-4DD7-95D1-C4E98D6…  {F825FDC7-712E-4D0F-A2ED-5614E1C…  real         nein     5245        0
 3276 │ Polygon(150 Points)   {B3FD626F-7660-427C-B8ED-0B80251…  {78AF774E-3377-418F-9ABC-B585242…  real         nein     4126        0
 3277 │ Polygon(255 Points)   {C6B30CE3-7B60-4F32-A1FE-C7B3C22…  {AE629820-1D7F-43F5-886E-7CA0AD7…  real         nein     1772        1
 3278 │ Polygon(434 Points)   {640F2EC9-713D-41FC-9167-9128AD7…  {F035FD7F-B43F-4334-85E5-A09FF95…  real         nein     1277        0
 3279 │ Polygon(292 Points)   {A512AB95-E7B6-47D2-B6D3-2968D33…  {B3E29E71-9392-4C24-896A-910D23B…  real         nein     5056        0
 3280 │ Polygon(359 Points)   {590B3731-46A0-4434-83FE-5126DBF…  {BA14DAC9-E5AF-4F4D-A926-E3B455A…  real         nein     1699        2
 3281 │ Polygon(779 Points)   {2F37FD41-6F1F-42FD-956E-C63D609…  {D24C20C6-A261-409C-A150-746B4AB…  real         nein     1008        0
 3282 │ Polygon(474 Points)   {522501E3-28F5-4A8A-AF0E-1B41C54…  {1C027FC7-A500-43AE-9D8D-EA2DB81…  real         nein     1624        3
 3283 │ Polygon(155 Points)   {47EE4875-0662-4FD6-951B-B61EB2D…  {D6692063-B23C-4728-AA76-81A0AC9…  real         nein     2563        0
 3284 │ Polygon(359 Points)   {044C0F72-C5E6-4D73-BBB6-58E886F…  {3ED2A789-E525-482B-B562-B0DCC15…  real         nein     2063        3
 3285 │ Polygon(314 Points)   {591DCEDB-428F-4FDB-9729-F64CE1F…  {CE177342-720A-4813-893C-F8A279C…  real         nein     1674        2
 3286 │ Polygon(243 Points)   {3E139028-F947-4B0C-925A-D0740B2…  {D0D20A79-4DA0-4453-9D83-CA58DD7…  real         nein     7145        0
 3287 │ Polygon(473 Points)   {17D5FD3B-5DFA-4CA3-A340-E24C7BD…  {B7447F84-AED8-4421-96BE-846E787…  real         nein     8471        3
 3288 │ Polygon(590 Points)   {ED4FCB44-35A3-4DDC-9659-87AB884…  {D03C19C8-58F1-4B02-919D-2191F58…  real         nein     3671        0
 3289 │ Polygon(378 Points)   {A7E1B4FF-B74D-450E-BA2D-C39D37B…  {DEAF80C6-4F8E-40EF-858B-4911DA7…  real         nein     6966        0
 3290 │ Polygon(396 Points)   {E27BFD98-5609-4BF1-9F3B-A802E2F…  {94F8EB2D-06EC-4CC7-81D6-5B63589…  real         nein     9231        0
 3291 │ Polygon(389 Points)   {4FD3D318-6525-412D-A5C5-E7D931B…  {E64C1632-9569-4B14-AD6D-8BC9E16…  real         nein     6982        0
 3292 │ Polygon(208 Points)   {62B59010-8169-4B17-B2BA-18706B4…  {44211B02-9694-4EF0-8EF6-15A8640…  real         nein     3254        2
 3293 │ Polygon(438 Points)   {7AA2CEAF-75DB-4C12-9F44-D498CB6…  {6945A991-ABB7-4BDA-BFA7-F2D41E3…  real         nein     1172        0
 3294 │ Polygon(262 Points)   {B50698B8-E89C-46EF-9967-B590B24…  {2BE1C248-3546-4523-BD02-BF69DE5…  real         nein     1847        0
 3295 │ Polygon(477 Points)   {6F4534C4-3DC9-4DC6-8C6D-C0B3F46…  {A9FD2356-CC32-4E4F-8206-26A29A7…  real         nein     1805        0
 3296 │ Polygon(964 Points)   {D76A78B4-BBC4-455A-A9C3-BA38E5C…  {852A1693-AEFA-4505-B0F2-1A3B611…  real         nein     1068        0
 3297 │ Polygon(246 Points)   {690603BB-6066-4A7D-ADF5-72F15DC…  {96972662-D73C-49F2-AD1E-ABC6D58…  real         nein     3975        0
 3298 │ Polygon(242 Points)   {ECCC32D4-3223-4979-B29D-9513B2D…  {F5FBFBA3-5A46-41D4-B56E-38EF039…  real         nein     3256        2
 3299 │ Polygon(121 Points)   {581B9700-574C-4369-889D-C27D2BC…  {6ECA2E1C-8FEF-4ECC-BA5A-47C571C…  real         nein     7222        0
 3300 │ Polygon(213 Points)   {C687529D-7EE3-4BF4-90E5-8295953…  {7CF50E14-D390-46D0-A02D-2DF6961…  real         nein     5624        2
 3301 │ Polygon(254 Points)   {1D0ED223-604D-417E-878C-0D96379…  {5197561F-AA33-4D90-B5C2-DE74E96…  real         nein     3305        2
 3302 │ Polygon(231 Points)   {705B68D8-E87B-4CB1-8907-895A691…  {F7EB8BD8-0D0D-4777-9C1F-2E1E627…  real         nein     3116        2
 3303 │ Polygon(811 Points)   {858FAD4E-0575-4E45-8035-17C853A…  {035D8674-EF45-4FE8-8343-D870F5F…  real         nein     1212        0
 3304 │ Polygon(275 Points)   {946C0D1C-A148-4152-B048-B539131…  {905D9D8C-B3C8-41E6-87ED-ED303FE…  real         nein     8471        4
 3305 │ Polygon(306 Points)   {243C1A33-3EE3-4BFC-9199-C8C171B…  {ECF6DDE7-508C-41F1-BE59-352ECF7…  real         nein     8415        1
 3306 │ Polygon(350 Points)   {D56F947C-90BE-484E-8107-6F8DBD3…  {D32C79F1-020E-4C5E-8281-C9C8262…  real         nein     1076        0
 3307 │ Polygon(231 Points)   {4535D16F-24AF-4C87-8B40-6BFBA14…  {C90136DA-1340-4548-97CA-0FF92D8…  real         nein     3425        2
 3308 │ Polygon(488 Points)   {16DCF288-5199-476B-A9F5-6E124E7…  {8A73D675-644D-4DDB-81CC-17ED878…  real         nein     2514        0
 3309 │ Polygon(262 Points)   {91C12A73-6FA6-4625-80C5-598FBE2…  {E5DD4946-EE1C-4CEA-A8EC-C4F2971…  real         nein     9543        0
 3310 │ Polygon(275 Points)   {FDAEB409-7B23-479F-8A5B-0E48DB9…  {7AD67497-6E03-48FA-A173-965F145…  real         nein     6333        0
 3311 │ Polygon(266 Points)   {1374BCFC-6AD5-42E5-A85C-6EC2B57…  {B729FFC2-591C-4EB6-9F2A-EAE6A84…  real         nein     3053        2
 3312 │ Polygon(244 Points)   {DD907655-419F-48EC-8391-CD1E7BC…  {8AB2B47E-28A6-4054-AAFD-02EDCEF…  real         nein     2558        0
 3313 │ Polygon(65 Points)    {9CDC0BF0-5D5F-4837-A562-5C81E95…  {522AEDA0-A97F-4D91-BF05-4D6DB64…  real         nein     1945        5
 3314 │ Polygon(1470 Points)  {91D14546-755F-47E2-80EC-D4BAC65…  {7D4FCE18-7081-49B9-B0E0-078F49D…  real         nein     6132        0
 3315 │ Polygon(150 Points)   {0B7FC150-4F93-4F72-A7E3-2A9A440…  {26E260DE-B5C5-42C1-9495-6A40332…  real         nein     1652        0
 3316 │ Polygon(533 Points)   {771ABABF-9D54-4568-BD59-A2E8437…  {22BCD407-E7CB-4583-AA5F-09DD9B5…  real         nein     8102        0
 3317 │ Polygon(76 Points)    {CA0D3962-2428-4F76-8778-6536800…  {E3C75836-3756-439F-88A1-22605CD…  real         nein     9423        0
 3318 │ Polygon(311 Points)   {CEC96612-E682-49D9-8328-15D72EB…  {2041FD19-0479-4D89-8580-4904CA9…  real         nein     1721        4
 3319 │ Polygon(57 Points)    {346E6F2B-3978-4E23-B066-810D1BA…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8005        0
 3320 │ Polygon(168 Points)   {563E81BD-B653-412F-BF95-475E8F5…  {3E4836D9-4866-4F8F-BCC2-603B167…  real         nein     2068        0
 3321 │ Polygon(97 Points)    {643970D4-0FBA-48A7-8F04-7DB4C86…  {98A651A0-97D2-4B28-A9CD-B3189A7…  real         nein     8576        0
 3322 │ Polygon(549 Points)   {82F8C8BF-CFA6-4F12-9266-ECC5D6E…  {9ACF65AE-4052-4F39-9F7D-83F81EE…  real         nein     1450        3
 3323 │ Polygon(526 Points)   {92D8A706-F76D-43B9-A592-F550F90…  {343667E2-1A55-4BBA-8FA4-BE87512…  real         nein     8556        3
 3324 │ Polygon(414 Points)   {A60BCE89-8642-42CE-8CC0-E41EEF2…  {FF327E44-240E-47A2-A054-818DA29…  real         nein     8637        0
 3325 │ Polygon(459 Points)   {4CCE0F20-137B-4905-83AA-CE238FE…  {C4816A0C-765A-4D89-B6EF-AC52D18…  real         nein     1376        2
 3326 │ Polygon(195 Points)   {B7C5AC5E-0821-49C4-B9B6-75134E3…  {ECE48B68-9DDA-4005-AA5C-3D2A728…  real         nein     9562        2
 3327 │ Polygon(255 Points)   {C1995BDF-B011-4F43-943F-6AF8386…  {6EADB66B-1D38-4554-9182-399CF36…  real         nein     3424        2
 3328 │ Polygon(870 Points)   {BF923302-B25D-4500-AD65-B551EE5…  {E26EE654-4E8B-4274-802E-261FFF6…  real         nein     1134        0
 3329 │ Polygon(63 Points)    {26A7120B-1610-4D97-9DD3-E30D009…  {3CDFF797-A88E-44C6-93CF-BE95B3B…  real         nein     8584        1
 3330 │ Polygon(221 Points)   {D352F71C-0F38-4EB6-9042-E1F1FD6…  {76B63699-D60F-433F-8FF7-AF0BE8F…  real         nein     1290        2
 3331 │ Polygon(362 Points)   {3CAC4261-0FA7-48F5-B6A7-797B56F…  {9A580E9B-40F6-4CC8-8C49-B8EB43B…  real         nein     9504        0
 3332 │ Polygon(392 Points)   {23C59942-843A-4ECC-BF53-A99AC1D…  {674319C5-453D-4350-8692-F8409B7…  real         nein     7137        0
 3333 │ Polygon(288 Points)   {B303BFFA-09FD-4350-B9F4-6EFE278…  {DDECB036-9C04-4733-82BB-7AA098D…  real         nein     4581        0
 3334 │ Polygon(374 Points)   {CAED141E-2623-40D0-8558-9AB964B…  {B076AF47-A70B-4EB1-8C6E-9A747F4…  real         nein     1609        2
 3335 │ Polygon(67 Points)    {02498A4E-741B-4B7E-9709-DB235C3…  {8C52C48D-1EC7-4CDF-97D2-3F5B058…  projektiert  nein     7484        0
 3336 │ Polygon(204 Points)   {428D48F0-D5B8-4B29-B593-C73D725…  {3E53FCC8-636B-4C37-A4BE-FF2C7C5…  real         nein     4556        2
 3337 │ Polygon(268 Points)   {0CE03B69-29B5-488C-99AB-D62CBB9…  {2842C415-D9A7-4AC2-B4CE-0AE096B…  real         nein     6038        0
 3338 │ Polygon(184 Points)   {CEB118D6-D831-4446-A24D-419CFC5…  {459E7B9A-0686-44E5-8C0D-859AC43…  real         nein     3422        1
 3339 │ Polygon(177 Points)   {D74DA985-0B98-424F-8E79-21C1D87…  {33113F40-E14B-4892-BD2D-DD8F2D0…  real         nein     1610        1
 3340 │ Polygon(122 Points)   {A9643304-C52E-4BD2-A185-094DB4E…  {051B8EF2-948A-4554-AD41-8AF2ECC…  real         nein     2556        0
 3341 │ Polygon(350 Points)   {1E518232-44B9-4B62-B2A3-5160E17…  {7529CED2-70FB-4943-8B66-8E2E356…  real         nein     3251        2
 3342 │ Polygon(567 Points)   {4C0C443E-12E2-4668-A6D5-8609FCF…  {C63B851F-D7E5-4BF9-AA22-AE5D749…  real         nein     1464        2
 3343 │ Polygon(423 Points)   {2C56A471-13F7-48A3-8432-5E9B268…  {0086CEA0-41D8-44A0-9936-9290835…  real         nein     2028        0
 3344 │ Polygon(263 Points)   {766220C3-921B-4B0D-812F-8B780BA…  {1A3E676F-23F1-474D-87AC-241F8E3…  real         nein     1653        3
 3345 │ Polygon(428 Points)   {FF86D8A2-D36F-424E-B6F9-47D57AA…  {B39D3DEB-0E62-45D9-B1EC-C7467D4…  real         nein     6646        0
 3346 │ Polygon(314 Points)   {5753E63A-9C3F-4DD8-B89C-69A5CB0…  {2AA3B708-8E92-4666-B009-310C3D9…  real         nein     5705        0
 3347 │ Polygon(208 Points)   {1E97FC7C-ACCD-4D95-B028-27F61E9…  {83838EE7-3BDF-4288-AF26-7D796E4…  real         nein     2732        2
 3348 │ Polygon(384 Points)   {1C18EE8D-62E6-406D-9BE9-DC4AC05…  {FDBF56CF-B910-4F7A-9D85-87D5425…  real         nein     1041       22
 3349 │ Polygon(313 Points)   {50DFA548-406D-47D4-AFEB-823F68E…  {835EC937-615F-46D7-8CDF-51E081E…  real         nein     5408        0
 3350 │ Polygon(227 Points)   {504C729A-D9AE-45CB-9CD8-023DC19…  {34064C95-6E1A-4CDF-9EE1-5FF21CB…  real         nein     8236        2
 3351 │ Polygon(517 Points)   {092450E0-2079-4118-A9C4-43FFF35…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1012        0
 3352 │ Polygon(621 Points)   {41C28347-344E-4E7F-B201-4FA97E6…  {8B24EEE0-1AFB-4B1E-A2B9-938A8B9…  real         nein     1126        0
 3353 │ Polygon(111 Points)   {2F7398F8-8B7A-4F12-BA99-94822BE…  {C60EB695-0666-44FC-AE3E-1930F79…  real         nein     3963        3
 3354 │ Polygon(296 Points)   {4FD8C277-C657-4009-8A00-2CDBC3D…  {00F4AA5D-9D86-4934-A9DD-575D06A…  real         nein     8614        0
 3355 │ Polygon(237 Points)   {F2B0D560-1AF5-4B6C-85FC-626505F…  {0367F644-2B41-4E81-B9BE-60590EF…  real         nein     9477        0
 3356 │ Polygon(415 Points)   {A5C8F279-0BFB-4230-B3BE-0984693…  {6A1ABE5D-0D8A-455F-8E34-3492C24…  real         nein     1164        0
 3357 │ Polygon(350 Points)   {8B62D47C-A728-408C-B165-0ACEA55…  {4F55CC88-E89A-4871-8EC0-64B74C0…  real         nein     3126        0
 3358 │ Polygon(576 Points)   {7057999B-73CB-4380-8146-698942C…  {7FC22357-ECC2-4048-B5D0-A948717…  real         nein     3623        2
 3359 │ Polygon(352 Points)   {F9145133-AB10-48CB-81BD-6A57710…  {E4775515-A537-4B4A-9857-327A9D6…  real         nein     6986        3
 3360 │ Polygon(302 Points)   {EABEE7C7-1625-41F0-82A0-290918B…  {5D3C0D0A-69F7-49DA-9AFB-3CD8B43…  real         nein     1174        2
 3361 │ Polygon(64 Points)    {C6A44221-A397-46EF-A7AB-38E74BE…  {9DB4FC13-B16E-4CAD-BFC6-E2BF2F4…  real         nein     7155        0
 3362 │ Polygon(480 Points)   {A052AC17-C5FB-4C8F-B5F2-CD66B6E…  {77B0FF85-1168-481C-8E7C-C8A95B9…  real         nein     6945        0
 3363 │ Polygon(202 Points)   {7D4D6653-E55E-4E74-9E7B-F5D595F…  {617DCC74-AD47-4BE3-94FA-4E51A34…  real         nein     9214        2
 3364 │ Polygon(452 Points)   {84805009-F6B2-435D-9196-94E6BCA…  {9AC8AF77-84C2-429E-9385-BC4B806…  real         nein     8546        0
 3365 │ Polygon(351 Points)   {7AE02B71-851D-4E0C-BC99-133E507…  {23FB9F74-4AE0-4F17-99EC-4EADD6B…  real         nein     6949        0
 3366 │ Polygon(335 Points)   {F5CFDF51-CCD4-4E05-B2F4-A086400…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4059        0
 3367 │ Polygon(267 Points)   {AC11E83B-3F55-42E2-8A1F-1119D99…  {E963DC45-B8DD-4249-8B35-725CF4C…  real         nein     1626        3
 3368 │ Polygon(448 Points)   {9C1F1156-BF40-40A1-9279-B69D27D…  {C691E717-310F-4D8B-BB33-AFE1888…  real         nein     1431        2
 3369 │ Polygon(157 Points)   {5012EC86-2D63-45F8-A527-27C603A…  {9FF6B2A2-5DC8-4555-A15A-D5C3D77…  real         nein     4446        0
 3370 │ Polygon(276 Points)   {4FDC9123-15CC-42D4-8027-D63E333…  {C73BEB75-F277-4A1A-B708-B59F187…  real         nein     4436        2
 3371 │ Polygon(343 Points)   {54A45D65-97A3-45A1-8DB2-FA3E6E5…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1203        0
 3372 │ Polygon(207 Points)   {955A9B78-1EE0-488F-A3E7-1B8D481…  {43BAF68B-81AD-45CB-9387-4D89D7C…  real         nein     3314        0
 3373 │ Polygon(275 Points)   {723BDEBE-F259-43AF-A32B-22770A2…  {0291BE91-BC6A-4162-B5BC-9976EDA…  real         nein     4583        2
 3374 │ Polygon(636 Points)   {ABF144FE-E230-444E-873F-7BA524E…  {9F925705-E639-4874-987A-B03916F…  real         nein     6648        0
 3375 │ Polygon(463 Points)   {B1592C22-5B6A-4F13-A460-5BE2CB9…  {B8854031-BC68-4E52-AD48-1E0B926…  real         nein     9327        0
 3376 │ Polygon(160 Points)   {6928DF94-2933-4D79-A2A0-0A1B1A7…  {2D14B52B-C8AF-45F4-B9FF-FFF42C6…  real         nein     2830        2
 3377 │ Polygon(432 Points)   {F75B23F9-F51D-4B8D-9FC2-7E80FA0…  {87590C7A-E4C1-45C8-84C3-D936548…  real         nein     3373        0
 3378 │ Polygon(596 Points)   {673EF975-81E2-41A9-9D44-D2BCC14…  {9DF0EABE-9B80-4934-A6A5-3F285CD…  real         nein     1432        2
 3379 │ Polygon(273 Points)   {B56F65B1-1B06-4027-86E0-EE9727F…  {0A804E51-E683-4985-8B9A-92ECD37…  real         nein     1473        0
 3380 │ Polygon(170 Points)   {6DB25DCA-F31C-48F3-BD89-71315E9…  {A3591B07-AA7E-46DC-B1B1-5574653…  real         nein     3426        0
 3381 │ Polygon(190 Points)   {D36625E9-2350-4C40-B3D4-8E549FC…  {7856421F-B723-41E1-9A76-2CD2924…  real         nein     8573        3
 3382 │ Polygon(86 Points)    {D688A64C-8A05-4FF8-930B-BDE4611…  {5C5F00A4-04B3-4D98-88B8-DAD9BE2…  real         nein     8553        5
 3383 │ Polygon(225 Points)   {4992E040-6559-4D67-AE10-8D3F902…  {C0A8DF6A-7431-40D7-8B0B-5D23EA4…  real         nein     8586        7
 3384 │ Polygon(165 Points)   {4B664968-23C8-4A97-AADC-03E13C4…  {92581984-D2A8-499F-A760-70582B6…  real         nein     8586        8
 3385 │ Polygon(504 Points)   {6C2A58CD-B6A5-443E-A805-FAAEB1A…  {7531EE98-4F0A-45F6-831F-4845DB1…  real         nein     1263        0
 3386 │ Polygon(39 Points)    {CA09E72C-3DFD-45AA-ADFE-E9B57D6…  {010A1B39-A63F-4336-9C25-84942BE…  real         nein     1969        0
 3387 │ Polygon(277 Points)   {5ACF86E4-8A90-43BE-B575-5007A69…  {B36E4D39-F0B3-40C1-B754-68871D5…  real         nein     3415        3
 3388 │ Polygon(203 Points)   {105F1638-9657-4419-AABA-634D5E6…  {EE9E2963-C7D2-47B5-9005-8B214AC…  real         nein     1423        0
 3389 │ Polygon(240 Points)   {CC4438D6-154C-4554-A5E0-8F29CAA…  {929F1905-EAB9-42BB-A038-A128922…  real         nein     8556        2
 3390 │ Polygon(557 Points)   {FB6DA618-714C-4C21-8FC8-9DEE259…  {0E232591-3FF0-4F63-89EB-2A08101…  real         nein     1608        4
 3391 │ Polygon(325 Points)   {229EBED7-36DB-4F0F-9879-4974A2B…  {616EB271-03D0-4384-97A2-EED4BAA…  real         nein     7430        2
 3392 │ Polygon(552 Points)   {C4FE0C30-CF1A-401F-BFFD-0B5C8DA…  {0836A74A-8580-4723-A459-F4820FE…  real         nein     6853        0
 3393 │ Polygon(287 Points)   {F89645B5-B2F9-4917-919E-8C9E1C8…  {8E1F9A26-478F-44E5-95DD-10453E7…  real         nein     4919        0
 3394 │ Polygon(206 Points)   {AE689D5E-9B4B-465C-90E1-6EEB67A…  {C820BE7D-6AFA-422C-804A-FC3BF64…  real         nein     1231        0
 3395 │ Polygon(305 Points)   {4DAB9E75-B679-4743-A296-D75E62D…  {4140D54E-4CD8-4D2F-B436-35EF186…  real         nein     5300        0
 3396 │ Polygon(248 Points)   {10A2A6E2-1E1E-40C8-9601-517DB76…  {D7DBD841-F999-4164-8445-4DADF3E…  real         nein     9215        0
 3397 │ Polygon(545 Points)   {8E7F4DE4-F558-47E1-8DA6-7A6D0A7…  {136FC897-9B8B-4E6B-AB0F-C6F95AA…  real         nein     9435        0
 3398 │ Polygon(287 Points)   {FF856C13-1ECB-451E-B512-72C5FAF…  {99CE084B-B008-42CC-A669-0E9C932…  real         nein     3175        0
 3399 │ Polygon(604 Points)   {42374733-47D9-4680-93E5-A21504D…  {2295F5D1-65C1-4BE5-A8FD-810F052…  real         nein     1673        2
 3400 │ Polygon(104 Points)   {A6D691D7-C627-40C9-864A-BC40E78…  {CE01BE6C-11E4-482D-9A64-00F1544…  real         nein     1966        5
 3401 │ Polygon(250 Points)   {DDD88124-DE23-42F7-9B40-AFEF778…  {8FB8FD43-8249-4530-86A6-5A11536…  real         nein     1934        0
 3402 │ Polygon(256 Points)   {40E927AD-BA40-4A16-B402-DAF9DBB…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9008        0
 3403 │ Polygon(105 Points)   {6B5B819A-560E-47BA-A6D9-B99AE7B…  {FDF1EEF7-6BA9-4DB8-9FEE-C8FFFE1…  real         nein     3991        0
 3404 │ Polygon(157 Points)   {7F3AFFB2-FD3A-4367-ADB2-22452BC…  {8573B004-2277-459D-9A47-443AEEE…  real         nein     1608        3
 3405 │ Polygon(321 Points)   {AB663902-9F76-4D67-90A6-1F85422…  {5F663512-80BF-46BF-BF40-3E5F2FE…  real         nein     8553        2
 3406 │ Polygon(205 Points)   {79B453FF-3B1B-4C70-9BF2-C210B03…  {68FA3458-C7EC-4A7E-A4FA-2D395A9…  real         nein     6598        0
 3407 │ Polygon(339 Points)   {60E820DA-71B3-4A3C-B324-3082DA9…  {EBBDFAA9-77DC-40ED-BBEC-D3B9FF8…  real         nein     3366        0
 3408 │ Polygon(134 Points)   {ED5FBB22-AA42-42FE-9D2F-EB5F199…  {6B06F590-F64D-4E88-B755-0218A8D…  real         nein     1475        3
 3409 │ Polygon(386 Points)   {E9966494-CCE0-48EB-83B0-C523821…  {9EBA9255-9396-4086-88DA-FB14F4A…  real         nein     1617        2
 3410 │ Polygon(659 Points)   {290D28F4-6024-410A-9BE6-6E7E26C…  {2E91DB08-2C42-4F1C-BDDC-DF75223…  real         nein     6004        0
 3411 │ Polygon(232 Points)   {4F251D5E-88B0-41B7-B968-5AA8133…  {3257D395-F052-4AAA-988C-DA100D3…  real         nein     1726        4
 3412 │ Polygon(213 Points)   {04B65690-8C67-4AC4-BDB4-38D874B…  {2F3D2729-201E-428E-9212-09E1C51…  real         nein     1782        3
 3413 │ Polygon(239 Points)   {4EF3A713-D5D4-4354-87C6-6371DB2…  {5DC4DB6B-F71F-4E2E-8778-13F8826…  real         nein     3366        2
 3414 │ Polygon(239 Points)   {CC40118E-FAA8-4007-B4FD-A558E17…  {B1993780-E136-4141-AF69-25C8A1E…  real         nein     6085        0
 3415 │ Polygon(1146 Points)  {65708BA1-031E-499A-BC7E-5DBAC92…  {19B66108-868D-4EB0-BE4F-61DF417…  real         nein     1046        0
 3416 │ Polygon(331 Points)   {A59A1EB4-933E-4308-8173-2008DAD…  {B8AFDDAB-A045-4AE0-BD3C-9A31712…  real         nein     8544        0
 3417 │ Polygon(578 Points)   {3C6DCF90-6659-4AEF-AA0A-9244815…  {EF89A8CB-DD7B-4CBE-A345-956905F…  real         nein     1815        0
 3418 │ Polygon(591 Points)   {6B209379-B27A-4A95-B343-BAFCB35…  {95ECAEE8-2E2B-422D-8CFC-84B4972…  real         nein     4563        0
 3419 │ Polygon(208 Points)   {E42D1F65-17CB-4A04-A52C-31629A1…  {92253C9D-8E43-4DDF-B955-D1642E9…  real         nein     1754        2
 3420 │ Polygon(134 Points)   {1C94BE90-7DD9-475A-8329-DA1F9C6…  {B490BAF8-F135-47D1-83E8-132ED32…  real         nein     7463        0
 3421 │ Polygon(141 Points)   {AB1496F9-55C1-47E6-BCC6-6929DDE…  {E5054693-37C2-46C9-8111-B7BB347…  real         nein     4584        2
 3422 │ Polygon(257 Points)   {403899A4-146D-4FA2-B26B-735F1C7…  {2F4D18D6-5345-4DE0-9D12-E70A872…  real         nein     3860        4
 3423 │ Polygon(864 Points)   {05D3CBA6-B3E0-4ABB-BFCB-963F7E8…  {F73D0857-08DB-4434-817C-DE5FF4D…  real         nein     8484        3
 3424 │ Polygon(215 Points)   {6BD6A7EB-04BF-4C1F-B464-E3478F9…  {4EC28EF9-3F7F-4843-84D0-0C1ECF0…  real         nein     1695        4
 3425 │ Polygon(187 Points)   {164A77C3-3702-4834-9223-E8A7C97…  {2C1B8426-E974-4AA5-8D9A-059AB26…  real         nein     2575        2
 3426 │ Polygon(364 Points)   {393C8E73-240E-429B-A124-B0DFBBB…  {7BA7DE9D-63AB-445F-95A8-ED988FC…  real         nein     1008        2
 3427 │ Polygon(323 Points)   {38450621-624F-4621-9AFA-24CD5CF…  {E51D8BD3-ACC6-4EF0-BDCC-2AACA82…  real         nein     8725        2
 3428 │ Polygon(150 Points)   {E6C03BC2-F64D-4B32-AD44-E93F710…  {6BDB738B-6AE3-4EAF-8170-735D096…  real         nein     1274        1
 3429 │ Polygon(153 Points)   {7DC9071E-2AE6-486C-B3AB-E4840C6…  {4638A2CF-E809-4283-A7E8-752592F…  real         nein     4579        0
 3430 │ Polygon(421 Points)   {9B7E890D-B066-4374-A78D-8E0204F…  {52B942E6-6A95-43EC-8F4C-6EFA26E…  real         nein     1673        3
 3431 │ Polygon(208 Points)   {69C2D6DF-F1BD-4318-86D1-C14E10B…  {64E06EBE-0CA8-4B4E-8483-4FA2577…  real         nein     1483        2
 3432 │ Polygon(987 Points)   {C9623C8D-D6E7-4D0B-BE8B-9421E5B…  {B87F96EE-275F-4AE9-9061-21CE4CA…  real         nein     4513        0
 3433 │ Polygon(380 Points)   {D0FDA430-7CB9-47AC-8170-1CF1683…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4054        0
 3434 │ Polygon(409 Points)   {8FF582E8-8EA8-4E5E-B319-A09C479…  {B1A0542E-BDBE-4C92-874E-FB52BF1…  real         nein     1470        2
 3435 │ Polygon(830 Points)   {8626614D-28AF-449B-98F6-58A25FC…  {20746236-29C8-4437-B33E-8FA01C3…  real         nein     8352        2
 3436 │ Polygon(252 Points)   {842BA68E-7B72-4600-B51B-B7CBF5B…  {F2E993CD-26F2-4E68-A647-EB61D15…  real         nein     1195        3
 3437 │ Polygon(243 Points)   {93E13347-EAB8-4C7B-B3D0-8AC64FD…  {23DCDFA9-7D3F-4D08-887C-60D0A4B…  real         nein     2019        2
 3438 │ Polygon(265 Points)   {D078B28E-81A4-46D2-9C12-F1811D2…  {9E27655F-65C6-463F-A0E0-C81DFA5…  real         nein     4564        1
 3439 │ Polygon(330 Points)   {B92E67EA-409A-40A3-A934-BB046B3…  {9F007556-AF94-4B47-ADA0-C15D3C7…  real         nein     6830        0
 3440 │ Polygon(400 Points)   {2975B305-4686-4E84-8B67-E4FDAD5…  {5ACA859B-C8B8-4C9D-BDE2-BFD2A94…  real         nein     9604        1
 3441 │ Polygon(287 Points)   {2EFD293A-F1A3-4113-A3D9-FA672DA…  {378B01B3-D89F-42BE-97F8-13B2CFC…  real         nein     6921        0
 3442 │ Polygon(577 Points)   {B59F78C6-1375-406B-A327-140F685…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4053        0
 3443 │ Polygon(224 Points)   {62E844F3-9B92-42F3-B842-A673F03…  {4052AA1C-D54D-45F2-8AA3-7620E34…  real         nein     1719        2
 3444 │ Polygon(607 Points)   {4F58E7E3-5101-4FF1-BFC3-F5A75AB…  {905DC16A-ADFE-4EC4-A2B6-6901F91…  real         nein     3047        0
 3445 │ Polygon(697 Points)   {A52A5D6B-145E-4C63-8D26-2A6EFC3…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3007        0
 3446 │ Polygon(260 Points)   {FA236E9C-DE6C-41D9-B481-9ED2015…  {A851EC3B-EBE4-4D9F-8DB9-C8D9F3B…  real         nein     5116        0
 3447 │ Polygon(268 Points)   {3FA7D822-C9CA-48CB-AFF2-2677DD9…  {C88D98F3-C5D3-4036-BDEF-769886B…  real         nein     1580        2
 3448 │ Polygon(564 Points)   {76167308-484B-4993-A749-03E4EC6…  {20CE8470-097B-499B-B96D-841D59A…  real         nein     6989        0
 3449 │ Polygon(393 Points)   {8A2A74FD-87AD-4CA1-BC3F-67D02E0…  {CBAEB91E-F48C-4946-9E33-2064FA8…  real         nein     6340        4
 3450 │ Polygon(272 Points)   {328ACBB0-3FCD-4E5B-A034-665D411…  {80F654C9-A1AE-415D-9E44-E387FAF…  real         nein     3652        0
 3451 │ Polygon(220 Points)   {795D0243-AB05-47C6-B77E-17823CD…  {28F310AE-C74A-4664-A17E-601CE11…  real         nein     6930        0
 3452 │ Polygon(304 Points)   {77940FAC-7108-466D-AF68-7866F25…  {27C38FEF-8E83-4BDE-AAEE-B1FC3A0…  real         nein     3455        0
 3453 │ Polygon(143 Points)   {0199E108-470D-4612-A780-37C9BC0…  {31B4C06F-DC95-4FEA-9BD7-347C86A…  real         nein     2842        0
 3454 │ Polygon(357 Points)   {5A5148AB-69AE-49EE-9136-E011BBC…  {6C53429E-3394-4E1E-9BC6-371641C…  real         nein     8832        2
 3455 │ Polygon(227 Points)   {4436A175-EAD4-4A9F-8AA0-C2F83C2…  {2E91DB08-2C42-4F1C-BDDC-DF75223…  real         nein     6015        0
 3456 │ Polygon(585 Points)   {F2F0050B-3FF2-4C85-91AD-B60C50E…  {CE73C742-EDA2-431C-B6E6-54318DC…  real         nein     1470        3
 3457 │ Polygon(222 Points)   {D924C540-1604-4E4A-9C30-A31E362…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1206        0
 3458 │ Polygon(340 Points)   {C3F425B5-13CB-4146-8717-FC02A4C…  {E977E0B6-1908-4409-9AC8-F6958D6…  real         nein     1296        0
 3459 │ Polygon(242 Points)   {1A968E2E-1402-43E6-AB1A-AB58164…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8001        0
 3460 │ Polygon(220 Points)   {F872BA45-9C8E-40D4-9CFF-223E3D3…  {681C9229-F3D8-4FFD-9722-0E07F20…  real         nein     8589        0
 3461 │ Polygon(39 Points)    {F175209D-8A7C-4A01-A565-843D8B1…  {FD96AF76-F3D1-4EB2-BFED-040E43A…  real         nein     7130        2
 3462 │ Polygon(201 Points)   {4A95F862-37BB-47AA-B20C-1EC5B63…  {3B887F8B-8CE6-4F10-BBBE-E337648…  real         nein     1407        3
 3463 │ Polygon(183 Points)   {09940C1C-EE4B-42A1-952F-7E20424…  {69C3412C-161C-439B-88CE-C83A5EC…  real         nein     7415        0
 3464 │ Polygon(267 Points)   {4A43BA31-B283-4173-A3FB-E65D595…  {E4E472B3-184F-4661-B259-848CFE0…  real         nein     4576        0
 3465 │ Polygon(247 Points)   {6171D7AE-49AA-407A-8C5D-CA81993…  {C8959E5C-17C2-452F-A2EE-2C00C01…  real         nein     4566        2
 3466 │ Polygon(209 Points)   {FBDC2635-E551-4242-913B-2331939…  {C03EC66C-0D51-423F-B88F-350EF7E…  real         nein     3636        2
 3467 │ Polygon(231 Points)   {72EFC2F7-D221-4C09-98C4-FB1DF6C…  {4C6BD8E3-74CF-419F-B360-E1EF395…  real         nein     1682        0
 3468 │ Polygon(100 Points)   {33A73F72-68A9-4812-B443-5DE10D9…  {EFCFA89D-6EFE-4C35-A2C1-C49EEB8…  real         nein     8585        2
 3469 │ Polygon(362 Points)   {7298A63E-2820-4C22-B11A-5309611…  {CEF46D42-5ADC-4734-8BBE-A8B5483…  real         nein     1580        3
 3470 │ Polygon(161 Points)   {FB2C6CB2-F810-47A7-A9E3-38155F5…  {8E2C17C4-4EB7-4EA4-9E15-D28A719…  real         nein     9249        1
 3471 │ Polygon(642 Points)   {9395656D-6181-4213-8AE4-83255E6…  {B5CFB4D6-7CF2-4CFF-9490-88D3AAC…  real         nein     1028        0
 3472 │ Polygon(444 Points)   {EA265528-1351-4D8E-9022-788F56C…  {5DDFCFE6-62FD-442E-B7E7-DBA700F…  real         nein     8566        5
 3473 │ Polygon(490 Points)   {14287DE2-DF37-4BCA-9936-B3284A2…  {0A33733E-41B5-4DEA-A287-59FE97F…  real         nein     1410        4
 3474 │ Polygon(463 Points)   {703280F9-3B96-450B-8BDE-3CB55F4…  {FE86C421-2618-4CC5-B7A9-6467C83…  real         nein     6946        0
 3475 │ Polygon(155 Points)   {D47366FA-3FB3-4D66-B71D-B32B689…  {D8CE50D6-B970-4546-A744-39C8F64…  real         nein     2953        3
 3476 │ Polygon(232 Points)   {009131A5-B299-45B2-B5C9-06444EE…  {C0CAD52B-039F-4A88-8C72-9089360…  real         nein     1688        2
 3477 │ Polygon(809 Points)   {39E214A6-00D4-4B98-843E-42DB81A…  {3EDA79F9-75D6-48F2-9E34-5860BA4…  real         nein     1295        2
 3478 │ Polygon(380 Points)   {84876937-8EBF-42CC-819C-94CA601…  {6EBE80B1-EFD5-411A-BE80-0E6F89E…  real         nein     9565        2
 3479 │ Polygon(205 Points)   {B577C591-90C5-44DF-BAB4-012EB45…  {0E6B04A9-33D4-4C5F-8444-B68AE89…  real         nein     8242        0
 3480 │ Polygon(669 Points)   {B5DA2E1F-F50F-4D66-97E4-E7A13BF…  {A788CFF6-0B34-48E5-90D0-17C5092…  real         nein     1277        1
 3481 │ Polygon(199 Points)   {8BDF27BF-F510-4C77-AAD2-3A97999…  {AE2FB7EB-9218-485E-B6F8-9F357F7…  real         nein     6816        0
 3482 │ Polygon(158 Points)   {6BE77E02-58C1-4962-9352-F701511…  {497177FB-97AE-4782-B799-3F9866D…  real         nein     2560        0
 3483 │ Polygon(165 Points)   {FFBEEFB9-2CE5-469F-9AD6-27BB2A4…  {8C6535BA-A4C9-4032-BD8B-5D076AD…  real         nein     1682        5
 3484 │ Polygon(569 Points)   {19C01A45-66D6-4815-9072-6F0089B…  {69EFD42F-2B94-44E0-9B21-EFCB971…  real         nein     9400        0
 3485 │ Polygon(346 Points)   {21166BF3-34B7-43C0-959F-65D5D9E…  {326D8329-C8C8-4A42-BD44-67378E4…  real         nein     3127        2
 3486 │ Polygon(236 Points)   {F97E72AA-A260-4075-B3AE-F87FEDE…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1205        0
 3487 │ Polygon(148 Points)   {58AB9F19-2404-454A-A5AA-B59649B…  {BD7EB53B-4B9C-4735-8E4E-21BFE82…  real         nein     1787        2
 3488 │ Polygon(229 Points)   {05F67007-EB54-43E1-9F7A-29EE41F…  {77AF265A-436F-4015-860E-E61E8EC…  real         nein     6825        0
 3489 │ Polygon(214 Points)   {19D826C3-DA98-4D48-9D92-EEAADAC…  {748C4665-1EED-42F2-ABFC-87C55F6…  real         nein     1653        2
 3490 │ Polygon(305 Points)   {740390E8-36C2-40F7-813D-2A2F0EB…  {9BE3B1D6-42BD-4761-B74C-D5F48D7…  real         nein     8806        0
 3491 │ Polygon(350 Points)   {93258C0F-8D23-415B-839D-7E3C6E7…  {18A77FB0-6E6F-4C1C-BAB5-3776DA8…  real         nein     9012        0
 3492 │ Polygon(249 Points)   {6559EA16-9A01-4947-B7D5-EB721A5…  {977FBC76-76EC-4379-93BB-439C8E4…  real         nein     3800        5
 3493 │ Polygon(251 Points)   {A0002F52-7BE3-4D3B-822D-76798E7…  {E41970D0-102B-4045-A00D-11A4BE4…  real         nein     3208        0
 3494 │ Polygon(450 Points)   {90AAD962-6B89-4F3D-A9BC-49BE227…  {6304E428-E486-4FC0-8E7C-E66EE2E…  real         nein     6644        0
 3495 │ Polygon(426 Points)   {1C0F7492-35D3-4EDB-AA58-C894B42…  {FB5A87C6-465C-451E-B881-8B7ED76…  real         nein     6981       11
 3496 │ Polygon(290 Points)   {0F02336F-84EA-4CF9-B8EC-BA7B89E…  {504F9543-8CCA-43AD-853A-FECB3BC…  real         nein     5613        0
 3497 │ Polygon(403 Points)   {6D1AC134-B849-4917-968D-4A043C9…  {E77E7D5A-FF7D-4EAC-A7C3-2D47D9C…  real         nein     8136        0
 3498 │ Polygon(66 Points)    {485C2813-ACB3-4F7B-8DA9-FA81A33…  {A606828F-40ED-40B4-8C93-230D29E…  real         nein     1933        4
 3499 │ Polygon(347 Points)   {DA4E40DC-C366-410E-AAB0-DACA66A…  {A700ED6B-4B98-47E0-92C0-AF7A5EE…  real         nein     1122        0
 3500 │ Polygon(389 Points)   {494BA82D-C622-494F-AE80-D039603…  {E39B55D4-DA0A-4765-9E49-EDEC27C…  real         nein     1279        2
 3501 │ Polygon(99 Points)    {1B737CD4-37B1-4B93-8531-4E61BA5…  {CB207CF7-63D6-4CCD-BE44-B9A7ABF…  real         nein     6414        0
 3502 │ Polygon(126 Points)   {527B8009-08C9-4D9F-8A7C-F0599C0…  {2F105402-2D92-4075-9E8B-B819008…  real         nein     4588        2
 3503 │ Polygon(237 Points)   {F68AAA85-40FF-4497-BF14-12C4668…  {BF7BFC58-B83F-4ED2-AC6C-6DE42E8…  real         nein     4558        2
 3504 │ Polygon(843 Points)   {A28AFF21-DD6B-459D-9B00-6AD0438…  {26D9F143-8BC5-48FC-9FC8-DEBE085…  real         nein     8584        0
 3505 │ Polygon(81 Points)    {393209D7-7869-41CE-8ADC-7F42C54…  {0B03946D-9EFF-4FA1-BCC5-5485D20…  real         nein     1945        3
 3506 │ Polygon(329 Points)   {79BD8218-3C03-4AE9-BC4A-D710447…  {165B5D24-AA65-4A3F-8179-55F6D79…  real         nein     6958        2
 3507 │ Polygon(97 Points)    {E1575B8C-E597-4848-93AB-01E598F…  {44A7549D-10D1-414A-B9BE-A166048…  real         nein     1955        3
 3508 │ Polygon(199 Points)   {CB138CF5-C843-4443-923F-EF89890…  {817A4145-43EC-4429-8EF4-D50E3E5…  real         nein     4571        2
 3509 │ Polygon(440 Points)   {7475DBF4-ECE1-40CC-A5BD-3E31ABC…  {5097CE05-999D-40BD-96B8-BCCCBFD…  real         nein     8774        0
 3510 │ Polygon(406 Points)   {768FB8C5-4238-4C72-8F9F-7C3EDD4…  {BE2A21CC-43AA-43F6-80A3-15AFC81…  real         nein     6777        1
 3511 │ Polygon(454 Points)   {C22C4AEC-7AAD-418C-92B1-F3C5692…  {EE763B08-060C-4771-829D-DE9F7A4…  real         nein     6807        0
 3512 │ Polygon(294 Points)   {B119F2C4-F5C5-42D0-ADB5-7FA0C3F…  {43EFC31D-6E8A-4193-A204-4E4A1AB…  real         nein     1098        0
 3513 │ Polygon(358 Points)   {5D352676-77E5-44DD-ABD4-7D1247F…  {F5D1CDD3-5CEC-49EC-9E00-2E61522…  real         nein     8360        2
 3514 │ Polygon(274 Points)   {FC520625-DEC1-438C-A3AF-0A10FCF…  {12C12978-A906-4676-BF15-B9D1D6B…  real         nein     6814        2
 3515 │ Polygon(165 Points)   {FAF1D8D7-2F9A-4CC7-9A3C-9A45B3C…  {4845AAAB-3B75-4DBE-AA92-F90A2FD…  real         nein     4453        0
 3516 │ Polygon(218 Points)   {25787FAE-17FA-466F-9DFB-72E217C…  {98049E54-1DCE-41EB-ACDD-5FF1DCF…  real         nein     3815        0
 3517 │ Polygon(396 Points)   {2BB53E39-F95B-46CF-A2E9-05653DF…  {538F4C20-60E3-4D99-B599-6B47918…  real         nein     2015        0
 3518 │ Polygon(374 Points)   {20277278-F384-4530-AFA1-3D754C7…  {3A94232E-C2C8-4025-8DF6-7C7E191…  real         nein     1726        3
 3519 │ Polygon(252 Points)   {D57E0B1B-5FE3-4EB0-ADB9-A7852C1…  {24B7A7BD-4927-45DF-9E3A-F3B3B51…  real         nein     4582        0
 3520 │ Polygon(270 Points)   {C7E8A044-FEFE-4FA4-8A8D-B6A8982…  {12798A4E-4B57-4EBA-8AD1-811A986…  real         nein     4656        0
 3521 │ Polygon(72 Points)    {B200FB68-DAD9-47A8-944C-2DD834C…  {A59F3008-3F5C-4398-84E6-14AACB6…  real         nein     7224        0
 3522 │ Polygon(99 Points)    {736BE195-D7CA-45C4-A22C-E084F60…  {A551BA34-A3C2-4EB9-9F1D-8298E53…  real         nein     7426        0
 3523 │ Polygon(268 Points)   {C4E01FC2-4D0D-40A2-9C1F-5D1159B…  {D7A4D806-0F21-4138-9D4A-6AA4C37…  real         nein     1025        0
 3524 │ Polygon(575 Points)   {6506776E-E5FD-4E71-8F39-6E503A8…  {7FA0534E-DFAD-4FC0-8D28-70C0357…  real         nein     3037        0
 3525 │ Polygon(308 Points)   {00B4BD51-ABDD-4276-8643-AEC7EB4…  {644FBF2B-44CB-4C8F-810F-F7C8C68…  real         nein     9320        2
 3526 │ Polygon(368 Points)   {04B6F34E-BDEE-4AC8-A6EB-64ECB26…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4055        0
 3527 │ Polygon(550 Points)   {91642536-A60A-4B2D-B159-0915867…  {0A29417B-8281-41D9-84BC-28990FC…  real         nein     1026        2
 3528 │ Polygon(350 Points)   {D2150B76-BBBA-4110-BBAD-3E1CE8E…  {3585F634-D556-4942-B079-296E40A…  real         nein     1587        0
 3529 │ Polygon(163 Points)   {202EE994-CBB0-43FF-A45E-BB398B1…  {FFA5E92A-FD5E-4832-94D9-FF155D8…  real         nein     8586        5
 3530 │ Polygon(218 Points)   {ADEC444D-CA2B-4DAF-8203-4AFEE23…  {0F452EE9-1FFF-44C9-9B1D-FB648B5…  real         nein     8572        3
 3531 │ Polygon(408 Points)   {55449A19-6800-45B6-8D5E-98BB3FF…  {CFCFF609-3785-428F-9544-4D7DE9E…  real         nein     6912        0
 3532 │ Polygon(139 Points)   {B5EA9714-EF37-41F0-B481-F59A932…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1207        0
 3533 │ Polygon(843 Points)   {30043EF9-8848-4B03-BEA8-A2E0030…  {2077A137-0F76-4B57-941D-1E1D040…  real         nein     1267        1
 3534 │ Polygon(230 Points)   {FDDB39E9-5923-49E4-B210-60E8A78…  {CAB64613-A4BE-4405-B458-369B674…  real         nein     8564        7
 3535 │ Polygon(240 Points)   {B47A2A16-8F11-4112-AB31-A536CB1…  {76E70659-9008-4BA4-9D84-89FCD48…  real         nein     6295        0
 3536 │ Polygon(361 Points)   {473D2FA3-8D4C-47B3-99DC-EDF0345…  {A45FFA4D-0C33-4708-A536-F189134…  real         nein     1683        2
 3537 │ Polygon(292 Points)   {F5CD6B89-E600-49F8-B6A5-F350B85…  {53871137-E9B3-4990-A537-C0DABB9…  real         nein     8585        7
 3538 │ Polygon(430 Points)   {A96E4652-9A48-4905-8779-CFE6A10…  {9C0D2F3B-3E51-4A16-AC31-A6D9A11…  real         nein     3215        0
 3539 │ Polygon(192 Points)   {40569B3E-9753-4829-91BA-51468C9…  {05DAD8D4-8595-41AB-BBED-CDA9A09…  real         nein     8583        2
 3540 │ Polygon(303 Points)   {71518D7C-8E68-4184-9090-68EACBE…  {EB7F16CE-FF95-44C2-B145-00CA498…  real         nein     9326        0
 3541 │ Polygon(448 Points)   {E8D9A3FF-C3A3-478D-8D0B-FFEDF7F…  {DF69B2CB-955C-4A92-8E41-41B5616…  real         nein     1078        0
 3542 │ Polygon(622 Points)   {4F09F4A2-9A84-4967-A0C1-FD221F8…  {AD18C6A5-3779-4264-96A6-689AC0D…  real         nein     6839        0
 3543 │ Polygon(205 Points)   {94B8B2BA-2829-456B-9DFB-E67F961…  {B770A493-2B71-4962-898F-18FACDE…  real         nein     4556        4
 3544 │ Polygon(107 Points)   {4E884E3F-3861-4762-B287-95DA5D4…  {972F1FED-0CAC-4FEA-A7C7-F61D044…  real         nein     8585        8
 3545 │ Polygon(623 Points)   {5EB073D7-E46D-46EA-B2C9-B0AC64C…  {F966C1DE-01B4-4CC4-843E-B68E580…  real         nein     1195        2
 3546 │ Polygon(323 Points)   {60FC4997-4244-4D10-B72F-E152182…  {016CE574-C1F8-47FC-BDBB-6791D40…  real         nein     8905        2
 3547 │ Polygon(377 Points)   {9BA93404-8EE2-45A6-84FB-2F789C3…  {34F6539E-A015-4477-99E8-F0E790E…  real         nein     9565        3
 3548 │ Polygon(509 Points)   {4FA9AEEE-E109-4F34-838C-831ED27…  {93B6D42B-ABEC-4B4B-BF60-5ECC77E…  real         nein     6605        0
 3549 │ Polygon(54 Points)    {DB67FCEB-04C9-4376-9EC7-653FD1C…  {185628BB-829C-4789-88A9-925C546…  real         nein     1945        7
 3550 │ Polygon(73 Points)    {19EE8127-3F9E-4C93-B9E5-A2F578B…  {5779C6E4-D529-44F4-8A93-9CB985F…  real         nein     1996        5
 3551 │ Polygon(326 Points)   {E9EE4D20-D882-499B-A794-305A062…  {208F6F77-6530-4B4F-8F6B-AAD2BE5…  real         nein     1029        0
 3552 │ Polygon(201 Points)   {C346404E-11D0-4D4B-8CAA-7EE735F…  {DF68F3BC-C4C9-487B-BE04-7828FF6…  real         nein     4423        0
 3553 │ Polygon(455 Points)   {D9A16EB7-6E0D-41A1-88DC-65F6F7C…  {C54DC0AF-420E-4834-AAE2-7DCA88C…  real         nein     9411        1
 3554 │ Polygon(221 Points)   {7022D372-5EE8-4A39-8DE6-2605697…  {47BFE108-B2D1-495F-82C6-D3DC6C8…  real         nein     8866        0
 3555 │ Polygon(288 Points)   {38820882-C4BC-4BA4-97C3-FA93CCA…  {0E4E4F9D-3C12-4D90-94AC-D349E4D…  real         nein     1526        2
 3556 │ Polygon(472 Points)   {21035736-F3FD-4C6D-8D24-74790F8…  {8EBDC89C-645F-4E84-AF70-C2C27AF…  real         nein     6918        0
 3557 │ Polygon(166 Points)   {0142D487-EB1D-4899-A677-854CC0D…  {56BC0848-DEAE-41EC-BB4C-B3E470D…  real         nein     6815        0
 3558 │ Polygon(229 Points)   {BA828C84-A6BF-43DF-A628-9BDD0BA…  {34B34B22-46C3-41AD-9402-6A258CE…  real         nein     1697        2
 3559 │ Polygon(188 Points)   {EEAD7C97-FF2B-4203-BB3F-5E18757…  {6B308D1D-DECD-416C-A522-B9D9545…  real         nein     1782        5
 3560 │ Polygon(534 Points)   {D525FBBB-581C-45BA-9333-A5E0AB5…  {9DC0EC91-04CC-4CC6-BF96-7017F00…  real         nein     1417        2
 3561 │ Polygon(216 Points)   {FA543C04-8BAB-495D-8CF0-FAAE98F…  {A7F9C373-0E55-487F-9B8D-0C80CD4…  real         nein     8545        1
 3562 │ Polygon(149 Points)   {E8A3D492-C287-4CC7-9D1E-3D509BE…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3005        0
 3563 │ Polygon(445 Points)   {4543869F-5AA1-47AB-91CC-3D2C148…  {5FB94B59-3952-4784-B6E6-340D6D8…  real         nein     6833        0
 3564 │ Polygon(579 Points)   {D79C677C-09B9-45F4-A174-3483B85…  {D972CD8E-07B2-4AF3-8B2D-E450BCE…  real         nein     4302        0
 3565 │ Polygon(737 Points)   {899B3F86-5FA5-4CFB-B8EB-7A465D7…  {8A537359-1389-4D42-A8CE-2346BF1…  real         nein     1822        0
 3566 │ Polygon(534 Points)   {254FDABB-5F69-4E57-8736-0589B2D…  {516333A6-DF15-4E6E-ACD3-12627FB…  real         nein     1724        7
 3567 │ Polygon(468 Points)   {6BDEB4B8-7A1F-469E-9513-42F1C93…  {607BD723-0486-4FC1-822A-0762640…  real         nein     1720        2
 3568 │ Polygon(629 Points)   {C6BFEE42-C035-48CF-BBA5-8D1C17D…  {002C3C74-8C57-40F6-99D2-C61B7E3…  real         nein     8487        1
 3569 │ Polygon(80 Points)    {92B45A93-77D9-4257-8FBA-E1C9501…  {CC94E620-716A-4D8D-AE64-43F894C…  real         nein     6410        4
 3570 │ Polygon(419 Points)   {1738CFD8-C583-4AC9-9A11-BF2E7B3…  {2AD9D846-07F2-435B-816B-A774816…  real         nein     1125        0
 3571 │ Polygon(416 Points)   {04A19B40-0E15-48F4-9F25-7451A4B…  {D047AE34-D295-4A01-840A-3732EE5…  real         nein     1132        0
 3572 │ Polygon(540 Points)   {836E78E9-6960-4A2E-AE33-F0482BE…  {96092F82-7401-48E8-BB32-40FB7F8…  real         nein     4112        1
 3573 │ Polygon(78 Points)    {6526592B-2927-41CE-9812-6BDFE0C…  {BC5C5C54-939F-475B-96AC-813594D…  real         nein     6343        2
 3574 │ Polygon(226 Points)   {85BBBD5A-D497-4BCF-ADC2-7DB8656…  {E281F5D4-893F-46E7-A71B-D5E2A46…  real         nein     6212        2
 3575 │ Polygon(383 Points)   {BDA842F7-F368-4E49-8F4B-8DCE0D3…  {1849543A-A0D8-4F95-89B0-51A80B5…  real         nein     6953        0
 3576 │ Polygon(434 Points)   {5C2379AD-561B-4C73-A258-6C45F25…  {A8E1A58F-835C-4D9F-B7EC-8ADF8F7…  real         nein     1522        9
 3577 │ Polygon(258 Points)   {400C22AD-B398-41A2-82B3-555F44C…  {E60DA1F9-8C1B-4DAB-BBF0-FA9A0B3…  real         nein     1131        0
 3578 │ Polygon(381 Points)   {13F13E85-6802-4E44-9914-A0E5FB9…  {DCE62E62-028B-4325-B471-277EF0D…  real         nein     8115        0
 3579 │ Polygon(186 Points)   {F6B7188C-010A-4E9F-B7E4-865D78C…  {9CCD6A75-B9D6-4354-9CEC-5D55A0A…  real         nein     6865        0
 3580 │ Polygon(188 Points)   {7FDBFE12-C450-4A87-AFA9-80730BE…  {17DFC072-603E-4684-98E7-5617743…  real         nein     4496        0
 3581 │ Polygon(340 Points)   {489B0F46-3E6D-4624-8834-53C7CC9…  {B1990549-980B-4CE2-9E6B-B0D939D…  real         nein     2027        3
 3582 │ Polygon(507 Points)   {6915D21D-A51B-482E-8671-6010A52…  {2168B2B7-8DDB-4220-9E1A-85C14F8…  real         nein     4586        0
 3583 │ Polygon(213 Points)   {D562897A-A689-439C-9EC1-F4DF0F3…  {A39C4C63-8093-4B3B-885E-EB5E0E2…  real         nein     3626        0
 3584 │ Polygon(178 Points)   {94106CDB-8FB3-4CB0-BFBE-81B876D…  {CC6AA2CF-034F-4567-860D-2E78853…  real         nein     4588        0
 3585 │ Polygon(678 Points)   {19215AA8-2CFF-404D-BC47-FABB439…  {5992D0E3-0168-4773-8A9E-74B4058…  real         nein     1022        0
 3586 │ Polygon(280 Points)   {85F66811-29F7-4143-BEC0-305BDD6…  {9540BFD6-FEDD-469C-B706-1B40722…  real         nein     6933        0
 3587 │ Polygon(275 Points)   {D23B5124-F686-42E1-BFBA-A95FA7A…  {AA7FB49B-945B-4BC0-896D-38A92E3…  real         nein     7110        0
 3588 │ Polygon(401 Points)   {6FFBAD0D-E74F-4BB4-85B6-774B9E2…  {D3D6D678-03A0-41A0-97C6-F3EEE0D…  real         nein     6948        0
 3589 │ Polygon(239 Points)   {D4329496-BAE3-4688-AE78-34965F1…  {7E050FE7-5223-4265-9839-8FF2249…  real         nein     5505        0
 3590 │ Polygon(391 Points)   {EABB3B22-0C81-42DF-AF45-1B8A28D…  {0D8967BD-A132-4A12-9ABC-7710105…  real         nein     1884        2
 3591 │ Polygon(112 Points)   {BB31FD3E-4B61-4FBE-960E-85C2B25…  {DEC01EBA-CC24-4158-9B68-F6B700F…  real         nein     8585       10
 3592 │ Polygon(97 Points)    {DAE894AE-BB07-4709-A6C9-1D75142…  {165D9B07-05FB-4A94-B3D0-4BAF369…  real         nein     1061        0
 3593 │ Polygon(254 Points)   {B4911AB1-47F3-4176-825F-06EC20B…  {5709820E-8EB2-4751-90CE-5D3A7A1…  real         nein     7422        0
 3594 │ Polygon(837 Points)   {55BBEBA7-EAAA-4913-99AF-D830F74…  {0C0A359D-AF2A-447F-876C-6A2F402…  real         nein     8750        2
 3595 │ Polygon(199 Points)   {D0C60864-60FC-40BA-9AA7-0B7495F…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8064        0
 3596 │ Polygon(599 Points)   {BB884F22-B91D-4393-AB26-9D4D0A3…  {5A423ECE-BF97-40AE-AD81-C6A177E…  real         nein     8484        2
 3597 │ Polygon(170 Points)   {5CE53C00-4565-4D02-A695-7DEE2B9…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1201        0
 3598 │ Polygon(260 Points)   {4FE7A93B-77DA-454B-878A-10CC614…  {D1969FA4-3289-4AC5-999E-74BED74…  real         nein     3215        2
 3599 │ Polygon(309 Points)   {264FBAC3-7AE6-4FB3-A619-D73310D…  {2E30CC3F-4B9C-408D-BD3C-FE17981…  real         nein     3900        3
 3600 │ Polygon(446 Points)   {734BDB85-2B2B-41A2-8624-3EB8F7A…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4051        0
 3601 │ Polygon(251 Points)   {B7BB5DC5-0130-417D-B4C9-608D43E…  {DAFD0F24-285E-4440-92A0-2A5482B…  real         nein     6935        0
 3602 │ Polygon(640 Points)   {F4C4B21D-D81A-4C83-9570-F6AE3C7…  {0EECB667-A6C5-4964-8E3F-9137E51…  real         nein     8044        1
 3603 │ Polygon(229 Points)   {6DFAB273-443A-498F-BB78-67855A8…  {E1FC7EC5-1D2F-49D6-A01C-25049FC…  real         nein     8310        1
 3604 │ Polygon(239 Points)   {147B8F5A-4D47-4A6B-9357-5B87F6A…  {23445068-6A7F-4A3A-A716-C4DCE89…  real         nein     1436        0
 3605 │ Polygon(220 Points)   {D59BEA18-DCB2-4A7B-A2A6-CF5B1C1…  {F218815C-3CB0-4008-8EA2-4B7D314…  real         nein     3206        3
 3606 │ Polygon(455 Points)   {23C24AE0-1CB0-4E7B-8592-94425FD…  {5C5E2E61-DEA1-4223-BA02-00538DD…  real         nein     2012        0
 3607 │ Polygon(843 Points)   {1E5D5249-75C7-4646-A986-A9D1372…  {60787F32-D966-4B9C-9F0D-E2FCEAB…  real         nein     4853        0
 3608 │ Polygon(104 Points)   {637F550D-2395-4400-9F91-5304D93…  {F3FDCEE2-1A3E-4840-A407-44E46D3…  real         nein     8564        3
 3609 │ Polygon(1695 Points)  {7B7587AF-F11E-4FF6-80FF-152CB27…  {261CBD6C-A5F3-40C2-8201-B0EEC5C…  real         nein     4115        0
 3610 │ Polygon(581 Points)   {BC78A8B1-4E80-42C1-B3B2-455E9EE…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1006        0
 3611 │ Polygon(722 Points)   {44516FCF-FCAC-44A1-8E5E-5F04DF8…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1005        0
 3612 │ Polygon(244 Points)   {E37102B6-BBBA-49AE-8944-89D2C86…  {53608176-DFBB-4569-8E44-D0F8934…  real         nein     2025        0
 3613 │ Polygon(130 Points)   {852DC43D-DB66-4297-8752-7CF0054…  {9EA6F566-E82B-42F0-8AA4-79DBAC0…  real         nein     3900        2
 3614 │ Polygon(772 Points)   {95279A9B-E945-4E75-9C7A-A3F9775…  {29DD5E91-66BF-4C99-97C2-F58007A…  real         nein     8572        4
 3615 │ Polygon(137 Points)   {473E56C8-D2C9-45E9-A801-E0D373A…  {77A96D47-964D-4B86-85F8-03519BA…  real         nein     4447        0
 3616 │ Polygon(446 Points)   {411AC227-AD7D-42FE-BE50-2DDC754…  {E297BFBA-C44C-403A-889F-03C3419…  real         nein     1248        0
 3617 │ Polygon(416 Points)   {BACE07C0-E322-4062-A578-C043F29…  {37AC3203-5E7D-4909-82A4-625BED2…  real         nein     6992        0
 3618 │ Polygon(112 Points)   {AE70222E-C258-42D9-A38E-20F5D1D…  {A4DBEE62-3F35-4EF6-A341-46D9D20…  real         nein     3435        0
 3619 │ Polygon(426 Points)   {5F04C024-F1EE-40C7-9092-A578A58…  {18E412E2-6771-4D42-97CF-011618A…  real         nein     7183        0
 3620 │ Polygon(144 Points)   {E9EF7F90-C40B-4470-A5E5-97F0BAB…  {C86D7721-78FF-4995-8567-5307677…  real         nein     8464        0
 3621 │ Polygon(114 Points)   {A312886B-C256-490C-BE78-C40601E…  {506E4003-9734-47D6-92AA-63E1488…  real         nein     3256        3
 3622 │ Polygon(853 Points)   {444A7FFB-30CA-4BAE-B05B-6679AE0…  {B9D6E0A0-596B-43A1-B3D9-C5F553C…  real         nein     4524        2
 3623 │ Polygon(305 Points)   {12471D08-BB7B-4D4C-80EA-37AB2CC…  {FF7385C3-CD7B-413B-AF28-9FD0D1B…  real         nein     6600        4
 3624 │ Polygon(115 Points)   {26F5A37B-E440-4CF5-986D-0DAB856…  {455D0DFE-228F-445F-B0E9-7029268…  real         nein     6723        3
 3625 │ Polygon(336 Points)   {6A385832-F696-4864-97A4-FDCF734…  {5F07378B-2628-4E97-AC8C-E6B2A8D…  real         nein     1304        3
 3626 │ Polygon(109 Points)   {495C3001-0D43-4A84-9FE3-83097C0…  {A223ED6F-7205-44FD-9A2C-F08A69A…  real         nein     8241        0
 3627 │ Polygon(186 Points)   {824A6B4F-9D90-4CDF-9DBE-D31BA92…  {785AAE7B-FE46-4FD1-914A-4D4F514…  real         nein     3429        3
 3628 │ Polygon(368 Points)   {0B29EF91-44CF-43C0-88DA-20162B5…  {5274BD67-2BF4-4D37-9DC2-8E156DC…  real         nein     8106        2
 3629 │ Polygon(191 Points)   {DA0354BC-CA17-44B6-BCC4-8F9C8E0…  {A07A95C4-77B3-4A69-AC86-D63A8EE…  real         nein     3380        2
 3630 │ Polygon(291 Points)   {8D7C74DA-AA22-4DD0-B731-3AE842A…  {42896F7B-1D86-4D15-8920-4D87B18…  real         nein     3624        2
 3631 │ Polygon(307 Points)   {DCE2D292-78CE-43A4-8E61-6E60BF5…  {CFDD9B46-1BBD-44DB-A65E-3089ED8…  real         nein     1355        2
 3632 │ Polygon(286 Points)   {101E4E55-EFC3-4ABE-9D55-6A7C7A7…  {A5775C28-9B9E-4BB9-9883-5003C04…  real         nein     1473        2
 3633 │ Polygon(213 Points)   {C9360518-5D8E-44CF-AB62-B5AF2AE…  {935C4949-AE58-49C4-8C2A-B06BE2E…  real         nein     8581        0
 3634 │ Polygon(105 Points)   {91E8F031-4E0B-4116-915D-FB5B597…  {B0B5D783-E649-4A28-B0F1-53FCBAF…  real         nein     7242        0
 3635 │ Polygon(305 Points)   {9AC1FD8F-1D18-4AE0-B63C-2147446…  {BFD02870-C396-4654-8E32-328BF46…  real         nein     6947        0
 3636 │ Polygon(178 Points)   {0E969F7A-DDBC-4791-B495-046FA25…  {58D4BE53-992E-4C09-9C42-36E927F…  real         nein     4558        0
 3637 │ Polygon(207 Points)   {BAB15377-035E-4957-8BA6-01E43B1…  {E91262CF-A639-43EA-9BD8-88A54BB…  real         nein     1756        2
 3638 │ Polygon(506 Points)   {F3552DF2-4B13-40E9-9789-1735116…  {A73002A3-FFFD-4EC0-8212-742D45A…  real         nein     6852        0
 3639 │ Polygon(7 Points)     {59905FCA-1620-4F32-9EBC-DE0FA05…  {95F97DAE-0DD9-4BA6-8CBB-605C277…  projektiert  nein     7710        2
 3640 │ Polygon(184 Points)   {77AEB580-089D-4DD4-9AC9-5997508…  {FE144532-91B3-4F8C-904E-2099F44…  real         nein     3303        4
 3641 │ Polygon(78 Points)    {21401D3B-EC25-4EC9-A922-8ACFA13…  {30DF2186-09D8-42CA-B3BD-28E0B7D…  real         nein     1966        7
 3642 │ Polygon(324 Points)   {BFE33947-9B0A-4EA9-81D4-B037EAA…  {85AA9A34-CA56-4072-95F7-31051C7…  real         nein     3053        4
 3643 │ Polygon(144 Points)   {FAC430FB-D2FC-4465-BD8D-372A08C…  {765820B1-CA64-461C-905A-E3AF21A…  real         nein     2533        0
 3644 │ Polygon(275 Points)   {A1FDFF69-6BFF-45BA-8009-C0C29FC…  {5AB62404-5126-4CF1-AB99-0A72A48…  real         nein     1686        2
 3645 │ Polygon(81 Points)    {57700FA6-45AA-454B-860C-7786D48…  {0EB88023-B8FB-473D-B2A1-EC12167…  real         nein     4442        0
 3646 │ Polygon(239 Points)   {2D905E7B-5F73-4FF3-A8F9-DB935A0…  {595EF4D1-A76A-4666-BAD1-CEB1B6B…  real         nein     5103        0
 3647 │ Polygon(400 Points)   {8132FB5D-9789-49D9-A29A-36DCC5A…  {C428B917-4074-45FC-BC28-C19A78A…  real         nein     8632        0
 3648 │ Polygon(393 Points)   {CAB3CCB7-849A-41F5-87CB-4FA4FD1…  {E763ECF7-05A1-44A3-A0A5-5DF8B8E…  real         nein     1683        3
 3649 │ Polygon(507 Points)   {41B3774E-C240-440E-9E0B-7AB5BD3…  {924FB6B8-2EC4-4812-BF7A-88E23FA…  real         nein     8332        2
 3650 │ Polygon(311 Points)   {38D5C35F-8B3F-4A8D-8F20-44F6A19…  {D42A411B-E872-460B-800F-F4EFF57…  real         nein     9604        2
 3651 │ Polygon(311 Points)   {5FF9AFFE-9310-4E28-AED1-2E65909…  {83D6DCCA-EED6-4097-8B97-05865BA…  real         nein     3968        0
 3652 │ Polygon(211 Points)   {3A9D61BC-81BE-481E-8FCD-A9F1C5C…  {0FB8FC01-1EB4-4C1E-AF80-B4B4F9A…  real         nein     1475        0
 3653 │ Polygon(331 Points)   {0B08B8CC-1D4F-407F-B05A-D15F171…  {4085D541-DA8E-4589-9E07-28B5E51…  real         nein     1996        2
 3654 │ Polygon(347 Points)   {3FAD5D4D-1929-4581-B190-2A3A887…  {A853766E-BA6A-461F-B1FB-62981E2…  real         nein     4564        0
 3655 │ Polygon(328 Points)   {0A80064E-A344-4CBC-8A5B-9DAD897…  {59B3988C-142E-4FA5-804F-7B12327…  real         nein     8003        0
 3656 │ Polygon(243 Points)   {4C359361-5CE0-4982-A7BE-19FD0E2…  {986EA00E-3C0F-4F07-9DF6-FD5BBBB…  real         nein     8245        0
 3657 │ Polygon(224 Points)   {4F06859D-4612-4F5E-9FC6-6469BBA…  {D60E07FD-D6AC-4416-8B5C-7108F06…  real         nein     1674        3
 3658 │ Polygon(150 Points)   {4F366DD1-B184-4A10-B5D1-CE69EFE…  {E716359F-7BDD-4373-ADE6-CDD9D3D…  real         nein     8471        0
 3659 │ Polygon(291 Points)   {8FCA6C31-91F7-431C-839A-C62F1EE…  {46E2BE28-2F3C-4648-98F1-47EE983…  real         nein     3948        0
 3660 │ Polygon(123 Points)   {C2728724-B59F-4266-BFE3-99FE526…  {C66E1655-6D2B-4E92-82A4-3731A99…  real         nein     3603        0
 3661 │ Polygon(286 Points)   {AB25F5DD-CC7B-4DA5-B935-E448F7B…  {0F04B6D7-4B8C-41C5-9F94-06B3E0E…  real         nein     3216        2
 3662 │ Polygon(129 Points)   {D152B5EB-83C1-4420-BBC9-C265C89…  {84A0B503-4EFE-4ED9-9553-52467B6…  real         nein     1610        2
 3663 │ Polygon(50 Points)    {1497DA3B-82C3-4EAC-A4F4-987E5BB…  {AF485C7B-D3DF-49DA-9D64-5B8385E…  real         nein     1945        9
 3664 │ Polygon(306 Points)   {51AF1308-3ECF-4557-A300-41AF8D7…  {92D20AB7-3AAE-46A1-914F-EB4B9D9…  real         nein     9556        2
 3665 │ Polygon(185 Points)   {BB0D5F91-7BE6-4DB8-ADA0-D705F48…  {B3253D3B-C0DA-4AD1-B1C4-C1182F2…  real         nein     3376        2
 3666 │ Polygon(683 Points)   {540B60E5-8DEA-46D3-818D-0C35063…  {E8FBA8B5-C1F5-4F4D-B713-2498CE3…  real         nein     3097        0
 3667 │ Polygon(201 Points)   {C52F4D0E-ADE2-4DC3-8F5D-6F94DCC…  {34B1FBAA-9BDF-44E3-BC71-3F337FA…  real         nein     4558        3
 3668 │ Polygon(144 Points)   {48B35A24-D7D8-49D8-8E78-0B16224…  {AA1A93EB-2AD6-4BD2-A05F-78FED43…  real         nein     1409        0
 3669 │ Polygon(249 Points)   {E20C822A-2C85-423F-A5AF-DFC5397…  {0BA741CC-72D0-4E11-A67B-4190E97…  real         nein     1148        3
 3670 │ Polygon(120 Points)   {5C61C99E-6BC4-425A-9B13-4E7DF78…  {5F028CE4-6C95-4B85-85C0-8171A0F…  real         nein     3942        3
 3671 │ Polygon(277 Points)   {900DC5A9-DD02-4B09-AC31-0C3F819…  {B2ABADCF-1298-4815-BCEF-B382E51…  real         nein     8583        1
 3672 │ Polygon(168 Points)   {3A24E9AF-F977-4D28-9324-533FEA3…  {9343FDFF-DCF5-494B-8AAE-FB3DE28…  real         nein     1097        0
 3673 │ Polygon(269 Points)   {82E79150-33D7-443F-8D63-6DF6D85…  {BD48FB53-7347-4311-B58A-F1594E0…  real         nein     1219       10
 3674 │ Polygon(529 Points)   {EB717621-060E-4719-85AD-EA8592A…  {49163F18-3ADC-44E8-BCBE-C615760…  real         nein     1802        0
 3675 │ Polygon(338 Points)   {2BF20599-23C5-4024-A088-30475DD…  {A435861A-DE29-4608-BED5-AD6D664…  real         nein     8585        1
 3676 │ Polygon(202 Points)   {588C7E01-15A1-46D5-AF38-52F92FA…  {3816EDD8-7949-48EF-B2C8-8FA45CF…  real         nein     3654        0
 3677 │ Polygon(151 Points)   {D5448D18-F274-4E3D-8736-222DB47…  {2A726AE4-F158-4160-AEC8-283F31B…  real         nein     6260        4
 3678 │ Polygon(235 Points)   {B585048C-5361-4C8B-A672-E0A675A…  {028F46E1-F24B-4817-B7EF-E8B8087…  real         nein     4304        0
 3679 │ Polygon(306 Points)   {B1C9A02F-61F0-4280-947B-5188C71…  {D5C733F5-9A76-415E-A60D-D29DDED…  real         nein     6724        2
 3680 │ Polygon(139 Points)   {E995AEF0-F5FF-4324-9091-2807C2C…  {B32DC482-D52E-463B-8A9E-777DE27…  real         nein     3702        0
 3681 │ Polygon(154 Points)   {EFDCBD26-CDDB-4473-A3C1-99A8A2E…  {DE07FAC7-0F77-4532-9108-4937B92…  real         nein     4535        0
 3682 │ Polygon(263 Points)   {B795120E-A64F-49EA-8E20-43DE201…  {A0524DD2-E5A6-4505-BCFE-89FB912…  real         nein     6956        0
 3683 │ Polygon(373 Points)   {76D8012E-BAF8-481E-8A4A-9C2EA70…  {5DA85827-F855-4F19-860A-4201CCA…  real         nein     6943        0
 3684 │ Polygon(322 Points)   {5F27DF51-09FE-48D4-BB1F-CD22585…  {3C89756E-00D7-4C86-9D23-CD936B2…  real         nein     8615        2
 3685 │ Polygon(183 Points)   {3A2C6BBE-E738-47FD-94C8-90609C7…  {89D9124C-BFE2-40DC-957D-7E726C5…  real         nein     4124        0
 3686 │ Polygon(150 Points)   {BCE9D09F-6D2B-48EE-A3C1-E14E679…  {55EAD33E-66CD-42E9-8551-70F50BC…  real         nein     2717        0
 3687 │ Polygon(309 Points)   {9546660F-24E5-4978-B586-677EAC1…  {752C29D4-3EC4-485C-B39C-AA8EF16…  real         nein     9057        2
 3688 │ Polygon(122 Points)   {FB70CECD-F0CE-48F7-8272-4D0F3FA…  {74E61E99-52E2-4268-B4E9-7F17290…  real         nein     1566        2
 3689 │ Polygon(293 Points)   {E68A0594-F4DB-4D2B-8D26-EB47A2B…  {BB517988-68D5-4A6B-AF68-7D3B480…  real         nein     9062        0
 3690 │ Polygon(595 Points)   {3EA6A302-B74A-4DC6-9777-6C32462…  {69FCBC8F-CB5F-4FB9-A02C-BA3285C…  real         nein     1225        0
 3691 │ Polygon(679 Points)   {C6E950F0-905E-4EC8-B824-847AD49…  {F2CA659E-A804-475B-82E8-D2AD797…  real         nein     1804        0
 3692 │ Polygon(596 Points)   {96FAF391-761B-4F53-89AE-90BEEBA…  {8B3AB8A1-CF9D-4480-A880-38644DA…  real         nein     6867        0
 3693 │ Polygon(282 Points)   {1AEE3A07-4FED-4FC8-97D8-574C14A…  {729512CF-EFAE-4655-8C8A-7880C19…  projektiert  nein     7187        0
 3694 │ Polygon(149 Points)   {235394A7-D390-4A42-AD55-4DB78E4…  {3B39022C-2C29-46D8-B5DF-C74C587…  real         nein     8564        6
 3695 │ Polygon(195 Points)   {9E304FA7-FFE6-4EEA-87AB-895175E…  {08DA9198-EA73-4561-B045-092ADB8…  real         nein     1966        3
 3696 │ Polygon(25 Points)    {F078DC15-647B-45C4-B402-3389715…  {C43DE7D5-A40B-4E51-9205-EB8DC05…  real         nein     7744        0
 3697 │ Polygon(402 Points)   {7FBEFA38-F5C3-4D59-B59A-015A1CE…  {AA969551-3F9A-4D79-B2D3-24DA677…  real         nein     8118        0
 3698 │ Polygon(540 Points)   {9BECAA8D-10A6-4129-92CD-FF5A1B8…  {CD41CCF5-F395-48DB-BFCD-A0B4680…  real         nein     1470        4
 3699 │ Polygon(227 Points)   {D8DCDAF0-79BF-4915-8EA5-C536456…  {A8A8E804-67BC-47F6-8ECA-465E9D5…  real         nein     5053        2
 3700 │ Polygon(366 Points)   {8F690D33-C7B9-4180-8CDA-FFF0BA3…  {F1744356-8FC7-4815-8EA0-06E72E0…  real         nein     5022        0
 3701 │ Polygon(377 Points)   {F2E639BC-C368-4BB8-B899-5459D9B…  {702B8799-485B-491C-9A51-6224A9A…  real         nein     8564        5
 3702 │ Polygon(254 Points)   {9D76792B-F91D-41DB-8B88-950B2FD…  {1A72EC60-B097-44B0-BA8A-D176A81…  real         nein     1993        0
 3703 │ Polygon(188 Points)   {75D93A23-8357-4A87-A2EB-DE47FAE…  {2C45BF3A-D6C2-456A-AAD2-8D0DC1E…  real         nein     8582        0
 3704 │ Polygon(239 Points)   {F11A0DD8-08D9-4417-BF6D-938C403…  {B7CE4E84-286B-4178-A644-7845D45…  real         nein     1534        2
 3705 │ Polygon(164 Points)   {9530C3F0-F8A1-4014-A455-8501EDF…  {541DAAA3-8083-434A-9E7E-193B4D8…  real         nein     2052        0
 3706 │ Polygon(137 Points)   {56568E99-9B99-4E3F-A44D-5B8F576…  {72EBAC96-17CB-4DBC-83D1-CC5F0A9…  real         nein     6978        0
 3707 │ Polygon(70 Points)    {6E3BE409-0CC7-4F5C-BC9E-4CA6B93…  {F2B5C0EE-57A9-4B7E-838C-852B155…  real         nein     3971        0
 3708 │ Polygon(628 Points)   {47FE36FC-179A-4479-8624-1C878C7…  {C2212BD8-CC09-4150-ACAC-8E306FF…  real         nein     8482        0
 3709 │ Polygon(481 Points)   {7991ECD9-A59D-4091-923B-B9FA0F9…  {F23B2B64-022B-4BA4-9533-DB4D50B…  real         nein     9532        0
 3710 │ Polygon(257 Points)   {F5EC8401-A7F3-4D00-B6EC-685D7FD…  {26F101D1-6062-497D-8C0C-A05A2C9…  real         nein     1219       12
 3711 │ Polygon(462 Points)   {D1E9870A-DB12-4ED4-B329-04C8979…  {2D873C04-4F82-4294-B2CF-9ECD4AD…  real         nein     9470        5
 3712 │ Polygon(292 Points)   {90B0EE9F-653A-45E9-B29B-F1F8680…  {EDFB9967-9546-420A-BC5B-4F04566…  real         nein     6952        0
 3713 │ Polygon(248 Points)   {509E7F5A-FB0A-42CA-8F51-DD23EC0…  {D0DB367A-1016-4808-84B6-6F4A238…  real         nein     3421        2
 3714 │ Polygon(279 Points)   {1ADC13EF-3158-4F9F-B6B6-B6BE816…  {EE0E3945-7CD0-4C9E-89C6-E5C4C95…  real         nein     3206        1
 3715 │ Polygon(371 Points)   {037EB98A-64AE-4631-8550-EE1E2FB…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3013        0
 3716 │ Polygon(204 Points)   {657F789D-5799-4534-AF3B-3D5DA8F…  {229DB21D-300B-40BD-B461-AFAAAE6…  real         nein     1376        3
 3717 │ Polygon(90 Points)    {276B103A-6FA8-4AE2-B50F-7051916…  {A6065FEE-A09B-4B94-8E47-CD7E794…  real         nein     1608        0
 3718 │ Polygon(23 Points)    {5C948F8E-4D6C-4C1C-A54B-2D6F070…  {A997BF49-F62B-40F4-91EA-4D1E3D4…  real         nein     7226        2
 3719 │ Polygon(140 Points)   {FDEAB4D4-F93D-44F7-A4CE-4FC8E0C…  {6996A891-8CE1-4981-BED3-F0FB350…  real         nein     3931        1
 3720 │ Polygon(196 Points)   {6099BEA5-A2A5-4094-9D42-3223EFF…  {360BAA16-B52F-4C9B-AC10-2CF8C23…  real         nein     8412        1
 3721 │ Polygon(161 Points)   {030DA402-C14E-4D81-8FE6-378771A…  {7DAC14BE-22F9-4E8C-B96C-2FF0FEB…  real         nein     9245        2
 3722 │ Polygon(411 Points)   {C756CA66-EFC0-47E6-B1E7-8BB2C0C…  {1B2D9A8D-3666-4B86-AA7A-5E71395…  real         nein     6927        0
 3723 │ Polygon(240 Points)   {0D3091FF-2F8D-4BD9-BE5E-476744D…  {B737A4DD-E4B5-40B6-914F-9F15EA8…  real         nein     7421        0
 3724 │ Polygon(77 Points)    {EBAF7F5D-AE0D-4595-8CC1-43A10EA…  {94E5D61C-32E0-4C47-9276-D0E0061…  projektiert  nein     6549        0
 3725 │ Polygon(84 Points)    {B5A6F1D1-875F-435A-B8EC-D7B6895…  {ADB86394-A1C9-4D76-B626-25052E9…  real         nein     1912        4
 3726 │ Polygon(335 Points)   {84642FE5-1C97-4A9D-B725-B83BBFD…  {B2DC0782-7019-41D6-A3CF-A8C78DF…  real         nein     8954        0
 3727 │ Polygon(130 Points)   {F6C2618E-6B5A-4DE7-96DD-2AFB255…  {994F2B2A-1D52-43CE-A0A5-D49DB02…  real         nein     3456        0
 3728 │ Polygon(211 Points)   {53E8DE4A-C527-45AC-9832-355D16F…  {C017F76A-698B-4A1D-ADB3-7EF2340…  real         nein     3128        0
 3729 │ Polygon(145 Points)   {4E6B969F-BB4C-4711-96BF-79DDDEB…  {517B5E6E-192D-4D7D-867C-38BDEF7…  real         nein     6038        2
 3730 │ Polygon(260 Points)   {B015B2F0-B8C4-4A6A-90FD-427A288…  {70D13601-C1E9-4749-83DF-E157D6E…  real         nein     8471        2
 3731 │ Polygon(196 Points)   {DA0CDDC5-9911-4506-93BC-9076FBF…  {9E6AC62F-6333-424E-B2DE-7EF5D49…  real         nein     3206        2
 3732 │ Polygon(279 Points)   {002D0ED8-66D1-4647-B514-D72F1FE…  {2BBCD493-1A9A-41D9-83C4-690F048…  real         nein     8614        2
 3733 │ Polygon(213 Points)   {6F07680E-03F4-45DA-A47E-BEC2048…  {B17B452E-6CE4-4F9D-A65F-05945F2…  real         nein     3421        0
 3734 │ Polygon(144 Points)   {CBF5EE76-1071-4641-B560-43F7BE3…  {48C92BDE-432B-4051-92F5-B7F3CF8…  real         nein     8586       10
 3735 │ Polygon(276 Points)   {AEA893F9-0516-4BDC-89C8-0C83CA5…  {85CE3152-8C47-48CC-A5BF-EBB2D64…  real         nein     2575        1
 3736 │ Polygon(198 Points)   {87AD93E5-E7D3-42FE-8A6A-00E60A6…  {A8771D6F-BEB6-4E2A-B8EB-8D85B8C…  real         nein     3656        0
 3737 │ Polygon(179 Points)   {6CCA41FA-4868-40ED-B3F4-7E732C4…  {7F246CA2-B753-4D4D-98E6-CA3EA61…  real         nein     3042        0
 3738 │ Polygon(156 Points)   {2340AFDF-19F4-407F-AC1E-5CF721A…  {72E84DD6-C8B1-4927-8ED2-51C9C0D…  real         nein     1975        0
 3739 │ Polygon(185 Points)   {D13B95B6-88B9-4CEB-B0ED-26B1B03…  {F3D1D69E-57C1-4C92-A5C8-A2EB1E8…  real         nein     5524        2
 3740 │ Polygon(147 Points)   {1B7876B7-C165-4EFF-9D6D-1A96835…  {57AF1967-0640-4AC8-B4EA-D08603C…  real         nein     3629        3
 3741 │ Polygon(313 Points)   {6A4DF118-B90D-49C1-A1C1-8D12ECF…  {FE752CC3-EB5A-4BA0-A787-AF30905…  real         nein     1407        2
 3742 │ Polygon(142 Points)   {38B5DB23-9F42-4D09-AD8A-50FA5E0…  {1C47652A-A368-43E6-A454-7E0109D…  real         nein     1443        2
 3743 │ Polygon(91 Points)    {3D6BF0FA-C7A0-45B8-B942-E18FF59…  {15E3A67B-D0D4-4BFE-82B4-194CE5B…  real         nein     2075        1
 3744 │ Polygon(510 Points)   {E0DFA603-CB53-4A86-ABFB-F5CFDDA…  {63E72167-74A9-4509-BA87-3554FE6…  real         nein     1000       27
 3745 │ Polygon(659 Points)   {7BA8E8D1-B96F-43D7-B4D6-8FE2E2B…  {F2284573-3A20-4E3D-AC8E-6F284DA…  real         nein     9426        0
 3746 │ Polygon(279 Points)   {E9C09ABD-5CED-4CA1-9D71-E60C538…  {E441BBC2-6CAC-45EE-9CD5-9190DB1…  real         nein     8580        5
 3747 │ Polygon(187 Points)   {AAE8AE68-8248-420C-B3B7-44B33DF…  {E3768DC6-7451-4CB2-8C27-245B70C…  real         nein     9249        2
 3748 │ Polygon(360 Points)   {AD7CD8E9-E91C-46ED-936A-F073925…  {14F9C48D-89E0-4DC6-939B-45E7B1C…  real         nein     3095        0
 3749 │ Polygon(571 Points)   {9842476B-C280-4D56-84A3-C5C60D7…  {71268A29-9692-4B55-833F-ADCF871…  real         nein     1820        0
 3750 │ Polygon(415 Points)   {BB2FDEB4-FFDD-405D-9DED-41FECF0…  {1E5F3C0E-728B-488F-8652-D7AAC64…  real         nein     1128        0
 3751 │ Polygon(69 Points)    {F0996A1D-BD82-476A-B9A0-AE97C7D…  {6A6D12BE-6584-43C3-A447-D59B081…  real         nein     1922        1
 3752 │ Polygon(292 Points)   {30A1EA60-CC2B-435E-AC80-43D5995…  {00FF6DD0-A34F-4591-8338-2A89F05…  real         nein     1791        0
 3753 │ Polygon(123 Points)   {A3D82754-DCE0-44AF-AB4F-6731A9A…  {AFB22232-AB22-438A-9CFA-2B54637…  real         nein     3983        0
 3754 │ Polygon(124 Points)   {7692A68D-A09D-4014-A0BB-DDA54F3…  {453032AC-560F-4F18-81A7-19A9B6E…  real         nein     1585        2
 3755 │ Polygon(140 Points)   {594DAA5C-C2ED-4484-93B9-7AC02C5…  {53CF88B7-0792-45DC-8ECD-57846F9…  real         nein     2037        2
 3756 │ Polygon(529 Points)   {61363B61-F95B-43CB-87E7-22107B3…  {046AB9DD-7A9E-4BD9-BC19-30C8A78…  real         nein     3048        0
 3757 │ Polygon(284 Points)   {95C5B3D1-F929-4D33-9C33-C89AB88…  {A241EC03-0F1D-4040-BE77-1286426…  real         nein     3206        4
 3758 │ Polygon(253 Points)   {DFA3DBB8-2497-4A1D-AA30-07C3FCF…  {72E86434-28AC-4A5F-AEB5-92D1E2A…  real         nein     2063        4
 3759 │ Polygon(336 Points)   {99C2E25A-2183-4E95-B895-ECCC7D1…  {272482E0-8C95-49F8-9300-726DA31…  real         nein     7130        2
 3760 │ Polygon(471 Points)   {C252050D-B2E2-418E-9097-7320AFF…  {D619D8C9-5791-4A0A-8027-C6B5CDB…  real         nein     6962        0
 3761 │ Polygon(255 Points)   {E5455B34-7054-4F97-AA1B-EB388A5…  {FD9C8DAB-ACB8-4E35-908F-ACA9BCB…  real         nein     5058        0
 3762 │ Polygon(365 Points)   {84F31AFF-7EC0-4D29-8A96-EFD3B81…  {FA2EFD60-6975-413E-90AC-7AE0F91…  real         nein     1041       26
 3763 │ Polygon(140 Points)   {D232AEC5-F926-4117-A380-01AC349…  {1EF9708A-C9B6-4B10-95DE-ED126EE…  real         nein     3971        1
 3764 │ Polygon(413 Points)   {3F3B2985-627C-4F1F-8AA1-485BCDA…  {78E1F989-C854-41E8-BD2C-B3D0726…  real         nein     6925        0
 3765 │ Polygon(451 Points)   {43B57C7C-C1F2-485A-828B-14319E7…  {3086E198-C97D-41E9-8001-1165A2E…  real         nein     6992        1
 3766 │ Polygon(288 Points)   {E8A0AEB6-C228-4371-82F9-DB6971E…  {58812EBC-DEC6-47FB-BD41-BD4146D…  real         nein     6998        1
 3767 │ Polygon(129 Points)   {2D49A520-B44A-48AF-916D-C570E2D…  {52B0F7FF-F949-4CAD-9C40-344673B…  real         nein     1914        2
 3768 │ Polygon(236 Points)   {6C0C2A10-B4FA-43B9-A9B2-8DACE70…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1208        0
 3769 │ Polygon(114 Points)   {EB377525-FFEE-4651-83C3-B07BD1C…  {6F33384A-265F-4FDD-A2D2-02577F7…  real         nein     1996        3
 3770 │ Polygon(141 Points)   {6D1CF4EC-8414-4DC4-8633-346EFDD…  {A16ED3B3-4DAC-4987-B884-CAC883E…  real         nein     1663        0
 3771 │ Polygon(302 Points)   {5DDACA16-7D51-4C41-8851-0FBFFC8…  {F94AE2F8-C45B-435A-954D-94F119E…  real         nein     5733        0
 3772 │ Polygon(106 Points)   {7B9EC7C2-43B8-440B-9F63-A5AD049…  {CB4DD56A-5BBD-4EB5-B595-F3BBF6E…  real         nein     1727        2
 3773 │ Polygon(65 Points)    {C8518B11-29EE-426B-87F3-B5511B6…  {51828B34-4AAD-4A93-9A16-B3493BC…  real         nein     1932        2
 3774 │ Polygon(371 Points)   {8DA69445-686F-4B50-96EF-F598652…  {B880C625-80E2-49D9-9E56-53530D1…  real         nein     4566        0
 3775 │ Polygon(192 Points)   {AF075D24-57C1-4A97-8D1C-D6BBF35…  {4781FD74-8D3C-400C-B055-4CACEA8…  real         nein     5406        2
 3776 │ Polygon(271 Points)   {F991F118-BFFF-4205-A187-D467BE3…  {4E1FF7A9-DE62-4A35-A695-BFEDA92…  real         nein     3307        0
 3777 │ Polygon(115 Points)   {911DD7F4-A772-4A21-A81F-DC8C3F5…  {0C83A825-B26D-461C-939D-8BEEBAA…  real         nein     8564        8
 3778 │ Polygon(404 Points)   {68C5AD7B-0D19-411B-8F8A-2B820EB…  {521194B6-47B9-4806-94ED-24CBC11…  real         nein     1484        2
 3779 │ Polygon(243 Points)   {67672F65-9889-4F65-BEB8-C934585…  {D1400EA8-2818-41C2-B33B-8D4B046…  real         nein     1723        3
 3780 │ Polygon(139 Points)   {4F6E36B4-C235-4EA3-AD58-4DB776C…  {6A2D8388-1993-4EDF-B6CE-B022655…  real         nein     8525        2
 3781 │ Polygon(362 Points)   {3191A75D-3250-4A85-AA5C-375208A…  {6726354D-64E8-4C77-BAD6-5972DAD…  real         nein     1880        3
 3782 │ Polygon(263 Points)   {A7DFFCF4-5B97-4745-8C66-B0E21AF…  {EC8E4C6A-1175-46CD-B3BB-8ABEB93…  real         nein     1993        2
 3783 │ Polygon(79 Points)    {CDCC5442-E94E-471F-89B7-106A2CA…  {AAD2044B-6E07-4DE2-9BF4-B1939C0…  real         nein     3960        2
 3784 │ Polygon(374 Points)   {493E1FD3-79B9-4CED-8740-29D5707…  {8D969192-A67F-463F-BF48-82C96EE…  real         nein     6944        0
 3785 │ Polygon(706 Points)   {1B72233E-F3F2-4D1A-9465-FE1F71C…  {7BFAC753-C939-4EF9-AF45-A9ECAED…  real         nein     4112        2
 3786 │ Polygon(123 Points)   {15A3ED2E-132A-41F8-AF22-ABA3595…  {60529D10-076B-47C9-8079-07C70ED…  real         nein     4584        3
 3787 │ Polygon(263 Points)   {C19438EE-C41B-4B51-B313-0EA0E60…  {6257E652-EDBF-4B5B-9AAB-4A657BF…  real         nein     6983        0
 3788 │ Polygon(128 Points)   {51538960-3D63-494B-BBD6-FFC9BD6…  {DAFC45F1-8635-42EA-ACB0-C047BF3…  real         nein     3286        0
 3789 │ Polygon(165 Points)   {27309F15-BFBE-477E-BFD2-993A8E8…  {A47E73B9-5B0E-4B91-BDEB-C88EFDE…  real         nein     1096        0
 3790 │ Polygon(165 Points)   {58945318-A4C5-4C1C-B98C-AD1B4E3…  {3C002A5C-C3C8-4218-B827-62FD1E2…  real         nein     1219        0
 3791 │ Polygon(151 Points)   {E27E14A8-3570-4AA3-8B23-0101B92…  {5D7B4001-AAF9-4A30-904E-87B2A8A…  real         nein     1670        2
 3792 │ Polygon(180 Points)   {3D367D5E-04A6-4FF4-9C6D-DD16E3D…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1209        0
 3793 │ Polygon(437 Points)   {3DF379E7-89C0-40F8-9E93-01A6074…  {C345B884-322F-404E-A877-34CB030…  real         nein     1966       11
 3794 │ Polygon(303 Points)   {A1DEC098-6CAD-42BF-B28F-D042BD2…  {E0316FAC-58FD-484A-B2C5-6D8F872…  real         nein     1091        1
 3795 │ Polygon(94 Points)    {3A6051E6-25A0-48CA-B1B9-D0D23BC…  {4111E13D-50BD-4A32-8E08-103F1A4…  real         nein     7414        0
 3796 │ Polygon(266 Points)   {4E70DBAC-4BA6-447A-AC09-8DDF161…  {08437C3A-AFC7-446C-BE03-43DA59A…  real         nein     9503        0
 3797 │ Polygon(141 Points)   {DF7CF4B6-1BBE-4A52-BBA9-6AD74E7…  {612EAE96-6A79-4E34-9E85-BAB6248…  real         nein     3053        5
 3798 │ Polygon(354 Points)   {8FA41502-C572-4976-9563-9EB3EEE…  {A7A211AA-7E4F-4DA8-8C2E-CD3DF50…  real         nein     6951        8
 3799 │ Polygon(192 Points)   {B485758E-7FAB-41D7-AB55-6A00C25…  {CC225689-F2ED-4EC7-8379-CC88AED…  real         nein     1513        2
 3800 │ Polygon(149 Points)   {3F45247D-9C7E-4BE9-B20A-AA9572D…  {2D3684AE-8DD7-4879-A4C2-C47290C…  real         nein     8242        1
 3801 │ Polygon(150 Points)   {D6C4DB5B-816E-4EA5-85EE-99535DB…  {2F700FA9-43AF-412A-B5FB-1210325…  real         nein     8246        0
 3802 │ Polygon(119 Points)   {AA82E9A1-5725-4149-91FD-3EE540E…  {942880BA-B314-446B-8B49-E1A0C75…  real         nein     1283        0
 3803 │ Polygon(344 Points)   {079942D1-6A4E-4FEA-B44A-D5E378A…  {6B1C11B1-03BB-40B7-9A27-71013E3…  real         nein     6913        0
 3804 │ Polygon(171 Points)   {A42AE5D1-36C0-4DB0-A358-14C77E2…  {81BD1866-AF5D-48E9-9554-0013C5E…  real         nein     1782        6
 3805 │ Polygon(132 Points)   {4FF8F6F1-523D-42B0-B983-F84FC41…  {33FCE218-D977-4532-900C-0483BD8…  real         nein     8556        4
 3806 │ Polygon(167 Points)   {2F62B0A7-AD7E-4E13-B6C8-0C6048B…  {E034CEAF-AC5A-4C39-ABD3-9FBEAC3…  real         nein     3475        1
 3807 │ Polygon(189 Points)   {4A1AA595-2A90-4A49-A1AB-D722399…  {3996E028-10CD-453A-9A0A-8EBAFE7…  real         nein     1608        2
 3808 │ Polygon(182 Points)   {167F6B9D-B2A0-43C1-984C-F5DF956…  {6F01B048-1848-47B2-9F91-57938B7…  real         nein     5012        3
 3809 │ Polygon(256 Points)   {5608FA98-FE82-46BA-9241-EBD448C…  {66192B62-DB0F-41BE-BFF3-A7CC30D…  real         nein     6854        0
 3810 │ Polygon(277 Points)   {DD8B16C3-E203-4FB7-885B-BA15A28…  {E5A9C01E-D030-4DF9-B201-D56A90B…  real         nein     1955        2
 3811 │ Polygon(365 Points)   {A7EBEA2A-4A37-47D9-90DF-5238078…  {20BC90DD-0E57-45D8-A09D-3869451…  real         nein     2036        0
 3812 │ Polygon(136 Points)   {5F93B860-0225-478E-9486-25E0543…  {606393FD-65D7-4EEF-BC01-AEDEC20…  real         nein     3656        1
 3813 │ Polygon(190 Points)   {FCD92B26-C08D-417B-BA31-68AB7AB…  {151355AF-FF7D-4971-8833-B1DD4B4…  real         nein     2063        0
 3814 │ Polygon(189 Points)   {261213E7-42AA-40D3-BAF1-21AB04E…  {6733EFBA-C91E-45FF-8D85-D410B67…  real         nein     4554        2
 3815 │ Polygon(60 Points)    {44BACA8B-E544-47A0-B71B-0B3EE01…  {392DD723-58F4-4F75-8700-A929654…  real         nein     3280        4
 3816 │ Polygon(191 Points)   {5DFDCC99-9C38-4C0C-ADD0-F59DED8…  {5DD4E8EC-8D70-4AD1-B33B-5317B0B…  real         nein     1724        3
 3817 │ Polygon(166 Points)   {D8D893E7-B82C-4EB9-9FE3-05671B2…  {C44028BE-1F8E-463A-AEC1-481907A…  real         nein     5643        0
 3818 │ Polygon(579 Points)   {7BBB6F33-5041-4B8A-9525-2493D54…  {CD2AAF13-C68F-4916-8143-2459916…  real         nein     1127        0
 3819 │ Polygon(201 Points)   {6F802331-3E9E-4E80-9DEC-6B1B582…  {AFD234BD-11DE-4DE1-9417-69A6995…  real         nein     1595        2
 3820 │ Polygon(369 Points)   {F90A4B60-8C9F-420D-B69B-744C61D…  {4AE7AFD9-7858-45F9-A639-62B92FA…  real         nein     6993        0
 3821 │ Polygon(205 Points)   {3052F054-F8A4-48DB-BE58-8FFE84E…  {B699D195-30D9-42BE-A19C-87F701C…  real         nein     6289        2
 3822 │ Polygon(138 Points)   {A3E55D49-C2F2-4AE0-93CC-C88A1CE…  {E0DD1DFC-B0F3-4A5C-B0AD-EF196BA…  real         nein     6817        0
 3823 │ Polygon(210 Points)   {AE4DC93C-1FB2-45E7-807A-E08E100…  {0F75AFFA-26EB-4FA4-83BA-E53F37A…  real         nein     8926        2
 3824 │ Polygon(491 Points)   {67FB2792-39C4-4B34-80FA-6C3C491…  {D07796C0-7E9B-4705-81EB-443F7DE…  real         nein     6917        0
 3825 │ Polygon(565 Points)   {D82CB56F-4D12-4239-A69F-9C70013…  {F22BF6B3-23F5-4F3D-AB3A-91629D5…  real         nein     6980        0
 3826 │ Polygon(323 Points)   {276F586C-6893-4048-8A73-D453E49…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3011        0
 3827 │ Polygon(325 Points)   {D4A29ACD-4C6A-41BA-892E-29D4CDA…  {667309EC-8B7F-466D-9FE1-17F80A1…  real         nein     1093        0
 3828 │ Polygon(715 Points)   {694A8ABB-7133-44A7-B062-733688E…  {99FFDF48-6874-4031-9AB1-EEA7B45…  real         nein     6526        0
 3829 │ Polygon(95 Points)    {B9FB4239-D5F6-427E-8F6A-A7B7D72…  {70E13B2C-2D39-43B6-AEA4-0B6FD50…  real         nein     2075        2
 3830 │ Polygon(160 Points)   {9DD75EA9-2056-4C0A-B9CB-D5D5A9E…  {12A3C49C-4A02-41D6-B006-C812932…  real         nein     1607        0
 3831 │ Polygon(345 Points)   {DD307EE9-1855-4FB0-AA74-5621251…  {2BBB3F82-5B17-4A27-B7B6-0A2E4AC…  real         nein     6832        1
 3832 │ Polygon(352 Points)   {36546824-9223-4510-9D46-7659C65…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1015        0
 3833 │ Polygon(216 Points)   {AB4B5AB8-9718-4BE8-B7EA-493B8CE…  {7ACFAE77-BA44-4366-9387-B3C79EC…  real         nein     8152        2
 3834 │ Polygon(59 Points)    {21904962-BEC3-4AB1-B0F7-A147D45…  {719B355B-66BE-469C-9618-26783AD…  real         nein     1554        2
 3835 │ Polygon(93 Points)    {1F945970-219B-49D6-BC2F-7E308FE…  {12F2589B-7554-48C9-8C8C-A67A8CE…  real         nein     1994        2
 3836 │ Polygon(39 Points)    {4EA4E58B-C19F-410C-A5A8-9DA4CE1…  {A9A913D4-7671-4272-A3B4-2E15D29…  real         nein     1788        0
 3837 │ Polygon(150 Points)   {42C0A11A-0555-4842-BD23-B1ABF75…  {59B99904-3AED-4823-88EC-11FF240…  real         nein     1787        0
 3838 │ Polygon(172 Points)   {7AC33615-8803-4F62-896C-33A03E3…  {6BF5F735-D58F-4497-877A-690D3CD…  real         nein     4535        2
 3839 │ Polygon(171 Points)   {A667FB02-C561-497E-ACBC-C43A7CD…  {5E4AD1C9-8C55-43C1-B300-033B28C…  real         nein     1722        0
 3840 │ Polygon(105 Points)   {D3CF7A4C-9214-4EE1-BB23-6753A39…  {8DC5E50F-CA90-4510-8740-D41861E…  real         nein     6343        4
 3841 │ Polygon(74 Points)    {41D6A28E-18D6-420D-8663-B4417AB…  {A9400DDA-12CD-4DCE-AFD4-6981D03…  real         nein     8253        2
 3842 │ Polygon(347 Points)   {2DC2F438-327E-4CFA-A609-8D81E06…  {958A806B-D5AF-4E83-93F3-20B47F6…  real         nein     5736        0
 3843 │ Polygon(186 Points)   {F31642D8-5F09-4815-AC40-80967C9…  {2B3923D8-32B4-4583-9CBD-E62B0FF…  real         nein     8471        5
 3844 │ Polygon(53 Points)    {5908E008-7373-4127-92E8-38420C6…  {511BE6CE-173B-49B0-B668-7F36596…  real         nein     3976        0
 3845 │ Polygon(152 Points)   {FCB46C5D-6DDB-47B4-BC27-AA674D0…  {5DF8DDBE-8D41-42A3-8F30-F9E716E…  real         nein     1204        0
 3846 │ Polygon(109 Points)   {A64A99F4-183F-4BB5-BF0E-E195F9B…  {59FEC785-00D6-45B7-935C-38F1191…  real         nein     8586        9
 3847 │ Polygon(50 Points)    {AA9446C7-38E9-44F1-8FD5-06260CF…  {60204B30-9996-4DA7-8372-84D8A76…  real         nein     3983        5
 3848 │ Polygon(75 Points)    {F0FDD97A-9C83-4802-8A10-6B1BD1E…  {EBD2EBD6-DF86-4361-8520-FEE174B…  real         nein     1912        3
 3849 │ Polygon(250 Points)   {1A374C48-EE36-4A6F-899F-DBD822A…  {A35E98BB-44EC-4050-A30D-D0F6747…  real         nein     5415        1
 3850 │ Polygon(25 Points)    {69B8B70E-D85D-4C45-B0D9-E3604ED…  {CD566D7E-9A8D-485A-A40B-C740970…  real         nein     6805        0
 3851 │ Polygon(372 Points)   {912375DD-16C8-4E84-9471-62D8B4D…  {ECE61DF4-A0D6-4038-A100-CD30B5D…  real         nein     1071        1
 3852 │ Polygon(113 Points)   {BFE8E339-A69E-4818-AACF-6AEB9F9…  {0C4A0802-1165-4BAB-B2ED-2CF5136…  real         nein     1443        3
 3853 │ Polygon(1141 Points)  {CE44D381-0109-41FE-853F-E4A8DD3…  {9FA897F8-94ED-4525-9D89-2E60729…  real         nein     9320        3
 3854 │ Polygon(164 Points)   {B3DC0A5D-27CE-40B8-90C6-5FBFE3F…  {B893D510-6F4D-4F47-81EE-AC290E8…  real         nein     1227        4
 3855 │ Polygon(209 Points)   {ACBB57F1-9E25-4879-B35E-B1ADB5F…  {F4C052E2-CE72-4C90-9E4A-2790227…  real         nein     8546        3
 3856 │ Polygon(338 Points)   {7ABCEE46-2515-447C-965A-CC5739B…  {6E957F63-5676-48FD-9AE6-04426D5…  real         nein     1134        2
 3857 │ Polygon(279 Points)   {098A62E3-A68B-4AD6-A3F0-4DA3DB6…  {A69E11D2-FFFD-4E3C-86B5-2FF854E…  real         nein     9442        2
 3858 │ Polygon(169 Points)   {DF3E94A1-98B3-4A9C-9050-1CFBB67…  {D580FBBD-6490-4F23-B830-3D28F6B…  real         nein     9503        2
 3859 │ Polygon(393 Points)   {4FA06ACF-EF20-44E4-9500-70038CB…  {90D5CA5F-2DD8-4224-9FB4-95EE1D4…  real         nein     6991        0
 3860 │ Polygon(116 Points)   {7EBFC0AB-67E4-4F9B-8D8A-7011347…  {95DDA547-880E-4B08-A872-B327AA4…  real         nein     6919        0
 3861 │ Polygon(63 Points)    {1FA7EF8A-6A29-4FD9-856D-B1DD36C…  {0DF19E53-8573-48A8-AD9A-3604A78…  real         nein     1933        3
 3862 │ Polygon(105 Points)   {70745062-E548-420D-B293-2BC7290…  {7466F5C5-5360-4073-B68D-133B75C…  real         nein     3971        2
 3863 │ Polygon(186 Points)   {2543CA05-11CF-4310-AAF7-5D3053D…  {F36ECE10-E4E2-4912-A5A8-553DD7E…  real         nein     1996        4
 3864 │ Polygon(193 Points)   {294D6605-4C78-4BBF-905F-325C332…  {C49112D6-E554-4E51-BACB-B416FD8…  real         nein     6760        2
 3865 │ Polygon(41 Points)    {E51F6A64-3542-478C-826B-24A7C5A…  {0F4843D2-E38B-4E71-BE4F-EF6B930…  real         nein     3983        4
 3866 │ Polygon(448 Points)   {A0BAFB4F-2223-4F69-BCAF-7A4F602…  {321E1BD6-9849-40B6-B71B-CC4136E…  real         nein     6950        0
 3867 │ Polygon(65 Points)    {62AB336D-60B7-4F4F-8F3D-A5112F3…  {E20AF42C-1208-4D65-9E78-A215E08…  real         nein     1991        4
 3868 │ Polygon(80 Points)    {2961813C-F225-42AF-8F35-04C6AB7…  {6C326728-B52A-4C67-8CE4-C9CBDE2…  real         nein     8564        0
 3869 │ Polygon(228 Points)   {D9D2B311-7418-41C4-927C-4214CAE…  {A578C6E3-979E-4CBF-8C54-2C5ACE6…  real         nein     6863        0
 3870 │ Polygon(252 Points)   {586048C6-8FEC-4ED0-9616-AA62915…  {25128012-18FD-4E33-B0F7-EC15062…  real         nein     6900        9
 3871 │ Polygon(92 Points)    {FAEF1EAF-83A0-42A8-B547-94EB9D1…  {8ACD9A14-D334-4C1E-976F-7828E35…  real         nein     1992        0
 3872 │ Polygon(437 Points)   {4F5FDCAF-E3C5-43B5-BEA1-0444DF3…  {8831D959-F740-470B-AE25-0055337…  real         nein     1404        2
 3873 │ Polygon(240 Points)   {5B5A1BA3-4392-4C26-A0F6-B2DB973…  {43208096-8E79-4EC8-9856-371D757…  real         nein     1687        2
 3874 │ Polygon(200 Points)   {39CBCE72-E55C-4257-BC48-B3CF08B…  {E66BBB07-5CAB-414D-A773-77B647A…  real         nein     5017        0
 3875 │ Polygon(395 Points)   {E9263F39-A262-4B1E-9717-56E6C82…  {D6A08CFB-7A89-4DA7-BBEB-9C92CA3…  real         nein     6924        0
 3876 │ Polygon(271 Points)   {B4159544-8E51-404B-A222-1816E64…  {16146473-1ECD-4236-BAD2-B89A4DD…  real         nein     9405        0
 3877 │ Polygon(222 Points)   {DD77F06D-EC4F-44BC-B1BC-7E1702D…  {C5D1290B-D3F8-4F14-B92C-3F6AD6B…  real         nein     7424        1
 3878 │ Polygon(306 Points)   {BEC8E610-CAC1-4D7B-A9D4-451A3CE…  {657F4684-766D-42D4-AE42-BBE38B3…  real         nein     1063        2
 3879 │ Polygon(81 Points)    {56C6231D-49B4-4560-A61B-2411016…  {4F78C0AB-D35E-4B6B-B914-937E676…  real         nein     7058        0
 3880 │ Polygon(115 Points)   {BFBC0C56-121D-47C3-AFB1-9C67126…  {76B11CD5-9C67-4E1D-8211-F6052BD…  real         nein     7114        0
 3881 │ Polygon(720 Points)   {DDEF6E3D-586B-49DC-A55E-B90F231…  {E16DC378-BA93-428E-88E4-4EF4AE8…  real         nein     1816        0
 3882 │ Polygon(258 Points)   {C6D909F1-7719-4F03-B92F-D5C15D2…  {2D15F15D-9AE3-48CA-865C-A6452B1…  real         nein     1971        2
 3883 │ Polygon(152 Points)   {79DD738C-BBA6-42CB-AA0B-635D06D…  {709E4943-331F-452F-8379-BA1052F…  real         nein     8572        0
 3884 │ Polygon(361 Points)   {BA9B3117-6EE8-4E91-96DB-8B3D64E…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1003        0
 3885 │ Polygon(293 Points)   {83D874B9-8AF1-43ED-BBE0-78C9DED…  {8AD44281-8AC4-41B0-8F65-7FB13A4…  real         nein     5222        0
 3886 │ Polygon(316 Points)   {66FF63A6-9A35-4808-810C-7F1FC96…  {7E51EAF3-19E5-4B2E-A9DA-27DE505…  real         nein     1996        7
 3887 │ Polygon(492 Points)   {CC89724B-81B9-4F89-8218-AF6AC98…  {5FE1D143-D026-4764-BA6F-CDFC60A…  real         nein     7163        0
 3888 │ Polygon(161 Points)   {56FBC63B-F40E-4001-B995-FA5D859…  {7B6D1636-7F6C-4181-8F29-4D60353…  real         nein     6618        0
 3889 │ Polygon(60 Points)    {05A45ED8-8108-44A1-891C-5CE714A…  {285AB59E-A952-496B-8869-825496A…  real         nein     6410        3
 3890 │ Polygon(134 Points)   {99E88A1C-EFA7-42E4-AA18-2170052…  {9E32D37D-7090-4FB2-A3EF-148A616…  real         nein     1966        9
 3891 │ Polygon(245 Points)   {D941545C-D689-47B7-B7AB-28DC5D5…  {80DB7048-C1BF-40E1-8FED-65BB118…  real         nein     6957        0
 3892 │ Polygon(236 Points)   {06612D48-A0B3-46DE-BB00-F5DA3A4…  {2E834F2E-89D3-42AE-AAC7-1C40ABA…  real         nein     1184        1
 3893 │ Polygon(145 Points)   {0A919EA4-63A7-4EF7-92B1-57918A5…  {AC4E73C4-AB1C-4EA4-BF53-ACCAD55…  real         nein     7415        2
 3894 │ Polygon(64 Points)    {E1106B24-7116-4518-B72A-D01FA94…  {74E8C111-7F5F-428F-8424-49507AF…  real         nein     6410        5
 3895 │ Polygon(129 Points)   {D28D05FC-9AA1-40A2-8ED4-5240A94…  {9B9A7E7E-3608-4E1F-A9AA-FCEC36F…  real         nein     5012        4
 3896 │ Polygon(45 Points)    {CDE68552-BEE7-422C-A9BB-43FB367…  {BA01D204-6080-4840-84D4-17180CD…  real         nein     9479        2
 3897 │ Polygon(282 Points)   {A975EB03-B8C3-4A98-A87D-BBBB5D3…  {4FE156B2-FE4A-4BFA-A2CA-575B37C…  real         nein     6814        3
 3898 │ Polygon(89 Points)    {C09973F5-8DDA-4A01-8F89-02C15E2…  {FDD3E8DA-A6FE-44F2-A7EC-FC55507…  real         nein     1947        0
 3899 │ Polygon(320 Points)   {EEFA3B97-A930-4A7D-BBB9-CDCA7B8…  {78D8BB25-8CAC-4F39-B7F1-949FD4C…  real         nein     6942        0
 3900 │ Polygon(286 Points)   {B9A958C5-A7B7-42F0-B07A-5A1DA5C…  {6D22E0F9-1ADA-4D30-9AB6-B833817…  real         nein     6674        2
 3901 │ Polygon(232 Points)   {E59D98FB-AADC-458C-AB72-D6E69C4…  {284D5ADB-B6EC-49D8-BA83-A60C869…  real         nein     6959        5
 3902 │ Polygon(59 Points)    {70C711BB-A29C-4373-917D-66893DA…  {ABC360FA-6978-45C5-9557-B7C11AD…  real         nein     1966       10
 3903 │ Polygon(247 Points)   {1B7DBB33-EFC0-489D-8A02-E13F82A…  {777E08BD-EB54-42D5-B79F-F54A321…  real         nein     8546        2
 3904 │ Polygon(190 Points)   {AC6726A5-FC8D-48E2-9461-8F4C4F7…  {C524BB25-2495-4700-B221-9DBBBE7…  real         nein     1216        0
 3905 │ Polygon(274 Points)   {4B5536B6-E8F9-4AFD-8CF0-6EB627C…  {637585CA-AF16-432E-AFDC-6609B49…  real         nein     8121        0
 3906 │ Polygon(266 Points)   {8B296D52-9578-4AAE-99E6-5450089…  {B11F0438-BEC7-48D3-823D-C64CE32…  real         nein     6873        0
 3907 │ Polygon(23 Points)    {89A1D68A-8590-4C20-9FE8-80A8E6F…  {4DEA3726-8AB7-4D5C-9B2D-9273788…  real         nein     9479        1
 3908 │ Polygon(310 Points)   {3276783C-B54C-48C4-851C-3914E93…  {B86A150D-DBC3-48E4-8D9F-6F7BACB…  real         nein     6900        5
 3909 │ Polygon(126 Points)   {F2B674F0-A2D6-4803-BA9D-19E40EF…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3015        0
 3910 │ Polygon(89 Points)    {14C89B8B-B6DE-400A-A5F4-8F952C1…  {A20B3F4D-679B-4B9C-86EA-75EA9BF…  real         nein     7212        1
 3911 │ Polygon(171 Points)   {8E062521-AC76-4B06-A944-F88CBE9…  {692B237A-BB8F-481E-BF1D-0B0D7D5…  real         nein     4932        2
 3912 │ Polygon(98 Points)    {21B07D15-0208-4BE3-BE5B-82B28E2…  {8B5D28E2-B58C-4A91-8043-5892532…  real         nein     1624        0
 3913 │ Polygon(349 Points)   {D995F4CA-ABEE-4EA1-8D0D-D2D6F05…  {4659759B-54E2-4FA8-8B89-E44CA6A…  real         nein     2950        2
 3914 │ Polygon(56 Points)    {575208BF-C923-4B56-9259-4260CD5…  {6B6A7BC7-C73A-4967-916D-45AD99C…  real         nein     1945        4
 3915 │ Polygon(401 Points)   {C71133D1-7C15-495A-86D9-02C09E9…  {126A01A8-0E35-4D68-9F4D-A081444…  real         nein     3855        1
 3916 │ Polygon(38 Points)    {DD631485-E16A-4CC7-8A66-38007E8…  {FE1FD12A-7E89-445C-9760-D46B976…  real         nein     1966        6
 3917 │ Polygon(207 Points)   {38BDEC63-6EFD-4D6E-8765-0730BF6…  {7992DEF4-FF72-4A37-AFF7-943987F…  real         nein     6929        0
 3918 │ Polygon(386 Points)   {18C2DF61-E58D-42F3-8141-EFB494B…  {06B3AD1C-5364-44D5-974D-43588EE…  real         nein     6967        0
 3919 │ Polygon(247 Points)   {11109A8D-6653-41C7-B029-40DEE9C…  {9839237D-654F-45C7-BDE0-50D2B75…  real         nein     1809        0
 3920 │ Polygon(426 Points)   {AC36D7DB-F35F-4E23-B214-F17810C…  {393E31FD-4044-4792-997F-DDFF4C7…  real         nein     6597        0
 3921 │ Polygon(115 Points)   {A40F05E0-C471-404E-B53D-1510C9E…  {F7F6B280-EBF7-4DA7-9107-9194EC8…  real         nein     5412        1
 3922 │ Polygon(94 Points)    {2C553520-9E19-417D-B6AC-3082004…  {AF103272-8DAF-496F-9F89-686E738…  real         nein     6717        0
 3923 │ Polygon(27 Points)    {43C71984-927D-4CC5-9A85-4034A9D…  {22B14973-BA77-47C5-A7C1-1DC73B3…  real         nein     6441        2
 3924 │ Polygon(79 Points)    {879D277A-8F77-48A5-B183-B0B15FE…  {4CE3FECB-1B79-4E09-9E25-CFD6E70…  real         nein     2882        0
 3925 │ Polygon(199 Points)   {32E40FBF-6CB9-4236-B48C-BD1D856…  {D43F938B-8471-46C9-9D46-4965130…  real         nein     6963        2
 3926 │ Polygon(92 Points)    {61A399C1-600D-48D9-867C-9788B7E…  {4AE2D53E-CBCB-45C5-90D1-408FD36…  real         nein     3294        2
 3927 │ Polygon(327 Points)   {2D3A00EB-9B0C-4C7E-A1CF-6F4746F…  {6E64037A-009F-40B8-A919-02B8D0D…  real         nein     6981       16
 3928 │ Polygon(317 Points)   {8FE4EF1C-491A-417B-B8BE-E708905…  {0F3A090C-755F-4571-B0C3-49D093D…  real         nein     1996        6
 3929 │ Polygon(328 Points)   {765A292A-450F-45E9-8017-108C8C0…  {1E7AC97B-E9D1-4AE8-A24E-014B154…  real         nein     6995        2
 3930 │ Polygon(182 Points)   {A4CB189A-8AA2-4196-A66A-C8F695B…  {93ED972F-FD8E-4AFE-BEF2-AA0FFFD…  real         nein     5643        3
 3931 │ Polygon(268 Points)   {B9AD6390-FC1D-4248-BFDF-5678F0B…  {F1F4EA88-1867-4D74-A54E-AF3F5D9…  real         nein     6916        0
 3932 │ Polygon(348 Points)   {28C61974-92AB-4E3E-93FD-0F4522A…  {4C00DC77-4910-45D4-9517-83169A9…  real         nein     8268        0
 3933 │ Polygon(121 Points)   {1BE75A2D-73BE-4764-8596-23721FA…  {93359614-ADD3-43AB-ACB2-8393CAF…  real         nein     1423        3
 3934 │ Polygon(175 Points)   {ACC70D0F-422A-473D-87DB-9534D7D…  {E6705EBD-2D16-4B4B-9114-CB97E0C…  real         nein     3372        0
 3935 │ Polygon(255 Points)   {924060C0-D4B8-48B3-9379-DB7E5E3…  {D5CEB10D-08DB-4DA6-B91A-2ECE2EA…  real         nein     3422        2
 3936 │ Polygon(378 Points)   {9004D009-C7B4-4C42-9329-B4D405B…  {CBF266D4-E964-47E8-AF1C-DCE2276…  real         nein     1817        0
 3937 │ Polygon(242 Points)   {FEE331E3-4644-4979-912F-EA67BB7…  {E2CFEF56-A647-4F17-8907-1FFC89C…  real         nein     6600        2
 3938 │ Polygon(158 Points)   {31A17D0D-1EB2-496E-BBE4-9C542D2…  {18C7C1C0-2376-45D6-8EC1-D488FCF…  real         nein     5301        0
 3939 │ Polygon(442 Points)   {505FB141-92E7-4C9B-BA3A-7F7AD0C…  {E0136623-FFBD-416E-B936-7024B5C…  real         nein     6981       15
 3940 │ Polygon(195 Points)   {115D7A64-23E7-4418-9C85-AB2CEF6…  {C2C5A228-45BE-435B-B10F-8F0A569…  real         nein     1071        2
 3941 │ Polygon(160 Points)   {277BD5BC-11AC-4A05-AD4E-0BDA2BD…  {2F73FFAD-48C3-468A-8C68-3953B99…  real         nein     1423        4
 3942 │ Polygon(474 Points)   {561CBFC9-C9AC-416B-A86C-55402EE…  {B7DF6668-162A-4AC6-85F8-645375F…  real         nein     6977        0
 3943 │ Polygon(162 Points)   {566290F4-8A8B-4271-BECA-B715611…  {8C45D04A-223D-4F7C-98F6-7366291…  real         nein     2149        2
 3944 │ Polygon(212 Points)   {018683DD-D64F-4826-A725-2D42220…  {E5C2501F-A6D4-4E1D-B453-8C2CCFB…  real         nein     6915        0
 3945 │ Polygon(60 Points)    {CE42E568-5EBB-4FB5-A025-69451A0…  {67E16C94-F11B-474A-BCAA-C7BC00C…  real         nein     1941        2
 3946 │ Polygon(313 Points)   {E0848CBC-433E-43DE-9A56-8E78743…  {C784E2ED-4736-4329-B4AC-0014A8B…  real         nein     8122        0
 3947 │ Polygon(40 Points)    {F38B248C-76E3-4B39-AE67-06B38F0…  {57840B3C-0EE8-489E-AF87-57F76B8…  projektiert  nein     7552        0
 3948 │ Polygon(290 Points)   {916862D5-5D23-4598-B4CF-0CDAA55…  {759F96BA-987D-4BB0-85FE-B2B6AB8…  real         nein     6363        1
 3949 │ Polygon(432 Points)   {6D216143-240F-4AF8-B7A0-A212C88…  {3B8C463E-9992-47DB-9AA2-238C2E7…  real         nein     1820        5
 3950 │ Polygon(107 Points)   {A8B7B83D-C20E-438A-AB4B-053AAAE…  {95092404-3F13-4520-883B-2EC504A…  real         nein     1925        1
 3951 │ Polygon(81 Points)    {6FF2B149-8DF3-4D7D-BA61-3100C1E…  {467329D3-4F60-4209-A9BB-F0F0A4B…  real         nein     8572        2
 3952 │ Polygon(96 Points)    {65DC972B-356C-4E70-94E0-083FDAE…  {F63D0F5E-5FB2-4600-A2D8-3C261A7…  real         nein     4556        3
 3953 │ Polygon(61 Points)    {772D7A59-9826-48AD-B862-9AC94DD…  {21B8A222-1435-46BD-AE99-6D8739C…  real         nein     6656        0
 3954 │ Polygon(147 Points)   {B923CD68-565D-47AA-A2AA-8627636…  {115BC8BD-EF30-4DCB-BB2F-7371442…  real         nein     1626        2
 3955 │ Polygon(657 Points)   {01148414-F192-4D0A-B83C-62AF3D7…  {68D6DFFC-CE28-40B7-AA71-668DDFF…  real         nein     4421        0
 3956 │ Polygon(69 Points)    {A9566224-4520-4B83-AAAB-FD0B2B5…  {024390FC-5451-4983-BD70-AFEFA38…  real         nein     1912        2
 3957 │ Polygon(157 Points)   {5DEAA88B-2175-4C6C-9025-61AEAAC…  {B4826BFE-ECD6-43A0-8908-B976E61…  real         nein     1724        6
 3958 │ Polygon(79 Points)    {96F48754-309B-4782-91DF-CD4E5DE…  {510CCB28-31F3-4E46-8439-63D7032…  real         nein     6746        0
 3959 │ Polygon(76 Points)    {FCE10A73-7A92-4ABC-93DA-D247B6E…  {D1517F98-88FA-48C8-BCB2-99B92A2…  real         nein     8554        0
 3960 │ Polygon(554 Points)   {693667CE-762B-4139-ADA7-CC30938…  {3D084FF9-5A57-4356-B666-155DE99…  real         nein     1148        2
 3961 │ Polygon(222 Points)   {C2598A3F-2924-4A22-9AB8-4BA1B71…  {69C17D6C-6BEB-4619-982A-22A7909…  real         nein     9223        1
 3962 │ Polygon(101 Points)   {1E62A8FB-98CB-4D21-8BB3-9DCB7E9…  {17499B16-3BD7-40D0-B7EC-E51DC73…  real         nein     9565        4
 3963 │ Polygon(252 Points)   {B958334F-C80C-4602-B552-8BEEBC5…  {3DB7AC29-524D-43F3-AEDF-86BD89A…  real         nein     1094        0
 3964 │ Polygon(122 Points)   {A6061281-80FC-4C6D-9E2D-E26966D…  {C422A6A9-786D-4FAE-9D4F-A7CDBE3…  real         nein     2333        2
 3965 │ Polygon(383 Points)   {F75C7541-0F21-45B1-AF01-4CB04C6…  {A03DAC98-FE96-440A-8081-29FE6A9…  real         nein     1180        2
 3966 │ Polygon(22 Points)    {D544DE52-CF72-4E04-AA46-DB52DDC…  {DEDD3BC3-C7F9-4A63-ABB9-F927005…  real         nein     1969        2
 3967 │ Polygon(142 Points)   {5BDD5ABA-1017-4C52-BE94-BEC4C3F…  {06C573F9-2717-48C2-8AE6-08F36EA…  real         nein     3957        2
 3968 │ Polygon(218 Points)   {FBB5684D-EF11-49D3-B54C-5E6D543…  {10CD97E3-CBCC-471F-ADC7-ED5DD02…  real         nein     9030        3
 3969 │ Polygon(287 Points)   {9B856CED-2722-44D5-A7F9-2734ADD…  {E4C1FD66-DFD7-48BE-9699-317941E…  real         nein     8543        2
 3970 │ Polygon(306 Points)   {2EF5C875-4F39-4A9B-B034-DD2847C…  {1A5CD8A2-3C3B-4FA2-9C2B-F252DF2…  real         nein     6976        0
 3971 │ Polygon(16 Points)    {092E3D2F-2F63-4BED-B207-4076E3E…  {464CD913-6FFC-4DD2-A380-BFE0178…  real         nein     7445        0
 3972 │ Polygon(632 Points)   {C016A4A5-E8B7-4866-8060-B0986D7…  {333DB2D9-B5E3-482F-A135-E573D42…  real         nein     6959        0
 3973 │ Polygon(212 Points)   {F6C274D3-F77D-40D5-9B63-D71E25C…  {2E02BC55-467B-487E-AF85-171C6E2…  real         nein     6990        0
 3974 │ Polygon(37 Points)    {6AC5FFA1-99C6-4A25-AA9A-16A6737…  {1E82DD7D-F51F-427F-AB92-1D2AC61…  real         nein     7413        0
 3975 │ Polygon(24 Points)    {6533EFBB-C99C-4E93-BACE-35637B1…  {3A23B691-0E9B-44AE-B058-7D92AF0…  real         nein     1945        8
 3976 │ Polygon(130 Points)   {F007493B-5161-4B8C-9AE3-6E6FC7B…  {82A1E2B0-0A60-4772-80CD-5F0304E…  real         nein     3280        2
 3977 │ Polygon(122 Points)   {A2A18BF0-B0A1-40D6-809E-B0B14FC…  {00C7C860-6F77-4B62-99AA-5112B30…  real         nein     5233        0
 3978 │ Polygon(195 Points)   {6E21CCD4-6994-4336-9D3D-363705F…  {79F9E978-36AC-4E02-B4A8-4AC0515…  real         nein     6959        3
 3979 │ Polygon(360 Points)   {5401BAA4-47C9-4813-ADC2-7EA37D3…  {319B7A10-1AB4-40F4-8B8A-7666017…  real         nein     6955        0
 3980 │ Polygon(121 Points)   {36DAB7E4-925E-4E79-9EEF-2D2809A…  {75C5834E-FAA6-4BDE-BAEB-EB8176E…  real         nein     6383        4
 3981 │ Polygon(147 Points)   {D4C8306A-493A-49E5-BFFB-7C6B800…  {63248C02-BB76-4797-B3E6-061BE2C…  real         nein     6988        0
 3982 │ Polygon(247 Points)   {DDE03707-B027-416C-BA32-BBB919C…  {19586719-20A2-45BD-B60C-4851050…  real         nein     6575        0
 3983 │ Polygon(119 Points)   {FE744158-D4C1-418A-81CB-2F886D2…  {5B7030BB-0234-4837-9B2A-E16C29E…  real         nein     1787        1
 3984 │ Polygon(80 Points)    {F65B7BBC-B677-4254-9181-68475C1…  {BDE16F0A-41A3-470C-87C1-2812E59…  real         nein     1992        3
 3985 │ Polygon(101 Points)   {B4413CAE-11E1-4A89-8EF3-DC05529…  {7F319E1A-5CB5-4E5D-8E6A-CC16120…  real         nein     1966        8
 3986 │ Polygon(155 Points)   {0A305285-F3E9-4C6E-AB0A-4F419D6…  {3FAB59B4-EF57-4318-984C-64A6BA1…  real         nein     6659        0
 3987 │ Polygon(176 Points)   {CF96B766-397C-455F-8F0E-A044947…  {59379418-C116-4936-BBB8-ECBC077…  real         nein     6716        0
 3988 │ Polygon(157 Points)   {F0DBAED7-B950-4608-A72A-973E61B…  {8FD1CC89-FDA8-40AB-8174-96C3A2F…  real         nein     3917        2
 3989 │ Polygon(88 Points)    {64D7E8E2-F267-43AA-A21E-D9A05E3…  {465E4AF4-3EBC-4DCE-B99B-3AA8FD2…  real         nein     1945        2
 3990 │ Polygon(264 Points)   {0E93F07B-9898-4BC8-B869-8D03E53…  {4F0BD036-614E-4C9E-8D0C-306DECB…  real         nein     6363        2
 3991 │ Polygon(84 Points)    {6BFB9765-C22D-45C1-BB13-7A66369…  {6ED33BE1-A9D0-4589-8ABA-410F6EC…  real         nein     1955        4
 3992 │ Polygon(63 Points)    {F0DDB7D4-39FA-4525-A514-460973E…  {CC218190-5E6C-438F-A9DE-C78A3AA…  real         nein     8143        2
 3993 │ Polygon(139 Points)   {85F51B86-3A0D-4B03-B25B-95E2499…  {96D26224-4DCA-4B90-A9AD-DFA921D…  real         nein     3212        2
 3994 │ Polygon(249 Points)   {B47437D5-8C10-4D1B-8082-1575D1C…  {4F58ABEF-343A-4B22-BA3B-963BFA3…  real         nein     6974        0
 3995 │ Polygon(82 Points)    {D41CEB40-7A68-4406-9FF0-10E46DB…  {C4E3E72F-348C-4A4F-9248-BBF0856…  real         nein     6746        2
 3996 │ Polygon(95 Points)    {1C078090-2F68-4352-AF29-2098C05…  {07131388-B76B-4904-8A4F-E81311C…  real         nein     8274        2
 3997 │ Polygon(46 Points)    {80E3CBFD-DD1F-41EC-92CB-BD32089…  {5EDAC58D-708D-4D8A-B11D-0BDAC42…  real         nein     1991        2
 3998 │ Polygon(61 Points)    {77AD9C90-E077-49DA-A5DF-5C3DFCC…  {7ADB6C42-B165-4F8D-9BE4-F0CF82D…  real         nein     5466        0
 3999 │ Polygon(346 Points)   {CB8B3572-ED65-4657-9961-ADAC4C2…  {F17FAAEC-5870-454E-8E32-EADB80B…  real         nein     6613        0
 4000 │ Polygon(284 Points)   {BF0FDC8E-98BE-43A1-976B-67B3C3E…  {C2E008D3-4A9A-4255-A10B-59A73AC…  real         nein     6780        2
 4001 │ Polygon(34 Points)    {710921DB-EEEB-44B3-9CE5-7CCD5AD…  {A7884FB7-9E49-4456-921D-113B6AE…  real         nein     9476        2
 4002 │ Polygon(353 Points)   {19C3B4D8-5B69-46B6-B12B-C69688F…  {F4C88003-B1CE-4464-B7F2-7238C99…  real         nein     5415        2
 4003 │ Polygon(183 Points)   {5390C282-2D67-4C12-B62D-B967984…  {9EF68E55-6166-40DA-9AAF-EA0BED6…  real         nein     6955        1
 4004 │ Polygon(144 Points)   {8012233E-BE46-4579-9BFD-3DBA853…  {053A9154-A049-443A-B759-CA6D1A1…  real         nein     2535        0
 4005 │ Polygon(69 Points)    {F2470448-42BB-4291-8D18-084EC10…  {11EDC112-2A78-406D-8B33-067FFC9…  real         nein     1091        3
 4006 │ Polygon(12 Points)    {8E525309-C9E5-4694-8206-24E2C01…  {663791EC-41FE-4547-BDCF-88824B2…  real         nein     3823        1
 4007 │ Polygon(55 Points)    {073DE7AE-1583-4DE0-AB83-0FCF350…  {10D70840-DF58-42D5-A563-F77E75F…  real         nein     8135        2
 4008 │ Polygon(76 Points)    {2EACF20C-C988-4124-BF65-44B64A4…  {4F790BE3-A11E-4522-BAB2-2E23828…  real         nein     1096        2
 4009 │ Polygon(60 Points)    {D35E4306-0290-4933-9EF5-861F098…  {B42582B2-DCFF-433D-87C0-4AE6CE7…  real         nein     1992        2
 4010 │ Polygon(134 Points)   {AD3503D2-8219-4274-AD85-CD90B7B…  {7B28F13F-EECC-44CC-AE0F-BF1D9E5…  real         nein     4588        1
 4011 │ Polygon(193 Points)   {AD33E774-299B-4229-B6CB-AAA3504…  {A9025C14-5127-4B0A-A1A3-18DA221…  real         nein     6958        2
 4012 │ Polygon(62 Points)    {19A64C28-E1FE-421C-A4A7-6017CCC…  {72990958-4872-4C1B-8169-8337749…  real         nein     7212        2
 4013 │ Polygon(57 Points)    {B0AFE19C-1EE7-4CD5-A8CF-062F2EE…  {038DFC8D-DBE8-44A5-B1A8-1F57BE2…  real         nein     1966        4
 4014 │ Polygon(24 Points)    {CC8FE5C3-02C7-451A-815D-41E5A12…  {FA009F9E-E974-4156-8408-11BC2E1…  real         nein     1991        5
 4015 │ Polygon(162 Points)   {8D45380B-4ADA-4258-A4DE-EFCADCE…  {93C770E6-61FE-414B-BCFD-3113744…  real         nein     8208        0
 4016 │ Polygon(31 Points)    {0AA656B8-852D-4E0A-BB7B-EB26D10…  {04832127-D421-49E9-A91F-C7F1518…  real         nein     1945        6
 4017 │ Polygon(58 Points)    {26B61DE0-9DB3-4D05-B8B4-DAA6A07…  {1A43A0BC-1910-40E5-80A8-0F72680…  real         nein     1991        3
 4018 │ Polygon(52 Points)    {CC44CA07-8102-4F34-9F17-4A06DE4…  {464EF710-7944-42DB-A456-7285A0E…  real         nein     1220        0
 4019 │ Polygon(104 Points)   {18426AA0-4E71-4442-B0FC-D93A85F…  {09AE2DB8-6D46-4E95-8005-BD2DA50…  real         nein     8212        4
 4020 │ Polygon(166 Points)   {F423C448-DC05-48B3-A15D-24037EE…  {6A98E946-6720-4717-98AA-51CFF79…  real         nein     5004        0
 4021 │ Polygon(137 Points)   {A53C1451-4DF6-4F40-9263-D7DF264…  {659DE919-4671-4540-BF88-2D5D2C2…  real         nein     3960        5
 4022 │ Polygon(77 Points)    {84954E9C-3D74-4625-97DB-EB5E475…  {8DB65111-AAC5-4986-B0E2-15D9665…  real         nein     9532        0
 4023 │ Polygon(67 Points)    {C67F9F70-9979-4B66-AAAA-C51C519…  {A3E6027E-E7D4-433F-BD86-FA329F7…  real         nein     3010        0
 4024 │ Polygon(30 Points)    {5A56EBCA-34AC-4F94-9676-68AC6D9…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4052        0
 4025 │ Polygon(105 Points)   {6662E567-BEAB-4980-9A74-D911870…  {ECC79FD0-4475-42AF-B13A-1D4DB04…  real         nein     1585        3
 4026 │ Polygon(102 Points)   {9EB843A9-593D-455D-A41B-377D2EB…  {DAECE6ED-BDD5-41AB-A042-D42A66D…  real         nein     3922        1
 4027 │ Polygon(116 Points)   {2CDA2006-BC0D-4B72-B2F3-E0998AB…  {29AEAEF1-D043-4130-AFD0-57206C9…  real         nein     6039        0
 4028 │ Polygon(103 Points)   {3B66C907-906C-4B17-9E24-BBA10ED…  {0F4DAADB-6812-4FDC-8BCE-7B47027…  real         nein     2807        1
 4029 │ Polygon(82 Points)    {7A4F7412-78C5-4084-9764-09297AB…  {F7DE1EB7-7FA5-4B5F-869F-5DB76A6…  real         nein     3907        3
 4030 │ Polygon(50 Points)    {CE6FE417-D2CD-40EC-A111-1A0AB6A…  {3C34FCEE-8BBC-4431-A66A-82128E9…  real         nein     5404        0
 4031 │ Polygon(104 Points)   {1A06684B-CD4A-48F7-B2EC-9C4406D…  {81BCE9BE-F688-49A0-B74D-BD0BD2A…  real         nein     6959        5
 4032 │ Polygon(129 Points)   {231EDADD-7F07-4347-95D9-F860EB4…  {4F227954-093E-4BCA-82C0-35D64BD…  real         nein     4615        0
 4033 │ Polygon(23 Points)    {250DB61F-7435-486F-9972-7ED7D0F…  {6FD7F449-5CEA-4760-9CB7-7BF6101…  real         nein     4101        0
 4034 │ Polygon(41 Points)    {1165B4F9-CE9E-41DA-88E5-E11E43F…  {2D554EB8-9D2C-4432-9CD5-9F35D98…  real         nein     6981       11
 4035 │ Polygon(9 Points)     {FA3ACA1F-DAB6-4A7F-A268-248F8D9…  {0C2F2A05-90B4-40C7-AA57-7DC1E36…  real         nein     3860        2
 4036 │ Polygon(75 Points)    {C4AF21D0-B90A-4151-9081-B3FBEDB…  {75FE8838-F64A-4DC3-9B21-44D060E…  real         nein     1011        0
 4037 │ Polygon(23 Points)    {DF0FBAF9-1E6F-4F85-9D4F-8276879…  {09D98613-AE9B-428F-A40A-E1D41DF…  real         nein     3976        2
 4038 │ Polygon(27 Points)    {1DCA0E39-0A2C-49D4-B1DE-D1FDCA2…  {B2FF23AC-E4FC-44A5-9A7C-45F96A5…  real         nein     3812        0
 4039 │ Polygon(138 Points)   {2F3D1C87-1F86-4F9C-8199-7B92112…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4001        0
 4040 │ Polygon(25 Points)    {F8EBE5F1-A2C5-4722-9DDB-CCA9AB4…  {F8E83653-0E70-441F-9C41-A568CF9…  real         nein     3823        2
 4041 │ Polygon(18 Points)    {AA301FE4-BCD9-4E79-9003-A927A55…  {37B227FD-E06F-400C-8118-C4C54E7…  real         nein     4524        3
 4042 │ Polygon(8 Points)     {D3708ED5-222E-498C-9D12-8FFA751…  {83947DBD-8789-45EF-8087-502416E…  projektiert  nein     7743        2
 4043 │ Polygon(47 Points)    {7312A853-5E3C-4556-B651-2BBABDD…  {B94D6EB2-AC01-45A4-A736-22B8664…  real         nein     9411        0
 4044 │ Polygon(60 Points)    {FBC654EE-A9CF-471B-AA23-5FF33BE…  {97D4242C-8830-49ED-BAD8-6590416…  real         nein     8832        0
 4045 │ Polygon(80 Points)    {5BC4974B-7EA4-4E91-9472-C51F568…  {9A2B5125-7F4F-4729-B391-C8B8571…  real         nein     6951       20
 4046 │ Polygon(32 Points)    {BF0BDE75-1912-4A44-925B-5F63B69…  {519E5910-9C1A-443C-917F-7ABBDDE…  real         nein     6010        2
 4047 │ Polygon(9 Points)     {91BBA199-EBB3-4270-AD86-3F3A0B3…  {574F7361-7BD5-44E3-926B-CEB56A3…  real         nein     3801       33
 4048 │ Polygon(55 Points)    {3769A5A8-DA93-4702-8070-85E9FF1…  {B86001A0-DAD3-416B-8CDC-005474A…  real         nein     6614        2
 4049 │ Polygon(39 Points)    {24BDF23C-840A-4604-871E-6C8F703…  {AF363EED-5CDB-498B-AB83-16FD426…  real         nein     8109        0
 4050 │ Polygon(26 Points)    {92B837E5-AEF0-4C3F-8D5F-9D14F37…  {4179A984-E94F-4629-955E-106EC77…  real         nein     6825        0
 4051 │ Polygon(2816 Points)  {B8833F24-000E-4687-9EE9-F98E96B…  {61EADDA7-BC66-4F34-B18B-84B0237…  real         nein     9497        0
 4052 │ Polygon(1302 Points)  {799D2C5F-4D16-4825-88F4-999F3D8…  {D110F81B-F764-462E-9C42-213190B…  real         nein     9495        0
 4053 │ Polygon(864 Points)   {F49FEAB8-77CB-4C74-BC7B-F5E000A…  {0F9FCE42-7BEB-464C-B1FE-E910565…  real         nein     9490        0
 4054 │ Polygon(450 Points)   {7EA990CA-FF91-4646-BDA3-008C084…  {42EB3AC4-C506-45DA-8FAA-90478B2…  real         nein     9496        0
 4055 │ Polygon(487 Points)   {AEF89EAC-B35B-43B3-883A-F542269…  {C34ECF7E-4B30-4A91-B205-393E842…  real         nein     9493        0
 4056 │ Polygon(406 Points)   {09AF8B18-790E-455F-9C43-FAA3550…  {37E35F88-8E71-4019-87AC-ABCAEBB…  real         nein     9487        0
 4057 │ Polygon(595 Points)   {FAFC917B-AB77-4C09-BCB4-9512F22…  {BDD37866-6547-4E78-8C3E-E3142B3…  real         nein     9486        0
 4058 │ Polygon(543 Points)   {D64D7B0B-F29D-4AFC-A93D-0DAAF48…  {B7035263-FBA4-4137-8EEB-7C15FF4…  real         nein     9488        0
 4059 │ Polygon(453 Points)   {D9AFCA13-F126-4409-BE92-35706D9…  {8742327F-80C5-46CB-992B-B56B241…  real         nein     9491        0
 4060 │ Polygon(1037 Points)  {A98B7EB7-262E-47C9-A158-CD6F825…  {5437B95A-8963-4F42-A351-A5457CD…  real         nein     9494        0
 4061 │ Polygon(604 Points)   {573CF298-0718-43CF-ABE1-4B2EAF6…  {741A02BE-C8C3-4FB8-9B77-1850535…  real         nein     9485        0
 4062 │ Polygon(701 Points)   {E7A5ECD9-0EB8-4CD6-9A67-9F40D23…  {A51E39B1-E7A1-4BFA-A049-9F286E6…  real         nein     9498        0
 4063 │ Polygon(367 Points)   {6B09EE94-4839-4A3B-A3B1-B7B6808…  {50DC73C8-FFD6-42DF-A2E3-03E129C…  real         nein     9492        0
 4064 │ Polygon(283 Points)   {2B13C5F5-709F-479A-940E-53C8AE9…  {6944F04D-E688-45F2-9AC6-92A8501…  real         nein     9533        1
 4065 │ Polygon(448 Points)   {E7F6F5BB-2663-45A6-98CF-C1F1FB2…  {D3B2FCE4-D779-46B8-986E-1B323C0…  real         nein     8862        0
 4066 │ Polygon(389 Points)   {C14706DE-9944-4A74-9A2B-DD160F0…  {3FF11B18-DCFC-4CE9-8171-8E91D8C…  real         nein     1148        9
 4067 │ Polygon(185 Points)   {8EB76A03-A1C3-4A9D-8C5C-D53C48D…  {F2FCFCE4-6304-4DBE-81BE-F06243B…  real         nein     8596        1
 4068 │ Polygon(129 Points)   {284DBC82-C73D-4DDF-A216-5F7C291…  {43F64440-2DD8-4FED-8064-547F1CE…  real         nein     1892        1
 4069 │ Polygon(226 Points)   {A49DA2CC-3201-4985-BB50-748F65B…  {8C519850-A731-4F2F-96FE-A4DF300…  real         nein     3075        2
 4070 │ Polygon(26 Points)    {5568DBC1-DD53-43F5-9BC8-66DAE4E…  {8A95FDAD-7394-4C6E-BFC3-D1352E4…  real         nein     1774        0
 4071 │ Polygon(285 Points)   {D81093AE-A7A2-4C40-A16E-BDB2773…  {9BB41B3B-BC53-4F3C-AA94-0305612…  real         nein     8574        2
 4072 │ Polygon(320 Points)   {E49EDD41-A47B-48FD-B75D-8A18F38…  {B3D80A32-3BE2-4D56-8CFC-C0D5C2F…  real         nein     8574        3
 4073 │ Polygon(156 Points)   {DA26E3EC-9F78-4001-9952-C4CD1DD…  {1AEAC4AF-3449-49B2-8A0A-90788C7…  real         nein     8574        4
 4074 │ Polygon(656 Points)   {A4B71077-4784-4B45-A6BE-60FF6D8…  {F2A13981-400F-4E88-9230-E5D9951…  real         nein     8623        0
 4075 │ Polygon(359 Points)   {962EC495-8C4D-4192-A515-20697E3…  {9996E4A2-AD7E-43C2-8B78-5ADAFE7…  real         nein     8155        1
 4076 │ Polygon(268 Points)   {9228BC56-6DD5-4B3E-805F-40FEC64…  {D003B2D4-7AAB-4B5A-A4D6-1DED7FC…  real         nein     1783        0
 4077 │ Polygon(49 Points)    {9ACB82A1-6B3F-4118-8D55-438A745…  {4241DDD8-9EC6-4FCA-BD2B-452A9D7…  real         nein     3961       27
 4078 │ Polygon(384 Points)   {07F5FF9B-8260-4BD5-B6CA-6B93429…  {95E0C671-3F7E-40B7-8088-353DCBB…  real         nein     6300        5
 4079 │ Polygon(426 Points)   {BF5AC0A6-A6B4-435E-A4B9-543217A…  {49F9F3DA-351C-47D2-B50D-2FFB4A0…  real         nein     1985        1
 4080 │ Polygon(42 Points)    {069B03CD-C456-49DB-B3E7-ECE67E2…  {003F9D30-760A-4F7D-94EA-3BD7376…  real         nein     1984        1
 4081 │ Polygon(91 Points)    {5F91FE71-C9DA-4942-9C51-9F563EA…  {E2AA5B22-39BD-4E44-B747-1CA064C…  real         nein     1985        2
 4082 │ Polygon(27 Points)    {FA27DC9D-82BF-4DC8-995A-FD7D6EE…  {DF180D3F-7B66-4100-80B6-BD3027B…  real         nein     1345        1
 4083 │ Polygon(1021 Points)  {E401E3F3-AAD8-4934-BF41-3DAE510…  {52C1D8A7-E615-48A8-9575-3C9F798…  real         nein     5225        1
 4084 │ Polygon(219 Points)   {0DB58294-9164-44B7-B4DA-C5DCCA0…  {5855645D-4C76-47B8-BBEA-78E6D9D…  real         nein     8522        2
 4085 │ Polygon(249 Points)   {32E2FF65-1EB9-4665-A611-9FC0D1D…  {0029033F-4F2C-469E-BCBE-53564A3…  real         nein     8580        8
 4086 │ Polygon(102 Points)   {1832A458-2CC6-48C7-8179-248C7E2…  {0546F7F7-D062-4093-A861-E871558…  real         nein     6875        3
 4087 │ Polygon(233 Points)   {05E98D84-4807-4196-8CDF-7DCB674…  {0DA6810D-A7DE-4AB0-B67A-C7D611B…  real         nein     6005        2
 4088 │ Polygon(32 Points)    {EF0A3CA6-8B4D-487F-9937-26BDFEF…  {2E8F8B45-84F9-4426-9D7F-FE0A2B4…  real         nein     6314        1
 4089 │ Polygon(1896 Points)  {DDF07753-36A0-4700-8E95-7CEF889…  {347DE0AA-D84E-4CC5-A5E9-BDCB962…  real         nein     8489        1
 4090 │ Polygon(531 Points)   {0BCB826F-835A-46E1-984A-415AEE9…  {65B8A26D-A1FE-4DC6-AD81-F16EE13…  real         nein     8489        2
 4091 │ Polygon(554 Points)   {6C22A874-0E00-45C1-9505-38BC3DE…  {ECFB9DBD-F2AB-4DAB-B220-CEF285E…  real         nein     6584        0
 4092 │ Polygon(56 Points)    {AC0604A9-8F9F-4CDF-BE7F-A2ECFBB…  {7197604C-B714-4CEE-965F-291EBEE…  real         nein     6807        0
 4093 │ Polygon(141 Points)   {AF666347-0B5E-40C8-B84E-15E2CEC…  {3D2F73AB-640F-4025-9523-95DECAA…  real         nein     6721        2
 4094 │ Polygon(177 Points)   {34FF9EA1-8D9E-4B8C-B72B-1DF1709…  {FAB87A7B-5C51-4217-B17A-01D25AE…  real         nein     6954        1
 4095 │ Polygon(29 Points)    {CE28F86D-038B-4E0B-AFA6-28AFE39…  {93B6D42B-ABEC-4B4B-BF60-5ECC77E…  real         nein     6600        0
 4096 │ Polygon(601 Points)   {A4A987AD-71E6-46F6-BB34-32D86F2…  {388788FA-2B95-4F09-A060-B24C4B0…  real         nein     6951       17
 4097 │ Polygon(764 Points)   {96DCEC01-C1E9-4C7F-BD6B-18517AB…  {5EFC0AE5-B1B2-4BE2-8FD3-560C942…  real         nein     6951       23
 4098 │ Polygon(422 Points)   {1ED8B19E-90EA-4E3B-8C56-D34294E…  {B20CEAFB-B567-4874-8915-B109831…  real         nein     6583        0
 4099 │ Polygon(260 Points)   {AB584AD4-ECA9-49FE-9E68-5A6AC1E…  {CDC71A9E-D998-4230-9FAE-A902FA4…  real         nein     7606        0
 4100 │ Polygon(131 Points)   {41C25902-CBDE-4A4E-88F3-128F8A8…  {6F0E72D5-1C2F-4551-BDB7-4D04DDB…  real         nein     7450        0
 4101 │ Polygon(638 Points)   {39EC3371-DE2E-4EE2-81E3-9A96126…  {59BC90DD-325F-4655-9C0C-A812541…  real         nein     8354        1
 4102 │ Polygon(69 Points)    {5277D2E6-1A0B-490E-95BF-26B9C6C…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4031        0
 4103 │ Polygon(40 Points)    {3FA96699-8649-4B76-9B16-96DEC42…  {E63DBC8A-F548-4AC1-A58C-4824598…  real         nein     4031        0
 4104 │ Polygon(6 Points)     {E17C393A-09F0-41B6-947A-F00F7DA…  {D210AAE4-71A1-486E-8ED5-5E37F50…  real         nein     7323        0
 4105 │ Polygon(221 Points)   {E557705F-F610-4AA8-8762-0083007…  {398E8F0D-4AE3-493B-A0E0-CF554EB…  real         nein     3907        2
 4106 │ Polygon(159 Points)   {02CDFA45-E265-4B92-85DE-C27FB4C…  {3F943713-D4D1-4D43-9AC3-B953109…  real         nein     6875        2
 4107 │ Polygon(322 Points)   {DCA8FC24-0ABA-49F5-833E-65FD394…  {777EE800-5CEB-42CA-A7C4-70BDF00…  real         nein     6872        0
 4108 │ Polygon(580 Points)   {C8754FCE-6E83-4F07-A7FE-6481412…  {58C46623-F622-43C0-9599-5E07C81…  real         nein     6548        2
 4109 │ Polygon(364 Points)   {C29740C6-BB22-4B87-BBED-6057C1B…  {4F33B78A-3DD7-424D-B127-1AB3E34…  real         nein     6548        0
 4110 │ Polygon(52 Points)    {F6CB33A0-C7F1-4117-A0BC-9021DF3…  {93F02C23-6604-4262-9EEE-9010241…  real         nein     8214        0
 4111 │ Polygon(247 Points)   {EC14910D-7CEC-4C25-9CDC-257733A…  {5BEB4BED-F01B-4A8D-8299-53D8D02…  real         nein     1997        2
 4112 │ Polygon(241 Points)   {F54433E5-F612-459B-B567-17AC06D…  {CBFD16F0-45D7-4B24-8635-B8D3B29…  real         nein     1868        0
 4113 │ Polygon(159 Points)   {090EE2CF-9D3D-4A93-907A-D7E263F…  {C35F4123-EDAF-43FB-8C72-777B4DB…  real         nein     8217        0
 4114 │ Polygon(149 Points)   {724290A1-3568-4E5F-9831-C29047C…  {EE53627E-3D2B-4317-9D54-D894B90…  real         nein     1624        3
 4115 │ Polygon(45 Points)    {8ED6EFE3-B5E7-474A-837A-FA40CA3…  {919B4C05-722B-4EB3-8709-B8DF6B3…  real         nein     3098        0
 4116 │ Polygon(68 Points)    {57464BA5-339A-4A49-9E00-8A1AAC2…  {761F2849-8DF6-464D-981C-6EA4056…  real         nein     9500        0
 4117 │ Polygon(864 Points)   {E4F99947-AD90-4CA6-9F9E-EC8BD23…  {B8B6B581-D4CE-49A9-A1DA-3089E77…  real         nein     9500        0
 4118 │ Polygon(541 Points)   {EF1022DD-D19F-400B-B65A-0895B64…  {EA1BEE98-F8EE-42EA-A693-F24FAA9…  real         nein     1298        0
 4119 │ Polygon(178 Points)   {7D3425A4-F87D-45AB-9831-B5696F3…  {9459A0F0-3D8B-4B5C-B8A9-7131674…  real         nein     1298        0
 4120 │ Polygon(776 Points)   {FC1A11CA-C6CA-485F-956F-A5EB042…  {BDA2ACF0-3F38-4933-AD7D-D2B52A5…  real         nein     2300        0
 4121 │ Polygon(66 Points)    {D4048F8C-0479-45D3-9553-52CCBBF…  {1EC960A2-5986-450C-AA43-83FD8C4…  real         nein     6313        0
 4122 │ Polygon(827 Points)   {0AB97003-6629-4E93-B5B2-AB8C301…  {D20971C9-2923-445E-BEA8-F83AC5C…  real         nein     7526        1
 4123 │ Polygon(252 Points)   {DF720422-C5F3-42F6-9C13-D434DEE…  {A6F11AED-D238-44D0-9210-BF68BB0…  real         nein     6981       17
 4124 │ Polygon(288 Points)   {951C66A5-4E99-4087-AE41-B8CC02A…  {40AA2284-65A6-4EBB-9856-B778CDB…  real         nein     1473        0
 4125 │ Polygon(390 Points)   {6F875E75-47D2-4B08-A597-5D0FAEA…  {4185A10F-0BA3-489C-83BF-E404196…  real         nein     7558        0
 4126 │ Polygon(655 Points)   {FE2BE876-09FD-4775-852F-40DA73A…  {7663A02D-9483-4622-86EA-07391CD…  real         nein     1168        0
 4127 │ Polygon(263 Points)   {93E1E5B8-A8AA-4E33-8910-142D4A0…  {EFA501B5-F577-471A-B98B-75F67D5…  real         nein     3963        5
````

### Shapefiles polygons

Shapefiles contain polygons, the can be accessed with:

````julia
shp = Shapefile.shapes(tab)
poly = shp[1]
Rasters.GeoInterface.coordinates.(poly.points) # points in a vector
````

````
1772-element Vector{Vector{Float64}}:
 [610633.000637002, 92967.9998220417]
 [610689.999482635, 93038.00055941255]
 [610714.9999329178, 93055.00018438045]
 [610808.0003180628, 93137.99970688463]
 [610845.000076477, 93177.99978026106]
 [610970.0004049705, 93294.99922514522]
 [611060.0000279214, 93370.00061304876]
 [611110.0004670394, 93420.00002301199]
 [611204.9997126252, 93473.00028182767]
 [611310.0010980745, 93555.00001271587]
 [611389.999658313, 93633.00024862512]
 [611404.9999881758, 93654.99974162901]
 [611459.9994730565, 93703.00022256702]
 [611530.000143625, 93777.99924652459]
 [611543.0003916891, 93802.99973315239]
 [611552.9993490846, 93872.99961526787]
 [611553.000272549, 93945.00033546194]
 [611560.0005349099, 93969.99971289547]
 [611577.9998287697, 93993.00027048626]
 [611592.9997837035, 94027.99989351901]
 [611613.0008614891, 94093.00090763945]
 [611643.000059764, 94153.00005366374]
 [611668.0001351173, 94182.99980865674]
 [611697.9994869633, 94203.00055460558]
 [611745.0007984075, 94223.00060992787]
 [611780.0004267991, 94233.0003468339]
 [611853.000195581, 94234.99969519865]
 [611877.9999919273, 94240.00020013333]
 [611928.0002962381, 94260.00031002847]
 [611970.0004753727, 94285.00032436088]
 [612003.0001085203, 94295.00002486937]
 [612037.9994484761, 94315.00086180324]
 [612107.9992726737, 94349.99948565075]
 [612153.0008772521, 94360.00040457163]
 [612283.0004816471, 94363.00080016731]
 [612362.9999454047, 94374.99937592213]
 [612390.0003043844, 94395.00006729821]
 [612415.0005239415, 94419.99977227786]
 [612484.9995405452, 94483.00067620006]
 [612530.0008567704, 94502.99969511988]
 [612568.0007087537, 94504.99940659791]
 [612638.0008883821, 94493.00056036477]
 [612655.0007037811, 94497.99991971508]
 [612634.9998190136, 94565.00022592317]
 [612634.9993769744, 94615.00072603818]
 [612639.9996440951, 94640.00006708155]
 [612658.0004476584, 94680.0007947414]
 [612665.0001332342, 94724.99937220557]
 [612689.9999778369, 94763.00020722245]
 [612694.999533365, 94777.99944822438]
 [612687.999973193, 94797.99952090239]
 [612689.9993916228, 94817.99975733529]
 [612705.0002888422, 94855.00040039822]
 [612653.0001052374, 94935.00025434542]
 [612618.0005927954, 95025.0005176793]
 [612620.000722847, 95054.99985414151]
 [612617.9996316561, 95093.00019782108]
 [612628.0001658652, 95142.99987991237]
 [612642.9992072925, 95175.00047292926]
 [612663.0004293392, 95234.99943701991]
 [612657.999864415, 95254.99954607364]
 [612638.0000467537, 95284.99948220998]
 [612649.9999222666, 95323.00008066572]
 [612652.9993383186, 95343.00033529552]
 [612645.0005786679, 95369.99945979999]
 [612634.9997183731, 95470.00027806]
 [612649.9991541703, 95523.00008112403]
 [612693.0000330908, 95593.00056377698]
 [612742.9994145274, 95644.99999372572]
 [612762.999271049, 95682.9997377492]
 [612800.0006833668, 95734.99993118175]
 [612829.9997374055, 95800.00012722761]
 [612837.9997089563, 95835.00062288961]
 [612832.9992017135, 95853.00071193936]
 [612818.0008047685, 95868.00058904981]
 [612765.0000655816, 95897.99992466695]
 [612740.0005481846, 95918.000669807]
 [612777.9998139289, 95975.00093141354]
 [612843.0001214546, 96062.99999441138]
 [612863.0000068131, 96099.99972843302]
 [612895.0008159407, 96208.00039100714]
 [612900.0002178116, 96263.0010321169]
 [612919.9995746412, 96353.00029625108]
 [612917.999484062, 96494.99968018463]
 [612924.9994579909, 96530.00015764953]
 [612948.0005957526, 96558.00085627133]
 [612974.9999547611, 96578.00054761716]
 [613005.0004508642, 96592.99924355418]
 [613027.9993773203, 96663.00036223899]
 [613044.9999719767, 96745.00049179317]
 [613064.9999150204, 96780.00020580726]
 [613102.9995174204, 96860.00069747643]
 [613113.000484269, 96894.99922953025]
 [613120.0000255873, 96944.99985702429]
 [613164.9998226551, 96983.00005597303]
 [613220.0007595618, 97050.00072698061]
 [613219.9998943695, 97080.0000270304]
 [613212.9998150646, 97118.00027974318]
 [613213.0001805687, 97140.000499804]
 [613222.9994934524, 97163.00091181851]
 [613252.9998453517, 97182.9996577653]
 [613245.0009991501, 97212.99981228368]
 [613242.9999273999, 97284.99949603535]
 [613259.9997239169, 97360.00055556626]
 [613277.9995569405, 97503.00031344173]
 [613293.0010215489, 97555.00110655211]
 [613332.999676936, 97632.99961457282]
 [613344.99958129, 97670.00020302682]
 [613355.0004521623, 97743.00011518454]
 [613363.0005102317, 97775.00058084077]
 [613383.0000206649, 97825.00044488382]
 [613398.0009661947, 97894.99941800884]
 [613395.0004447708, 97947.99989353864]
 [613402.9998489327, 97968.00023915336]
 [613409.9999094087, 97999.99968660426]
 [613418.0000640156, 98097.99981241275]
 [613453.0008365818, 98103.00049933576]
 [613485.0002702227, 98120.00025166449]
 [613568.0004095657, 98142.99999205806]
 [613652.999428794, 98169.99980883533]
 [613784.9997400544, 98182.99934085422]
 [613829.9993446374, 98193.00025973884]
 [613873.000809797, 98208.00019226334]
 [613908.0001497817, 98228.00002918883]
 [614050.0001005991, 98217.99951311153]
 [614102.9994166045, 98167.99997741931]
 [614167.9999830805, 98142.99991016768]
 [614194.9999282996, 98108.00005140081]
 [614237.9996912705, 98078.00053379544]
 [614253.000318937, 98055.00057670612]
 [614243.0004098234, 98018.00002464611]
 [614245.0009242002, 97999.99988100522]
 [614249.9994891286, 97979.99977191516]
 [614277.999864584, 97929.99978131622]
 [614312.9998484639, 97893.00004812128]
 [614353.0007721937, 97823.00007584767]
 [614404.9993119071, 97799.99979199863]
 [614447.999209653, 97800.00057446974]
 [614463.0009432816, 97807.99992746842]
 [614500.0008552956, 97808.00060075751]
 [614522.9993197386, 97790.00083921732]
 [614544.9994210547, 97750.00083945572]
 [614553.0000365262, 97728.00076498906]
 [614570.0005729143, 97708.0008742993]
 [614594.999744248, 97699.99924917033]
 [614625.0003074033, 97677.99957503776]
 [614642.9999279397, 97654.9996725212]
 [614695.0010155933, 97613.00019868396]
 [614717.9996819211, 97588.00036713002]
 [614728.0001772738, 97570.00036906515]
 [614740.0005907734, 97520.00008731411]
 [614787.9992741903, 97422.99999050955]
 [614820.0003517225, 97383.00017273614]
 [614842.9999603649, 97360.00036120445]
 [614864.9998309844, 97327.99944144992]
 [614889.9997138529, 97329.99991637889]
 [614923.0000585894, 97349.99971692485]
 [615020.0002900228, 97437.99936223052]
 [615065.000452591, 97497.99978123623]
 [615079.9994940183, 97530.00037425333]
 [615104.9995693755, 97560.00012924644]
 [615163.0001913253, 97603.00061478018]
 [615195.0006249908, 97619.99936711512]
 [615298.0003800854, 97620.00024139805]
 [615363.0003697478, 97615.00037418514]
 [615425.0002800215, 97613.00048238343]
 [615550.0002712648, 97602.99965696072]
 [615603.0004336375, 97593.00052138246]
 [615642.9997040508, 97615.00046929314]
 [615694.9994844765, 97653.00079562081]
 [615727.9995408346, 97682.99969617793]
 [615785.0002516847, 97723.00013350882]
 [615850.0003667255, 97782.99991645014]
 [615904.9995920683, 97839.99948739345]
 [615933.0009486659, 97860.00019698472]
 [615973.0004209642, 97875.00007488181]
 [616067.9999643856, 97882.99988359227]
 [616199.9996411507, 97917.99963565386]
 [616293.0002181362, 97925.00039799493]
 [616339.999817992, 97935.00035326507]
 [616340.0009433412, 98000.00100344559]
 [616343.0005613357, 98012.99918804146]
 [616358.0001795772, 98024.99958101966]
 [616405.0004910217, 98044.99963632754]
 [616424.9996359219, 98073.00028032182]
 [616473.0003066099, 98163.00030346368]
 [616533.0003141306, 98220.00022864625]
 [616592.9995888824, 98238.00106623521]
 [616655.0011198825, 98250.0003505445]
 [616808.0008694357, 98294.99984998033]
 [616908.0002302469, 98349.99944225287]
 [616992.9993215328, 98383.00013143248]
 [617044.9995269829, 98425.00035443652]
 [617095.0001899173, 98444.99995189482]
 [617184.9995162504, 98395.00054896226]
 [617253.0010528682, 98380.00060355454]
 [617367.9999589156, 98374.99992654109]
 [617428.00005512, 98385.00047261086]
 [617520.0003560556, 98427.99957616394]
 [617548.0001594118, 98452.9998363394]
 [617623.0003670311, 98502.99976237153]
 [617699.9994976927, 98538.00033371727]
 [617782.999891623, 98585.00089209934]
 [617828.0004392569, 98615.00066199616]
 [617857.9999636647, 98650.00025529852]
 [618000.0001867122, 98754.99996949664]
 [618027.9998650508, 98765.0005430198]
 [618123.000628644, 98812.99954583622]
 [618149.9991302214, 98817.99931620421]
 [618175.0008515128, 98842.9996635453]
 [618188.0004000022, 98868.00099940247]
 [618213.00002679, 98888.00062350518]
 [618250.0001726206, 98877.9999818189]
 [618298.0003925617, 98920.00006775973]
 [618523.000272712, 98973.00011056414]
 [618489.9998541761, 99054.99964050032]
 [618479.9991893196, 99095.00067414252]
 [618470.0005791803, 99193.00032755069]
 [618469.9996392075, 99249.99944891405]
 [618464.9999825483, 99289.99999336679]
 [618462.999614977, 99373.00075755456]
 [618442.9993865426, 99525.00077692428]
 [618443.0000878951, 99570.000758061]
 [618460.0003621603, 99680.00092495233]
 [618467.9995335158, 99752.99991965333]
 [618465.0007210508, 99793.00073755499]
 [618495.0001405715, 99874.9998195669]
 [618518.0002885779, 99920.00112405412]
 [618557.999469852, 100015.00090481402]
 [618623.0004549358, 100073.00022258844]
 [618669.9999614233, 100103.00107028308]
 [618765.0000774694, 100158.00054449029]
 [618794.9997050605, 100180.00085553233]
 [618914.9999134497, 100282.999792358]
 [619027.9999576566, 100443.00029290753]
 [619035.0001687277, 100483.00020908828]
 [619039.9994287728, 100569.99927619557]
 [619043.0006639403, 100658.00036993077]
 [619077.9997324473, 100804.99988525888]
 [619102.9996471929, 100940.00066555006]
 [619100.0002353702, 100963.0002979017]
 [619140.0003074078, 101063.00038682825]
 [619165.0000538563, 101102.99959811363]
 [619188.0009892946, 101150.00037186957]
 [619238.000189652, 101217.99947742108]
 [619248.0000941068, 101244.99946664477]
 [619262.9998854895, 101269.99967558368]
 [619284.9999758926, 101292.99992928597]
 [619327.999184968, 101318.00034814049]
 [619354.9996689993, 101347.99966634491]
 [619378.0008986779, 101379.99996228657]
 [619388.0006154686, 101405.00013373911]
 [619407.9994543804, 101420.00034156333]
 [619437.9996370828, 101433.00061665056]
 [619455.0004313672, 101447.99980199196]
 [619480.0005285933, 101419.99988136043]
 [619489.9993047309, 101392.99985212076]
 [619489.9997371224, 101367.99975564078]
 [619525.0010105888, 101349.99994858268]
 [619562.999745002, 101338.00018715305]
 [619548.0007590428, 101314.9999859388]
 [619528.0006282238, 101302.99978968312]
 [619572.9999047493, 101250.00019499022]
 [619592.999990359, 101220.0002929282]
 [619643.0003634456, 101089.9996683423]
 [619653.0004918115, 101058.0006848698]
 [619675.0004859597, 101024.99999264695]
 [619714.9997203371, 100940.00059900574]
 [619742.9999612906, 100905.0011074502]
 [619830.0004545928, 100810.00012831137]
 [619908.000047511, 100739.99966238094]
 [619950.0008510277, 100704.99945892744]
 [619999.9995726605, 100675.00056509429]
 [620034.9999972887, 100658.0001241029]
 [620070.0000393365, 100660.00056064085]
 [620209.999804868, 100688.00023036698]
 [620279.9997278957, 100700.00047288454]
 [620424.9993642572, 100734.99951503324]
 [620509.9993024284, 100747.9999512364]
 [620560.0007757009, 100780.0009208185]
 [620585.0002304855, 100809.99955208723]
 [620650.0005712222, 100900.00034780592]
 [620818.0005757409, 101039.99968040017]
 [620845.0005785102, 101048.00024964231]
 [620952.9995162901, 101043.00032523545]
 [621040.0003140236, 101007.99917041168]
 [621090.0000356532, 100978.00027658834]
 [621145.0005274569, 100959.99998607783]
 [621253.0004325437, 100878.00026096647]
 [621304.9996220043, 100825.0003245236]
 [621329.9999224342, 100813.00001612774]
 [621365.0001658399, 100804.99999080821]
 [621397.9995857399, 100788.0005301885]
 [621464.9999111805, 100729.99951028234]
 [621505.0000522587, 100678.00050208703]
 [621510.0007284816, 100645.00002716832]
 [621509.9994734625, 100608.00031836827]
 [621522.9999671632, 100584.99938392916]
 [621538.0003044396, 100570.00083873545]
 [621567.9997777152, 100550.00021001029]
 [621663.0003434613, 100533.00035901857]
 [621775.0001170255, 100457.99999649262]
 [621857.9996814119, 100390.00067214489]
 [621895.0001711516, 100370.00011226292]
 [621948.0004032368, 100315.00009329554]
 [621978.000614747, 100308.0000649951]
 [622022.999720581, 100308.00050748503]
 [622113.000536334, 100278.00000691174]
 [622235.0004877566, 100244.99968243795]
 [622270.0009123647, 100228.00024149475]
 [622323.001097447, 100224.9996240557]
 [622373.0008526198, 100242.99994702124]
 [622418.0003141316, 100275.00086741697]
 [622454.9999984778, 100295.00015487267]
 [622498.0002942189, 100335.00042505679]
 [622578.0006165999, 100378.0001975796]
 [622660.0005678511, 100390.00055809696]
 [622695.0004488317, 100400.00036407288]
 [622830.0001555806, 100480.00038621257]
 [622860.000065073, 100488.00005065017]
 [622890.0001960394, 100485.00020709277]
 [622919.9995686157, 100470.00080934454]
 [622970.0000352719, 100403.00020664821]
 [622988.0007890731, 100318.0004580343]
 [623037.9993697911, 100294.99988740869]
 [623064.9994735661, 100293.00006053713]
 [623124.9994737533, 100299.99997378887]
 [623159.9995963438, 100298.00022558376]
 [623199.9998917812, 100288.00015705933]
 [623237.9997395459, 100300.00008491045]
 [623298.0008135296, 100353.00012263386]
 [623333.0006475068, 100414.99933014551]
 [623392.9997214647, 100468.00036789746]
 [623453.0001176215, 100504.99966663921]
 [623595.0003912135, 100508.00020148445]
 [623665.0002538336, 100523.00058255557]
 [623685.0002606013, 100525.00087159363]
 [623702.9999405118, 100543.00087989264]
 [623754.9997675442, 100508.00077475885]
 [623873.0004075422, 100490.00010370348]
 [623912.9999043169, 100470.0005733561]
 [623950.0005953953, 100440.00055166463]
 [624005.0000335186, 100375.00109054116]
 [624130.000750479, 100205.00046837714]
 [624152.9992072865, 100184.99977080885]
 [624184.9995845669, 100170.00039273337]
 [624259.9999019357, 100162.99980688818]
 [624287.9995718456, 100132.9996966834]
 [624313.0004964262, 100090.00095667008]
 [624348.0003841582, 100050.0004534408]
 [624385.0007732188, 100035.00012448757]
 [624458.0000858591, 100028.00051901034]
 [624515.0007837252, 99999.99978630886]
 [624558.0009855393, 99994.99997821337]
 [624668.0000899363, 99953.000120106]
 [624719.9998162935, 99923.00024590107]
 [624830.0000817578, 99873.00101836213]
 [624880.0004611225, 99860.00090961372]
 [624928.0004129703, 99867.99975100688]
 [625025.0006411315, 99867.99970479509]
 [625117.9999605432, 99863.00038835607]
 [625180.0003077238, 99853.0005361648]
 [625265.0006083405, 99848.00014102062]
 [625493.0001111053, 99800.00016608345]
 [625545.0002736795, 99798.00058504516]
 [625642.999556222, 99760.00089532416]
 [625823.0000687239, 99628.00059266736]
 [625873.000110404, 99595.000497232]
 [625930.0002250274, 99565.00066806372]
 [626000.0001895468, 99515.00039500582]
 [626135.0006230201, 99433.00014309239]
 [626203.000769198, 99380.00032826269]
 [626335.0002794461, 99307.99989181367]
 [626368.0003323478, 99282.99952308915]
 [626469.9993830277, 99330.00099231389]
 [626634.999888401, 99394.99919513382]
 [626748.000672822, 99444.9999617695]
 [626930.0006824145, 99518.00074905591]
 [626968.0003478684, 99505.0009099964]
 [627005.0003813747, 99478.00053478948]
 [627050.000100557, 99458.00055457935]
 [627088.0005656035, 99453.00101223632]
 [627124.9997976067, 99457.99982375336]
 [627200.0008183152, 99485.0000943226]
 [627255.0007375589, 99490.00021051124]
 [627403.000411094, 99599.99979457405]
 [627484.9992832376, 99668.00070413445]
 [627543.0001542142, 99592.99990415342]
 [627658.0004125391, 99463.00102907191]
 [627718.0004472412, 99420.00044969664]
 [627880.0007657552, 99255.0000718999]
 [627913.0008687539, 99227.99962900054]
 [628003.0000566328, 99198.0000394549]
 [628075.0001314078, 99184.99977576196]
 [628187.9997231446, 99083.00090524358]
 [628193.0005129533, 99048.00069183357]
 [628185.0007791126, 99002.99988753551]
 [628199.9997227662, 98914.99987774507]
 [628213.0004236872, 98877.99972554855]
 [628248.0004437497, 98812.99990722968]
 [628247.9996479999, 98724.99964359278]
 [628255.0002026737, 98697.99976072866]
 [628233.0002862312, 98669.99934999409]
 [628193.0004088555, 98613.00055920084]
 [628195.0010754685, 98584.99955459838]
 [628204.9997784498, 98549.99942576974]
 [628204.9997803567, 98509.99994232925]
 [628195.000580276, 98484.99984595105]
 [628198.0002044613, 98457.99989537764]
 [628213.000770442, 98424.99992537328]
 [628268.0009439887, 98340.00070380625]
 [628274.9995757783, 98270.00022616993]
 [628275.000252089, 98242.99922480862]
 [628318.0003816953, 98208.00065451505]
 [628353.0004017829, 98142.9998361571]
 [628395.0000497773, 98087.99950713906]
 [628418.0007253229, 98084.99978512469]
 [628435.000056188, 98060.00014564912]
 [628448.0005066487, 98032.99936428812]
 [628454.9992116232, 98000.0002589044]
 [628469.9994539085, 97940.00028756092]
 [628502.9998073927, 97902.99947378722]
 [628539.9994150742, 97892.99972906693]
 [628582.9996699482, 97852.99997329686]
 [628605.0001643894, 97818.0010476184]
 [628635.0001441677, 97798.000813562]
 [628768.0002111982, 97743.00102453984]
 [628788.0003146102, 97725.00069542733]
 [628809.9998591925, 97688.00069552181]
 [628837.9999507947, 97624.99983287699]
 [628863.0004432388, 97587.99988375742]
 [628893.0004981626, 97564.99953843864]
 [628943.0002576326, 97499.99997396265]
 [628978.0005763457, 97463.00019407399]
 [628973.0008691354, 97413.00023952106]
 [628974.999911257, 97379.9993674547]
 [629010.0000110758, 97293.00021196278]
 [629052.9999143833, 97238.00107153857]
 [629087.9998229047, 97214.99981999994]
 [629273.0003700505, 97140.0000807228]
 [629314.9999359536, 97107.99946042632]
 [629380.0004204931, 97048.00081367281]
 [629438.0006150133, 97009.9997037467]
 [629504.9995722184, 97003.00068064152]
 [629547.9993233315, 96977.99962025297]
 [629588.0010166605, 96984.99948804312]
 [629683.0005359187, 96974.99987803832]
 [629743.0004400676, 96963.00011974086]
 [629879.9995709372, 96958.0005212957]
 [629950.00074462, 96960.00094590172]
 [630038.000482619, 96990.00072056463]
 [630115.0004549673, 96988.00045647757]
 [630164.9996938999, 96948.00041132593]
 [630192.9999168371, 96933.00059241269]
 [630213.0002514814, 96882.99995049328]
 [630233.0004340165, 96863.00038841597]
 [630318.0000902057, 96817.99993962447]
 [630353.0009422532, 96793.00081595941]
 [630407.9996941761, 96737.99977038412]
 [630439.9997253714, 96718.00030303627]
 [630523.0007567533, 96650.00031050069]
 [630580.0000595468, 96580.00024069985]
 [630634.999952785, 96529.99987507393]
 [630735.0002784914, 96479.9998646907]
 [630767.9992405669, 96458.00053322995]
 [630833.0000533797, 96445.00087840561]
 [630863.000392367, 96434.99975534968]
 [630893.0001096379, 96403.0000402619]
 [630924.9999147559, 96375.00108490606]
 [630943.0009811447, 96349.9998271728]
 [631009.9999383212, 96342.99980412968]
 [631058.0005307684, 96349.99973506466]
 [631109.9998749655, 96350.0001455581]
 [631215.0001651354, 96308.0002147415]
 [631267.9997733572, 96255.00025511534]
 [631367.999716057, 96230.00004864279]
 [631438.000426919, 96228.00084569042]
 [631520.0003719003, 96208.00067449866]
 [631682.9999130196, 96190.000252213]
 [631879.9995230151, 96157.99978045373]
 [631950.000201743, 96158.00056996796]
 [632019.9996395167, 96173.00030295787]
 [632092.9993044992, 96173.00008345608]
 [632313.0007004172, 96210.00028249182]
 [632335.0001053947, 96302.99986585866]
 [632338.000288365, 96352.99966840543]
 [632482.999863896, 96337.99928893756]
 [632677.9991296055, 96328.00074027611]
 [632775.0008932828, 96315.00049759504]
 [632935.000158998, 96315.0000164954]
 [633107.9997224292, 96355.00034555416]
 [633405.0010741701, 96435.00015101164]
 [633492.9999795135, 96477.99972435755]
 [633587.9999009051, 96518.00028795253]
 [633667.9998108263, 96562.99987781288]
 [633805.0006558655, 96658.00110783898]
 [633858.0006896971, 96703.00077888517]
 [633913.0000035285, 96730.00051175508]
 [633963.0005652156, 96743.00031241658]
 [634023.0004987052, 96730.00018099607]
 [634190.0003306452, 96755.00058462877]
 [634320.0011235556, 96793.00005052272]
 [634383.0006737798, 96802.99982340356]
 [634428.0005475878, 96797.99970693741]
 [634468.0002570647, 96805.00058161892]
 [634468.000622044, 96782.99970911258]
 [634495.0009361542, 96763.00015455473]
 [634538.0007918822, 96770.00063882301]
 [634554.9994775185, 96728.00008967686]
 [634574.9997630323, 96710.0004380917]
 [634594.9995296355, 96663.0009545442]
 [634617.9998132188, 96644.99933958653]
 [634633.0004172006, 96607.99973707601]
 [634647.9996562185, 96593.00000706728]
 [634669.9998077096, 96583.00033353428]
 [634675.000351897, 96549.99958579801]
 [634687.9999240118, 96514.99994727488]
 [634734.999303346, 96430.00001346819]
 [634754.9997049845, 96405.00040244688]
 [634783.0001014026, 96379.99988907612]
 [634813.0000273483, 96323.00058553087]
 [634893.0005178127, 96230.00010088074]
 [634943.0005965789, 96163.00009939929]
 [635040.0002749844, 96057.99989176648]
 [635069.999636897, 96035.00039119725]
 [635085.0003284739, 96053.00046998331]
 [635197.9997190349, 96025.00001144757]
 [635288.0002739389, 95988.00032434556]
 [635337.9997886722, 95955.00012584]
 [635395.0006637834, 95900.000140267]
 [635508.0010828751, 95810.0000410103]
 [635544.9992577434, 95797.99956213108]
 [635620.0009598101, 95813.00039063784]
 [635688.0005835304, 95833.00010471568]
 [635815.0003013437, 95845.00058526701]
 [635883.0002070972, 95847.99939786083]
 [635935.0005546102, 95825.00016582242]
 [635960.0007871, 95809.9995578873]
 [636005.0007576436, 95810.00010713012]
 [636060.0005889441, 95817.99973207212]
 [636080.0006256199, 95814.99999356459]
 [636108.0011049677, 95785.00050916056]
 [636163.0003085277, 95650.00096272993]
 [636198.0001482876, 95597.99969124871]
 [636182.9999543906, 95549.99978630738]
 [636190.0009783392, 95488.00023102433]
 [636237.999738573, 95380.00044269186]
 [636173.0005515194, 95213.00061705279]
 [636168.0010524851, 95182.99972987812]
 [636174.9993796882, 95162.99993118794]
 [636203.0000746954, 95120.0005221167]
 [636233.0006264022, 94965.00078645987]
 [636228.0010729677, 94877.99922958182]
 [636204.9994981089, 94792.99944138134]
 [636188.000831728, 94653.00004515312]
 [636199.9999804859, 94522.99994491265]
 [636217.9994663816, 94493.00033844232]
 [636230.000005987, 94459.99967614372]
 [636243.0003577906, 94378.00030997762]
 [636324.999460731, 94248.00106411475]
 [636353.0001013585, 94147.99998534776]
 [636417.9298503582, 94040.00940361603]
 [636406.6751514513, 94022.30336884724]
 [636392.4843168284, 93952.61459946459]
 [636378.211736354, 93927.88856853997]
 [636367.6329265068, 93916.84350342123]
 [636365.0380542681, 93909.24451578356]
 [636335.917215849, 93900.65321013553]
 [636302.6250357473, 93852.54308257089]
 [636289.3134058913, 93830.75604634408]
 [636259.0906539076, 93756.71810648305]
 [636225.6526476757, 93698.1330378395]
 [636217.6870824491, 93672.23909066134]
 [636221.1830689744, 93552.35382802565]
 [636202.7694027621, 93532.95971565913]
 [636208.758798708, 93508.85592843729]
 [636203.9201571484, 93487.43999347634]
 [636197.8702881978, 93479.77896402928]
 [636188.1663993773, 93473.45988220364]
 [636185.3258600963, 93445.8000078129]
 [636179.2362426318, 93422.981065716]
 [636148.997377866, 93355.74208626302]
 [636123.6805776308, 93284.41919055226]
 [636077.9136380791, 93222.30099189804]
 [636061.8521249366, 93193.58696224607]
 [636058.630608067, 93164.59109094784]
 [636043.5550510288, 93138.48405822394]
 [636039.1321710764, 93131.42204516343]
 [636024.1413388682, 93121.89891737474]
 [635955.7337073692, 93102.38419550953]
 [635873.8160629969, 93084.17830116434]
 [635815.1371815316, 93019.06796224977]
 [635793.6510867692, 92965.34801129182]
 [635868.8495874096, 92871.9234704894]
 [635837.4339914984, 92788.52457031488]
 [635821.5731705753, 92778.355435653]
 [635813.5813313317, 92768.98039243402]
 [635781.9687426495, 92745.43314303346]
 [635777.5376700214, 92749.98606257068]
 [635764.1518356845, 92740.52795399603]
 [635754.0768435742, 92740.44983147715]
 [635744.6820026273, 92731.23277021814]
 [635711.968197563, 92720.77243154366]
 [635704.6404385386, 92706.5354246038]
 [635691.2605124606, 92702.60728405838]
 [635682.3776859908, 92692.49723422412]
 [635672.5677380838, 92689.7441304437]
 [635664.1709375415, 92678.05209570633]
 [635654.8240581262, 92671.15202160826]
 [635631.9431250769, 92668.0187604906]
 [635596.6557691112, 92630.58854668713]
 [635540.5359981478, 92618.99592889364]
 [635512.8845064441, 92589.44676262261]
 [635485.3771455159, 92552.00864382241]
 [635466.2304749531, 92532.90552082409]
 [635427.0673654333, 92420.49269421483]
 [635373.0087236245, 92340.75349646456]
 [635360.0163209664, 92305.25854356632]
 [635315.625772482, 92219.51249862816]
 [635304.3413125483, 92187.40254696272]
 [635299.4693758221, 92183.78050848549]
 [635296.2301265326, 92138.65573043167]
 [635290.7507333691, 92102.29187426905]
 [635289.0634599356, 92058.56110708117]
 [635289.3197687264, 92039.93721812697]
 [635291.6948658942, 92033.9862815985]
 [635289.7190777877, 92021.29133104942]
 [635280.7414581658, 91998.71635228458]
 [635264.0794698684, 91998.66814919584]
 [635256.5047271826, 91983.45614489344]
 [635254.6278799202, 91974.32317490682]
 [635246.8858977132, 91973.5560848563]
 [635220.8403452524, 91947.60591733106]
 [635202.6765176422, 91937.93075169642]
 [635176.3410362412, 91907.70860538728]
 [635159.6996364157, 91872.1866081089]
 [635138.1447377185, 91866.93037547817]
 [635127.1217458445, 91866.87524125712]
 [635112.8769056193, 91857.80611994627]
 [635085.6070430455, 91850.5978288737]
 [635029.0397079429, 91873.02900846142]
 [635008.0822658204, 91840.22694274163]
 [634983.5924629738, 91829.30870710156]
 [634959.2775307964, 91826.17942845868]
 [634951.8845937983, 91822.67335853993]
 [634892.084824199, 91811.1436954665]
 [634838.6429468206, 91805.8600737999]
 [634794.449363524, 91782.48466984872]
 [634761.7285047658, 91775.26131233074]
 [634742.6186899194, 91764.85413939459]
 [634705.5444964198, 91717.70096012217]
 [634676.3047779991, 91701.88069491023]
 [634639.6017078, 91707.56021402056]
 [634621.2829408738, 91694.23306765796]
 [634597.0571802881, 91680.75685006121]
 [634559.6018333215, 91642.86961244256]
 [634549.6161136653, 91626.36458620422]
 [634551.8933292931, 91613.27668983901]
 [634536.9934537127, 91606.36454803204]
 [634515.6348022473, 91586.19740420178]
 [634505.6977386306, 91590.42425842001]
 [634477.7267278583, 91592.1769068669]
 [634475.6386156393, 91599.02384170392]
 [634451.8464742632, 91608.48449648746]
 [634438.7824891694, 91608.1013392581]
 [634424.1073124281, 91619.33409504959]
 [634410.8485430547, 91605.95501074666]
 [634395.5325815976, 91604.23583376958]
 [634377.8026907807, 91598.35365145377]
 [634360.4698644514, 91588.56849659981]
 [634346.8469200014, 91585.7573466143]
 [634339.8629910118, 91581.7522845811]
 [634339.7470580082, 91577.71830653971]
 [634316.2523516872, 91560.9421169875]
 [634300.212514543, 91551.75797443595]
 [634294.7285091073, 91552.30190434895]
 [634279.5596570258, 91543.98376740661]
 [634240.5131583656, 91515.3034570185]
 [634212.228422517, 91500.49619759282]
 [634174.8650255898, 91465.61694366738]
 [634169.1852510726, 91452.24895180528]
 [634151.0044359643, 91441.82079032811]
 [634141.3494631727, 91440.56167978108]
 [634060.4352265894, 91458.01459105057]
 [634010.7972154353, 91460.6449699501]
 [633987.5563053949, 91335.57941099629]
 [633994.6891229363, 91286.01678525684]
 [634023.5744312024, 91266.29525209249]
 [634028.4337025245, 91249.74840728706]
 [634012.2030186036, 91231.33531588259]
 [634010.591370189, 91210.20541864955]
 [634023.6739480396, 91174.8567831625]
 [634074.1748727773, 91117.12173410738]
 [634184.0011886065, 91033.47155931151]
 [634201.1214421978, 91017.50986076733]
 [634203.6538129825, 90995.0590217698]
 [634218.9670780584, 90978.47630476601]
 [634226.993318508, 90963.6654885531]
 [634228.2425776579, 90947.9945946083]
 [634221.2458213572, 90933.58059273666]
 [634220.689099027, 90916.86468280278]
 [634225.7083247862, 90903.05782407075]
 [634253.5767967724, 90873.50733545468]
 [634268.4589016116, 90866.60055711855]
 [634273.5100004976, 90860.44065446417]
 [634280.1992536492, 90844.91682606479]
 [634290.9294217913, 90834.35801821583]
 [634297.830786082, 90812.12623127889]
 [634331.3911554059, 90788.53977757342]
 [634330.2853937844, 90774.21384708954]
 [634324.9538724076, 90745.57294798121]
 [634327.3332525685, 90722.56311035526]
 [634332.4445246218, 90705.96226893713]
 [634334.192687279, 90696.0883474922]
 [634330.6267190429, 90694.31431424755]
 [634322.8197228428, 90694.39321850213]
 [634311.7147268102, 90694.59208180897]
 [634293.1717960136, 90691.15187541711]
 [634273.7170097785, 90679.03370818227]
 [634262.6933924082, 90656.40370476789]
 [634255.8497847765, 90633.02175672953]
 [634253.0257232861, 90576.56004943547]
 [634264.5653520254, 90538.2044125413]
 [634278.2698577349, 90507.17975958629]
 [634310.5530664789, 90433.04358321379]
 [634353.9279988855, 90375.12744823023]
 [634356.9551249216, 90367.4105298944]
 [634354.5652595973, 90359.38654722106]
 [634343.5843914546, 90351.87145674099]
 [634327.9245601322, 90342.32132094445]
 [634318.8647284023, 90332.53526707321]
 [634217.6038488669, 90268.98839936835]
 [634108.4705536767, 90170.52763789009]
 [634056.8195422475, 90112.97434096724]
 [634048.998692192, 90104.24429609724]
 [634030.0731699385, 90076.19222765324]
 [634018.4156622234, 90046.9772546587]
 [634013.95838493, 90003.58845168026]
 [634023.4312761921, 89949.48988078462]
 [634036.1077952477, 89917.70121971125]
 [634049.1501449042, 89896.10950401572]
 [634051.7904038096, 89880.39862728129]
 [634053.2930049154, 89844.10485593157]
 [634051.9483504377, 89823.3299599005]
 [634006.9716052416, 89809.74448966015]
 [633917.0041624418, 89779.70556563132]
 [633858.8437299556, 89747.790040696]
 [633828.4314735855, 89704.1639222963]
 [633824.230730846, 89688.82195992554]
 [633863.0934648105, 89582.76604882136]
 [633898.5094053275, 89524.67481771209]
 [633931.0069959495, 89487.79042809148]
 [633958.4252151921, 89473.49284559317]
 [633974.9203259117, 89466.16808936893]
 [633980.0053600423, 89463.91016451677]
 [634005.7289015944, 89430.2506735299]
 [634005.6201374342, 89416.03875455816]
 [634005.3643948662, 89400.53084129836]
 [634008.29156742, 89390.01393796691]
 [634016.4707612337, 89378.00810736654]
 [634031.319107437, 89356.55341292206]
 [634057.0243799285, 89339.11382772226]
 [634076.6444601315, 89333.50509969788]
 [634095.1445038776, 89330.1383450066]
 [634123.8017512776, 89314.09478774904]
 [634137.8180659894, 89294.57107195795]
 [634136.9652304491, 89284.69111880069]
 [634133.7564199757, 89273.3931451031]
 [634122.4636498276, 89259.98308497597]
 [634113.410814795, 89250.3960300343]
 [634095.4861065038, 89233.51890905524]
 [634071.4094699911, 89212.55773664838]
 [634055.5979409417, 89184.7927045531]
 [634043.1486608188, 89141.88980121048]
 [634012.6891094052, 89116.0505791651]
 [634008.6194667129, 89094.67265337225]
 [634006.938825027, 89073.13975763525]
 [634006.7441975692, 89050.69088534232]
 [634009.5413834103, 89039.37798503661]
 [634016.5525623639, 89028.31413472338]
 [634020.7868244898, 89012.34627893426]
 [634026.5801978179, 88989.61348137115]
 [634021.6205967034, 88965.76455903373]
 [634021.2062527104, 88926.23678302925]
 [634021.0018107414, 88892.60697540455]
 [634024.7323519284, 88859.83721082758]
 [634032.5477616566, 88834.83045112473]
 [634030.9862068396, 88808.05658721033]
 [634016.9369732832, 88762.40968024111]
 [634009.2358556289, 88709.52589268914]
 [634003.5719788608, 88702.3208653076]
 [633982.0522226255, 88688.47568287798]
 [633956.6454151211, 88677.87443420671]
 [633934.5304712672, 88675.36217884258]
 [633883.1065358027, 88673.50056197507]
 [633852.0856888042, 88665.5012297027]
 [633827.1269975445, 88647.87502720936]
 [633774.0833494855, 88628.75249059366]
 [633748.1465088665, 88620.16822376625]
 [633726.4066231115, 88614.13899335876]
 [633696.901907223, 88598.17672573429]
 [633669.8730167879, 88592.63842792752]
 [633653.2220427167, 88591.732229946]
 [633627.3120509011, 88592.26091063798]
 [633598.8821157125, 88589.47557977702]
 [633581.619239653, 88582.68540842296]
 [633559.5095714781, 88563.555249414]
 [633540.9577370214, 88554.30807656655]
 [633526.3098076599, 88550.6279191072]
 [633516.1249411157, 88542.98483908201]
 [633480.4784780352, 88512.02558339947]
 [633478.8890343002, 88478.55675793959]
 [633481.4547621992, 88434.57804409863]
 [633472.8500880317, 88294.71674952302]
 [633470.7072896793, 88162.08649191524]
 [633462.4732650699, 87983.05542883732]
 [633453.9531785401, 87928.32764197426]
 [633449.0484595231, 87911.58367913637]
 [633443.8088501098, 87888.24575042022]
 [633416.5248199583, 87830.85974993788]
 [633412.3353250872, 87800.57587428985]
 [633403.4529201695, 87765.05497170566]
 [633392.9685635115, 87726.68806606345]
 [633395.1781612497, 87690.56930232584]
 [633395.8926179162, 87663.01347072473]
 [633392.7630034052, 87639.8995664635]
 [633390.7034020831, 87615.9486801109]
 [633383.7503541276, 87558.8339262079]
 [633379.682081787, 87515.1311297936]
 [633378.5155302444, 87488.14427193525]
 [633372.4589275394, 87464.43433540166]
 [633358.4592538893, 87445.31427532596]
 [633348.0315933129, 87425.26526422596]
 [633347.9568614642, 87403.6443204922]
 [633369.6170548664, 87382.34459867512]
 [633386.887022461, 87380.63978220825]
 [633383.1904582147, 87345.8968308632]
 [633361.8476469856, 87335.8276345499]
 [633353.559765357, 87328.2275675578]
 [633334.5538345183, 87327.36137244699]
 [633341.9150446189, 87308.30249659506]
 [633428.2508897296, 87217.32662063725]
 [633432.0689666248, 87210.06767845157]
 [633459.4120364527, 87197.45099387107]
 [633464.0441362476, 87188.11206534659]
 [633472.2891847036, 87182.06416607831]
 [633480.4753717933, 87164.68129459031]
 [633525.6295741273, 87136.72183332093]
 [633532.9107190603, 87123.0189432244]
 [633530.1948497801, 87113.00194012401]
 [633538.6531343801, 87087.5670916321]
 [633550.7785364031, 87051.59330760226]
 [633554.9807294932, 87034.72439347189]
 [633553.5309204134, 87019.45941665882]
 [633551.1661883406, 86998.1204455661]
 [633560.9887676558, 86948.21267253523]
 [633565.5133267429, 86901.2978370153]
 [633564.1729245757, 86852.69094485388]
 [633572.2803091041, 86819.16311298922]
 [633667.1494321899, 86785.14718292748]
 [633774.5919812087, 86713.08647867528]
 [633780.4932468156, 86607.98080320473]
 [634010.9006288284, 86272.95103401474]
 [633999.4709914003, 86246.15098250518]
 [633853.7978736134, 85965.06817449584]
 [633755.1717039472, 85732.46824000606]
 [633706.3664336768, 85523.07701322151]
 [633633.7773903114, 85446.61404191633]
 [633499.6344817084, 85405.0686188799]
 [633184.3676626083, 85420.92208302786]
 [633098.5688475783, 85208.02570163153]
 [633010.5823582491, 85106.24777981872]
 [632767.3111192215, 85229.30306583043]
 [632721.9192475086, 85384.03811716211]
 [632666.6550380405, 85502.4512961048]
 [632575.4991209283, 85561.79659069641]
 [632376.3637908942, 85594.00851465396]
 [632144.3630166742, 85547.76166081613]
 [631972.7209350334, 85527.71031835466]
 [631723.5351275277, 85547.8189873898]
 [631366.3338855078, 85676.96578631396]
 [631191.4997831836, 85684.64268304118]
 [630885.2008304994, 85648.04474380931]
 [630800.513640104, 85717.68790251708]
 [630663.9356769512, 85793.74218166957]
 [630621.0180441713, 85885.58432307695]
 [630582.5526370883, 85951.02228037259]
 [630474.2547161675, 86006.07086305339]
 [630378.1630365973, 86028.52634053971]
 [630281.6243978231, 86046.94176932977]
 [630196.7684822624, 86087.7046350074]
 [630097.3016183403, 86131.57426609879]
 [630082.920688609, 86132.58201461536]
 [629984.6801686499, 86139.46529666532]
 [629900.3565081516, 86153.02189886976]
 [629792.2566954637, 86196.54236941319]
 [629722.0798214418, 86224.33337187386]
 [629615.4224193445, 86223.7154254995]
 [629520.6463671627, 86179.24725499477]
 [629361.0855812891, 86039.17394612347]
 [629188.301733049, 85913.41654044534]
 [629136.3476910844, 85842.80688643665]
 [629055.1923276564, 85823.18521316066]
 [628950.5857835236, 85836.34344240816]
 [628803.77708757, 85784.7682540369]
 [628709.7774061059, 85700.75570062408]
 [628608.0432307731, 85567.90251614538]
 [628455.7701246236, 85351.89157741476]
 [628333.0775552146, 85272.85755204252]
 [628198.4550779526, 85191.09028221626]
 [628152.6946291012, 85159.75913523187]
 [628066.2513559293, 85133.71530128772]
 [628001.2098195659, 85122.89700952351]
 [627969.9195623131, 85168.33689655308]
 [627805.7594117586, 85280.295034446]
 [627570.3721995725, 85440.44136048623]
 [627508.2596880343, 85530.7341371716]
 [627510.9076104546, 85642.80731056606]
 [627440.4033478597, 85711.76272036837]
 [627392.1327012918, 85808.19181045587]
 [627394.2127688758, 85905.29082318241]
 [627321.9063725935, 85989.39735232262]
 [627190.0884362484, 86059.83866170642]
 [627092.6211007937, 86152.25781660949]
 [626962.5656060041, 86280.5517389033]
 [626854.7659358687, 86308.8650622223]
 [626671.1269159116, 86418.45382199356]
 [626630.6048707126, 86446.93737084659]
 [626562.5599095728, 86482.66649178888]
 [626517.1070040175, 86499.31183209324]
 [626412.7251416462, 86545.89440101155]
 [626301.1671401828, 86611.34402882122]
 [626243.9321686771, 86641.83929385475]
 [626213.2651225558, 86664.65196504405]
 [626181.6450098171, 86695.04669501996]
 [626158.0495720209, 86755.01986794302]
 [626145.1955243022, 86767.57476017188]
 [626122.1671629354, 86819.15685916052]
 [626109.0689021463, 86854.32197395616]
 [626104.4189060485, 86856.63191256413]
 [626086.8860407885, 86852.68655401723]
 [626052.7712820775, 86847.21187848107]
 [626030.504379468, 86849.9755011768]
 [625985.3774865258, 86865.09983213869]
 [625948.4644553696, 86889.99041056976]
 [625920.9393627556, 86915.86616966815]
 [625890.6111894257, 86951.89397969957]
 [625884.0841661379, 86958.16992398059]
 [625857.8742178244, 86968.06054650998]
 [625840.3461627356, 86984.12838898608]
 [625809.0968390558, 87036.54834684162]
 [625799.9987489161, 87051.37833023828]
 [625772.3957155846, 87071.04902561716]
 [625765.6685966402, 87087.52806869675]
 [625761.5851949222, 87132.27644369652]
 [625751.5180200174, 87156.61150489606]
 [625744.8679352365, 87169.44351276041]
 [625743.2328615645, 87178.16857061957]
 [625734.6997785193, 87191.91955345719]
 [625724.6407822053, 87197.41842568832]
 [625725.6457004702, 87205.44852459297]
 [625713.4777053291, 87212.0583696122]
 [625716.7425702986, 87224.38555276852]
 [625708.8025876847, 87227.19943658603]
 [625705.1835316482, 87235.2264513441]
 [625677.7345030373, 87254.30914362129]
 [625662.3574109524, 87273.01905175264]
 [625652.3100605328, 87315.84929900449]
 [625644.7319217973, 87334.91335256178]
 [625622.0969415843, 87346.07505287808]
 [625608.6930184758, 87345.81280642051]
 [625589.2881298283, 87345.42944958224]
 [625548.7922236094, 87359.24285162616]
 [625497.0153460548, 87376.63708440989]
 [625470.6874382752, 87382.32266256871]
 [625449.0075266042, 87385.69830209047]
 [625432.6775595545, 87391.78206611823]
 [625394.6727794937, 87390.83536528221]
 [625371.5449501355, 87386.37889982754]
 [625356.3599499563, 87395.28571302583]
 [625340.1949648812, 87403.17349816849]
 [625318.7230557983, 87406.15413750871]
 [625298.7892043341, 87402.15973479151]
 [625291.0732903533, 87397.60554871144]
 [625273.5113151951, 87405.26530615253]
 [625230.7864084721, 87420.43668127902]
 [625133.000698096, 87447.13217051829]
 [625110.5117872737, 87450.89179917889]
 [625073.5959478192, 87455.5701746241]
 [625060.3889249003, 87465.71703625523]
 [625040.8189574734, 87473.7367607832]
 [625001.9840720909, 87484.3811612251]
 [624984.4770263995, 87499.44599401076]
 [624975.3690274061, 87504.6708807903]
 [624965.9390682257, 87505.8857214501]
 [624927.419332866, 87500.52696694851]
 [624914.7923939297, 87501.4787468117]
 [624901.8674092602, 87507.42757142171]
 [624886.5844589876, 87511.12933058404]
 [624857.4865822712, 87515.16084174892]
 [624823.2427616633, 87516.28823014877]
 [624787.4769877301, 87513.38455039474]
 [624752.1232171474, 87509.88687216735]
 [624698.9175262083, 87508.43988979372]
 [624656.843543634, 87531.22835323987]
 [624623.1205852663, 87546.57689389761]
 [624590.3236823361, 87555.53738726374]
 [624549.8456887124, 87578.55688206055]
 [624529.8327029371, 87588.77062055968]
 [624487.0108461264, 87598.73594165269]
 [624458.6528399091, 87615.98959903137]
 [624410.0467353773, 87655.46111115237]
 [624394.6038049983, 87657.15884727954]
 [624309.176291322, 87655.88028046003]
 [624275.3535755315, 87645.70856307664]
 [624200.7469608677, 87648.74523641953]
 [624153.5871602688, 87655.32244458889]
 [624063.2092659877, 87697.07321973827]
 [623999.2301680481, 87744.84753557487]
 [623974.1541577126, 87760.6142377262]
 [623981.9899976872, 87667.4584449671]
 [623976.327038463, 87561.03027340314]
 [623935.2881908532, 87358.09548938563]
 [623827.7094391634, 87078.5497257767]
 [623652.0277958701, 86827.43500878218]
 [623536.7495438522, 86710.59473870361]
 [623403.7431657894, 86617.42138375303]
 [623276.4179615461, 86502.59491474972]
 [623135.680927178, 86344.47799800432]
 [623080.0908097856, 86258.08203172086]
 [622970.7612278751, 85952.73696975125]
 [622982.5600346811, 85886.92607444913]
 [622993.6659720613, 85870.98022788115]
 [622998.9309502187, 85866.44630422542]
 [622999.8999445653, 85864.9813175243]
 [622998.6049461225, 85864.62529699202]
 [622494.3778540699, 85842.06244037062]
 [622291.0422049101, 85827.06026504845]
 [622129.0374892746, 85816.97373738598]
 [622009.3756902271, 85806.01786619144]
 [621924.5268918471, 85821.06156659404]
 [621865.947049385, 85838.52367779105]
 [621800.9312368266, 85862.76269713725]
 [621743.3644038821, 85884.64582933909]
 [621702.271584043, 85923.76523791616]
 [621655.3538572853, 85994.48959374604]
 [621619.4870772292, 86052.82210639537]
 [621590.2393486283, 86135.90075134848]
 [621571.7705501193, 86199.9795410107]
 [621558.9676798291, 86240.55439061258]
 [621542.663802585, 86275.85817956385]
 [621533.7788300539, 86279.88504639994]
 [621320.8702758279, 86294.43075768431]
 [621291.2533553278, 86303.20130825038]
 [621258.5664866646, 86329.70183230258]
 [621257.3105068376, 86336.55482097546]
 [621261.6185565628, 86358.92491455698]
 [621271.2536988643, 86420.94913817008]
 [621265.6969228066, 86503.23715005862]
 [621240.8612155931, 86597.83087725705]
 [621192.7805659985, 86697.46324952068]
 [621171.1507949928, 86769.81599997013]
 [621148.191046126, 86849.72473878392]
 [621121.51719522, 86887.52236967959]
 [621022.550532413, 86944.43090080643]
 [620994.0256164663, 86955.76547139125]
 [620981.5006395569, 86955.41327648354]
 [620940.5516889011, 86944.16962720816]
 [620927.8756334502, 86913.40439366816]
 [620921.4266421094, 86911.97529182099]
 [620913.9157034855, 86930.10019681384]
 [620911.2837178503, 86933.69716023817]
 [620913.5277217352, 86936.85419884766]
 [620908.715743306, 86941.61912981197]
 [620908.670753192, 86945.39913362419]
 [620907.6087597387, 86947.1391192076]
 [620893.7588422954, 86968.74892992503]
 [620889.3028613852, 86972.81886558779]
 [620880.735887514, 86976.56373702754]
 [620858.357050885, 87023.04444497786]
 [620840.8671060596, 87069.34430068784]
 [620844.5780131958, 87076.96444470016]
 [620845.6777426689, 87104.84574463808]
 [620848.9473808225, 87141.08616797223]
 [620980.239214653, 87819.86437128719]
 [620934.7711154615, 88067.82203372146]
 [620940.5469867212, 88078.01624113797]
 [620942.7378069414, 88095.69045844075]
 [620933.6375602599, 88127.02760753162]
 [620940.5770436664, 88177.43723988718]
 [620955.7495762948, 88217.83792151253]
 [620980.5193404576, 88228.20747620196]
 [621011.6736511131, 88282.65958962779]
 [621010.4215422556, 88294.87068945146]
 [621020.1641332876, 88332.29124238506]
 [621014.8358803102, 88362.08444458617]
 [621009.9438091556, 88372.45045967273]
 [621028.2472336444, 88422.4212943409]
 [621036.518035641, 88438.45860580604]
 [621038.2328077371, 88461.48586819823]
 [621032.5576682921, 88479.51094593659]
 [621035.726569614, 88488.0610894263]
 [621028.27746825, 88503.10910500673]
 [621036.6392996422, 88515.99338647367]
 [621039.5171663538, 88528.36356302342]
 [621034.1591085292, 88537.59655825622]
 [621020.6971050181, 88545.8463962029]
 [620981.1327750951, 88603.79125827597]
 [620947.2107164209, 88629.83290267207]
 [620932.2827269442, 88637.46070770484]
 [620918.2904857653, 88671.08079072794]
 [620863.4867448804, 88675.83584155355]
 [620845.9969313603, 88666.40942875684]
 [620746.9962385783, 88691.96088441102]
 [620710.1273196654, 88704.99034455577]
 [620711.5212373629, 88712.85244884847]
 [620706.3141374496, 88726.43549050407]
 [620690.4030512995, 88744.83238577786]
 [620667.7189872384, 88764.86417426304]
 [620639.2257808637, 88803.30204187504]
 [620623.5007840303, 88812.17184487818]
 [620595.2518818725, 88818.38939343885]
 [620581.5580362986, 88810.12106132429]
 [620556.5768477112, 88844.62795335303]
 [620531.5008670412, 88857.26662409675]
 [620494.4806992381, 88896.62834587187]
 [620491.9125357849, 88915.36648729054]
 [620476.5104169161, 88936.91542346857]
 [620400.8155206912, 88970.27738148825]
 [620369.0633903535, 89002.6051284687]
 [620314.5835076103, 89022.12833345891]
 [620280.3904066421, 89052.7880192912]
 [620242.8149433313, 89123.63404707305]
 [620248.1155445185, 89162.58353455379]
 [620220.0155385494, 89179.66019484741]
 [620244.2992991488, 89190.68974732276]
 [620240.9022443737, 89198.45376347836]
 [620227.5292378435, 89206.96960571726]
 [620214.1352545879, 89213.04342305096]
 [620174.3441575541, 89246.56503578565]
 [620110.0973587964, 89262.94903159267]
 [620075.980386056, 89280.04358261246]
 [620049.3456709565, 89265.5919530152]
 [620025.2947298745, 89273.45659447297]
 [620002.1896814088, 89292.09036126184]
 [619959.5328847857, 89295.61262067195]
 [619939.8051369801, 89280.5671107502]
 [619922.9732204202, 89281.6208151472]
 [619892.5675578655, 89263.83608348474]
 [619866.5856445717, 89269.90067174696]
 [619830.1139818231, 89255.68686559486]
 [619801.649129714, 89256.75335850571]
 [619790.4060805937, 89268.51327205995]
 [619739.1163799682, 89266.96632353419]
 [619719.5683803728, 89278.3650823883]
 [619674.0387664998, 89264.29911294853]
 [619659.0518626381, 89262.93382662072]
 [619647.2368861806, 89267.36665620292]
 [619628.3080203545, 89264.29828106725]
 [619610.5342099679, 89254.70786146069]
 [619609.9091074556, 89265.88296229005]
 [619580.9172854876, 89264.07941680218]
 [619572.1873982705, 89257.29718990362]
 [619558.5874920856, 89255.3649231121]
 [619540.1327073132, 89243.47246800417]
 [619528.8877156377, 89249.17632071767]
 [619516.4978275847, 89244.6240496345]
 [619507.1928053865, 89252.41095855202]
 [619485.4028947346, 89255.74359563588]
 [619464.998850639, 89272.3353910568]
 [619394.5640614809, 89291.32930050325]
 [619347.6602629902, 89297.53450959318]
 [619318.7404199295, 89297.91298732243]
 [619259.5466902589, 89304.05497221442]
 [619238.8257134488, 89313.73769250387]
 [619156.4836615716, 89367.40273344866]
 [619120.3986812218, 89386.451268291]
 [619101.6686485304, 89400.8610722556]
 [619088.2156707265, 89406.39488309546]
 [619071.0245886835, 89425.10775825738]
 [619070.7355608587, 89428.21078415475]
 [619053.070516746, 89443.2016133262]
 [619027.7543929996, 89471.06743258605]
 [619014.835430164, 89474.71023415479]
 [619010.155496573, 89470.44710622099]
 [618991.3735255573, 89478.3838442493]
 [618987.8795805653, 89474.62874299145]
 [618972.8305711587, 89484.42856763213]
 [618961.2416604816, 89481.7933303623]
 [618926.7238282312, 89484.30872771736]
 [618906.0698365176, 89495.52346460494]
 [618897.803997357, 89483.40219254515]
 [618884.7140756912, 89482.80394842308]
 [618860.410019427, 89502.96170870242]
 [618841.4772124884, 89493.6862711768]
 [618823.7692475946, 89500.34901595073]
 [618801.9362519486, 89512.66874248594]
 [618792.8062324121, 89520.07265074017]
 [618774.1070832193, 89546.7485784192]
 [618732.3089940894, 89580.61115807071]
 [618690.9439655497, 89607.83167891178]
 [618694.0507496743, 89628.77594570785]
 [618669.9687650787, 89641.24663284859]
 [618638.0336895321, 89667.90431957485]
 [618607.5765860071, 89696.64705412145]
 [618583.301463839, 89723.73688452631]
 [618583.5391094082, 89760.97026267652]
 [618568.9237214639, 89810.43049340138]
 [618577.7923278825, 89846.74001928022]
 [618584.9271496906, 89861.35329578481]
 [618573.1369297791, 89891.44238341297]
 [618561.4828907282, 89902.38128124547]
 [618549.5265967861, 89940.37344519782]
 [618546.4824444636, 89958.21656897223]
 [618563.6728477204, 90011.07741240688]
 [618564.4307308523, 90022.95654546197]
 [618557.6707012241, 90030.03749358654]
 [618551.7386090612, 90043.22751810504]
 [618534.5164765186, 90067.28344634948]
 [618529.3353801753, 90080.47448454147]
 [618534.6860401421, 90113.19691041029]
 [618533.8698945431, 90129.02705450279]
 [618539.5957786358, 90137.89724771577]
 [618537.6146868669, 90148.73332047701]
 [618531.8256332293, 90157.77730597286]
 [618532.1004785848, 90173.92247307178]
 [618526.1463479261, 90191.18453807387]
 [618516.5092321553, 90209.03254196598]
 [618521.5090552388, 90224.76079083]
 [618513.634043501, 90230.60770628125]
 [618505.5837186959, 90269.56795100754]
 [618487.7785875498, 90293.81787059274]
 [618484.9553654899, 90318.88507091253]
 [618499.9451149936, 90336.52452069093]
 [618503.9657188785, 90375.93898955607]
 [618486.7445750525, 90401.18392975189]
 [618482.8504433135, 90417.35402126682]
 [618428.3376672477, 90425.64811291469]
 [618406.4497217258, 90432.71478571034]
 [618375.599737404, 90449.1183892221]
 [618358.445677358, 90465.49024155525]
 [618339.2036845216, 90475.9969970192]
 [618321.75765507, 90489.31381336469]
 [618304.6456927201, 90495.35956278695]
 [618267.7774500316, 90542.52836571365]
 [618257.3172884963, 90565.6834079137]
 [618237.354165175, 90590.37129264187]
 [618221.7570256797, 90614.20924825528]
 [618224.1727044528, 90646.66661807321]
 [618227.6485224055, 90663.82785360393]
 [618232.2584283318, 90671.0490099635]
 [618232.3412611933, 90688.62418792673]
 [618225.6831236213, 90707.02725158102]
 [618229.1829531629, 90722.95247513361]
 [618212.5756427309, 90765.4055992724]
 [618209.4413561812, 90797.45486403536]
 [618200.2662010844, 90819.17891524508]
 [618141.3248681547, 90888.782541895]
 [618127.8469346254, 90889.6623055542]
 [618117.8199521864, 90893.67916348751]
 [618102.4660682501, 90890.42785154445]
 [618028.1851735092, 90922.80582540503]
 [618021.3972152974, 90922.37269758049]
 [617996.968241117, 90933.94836941999]
 [617990.0881971978, 90942.6063311981]
 [617977.7531897412, 90950.61218719326]
 [617968.8700323212, 90972.41024445854]
 [617962.3045337739, 91028.82169140862]
 [617952.8153521302, 91053.5287668552]
 [617929.0002175275, 91081.66061608886]
 [617914.1109695054, 91116.5276953161]
 [617904.3199863171, 91120.48555694596]
 [617890.2948670883, 91141.26651046649]
 [617881.0158309535, 91150.50743445137]
 [617863.683483834, 91197.25358850537]
 [617845.3483103239, 91226.28054640969]
 [617847.3182037618, 91236.36368348]
 [617842.6230812913, 91252.02575532247]
 [617825.568951949, 91275.6456822411]
 [617817.1507006946, 91307.06584457193]
 [617810.3426605113, 91315.28780327797]
 [617806.5094459156, 91340.15898325863]
 [617800.2532992446, 91359.28606149393]
 [617802.6521369653, 91374.99326283514]
 [617799.1120448877, 91386.77431672152]
 [617687.6224670117, 91407.51949693335]
 [617676.1085573741, 91404.73025948631]
 [617653.2246391284, 91409.50389113682]
 [617630.4856688265, 91419.68157968819]
 [617621.5636569749, 91426.15348236886]
 [617610.3407636476, 91421.4742312351]
 [617601.6127615288, 91426.80612600212]
 [617583.3577265531, 91441.17893823548]
 [617569.8775075807, 91472.15800405391]
 [617558.9923976533, 91490.11998638835]
 [617544.1304231454, 91496.13077638825]
 [617536.3472631297, 91517.55884994756]
 [617529.8022164794, 91526.30881873966]
 [617524.0322045954, 91530.93876026341]
 [617512.1543664135, 91520.82844268922]
 [617496.2699258248, 91576.58271352184]
 [617488.8028350982, 91590.51971761887]
 [617469.8938559331, 91599.3904627148]
 [617449.0949201358, 91604.79413862471]
 [617428.4890248857, 91605.80977398569]
 [617407.2540726577, 91613.20146192223]
 [617390.8181747054, 91612.06115149269]
 [617103.7292521707, 91666.48347556154]
 [617077.9613807569, 91668.0070221234]
 [617059.4644130912, 91675.42376011572]
 [617048.3894878755, 91674.02054456598]
 [617042.7865190153, 91674.01644260251]
 [617024.9935524967, 91680.90018804978]
 [616995.9035815819, 91694.85979904102]
 [616986.8195669493, 91701.71970267057]
 [616986.0936312207, 91695.3676256915]
 [616970.5597210333, 91694.9893393188]
 [616958.9467595137, 91697.72915558144]
 [616942.4359653896, 91685.68473431165]
 [616924.5570286067, 91689.48344722012]
 [616889.0045199328, 91658.48548927098]
 [616878.9945989221, 91656.01528238377]
 [616868.1716390382, 91658.12010664016]
 [616854.2397759431, 91651.83879014544]
 [616838.3300305584, 91634.30332467779]
 [616825.8650516404, 91639.37614886228]
 [616814.3412110083, 91629.31683823859]
 [616792.3824613912, 91615.76830276466]
 [616782.8705161158, 91615.56512769831]
 [616782.2055579614, 91611.54207520827]
 [616772.7526326256, 91609.2018797575]
 [616770.7336716802, 91606.26581355202]
 [616772.3577472685, 91597.34475352641]
 [616769.231769839, 91596.7946911429]
 [616768.5888969739, 91583.76554863126]
 [616763.222110636, 91564.37725634451]
 [616757.574230095, 91555.08706033176]
 [616746.2183231274, 91551.9238220021]
 [616743.454445013, 91540.68965893162]
 [616739.4465333243, 91533.72351608588]
 [616734.7565885425, 91530.64639987846]
 [616733.1476764546, 91522.31828699417]
 [616715.2730653626, 91491.77265515886]
 [616712.1342006727, 91479.34247326037]
 [616695.52042789, 91465.10802813152]
 [616693.7174859915, 91460.03694441811]
 [616683.2486148449, 91452.57767909137]
 [616670.0888540623, 91435.05626378742]
 [616639.4980917565, 91427.89763544756]
 [616629.9701219512, 91430.29048615484]
 [616619.2451998868, 91428.35027157993]
 [616589.8984733273, 91416.69462071786]
 [616581.9615175254, 91416.67947618662]
 [616571.4765234251, 91422.19434082811]
 [616559.2036150934, 91419.71209265279]
 [616558.3796042644, 91421.33609397049]
 [616546.4987127979, 91416.84583276787]
 [616546.5956603821, 91422.31588945024]
 [616506.8247750674, 91433.50127829479]
 [616503.0988632566, 91426.38313905007]
 [616478.9650138692, 91424.6276824153]
 [616470.2460294068, 91428.0925585988]
 [616465.1910710011, 91426.66545231623]
 [616460.191074155, 91429.259387407]
 [616453.2351372453, 91426.6782349584]
 [616441.6451765824, 91429.31405059327]
 [616421.6353523551, 91422.49161810234]
 [616407.2714489711, 91420.71133893784]
 [616389.1546310349, 91412.11792310316]
 [616377.7526884016, 91412.74272196734]
 [616354.420902312, 91403.84320819388]
 [616347.612912223, 91406.78311387033]
 [616333.3431313512, 91392.02970616482]
 [616329.0431537497, 91392.1846295021]
 [616318.1783005045, 91383.06934034592]
 [616309.6813922481, 91378.3691385878]
 [616300.5864205116, 91380.71199666895]
 [616285.1857159585, 91358.57349424603]
 [616277.9857987429, 91354.05831794102]
 [616270.2978326393, 91354.98418738674]
 [616266.0208059341, 91360.30316299002]
 [616262.6139065045, 91351.69301456974]
 [616241.8522071996, 91332.1384405685]
 [616234.5914166119, 91314.30712946069]
 [616226.14653882, 91306.36389609157]
 [616213.8636513591, 91301.68662569612]
 [616199.822819675, 91292.1572746088]
 [616166.0791276104, 91279.43753308]
 [616166.1481090683, 91281.35255356082]
 [616149.8172356558, 91277.5632184488]
 [616083.7388547126, 91250.9637493754]
 [616076.4150010172, 91239.82350429922]
 [616053.748239681, 91227.92497251465]
 [616050.2063649175, 91216.7927963139]
 [616004.1670677917, 91169.62648527292]
 [615991.119348287, 91147.68702765157]
 [615985.3344202789, 91143.48188020138]
 [615942.2647178856, 91137.31003476832]
 [615927.3947517287, 91142.44481582545]
 [615901.561052405, 91125.86117939072]
 [615898.3002441276, 91107.55393626704]
 [615894.6283186139, 91101.84881219387]
 [615869.5165754405, 91089.46623107222]
 [615842.041799256, 91081.9476557972]
 [615800.6512120824, 91062.64370906091]
 [615783.5713582408, 91057.2293440052]
 [615768.5665615812, 91044.57094396598]
 [615759.5425842556, 91047.46180884117]
 [615755.5236333084, 91044.64170741921]
 [615751.4966373406, 91046.57365356249]
 [615743.6837645279, 91037.73542270454]
 [615723.8369090976, 91034.10802525691]
 [615707.5720008258, 91033.9557278558]
 [615693.9841376613, 91027.4804156726]
 [615693.0731873282, 91022.77635187241]
 [615681.0242514348, 91023.06913563151]
 [615675.6073443737, 91016.43997053966]
 [615644.1545806982, 91009.9303330319]
 [615632.6627578145, 90997.98100401775]
 [615624.212851998, 90992.99580025674]
 [615623.0829035817, 90988.21773172889]
 [615590.3441413093, 90982.31307690604]
 [615579.7233020854, 90971.57677591058]
 [615573.1593657702, 90968.70362766161]
 [615525.3986023173, 90971.7157891042]
 [615496.5586801843, 90980.3853515284]
 [615490.989736943, 90977.66022286711]
 [615484.3147371032, 90981.55014050024]
 [615482.6588242725, 90973.32802782409]
 [615475.0958679892, 90973.14488841187]
 [615461.1359826762, 90969.22259508967]
 [615412.7353306828, 90960.8566306555]
 [615393.9144485891, 90959.4402740695]
 [615383.7344817681, 90961.90011358715]
 [615351.8825497603, 90973.37364937442]
 [615309.5517067263, 90981.59896193106]
 [615257.5219128208, 90990.32110304688]
 [615243.65598889, 90990.41585176649]
 [615243.0399955335, 90990.0758371476]
 [615235.1080810938, 90985.69664889247]
 [615228.4080710473, 90990.6775770265]
 [615209.135171031, 90991.41523384364]
 [615179.9872853201, 90996.424753922]
 [615137.8064417649, 91004.61706887619]
 [615089.380675167, 91008.35022546147]
 [615044.2379247708, 91008.45340531897]
 [615027.6010254482, 91007.57509386563]
 [615016.8831651788, 90999.1148139572]
 [615012.0172960658, 90988.16161547064]
 [615010.1742983124, 90989.003590399]
 [614998.3793126388, 90994.39642998432]
 [614979.5543355104, 91003.00317395908]
 [614972.4513441256, 91006.25207737212]
 [614964.477394972, 91005.55792534917]
 [614957.2693969532, 91009.56783449254]
 [614949.7684330792, 91010.14870387723]
 [614942.6264674732, 91010.70257951872]
 [614933.7824651068, 91016.12847311987]
 [614930.7334642756, 91018.00043644893]
 [614926.6334781888, 91018.93337123633]
 [614919.3345029348, 91020.59625515749]
 [614906.3025030929, 91028.20709451189]
 [614881.8265530744, 91037.26274019596]
 [614878.8015469322, 91039.68070944719]
 [614865.588569644, 91045.0195226946]
 [614838.3946334721, 91054.20612025612]
 [614810.1287392795, 91059.59366017242]
 [614777.9118920362, 91062.34310173115]
 [614758.4050043476, 91061.9177426164]
 [614749.4850608729, 91061.17857293526]
 [614742.7231037179, 91060.61844430443]
 [614714.9572896475, 91057.26490555561]
 [614704.663358579, 91056.02170582316]
 [614657.5096189101, 91056.17084956098]
 [614643.9606966539, 91055.90360041302]
 [614635.0487925, 91051.01338920038]
 [614606.0229015101, 91056.50791636678]
 [614600.4929086859, 91058.98784067179]
 [614594.7159162016, 91061.57676157907]
 [614588.6079618301, 91060.340638059]
 [614575.8630570546, 91057.75938030423]
 [614552.7650785968, 91069.0070730646]
 [614529.0081007547, 91080.57575706243]
 [614522.4881174109, 91082.63565913994]
 [614504.7531627209, 91088.23839278167]
 [614460.4482073935, 91109.45979990967]
 [614418.1053611336, 91118.0321157348]
 [614416.2633640553, 91118.80208995787]
 [614406.3143799083, 91122.95395066333]
 [614404.1384175438, 91120.25888402193]
 [614403.6584198474, 91120.29687567064]
 [614376.7205500363, 91122.33640613264]
 [614368.8615880179, 91122.93126914426]
 [614367.4395995643, 91122.54623940992]
 [614360.8416531552, 91120.75710142862]
 [614336.0217869767, 91121.17365412026]
 [614320.7218694692, 91121.43037838132]
 [614316.1289070965, 91120.1512819908]
 [614309.7709591825, 91118.38014855147]
 [614278.9900402657, 91127.8466836714]
 [614263.5201036644, 91130.21642605655]
 [614252.1621064632, 91136.5692832306]
 [614230.1901798641, 91141.68993495795]
 [614224.2251860002, 91144.53385500464]
 [614217.5741928788, 91147.70176582257]
 [614205.5592475953, 91148.96455994154]
 [614193.787301211, 91150.2013582192]
 [614174.1113291817, 91158.76808631304]
 [614159.5603805557, 91161.86785274507]
 [614152.4093801815, 91166.09276507999]
 [614147.8643799488, 91168.77770936297]
 [614137.7064372087, 91168.68552365752]
 [614127.9064493382, 91173.14239013518]
 [614114.5114659193, 91179.23420763438]
 [614106.1544128134, 91189.72516094505]
 [614102.3853888473, 91194.4581399027]
 [614092.109410935, 91198.14398998306]
 [614079.1944386854, 91202.7768015663]
 [614066.5974311297, 91210.94665444274]
 [614050.3895611687, 91206.72131718641]
 [614028.704597944, 91215.53601122453]
 [614025.642603135, 91216.78096802525]
 [614013.1646993158, 91213.94271254783]
 [614006.3817515924, 91212.40057367877]
 [614002.5367812319, 91211.52549495024]
 [614001.0247928891, 91211.18146399154]
 [613989.12284287, 91212.87726451179]
 [613979.710882383, 91214.22010678268]
 [613966.2129805459, 91211.7698366466]
 [613928.716557233, 91172.90876439148]
 [613923.7256018191, 91171.12865572897]
 [613904.0858802594, 91153.26411910681]
 [613893.8660251442, 91143.96883987682]
 [613887.5890349521, 91146.6087521997]
 [613878.6060489746, 91150.38762673282]
 [613868.6031513527, 91145.44739517149]
 [613858.1763133365, 91134.47009528853]
 [613855.6014203161, 91124.69695032394]
 [613846.5525544047, 91115.85469694143]
 [613849.2266570933, 91103.4616211576]
 [613849.5116680302, 91102.1416130888]
 [613848.1166817015, 91101.51658143775]
 [613831.7118423478, 91094.17920935691]
 [613821.5868495867, 91099.34207701121]
 [613815.2978540814, 91102.5489948066]
 [613814.1428549098, 91103.13797971142]
 [613810.7768322349, 91107.49896226385]
 [613803.0078876885, 91106.19880789073]
 [613797.1319296209, 91105.21669114179]
 [613792.2369354933, 91107.46262464732]
 [613782.5719470801, 91111.89749336007]
 [613770.0770031181, 91113.30228017415]
 [613767.8040638163, 91108.23218792315]
 [613765.4971254361, 91103.08509428088]
 [613761.5591265728, 91105.2700445857]
 [613759.9641270345, 91106.15502445484]
 [613756.8341699596, 91103.46094047156]
 [613755.3621901384, 91102.19490098146]
 [613751.5451973834, 91103.66484630885]
 [613747.2592055287, 91105.31478490782]
 [613743.7052317992, 91104.62471332891]
 [613741.8602454468, 91104.26567616522]
 [613741.0832403682, 91105.25567196905]
 [613739.3682291571, 91107.44166272003]
 [613712.0233620494, 91109.43418530468]
 [613709.937379206, 91108.84614145562]
 [613702.6194393749, 91106.78498764244]
 [613695.920446316, 91109.97389779966]
 [613688.3854541148, 91113.56179675566]
 [613678.7795386408, 91110.27158898438]
 [613665.2646575534, 91105.64329667231]
 [613641.4530184093, 91081.53062142465]
 [613634.7360844035, 91078.50346884706]
 [613615.6802716285, 91069.91503598052]
 [613601.013504465, 91053.94860887888]
 [613581.5307253884, 91042.05713507942]
 [613564.5418804955, 91035.64576167136]
 [613563.356914356, 91032.7687112298]
 [613562.1949475638, 91029.94766177052]
 [613557.4090085262, 91026.32053829395]
 [613556.7190173056, 91025.79852050156]
 [613556.487027445, 91024.86550691181]
 [613554.0601334689, 91015.10636478216]
 [613548.4171732346, 91014.21625319545]
 [613532.4652856368, 91011.70093776536]
 [613527.8103184367, 91010.96684572061]
 [613525.0163342403, 91010.93579458485]
 [613499.812476804, 91010.65533329267]
 [613486.0946082034, 91004.82902525736]
 [613478.9466766674, 91001.79386475802]
 [613468.5897538848, 90999.71365547483]
 [613463.3147932112, 90998.65454888591]
 [613461.2318210286, 90996.94049378432]
 [613453.2349278416, 90990.35828223063]
 [613443.5279943305, 90989.02909230982]
 [613423.8331291975, 90986.3357070051]
 [613414.2172824027, 90975.80942640053]
 [613406.2923604785, 90972.21524615424]
 [613392.0235602469, 90959.50285895991]
 [613387.9826736369, 90949.91168915869]
 [613387.4976872362, 90948.76166879163]
 [613386.4916957313, 90948.45464740928]
 [613362.4378986945, 90941.13213633501]
 [613358.2610332333, 90929.39094247132]
 [613355.5431207087, 90921.75781639187]
 [613339.4713197183, 90910.18040779665]
 [613336.2083601216, 90907.83032484449]
 [613329.2513939677, 90908.33320334402]
 [613325.3984991643, 90899.49604452969]
 [613315.7526120136, 90893.24280628262]
 [613311.0147712951, 90879.22057931303]
 [613310.6237844301, 90878.06456059459]
 [613271.4170036124, 90877.90084575082]
 [613252.9371069247, 90877.82350881308]
 [613247.597136776, 90877.80141145368]
 [613227.6122156584, 90881.18108184598]
 [613221.0392416002, 90882.29297344237]
 [613209.0672888536, 90884.31777599601]
 [613208.3472916905, 90884.43976412492]
 [613207.3842981462, 90884.32274543008]
 [613194.4333851098, 90882.73349389026]
 [613183.1084265386, 90884.99331056837]
 [613181.9724306917, 90885.22029218466]
 [613181.4184343385, 90885.16028150216]
 [613166.0455355222, 90883.48898507858]
 [613161.2995409939, 90885.68992084489]
 [613158.4805442354, 90886.99788269594]
 [613157.3205580526, 90886.21985378637]
 [613155.7675765564, 90885.17781507479]
 [613141.5126484226, 90885.94356345528]
 [613134.3526577435, 90889.15146541868]
 [613128.7086650972, 90891.6793881284]
 [613119.6026943357, 90893.92624504484]
 [613106.1607375311, 90897.23903378849]
 [613103.449716637, 90901.02902252431]
 [613103.1277141558, 90901.47902118419]
 [613102.3127176639, 90901.58600743387]
 [613095.7087461968, 90902.44289590721]
 [613076.4287288861, 90915.5526768142]
 [613063.6227173799, 90924.26153130116]
 [613057.4847337457, 90926.12843839359]
 [613056.7847356122, 90926.34142779808]
 [613056.5397339741, 90926.65742651375]
 [613052.007703621, 90932.51040283772]
 [613028.6007463234, 90941.70806939444]
 [613018.3727957685, 90942.48089110223]
 [613008.57784313, 90943.21972034352]
 [613000.3839033834, 90941.66255565606]
 [612974.6579958302, 90946.97214099213]
 [612973.1090013909, 90947.29211602786]
 [612956.9691007374, 90946.26381210699]
 [612934.6752379779, 90944.84139228707]
 [612907.4994052456, 90943.10988055341]
 [612898.6504516739, 90943.39372243665]
 [612874.6184445374, 90958.2124340584]
 [612849.1493803255, 90979.89018840613]
 [612818.361408117, 90994.97977985366]
 [612777.3917214002, 90985.92594368661]
 [612744.2670896623, 90966.48314592087]
 [612722.1372464407, 90962.90470743462]
 [612669.7995228391, 90964.39377032884]
 [612627.354783556, 90961.74597164633]
 [612574.8071756081, 90951.16290951251]
 [612543.0503373824, 90952.69234719127]
 [612536.7983960434, 90950.16620810091]
 [612510.9524690966, 90957.59081249092]
 [612489.838587581, 90957.45542705452]
 [612422.2637819775, 90976.50938912762]
 [612405.9927865628, 90985.54918391083]
 [612341.5760221337, 90998.41314128097]
 [612294.0593335286, 90993.39022648986]
 [612252.1675055011, 90999.77652856719]
 [612211.2436687951, 91006.51085175166]
 [612206.9996592943, 91009.99680954752]
 [612200.8427077525, 91008.49068242962]
 [612188.1377425074, 91012.26248918698]
 [612178.2717975673, 91012.23130940246]
 [612116.0549672467, 91030.75536362309]
 [612111.0630170562, 91028.4252494195]
 [612085.0021398225, 91030.73379853321]
 [612050.8233403517, 91029.59416535721]
 [612022.1934794664, 91031.68266552755]
 [611997.5605641749, 91037.16827251612]
 [611982.8726618903, 91035.46198820169]
 [611974.4137482211, 91031.30979264084]
 [611963.3108009578, 91032.2476000876]
 [611931.0760488526, 91024.97594070577]
 [611919.3650824408, 91028.28876093769]
 [611911.3130740847, 91033.88267063028]
 [611904.8231984258, 91024.5704590765]
 [611897.9182811767, 91019.88628644124]
 [611892.9652116912, 91030.11229901202]
 [611884.1892535688, 91030.83314660972]
 [611866.0583849028, 91027.59678430593]
 [611858.6444732394, 91022.62159948867]
 [611839.416512971, 91029.68632065138]
 [611821.3806127491, 91029.72199292308]
 [611809.8146255314, 91035.14383696431]
 [611792.5037005892, 91037.3615443352]
 [611783.2717987995, 91032.40932668022]
 [611778.5248782677, 91026.80818409454]
 [611697.0104508556, 91014.14357413564]
 [611672.3896833203, 91004.04202484651]
 [611655.6168112451, 91000.37068287581]
 [611633.4558866064, 91005.39533020415]
 [611626.9849402606, 91003.52519371573]
 [611618.230942933, 91008.36708308826]
 [611603.9749982535, 91010.87784897129]
 [611599.0269820762, 91015.47980516982]
 [611584.7450053523, 91021.38460465353]
 [611575.5100725401, 91019.70541980687]
 [611568.9830370846, 91027.26437696535]
 [611559.6521064164, 91025.41518866392]
 [611558.4860827763, 91028.59019933158]
 [611552.3301153847, 91028.7550890048]
 [611544.2510853373, 91036.65202132805]
 [611525.4361455363, 91041.31672590888]
 [611490.9751407242, 91061.9943066453]
 [611485.4150573661, 91074.03832642695]
 [611474.8900434267, 91081.6682115739]
 [611452.6950510234, 91093.85793021992]
 [611431.4330907429, 91102.11462634843]
 [611406.0081171606, 91114.21028529396]
 [611386.118175712, 91119.67797837738]
 [611370.9862259291, 91123.23973887673]
 [611348.8303472302, 91123.41733763256]
 [611342.6663003212, 91131.97131138515]
 [611330.6903333223, 91135.50112897546]
 [611322.6302344323, 91150.64613441436]
 [611296.6011363245, 91176.22591775401]
 [611273.61721554, 91181.32555086004]
 [611261.3931947416, 91190.67342235193]
 [611248.7862510186, 91192.11820752926]
 [611230.3552309101, 91205.02600185256]
 [611229.0651638232, 91212.85505699004]
 [611232.768088301, 91218.65118254267]
 [611220.7080198909, 91232.92310645392]
 [611211.1567942268, 91262.30822773946]
 [611201.0076918997, 91279.03821109225]
 [611196.5646906531, 91281.770157701]
 [611181.5794323707, 91317.7752466041]
 [611181.8993879455, 91322.27229757677]
 [611168.2154565934, 91323.04305639697]
 [611160.8594100159, 91332.26001512146]
 [611160.7922309046, 91351.18520391175]
 [611157.4752340503, 91352.79515973697]
 [611159.0161809193, 91357.49523496018]
 [611155.5090904889, 91369.08328750901]
 [611139.9270743431, 91379.9061127233]
 [611132.2859699271, 91395.38812916877]
 [611125.6750267615, 91393.26498759499]
 [611115.3259810728, 91404.13990852471]
 [611111.4998862182, 91416.38096182763]
 [611101.985841358, 91426.67989216236]
 [611089.06685339, 91432.97272033956]
 [611092.3767620655, 91440.66485777704]
 [611087.839603975, 91459.9899692691]
 [611079.8035275898, 91472.74795118072]
 [611054.0562461849, 91517.48993203476]
 [611052.967811246, 91563.98837908592]
 [611057.9645145093, 91592.35275476165]
 [611081.0419472903, 91638.6546394357]
 [611113.956344112, 91682.9906833079]
 [611121.5611817179, 91695.6629488784]
 [611124.8135819533, 91757.0006238817]
 [611132.835918254, 91822.28742530048]
 [610846.8741073562, 92726.01929349033]
 [610690.7039557701, 92813.49632665874]
 [610676.1741597605, 92807.62100349487]
 [610621.5955438729, 92833.47526893957]
 [610566.4842266856, 92883.68976834966]
 [610633.000637002, 92967.9998220417]
````

### Crop and mask raster

Read it and select Zermatt (3920)

````julia
ra_z = crop(ra; to = tab.geometry[zermatt])
mask_z = mask(ra_z, with = tab.geometry[zermatt])
plot(mask_z)
````

````
Plot{Plots.PlotlyBackend() n=1}
Captured extra kwargs:
  Series{1}:
    tickcolor: RGB{Float64}(0.3,0.3,0.3)

````

# Exercise

- Download the Swiss Glacier Inventory 2016 from https://www.glamos.ch/en/downloads#inventories/B56-03
- look up Gornergletscher
- plot it into the last plot we just did
- mask the elevation map with the Gornergletscher outline and calculate the mean elevation

# Exercise solution

````julia
!isfile("data/sgi.zip") && Downloads.download("https://doi.glamos.ch/data/inventory/inventory_sgi2016_r2020.zip", "data/sgi.zip")
zip = ZipFile.Reader("data/sgi.zip")
for f in zip.files
    name = basename(f.name)
    if startswith(name, "SGI_2016_glaciers")
        write("data/$(name)", read(f))
    end
end
close(zip)
````

````julia
using Shapefile
sgi = Shapefile.Table("data/SGI_2016_glaciers.shp")
ind = findfirst(skipmissing(sgi.name.=="Gornergletscher"))

plot(sgi.geometry[ind])
````

````
Plot{Plots.PlotlyBackend() n=1}
````

load DHM again with the CRS (coord reference system) specifed

````julia
ra = Raster("data/dhm200.asc", crs=EPSG(21781))

ra_z = crop(ra; to = tab.geometry[zermatt])
mask_z = mask(ra_z, with = tab.geometry[zermatt])
````

````
128×80×1 Raster{Float32,3} with dimensions: 
  X Projected{Float64} LinRange{Float64}(610700.0, 636100.0, 128) ForwardOrdered Regular Intervals crs: EPSG,
  Y Projected{Float64} LinRange{Float64}(101100.0, 85300.0, 80) ReverseOrdered Regular Intervals crs: EPSG,
  Band Categorical{Int64} 1:1 ForwardOrdered
extent: Extent(X = (610700.0, 636300.0), Y = (85300.00000000001, 101300.0), Band = (1, 1))missingval: -9999.0
crs: EPSG:21781
values: [:, :, 1]
           101100.0  100900.0  …  85900.0  85700.0  85500.0  85300.0
 610700.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 610900.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 611100.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 611300.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 611500.0   -9999.0   -9999.0  …  -9999.0  -9999.0  -9999.0  -9999.0
      ⋮                        ⋱                        ⋮    
 635100.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 635300.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 635500.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 635700.0   -9999.0   -9999.0  …  -9999.0  -9999.0  -9999.0  -9999.0
 635900.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
 636100.0   -9999.0   -9999.0     -9999.0  -9999.0  -9999.0  -9999.0
````

The shapefile for Gorner is in the newer LV95 coordinates.
-> transform the raster to LV95 (only the already cropped one)

````julia
lv95 = EPSG(2056)
ra_z_95 = resample(ra_z, 1, crs=lv95)
````

````
25600×16000×1 Raster{Float32,3} with dimensions: 
  X Projected{Float64} LinRange{Float64}(2.6107e6, 2.6363e6, 25600) ForwardOrdered Regular Intervals crs: WellKnownText,
  Y Projected{Float64} LinRange{Float64}(1.1013e6, 1.0853e6, 16000) ReverseOrdered Regular Intervals crs: WellKnownText,
  Band Categorical{Int64} 1:1 ForwardOrdered
extent: Extent(X = (2.6107e6, 2.6363e6), Y = (1.0853000000000042e6, 1.1013000000000042e6), Band = (1, 1))missingval: -9999.0
crs: PROJCS["CH1903+ / LV95",GEOGCS["CH1903+",DATUM["CH1903+",SPHEROID["Bessel 1841",6377397.155,299.1528128,AUTHORITY["EPSG","7004"]],AUTHORITY["EPSG","6150"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4150"]],PROJECTION["Hotine_Oblique_Mercator_Azimuth_Center"],PARAMETER["latitude_of_center",46.9524055555556],PARAMETER["longitude_of_center",7.43958333333333],PARAMETER["azimuth",90],PARAMETER["rectified_grid_angle",90],PARAMETER["scale_factor",1],PARAMETER["false_easting",2600000],PARAMETER["false_northing",1200000],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","2056"]]
values: [:, :, 1]
               1.1013e6     1.1013e6  …      1.0853e6      1.0853e6
 2.6107e6   2901.59      2901.59         -9999.0       -9999.0
 2.6107e6   2901.59      2901.59         -9999.0       -9999.0
 2.6107e6   2901.59      2901.59         -9999.0       -9999.0
 2.6107e6   2901.59      2901.59         -9999.0       -9999.0
 2.6107e6   2901.59      2901.59      …  -9999.0       -9999.0
 ⋮                                    ⋱      ⋮         
 2.63629e6  3289.78      3289.78         -9999.0       -9999.0
 2.6363e6   3289.78      3289.78         -9999.0       -9999.0
 2.6363e6   3289.78      3289.78         -9999.0       -9999.0
 2.6363e6   3289.78      3289.78      …  -9999.0       -9999.0
 2.6363e6   3289.78      3289.78         -9999.0       -9999.0
 2.6363e6   3289.78      3289.78         -9999.0       -9999.0
````

````julia
mask_gor = mask(ra_z_95, with = sgi.geometry[ind])
using Plots
plot(mask_gor)
````

````
Plot{Plots.PlotlyBackend() n=1}
Captured extra kwargs:
  Series{1}:
    tickcolor: RGB{Float64}(0.3,0.3,0.3)

````

mean elevation, just count the not masked points (mask is -9999)

````julia
using Statistics
mean(mask_gor[mask_gor[:].>0])
````

````
3355.8535f0
````

