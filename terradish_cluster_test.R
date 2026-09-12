library(terradish)
library(terra)

set.seed(42)

#load data (and fix coords)
nd2_gendist    <- as.matrix(read.csv("~/scratch/las80898/terradish/nd2_genetic_distance_matrix.csv", row.names = 1))
covariates <- rast("~/scratch/las80898/terradish/september_stack.tif")
nd2_coords_a  <- read.csv("~/scratch/las80898/terradish/nd2_coords_reduced.csv")
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

#scale covariates
covariates <- scale_covariates(covariates)   # important for numerical stability
# fit conductance suface
surface <- conductance_surface(
  covariates,
  nd2_coords,
  directions  = 8,
  saveStack   = TRUE,   # needed if you'll use crop_buffer, Gaussian smoothing, etc.
  crop_buffer = 0.05    # trims the raster to the sampled area; speeds up small fits
)
# fit models
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
png("/scratch/las80898/terradish/terradish_test_IBD.png")
plot(fit_IBD, data = surface)                    # marginal associations, default
dev.off()

png("/scratch/las80898/terradish/terradish_test_HLI_with_CI.png")
plot(fit_HLI, type = "surface", data = surface)  # fitted conductance surface + 95% CI
dev.off()

png("/scratch/las80898/terradish/terradish_test_observed_v_fitted.png")
plot(fit_HLI, type = "fit")                       # observed vs. fitted
dev.off()

png("/scratch/las80898/terradish/terradish_test_constrained_HLI.png")
plot(fit_HLI, type = "marginal", data = surface,
     support = "focal", support_probs = c(0.01, 0.99),
     clamp_covariates = c("HLI"))
dev.off()

