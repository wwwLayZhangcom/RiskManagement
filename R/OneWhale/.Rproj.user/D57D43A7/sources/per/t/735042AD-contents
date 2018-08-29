library(logiBin)

# 查看特征的IV值
iv_table <- function(df,
                     y,
                     exclude,
                     save_iv = NULL,
                     save_woe = NULL) {
  # 1.排除无需计算IV的特征
  cols <- colnames(df)
  cols <- cols[!names(df) %in% exclude]
  
  # 2.循环计算每个特征IV值,判断是否保存WOE明细
  vars <- NULL
  iv <- NULL
  err <- NULL
  result <- as.data.frame(NULL)
  for (i in cols) {
    bins <- getBins(df, y, i)
    iv_ <- bins$varSummary['iv']
    
    # iv table
    if (length(iv_) > 0) {
      vars <- append(i, vars, after = length(vars) + 1)
      result[length(vars), 1] <- i
      result[length(vars), 2] <- iv_[1, 1]
      
      # woe
      if (length(save_woe) > 0) {
        woe <- as.data.frame(bins$bin)
        write.csv(woe, file = save_woe, append = T)
      }
      
    } else {
      print(paste(i, "发生错误!", sep = " "))
      err <- append(i, err, after = length(err) + 1)
    }
  }
  
  # 3.判断是否保存IV结果表到本地
  if (length(save_iv) > 0) {
    write.csv(result, save_iv)
  }
  
  print(err)
  return(result)
}

iv_table(
  metadata,
  "ovr30",
  c("customer_id", "ovr30", "sample_flag", "X"),
  save_iv = "iv.csv",
  save_woe = "woe.csv"
)