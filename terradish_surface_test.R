#testing terradish again
library(terradish)
library(terra)

set.seed(42)

# ---- 1. Import data ----------------------------------------------------
nd2_gendist <- as.matrix(read.csv("/scratch/las80898/terradish/nd2_genetic_distance_matrix.csv", row.names = 1, check.names = FALSE))
covariates <- rast("/scratch/las80898/terradish/september_stack.tif")
nd2_coords_df <- read.csv("/scratch/las80898/terradish/nd2_coords_reduced.csv")

# ---- 2. Align sample IDs between coords and gendist BEFORE anything else ----
setdiff(nd2_coords_df$sample_id, rownames(nd2_gendist))   # should be character(0)
setdiff(rownames(nd2_gendist), nd2_coords_df$sample_id)   # should be character(0)

#checks
length(setdiff(nd2_coords_df$sample_id, rownames(nd2_gendist)))   # should be 0
length(setdiff(rownames(nd2_gendist), nd2_coords_df$sample_id))   # should be 0

nd2_gendist <- nd2_gendist[nd2_coords_df$sample_id, nd2_coords_df$sample_id]

# ---- 3. Points as a SpatVector, in their ORIGINAL geographic CRS -----------
# Only one reprojection pass is needed -- do it once, at the end, not twice.
nd2_coords_vect <- terra::vect(
  nd2_coords_df,
  geom = c("x", "y"),
  crs  = "EPSG:4326"      # confirm this matches how nd2_coords_reduced.csv was recorded
)

# ---- 4. Determine an appropriate UTM zone from the points' centroid --------
centroid <- terra::centroids(terra::aggregate(nd2_coords_vect))
lon <- terra::crds(centroid)[1, 1]
lat <- terra::crds(centroid)[1, 2]

utm_zone        <- floor((lon + 180) / 6) + 1
hemisphere_code <- if (lat >= 0) "326" else "327"
target_crs      <- paste0("EPSG:", hemisphere_code, sprintf("%02d", utm_zone))
target_crs   # sanity check -- should be a real UTM EPSG code for your region

# ---- 5. Reproject raster and points ONCE, to the same target CRS -----------
covariates      <- terra::project(covariates, target_crs)
nd2_coords_vect <- terra::project(nd2_coords_vect, target_crs)

# Pull coordinates back into a plain numeric matrix, with sample IDs preserved
# directly from the source data.frame (not from the SpatVector, which has no rownames)
nd2_coords <- terra::crds(nd2_coords_vect)
rownames(nd2_coords) <- nd2_coords_df$sample_id
storage.mode(nd2_coords) <- "double"

# Confirm units and ID alignment before proceeding
terra::linearUnits(covariates)                        # should be 1 (meters)
identical(rownames(nd2_coords), rownames(nd2_gendist)) # must be TRUE
identical(rownames(nd2_coords), colnames(nd2_gendist)) # must be TRUE

# ---- 6. Crop raster to a buffered extent around the points -----------------
site_ext   <- terra::ext(nd2_coords)   # ext() on a 2-col matrix builds bbox directly
buffer_dist <- 5000                    # meters, now that units are confirmed as meters
site_ext   <- site_ext + buffer_dist

covariates_cropped <- terra::crop(covariates, site_ext)
terra::ncell(covariates)           # before
terra::ncell(covariates_cropped)   # after -- should now be dramatically smaller

# ---- 7. Scale and build the conductance graph -------------------------------

# Aggregate before building the graph -- fact=3 takes 30m -> 90m,
# cutting cell count by ~9x; fact=5 -> 150m, cutting by ~25x
covariates_agg <- terra::aggregate(covariates_cropped, fact = 3, fun = "mean")
terra::ncell(covariates_agg)   # compare against 17,545,892

covariates_agg <- scale_covariates(covariates_agg)


surface_test <- conductance_surface(
  covariates_agg,
  nd2_coords,
  directions = 8,
  saveStack  = TRUE
)

# NOW benchmark using the graph object, not the raster
terradish_solver_benchmark(surface_test, n_replicates = 2)



assessment <- terradish_assess_settings(
  nd2_gendist ~ 1, data = covariates,
  conductance_model = loglinear_conductance,
  measurement_model = mlpe,
  probe_maxit = 2, coarse_probe = TRUE
)
assessment$recommended