##################### Plotting geo coordinates ###########################
###############################################################################

# set working directory
setwd("C:/Users/evaad/Desktop/Master'in life/Data/RStudio/Geomap")


libraries <- c("ggplot2",
               "ggrepel",
               "ggspatial",
               "sf",
               "rnaturalearth",
               "rnaturalearthdata",
               "rgeos")

#install.packages("remotes") # if remotes isn't installed
#remotes::install_github("paleolimbot/ggspatial")

for (lib in libraries) {
  if (require(package = lib, character.only = TRUE)) {
    print("Successful")
  } else {
    print("Installing")
    source("https://bioconductor.org/biocLite.R")
    biocLite(pkgs = lib)
    library(lib, character.only = TRUE)
  }
}


## Set theme:
theme_set(theme_bw())

## Load image of the world:
world <- ne_countries(scale = "medium",
                      returnclass = "sf")
world_points <- st_centroid(world)
world_points <- cbind(world, st_coordinates(st_centroid(world$geometry)))


(italy_map <- ggplot(data = world) +
  geom_sf() +
  geom_text(data = world_points,
            aes(x = label_x,
                y = label_y,
                label = name),
            fontface = "bold",
            check_overlap = FALSE) +  
  coord_sf(xlim = c(4, 22),
           ylim = c(36, 46),
           expand = FALSE) +
  geom_point(data = inputall,
             aes(x = Longitude,
                 y = Latitude,
                 fill = Subspecies,
                 shape = Subspecies),
             size = 3) +
  annotate(geom = "text", x = 12.5, y = 40, label = "Tyrrhenian Sea", 
             fontface = "italic", color = "grey70", size = 4) +
  annotate(geom = "text", x = 19.2, y = 37.5, label = "Ionian Sea", 
             fontface = "italic", color = "grey70", size = 4) +  
  annotate(geom = "text", x = 15.5, y = 42.8, label = "Adriatic Sea", 
             fontface = "italic", color = "grey70", size = 4) +  
  xlab("Longitude") +
  ylab("Latitude") +
  annotation_scale(location = "bl",
                     width_hint = 0.5))  
 
  

## Update colour:
library(RColorBrewer)


(col_map_j = italy_map +
  scale_shape_manual(
    values = c(
      21, 22, 23, 24, 25)) +
  scale_fill_brewer(palette = "Set1") +
  theme(axis.text = element_text(size = 10,
                                 face = "plain"),
        axis.title = element_text(size = 15,
                                  face = "bold"),
        legend.text = element_text(size = 10,
                                   face = "italic"),
        legend.title = element_text(size = 12,
                                    face = "bold")))


# Set1

ggsave(file = paste("bombus_map_sample_locations_other_map2.png"), height = 153,
       width = 253, units = "mm", type = "cairo", col_map_j)
ggsave(file = paste("bombus_map_sample_locations_other_map2.pdf"), height = 153,
       width = 253, units = "mm", col_map_j)
ggsave(file = paste("bombus_map_sample_locations_big2.pdf"), height = 283,
       width = 283, units = "mm", col_map)



