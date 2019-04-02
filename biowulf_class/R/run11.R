time1 <- Sys.time()

enrichfun<-function(sig, scalex, origT){
#sig is a vector with an indicator of which genes are in the signature
#    (1 for in siganature 0 for out of signature)
#scalex is the t-statistic from the permuted data
#origT is a list of unpermuted t-statistics ORDERED FROM LEAST TO GREATEST
#output is a vector of 3 numbers
#  first is the unweighted KS,
#  second is the KS weighted by the permuted T-stat (as in the PNAS paper)
#  third is weighted according to the original T-statistic
ord=order(scalex) 
gnum2<-length(ord)
sig<-sig[ord] == 1
scalex<-scalex[ord][sig]
origT<-origT[sig]
signum<-sum(sig)
downval<-1/(gnum2 - signum)
downsum<-(1:gnum2) * downval
upscale<-rep(0, gnum2)
upscale[sig]<-(1/signum) + downval
upsum<-cumsum(upscale)
tsum<-upsum - downsum
ksup<-max(tsum)
ksdown<-min(tsum)
ks<-ifelse(abs(ksup) > abs(ksdown), ksup, ksdown)
upscale[sig]<-abs(scalex)/sum(abs(scalex)) + downval
upsum<-cumsum(upscale)
tsum<-upsum - downsum
ksup<-max(tsum)
ksdown<-min(tsum)
ks2<-ifelse(abs(ksup) > abs(ksdown), ksup, ksdown)
upscale[sig]<-abs(origT)/sum(abs(origT)) + downval
upsum<-cumsum(upscale)
tsum<-upsum - downsum
ksup<-max(tsum)
ksdown<-min(tsum)
ks3<-ifelse(abs(ksup) > abs(ksdown), ksup, ksdown)
c(ks, ks2, ks3)
}


var.row<-function(mat){
n<-dim(mat)[2]
n/(n-1) * (rowMeans(mat^2)-(rowMeans(mat)^2))
}


sim.all<-function(nclass1, nclass2, clustsize, ngenes=2,ngenes.s,p=.5, mua=0, siga=1,mub=0,sigb=1, sige=1, nboot=1000, nperm=1000,nsim=1000, filename, seed){
#Simulation with subject random effect and gene random effect
#nclass1 is number in class 1 (e.g., tumors)
#nclass2 is number in class 2 (e.g., normals)
#p is mixing proportion for adding random means to class 1
# mua is mean for random effect (set to zero)
#siga is sd for random effect
#mub is mean for rnorm for random means for class 1, sigb is corresponding sd
#ROWS ARE GENES AND COLUMNS ARE SUBJECTS
write("",file=filename, append=F)
set.seed(seed)
for(i in 1:nsim){
n<-nclass1+nclass2
#ai<-rnorm(nclass1)
#ai<-matrix(ai, nrow=ngenes, ncol=nclass1, byrow=T)
t.thresh<-qt(0.9995,n-2)
nclust<-ngenes/clustsize

nclust<-ngenes/clustsize
#ai<-rnorm(nclass1*nclust,sd= siga)
#ai<-matrix(rep(ai, each=clustsize), nrow=ngenes, ncol=nclass1, byrow=F)
#ai<-matrix(0, nrow=ngenes, ncol=nclass1, byrow=T)
#ai2<-rnorm(nclass2*nclust, sd=siga)
#ai2<-matrix(rep(ai2, each=clustsize), nrow=ngenes, ncol=nclass2, byrow=F)

#nclust.list<-ngenes.s/clustsize
#ck<-rnorm(nclass2*(ngenes.s/clustsize),sd= siga)
# cks<-matrix(rep(ck, each=clustsize),nrow=ngenes.s, ncol=nclass2)
#ck<-rbind(cks,cks)
#ck<-rbind(ck,  matrix(rnorm(((ngenes-(ngenes.s*2))*nclass2), sd=siga), nrow=ngenes-(ngenes.s*2), ncol=nclass2) )

#ck2<-rnorm(nclass2*(ngenes.s/clustsize),sd= siga)
#cks2<-matrix(rep(ck2, each=clustsize),nrow=ngenes.s, ncol=nclass2)
#ck2.fill<-rbind(cks2,matrix(rnorm(ngenes.s*nclass2, sd=siga), nrow=ngenes.s, ncol=nclass2))

#ck2<-rbind(ck2.fill,cks2)
#ck2<-rbind(ck2,  matrix(rnorm(((ngenes-(ngenes.s*3))*nclass2), sd=siga), ncol=nclass2))

pj<-rbinom(ngenes,1,p)
bj<-matrix((1-pj)*0 + pj*rnorm(ngenes, mub, sd=sigb),nrow=ngenes, ncol=nclass1)
eij<-matrix(rnorm(nclass1*ngenes, sd=sige), nrow=ngenes, ncol=nclass1)
eij2<-matrix(rnorm(nclass2*ngenes, sd=sige), nrow=ngenes, ncol=nclass2)

xij.c1<-bj+eij
xij.c2<-eij2

var.c1<-var.row(xij.c1)
var.c2<-var.row(xij.c2)

xij.c1<-sweep(xij.c1, 1, sqrt(var.c1), FUN="/")
xij.c2<-sweep(xij.c2, 1, sqrt(var.c2), FUN="/")


mndifs<-rowMeans(xij.c1)- rowMeans(xij.c2)
var.c1<-var.row(xij.c1) #These are now 1
var.c2<-var.row(xij.c2) #These are now 1


#sp<- sqrt( ( (nclass1-1)*var.c1 + (nclass2-1)*var.c1 ) / (nclass1 + nclass2 - 2) )
stdifs<-sqrt((1/nclass1)+ (1/nclass2))

tstats<-mndifs/stdifs
#d.o.f<-((var.c1/nclass1 + var.c2/nclass2))^2/( (( (var.c1/nclass1)^2)/ (nclass1-1)) + (( (var.c2/nclass2)^2)/ (nclass2-1)))
tpval<-2*(1-pt(abs(tstats),n-2))
tpval1<-ifelse(tpval==0, min(tpval[tpval>0]), tpval)
truep.s.score<-mean(-log(tpval1[1:ngenes.s]))
i.vec<-cumsum(rep(1,ngenes.s))
true.ks<-max( (i.vec/ngenes.s) - sort(tpval1[1:ngenes.s]))


truen.s<-sum(ifelse(tpval[1:ngenes.s]<0.001,1,0))
truen.sbar<-sum(ifelse(tpval[(ngenes.s+1):ngenes]<0.001,1,0))


truep.s<-mean(ifelse(tpval[1:ngenes.s]<0.001,1,0))
truep.sbar<-mean(ifelse(tpval[(ngenes.s+1):ngenes]<0.001,1,0))
truep.dif<-truep.s-truep.sbar
truet.s<-mean(tstats[1:ngenes.s])
truet.sbar<-mean(tstats[(ngenes.s+1):ngenes])
truet.dif<-truet.s-truet.sbar


pval.p<-1-phyper((truen.s-1),truen.sbar+truen.s,(ngenes-truen.sbar-truen.s) ,ngenes.s)

#################3
#INDEPENDENCE 
#################

fish.tab<-matrix(c(truen.s, ngenes.s-truen.s, truen.sbar, (ngenes-ngenes.s-truen.sbar)),  nrow=2, ncol=2, byrow=T)


f.pv<-fisher.test(fish.tab, alternative="greater")$p.value
f.pvts<-fisher.test(fish.tab)$p.value
f.pvl<-fisher.test(fish.tab, alternative="less")$p.value
suc<-c(truen.s, truen.sbar)
trials<-c(ngenes.s, ngenes-ngenes.s)
bin.pvl<-prop.test(suc,trials, alternative="greater")$p.value
chisq<-chisq.test(fish.tab)$p.value

###########
#GSEA
###########


xij<-cbind(xij.c1,xij.c2)

ordt<-sort(tstats)
s.genes<-c(rep(1,ngenes.s), rep(0, (ngenes-ngenes.s)))

#########################NOW PERMUTE###################
p.k1<-p.k2<-p.k3<-rep(NA,nboot)

for (b in 1:nboot){



####################
#Permutation of residuals for t-stats and props.
####################

psamp<-sample(n,replace=F)
xprm.c1<-xij[,psamp[1:nclass1]]
xprm.c2<-xij[,psamp[(nclass1+1):n]]

mndifs.prm<-rowMeans(xprm.c1)- rowMeans(xprm.c2)
stdifs.prm<-sqrt((var.row(xprm.c1)/nclass1)+ (var.row(xprm.c2)/nclass2))
tstats.prm<-mndifs.prm/stdifs.prm

p1<-enrichfun(s.genes, tstats.prm, ordt)

p.k1[b]<-p1[1]
p.k2[b]<-p1[2]
p.k3[b]<-p1[3]
}
rm(xij)


#####
#Permuted tstats and proportions
#####

k.out<-enrichfun(s.genes, tstats, ordt)

pval.1<-mean(ifelse(sign(k.out[1])*p.k1 > k.out[1],1,0))
pval.2<-mean(ifelse(sign(k.out[2])*p.k2 > k.out[2],1,0))
pval.3<-mean(ifelse(sign(k.out[3])*p.k3 > k.out[3],1,0))



#########################NOW RESAMPLE###################
fcs<-ks<-rep(NA,nperm)


for (b in 1:nperm){
##############
p.samp<-sort(sample(tpval, size=ngenes.s, replace=F))
fcs[b]<-mean(-log(p.samp))
ks[b]<-max( (i.vec/ngenes.s) - p.samp)
}

fcs.pv<-mean(ifelse(fcs>truep.s.score,1,0))
ks.pv<-mean(ifelse(ks>true.ks,1,0))


##############################################
##OUR APPROACH
##############################################

#mean.bj.obs<-apply(bj.obs,1,mean)


mean.bj.1.obs<-rowMeans(xij.c1)
mean.bj.2.obs<-rowMeans(xij.c2)
mean.bj.obs<-mean.bj.1.obs-mean.bj.2.obs
mean.bj<-mean(mean.bj.obs)
sig2.b.hat<-var(mean.bj.obs)
sig2.c1.hat<-var.row(xij.c1)
sig2.c2.hat<-var.row(xij.c2)
s2.j<-((sig2.c1.hat/nclass1) + (sig2.c2.hat/nclass2))
sig2.bar<-mean(s2.j)
bj.star<-mean.bj + ((mean.bj.obs-mean.bj)*sqrt((sig2.b.hat - sig2.bar)/(sig2.b.hat- sig2.bar + s2.j)))


bj.mat<-matrix(mean.bj.obs, nrow=ngenes, ncol=ngenes, byrow=T)
sig2.bj.hat<-(sig2.c1.hat/nclass1 + sig2.c2.hat/nclass2)
mean.bj.est<-mean.bj.obs

gc()
delta<-100 
while(delta>0.0000001){
i<-1
uj<-rep(NA, ngenes)
for (i in 1:ngenes){
fij<-matrix(dnorm(mean.bj.obs[i], mean=mean.bj.est, sd=sqrt(sig2.bj.hat)), nrow=ngenes)
gj<-sum(fij)
fijgj.tab<-fij/gj
uj.num<- t((mean.bj.obs/sig2.bj.hat) * t(fijgj.tab))
uj.denom<- t((1/sig2.bj.hat)* t(fijgj.tab))
uj[i]<- sum(uj.num)/sum(uj.denom)
}
delta<-min(abs(uj - mean.bj.est))
mean.bj.est<-uj
}
bj.star.ed<-mean.bj.est



mn1<-rowMeans(xij.c1)
mn2<-rowMeans(xij.c2)
res1<-sweep(xij.c1,1, mn1, FUN="-")
res2<-sweep(xij.c2,1,mn2, FUN="-")

res<-cbind(res1,res2)
#rm(res1,res2)
gc()

#########################NOW BOOTSTRAP###################
ts.b.s<-ts.b.sbar<-bt.p.s<-bt.p.sbar<-ts.br.s.ed<-ts.br.sbar.ed<-p.res.s.ed<-p.res.sbar.ed<-ts.bj.s<-ts.bj.sbar<-bt.pj.s<-bt.pj.sbar<-p.res.s<-p.res.sbar<-ts.br.s<-ts.br.sbar<-p.prm.s<-p.prm.sbar<-ts.prm.s<-ts.prm.sbar<-p.pm1.s<-p.pm1.sbar<-ts.pm1.s<-ts.pm1.sbar<-p.prm.dif<-ts.prm.dif<-rep(NA,nboot)

for (b in 1:nboot){
samp1<-sample(nclass1, replace=T)
samp2<-sample(nclass2, replace=T)


##############
#Boostrapped t-tsats and proportions
##############
xbt.c1<-xij.c1[,samp1]
xbt.c2<-xij.c2[,samp2]

mndifs.b<-rowMeans(xbt.c1)- rowMeans(xbt.c2)

var.c1.b<-var.row(xbt.c1)
var.c2.b<-var.row(xbt.c2)

sp.b<- sqrt( ( (nclass1-1)*var.c1.b + (nclass2-1)*var.c1.b ) / (nclass1 + nclass2 - 2) )
stdifs.b<-sp.b*sqrt((1/nclass1)+ (1/nclass2))
tstats.b<-mndifs.b/stdifs.b
#tpval.b<-2*(1-pt(abs(tstats.b),n-2))

ts.b.s[b]<-mean(tstats.b[1:ngenes.s])
ts.b.sbar[b]<-mean(tstats.b[(ngenes.s+1):ngenes])
bt.p.s[b]<-mean(ifelse(abs(tstats.b[1:ngenes.s])>t.thresh,1,0))
bt.p.sbar[b]<-mean(ifelse(abs(tstats.b[(ngenes.s+1):ngenes])>t.thresh,1,0))




#############
#Boostrap residuals for t-stats and props
#############
n<-nclass1 + nclass2
samp1<-sample(nclass1, replace=T)
samp2<-sample(((nclass1+1):n), replace=T)
bj.samp<-sample(bj.star,size=ngenes, replace=T)
res.b.c1<-res[,samp1]
res.b.c2<-res[,samp2]
res.b.c1<-res.b.c1+(bj.samp)
res.b.c2<-res.b.c2


mndifs.b.res<-rowMeans(res.b.c1)- rowMeans(res.b.c2)
var.c1.b<-var.row(res.b.c1) #THESE ARE NOW 1
var.c2.b<-var.row(res.b.c2) #THESE ARE NOW 1
sp.b<- sqrt( ( (nclass1-1)*var.c1.b + (nclass2-1)*var.c1.b ) / (nclass1 + nclass2 - 2) )
stdifs.b<-sp.b*sqrt((1/nclass1)+ (1/nclass2))
tstats.res<-mndifs.b.res/stdifs.b
#tpval.b.res<-2*(1-pt(abs(tstats.res),(nclass1 + nclass2 -2)))

ts.br.s[b]<-mean(tstats.res[1:ngenes.s])
ts.br.sbar[b]<-mean(tstats.res[(ngenes.s+1):ngenes])
p.res.s[b]<-mean(ifelse(abs(tstats.res[1:ngenes.s])>t.thresh,1,0))
p.res.sbar[b]<-mean(ifelse(abs(tstats.res[(ngenes.s+1):ngenes])>t.thresh,1,0))

rm(res.b.c1, res.b.c2, mndifs.b.res)



#############
#Boostrap residuals for t-stats and props a la ED
#############
n<-nclass1 + nclass2
samp1<-sample(nclass1, replace=T)
samp2<-sample(((nclass1+1):n), replace=T)

res.b.c1<-res[,samp1]
res.b.c2<-res[,samp2]
bj.samp<-sample(bj.star.ed,size=ngenes, replace=T)
res.b.c1<-res.b.c1+(bj.samp)
res.b.c2<-res.b.c2


mndifs.b.res<-rowMeans(res.b.c1)- rowMeans(res.b.c2)
var.c1.b<-var.row(res.b.c1) #THESE ARE NOW 1
var.c2.b<-var.row(res.b.c2) #THESE ARE NOW 1
sp.b<- sqrt( ( (nclass1-1)*var.c1.b + (nclass2-1)*var.c1.b ) / (nclass1 + nclass2 - 2) )
stdifs.b<-sp.b*sqrt((1/nclass1)+ (1/nclass2))
tstats.res<-mndifs.b.res/stdifs.b
#tpval.b.res<-2*(1-pt(abs(tstats.res),(nclass1 + nclass2 -2)))

ts.br.s.ed[b]<-mean(tstats.res[1:ngenes.s])
ts.br.sbar.ed[b]<-mean(tstats.res[(ngenes.s+1):ngenes])
p.res.s.ed[b]<-mean(ifelse(abs(tstats.res[1:ngenes.s])>t.thresh,1,0))
p.res.sbar.ed[b]<-mean(ifelse(abs(tstats.res[(ngenes.s+1):ngenes])>t.thresh,1,0))

rm(res.b.c1, res.b.c2, mndifs.b.res)




######################
#George's WILD bootstrap
#####################

pm1.c1<-matrix(rep(sample(c(-1,1),nclass1, replace=T), ngenes),byrow=T, nrow=ngenes)
pm1.c2<-matrix(rep(sample(c(-1,1),nclass2, replace=T),ngenes),byrow=T, nrow=ngenes)
#pm1.c1<-sample(c(-1,1),nclass1, replace=T)
#pm1.c2<-sample(c(-1,1),nclass2, replace=T)


res.pm1.c1<-res[,(1:nclass1)]*pm1.c1 +bj.samp
res.pm1.c2<-res[,((nclass1+1):n)]*pm1.c2

mndifs.pm1<-rowMeans(res.pm1.c1)- rowMeans(res.pm1.c2)

var.c1.b<-var.row(res.pm1.c1)
var.c2.b<-var.row(res.pm1.c2)


sp.b<- sqrt( ( (nclass1-1)*var.c1.b + (nclass2-1)*var.c1.b ) / (nclass1 + nclass2 - 2) )
stdifs.b<-sp.b*sqrt((1/nclass1)+ (1/nclass2))

tstats.pm1<-mndifs.pm1/stdifs.b
#tpval.pm1<-2*(1-pt(abs(tstats.pm1),n-2))

ts.pm1.s[b]<-mean(tstats.pm1[1:ngenes.s])
ts.pm1.sbar[b]<-mean(tstats.pm1[(ngenes.s+1):ngenes])
p.pm1.s[b]<-mean(ifelse(abs(tstats.pm1[1:ngenes.s])>t.thresh,1,0))
p.pm1.sbar[b]<-mean(ifelse(abs(tstats.pm1[(ngenes.s+1):ngenes])>t.thresh,1,0))

rm(pm1.c1, pm1.c2, res.pm1.c1, res.pm1.c2, mndifs.pm1)


}


#####
#Boostrapped t-stats and proportions
#####
var.bt.t<-var(ts.b.s-ts.b.sbar)
mn.bt.ts<-mean(ts.b.s)
mn.bt.tsbar<-mean(ts.b.sbar)
var.bt.p<-var(bt.p.s-bt.p.sbar)
mn.bt.ps<-mean(bt.p.s)
mn.bt.psbar<-mean(bt.p.sbar)


ts.bt.pval<-mean(ifelse(0> (ts.b.s-ts.b.sbar), 1,0))
p.bt.pval<-mean(ifelse(0 > (bt.p.s-bt.p.sbar),1,0))

#####
#Bootstrapped residuals for t-stats and props.
#####
var.res.t<-var(ts.br.s-ts.br.sbar)
mn.res.ts<-mean(ts.br.s)
mn.res.tsbar<-mean(ts.br.sbar)
var.res.p<-var(p.res.s-p.res.sbar)
mn.res.ps<-mean(p.res.s)
mn.res.psbar<-mean(p.res.sbar)

ts.res.pval<-mean(ifelse(truet.dif> (ts.br.s-ts.br.sbar), 1,0))
p.res.pval<-mean(ifelse(truep.dif > (p.res.s-p.res.sbar),1,0))


#####
#Bootstrapped residuals for t-stats and props.
#####
var.res.t.ed<-var(ts.br.s.ed-ts.br.sbar.ed)
mn.res.ts.ed<-mean(ts.br.s.ed)
mn.res.tsbar.ed<-mean(ts.br.sbar.ed)
var.res.p.ed<-var(p.res.s-p.res.sbar.ed)
mn.res.ps.ed<-mean(p.res.s.ed)
mn.res.psbar.ed<-mean(p.res.sbar.ed)

ts.res.pval.ed<-mean(ifelse(truet.dif> (ts.br.s.ed-ts.br.sbar.ed), 1,0))
p.res.pval.ed<-mean(ifelse(truep.dif > (p.res.s.ed-p.res.sbar.ed),1,0))





#####
#Wild bootstrap for tstats and props
####

var.pm1.t<-var(ts.pm1.s-ts.pm1.sbar)
mn.pm1.ts<-mean(ts.pm1.s)
mn.pm1.tsbar<-mean(ts.pm1.sbar)
var.pm1.p<-var(p.pm1.s-p.pm1.sbar)
mn.pm1.ps<-mean(p.pm1.s)
mn.pm1.psbar<-mean(p.pm1.sbar)

ts.pm1.pval<-mean(ifelse(truet.dif> (ts.pm1.s-ts.pm1.sbar), 1,0))
p.pm1.pval<-mean(ifelse(truep.dif > (p.pm1.s-p.pm1.sbar),1,0))






out.table<-matrix(c(truen.s, truen.sbar, pval.p,f.pv,f.pvts,f.pvl,chisq, bin.pvl, pval.1, pval.2, pval.3, fcs.pv, ks.pv,var.bt.t, mn.bt.ts, mn.bt.tsbar,ts.bt.pval, var.bt.p, mn.bt.ps, mn.bt.psbar, p.bt.pval,  var.res.t, mn.res.ts, mn.res.tsbar, ts.res.pval, var.res.p, mn.res.ps, mn.res.psbar, p.res.pval, var.res.t.ed, mn.res.ts.ed, mn.res.tsbar.ed, ts.res.pval.ed, var.res.p.ed, mn.res.ps.ed, mn.res.psbar.ed, p.res.pval.ed,  var.pm1.t, mn.pm1.ts, mn.pm1.tsbar,ts.pm1.pval, var.pm1.p, mn.pm1.ps, mn.pm1.psbar,  p.pm1.pval, truep.s, truep.sbar,truet.s,truet.sbar,tstats[1], tstats[2], xij.c1[1,1], xij.c1[2,1],xij.c2[1,1], xij.c2[2,1]), nrow=55, byrow=T)

write(out.table,file=filename, append=T)
}
}




sim.all(nclass1=200,nclass2=200, clustsize=100, ngenes=10000,ngenes.s=500,p=.9, mub=0,sigb=sqrt(.1), siga=sqrt(0.45), sige=sqrt(0.4), nboot=1999,nperm=1999, nsim=1,filename="/data/teacher/biowulf-class/R/run11.txt", seed=49954)


Sys.time()-time1
