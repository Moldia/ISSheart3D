source('./r/helper_functions.R')
if(!require("sp")){
  install.packages("sp")
  library("sp")
}
if(!require("png")){
  install.packages("png")
  library("png")
}

load('./data/ISS_regi6_5weeks_regV2.RData')
# load('./data/some_DAPI.RData')

data = read.csv('F:/FetalHeartManuscript/week6.5_2/issSingleCell/Stitched/ExpandedCells.csv')
in.coord = data[,c(3:5,3)]*.5
colnames(in.coord) = c("intensity", "x", "y", "area")


out.coord <- rcp.to.atlas(regi, in.coord)

plot(out.coord$right.left, out.coord$rostral.caudal, ylim=rev(range(dataset$rostral.caudal)), asp=1)

