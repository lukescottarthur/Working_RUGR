library(radish)
library(terra)
library(sp)
library(sf)
library(raster)
library(ggplot2)
library(adegenet)
#library(GeNetIt)
library(readxl)


setwd("/scratch/las80898/radish_sim1")


# load data
updated_stack <- rast("updated_stack.tif")
scaled_covariates <- stack(scale(updated_stack))


sites <- read_excel("sample_locations.xlsx")
sites_sf_object <- st_as_sf(sites, coords = c("longitude", "latitude"), crs = 4326)
sample_l <- (as_Spatial(sites_sf_object))
sample_locations <- SpatialPoints(sample_l, proj4string=CRS("EPSG:4326"))

raw_genetic_data <- read_excel("simulated_genetic_data.xlsx")
sim_data_genind <- df2genind(raw_genetic_data, sep = "", type = c("codom"), ploidy = 2, check.ploidy = FALSE)
pop(sim_data_genind) <- rep("Pop1", nInd(sim_data_genind))
sim_data_genpop <- genind2genpop(sim_data_genind)
genetic_data <- dist.genpop(sim_data_genpop, method = 1, diag = FALSE, upper = FALSE)


surface <- conductance_surface(covariates = scaled_covariates,
                               coords = sample_locations,
                               directions = 8,
                               saveStack = TRUE)

# Fitting Radish models (takes a while)
fit_mlpe <- radish(genetic_data ~ HLI + CH + CC + imp_surf,
                   data = surface, 
                   conductance_model = radish::loglinear_conductance, 
                   measurement_model = radish::mlpe)

summary(fit_mlpe)

fit_ibd <- radish(genetic_data ~ 1,
                  data = surface, 
                  conductance_model = radish::loglinear_conductance, 
                  measurement_model = radish::mlpe)
anova(fit_ibd, fit_mlpe)

# Visualizing results
plot(fitted(fit_mlpe, "distance"), genetic_data, pch = 19,
     xlab = "Optimized resistance distance", ylab = "Nei's Genetic Distance ")

## Plot fitted conductance surface
fitted_conductance <- conductance(surface, fit_mlpe, quantile = 0.95)

plot(log(fitted_conductance[["est"]]), 
     main = "Fitted conductance surface\n(HLI + CC + CH + imp_surf)")

