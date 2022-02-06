Some changes are necessary to make [loadpds.m](https://github.com/csdms-contrib/slepian_hotel/blob/master/MGS/loadpds.m) work. The file in this repository has the following changes:

* change line 53 from `if ~strcmp(cmdline{3},'-mars')` to `if ~strcmp(cmdline{4},'-mars')`
* change line 65 from `if ~strcmp(cmdline{6},'-pc')` to `if ~strcmp(cmdline{7},'-pc')`
* change line 79 from `for i=5:407%i=1:407` to `for i=1:150`
 
