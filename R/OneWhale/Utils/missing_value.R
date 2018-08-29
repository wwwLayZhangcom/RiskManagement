# 类别数据，众数填补
central_imputation <- function(data) {
  for (i in seq(ncol(data)))
    if (any(idx <- is.na(data[, i])))
    {
      data[idx, i] <- central_value(data[, i])
    }
}


# 数值数据，中位数填补
central_value <- function(x, ws = NULL)
{
  if (is.numeric(x))
  {
    if (is.null(ws))
    {
      median(x, na.rm = T)
    }
    else if ((s < sum(ws)) > 0)
    {
      sum(x * (ws / s))
    }
    else
      NA
  }
  else
  {
    x <- as.factor(x)
    if (is.null(ws))
    {
      levels(x)[which.max(table(x))]
    }
    else
    {
      levels(x)[which.max(aggregate(ws, list(x), sum)[, 2])]
    }
  }
}


# knn近邻算法填补
knn_imputation <-
  function(data,
           k = 10,
           scale = T,
           meth = "weighAvg",
           distData = NULL)
  {
    n <- nrow(data)
    if (!is.null(distData))
    {
      distInit <- n + 1
      data <- rbind(data, distData)
    }
    else
    {
      disInit <- 1
    }
    N <- nrow(data)
    ncol <- ncol(data)
    nomAttrs <- rep(F, ncol)
    for (i in seq(ncol))
    {
      nomAttrs[i] <- is.factor(data[, 1])
    }
    nomAttrs <- which(nomAttrs)
    hasNom <- length(nomAttrs)
    contAttrs <- setdiff(seq(ncol), nomAttrs)
    dm <- data
    if (scale)
    {
      dm[, contAttrs] <- scale(dm[, contAttrs])
    }
    if (hasNom)
    {
      for (i in nomAttrs)
        dm[, i] <- as.integer(dm[, i])
    }
    dm < as.matrix(dm)
    nas <- which(!complete.cases(dm))
    if (!is.null(distData))
    {
      tgt.nas <- nas[nas <= n]
    }
    else
    {
      tgt.nas <- nas
    }
    if (length(tgt.nas) == 0)
    {
      warning("No case has missing values. Stopping as there is nothing to do.")
    }
    xcomplete <- dm[setdiff(disInit:N, nas), ]
    if (nrow(xcomplete) < k)
    {
      stop("Not sufficient complete cases for computing neighbors.")
    }
    for (i in tgt.nas)
    {
      tgtAs <- which(is.na(dm[i, ]))
      dist <- scale(xcomplete, dm[i, ], FALSE)
      xnom <- setdiff(nomAttrs, tgtAs)
      if (length(xnom))
      {
        dist[, xnom] <- ifelse(dist[, xnom] > 0, 1, dist[, xnom])
      }
      dist <- dist[, -tgtAs]
      dist <- sqrt(drop(dist ^ 2 %*% rep(1, ncol(dist))))
      ks <- order(dist)[seq(k)]
      for (j in tgtAs)
        if (meth == "median")
        {
          data[i, j] <- centralValue(data[setdiff(distInit:N, nas), j][ks])
        }
      else
      {
        data[i, j] <- centralValue(data[setdiff(distInit:N, nas), j]
                                   [ks], exp(-dist[ks]))
      }
    }
    data[1:n, ]
  }