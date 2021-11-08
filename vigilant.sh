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

#Although this file MUST be in the same path of vigilant.sh here we check it is so.
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
   \?) echo "Option not existent: ${OPTARG}" 1>&2;;
    :) echo "Missing value: ${OPTARG} requires an argument " 1>&2;;
  esac
done


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
${VIGILANTHOME}/create_ins_report.sh -j nextclade_output/nextclade.json -d ${outDir} -v ${voci}



#--------------------------------------------------------------------
#
# Let's get Organized
#
#--------------------------------------------------------------------
mv nextclade_output ${outDir}


