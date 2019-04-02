# 3dLME_ISC_OneGroup_n42.R
#
# Created 5/18/18 by DJ based on 3dLME_ISC_OneGroup.R from EF.
# Updated 12/11/18 by DJ - _d3, including inputs to accommodate Vis & Aud versions
# Updated 3/4/19 by DJ - a182_v2 version with 69 ok subjects
# Updated 4/2/19 by DJ - comments

# get inputs
args = commandArgs(trailingOnly=TRUE)

# list all the subject or session labels
G1Subj <- c('h1157','h1028','h1073','h1036','h1093','h1118','h1031','h1169','h1016','h1074','h1002','h1102','h1152','h1167','h1185','h1027','h1043','h1146','h1179','h1018','h1098','h1012','h1186','h1010','h1189','h1082','h1061','h1175','h1014','h1011','h1076','h1013','h1048','h1022','h1029','h1097','h1108','h1046','h1038','h1034','h1187','h1024','h1003','h1083','h1120','h1180','h1161','h1174','h1129','h1088','h1035','h1096','h1176','h1150','h1197','h1163','h1058','h1142','h1106','h1184','h1095','h1153','h1168','h1059','h1004','h1057','h1087','h1054','h1154')

# move to results directory
setwd("/data/NIMH_Haskins/a182_v2/IscResults/Pairwise")
# File that contains all the input files of correlation values (without Z-transformation)
# in a three column format: the first 2 columns for the pair labels, and the 3rd for input filenames

# input & output files given as arguments:
if (length(args)>1) {
  # input table of filenames
  inFile = args[1]
  # Output file name
  outFile = args[2]

} else { # no arguments given, so use defaults
  # input table of filenames
  inFile <- 'StoryPairwiseIscTable.txt'
  # inFile <- 'StoryPairwiseIscTable_aud.txt'
  # inFile <- 'StoryPairwiseIscTable_vis.txt'

  # Output file name
  outFile <- '3dLME_1Grp_n69_Automask'

}
print(paste("input:",inFile))
print(paste("output:",outFile))

# mask file to exclude the voxels outside of the brain
mask <- NULL # or 'myMask+tlrc'
# mask <- '/data/finnes/story_task/grp_mask_volResults_n22_70perc+tlrc.HEAD'

# number of CPUs for parallel computation
nNodes <- 16  # should be always great than 1

######################## Don't touch anything below ############################

first.in.path <- function(file) {
   ff <- paste(strsplit(Sys.getenv('PATH'),':')[[1]],'/', file, sep='')
   ff<-ff[lapply(ff,file.exists)==TRUE];
   #cat('Using ', ff[1],'\n');
   return(gsub('//','/',ff[1], fixed=TRUE))
}
source(first.in.path('AFNIio.R'))

allFiles <- read.table(inFile, header=T)
allFiles$InputFile <- as.character(allFiles$InputFile)

G1Files <- allFiles[(allFiles$Subj %in% G1Subj) & (allFiles$Subj2 %in% G1Subj),]
G1Files$InputFile <- as.character(G1Files$InputFile)

# read in mask
if(!is.null(mask)) {
   if(is.null(mm <- read.AFNI(mask, forcedset = TRUE))) {
      warning("Failed to read mask", immediate.=TRUE)
      return(NULL)
   }
   maskData <- mm$brk[,,,1]
}

inData <- read.AFNI(as.character(G1Files$InputFile)[1], forcedset = TRUE)
dimx <- inData$dim[1]
dimy <- inData$dim[2]
dimz <- inData$dim[3]
# for writing output purpose
head <- inData
r2z <- function(r) 0.5*(log(1+r)-log(1-r))
z2r <- function(z) (exp(2*z)-1)/(exp(2*z)+1)

nSubj <- length(G1Subj)
nFile <- length(G1Files$InputFile)
NN <- nSubj*(nSubj-1)/2
allData <- array(0, dim=c(dimx, dimy, dimz, nFile))

# make sure to read the files in a proper order to form the correlation matrix: upper triangle
ll <- 0
for(ii in 1:(nSubj-1))
   for(jj in (ii+1):nSubj) {
      ll <- ll+1
      allData[,,,ll] <- read.AFNI(allFiles[(allFiles$Subj == G1Subj[ii] | allFiles$Subj == G1Subj[jj]) &
         (allFiles$Subj2 == G1Subj[ii] | allFiles$Subj2 == G1Subj[jj]), 'InputFile'], forcedset = TRUE)$brk
}
cat('Reading input files: Done!\n\n')

tolL <- 1e-16 # bottom tolerance for avoiding division by 0 and for avioding analyzing data with most 0's
if(!is.null(mask)) allData <- array(apply(allData, 4, function(x) x*(abs(maskData)>tolL)),
       dim=c(dimx,dimy,dimz,nFile))
allData <- r2z(allData)

genLab <- function(nSubj, mydat) {
   tmp1 <- vector('character', nSubj*(nSubj-1))
   tmp2 <- vector('numeric', nSubj*(nSubj-1))
   ll <- 0
   for(ii in 1:nSubj)
   for(jj in 1:nSubj) {
      if(jj!=ii) {
         ll    <- ll+1
         tmp1[ll] <- paste('s', jj, sep='')
         tmp2[ll] <- mydat[ii, jj]
      }
   }
   return(cbind(tmp1, tmp2))
}

#require(lme4)
#fm <- lme(beta0 ~ 1, random=list(Subj=~1, Subj2=~1), data=myDatN)

mylme <- function(myDat, nSubj, NN) {
   if (!all(abs(myDat) < 10e-8)) {
      corM  <- matrix(NA, nSubj, nSubj)
      corM[lower.tri(corM)] <- myDat
      # flip it to get the upper triangle
      corM[upper.tri(corM)] <- t(corM)[upper.tri(t(corM))]
      tmp <- genLab(nSubj, corM)
      myDatN <- data.frame(Subj=rep(paste('s', 1:nSubj, sep=''), each = nSubj-1), # subject column
         Subj2=as.factor(tmp[,1]),   # z-score label column: necessary?
         beta0=as.numeric(tmp[,2]),  # z-score column
         row.names = NULL)
      fm <- NULL
      try(fm <- summary(lmer(beta0~1+(1|Subj)+(1|Subj2), data=myDatN)), silent=TRUE)
      if(is.null(fm)) return(c(0,0,0,0,0)) else {
         cc <- fm$coefficients
         tN1 <- cc[1]*sqrt(NN-1)/(cc[2]*sqrt(2*NN-1))  # new t-value
         #tN2 <- cc[1]/(cc[2]*sqrt(2))
         # 2-sided p
         #pval <- 2*pt(abs(tN1), nSubj-1, lower.tail = FALSE)
         zeta2 <- fm$varcor$Subj[1,1]
         eta2  <- attr(fm$varcor, 'sc')^2
         rho   <- zeta2/(2*zeta2+eta2)
         return(c(z2r(cc[1]), tN1, zeta2, eta2, rho))
      }
   } else return(c(0, 0, 0, 0, 0))
}
# mylme(allData[40,40,40,], n1, n2, N1, N2)

# Initialization
NoBrick <- 5
options(warn=-1)
if (nNodes>1) {
   library(snow)
   cl <- makeCluster(nNodes, type = "SOCK")
   clusterExport(cl, c('genLab', 'z2r'), envir=environment())
   clusterEvalQ(cl, library(lme4))

   if(dimy == 1 & dimz == 1) {  # LME with surface or 1D data
      nSeg <- 20
      # drop the dimensions with a length of 1
      allData <- allData[, , ,]
      # break into 20 segments, leading to 5% increamental in parallel computing
      dimx_n <- dimx%/%nSeg + 1
      # number of datasets need to be filled
      fill <- nSeg-dimx%%nSeg
      # pad with extra 0s
      allData <- rbind(allData, array(0, dim=c(fill, NoFile)))
      # declare output receiver
      out <- array(0, dim=c(dimx_n, nSeg, NoBrick))
      # break input multiple segments for parrel computation
      dim(allData) <- c(dimx_n, nSeg, nFile)

      for(kk in 1:nSeg) {
         out[,kk,] <- aperm(parApply(cl, allData[,kk,], 1, mylme, nSubj, NN), c(2,1))
         cat("Computation done: ", 100*kk/nSeg, "%: ", format(Sys.time(), "%D %H:%M:%OS3"), "\n", sep='')
      }
      # convert to 4D
      dim(out) <- c(dimx_n*nSeg, 1, 1, NoBrick)
      # remove the trailers (padded 0s)
      out <- out[-c((dimx_n*nSeg-fill+1):(dimx_n*nSeg)), 1, 1,,drop=F]
   } else {
      out <- array(0, dim=c(dimx, dimy, dimz, NoBrick))
      for (kk in 1:dimz) {
         out[,,kk,] <- aperm(parApply(cl, allData[,,kk,], c(1,2), mylme, nSubj, NN), c(2,3,1))
         cat("Z slice ", kk, "done: ", format(Sys.time(), "%D %H:%M:%OS3"), "\n")
      }
   }
   stopCluster(cl)
}

brickNames <- c('correlation', 'correlation t', 'zeta2', 'eta2', 'rho')
statsym    <- list(list(sb=1, typ="fitt", par=nSubj-1))
write.AFNI(outFile, out, brickNames, defhead=head, idcode=newid.AFNI(), com_hist='', statsym=statsym, addFDR=1, type='MRI_short')
