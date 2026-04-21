# Updated raster stack

library(spatialEco)
library(terra)

# jobs to do:
# 1. calculate hli from elevation
# 2. calculated stdev focal areas with terra::focal(input, win = x, fun = sd, na.rm = TRUE)
# for canopy height both years, then subtract rasters
# 3. and canopy cover both years, then subtract rasters
# 4. subtract impervious surface rasters
# 5. convert CRS, crop, make stack

setwd("/scratch/las80898/bonasa/updated_tifs")

## job 1 - done
elevation_untrimmed <- rast("elevation.tif")
HLI_untrimmed <- hli(elevation_untrimmed, force.hemisphere = "northern")

## job 2 - done
# CH_2000
CH_2000_untrimmed <- rast("canopy_height_2000.tif")
CH_2000_untrimmed_focal <- focal(CH_2000_untrimmed, win = 3, fun = sd, na.rm = TRUE)
# CH_2019
CH_2019_untrimmed <- rast("canopy_height_2019.tif")
CH_2019_untrimmed_focal <- focal(CH_2019_untrimmed_resample, win = 3, fun = sd, na.rm = TRUE)
# subtract rasters
CH_difference_untrimmed <- CH_2019_untrimmed_focal - CH_2000_untrimmed_focal

## job 3
# CC_1985
CC_1985_untrimmed <- rast("canopy_cover_1985.tif")
CC_1985_untrimmed_reprojected <- project(CC_1985_untrimmed, crs(CH_2000_untrimmed))
# resample 
CC_1985_untrimmed_resample <- resample(CC_1985_untrimmed_reprojected, CH_2000_untrimmed, method = "bilinear")
# compute focal window
CC_1985_untrimmed_focal <- focal(CC_1985_untrimmed_resample, win = 3, fun = sd, na.rm = TRUE)
# CC_2023
CC_2023_untrimmed <- rast("canopy_cover_2023.tif")
CC_2023_untrimmed_reprojected <- project(CC_2023_untrimmed, crs(CH_2000_untrimmed))
# resample 
CC_2023_untrimmed_resample <- resample(CC_2023_untrimmed_reprojected, CH_2000_untrimmed, method = "bilinear")
# compute focal window
CC_2023_untrimmed_focal <- focal(CC_2023_untrimmed_resample, win = 3, fun = sd, na.rm = TRUE)
# subtract rasters
CC_difference_untrimmed <- CC_2023_untrimmed_focal - CC_1985_untrimmed_focal

## job 4 - done
# imp_surf 1985
imp_surf_1985_untrimmed <- rast("imp_surf_1985.tif")
imp_surf_2024_untrimmed <- rast("imp_surf_2024.tif")
imp_surf_difference_untrimmed <- imp_surf_2024_untrimmed - imp_surf_1985_untrimmed


## job 5 - 
# set extent of study area
my_extent <- ext(-84.8, -82.6, 34.4, 35.8)
study_area_extent <- rast(my_extent)

# project CRS onto other layers
# ex: raster_with_new_projection <- project(raster_to_change, crs(raster_with_extent_I_want)
imp_surf_difference_untrimmed_a <- project(imp_surf_difference_untrimmed, crs(CH_difference_untrimmed))
HLI_untrimmed_a <- project(HLI_untrimmed, crs(CH_difference_untrimmed))
study_area_extent_a <- project(study_area_extent, crs(CH_difference_untrimmed))

# crop to study area
HLI_a <- crop(HLI_untrimmed_a, study_area_extent_a)
CH_a <- crop(CH_difference_untrimmed, study_area_extent_a)
CC_a <- crop(CC_difference_untrimmed, study_area_extent_a)
imp_surf_a <- crop(imp_surf_difference_untrimmed_a, study_area_extent_a)

# save as tifs to check interactively
writeRaster(HLI_a, "/scratch/las80898/bonasa/temp_tifs/HLI_A.tif", overwrite=TRUE)
writeRaster(CH_a, "/scratch/las80898/bonasa/temp_tifs/CH_a.tif", overwrite=TRUE)
writeRaster(CC_a, "/scratch/las80898/bonasa/temp_tifs/CC_a.tif", overwrite=TRUE)
writeRaster(imp_surf_a, "/scratch/las80898/bonasa/temp_tifs/imp_surf_a.tif", overwrite=TRUE)


# plot(HLI)
# plot(imp_surf)
# plot(CH_difference_untrimmed)
# plot(CC_difference_untrimmed)

#sink("/scratch/las80898/pcadapt_output/GFMxWM_snp_pc_associations.txt")
#print(snp_pc)
#sink()

# validate crop
#crs(HLI)
#crs(CH)
#crs(CC)
#crs(imp_surf)

#res(HLI)
#res(CH)
#res(CC)
#res(imp_surf)

#ext(HLI)
#ext(CH)
#ext(CC)
#ext(imp_surf)

# If resolution or extent differs, resample to match a reference layer




# make raster stack
#updated_stack <- c(HLI, CH, CC, imp_surf)

# change variable names??
#names(updated_stack) <- c("HLI", "CH", "CC", "imp_surf")

# Final check
#print(updated_stack)
#nlyr(updated_stack)   # Should equal number of layers - ...


# save
#writeRaster(updated_stack, "updated_stack.tif", overwrite = TRUE)   


