##################################
# A simple probabilistic inference
#   program for a Lotka-Volterra
#   model using rstan and Stan
#
#   Adapted from:
#     https://github.com/stan-dev/example-models/tree/master/knitr/lotka-volterra
##################################

library(rstan)
library(shiny)
library(shinystan)
library(rstanarm)
library(bayesplot)
library(ggplot2)

lynx_hare_df <- read.csv("hudson-bay-lynx-hare.csv", comment.char="#")

# the data is munged into a form suitable for Stan.

N <- length(lynx_hare_df$Year) - 1
ts <- 1:N
y_init <- c(lynx_hare_df$Hare[1], lynx_hare_df$Lynx[1])
y <- as.matrix(lynx_hare_df[2:(N + 1), 2:3])
y <- cbind(y[ , 2], y[ , 1]); # hare, lynx order
lynx_hare_data <- list(N, ts, y_init, y)

# the model is translated to C++ and compiled.

model <- stan_model("lotka-volterra.stan")

fit <- sampling(model, data = lynx_hare_data)

# The output can be displayed in tabular form, here limited to the median 
# (0.5 quantile) and 80% interval (0.1 and 0.9 quantiles), and restricted to the parameters of interest.


print(fit, pars=c("theta", "sigma", "z_init"),
      probs=c(0.1, 0.5, 0.9), digits = 3)

shinystan::launch_shinystan(fit)


# Plot posterior

# posterior <- as.array(fit)
# dim(posterior)
# 
# 
# color_scheme_set("red")
# mcmc_intervals(posterior, pars = c("theta", "sigma", "z_init")) # ,"female"
# 
# 
# mcmc_areas(
#   posterior,
#   pars = c("(Intercept)"),
#   prob = 0.8, # 80% intervals
#   prob_outer = 0.99, # 99%
#   point_est = "mean"
# )
# 
# color_scheme_set("green")
# mcmc_hist(posterior, pars = c("(Intercept)")) #, "wt", "sigma"
# 
# color_scheme_set("blue")
# mcmc_hist(posterior, pars = c("(Intercept)")) # , "wt", "sigma"
# 
# color_scheme_set("teal")
# mcmc_violin(posterior, pars = c("(Intercept)"), probs = c(0.1, 0.5, 0.9))
# 
# 
# color_scheme_set("pink")
# # mcmc_pairs(posterior, pars = c("(Intercept)"))
# #, # , "wt", "sigma"
# #           off_diag_args = list(size = 1.5))
# 
# color_scheme_set("blue")
# mcmc_trace(posterior, pars = c("(Intercept)"))