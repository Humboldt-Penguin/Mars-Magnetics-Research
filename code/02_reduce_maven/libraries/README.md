### Libraries

* [Slepian Alpha](https://github.com/csdms-contrib/slepian_alpha)
	* Spherical harmonics and Slepian functions as developed by Simons, Dahlen & Wieczorek.
* [Slepian Hotel](https://github.com/csdms-contrib/slepian_hotel)
	* Inversions using gradient vector Slepian functions (GVSF) as developed by Plattner & Simons.
* [Slepian Golf](https://github.com/csdms-contrib/slepian_golf)
	* Vector Slepian functions as developed by Plattner & Simons.

---
### Corrections

Some changes are necessary to make [the original loadpds.m](https://github.com/csdms-contrib/slepian_hotel/blob/master/MGS/loadpds.m) work. At minimum, you must:

* Change line 53 from `if ~strcmp(cmdline{3},'-mars')` to `if ~strcmp(cmdline{4},'-mars')`.
* Change line 65 from `if ~strcmp(cmdline{6},'-pc')` to `if ~strcmp(cmdline{7},'-pc')`.
* Change line 79 from `for i=5:407%i=1:407` to `for i=5:500`. 
	* Alternatively, you can try to look for the first line of data.

The loadpds.m in this repository has those edits and comments explaining how stuff works.
