# =============================================================================
# POLYCLOCK project: Part 00, download the gnomAD HGDP+1KG metadata
# =============================================================================
# Purpose:  Download gnomad_meta_updated.tsv (gnomAD v3.1.2 HGDP+1KG sample
#           metadata; population labels and coordinates from Bergstrom et al.
#           2020) into data/raw/.
# Output:   data/raw/gnomad_meta_updated.tsv
# =============================================================================

# Settings ----------------------------------------------------------------

# Web address of the gnomAD metadata file (the text is split over three lines
# and joined by paste0)
URL <- paste0("https://gnomad-public-us-east-1.s3.amazonaws.com/release/3.1/",
              "secondary_analyses/hgdp_1kg_v2/metadata_and_qc/",
              "gnomad_meta_updated.tsv")
RAW_DIR <- "data/raw"                                  # folder for downloaded files
FILE    <- file.path(RAW_DIR, "gnomad_meta_updated.tsv")   # full path of the saved file

# Download ----------------------------------------------------------------

# Create data/raw if it is missing (no warning if it already exists)
dir.create(RAW_DIR, showWarnings = FALSE, recursive = TRUE)

# Download only if the file is not already there
if (file.exists(FILE)) {
    cat("File already exists, not downloading again:", FILE, "\n")
} else {
    options(timeout = 600)              # allow up to 10 min (default is 60 s)
    cat("Downloading", basename(FILE), "...\n")
    # mode = "wb": save the file exactly as it is on the server
    download.file(URL, destfile = FILE, mode = "wb")
}

