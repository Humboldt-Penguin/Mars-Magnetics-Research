### this script downloads and unzips data for `04_curie_depths` scripts -- works for linux/mac. just do it manually for windows.

# download from https://drive.google.com/file/d/1ZToKE6OxZFlObjTOecPILngcQVnaqFJv/view?usp=sharing
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1ZToKE6OxZFlObjTOecPILngcQVnaqFJv' -O 'data.zip'

# unzip
unzip 'data.zip'

# remove zipfile
rm 'data.zip'

# use these next two lines if running in an already existing data folder
# mv data/* . 
# rmdir data/