Some changes are necessary to make [the original loadpds.m](https://github.com/csdms-contrib/slepian_hotel/blob/master/MGS/loadpds.m) work. At minimum, you must:

* Change line 53 from `if ~strcmp(cmdline{3},'-mars')` to `if ~strcmp(cmdline{4},'-mars')`.
* Change line 65 from `if ~strcmp(cmdline{6},'-pc')` to `if ~strcmp(cmdline{7},'-pc')`.
* Change line 79 from `for i=5:407%i=1:407` to skip further in. I find the first instance of a year, but you can easily just go 500 lines in.

The loadpds.m in this repository has those edits and comments explaining how stuff works.
