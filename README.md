Email: [z.kamal2021@gmail.com](mailto:z.kamal2021@gmail.com) or [zain.kamal@rutgers.edu](mailto:zain.kamal@rutgers.edu), I compulsively check both.

Many thanks to Professor Lujendra Ojha from Rutgers for his mentorship throughout this research project.

# Mars Magnetics Research (Ongoing)

## Background

There are two main ways in which we predict the crust of Mars was magnetized. 

The first starts with [dynamo theory](https://en.wikipedia.org/wiki/Dynamo_theory), which explains how heat flow from the inner core of a planet creates convection currents of fluid metal in the outer core, which takes on a roll-like shape due to the Coriolis force, resulting in circulating electric currents that generate a plant/star's magnetosphere (this is the same magnetosphere that shields planets from solar energetic particles). As a result, when natural rocks are heated past their Curie temperature, a planet's internal magnetic field can induce a permanent magnetic moment as the rock cools down. We observe this phenomena on Earth through lodestones, and predict a similar process contributes to the magnetization of Mars's crust. 

The second way is the concept of [chemical remanent magnetization (CRM)](https://doi.org/10.1016/B978-0-444-41084-9.50013-8), which is more complicated, but basically entails that water-rock interactions can magnetize rocks at temperatures below their Curie point. 

**Our research seeks to better understand and possibly quantify the extent to which each of the above methods contributed to the magnetization of Mars's crust.**

## Methodology

NASA's MAVEN satellite has a Fluxgate Magnetometer instrument that collected high resolution vector magnetic field track data from 2014-2021. Although there are already spherical harmonic models of the magnetic field of Mars's crust, the resolution is quite low because of interpolation and height variations in Maven's orbit. Still, the coarse spherical harmonic models suggest that areas that used to have lots of hydrothermal activity have higher magnetization than average. We will construct high-resolution, local spherical harmonic models in regions such as the Eridiania basin, and then do an inversion to pinpoint the depth of the source of the magnetic field. If the source is in the top-layer of the crust (<10 km), we can attribute the magnetization to CRM (water-rock interactions) since water can only penetrate so far due to the permeability of the crust. If the source is deeper in the crust (>10km, <100km), we can attribute the magnetization to dynamo theory.

### Libraries

* [Slepian Hotel](https://github.com/csdms-contrib/slepian_hotel): inversions using gradient vector Slepian functions
* [Slepian Alpha](https://github.com/csdms-contrib/slepian_alpha)
* [Slepian Golf](https://github.com/csdms-contrib/slepian_golf)
