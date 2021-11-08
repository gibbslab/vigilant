#!/bin/bash

#
# Example create_samplesheet.sh 2colfile prefix
# 2colfile:file holding "sampleid \t barcode"
# prefix: a unique name given to this sample sheet
#


#Import common library
tp=$(dirname ${0})
source $tp/vigilant.env
source ${VIGILANTHOME}/lib/fp.sh

#If not prefix given use timestamp
if [ -z "${2}" ];then
  
  saythis "Prefix not provided. Using timestamp for output samplesheet." "warn"
  sampleSheet=$(rightnow)".samplesheet.csv"

else
  
  sampleSheet="${2}.samplesheet.csv"

fi

#create samplesheet
echo "sample,barcode" > $sampleSheet

while read line;do

  #Some entries are not valid. Barcode has to be numeric
  	#read SampleID and Barcode
 sampleid=$(echo ${line} | awk '{print $1}')
 barcode=$(echo ${line} | awk '{print $2}')
 
 #If barcode or Sample ID are NOT empty
  if [ -n "${barcode}" ];then

 	 printf "${sampleid},${barcode}\n" >> $sampleSheet
  fi


done < ${1}
