#!/bin/bash
#
# BIOINFORMATICS AND SYSTEMS BIOLOGY LABORATORY
#  Instituto de Genetica - Universidad Nacional de Colombia
#
# This script is a wrapper for a series of routines that
# allow to run nf-core/viral recon plus inhouse scripts for
# the Genomic Surveillance of human Sars-CoV2 in Colombia.
#
# INPUT
# -i Path to fastq_pass folder
# -s Path to sequencing summary
# -q Path to sample sheet
# -o Unique name for output dir.
# -v Path to a file containig a description of variants of interest.#
# -m Path to metadatafile

#--------------------------------------------------------------------
#
# GET THE VIGILANTHOME environmental variable
#
#--------------------------------------------------------------------
tp=$(dirname ${0})
source $tp/vigilant.env

#Import common library
source ${VIGILANTHOME}/lib/fp.sh


#--------------------------------------------------------------------
#
# GET SCRIPT ARGUMENTS
#
#--------------------------------------------------------------------
while getopts i:s:q:o:v:m: flag
do
  case "${flag}" in
    i) fastqDir=${OPTARG};;
    s) sequencingSummary=${OPTARG};;
    q) sampleSheet=${OPTARG};;
    o) outDir=${OPTARG};;
    v) voci=${OPTARG};;
    m) metaData=${OPTARG};;
   \?) echo "Option not existent: ${OPTARG}" 1>&2;;
    :) echo "Missing value: ${OPTARG} requires an argument " 1>&2;;
  esac
done


# Before running ANYTHING we have to make sure that metadata File is present
# This file is necessary to create the report and as for this version this file has a
# specific number of fields (17) and  we will take just some of them. That will be perfomed
# by create_ins_report script.
if [ -z ${metaData} ] 
  then
    saythis "Meta data file is needed. Imposible to run. Quitting."  "error"
    exit 1
fi


checkFile=$(fileexists ${metaData})
if [ $checkFile -eq 0 ];then
  saythis "Error: File ${metaData} not found. Quitting." "error"
  exit 1
fi

#--------------------------------------------------------------------
#
# RUN VIRALRECON
#
#--------------------------------------------------------------------


${VIGILANTHOME}/run_viralrecon.sh \
 -i ${fastqDir} \
 -s ${sequencingSummary} \
 -q ${sampleSheet} \
 -o ${outDir}

#--------------------------------------------------------------------
#
# RUN NEXTCLADE 
#
#--------------------------------------------------------------------

# Before running this, check that Medaka directory was created.
# Sometimes it just runs pycoqc but due to bad quality it is not able to run
# Medaka's downstream analysis. 

medakaDir=$(echo "${outDir}/medaka")
checkDir=$(direxists ${medakaDir})
if [ $checkDir -eq 0 ]; then
	saythis "ERROR: Unable to find directory: \"${medakaDir}\". Maybe wrong path?." "error"
	exit 1
fi

${VIGILANTHOME}/run_offline_nextclade.sh ${outDir} 


#--------------------------------------------------------------------
#
# CREATE REPORT
#
#--------------------------------------------------------------------
# Is important to keep the -v option at the end. If not and it is empty it 
# will take the next argument as if it were the argument value.
${VIGILANTHOME}/create_ins_report.sh -j nextclade_output/nextclade.json -d ${outDir} -v ${voci} -m ${metaData}



#--------------------------------------------------------------------
#
# Let's get Organized
#
#--------------------------------------------------------------------
mv nextclade_output ${outDir}


