library(influxdbr)
library(xts)
library(mlbench)
require(caret)

#Read train file
trainFile = read.csv("Data/BPHTrain.csv")

#Create the prediction model using Random Forest algorithm
control = trainControl(method="repeatedcv", number=10, repeats=3)
set.seed(7)
cforest_trained <- train(Infestation~., data=trainFile, method="cforest", trControl=control)
imp <- varImp(cforest_trained, scale = FALSE)

#Create the prediction model using Stochaistic graient boost model
gbm_trained <- train(Infestation~., data=trainFile, method="gbm", trControl=control)
#Get the variable importance
imp <- varImp(gbm_trained, scale = FALSE)


#open connection to influxdb
dbcon =influxdbr::influx_connection()

while(1)
{
#read incoming sensor data from database every 15 seconds( ideally data from sensors will collected every day but here scaled down to 15 seconds for testing)
result <- influxdbr::influx_select(con = dbcon, db = "iotDb",
                                   field_keys = "*", measurement = "InfestationF1",
                                   limit = 1,
                                   order_desc = TRUE,
                                   return_xts = FALSE)

  
resultDf= as.data.frame(result)
resultVector = as.vector(t(resultDf))
timestamp = as.double(resultVector[5,])

#predict the infestation risk
predictResult = predict(gbm_trained, resultDf, type = "prob")

#write the prediction back to database
#finalOutput <- as.data.frame(cbind(predictResult, timestamp))
xtsObj <- xts(predictResult$yes, order.by=as.POSIXct(timestamp,origin="1970-01-01"))
#give column names
names(xtsObj) <- "risk"

influxdbr::influx_write(con = dbcon, 
                        db = "iotDb",
                        x = xtsObj, 
                        measurement = "infestationP4",
                        precision = c("ns")
                        )

#wait for sometime
Sys.sleep(15)
}
