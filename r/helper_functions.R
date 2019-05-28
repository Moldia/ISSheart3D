load('./data/EPSatlas.RData')
load('./data/atlasIndex.RData')
load('./data/c18_heart_ontology.RData')


rcp.to.atlas<-function(registration, segmentation, atlas='c18heart'){
  featureregion <- rep(NA, length(segmentation$x))
  featurecolor <- rep("#000000", length(segmentation$x))
  
  coordinate <- registration$coordinate
  k <- which(abs(coordinate - atlasIndex$mm.from.origin) ==
               min(abs(coordinate - atlasIndex$mm.from.origin)))
  scale.factor <- mean(c(dim(registration$transformationgrid$mx)[1]/registration$transformationgrid$height,
                         dim(registration$transformationgrid$mx)[2]/registration$transformationgrid$width))
  
  outlines <- registration$atlas$outlines
  plate.info <- EPSatlas$plate.info[[k]]
  namelist<-plate.info$acronym
  colorlist<-plate.info$unique.col
  
  for(i in 2:length(outlines)){
    if(EPSatlas$plates[[k]]@paths[i]$path@rgb != '#000000'){
      temp<-point.in.polygon(segmentation$x, segmentation$y, c(outlines[[i]]$xT/scale.factor),c(outlines[[i]]$yT/scale.factor) )
      color.id<-as.character( ontology$unique.col[which(ontology$adj.col== EPSatlas$plates[[k]]@paths[i]$path@rgb  )] )
      featurecolor[which(temp==1)]<-color.id
      featureregion[which(temp==1)]<-as.character(ontology$acronym[which(ontology$unique.col==color.id)])
      
    }
  }
  
  
  segmentation$acronym <- featureregion
  segmentation$color <- featurecolor
  dataset <- data.frame(x = segmentation$x, y = segmentation$y, intensity = segmentation$intensity, area = segmentation$area, id = ontology$id[match(segmentation$acronym, ontology$acronym)], color = as.character(segmentation$color), acronym = segmentation$acronym)
  
  index <- round(scale.factor * cbind( dataset$y,  dataset$x ))
  index[index == 0] <- 1
  if (length(which(index[, 1] > dim(registration$transformationgrid$mxF)[1]))) {
    index[which(index[, 1] > dim(registration$transformationgrid$mxF)[1]),
          1] <- dim(registration$transformationgrid$mxF)[1]
  }
  if (length(which(index[, 2] > dim(registration$transformationgrid$mxF)[2]))) {
    index[which(index[, 2] > dim(registration$transformationgrid$mxF)[2]),
          2] <- dim(registration$transformationgrid$mxF)[2]
  }
  
  scale.factor <- mean(dim(registration$transformationgrid$mx)/c(registration$transformationgrid$height,
                                                                 registration$transformationgrid$width))
  
  somaX <- registration$transformationgrid$mxF[index]
  somaY <- registration$transformationgrid$myF[index]
  
  
  right.left<-(somaX - registration$atlas$outlines[[1]]$x[1])*(532/diff(registration$atlas$outlines[[1]]$x[1:2]))
  rostral.caudal<-(somaY - registration$atlas$outlines[[1]]$y[1])*(598/diff(registration$atlas$outlines[[1]]$y[c(1,4)]))
  
  dataset$right.left <- right.left
  dataset$rostral.caudal <- rostral.caudal
  dataset$anterior.posterior<-rep(atlasIndex[which(atlasIndex[,2]==registration$coordinate), 1], length(dataset$right.left))
  
  
  return(dataset)
}


plot.regi<-function(registration=regi, main = NULL, border = rgb(154, 73, 109,
                                                                 maxColorValue = 255), draw.trans.grid = FALSE, batch.mode = FALSE){
  scale.factor <- mean(dim(registration$transformationgrid$mx)/c(registration$transformationgrid$height,
                                                                 registration$transformationgrid$width))
  xMax <- max(c(registration$transformationgrid$mx, registration$transformationgrid$mxF),
              na.rm = TRUE) * (1/scale.factor)
  xMin <- min(c(registration$transformationgrid$mx, registration$transformationgrid$mxF),
              na.rm = TRUE) * (1/scale.factor)
  yMax <- max(c(registration$transformationgrid$my, registration$transformationgrid$myF),
              na.rm = TRUE) * (1/scale.factor)
  yMin <- min(c(registration$transformationgrid$my, registration$transformationgrid$myF),
              na.rm = TRUE) * (1/scale.factor)
  main.title <- main
  if (is.null(main)) {
    main.title <- basename(registration$outputfile)
  }
  plot(c(xMin, xMax), c(yMin, yMax), ylim = c(yMax, yMin),
       xlim = c(xMin, xMax), asp = 1, axes = F, xlab = "", ylab = "",
       col = 0, main = main.title, font.main = 1)
  polygon(c(0, rep(registration$transformationgrid$width, 2),
            0), c(0, 0, rep(registration$transformationgrid$height,
                            2)))
  img <- paste(registration$outputfile, "_undistorted.png",
               sep = "")
  img <- readPNG(img)
  img = as.raster(img[, ])
  if (batch.mode) {
    img <- apply(img, 2, rev)
  }
  rasterImage(img, 0, 0, registration$transformationgrid$width,
              registration$transformationgrid$height)
  if (!is.null(border)) {
    lapply(1:registration$atlas$numRegions, function(x) {
      polygon(registration$atlas$outlines[[x]]$xT/scale.factor,
              registration$atlas$outlines[[x]]$yT/scale.factor,
              border = border)
    })
  }
  if (draw.trans.grid) {
    hei<-dim(registration$transformationgrid$mx)[1]
    wid<-dim(registration$transformationgrid$mx)[2]
    
    lapply(seq(1, hei, by = 50), function(x) {
      lines(registration$transformationgrid$mx[x, ]/scale.factor,
            registration$transformationgrid$my[x, ]/scale.factor,
            col = "lightblue")
    })
    lines(registration$transformationgrid$mx[hei, ]/scale.factor,
          registration$transformationgrid$my[hei, ]/scale.factor,
          col = "lightblue")
    lapply(seq(1, wid, by = 50), function(x) {
      lines(registration$transformationgrid$mx[, x]/scale.factor,
            registration$transformationgrid$my[, x]/scale.factor,
            col = "lightblue")
    })
    lines(registration$transformationgrid$mx[, wid]/scale.factor,
          registration$transformationgrid$my[, wid]/scale.factor,
          col = "lightblue")
  }
}

