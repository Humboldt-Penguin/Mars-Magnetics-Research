## Install

Replicating one of these environments requires a [mamba](https://mamba.readthedocs.io/en/latest/installation.html#fresh-install) (recommended for better speed and less bloat) or conda installation. All instances of `conda`/`mamba` are interchangeable.

1. Navigate command line to `src/build/` directory. Run `conda env create --file [name of YAML file]`.

	- Note: If you would like to change the default environment name (e.g. "mars4"), add the `-n [envname]` flag as such: `conda env create -n [envname] --file [name of YAML file]`

2. Navigate command line to `src/lib/` directory. Run `pip install -e .`

	- Note: The `-e` flag means changes to lib modules will go into effect immediately without needing to reinstall with pip.

---	
## Delete	
	
To delete an environment run `conda remove -n [envname] --all`. This is recommended when usage is complete, as environments can take 5+ GB storage.


---
## Package Summaries

This explains the purpose/context for packages. Custon environments can be created manually with `conda create -n [envname] [package 1] [package 2] [package 3] ...`.

- Basic requirements:
	- `numpy`, `matplotlib`, `scipy` -- Ubiquitous data science libraries.
	- `gdown` -- Downloading datasets from Google Drive.
	- `pandas` -- Managing crater database (see lib/zerisk/Craters.py).
- Notebooks (choose one):
	- `jupyterlab` -- Notebooks in browser.
	- `jupyter` -- Notebooks in VSCode.
- 3D Animations:
	- `vpython` -- Strong + easy 3D graphics/animation library, see examples [here](https://github.com/Humboldt-Penguin/Physics_Simulations). Warning: not compatible with VSCode notebooks; however `.py` files work fine to my knowledge.
	- `jupyterlab-vpython` -- Required if using vpython in jupyterlab notebooks.
- Misc:
	- `cdflib` -- Interfacing with MAVEN SWIA `.cdf` data.