#!/bin/sh
#echo 'example,tag1=a,tag2=b i=42i,j=43i,k=44i'
#curl -i -XPOST 'http://localhost:8086/write?db=iotDb' --data-binary 'cpu_load_shorttest,host=server10,region=india-west value=0.64 1434055562000000000'

#curl -i -XPOST 'http://localhost:8086/write?db=iotDb' --data-binary @cpu_data.txt

file="/tmp/test_crop1.csv"

#get all the filed names
#declare -a fieldnames=("MinTemp" "MaxTemp" "NitrogenPPM" "RainfallMM" "Humidity" "LightTrapBPH" "CropSpacing" "MultipleRiceCropping" "RiceVariety1" "RiceVariety2" "RiceVariety3" "Pesticide1" "Pesticide2")

#echo "${fieldnames[*]}"
 
featureName="InfestationF1 "
awk 'NR>1' "$file" | while IFS= read -r line
 do  
  #separate the fields  
fieldValues=$(echo $line | awk -F, '{print "MinTemp="$1",MaxTemp="$2",NitrogenPPM="$3",RainfallMM="$4",Humidity="$5",LightTrapBPH="$6",CropSpacing="$7",MultipleRiceCropping="$8",RiceVariety1="$9",RiceVariety2="$10",RiceVariety3="$11",Pesticide1="$12",Pesticide2="$13}')
  timestamp=$(date +%s) 

  ns=1000000000
  nano=`expr $timestamp \\* $ns`  
  emptyspace=' '
  text=$featureName$fieldValues$emptyspace$nano
  textnew=$(echo $text | sed 's/\\r//g')
  echo $textnew | curl -d @- 'http://localhost:8086/write?db=iotDb'
  #curl -i -XPOST 'http://localhost:8086/write?db=iotDb' --data-binary '$textnew'
  sleep 10
  
done 

SELECT Humidity FROM "InfestationF2" WHERE $timeFilter GROUP BY time($__interval) fill(null)