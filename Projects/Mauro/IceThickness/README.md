## Data
1) surface_dem_rhone_2007.asc --> glacier surface topography for the year 2007
2) bedrock_rhone.asc -->  glacier bedrock topography (nicht mehr die allerneuste Schätzung, aber für eine Übung auf jeden Fall ok)
3) glacier_mask_rhone_2007.asc --> mask flagging the glacier extent: 1=glacier, 0=no glacier
4) glacier_outline_rhone_2007.txt --> glacier outline
5) flowline_rhone_2007.txt --> (manually digitized) glacier flowline

Formats:

"1-3)" are ascii grids. Description here.

"4)" is a column-organized text file, with "x_coord, y_coord, nn". Here, "nn" is a flag required for determining rock outcrops: nn=21 --> begin of a segment; nn=23 --> end of a segment; nn=20 --> "home" point, nn=22 --> everything else. (weitere Erklärung wohl eher mündlich)

"5)" is a column organized text file with "x_coord, y_coord, z_surface, z_bedrock"

All coordinates are in the CH1903/LV03 coordinate system.
