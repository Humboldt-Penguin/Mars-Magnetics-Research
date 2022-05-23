Email: [zain.erin.kamal@rutgers.edu](mailto:zain.erin.kamal@rutgers.edu) and/or [zain.erin.kamal@gmail.com](mailto:zain.erin.kamal@gmail.com), I compulsively check both.

I'd like to express my gratitude to my primary supervisor, Lujendra Ojha, who guided me throughout this project. I'd also like to thank the NASA New Jersey Space Grant Consortium for awarding me a Fellowship Grant to continue my work in Summer 2022.

# High-Resolution Analysis of Martian Crustal Magnetization from the MAVEN Satellite in Relation to Hydrated Minerals

## Abstract (Incomplete)

We're analyzing the high-resolution crustal magnetic field data from the Mars Atmosphere and Volatile Evolution (MAVEN) spacecraft to help better understand the geological history of Mars. The rocks of Mars were magnetized by an Earth-like dynamo more than 4 billion years ago. However, the geological conditions that enabled magnetization remain enigmatic. A plethora of evidence suggests the presence of substantial volumes of water in the Martian crust 4-billion years ago. Our hypothesis is that the chemical reactions associated with the interaction of voluminous water with the deep crust of Mars at elevated temperatures may have been a key process that magnetized the crust. If true, the deep rock-water reaction would not only have been notable for its role in the magnetic history of Mars but also for the biosphere and the contribution of key greenhouse gases to the atmosphere.

## 1. Background (Martian Crustal Magnetization)

There are two main ways in which we predict the crust of Mars was magnetized. 

The first starts with [dynamo theory](https://en.wikipedia.org/wiki/Dynamo_theory), which explains how heat flow from the inner core of a planet creates convection currents of fluid metal in the outer core, which takes on a roll-like shape due to the Coriolis force, resulting in circulating electric currents that generate a plant/star's magnetosphere (this is the same magnetosphere that shields planets from solar energetic particles). As a result, when natural rocks are heated past their Curie temperature, a planet's internal magnetic field can induce a permanent magnetic moment as the rock cools down. We observe this phenomena on Earth through lodestones, and predict a similar process contributes to the magnetization of Mars's crust. 

The second way is the concept of [chemical remanent magnetization (CRM)](https://doi.org/10.1016/B978-0-444-41084-9.50013-8), which is more complicated, but basically entails that water-rock interactions can magnetize rocks at temperatures below their Curie point. 

Our research seeks to better understand and possibly quantify the extent to which each of the above methods contributed to the magnetization of Mars's crust.


## 2. Methodology

Pre-existing spherical harmonic models of Martian crustal magnetic fields suggest that regions with evidence of hydrothermal activity have higher magnetization than average. However, the resolution of these models isn't high enough to fully understand what's going on. I'll be using the high-resolution magnetic field tracks from the MAVEN spacecraft (2014-2021) to assess the relationship between crustal magnetic fields and geolgoical features of interest. 

We will construct high-resolution, local spherical harmonic models around geological features of interest, and then do an inversion to pinpoint the depth of the source of the magnetic field. If the source is in the top-layer of the crust (<10 km), we can attribute the magnetization to CRM (water-rock interactions) since water can only penetrate so far due to the permeability of the crust. If the source is deeper in the crust (>10km, <100km), we can attribute the magnetization to dynamo theory.

### Libraries

* [Slepian Hotel](https://github.com/csdms-contrib/slepian_hotel): inversions using gradient vector Slepian functions
* [Slepian Alpha](https://github.com/csdms-contrib/slepian_alpha)
* [Slepian Golf](https://github.com/csdms-contrib/slepian_golf)
