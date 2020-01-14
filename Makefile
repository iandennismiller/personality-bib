all:
	@echo OK

requirements:
	R -f R/requirements.R

pybliometrics-config:
	python -c 'import pybliometrics; pybliometrics.pybliometrics.utils.create_config()'

notebook:
	jupyter notebook

.PHONY: requirements pybliometrics-config notebook
