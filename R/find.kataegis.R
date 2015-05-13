#' @import parallel
#' @import GenomicRanges
#' @import IRanges
find.kataegis <- function(x, min.snvs, max.mean.distance, 
	ncpus = getOption('cl.cores', 1)) {
  chrs <- as.character(runValue(seqnames(x)))
  if (ncpus > 1) {
    cl <- makeCluster(ncpus)
    # clusterEvalQ(cl, { library('GenomicRanges') })
    clusterExport(cl, 'reduceWithin', envir = environment())
    unlist(GRangesList(tryCatch({ 
	    parSapplyLB(cl = cl, chrs, find.kataegis.helper, x) 
    }, 
    finally = { 
	    stopCluster(cl) 
    })))
  } else {
    unlist(GRangesList(sapply(chrs, find.kataegis.helper, x)))
  }
}