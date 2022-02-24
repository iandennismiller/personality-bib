all:
	@echo OK

requirements:
	# R -f R/requirements.R
	pip install -r python/requirements.txt

pybliometrics-config:
	python -c 'import pybliometrics; pybliometrics.pybliometrics.utils.create_config()'

notebook:
	jupyter notebook

graph-90s:
	python3 ./python/graph-runner.py 90s

graph-all-time-not-personality:
	python3 ./python/graph-runner.py all-time --path "data/graph-not-personality"

graph-per-decade-not-personality:
	python3 ./python/graph-runner.py per-decade --path "data/graph-not-personality"

.PHONY: requirements pybliometrics-config notebook
