# ============================================================================
# PROJECT: IMPACT OF ATMOSPHERIC CORRECTION ON SPECTRAL STABILITY
# STEP 02: Pluriannual Geographic Location Map Construction (16 x 11.5 cm)
# AUTHOR: Inácio Samuel Cuna | UFV / IIAM
# REPOSITORY: @GeoprocessingCuna
# ============================================================================

# 1. LOAD REQUIRED LIBRARIES -------------------------------------------------
library(sf)
library(ggplot2)
library(dplyr)
library(patchwork)
library(ggspatial)
library(rnaturalearth)
library(png)       # Required for reading spatial raster PNG textures
library(grid)      # Required for converting PNG grids into graphical grobs

# 2. SET WORKING DIRECTORY ---------------------------------------------------
# Configures the local directory to target core spatial datasets
setwd("C:/Users/LENOVO/Desktop/UFV/Simea")

# 3. LOAD BASE MAPS (NATIONAL & STATE CONTEXT) --------------------------------
# Fetches international boundary geometries for Brazil's territorial units
brazil_states <- ne_states(country = "Brazil", returnclass = "sf")
minas <- brazil_states %>% filter(name == "Minas Gerais")

# 4. LOAD LOCAL DATASET (VIÇOSA BOUNDARY & EXPERIMENTAL RASTER) --------------
# Reads the exclusive municipal shapefile generated in Step 01
vicosa <- st_read("vicosa_municipio.shp", quiet = TRUE) 

# Harmonizes the Coordinate Reference System (CRS) to WGS 84 (EPSG:4326)
vicosa <- st_transform(vicosa, st_crs(brazil_states))
vicosa$muni <- "Viçosa"

# Reads the underlying experimental crop texture layer
img_png <- png::readPNG("vicosa.png")
g_png   <- grid::rasterGrob(img_png, interpolate = TRUE)

# Color vector mapping for thematic aesthetics
mun_colors <- c("Viçosa" = "maroon")

# 5. ZOOM MAP A: MUNICIPALITY OF VIÇOSA BOUNDARIES ---------------------------
# Computes a proportional bounding box (bbox) with buffer padding
bbox <- st_bbox(vicosa)
scale_factor <- 0.08 

xlim <- c(bbox["xmin"] - (bbox["xmax"] - bbox["xmin"]) * scale_factor, bbox["xmax"] + (bbox["xmax"] - bbox["xmin"]) * scale_factor)
ylim <- c(bbox["ymin"] - (bbox["ymax"] - bbox["ymin"]) * scale_factor, bbox["ymax"] + (bbox["ymax"] - bbox["ymin"]) * scale_factor)

map_vicosa <- ggplot() +
  geom_sf(data = vicosa, aes(fill = muni), color = "black", linewidth = 0.5) +
  scale_fill_manual(values = mun_colors, guide = "none") +
  
  # Adds compact scale indicators and minimalist north arrow
  annotation_scale(location = "br", width_hint = 0.15, style = "ticks") + 
  annotation_north_arrow(location = "tr", style = north_arrow_fancy_orienteering,
                         height = unit(0.6, "cm"), width = unit(0.6, "cm")) + 
  coord_sf(xlim = xlim, ylim = ylim) +
  theme_bw() + 
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 7.5),
    axis.text.y = element_text(size = 7.5),
    axis.title = element_blank(),
    panel.grid.major = element_line(color = "gray95", linewidth = 0.3),
    panel.grid.minor = element_blank()
  ) +
  labs(title = "A) Municipality of Viçosa")

# 6. ZOOM MAP B: EXPERIMENTAL COFFEE PLOT RASTER LAYOUT ----------------------
# Maps the high-resolution crop geometry onto a clear grid frame
map_experimental <- ggplot() + 
  annotation_custom(g_png, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  ) +
  labs(title = "B) Experimental Crop Field")

# 7. GLOBAL MAP: REGIONAL MACRO CONTEXT (BRAZIL AND OCEANS) ------------------
# Computes the geometric centroid of Minas Gerais for label pinning
minas_centroid <- st_point_on_surface(st_union(minas)) 

map_contexto <- ggplot() +
  geom_sf(data = brazil_states, fill = "antiquewhite", color = "gray60", linewidth = 0.2) +
  geom_sf(data = minas, fill = "lightblue", color = "blue", linewidth = 0.4) +
  geom_sf(data = vicosa, aes(fill = muni), color = "black", size = 2) +
  
  geom_sf_text(data = minas_centroid, aes(label = "Minas Gerais"), 
               color = "blue", size = 2.5, face = "bold") +
  
  annotate("text", x = -50, y = -15, label = "BRAZIL", 
           color = "gray30", size = 4.5, fontface = "bold") +
  
  annotate("text", x = -36, y = -20, label = "Atlantic\nOcean", 
           color = "blue4", size = 2.5, fontface = "italic") +
  
  scale_fill_manual(values = mun_colors, name = "Study Area") +
  annotation_scale(location = "bl", width_hint = 0.2) +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "lightcyan", color = "black"),
    legend.position = "bottom",
    axis.text = element_blank(),
    panel.grid = element_blank()
  ) +
  labs(title = "",
       caption = "Source: IBGE / Natural Earth\nAuthor: Inacio Samuel Cuna")

# 8. MULTI-PANEL COMPOSITION ASSEMBLY (PATCHWORK PLATFORM) ------------------
# Blends macro, municipal, and plot-level maps with proportional layouts
mapa_final <- (map_contexto | (map_vicosa / map_experimental)) + 
  plot_layout(widths = c(1.0, 1.0), heights = c(1.3, 0.7))

# Renders output frame inside RStudio
print(mapa_final)

# 9. HIGH-RESOLUTION ARTIFACT EXPORTATION (300 DPI STANDARD) ----------------
# Standardized dimensions tailored to fit UFV manuscript margins flawlessly
ggsave(
  filename = "Localizacao_Brasil_Vicosa_Experimento.png", 
  plot = mapa_final, 
  width = 16.0,          # Precise column layout width in centimeters
  height = 11.5,         # Proportional aspect ratio using dot separation
  units = "cm", 
  dpi = 300              # Standard high-resolution output print quality
)

cat("\n=======================================================\n")
cat(" [SUCCESS] Map saved seamlessly with 16.0 x 11.5 cm!  \n")
cat("=======================================================\n")
