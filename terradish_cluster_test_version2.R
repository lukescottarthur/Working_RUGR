library(terradish)
library(terra)

set.seed(42)

# need to move these files into accessible area
nd2_gendist    <- as.matrix(read.csv("/scratch/las80898/terradish/nd2_genetic_distance_matrix.csv", row.names = 1))
covariates <- rast("/scratch/las80898/terradish/september_stack.tif")

##### importing and fixing coords
nd2_coords_a  <- read.csv("/scratch/las80898/terradish/nd2_coords_reduced.csv")
original_crs <- "EPSG:4326" 
nd2_coords_a <- terra::vect(
  nd2_coords_a,                     # your existing numeric x/y matrix
  geom = c("x", "y"),             # adjust column names/order if needed
  crs  = original_crs
)
target_crs      <- terra::crs(covariates)
nd2_coords_proj <- terra::project(nd2_coords_a, target_crs)

nd2_coords <- terra::crds(nd2_coords_proj)
rownames(nd2_coords) <- rownames(nd2_coords_a)   # re-attach your sample IDs
storage.mode(nd2_coords) <- "double"


####reprojecting raster covariates
# 1. Find a reasonable UTM zone from your study area's centroid
centroid <- terra::project(
  terra::vect(matrix(colMeans(nd2_coords), nrow = 1), crs = terra::crs(covariates)),
  "EPSG:4326"
)
lon <- terra::crds(centroid)[1,1]
lat <- terra::crds(centroid)[1,2]

utm_zone <- floor((lon + 180) / 6) + 1
hemisphere_code <- if (lat >= 0) "326" else "327"   # EPSG prefix for N/S UTM
target_crs <- paste0("EPSG:", hemisphere_code, sprintf("%02d", utm_zone))
target_crs   # sanity-check this looks like a real UTM EPSG code for your region

# 2. Reproject the raster to that CRS
covariates <- terra::project(covariates, target_crs)

# 3. Reproject your points to match (as a SpatVector, so CRS carries explicitly)
nd2_coords_vect <- terra::vect(
  nd2_coords,
  type = "points",
  crs  = "EPSG:4326"
) # your points' known source CRS
nd2_coords_vect <- terra::project(nd2_coords_vect, target_crs)
nd2_coords <- terra::crds(nd2_coords_vect)
rownames(nd2_coords) <- rownames(nd2_coords_vect)

# 4. Confirm units are now same
terra::linearUnits(covariates)   # should now return 1 (meters)
terra::res(covariates)           # cell size should now read in meters, not degrees
terra::ncell(covariates)         # check the new cell count post-reprojection


# trimming raster
# Get the actual bounding box of your sample points
x_range <- range(nd2_coords[,1])
y_range <- range(nd2_coords[,2])

# Build a proper extent: xmin, xmax, ymin, ymax
site_ext <- ext(nd2_coords)

# Expand it by a buffer distance in the raster's map units
# (5000 = 5km if your CRS is in meters -- adjust to your actual units/needs)
buffer_dist <- 5000
site_ext <- site_ext + buffer_dist

# Crop the raster to that expanded extent
covariates_cropped <- terra::crop(covariates, site_ext)
terra::ncell(covariates_cropped)   # should now be dramatically smaller

######

covariates <- scale_covariates(covariates_cropped)   # important for numerical stability


surface <- conductance_surface(
  covariates,
  nd2_coords,
  directions  = 8,
  saveStack   = TRUE,   # needed if you'll use crop_buffer, Gaussian smoothing, etc.
  crop_buffer = 0.05    # trims the raster to the sampled area; speeds up small fits
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


