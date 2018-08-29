rm(list = ls())
source("Utils/binning.R")
source("Utils/missing_value.R")
source("Utils/outlier.R")
source("Utils/woe_iv.R")

library(scorecard)

# step.1  获取数据

if (file.exists(paste(getwd(), "/scorecard/v1/data/android_v4.RData", sep = ""))) {
  load(file = "Scorecard/v1/data/android_v4.RData")
  metadata <- data
} else {
  data <- read.csv(file = "Scorecard/v1/data/android_v4.csv",
                   header = T,
                   encoding = "utf-8")
  save(data, file = "Scorecard/v1/data/android_v4.RData")
}

# step.2  分组查看字段
