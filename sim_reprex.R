# Load required packages
library(lme4)

# Set seed for reproducibility
set.seed(123)

# Parameters
n_groups <- 100     # Number of groups (levels of grid1)
n_per_group <- 1000  # Observations per group
n <- n_groups * n_per_group  # Total observations

# Simulate grouping variable
grid1 <- factor(rep(1:n_groups, each = n_per_group))

# Simulate predictor variables
var1 <- rnorm(n, mean = 0, sd = 1)  # Continuous predictor
var2 <- rbinom(n, size = 1, prob = 0.5)  # Binary predictor

# Simulate random intercepts
random_intercepts <- rnorm(n_groups, mean = 0, sd = 0.5)  # Random effect for grid1

# Simulate linear predictor
# Intercept: -1, var1 coefficient: 0.5, var2 coefficient: -0.3
eta <- -1 + 0.5 * var1 - 0.3 * var2 + random_intercepts[grid1]

# Apply the cloglog link
prob <- 1 - exp(-exp(eta))

# Simulate binary response variable
response <- rbinom(n, size = 1, prob = prob)

# Create the dataset
data <- data.frame(response = response, var1 = var1, var2 = var2, grid1 = grid1)




# Example GLMM model using lme4
model <- glmer(response ~ var1 + var2 + (1 | grid1), 
               family = binomial(link = "cloglog"), 
               data = data)



# Use bootMER for uncertainty estimation
boot_predictions <- bootMer(
  model, 
  FUN = function(fit) predict(fit, newdata = data), 
  nsim = 10, 
  seed = 42
)

# Combine all bootstrap predictions
boot_all_predictions <- boot_predictions$t[, 1] # 1st sim

# Calculate global mean, LCI, and UCI for bootMER
boot_global_mean <- median(boot_all_predictions)
boot_global_se <- sd(boot_all_predictions)


# Use predictInterval for uncertainty estimation
predict_results <- predictInterval(
  model,
  newdata = data,
  which = "fixed",
  level = 0.48,
  type = "linear.prediction",
  n.sims = 1000
)

# Calculate global mean, LCI, and UCI for predictInterval
predict_mean <- predict_results$fit
predict_se <- predict_results$fit - predict_results$lwr

# Print the comparison
cat(sprintf("Mean: bootMer = %.3f, predictInterval = %.3f\n", boot_global_mean, predict_mean[1]))
cat(sprintf("se: bootMer = %.3f, predictInterval = %.3f\n", boot_global_se, predict_se[1]))
