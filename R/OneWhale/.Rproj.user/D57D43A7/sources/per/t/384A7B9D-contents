library(logiBin)

# 查看特征的IV值
iv_table <- function(df,y,exclude){
  
  # 1.排除无需计算IV的特征
  cols <- colnames(df)
  cols <- cols[!names(df) %in% exclude]
  
  # 2.循环计算每个特征IV值
  vars <- list()
  iv <- list()
  for (i in cols) {
    bins <- getBins(df,y,i)
    iv_ <- bins$varSummary['iv']
    append(i,vars,after = length(vars))
    append(iv_[1,1],iv,after = length(iv))
    print(i)
    print(iv_[1,1])
  }
  print(vars)
  print(iv)
}

iv_table(metadata,"ovr30",c("customer_id","ovr30","sample_flag","X"))


cols <- colnames(metadata)
exclude <- c("customer_id","ovr30","sample_flag","X")
cols <- cols[!names(metadata) %in% exclude]

for (i in cols) {
  library(logiBin)
  bins <- getBins(df,y,i)
  append(i,vars)
  append(bins$varSummary['iv'],iv)
}
