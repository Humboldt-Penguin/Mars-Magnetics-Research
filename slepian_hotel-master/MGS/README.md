Some changes are necessary to make [the original loadpds.m](https://github.com/csdms-contrib/slepian_hotel/blob/master/MGS/loadpds.m) work. At minimum, you must:

* change line 53 from `if ~strcmp(cmdline{3},'-mars')` to `if ~strcmp(cmdline{4},'-mars')`
* change line 65 from `if ~strcmp(cmdline{6},'-pc')` to `if ~strcmp(cmdline{7},'-pc')`
* change line 79 from `for i=5:407%i=1:407` to `for i=1:500`
  * this is optional and arbitrary, but it prevents some annoying indexing errors and the loss in data is negligible (~0.01%).

The loadpds.m in this repository has those edits and comments explaining how stuff works.
