library(lattice)
library(e1071)
library(class)
set.seed(123)
online.news.popularity <- read.csv(file="new_sample_OnlineNewsPopularity.csv",head=TRUE,sep=",")

online.news.popularity$channel <- online.news.popularity$data_channel_is_lifestyle +
                                  2*online.news.popularity$data_channel_is_entertainment +
                                  3*online.news.popularity$data_channel_is_bus +
                                  4*online.news.popularity$data_channel_is_socmed +
                                  5*online.news.popularity$data_channel_is_tech +
                                  6*online.news.popularity$data_channel_is_world

online.news.popularity <- online.news.popularity[,-c(1,2,36)]


data <- subset(online.news.popularity, n_tokens_content > 0)

data <- transform(data, num_hrefs = log(num_hrefs), num_self_hrefs = log(num_self_hrefs),
                  self_reference_avg_sharess = log(self_reference_avg_sharess),
                  shares = log(shares), n_tokens_content = log(n_tokens_content))

data[data == -Inf] = -2


data.nrm <- as.data.frame(apply(data, MARGIN = 2,  function(x) {
  y <- (x - mean(x))/sd(x)
  y
}))



#########################################################
### 1. K Means ###
#########################################################

km <- function(data, num_cl, maxIter) {
  current_min = +Inf
  for (i in 1:maxIter) {
    k_mean <- kmeans(data, num_cl)
    if (k_mean$tot.withinss < current_min) {
      best <- k_mean
      current_min <- k_mean$tot.withinss
    }
  }
  best
}

ind <- sample(1:nrow(data.nrm), 1000)

data <- data.nrm[ind, c(1:24,33,34)]
data <- data.nrm[ind, 25:32]



k_mean_4 <- km(data, 3, 20)
pca.std <- prcomp(data, center = FALSE, scale. = FALSE)
plot(pca.std$x[,1], pca.std$x[,2], col = k_mean_3$cluster, xlab = 'PCA 1', ylab = 'PCA 2', main = 'PCA: Z-score')


k_mean_4 <- km(data, 4, 20)
pca.std <- prcomp(data, center = FALSE, scale. = FALSE)
plot(pca.std$x[,1], pca.std$x[,2], col = k_mean_4$cluster, xlab = 'PCA 1', ylab = 'PCA 2', main = 'PCA: Z-score')


k_mean_7 <- km(data, 7, 20)
pca.std <- prcomp(data, center = FALSE, scale. = FALSE)
plot(pca.std$x[,1], pca.std$x[,2], col = k_mean_7$cluster, xlab = 'PCA 1', ylab = 'PCA 2', main = 'PCA: Z-score')


get_errors_for_list_of_k <- function(data, max_iter, k_range) {
  return (sapply(k_range,
                 function(k)
                    return(km(data, k, max_iter)$tot.withinss)
                 )
          )
}

plot(get_errors_for_list_of_k(data, 50, 1:20),
     main="Least squares errors",
     xlab="different k",
     ylab="within-cluster sum of squares")


##########################
### 2. NN MST          ###
##########################




