# =============================================================================
# POLYCLOCK Project — Part 01: HGDP Population Table
# =============================================================================
# Purpose:  Build the population table (one row per HGDP population) that
#           every later script reads: climate extraction, photoperiod, and
#           the Shiny app.
#
# INPUT:
#   data/raw/gnomad_meta_updated.tsv      # gnomAD v3.1.2 HGDP+1KG metadata
#                                         # 4,150 rows, one per individual
# OUTPUT:
#   data/derived/populations_54.csv       # 54 rows, one per population

# WHICH COLUMNS:
#   The metadata file has two sets of population labels. This script reads
#   only the Bergström et al. 2020 set (Science 367: eaay5012), which the
#   gnomAD v3.1.2 release uses for population labels and coordinates
#   (Koenig et al. 2024, Genome Research 34: 796): population, latitude, 
#   longitude, region   (54 populations)
#
#   The older set is NOT read. It is the columns whose names start with
#   "hgdp_tgp_meta.". In our check it has 52 populations and different
#   coordinates for PapuanHighlands, NorthernHan and Mongolian.   
# =============================================================================

# Setup -------------------------------------------------------------------
# Install (if not installed) and Load packages
list_packages <- c("readr", "dplyr")    # Vector of packages to install
for (pk in list_packages) {                # Loop to check if packages are 
    # install, and if not install them
    if(!require(pk, character.only = T))
        install.packages(pk)
    library(pk, character.only = T)        # Load packages in the vector package
}

meta_path <- "data/raw/gnomad_meta_updated.tsv"
out_path  <- "data/derived/populations_54.csv"


# Read Only the Columns for this project ---------------------------------- 
meta <- read_tsv(
    meta_path,
    col_types = cols_only(
        s            = col_character(),
        subsets.hgdp = col_logical(),
        high_quality = col_logical(),
        population   = col_character(),
        latitude     = col_double(),
        longitude    = col_double(),
        region       = col_character()
    ),
    na = c("", "NA")
)

hgdp <- meta %>% filter(subsets.hgdp)
stopifnot("expected 948 HGDP individuals" = nrow(hgdp) == 948)

# Check Coordinates Within Each Population ---------------------------------

consistency <- hgdp %>%
    group_by(population) %>%
    summarise(
        n_lat    = n_distinct(latitude),
        n_lon    = n_distinct(longitude),
        n_region = n_distinct(region, na.rm = TRUE),
        .groups  = "drop"
    )

# Each population must have exactly one coordinate pair and one region
stopifnot(all(consistency$n_lat == 1),
          all(consistency$n_lon == 1),
          all(consistency$n_region == 1))

# One Row per Population -------------------------------------------------

# high_quality: gnomAD's QC flag. Six of the most isolated populations are
# flagged false for every individual. This is a documented gnomAD artifact, and 
# not a data problem. All individuals are kept

# site_id / n_pops_at_site: some populations were sampled at the same place
# (Balochi and Brahui; Druze and Palestinian) and so receive identical
# climate values. Recorded rather than merged: they are distinct groups
# sharing one climate.
pops <- hgdp %>%
    group_by(population) %>%
    summarise(
        region         = first(na.omit(region)),
        lat            = first(latitude),
        lon            = first(longitude),
        n              = n(),
        n_high_quality = sum(high_quality),
        .groups        = "drop"
    ) %>%
    mutate(all_qc_flagged = n_high_quality == 0) %>%
    group_by(lat, lon) %>%
    mutate(site_id = cur_group_id(), n_pops_at_site = n()) %>%
    ungroup() %>%
    arrange(region, population)

# Checks -----------------------------------------------------------------
# Expected 54 populations
cat("Number of populations:", nrow(pops), "\n")

# Missing coordinates
cat("All coordinates present:", !anyNA(pops$lat) && !anyNA(pops$lon), "\n")

# Missing regions
cat("All regions present:", !anyNA(pops$region), "\n")

# Coordinates out of range
cat("Any latitude out of range:",  any(abs(pops$lat) > 90,  na.rm = TRUE), "\n")
cat("Any longitude out of range:", any(abs(pops$lon) > 180, na.rm = TRUE), "\n")

# Expected 52 sampling sites
cat("Number of distinct sampling sites:", n_distinct(pops$site_id), "\n")

# Populations with fewer than 5 individuals
cat("Any population with fewer than 5 individuals:", any(pops$n < 5), "\n")

# Guard against the older annotation set: it puts PapuanHighlands at -4.0
cat("PapuanHighlands latitude is -6.1:",
    isTRUE(all.equal(pops$lat[pops$population == "PapuanHighlands"], -6.1)), "\n")

# Output and Summary ------------------------------------------------------
dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
write_csv(pops, out_path)

cat("Wrote", out_path, "\n")
cat(nrow(pops), "populations,", sum(pops$n), "individuals,",
    n_distinct(pops$site_id), "sampling sites\n\n")

cat("Populations per region:\n")
print(count(pops, region))

cat("\nPopulations sharing a sampling site:\n")
pops %>%
    filter(n_pops_at_site > 1) %>%
    select(population, region, lat, lon) %>%
    print()

cat("\nPopulations with every individual QC-flagged (kept):\n")
cat(" ", paste(pops$population[pops$all_qc_flagged], collapse = ", "), "\n")

cat("\nPopulations with some individuals QC-flagged:\n")
pops %>%
    filter(n_high_quality < n, !all_qc_flagged) %>%
    select(population, n, n_high_quality) %>%
    print()

