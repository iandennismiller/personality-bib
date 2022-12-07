all:
	@echo OK

start:
	jupyter lab

requirements:
	# R -f R/requirements.R
	pip install -r src/requirements.txt
	pip install -e ./src

pybliometrics-config:
	python -c 'import pybliometrics; pybliometrics.pybliometrics.utils.create_config()'

graph-90s:
	python3 src/scripts/graph-runner.py 90s

graph-all-time:
	python3 src/scripts/graph-runner.py all-time --filename ./products/graphs/journals-all.graphml

graph-per-decade:
	python3 src/scripts/graph-runner.py per-decade --path ./products/graphs

.PHONY: requirements pybliometrics-config notebook
