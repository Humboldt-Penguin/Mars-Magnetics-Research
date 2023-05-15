#!/bin/bash

if [[ -d "data/" ]]; then
	yn="null"
	while [[ ! "$yn" == "y" ]] || [[ ! "$yn" == "n" ]]; do
		read -p 'Data folder already exists. Would you like to delete and redownload? [y/n] ' yn

		if [[ "$yn" == "n" ]]; then
			exit 0
		fi
		if [[ "$yn" == "y" ]]; then
			rm -rf "data/"
			break
		fi

	done
fi

#echo "finish"


#download all scripts


# remove an existing data folder
  5 rm -rf
  6
  7
  8 # download from https://drive.google.com/file/d/1ZToKE6OxZFlObjTOecPILngcQVnaqFJv/view?usp=sharing
  9 wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1ZToKE6OxZFlObjTOecPILngcQVnaqFJv' -O 'da    ta.zip'
 10
 11 # unzip
 12 unzip 'data.zip'
 13
 14 # remove zipfile
 15 rm 'data.zip' 
