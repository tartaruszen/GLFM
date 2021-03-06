# Tiny example
rm(list=ls())
# Aqui pones el path de tu directorio. Lo puedes obtener con getwd()
setwd("~/Documents/Working_papers/FAP_Rpackage/GLFM/src/GLFMR")
source("GLFM_infer.R")
source("GLFM_computeMAP.R")
source("GLFM_complete.R")
source("GLFM_computePDF.R")
source("init_default_params.R")
 X <- matrix(rnorm(10,0,1),nrow=10,ncol=5)
 C <- c('g','g','g','g','g')
 data<-list("X"=X,"C"=C)
 # GLFM_infer, c() es para un vector vacio, 
 # te devuelve una lista de listas: output$hidden y output$params
 output<-GLFM_infer(data,c())
 # GLFM_computeMAP
 # Te devuelve la matrix X_map
 Kest<-dim(output$hidden$B)[1]
 Zp <-diag(Kest)
 X_map <- GLFM_computeMAP(data$C, Zp, output$hidden, output$params,c())
 #GLFM_computePDF, te devuelve una lista con pdf y xd
 D<-dim(X)[2]
 for(dd in 1:D){
  pdf_val<-GLFM_computePDF(data,Zp,output$hidden,output$params,dd) 
  print(pdf_val)
  readline("Press return to continue")
 }
 #GLFM_complete
 X[1,5]<-NaN
 X[10,5]<-NaN
 data<-list("X"=X,"C"=C)
output2<-GLFM_complete(data,c())
 # Aqui tengo duda sobre como llamar a GLFM_computeMAP