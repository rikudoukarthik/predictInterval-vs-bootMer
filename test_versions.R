### NOTE: this script modifies your installed packages ###

### Run after soib_reprex.R has been run and its objects are 
### still in the environment

# install older version of merTools
library(devtools)
devtools::install_version("merTools", version = "0.6.1")
# check version
packageVersion("merTools")


###


# model and predictInterval()

library(dplyr)
library(lme4)
library(merTools)

# tictoc::tic("predictInterval")
model_predint_old = predictInterval(model, newdata = data_to_pred, which = "fixed",
                                    level = 0.48, type = "linear.prediction")
predint_old_mean <- model_predint_old$fit
predint_old_se <- model_predint_old$fit - model_predint_old$lwr
# tictoc::toc()

# print comparisons
paste("SEs: 0.6.2 =", predint_se[1], ", 0.6.1 =", predint_old_se[1])


###


# revert to latest merTools version

# detach("package:merTools", unload = TRUE, force = TRUE)
# detach("package:lme4", unload = TRUE, force = TRUE)
install.packages("merTools")
# check version
packageVersion("merTools")
