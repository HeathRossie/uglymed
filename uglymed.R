###### ugnlymed ######
# 2021 Oct 29 
# written by Hiroshi Matsui, PhD

# functions in uglymed
# read.med : read a file from MED
# read.med.all : read multiple files and combine by read.med
# log.sur : compute log-survivor probabilities
# log.survivor.plot : depict log-survivor plot
# estimate_bout : feed irt, return three bout parameters according to a double-exponential model

### read raw data ------------------------------------------------------------#
read.med = function(file, rft_indicator, scale=NULL, remove=NULL, remove_initial=NULL){
  # file : file name, should be character
  # rft_indicator : number indicating rft, which should be removed for response time series
  # scale : numeric, scaling for desirable units (for example data unit is 10ms, scaling 1/100 prduces unit sec)
  # remove : int, remove data 
  # remove_initial : integer (N), latest N data is used, initial all_data_length - N were removed
  
  # read data
  d =  read.csv(file, skip=5)
  colnames(d) = "press"
  column_C = grep("C:", d$press)
  column_N = setdiff(grep("N:", d$press), grep("N: ", d$press))
  length(column_C)
  length(column_N)
  resp = list()
  
  options(warn=-1)
  for(i in 1:length((column_C))){
    temp = d[ (column_C[i] + 1) : (column_N[i] - 1),]
    temp = strsplit(temp, " ")
    temp = lapply(temp, as.numeric)
    temp = unlist(temp)
    temp = temp[!is.na(temp)]
    resp[[i]] = temp
  }
  options(warn=0)
  
  
  # remove unnecessary data
  if(length(remove) > 0) {
    resp = resp[-remove]
  }
  
  if(length(remove_initial) > 0) {
    N = length(resp) - remove_initial
    resp = resp[-(1:N)]
  }
  
  
  
  # scale (for example, if data unit is 10ms, scaling 1/100 produces unit sec)
  if(length(scale) > 0){
    resp = lapply(resp, function(v) v/scale)
    rft_indicator = rft_indicator/scale
  }
  
  
  # combine
  data = list()
  for(i in 1:length(resp)){
    data[[i]] = list(resp[[i]], i)
  }
  
  d = lapply(data, function(L){
    
    d_ = data.frame(id = L[[2]], resp = L[[1]])
    d_$rft = 0
    d_[which(d_$resp==rft_indicator)-1,]$rft = 1
    d_ = d_[d_$resp!=rft_indicator,]
    d_$irt = c(d_$resp[1], diff(d_$resp))
    d_$file = file
    return(d_)
  }) %>% do.call(rbind,.)
  
  return(d)
}


# d = read.med( "!2020-11-20.txt", rft_indicator=0.2, scale=100,  remove_initial=16)


### read raw data ------------------------------------------------------------#
# read multiple files
read.med.all = function(files, rft_indicator, scale=NULL, remove=NULL, remove_initial=NULL){
  d = do.call(rbind, lapply(files, function(file) read.med(file, rft_indicator=rft_indicator, scale=scale, remove=remove, remove_initial=remove_initial)))
  return(d)
}

# d = read.med.all(c("!2020-11-20.txt", "!2020-11-24.txt"), rft_indicator=0.2, scale = 100,remove_initial=16)


### log-survivor plot ------------------------------------------------------------#

log.sur = function(irt, LEN = 10, MIN=NULL, MAX=NULL){
  if(length(MIN) == 0) MIN = min(irt)
  if(length(MAX) == 0) MAX = max(irt)
  
  BIN = seq(MIN,MAX,length=LEN)
  PROB = 1-unlist(lapply(BIN, function(bin) sum(irt < bin)/length(irt)))
  
  return(data.frame(bin = BIN, prob = PROB, logP = log(PROB)))
}


log.survivor.plot = function(irt, LEN = 10, MIN=NULL, MAX=NULL){
  logp = log.sur(irt, LEN = LEN, MIN=MIN, MAX=MAX)
  p = ggplot(logp) + 
    geom_line(aes(x=bin, y=logP)) + 
    geom_point(aes(x=bin, y=logP)) + 
    xlab("time") + ylab("log probability (irt < t)") + 
    theme(axis.text = element_text(size=rel(2)),
          axis.title = element_text(size=rel(2)))
  
  return(p)
}



### bout parameters ------------------------------------------------------------#
# using maximum likelihood via VGAM package
# see https://rdrr.io/cran/VGAM/man/mix2exp.html

estimate_bout = function(irt){
  # test
  # dat = c(rexp(1000, rate=1), rexp(500, rate=50))
  # dat = sort(dat)
  # fit = VGAM::vglm(dat ~ 1, VGAM::mix2exp, trace = TRUE)
  
  fit = VGAM::vglm(irt ~ 1, VGAM::mix2exp, trace = TRUE)
  param = VGAM::Coef(fit)
  
  params = data.frame(
    bout_length = 1/param[1],
    bout_initiation = 1/param[2],
    bout_within = 1/param[3])
  return(params)
}

# estimate_bout(d$irt)

