# Author: Oscar Perpinan Lamigueiro oscar.perpinan@upm.es
# Date :  June 2011
# Version 0.10
# Licence GPL v3

##xyplot for directions created with xyLayer
setGeneric('xyplot')

setMethod('xyplot',
          signature(x='RasterStackBrick', data='missing'),
          definition=function(x, data=NULL, dirXY=y, stat='mean',
            xlab='Time', ylab='', digits=0,
            par.settings=rasterTheme(),...){

            idx=getZ(x)
            if (is.null(idx)) stop('z slot of the object is NULL.')

            dirLayer <- xyLayer(x, dirXY=substitute(dirXY))
            z <- zonal(x, dirLayer, stat, digits=digits)
            nRows <- nrow(z)
            zz <- as.data.frame(t(z[,-1]), row.names='')
            names(zz) <- z[,1]
            zz <- zoo(zz, order.by=idx)
            p <- xyplot(zz, xlab=xlab, ylab=ylab,
                        superpose=TRUE, auto.key=FALSE, par.settings=par.settings, ...)
            p + glayer(panel.text(x[1], y[1], group.value, cex=0.7))
          }
          )


setMethod('xyplot', signature(x='formula', data='Raster'),
          definition=function(x, data, dirXY, maxpixels=1e5,
            alpha=0.05,
            xscale.components=xscale.raster,
            yscale.components=yscale.raster,
            par.settings=rasterTheme(),...){

            ## names replace layerNames with raster version 2.0-04
            rasterVersion <- as.character(packageVersion('raster'))
            nms <- if (compareVersion(rasterVersion, '2.0-04') == -1) layerNames(data) else names(data)

            nl <- nlayers(data)

            data <- sampleRegular(data, maxpixels, asRaster=TRUE)
            df <- getValues(data)
            df <- as.data.frame(df)
            names(df) <- make.names(nms)

            xLayer <- getValues(init(data, v='x'))
            yLayer <- getValues(init(data, v='y'))

            df <- cbind(data.frame(x=xLayer, y=yLayer), df)

            if (!missing(dirXY)) {
              dirXY <- getValues(xyLayer(data, dirXY=substitute(dirXY)))
              df <- cbind(df, dirXY)
            }

            p <- xyplot(x=x, data=df,
                        alpha=alpha,
                        xscale.components=xscale.components,
                        yscale.components=yscale.components,
                        par.settings=par.settings, ...)
            p
          }
          )