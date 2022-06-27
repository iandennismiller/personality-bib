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

graph-all-time:
	python3 ./python/graph-runner.py all-time --path "data/graph-all-time"

graph-per-decade:
	python3 ./python/graph-runner.py per-decade --path "data/graph-all-time"

.PHONY: requirements pybliometrics-config notebook
