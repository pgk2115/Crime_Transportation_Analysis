
library(dplyr)
library(stringr)
library(tidyverse)
library(rgdal)
library(arm)
library(ggplot2)

tractsv <- readOGR(dsn = "C:\\Users\\jchae\\Desktop\\Tracts", layer= "TractsALL2010")

chic<-read.csv('chicago_cleaned.csv', stringsAsFactors = F)
pt<-read.csv("Chicago_Homicide.csv", stringsAsFactors = F)

sp <- SpatialPoints(pt[,c("longitude", "latitude")])
proj4string(sp) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
proj4string(sp)


by_tract <- over(sp, tractsv)
by_tract$FIPS <- as.character(by_tract$FIPS)

pt$fips <- by_tract$FIPS


pt<-pt[, c("fips", "min_Getaway_Distance")]
means<-tapply(pt$min_Getaway_Distance, pt$fips, mean)
fips<-names(means)
names(means)<-NULL
means<-cbind(fips, means)
means<-as.data.frame(means)
means$fips<-as.numeric(as.character(means$fips))
means$means<-as.numeric(as.character(means$means))

##demographic data cleaning 
dem<-read.csv("census tract covariates.csv", stringsAsFactors = F)
dem$tract<-str_pad(dem$tract, side="left", pad=0, width=6)
dem$county<-str_pad(dem$county, side="left", pad=0, width=3)
dem$state<-str_pad(dem$state, side="left", pad=0, width=2)
dem$fips<-paste0(dem$state, dem$county, dem$tract)

fips<-dem[,c("fips")]

dem_10<-dem[,c(grep("2010", colnames(dem)))]
dem_10<-cbind(fips, dem_10)

dem_00<-dem[,c(grep("2000", colnames(dem)))]
dem_00<-cbind(fips, dem_00)


census<-chic %>%
  group_by(fips, ofns_desc) %>%
  tally() %>% 
  complete(ofns_desc=c("Aggravated Assault", "burglary", "criminal homicide", "robbery", "theft(including auto)"), fill = list(n = 0)) 

vars<-colnames(dem_10)[-1]
for(i in 1:length(vars)){
  census[,vars[i]]<-dem_10[match(census$fips, dem_10$fips), vars[i]]
}

census$sqmi<-tractsv$SQMI[match(census$fips, tractsv$FIPS)]
census$mean_getaway_dist<-means$means[match(census$fips, means$fips)]


lm1<-lm(n~frac_coll_plus2010+foreign_share2010+poor_share2010+share_black2010+share_hisp2010+share_asian2010+
          singleparent_share2010+traveltime15_2010+mail_return_rate2010+popdensity2010+sqmi, 
        data=census[which(census$ofns_desc=="criminal homicide"),])
summary(lm1)

modelcoef<-summary(lm1)$coefficients[1:length(lm1$coefficients), 1]
modelse<-summary(lm1)$coefficients[1:length(lm1$coefficients), 2]
names<-names(lm1$coefficients)
dfplot<-data.frame(names, modelcoef, modelse)
rownames(dfplot)<-NULL

pdf("coefplot1.pdf")
p<-ggplot(dfplot, aes(x=names, y=modelcoef)) + 
  geom_pointrange(aes(ymin=modelcoef-1.96*modelse, ymax=modelcoef+1.96*modelse)) + 
  theme_bw()  + coord_flip() + xlab('Variables') + ylab('')+ geom_hline(yintercept = 0, lty=2)
p+ggtitle("Coefficients from OLS Regression on Counts of Criminal Homicide in Chicago", subtitle = "Includes 0 counts")
dev.off()

hom<-census %>%
  filter(ofns_desc=="criminal homicide")

hom$binary<-ifelse(hom$n==0, 0, 1)

homicide<-subset(hom, n>0)

lm2<-lm(n~frac_coll_plus2010+foreign_share2010+poor_share2010+share_black2010+share_hisp2010+share_asian2010+
          singleparent_share2010+traveltime15_2010+mail_return_rate2010+popdensity2010+sqmi+log(mean_getaway_dist), 
        data=homicide)
summary(lm2)

modelcoef<-summary(lm2)$coefficients[1:length(lm2$coefficients), 1]
modelse<-summary(lm2)$coefficients[1:length(lm2$coefficients), 2]
names<-names(lm2$coefficients)
dfplot<-data.frame(names, modelcoef, modelse)
rownames(dfplot)<-NULL

pdf("coefplot2.pdf")
p<-ggplot(dfplot, aes(x=names, y=modelcoef)) + 
  geom_pointrange(aes(ymin=modelcoef-1.96*modelse, ymax=modelcoef+1.96*modelse)) + 
  theme_bw()  + coord_flip() + xlab('Variables') + ylab('')+ geom_hline(yintercept = 0, lty=2)
p+ggtitle("Coefficients from OLS Regression on Counts of Criminal Homicide in Chicago", subtitle = "Does not include 0 counts")
dev.off()

glm1<-glm(binary~frac_coll_plus2010+foreign_share2010+poor_share2010+share_black2010+share_hisp2010+share_asian2010+
            singleparent_share2010+traveltime15_2010+mail_return_rate2010+popdensity2010+sqmi, data=hom, family="binomial")
summary(glm1)

modelcoef<-summary(glm1)$coefficients[1:length(glm1$coefficients), 1]
modelse<-summary(glm1)$coefficients[1:length(glm1$coefficients), 2]
names<-names(glm1$coefficients)
dfplot<-data.frame(names, modelcoef, modelse)
rownames(dfplot)<-NULL

pdf("coefplot3.pdf")
p<-ggplot(dfplot, aes(x=names, y=modelcoef)) + 
  geom_pointrange(aes(ymin=modelcoef-1.96*modelse, ymax=modelcoef+1.96*modelse)) + 
  theme_bw()  + coord_flip() + xlab('Variables') + ylab('')+ geom_hline(yintercept = 0, lty=2)
p+ggtitle("Coefficients from Logistic Regression on Criminal Homicide in Chicago", subtitle = "1 if homicide occurred in census tract, 0 otherwise")
dev.off()

