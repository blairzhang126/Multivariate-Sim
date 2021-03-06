#R code for simulating unbalanced scenario (Scenario1 in paper), which has 4 traits with case sample size of 100 and 1 trait with case sample size of 500. 
library(bindata)
library(MultiPhen)
n=10000
maf=0.05

#User can specify different beta0 to control case sample size
beta0=c(-4.6,-4.6,-4.6,-4.6,-3)
x<-sample(c(0,1,2),n,replace=T,prob=c((1-maf)*(1-maf),2*maf*(1-maf),maf*maf))
x<-as.matrix(x)
#User can specify different beta to control the effect sizes of the SNPs
beta=c(0.3,0.3,0.3,0.3,0.3)

#User can input a phenotype matrix which they wish to produce the correlation matrix for simulated traits. In this example, d file contains 5 traits as columns and individuals as rows (with a header and no rowname). Here I'm posting an example of the correlation matrix (b_cor) among 5 traits that described in the manuscript.
#d<-read.table("random_select_5_trait_from_ukb",header=T)
#b_cor<-cor(d)
#b_cor
#              F322         F432         I208        I258         I429
#F322  1.0000000000 0.0415276512 0.0007543885 0.001951613 -0.001077797
#F432  0.0415276512 1.0000000000 0.0008421039 0.005441721  0.002168689
#I208  0.0007543885 0.0008421039 1.0000000000 0.098728472  0.003179557
#I258  0.0019516132 0.0054417214 0.0987284719 1.000000000  0.029784037
#I429 -0.0010777969 0.0021686888 0.0031795574 0.029784037  1.000000000
b_cor<-matrix(c(1.0000000000,0.0415276512,0.0007543885,0.001951613,-0.001077797, 0.0415276512, 1.0000000000, 0.0008421039, 0.005441721,  0.002168689, 0.0007543885, 0.0008421039, 1.0000000000, 0.098728472,  0.003179557, 0.0019516132, 0.0054417214, 0.0987284719, 1.000000000,  0.029784037, -0.0010777969, 0.0021686888, 0.0031795574, 0.029784037,  1.000000000),nrow=5,ncol=5,byrow=TRUE)

prob<-matrix(nrow=10000, ncol=5)
prob[,1]<-exp(beta0[1]+x %*% t(beta[1]))/(1+exp(beta0[1]+x %*% t(beta[1])))
prob[,2]<-exp(beta0[2]+x %*% t(beta[2]))/(1+exp(beta0[2]+x %*% t(beta[2])))
prob[,3]<-exp(beta0[3]+x %*% t(beta[3]))/(1+exp(beta0[3]+x %*% t(beta[3])))
prob[,4]<-exp(beta0[4]+x %*% t(beta[4]))/(1+exp(beta0[4]+x %*% t(beta[4])))
prob[,5]<-exp(beta0[5]+x %*% t(beta[5]))/(1+exp(beta0[5]+x %*% t(beta[5])))

y<-t(apply(prob, 1, function(m) rmvbin(1, margprob=m, bincorr=b_cor)))

colnames(y) <-c("Trait_1","Trait_2", "Trait_3", "Trait_4", "Trait_5")
logistic.out1 <- glm(y[,1] ~ x[,1],family=binomial)
tmp1 <- summary(logistic.out1)[[12]][2,]

logistic.out2 <- glm(y[,2] ~ x[,1],family=binomial)
tmp2 <- summary(logistic.out2)[[12]][2,]

logistic.out3 <- glm(y[,3] ~ x[,1],family=binomial)
tmp3 <- summary(logistic.out3)[[12]][2,]

logistic.out4 <- glm(y[,4] ~ x[,1],family=binomial)
tmp4 <- summary(logistic.out4)[[12]][2,]

logistic.out5 <- glm(y[,5] ~ x[,1],family=binomial)
tmp5 <- summary(logistic.out5)[[12]][2,]

tmp<-cbind(tmp1,tmp2,tmp3,tmp4,tmp5)
tmp_t<-t(tmp)
write.table(tmp_t,file="run1.unbalanced.logistic.output",quote=F,row.names=T,col.names=T,sep='\t')


y<-as.matrix(y)
rownames(y)<-seq(1:10000)
rownames(x)<-seq(1:10000)
mPhen_out <- mPhen(x[,1, drop=FALSE], y, phenotypes = all,  resids = NULL, covariates=NULL, strats = NULL,opts = mPhen.options(c("regression","pheno.input")))
mPhen_jointp <- mPhen_out$Results[,,,2][6]
write.table(mPhen_jointp, file="run1.unbalanced.multiphen.output", col.names=T, row.names=T, sep="\t",quote=F)

