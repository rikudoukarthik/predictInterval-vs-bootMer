### NOTE: this script modifies your installed packages ###

### Run after soib_reprex.R has been run and its objects are 
### still in the environment

# install older version of merTools
library(devtools)
devtools::install_version("merTools", version = "0.6.1")
remove.packages("lme4", lib="~/R/x86_64-pc-linux-gnu-library/4.4") # linux
devtools::install_version("lme4", version = "1.1.33") 
# R 4.4.2 unable to install older lme4, see https://github.com/tidyverse/vroom/issues/538#issuecomment-2090869926

# check version
packageVersion("merTools")
packageVersion("lme4")

###


# model and predictInterval()

library(dplyr)
library(lme4)
library(merTools)


load("reprex_pred_lwdu.RData")
# subsetting the data, still reproduces issue
data_lwdu <- slice_sample(data_lwdu, n = 100000) 


# model
model <- glmer("OBSERVATION.COUNT ~ month + month:log(no.sp) + timegroups + (1|gridg3/gridg1)", 
               data = data_lwdu, family = binomial(link = 'cloglog'), 
               nAGQ = 0, control = glmerControl(optimizer = "bobyqa"))

# dataframe to predict
data_to_pred <- data_lwdu %>% 
  distinct(month, timegroups) %>% 
  mutate(no.sp = 15,
         gridg1 = data_lwdu$gridg1[1], 
         gridg3 = data_lwdu$gridg3[1])


# tictoc::tic("predictInterval")
model_predint_old = predictInterval(model, newdata = data_to_pred, which = "fixed",
                                    level = 0.48, type = "linear.prediction")
predint_old_mean <- model_predint_old$fit
predint_old_se <- model_predint_old$fit - model_predint_old$lwr
# tictoc::toc()

# print comparisons (run soib_reprex.R first to get predint_se)
paste("SEs: current =", predint_se[1], ", old =", predint_old_se[1])


###


# revert to latest merTools version

# detach("package:merTools", unload = TRUE, force = TRUE)
# detach("package:lme4", unload = TRUE, force = TRUE)
install.packages("merTools")
install.packages("lme4")
# check version
packageVersion("merTools")
packageVersion("lme4")
