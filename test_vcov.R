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


vcov(model, use.hessian = TRUE) # TRUE unavailable because nAGQ == 0
vcov(model, use.hessian = FALSE)

getME(model, "RX")
getME(model, "beta") # estimates for fixed effects
getME(model, "theta") # estimates for random effects


# testing model with nAGQ > 0
# model2 <- glmer("OBSERVATION.COUNT ~ month + month:log(no.sp) + timegroups + (1|gridg3/gridg1)", 
#                 data = data_lwdu, family = binomial(link = 'cloglog'), 
#                 nAGQ = 1, control = glmerControl(optimizer = "bobyqa"))
# # VERY long time to run, so save
# save(model2, file = "test_vcov_nAGQ1.RData")
load("test_vcov_nAGQ1.RData")


# dataframe to predict
data_to_pred <- data_lwdu %>% 
  distinct(month, timegroups) %>% 
  mutate(no.sp = 15,
         gridg1 = data_lwdu$gridg1[1], 
         gridg3 = data_lwdu$gridg3[1])


predint1 = predictInterval(model, newdata = data_to_pred, which = "fixed",
                           level = 0.48, type = "linear.prediction")
predint1_mean <- predint1$fit
predint1_se <- predint1$fit - predint1$lwr

predint2 = predictInterval(model2, newdata = data_to_pred, which = "fixed",
                           level = 0.48, type = "linear.prediction")
predint2_mean <- predint2$fit
predint2_se <- predint2$fit - predint2$lwr


# print comparisons
paste("nAGQ = 0:", predint1_se[1], ", nAGQ = 1:", predint2_se[1])
