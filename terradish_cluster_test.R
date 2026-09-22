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
covariates <- scale_covariates(covariates_cropped)

surface <- conductance_surface(
  covariates,
  nd2_coords,
  directions = 8,
  saveStack  = TRUE
)

fit_IBD <- terradish(
  gendist ~ 1,
  data              = surface,
  conductance_model = loglinear_conductance,
  measurement_model = mlpe
)

fit_HLI <- terradish(
  gendist ~ HLI,          # replace with your covariate name(s)
  data              = surface,
  conductance_model = loglinear_conductance,
  measurement_model = mlpe
)


# Inspect grid_result for a well-defined single peak vs. a flat ridge or
# multiple peaks. A flat/ridge-shaped surface at your sample size is a strong
# signal that the parameter isn't well identified with this much data --
# report that honestly rather than over-interpreting the point estimate.

theta_grid <- as.matrix(expand.grid(
  HLI = seq(-1, 1, length.out = 21)
))

grid_result <- terradish_grid(
  theta             = theta_grid,
  formula           = gendist ~ HLI,
  data              = surface,
  conductance_model = loglinear_conductance,
  measurement_model = mlpe
)


summary(fit_IBD)
summary(fit_HLI)


aic_table(
  list(fit_IBD, fit_HLI),
  mod_names = c("IBD", "HLI"),
  AICc      = TRUE
)

# Likelihood ratio test as a cross-check for nested comparisons (e.g., does
# adding altitude improve on the forest-cover-only model?) 
#**don't need for test, but will later
# anova(fit_ibd, fit_covA)

## cross validation
cv_reps_IBD <- terradish_cv_replicates(
  pts        = nd2_coords,
  covariates = covariates,
  fmla       = gendist ~ 1,
  model      = mlpe,
  seeds      = 1:3          # change to 20 for actual pipeline
)                             
summary(cv_reps_IBD)

cv_reps_HLI <- terradish_cv_replicates(
  pts        = nd2_coords,
  covariates = covariates,
  fmla       = gendist ~ HLI,
  model      = mlpe,
  seeds      = 1:3          # change to 20 for actual pipeline
)                             
summary(cv_reps_HLI)

# Compare candidate models on held-out predictive likelihood
cv_IBD  <- terradish_cv_replicates(pts = nd2_coords, covariates = covariates,
                                   fmla = gendist ~ 1, model = mlpe, seeds = 1:3)
cv_HLI <- terradish_cv_replicates(pts = nd2_coords, covariates = covariates,
                                   fmla = gendist ~ HLI,
                                   model = mlpe, seeds = 1:3)

cv_model_selection(
  list(cv_IBD, cv_HLI),
  cv_names = c("IBD", "HLI"),
  aic      = TRUE
)

# ---- 9. Visualize and report honestly ----------------------------------------

plot(fit_IBD, data = surface)                    # marginal associations, default
plot(fit_HLI, type = "surface", data = surface)  # fitted conductance surface + 95% CI
plot(fit_HLI, type = "fit")                       # observed vs. fitted

# Constrain predictions to the well-supported covariate range -- with few
# samples your covariate range is narrow, and extrapolated tails of the
# fitted surface are the least trustworthy part of the output.
plot(fit_HLI, type = "marginal", data = surface,
     support = "focal", support_probs = c(0.01, 0.99),
     clamp_covariates = c("HLI"))


