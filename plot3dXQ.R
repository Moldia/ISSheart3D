# functions
library(rgl)
library(misc3d)
library("sp")
library("png")
source('./r/helper_functions.R')

# regi
load('./data/ISS_regi6_5weeks_regV2.RData')

# segmentation data
segmentation <- read.csv("segmentation.csv")

# atlast at 0.5 scale
segmentation$x = segmentation$x *.5
segmentation$y = segmentation$y *.5

#get your dataset object
dataset<-rcp.to.atlas(regi, segmentation)

datasetClean <- dataset[!is.na(dataset$acronym),]

# load cell type info
celltype = read.csv("cell_class.csv")
datasetClean.celltype <- dataset[!is.na(dataset$acronym) & (celltype$include==1),]


# load heart 3D model
load('./data/heart.RData')


#######################
#open 3D plot window
open3d(windowRect = c(100, 100, 1280, 720))
#draw high-resolution heart. If you want low resolution then change organ to organ.dwnsmp


rgl.clear()


drawScene.rgl(organ[which(names(organ.dwnsmp)%in%c('WH'))])
#add anterior posterio value from registration file
#datasetClean$anterior.posterior<-rep(atlasIndex[which(atlasIndex[,2]==regi$coordinate), 1], length(dataset$right.left))
#draw the points
# points3d(598-datasetClean$rostral.caudal, 
#          532-datasetClean$right.left, 
#          dataset$anterior.posterior, 
#          alpha = 0.5, 
#          size = 6, 
#          color = datasetClean$color)


points3d(598-datasetClean.celltype$rostral.caudal, 
         532-datasetClean.celltype$right.left, 
         dataset$anterior.posterior, 
         alpha = 1, 
         size = 4, 
         color = celltype[!is.na(dataset$acronym) & (celltype$include==1),]$color)

#################################

perspective<-list(FOV = 30, ignoreExtent = FALSE, listeners = 1L,
                  mouseMode = structure(c("trackball", "zoom", "fov", "pull"
                  ), .Names = c("left", "right", "middle", "wheel")), skipRedraw = FALSE,
                  userMatrix = structure(c(-0.0108720660209656, 0.899227440357208,
                                           0.437346190214157, 0, 0.955604612827301, -0.119448974728584,
                                           0.269354522228241, 0, 0.2944515645504, 0.420858442783356,
                                           -0.858007192611694, 0, 0, 0, 0, 1), .Dim = c(4L, 4L)),
                  scale = c(1,1, 1),
                  viewport = structure(c(0L, 0L, 1280L, 720L), .Names = c("x", "y", "width", "height")),
                  zoom = 1, windowRect = c(0L, 45L, 1280L, 765L), family = "sans", font = 1L, cex = 1, useFreeType = TRUE)

par3d(perspective)

# save current perspective
perspective.front <- par3d(no.readonly=TRUE)
perspective.side <- par3d(no.readonly=TRUE)
perspective.top <- par3d(no.readonly=TRUE)


#use the perspective
par3d(new.perspective)


#save image as PNG
rgl.snapshot(filename='3d_heart_celltypes_top.png')

save(perspective.front, perspective.side, perspective.top, file='perspectives.RData')
