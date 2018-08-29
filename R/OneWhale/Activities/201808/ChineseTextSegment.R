# reset workplace
rm(list = ls())

library(jiebaR)
library(openxlsx)

data <- read.xlsx(xlsxFile = "../data/数据分析.xlsx",
                  sheet = "数据处理结果")

data_requirement <- data$岗位职责

wk <- worker()
segment <- wk[data_requirement]
cipin <- as.data.frame(freq(segment))




##################################################

feature <- c(
   '数据挖掘',
   '风控',
   '统计',
   '本科',
   '算法',
   '数据库',
   '建模',
   '数学',
   'sql',
   '统计学',
   'r',
   'python',
   '报表',
   '数据处理',
   'sas',
   '风险管理',
   'excel',
   '数据仓库',
   'spss',
   'oracle',
   'mysql',
   'office',
   'etl'
)


#write.csv(cipin,"cipin.csv")
