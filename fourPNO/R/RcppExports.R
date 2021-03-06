# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' @title Generate Random Multivariate Normal Distribution
#' @description Creates a random Multivariate Normal when given number of obs, mean, and sigma. 
#' @usage rmvnorm(n, mu, sigma)
#' @param n An \code{int}, which gives the number of observations.  (> 0)
#' @param mu A \code{vector} length m that represents the means of the normals.
#' @param sigma A \code{matrix} with dimensions m x m that provides the covariance matrix. 
#' @return A \code{matrix} that is a Multivariate Normal distribution
#' @author James J Balamuta
#' @examples 
#' #Call with the following data:
#' rmvnorm(2, c(0,0), diag(2))
#' 
rmvnorm <- function(n, mu, sigma) {
    .Call('fourPNO_rmvnorm', PACKAGE = 'fourPNO', n, mu, sigma)
}

#' @title Initialize Thresholds
#' @description Internal function for initializing item thresholds.
#' @param Ms A \code{vector} with the number of scale values. 
#' @return A \code{matrix} that is a Multivariate Normal distribution
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
kappa_initialize <- function(Ms) {
    .Call('fourPNO_kappa_initialize', PACKAGE = 'fourPNO', Ms)
}

#' @title Internal Function for Updating Theta in Gibbs Sampler
#' @description Update theta in Gibbs sampler
#' @param N An \code{int}, which gives the number of observations.  (> 0)
#' @param Z A \code{matrix} N by J of continuous augmented data.
#' @param as A \code{vector} of item discrimination parameters.
#' @param bs A \code{vector} of item threshold parameters.
#' @param theta A \code{vector} of prior thetas.
#' @param mu_theta The prior mean for theta.
#' @param Sigma_theta_inv The prior inverse variance for theta.
#' @return A \code{vector} of thetas.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
update_theta <- function(N, Z, as, bs, theta, mu_theta, Sigma_theta_inv) {
    .Call('fourPNO_update_theta', PACKAGE = 'fourPNO', N, Z, as, bs, theta, mu_theta, Sigma_theta_inv)
}

#' @title Update a and b Parameters of 2PNO, 3PNO, 4PNO
#' @description Update item slope and threshold
#' @param N An \code{int}, which gives the number of observations.  (> 0)
#' @param J An \code{int}, which gives the number of items.  (> 0)
#' @param Z A \code{matrix} N by J of continuous augmented data.
#' @param as A \code{vector} of item discrimination parameters.
#' @param bs A \code{vector} of item threshold parameters.
#' @param theta A \code{vector} of prior thetas.
#' @param mu_xi A two dimensional \code{vector} of prior item parameter means.
#' @param Sigma_xi_inv A two dimensional identity \code{matrix} of prior item parameter VC matrix.
#' @return A list of item parameters.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
update_ab_NA <- function(N, J, Z, as, bs, theta, mu_xi, Sigma_xi_inv) {
    .Call('fourPNO_update_ab_NA', PACKAGE = 'fourPNO', N, J, Z, as, bs, theta, mu_xi, Sigma_xi_inv)
}

#' @title Update a and b Parameters of 4pno without alpha > 0 Restriction
#' @description Update item slope and threshold
#' @param N An \code{int}, which gives the number of observations.  (> 0)
#' @param J An \code{int}, which gives the number of items.  (> 0)
#' @param Z A \code{matrix} N by J of continuous augmented data.
#' @param as A \code{vector} of item discrimination parameters.
#' @param bs A \code{vector} of item threshold parameters.
#' @param theta A \code{vector} of prior thetas.
#' @param mu_xi A two dimensional \code{vector} of prior item parameter means.
#' @param Sigma_xi_inv A two dimensional identity \code{matrix} of prior item parameter VC matrix.
#' @return A list of item parameters.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
update_ab_norestriction <- function(N, J, Z, as, bs, theta, mu_xi, Sigma_xi_inv) {
    .Call('fourPNO_update_ab_norestriction', PACKAGE = 'fourPNO', N, J, Z, as, bs, theta, mu_xi, Sigma_xi_inv)
}

#' @title Update Lower and Upper Asymptote Parameters of 4PNO
#' @description Internal function to update item lower and upper asymptote
#' @param Y A N by J \code{matrix} of item responses.
#' @param Ysum A \code{vector} of item total scores.
#' @param Z A \code{matrix} N by J of continuous augmented data.
#' @param as A \code{vector} of item discrimination parameters.
#' @param bs A \code{vector} of item threshold parameters.
#' @param gs A \code{vector} of item lower asymptote parameters.
#' @param ss A \code{vector} of item upper asymptote parameters.
#' @param theta A \code{vector} of prior thetas.
#' @param Kaps A \code{matrix} for item thresholds (used for internal computations).
#' @param alpha_c The lower asymptote prior 'a' parameter.
#' @param beta_c The lower asymptote prior 'b' parameter.
#' @param alpha_s The upper asymptote prior 'a' parameter.
#' @param beta_s The upper asymptote prior 'b' parameter.
#' @param gwg_reps The number of Gibbs within Gibbs MCMC samples for marginal distribution of gamma.
#' @return A list of item threshold parameters.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
update_WKappaZ_NA <- function(Y, Ysum, Z, as, bs, gs, ss, theta, Kaps, alpha_c, beta_c, alpha_s, beta_s, gwg_reps) {
    .Call('fourPNO_update_WKappaZ_NA', PACKAGE = 'fourPNO', Y, Ysum, Z, as, bs, gs, ss, theta, Kaps, alpha_c, beta_c, alpha_s, beta_s, gwg_reps)
}

#' @title Compute 4PNO Deviance
#' @description Internal function to -2LL
#' @param N An \code{int}, which gives the number of observations.  (> 0)
#' @param J An \code{int}, which gives the number of items.  (> 0)
#' @param Y A N by J \code{matrix} of item responses.
#' @param as A \code{vector} of item discrimination parameters.
#' @param bs A \code{vector} of item threshold parameters.
#' @param gs A \code{vector} of item lower asymptote parameters.
#' @param ss A \code{vector} of item upper asymptote parameters.
#' @param theta A \code{vector} of prior thetas.
#' @return -2LL.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
min2LL_4pno <- function(N, J, Y, as, bs, gs, ss, theta) {
    .Call('fourPNO_min2LL_4pno', PACKAGE = 'fourPNO', N, J, Y, as, bs, gs, ss, theta)
}

#' @title Simulate from 4PNO Model
#' @description Generate item responses under the 4PNO
#' @param N An \code{int}, which gives the number of observations.  (> 0)
#' @param J An \code{int}, which gives the number of items.  (> 0)
#' @param as A \code{vector} of item discrimination parameters.
#' @param bs A \code{vector} of item threshold parameters.
#' @param gs A \code{vector} of item lower asymptote parameters.
#' @param ss A \code{vector} of item upper asymptote parameters.
#' @param theta A \code{vector} of prior thetas.
#' @return A N by J \code{matrix} of dichotomous item responses.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
Y_4pno_simulate <- function(N, J, as, bs, gs, ss, theta) {
    .Call('fourPNO_Y_4pno_simulate', PACKAGE = 'fourPNO', N, J, as, bs, gs, ss, theta)
}

#' @title Calculate Tabulated Total Scores 
#' @description Internal function to -2LL
#' @param N An \code{int}, which gives the number of observations.  (> 0)
#' @param J An \code{int}, which gives the number of items.  (> 0)
#' @param Y A N by J \code{matrix} of item responses.
#' @return A vector of tabulated total scores.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
Total_Tabulate <- function(N, J, Y) {
    .Call('fourPNO_Total_Tabulate', PACKAGE = 'fourPNO', N, J, Y)
}

#' @title Gibbs Implementation of 4PNO
#' @description Internal function to -2LL
#' @param Y A N by J \code{matrix} of item responses.
#' @param mu_xi A two dimensional \code{vector} of prior item parameter means.
#' @param Sigma_xi_inv A two dimensional identity \code{matrix} of prior item parameter VC matrix.
#' @param mu_theta The prior mean for theta.
#' @param Sigma_theta_inv The prior inverse variance for theta.
#' @param alpha_c The lower asymptote prior 'a' parameter.
#' @param beta_c The lower asymptote prior 'b' parameter.
#' @param alpha_s The upper asymptote prior 'a' parameter.
#' @param beta_s The upper asymptote prior 'b' parameter.
#' @param burnin The number of MCMC samples to discard.
#' @param cTF A J dimensional \code{vector} indicating which lower asymptotes to estimate.
#' @param sTF A J dimensional \code{vector} indicating which upper asymptotes to estimate.
#' @param gwg_reps The number of Gibbs within Gibbs MCMC samples for marginal distribution of gamma.
#' @param chain_length The number of MCMC samples.
#' @return Samples from posterior.
#' @author Steven Andrew Culpepper
#' 
Gibbs_4PNO <- function(Y, mu_xi, Sigma_xi_inv, mu_theta, Sigma_theta_inv, alpha_c, beta_c, alpha_s, beta_s, burnin, cTF, sTF, gwg_reps, chain_length = 10000L) {
    .Call('fourPNO_Gibbs_4PNO', PACKAGE = 'fourPNO', Y, mu_xi, Sigma_xi_inv, mu_theta, Sigma_theta_inv, alpha_c, beta_c, alpha_s, beta_s, burnin, cTF, sTF, gwg_reps, chain_length)
}

#' @title Update 2PNO Model Parameters
#' @description Internal function to update 2PNO parameters
#' @param Y A N by J \code{matrix} of item responses.
#' @param Z A \code{matrix} N by J of continuous augmented data.
#' @param as A \code{vector} of item discrimination parameters.
#' @param bs A \code{vector} of item threshold parameters.
#' @param theta A \code{vector} of prior thetas.
#' @param Kaps A \code{matrix} for item thresholds (used for internal computations).
#' @return A list of item parameters.
#' @seealso \code{\link{Gibbs_4PNO}}
#' @author Steven Andrew Culpepper
#' 
update_2pno <- function(N, J, Y, Z, as, bs, theta, Kaps, mu_xi, Sigma_xi_inv, mu_theta, Sigma_theta_inv) {
    .Call('fourPNO_update_2pno', PACKAGE = 'fourPNO', N, J, Y, Z, as, bs, theta, Kaps, mu_xi, Sigma_xi_inv, mu_theta, Sigma_theta_inv)
}

#' @title Gibbs Implementation of 2PNO
#' @description Implement Gibbs 2PNO Sampler
#' @param Y A N by J \code{matrix} of item responses.
#' @param mu_xi A two dimensional \code{vector} of prior item parameter means.
#' @param Sigma_xi_inv A two dimensional identity \code{matrix} of prior item parameter VC matrix.
#' @param mu_theta The prior mean for theta.
#' @param Sigma_theta_inv The prior inverse variance for theta.
#' @param burnin The number of MCMC samples to discard.
#' @param chain_length The number of MCMC samples.
#' @return Samples from posterior.
#' @author Steven Andrew Culpepper
#' 
Gibbs_2PNO <- function(Y, mu_xi, Sigma_xi_inv, mu_theta, Sigma_theta_inv, burnin, chain_length = 10000L) {
    .Call('fourPNO_Gibbs_2PNO', PACKAGE = 'fourPNO', Y, mu_xi, Sigma_xi_inv, mu_theta, Sigma_theta_inv, burnin, chain_length)
}

