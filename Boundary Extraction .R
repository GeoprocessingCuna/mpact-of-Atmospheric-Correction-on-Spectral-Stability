# ============================================================================
# PROJECT: IMPACT OF ATMOSPHERIC CORRECTION ON SPECTRAL STABILITY
# STEP 01: Boundary Extraction and Shapefile Filtering for Viçosa - MG
# AUTHOR: Inácio Samuel Cuna | UFV / IIAM
# REPOSITORY: @GeoprocessingCuna
# ============================================================================

# 1. LOAD REQUIRED LIBRARIES -------------------------------------------------
library(sf)
library(ggplot2)

# 2. SET WORKING DIRECTORY ---------------------------------------------------
# Configures the local path to access datasets directly
setwd("C:/Users/LENOVO/Desktop/UFV/Simea")

# 3. READ STATE-LEVEL MUNICIPAL SHAPEFILE ------------------------------------
# Loads the official Brazilian IBGE shapefile from the local directory
mg_completo <- sf::st_read("MG_Municipios_2025/MG_Municipios_2025.shp", quiet = FALSE)

# 4. FILTER MUNICIPAL BOUNDARY BY IBGE CODE ----------------------------------
# Extracts the target geometry for Viçosa using its unique official geocode
vicosa_geo <- subset(mg_completo, CD_MUN == "3171303")

# 5. GENERATE MAP FOR RADIOMETRIC VALIDATION ---------------------------------
# Renders a reference layout to inspect spatial boundaries
ggplot() +
  geom_sf(data = vicosa_geo, fill = "#4F94CD", color = "black", linewidth = 0.5) +
  theme_minimal() +
  labs(
    title = "Territorial Boundary of Viçosa - MG, Brazil",
    subtitle = "Locally Extracted Dataset - Official IBGE (2022) Framework",
    x = "Longitude (Decimal Degrees)",
    y = "Latitude (Decimal Degrees)"
  )

# 6. EXPORT EXCLUSIVE MUNICIPAL SHAPEFILE ------------------------------------
# Saves the vector mask as a standardized shapefile for Google Earth Engine
sf::st_write(
  obj = vicosa_geo, 
  dsn = "vicosa_municipio.shp", 
  layer = "vicosa_boundary",
  delete_layer = TRUE,
  quiet = FALSE
)

cat("\n=======================================================\n")
cat(" [SUCCESS] 'vicosa_municipio.shp' exported seamlessly! \n")
cat("=======================================================\n")
