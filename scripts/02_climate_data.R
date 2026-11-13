# =============================================================================
# POLYCLOCK Project - Climate Variables and Photoperiod
# =============================================================================
# Purpose:  Download WorldClim 2.1 bioclimatic variables, extract them at the
#           54 HGDP population coordinates and over buffers of increasing
#           radius, and compute the annual photoperiod range from latitude.
#
# INPUT:
#   data/derived/populations_54.csv       # from 01_populations.R
#   WorldClim rasters                     # downloaded on first run to
#                                         # data/raw/worldclim/ (gitignored)
#
# OUTPUT (data/derived/):
#   climate_54.csv                        # 54 rows: climate at the point
#   climate_buffers.csv                   # 324 rows: point + 5 radii
#   climate_sensitivity.csv               # 54 rows: change with the radius            
#
#
# VARIABLES EXTRACTED (https://www.worldclim.org/data/bioclim.html):
# BIO1:  Annual Mean Temperature (ºC)
# BIO4:  Temperature Seasonality (standard deviation ×100)
# BIO10: Mean Temperature of the Warmest Quarter (ºC)
# BIO11: Mean Temperature of the Coldest Quarter (ºC)
# BIO12: Annual Precipitation (mm)

# VARIABLES CALCULATED
# photoperiod_range_h: hours of daylight on the longest day minus the
#        shortest day of the year
# =============================================================================

# Packages used
list_packages <- c("dplyr", "terra", "geodata", "readr")

# Install any package that is not installed yet
for (pk in list_packages) {                # Loop to check if packages are 
    # install, and if not install them
    if(!require(pk, character.only = T))
        install.packages(pk)
    library(pk, character.only = T)        # Load packages in the vector package
}

# Settings ----------------------------------------------------------------

RESOLUTION <- 0.5                       # arc-minutes: 0.5 = 30 arc-seconds (~1 km)
RADII_KM   <- c(10, 25, 50, 75, 100)    # buffer sizes; radius 0 is the point
VARIABLES  <- c("BIO1", "BIO4", "BIO10", "BIO11", "BIO12")

RASTER_DIR <- "data/raw/worldclim"
OUT_DIR    <- "data/derived"

# Populations -------------------------------------------------------------

pops <- read_csv("data/derived/populations_54.csv", show_col_types = FALSE) %>%
    select(population, region, lat, lon, n, site_id) %>%
    arrange(population)

# Turn the table into map points. crs = "EPSG:4326" is the code for WGS 84
# latitude/longitude in degrees: WGS 84 is the standard model of the Earth's
# shape used by GPS and by WorldClim, so the points and the raster cells line
# up. Knowing the CRS also lets terra measure buffer radii in metres along the
# Earth's curved surface. 
sites <- vect(as.data.frame(pops), geom = c("lon", "lat"), crs = "EPSG:4326",
              keepgeom = TRUE)

# Climate maps ----------------------------------------------------------------

# Downloads climate data from WorldClim
bio <- worldclim_global(var = "bio", res = RESOLUTION, path = RASTER_DIR)

#  Shorten the layer names from "wc2.1_30s_bio_1" to "BIO1", "BIO2",..
names(bio) <- sub(".*_bio_", "BIO", names(bio))

# Keep only the five variables
bio <- bio[[VARIABLES]]


# Climate at the point ----------------------------------------------------
# Extract values from a SpatRaster for the set of locations defined in sites
at_point <- extract(bio, sites, ID = FALSE)

# Creates land_fraction column. If BIO1 is NA, the point fell on a cell with 
# no data, i.e  water, and gets 0, otherwise it gets 1.
at_point$land_fraction <- ifelse(is.na(at_point$BIO1), 0, 1)

# Prints populations with coordinates in the water
cat("Populations with no value at the point (coordinate on water):\n")
print(pops$population[is.na(at_point$BIO1)])

# binds in columns the population table, a new radius_km column set to 0, 
# and the climate values.
out <- bind_cols(pops, radius_km = 0, at_point)

# Climate averaged over buffers -------------------------------------------

# For each radius: draw a circle around every population, then average the
# climate cells inside it. Each cell counts in proportion to how much of it
# lies inside the circle (exact = TRUE), so small circles still get a value.
# Sea cells have no value and are left out, so coastal circles average land only.

for (r in RADII_KM) {        # repeat for 10, 25, 50, 75, 100 km
    
    # Draw a circle of radius r around each population point
    circles <- buffer(sites, width = r * 1000)            # width in metres
    
    # List every climate cell that touches each circle, with:
    #   ID       = which circle (population) the cell belongs to
    #   fraction = share of the cell that lies inside the circle (0 to 1)
    cells   <- extract(bio, circles, exact = TRUE, ID = TRUE)
    
    means <- cells %>%
        group_by(ID) %>%
        summarise(
            #  Proportion of the circle's area covered by land (e.g. 1 = all land, 
            # 0.5 = half sea, 0 = all sea). BIO1 is NA wherever the cell is sea 
            # (all layers share the same land mask)
            land_fraction = sum(fraction[!is.na(BIO1)]) / sum(fraction),
            # Area-weighted mean of each variable; na.rm = TRUE skips sea cells
            BIO1  = stats::weighted.mean(BIO1,  fraction, na.rm = TRUE),
            BIO4  = stats::weighted.mean(BIO4,  fraction, na.rm = TRUE),
            BIO10 = stats::weighted.mean(BIO10, fraction, na.rm = TRUE),
            BIO11 = stats::weighted.mean(BIO11, fraction, na.rm = TRUE),
            BIO12 = stats::weighted.mean(BIO12, fraction, na.rm = TRUE)
        ) %>% 
        arrange(ID) %>%     # same order as pops
        select(-ID)         # remove ID
    
    # Check that there is exactly one row per population, otherwise stop
    stopifnot(nrow(means) == nrow(pops))            
    
    # Add population info and the radius, then stack under the rows 
    out <- bind_rows(out, bind_cols(pops, radius_km = r, means))
    cat("Done:", r, "km\n")
}

# A circle that is all sea gives NaN, store it as an NA value instead
out[is.na(out)] <- NA


# Photoperiod ----------------------------------------------------------------

# Day length in hours for a latitude and day of the year.
# CBM model, Forsythe et al. (1995), Ecological Modelling 80: 87-95, Eqs. 1-3.
#   lat = latitude in degrees (north positive, south negative)
#   day = day of the year (1 to 365)
day_length <- function(lat, day) {
    
    # Eq. 1: revolution angle of the Earth around the sun (radians)
    theta <- 0.2163108 + 2 * atan(0.9671396 * tan(0.00860 * (day - 186)))
    
    # Eq. 2: the sun's declination (radians): the angular distance at solar
    # noon between the sun and the equator (p. 89)
    phi <- asin(0.39795 * cos(theta))
    
    # Eq. 3 (inside the brackets): combines latitude and declination.
    # p = 0.8333 degrees: sun's radius + 34' refraction (Table 1, footnote a),
    # so sunrise/sunset is when the top of the sun apparently touches the
    # horizon (Table 1, definition 3). Degrees are converted to radians (p. 89).
    a <- (sin(0.8333 * pi / 180) + sin(lat * pi / 180) * sin(phi)) /
        (cos(lat * pi / 180) * cos(phi))
    
    # Not in the paper's equations: the paper notes that 'a' can fall outside
    # -1 to 1 near the poles (continuous light or darkness, p. 89). Clamping 'a' 
    # at -1 and 1 keeps acos() valid and gives 24 h of light or 0 h of light
    a <- pmin(pmax(a, -1), 1)
    
    # Eq. 3: day length D in hours
    24 - (24 / pi) * acos(a)
} 


# Annual range of day length for each population ----------------------------
# Range = longest day minus shortest day. About 0 h at the equator and
# grows with latitude (about 12 h at 60 degrees). It measures how much
# day length changes through the year at that latitude.

# New empty column (NA until filled)
pops$photoperiod_range_h <- NA_real_  # NA_real_ makes it a numeric column

# Repeat for each population (row i of pops)
for (i in 1:nrow(pops)) {
    
    # Day length in hours for each of the 365 days at this latitude
    hours <- day_length(pops$lat[i], 1:365)
    
    # Longest day minus shortest day
    pops$photoperiod_range_h[i] <- max(hours) - min(hours)
}

# Copy the range into the climate table. 'out' has one row per population per
# radius (324 rows), so each population's value is repeated on each of its
# rows. The join matches rows by population name.
out <- left_join(out, select(pops, population, photoperiod_range_h), by = "population")


# Sensitivity to the radius ---------------------------------------------------

# For each population: the climate value at the exact point, and how much the
# value changes across the radii (largest minus smallest of the six values:
# 0, 10, 25, 50, 75 and 100 km). A small shift means the radius hardly matters;
# a large shift means the value depends on the radius (e.g. mountain sites).

sens <- out %>%
    group_by(population, region, lat, lon, site_id) %>%    # the 6 rows (radii) of each population
    summarise(
        # Annual mean temperature (BIO1, in degrees C)
        bio1_point = BIO1[radius_km == 0],           # value at the exact point
        bio1_shift = max(BIO1, na.rm = TRUE) - min(BIO1, na.rm = TRUE),
        
        # Temperature seasonality (BIO4)
        bio4_point = BIO4[radius_km == 0],
        bio4_shift = max(BIO4, na.rm = TRUE) - min(BIO4, na.rm = TRUE),
        
        # Lowest land share across the radii (low = coastal or sea point)
        min_land_fraction = min(land_fraction, na.rm = TRUE),
        
        .groups = "drop"                    # remove the grouping 
    ) %>%
    arrange(desc(bio1_shift))              # most sensitive first

# Print the five populations whose BIO1 changes most with the radius
cat("Populations whose BIO1 moves most with the radius:\n")
print(head(select(sens, population, bio1_point, bio1_shift), 5))


# Save --------------------------------------------------------------------

# Record the resolution in the tables (0.5 arc-minutes = 30 arc-seconds)
out  <- mutate(out,  res_arcmin = RESOLUTION)
sens <- mutate(sens, res_arcmin = RESOLUTION)

# Point table: one row per population, climate at the exact coordinate
point <- out %>%
    filter(radius_km == 0) %>%                       # keep only the point rows
    select(population, region, lat, lon, n, site_id,
           all_of(VARIABLES),                        # BIO1, BIO4, BIO10, BIO11, BIO12
           photoperiod_range_h, land_fraction, res_arcmin)

# Create the output folder if missing
# recursive = TRUE: also create parent folders (e.g. "data" before "data/derived")
# showWarnings = FALSE: no warning if the folder already exists
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# Write the three tables to data/derived/
write_csv(point, file.path(OUT_DIR, "climate_54.csv"))           
write_csv(out,   file.path(OUT_DIR, "climate_buffers.csv"))     
write_csv(sens,  file.path(OUT_DIR, "climate_sensitivity.csv"))  

# Confirmation message with the number of rows in each table
cat("Saved", nrow(point), "+", nrow(out), "+", nrow(sens), "rows to", OUT_DIR, "\n")

