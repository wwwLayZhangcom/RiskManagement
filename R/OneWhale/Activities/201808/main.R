library(scorecard)
library(openxlsx)
library(dummies)

model <- read.xlsx(xlsxFile = "../data/model.xlsx")


m <- read.table("clipboard",header = T,sep = '\t')

# 异常值处理
# 查看招聘大于10的行
tail(sort(model$招聘人数处理),100)
length(which(model$招聘人数处理 > 10))
# 剔除招聘大于10的行
df <- model[-which(model$招聘人数处理 > 10),]


# 哑变量处理
df <- cbind(df,as.data.frame(dummy(df$公司性质重编码)))
# 删除原变量 & 哑变量中的一个
df <- df[,-c(6,42)]


# 构建评分卡模型

# 1.处理缺失变量
df_nona <- var_filter(dt = df,
                      y = "Y")
df_nona <- df_nona[,2:length(df_nona)]

# 2.拆分训练集和测试集
df_spilt <- split_df(dt = df_nona,
                     y = "Y",
                     ratio = 0.8)
train <- df_spilt$train
test <- df_spilt$test

# 3.WOE转换
bins <- woebin(dt = m,
               y = "Y",x = "VAR08")
woebin_plot(bins)

# 4.将测试集和训练集进行分箱
train_woe = woebin_ply(train, bins)
test_woe = woebin_ply(test, bins)

# 5.通过广义线性模型函数构建逻辑回归模型
m1 = glm( Y ~ ., family = binomial(), data = train_woe)
summary(m1)

# 6.模型指标
m_step = step(m1, direction="both", trace = FALSE)
m2 = eval(m_step$call)
summary(m2)

train_pred = predict(m2, train_woe, type='response')
test_pred = predict(m2, test_woe, type='response')

train_perf = perf_eva(train$Y, train_pred, title = "train")
test_perf = perf_eva(test$Y, test_pred, title = "test")

# 7.分值
card = scorecard(bins, m2)

train_score = scorecard_ply(train, card, print_step=0)
test_score = scorecard_ply(test, card, print_step=0)

# 8.查看IV
iv(df_nona, y = "Y")

##############################
#variable info_value
#1: 工作经验重编码 0.98894514
#2: 学历要求重编码 0.59655439
#3:           算法 0.35819548
#4:       岗位分类 0.27272865
#6:         office 0.23292005
#7:         python 0.20226434
#8:       数据挖掘 0.17724367
#9:          excel 0.17505888
#10:           建模 0.13234947
#11:              r 0.12459196
#12:           风控 0.11258778
#13:       风险管理 0.07917727
#14:           报表 0.05923510
#15:           本科 0.05423588
#16: 公司规模重编码 0.03911103
#17:            df3 0.02552586
#18:           spss 0.02494755
#19:            sql 0.02474288
#20:            df0 0.02357368
#21:           数学 0.02197557
##############################




