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

graph-80s:
	python3 src/scripts/graph-runner.py one-decade 80s

graph-90s:
	python3 src/scripts/graph-runner.py one-decade 90s

graph-00s:
	python3 src/scripts/graph-runner.py one-decade 00s

graph-10s:
	python3 src/scripts/graph-runner.py one-decade 10s

graph-all-time:
	python3 src/scripts/graph-runner.py all-time --filename ./products/graphs/journals-all.graphml

graph-per-decade:
	python3 src/scripts/graph-runner.py per-decade --path ./products/graphs

.PHONY: requirements pybliometrics-config notebook
