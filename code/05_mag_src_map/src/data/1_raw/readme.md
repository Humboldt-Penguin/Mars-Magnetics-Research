====================================================================
PREAMBLE
====================================================================

Purpose of this file:
	- Describe all data product (description, source, modifications, interfaces, 



====================================================================
TABLE OF CONTENTS
====================================================================

01. `GRS.zip`
	- NASA GRS chemical concentration maps.

02. `crustal_heat_flow.zip`
	- "" provided by Ojha.

03. `craters.zip`
	- Crater database from Robbins.

04. `crustal_thickness.zip`
	- "" from Wieczorek script.

05. `magnetization_depth.zip`
	- "" from Gong & Wieczorek source depths paper.

06. `maven_mag_raw.zip`
	- NASA MAVEN magnetometer data.




====================================================================
====================================================================
====================================================================
01. 
	TITLE: GRS
	LINK: https://drive.google.com/drive/folders/1Ozi1LS0wDN86vodTWJ3_326JoS5Bc0eG?usp=sharing
====================================================================


DESCRIPTION:
	GRS Elemental Concentration Data from 2001 Mars Odyssey. 



SOURCE:
	Prof. Ojha gave me this file on 2022-10-26 with the following description:

		> There are four different files here. For start, you can use any of them. 
		> They have a dimension of 180 in Y dir (latitude) and 360 in X dir (longitude). 
		> The areas that are younger than Noachian (~3.8 Ga) in age have been masked and should have a value of NaN. 

	The source is this Dropbox folder: https://www.dropbox.com/sh/od2f9n06zioc7rj/AABbv8qodzNTG2lWmfOV08wua?dl=0



INTERFACE:
	- GRS.py


USEFUL LINKS:
	- Background literature:
		- [Amagmatic hydrothermal systems on Mars from radiogenic heat | Nature Communications](https://www.nature.com/articles/s41467-021-21762-8#Sec13)
		- [Depletion of Heat Producing Elements in the Martian Mantle - Ojha - 2019 - Geophysical Research Letters - Wiley Online Library](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2019GL085234)
		- [Groundwater production from geothermal heating on early Mars and implication for early martian habitability | Science Advances](https://www.science.org/doi/10.1126/sciadv.abb1669)
		- [Martian surface heat production and crustal heat flow from Mars Odyssey Gamma‐Ray spectrometry - Hahn - 2011 - Geophysical Research Letters - Wiley Online Library](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2011GL047435)


CHANGE LOG / LINKS:
	- 230430
		- added data+interface delineation
		- moved interface class to data folder
		- 



CONTENTS:
	GRS/
	├── README.txt
	├── data/
	│   ├── smoothed/
	│   │   ├── cl_sr_5x5.lbl
	│   │   ├── cl_sr_5x5.tab
	│   │   ├── fe_sr_5x5.lbl
	│   │   ├── fe_sr_5x5.tab
	│   │   ├── h2o_sr_5x5.lbl
	│   │   ├── h2o_sr_5x5.tab
	│   │   ├── kvsth_sr_5x5.lbl
	│   │   ├── kvsth_sr_5x5.tab
	│   │   ├── k_sr_5x5.lbl
	│   │   ├── k_sr_5x5.tab
	│   │   ├── si_sr_5x5.lbl
	│   │   ├── si_sr_5x5.tab
	│   │   ├── th_sr_5x5.lbl
	│   │   └── th_sr_5x5.tab
	│   └── unsmoothed/
	│       ├── 10x10/
	│       │   ├── cl_10x10.lbl
	│       │   ├── cl_10x10.tab
	│       │   ├── fe_10x10.lbl
	│       │   ├── fe_10x10.tab
	│       │   ├── h2o_10x10.lbl
	│       │   ├── h2o_10x10.tab
	│       │   ├── k_10x10.lbl
	│       │   ├── k_10x10.tab
	│       │   ├── si_10x10.lbl
	│       │   ├── si_10x10.tab
	│       │   ├── th_10x10.lbl
	│       │   └── th_10x10.tab
	│       ├── 2x2/
	│       │   ├── fe_2x2.lbl
	│       │   ├── fe_2x2.tab
	│       │   ├── h2o_2x2.lbl
	│       │   ├── h2o_2x2.tab
	│       │   ├── k_2x2.lbl
	│       │   ├── k_2x2.tab
	│       │   ├── si_2x2.lbl
	│       │   ├── si_2x2.tab
	│       │   ├── th_2x2.lbl
	│       │   └── th_2x2.tab
	│       └── 5x5/
	│           ├── cl_5x5.lbl
	│           ├── cl_5x5.tab
	│           ├── fe_5x5.lbl
	│           ├── fe_5x5.tab
	│           ├── h2o_5x5.lbl
	│           ├── h2o_5x5.tab
	│           ├── k_5x5.lbl
	│           ├── k_5x5.tab
	│           ├── si_5x5.lbl
	│           ├── si_5x5.tab
	│           ├── th_5x5.lbl
	│           └── th_5x5.tab
	└── interface/
		├── GRS.html
		├── GRS.py
		└── __init__.py


[generated with https://tree.nathanfriend.io/]




====================================================================
02. 
	TITLE: crustal_heat_flow
	LINK: https://drive.google.com/drive/folders/1shBdEw74bA3Wz4B0TC9gNKcRXoyJcCbO?usp=sharing
====================================================================


DESCRIPTION:
	Crustal heat production estimates from GRS data + varying values for mantle heat production.



SOURCE:
	Mars Orbital Data Exlorer: https://ode.rsl.wustl.edu/mars/index.aspx
		- In step 1, choose "2001 Mars Odyssey Orbiter > Derived Data > Element Concentrations Maps (ELEMTS)"
		- In step 4, choose "Maintain original PDS archive directory structure"



MODIFICATIONS TO ORIGIAL SOURCE:
	- 	



INTERFACE:
	- `GRS.py`


USEFUL LINKS:
	- Descriptions of data
		- Explore data repository: https://pds-geosciences.wustl.edu/missions/odyssey/grs_elements.html
		- Data explanation/citation: https://ode.rsl.wustl.edu/mars/pagehelp/Content/Missions_Instruments/Mars_Odyssey/GRS/IDR/ELEMTS.htm
		- GRS instrument suite (+landing page): https://pds-geosciences.wustl.edu/missions/odyssey/grs.html
	- Visualize data
		- Pics in browser: https://pds-geosciences.wustl.edu/ody/ody-m-grs-5-elements-v1/odgm_xxxx/browse/browse.htm



CHANGE LOG / LINKS:
	-



CONTENTS:
	GRS/
	├── README.txt
	├── data/
	│   ├── smoothed/
	│   │   ├── cl_sr_5x5.lbl
	│   │   ├── cl_sr_5x5.tab
	│   │   ├── fe_sr_5x5.lbl
	│   │   ├── fe_sr_5x5.tab
	│   │   ├── h2o_sr_5x5.lbl
	│   │   ├── h2o_sr_5x5.tab
	│   │   ├── kvsth_sr_5x5.lbl
	│   │   ├── kvsth_sr_5x5.tab
	│   │   ├── k_sr_5x5.lbl
	│   │   ├── k_sr_5x5.tab
	│   │   ├── si_sr_5x5.lbl
	│   │   ├── si_sr_5x5.tab
	│   │   ├── th_sr_5x5.lbl
	│   │   └── th_sr_5x5.tab
	│   └── unsmoothed/
	│       ├── 10x10/
	│       │   ├── cl_10x10.lbl
	│       │   ├── cl_10x10.tab
	│       │   ├── fe_10x10.lbl
	│       │   ├── fe_10x10.tab
	│       │   ├── h2o_10x10.lbl
	│       │   ├── h2o_10x10.tab
	│       │   ├── k_10x10.lbl
	│       │   ├── k_10x10.tab
	│       │   ├── si_10x10.lbl
	│       │   ├── si_10x10.tab
	│       │   ├── th_10x10.lbl
	│       │   └── th_10x10.tab
	│       ├── 2x2/
	│       │   ├── fe_2x2.lbl
	│       │   ├── fe_2x2.tab
	│       │   ├── h2o_2x2.lbl
	│       │   ├── h2o_2x2.tab
	│       │   ├── k_2x2.lbl
	│       │   ├── k_2x2.tab
	│       │   ├── si_2x2.lbl
	│       │   ├── si_2x2.tab
	│       │   ├── th_2x2.lbl
	│       │   └── th_2x2.tab
	│       └── 5x5/
	│           ├── cl_5x5.lbl
	│           ├── cl_5x5.tab
	│           ├── fe_5x5.lbl
	│           ├── fe_5x5.tab
	│           ├── h2o_5x5.lbl
	│           ├── h2o_5x5.tab
	│           ├── k_5x5.lbl
	│           ├── k_5x5.tab
	│           ├── si_5x5.lbl
	│           ├── si_5x5.tab
	│           ├── th_5x5.lbl
	│           └── th_5x5.tab
	└── interface/
		├── GRS.html
		├── GRS.py
		└── __init__.py


[generated with https://tree.nathanfriend.io/]



