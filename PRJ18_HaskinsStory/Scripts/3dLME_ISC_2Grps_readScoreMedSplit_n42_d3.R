# 3dLME_2Grps_readScoreMedSplit_n42.R
#
# Created 5/18/18 by DJ based on 3dLME_2Grps_gstpMedSplit_n22.R from EF.
# Updated 5/22/18 by DJ - IscResults_d2 directory
# Updated 5/23/18 by DJ - removed 3 high-motion subjects
# Updated 12/11/18 by DJ - _d3, including inputs to accommodate Vis & Aud versions

# get inputs
args = commandArgs(trailingOnly=TRUE)

# list lables for Group 1 - ReadScore <= MEDIAN(ReadScore)
# G1Subj <- c('tb0027','tb0094','tb0170','tb0276','tb0312','tb0313','tb0456','tb0543','tb0593','tb0782','tb1063','tb1208','tb1314','tb5833','tb5868','tb5976','tb6366','tb6631','tb6812','tb6930','tb7125')
G1Subj <- c('tb0027','tb0094','tb0170','tb0276','tb0312','tb0313','tb0456','tb0543','tb0593','tb1063','tb1208','tb1314','tb5833','tb5976','tb6048','tb6366','tb6631','tb6812','tb6930','tb7125')

# list lables for Group 2 - ReadScore > MEDIAN(ReadScore)
# G2Subj <- c('tb0065','tb0093','tb0169','tb0275','tb0349','tb0498','tb0716','tb5985','tb6048','tb6082','tb6150','tb6199','tb6301','tb6367','tb6487','tb6562','tb6842','tb6874','tb6899','tb7065','tb7153')
G2Subj <- c('tb0065','tb0093','tb0169','tb0275','tb0349','tb0498','tb0716','tb5985','tb6082','tb6150','tb6199','tb6301','tb6367','tb6487','tb6562','tb6842','tb6874','tb6899','tb7153')

# move to results directory
setwd("/data/NIMH_Haskins/a182/IscResults_d3/Pairwise")
# File that contains all the input files of correlation values (without Z-transformation)
# in a three column format: the first 2 columns for the pair labels, and the 3rd for input filenames
if (length(args)>1) {
  inFile = args[1]
  outFile = args[2]
} else {
  inFile <- 'StoryPairwiseIscTable.txt'
  # inFile <- 'StoryPairwiseIscTable_aud.txt'
  # inFile <- 'StoryPairwiseIscTable_vis.txt'

  # Output file name
  outFile <- '3dLME_2Grps_readScoreMedSplit_n42_Automask'

}
print(paste("input:",inFile))
print(paste("output:",outFile))

# mask file to exclude the voxels outside of the brain
mask <- NULL # or 'myMask+tlrc'
# mask <- '/data/finnes/story_task/isc_analysis/grp_mask_n23_70perc+tlrc.HEAD'

# number of CPUs for parallel computation
nNodes <- 16

####################################################

first.in.path <- function(file) {
   ff <- paste(strsplit(Sys.getenv('PATH'),':')[[1]],'/', file, sep='')
   ff<-ff[lapply(ff,file.exists)==TRUE];
   #cat('Using ', ff[1],'\n');
   return(gsub('//','/',ff[1], fixed=TRUE))
}
source(first.in.path('AFNIio.R'))

allFiles <- read.table(inFile, header=T)
# allFiles <- read.csv(inFile, header=T)
allFiles$InputFile <- as.character(allFiles$InputFile)

#G1Files <- allFiles[(allFiles$Subj %in% G1Subj) & (allFiles$Subj2 %in% G1Subj),]
#G2Files <- allFiles[(allFiles$Subj %in% G2Subj) & (allFiles$Subj2 %in% G2Subj),]
#G1Files$InputFile <- as.character(G1Files$InputFile)
#G2Files$InputFile <- as.character(G2Files$InputFile)

# verify
#for (ii in G1Subj)
#   print(c(ii, '=', sum(G1Files$Subj==ii) + sum(G1Files$Subj2==ii)))
#
#for (ii in G2Subj)
#   print(c(ii, '=', sum(G2Files$Subj==ii) + sum(G2Files$Subj2==ii)))

# read in mask
if(!is.null(mask)) {
   if(is.null(mm <- read.AFNI(mask, forcedset = TRUE))) {
      warning("Failed to read mask", immediate.=TRUE)
      return(NULL)
   }
   maskData <- mm$brk[,,,1]
}
#if(is.null(mm <- read.AFNI('mask_TT_N27+tlrc', forcedset = TRUE))) {
#   warning("Failed to read mask", immediate.=TRUE)
#   return(NULL)
#}
#maskData <- mm$brk[,,,1]

inData <- read.AFNI(as.character(allFiles$InputFile)[1], forcedset = TRUE)
dimx <- inData$dim[1]
dimy <- inData$dim[2]
dimz <- inData$dim[3]
# for writing output purpose
head <- inData

allSubj <- c(G1Subj, G2Subj)
n1 <- length(G1Subj)
n2 <- length(G2Subj)
N1 <- n1*(n1-1)/2
N2 <- n2*(n2-1)/2
N12 <- n1*n2
nSubj <- length(allSubj)
nFile <- nSubj*(nSubj-1)/2
allData <- array(0, dim=c(dimx, dimy, dimz, nFile))
r2z <- function(r) 0.5*(log(1+r)-log(1-r))
z2r <- function(z) (exp(2*z)-1)/(exp(2*z)+1)

# make sure to read the files in a proper order to form the correlation matrix: upper triangle
ll <- 0
for(ii in 1:(nSubj-1))
   for(jj in (ii+1):nSubj) {
      ll <- ll+1
      allData[,,,ll] <- read.AFNI(allFiles[(allFiles$Subj == allSubj[ii] | allFiles$Subj == allSubj[jj]) &
         (allFiles$Subj2 == allSubj[ii] | allFiles$Subj2 == allSubj[jj]), 'InputFile'], forcedset = TRUE)$brk
}
cat('Reading input files: Done!\n\n')

tolL <- 1e-16 # bottom tolerance for avoiding division by 0 and for avioding analyzing data with most 0's
allData <- r2z(allData)

genLab <- function(nSubj, mydat, n1) {
   tmp0 <- vector('character', nSubj*(nSubj-1))
   tmp1 <- vector('character', nSubj*(nSubj-1))
   grp  <- vector('character', nSubj*(nSubj-1))
   tmp2 <- vector('numeric', nSubj*(nSubj-1))
   ll <- 0
   for(ii in 1:nSubj)
   for(jj in 1:nSubj) {
      if(jj!=ii) {
         ll    <- ll+1
         tmp0[ll] <- paste('s', ii, sep='')
         tmp1[ll] <- paste('s', jj, sep='')
         if(ii <= n1 & jj <= n1) grp[ll] <- 'G1' else if(ii > n1 & jj > n1)
            grp[ll] <- 'G2' else grp[ll] <- 'G12'
         tmp2[ll] <- mydat[ii, jj]
      }
   }
   aa <- data.frame(Subj=tmp0, Subj2=tmp1, G=grp, beta=tmp2)
   return(aa)
}

#require(lme4)
#fm <- lme(beta0 ~ 1, random=list(Subj=~1, Subj2=~1), data=myDatN)

mylme <- function(myDat, n1, n2, NN1, NN2, NN12) {
   if (!all(abs(myDat) < 10e-8)) {
      corM  <- matrix(NA, n1+n2, n1+n2)
      corM[lower.tri(corM)] <- myDat
      # flip it to get the upper triangle
      corM[upper.tri(corM)] <- t(corM)[upper.tri(t(corM))]
      tmp <- genLab(n1+n2, corM, n1)

      # Be careful about the contrast setting: default is contr.treatment, and the baseline
      # level seems to be the first level (not the first alphabetically) in a data.frame
      fm <- summary(lmer(beta~0+G+(1|Subj)+(1|Subj2), data=tmp)) # G1 as reference level
      cc <- fm$coefficients
      # later on move the 7 C* outside
      ww <- matrix(c(1,0,0,    # G1
                     0,0,1,    # G2
                     0,1,0,    # G12
                    -1,0,1, # G2 - G1
                     1,-1,0, # G1 - G12
                     0,-1,1, # G2 - G12
                     0.5,-1,0.5), # (G1+G2)/2 - G12
                   nrow = 7, ncol = 3, byrow = TRUE)
      vv <- t(ww%*%coef(fm)[,1])
      se <- rep(1e8, 7)
      for(ii in 1:7) se[ii] <- as.numeric(sqrt(t(ww[ii,]) %*% vcov(fm) %*% ww[ii,]))
      tt <- vv/se
      #tN1 <- (cc[3,1]*0.5-cc[2,1])*sqrt((NN1+NN2)-2)/(sqrt((cc[3,2])^2*0.25+(cc[2,2])^2)*sqrt(2*(NN1+NN2)-2))  # (G1+G2)/2 - G12
      #tN1 <- cc[2,1]*sqrt((NN1+NN2)-2)/(cc[2,2]*sqrt(2*(NN1+NN2)-2))  # new t-value
      # 2-sided p
      #pval <- 2*pt(abs(tN1), n1+n2-2, lower.tail = FALSE)
      zeta2 <- fm$varcor$Subj[1,1]
      eta2  <- attr(fm$varcor, 'sc')^2
      rho   <- zeta2/(2*zeta2+eta2)
      return(c(c(rbind(vv,tt)), zeta2, eta2, rho))
    } else return(rep(0, 17))
}
# mylme(allData[40,40,40,], n1, n2, N1, N2, N12)

# Initialization
NoBrick <- 17
out <- array(0, dim=c(dimx, dimy, dimz, NoBrick))

if (nNodes>1) {
   library(snow)
   cl <- makeCluster(nNodes, type = "SOCK")
   clusterExport(cl, c('genLab', 'z2r'), envir=environment())
   clusterEvalQ(cl, library(lme4))
   for (kk in 1:dimz) {
      out[,,kk,] <- aperm(parApply(cl, allData[,,kk,], c(1,2), mylme, n1, n2, N1, N2, N12), c(2,3,1))
      cat("Z slice ", kk, "done: ", format(Sys.time(), "%D %H:%M:%OS3"), "\n")
   }
   stopCluster(cl)
}

brickNames <- c('G1', 'G1 t',
                'G2', 'G2 t',
                'G12', 'G12 t',
                'G2-G1', 'G2-G1 t',
                'G1-G12', 'G1-G12 t',
                'G2-G12', 'G2-G12 t',
                'Ave-G12', 'Ave-G12 t', 'zeta2', 'eta2', 'rho')
statsym    <- list(list(sb=1, typ="fitt", par=n1-1), list(sb=3, typ="fitt", par=n2-1),
                   list(sb=5, typ="fitt", par=n1+n2-2), list(sb=7, typ="fitt", par=n1+n2-2),
                   list(sb=9, typ="fitt", par=n1+n2-2), list(sb=11, typ="fitt", par=n1+n2-2),
                   list(sb=13, typ="fitt", par=n1+n2-2))
write.AFNI(outFile, out, brickNames, defhead=head, idcode=newid.AFNI(), com_hist='', statsym=statsym, addFDR=1, type='MRI_short')
