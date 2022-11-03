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
	cd src && python3 ./scripts/graph-runner.py 90s

graph-all-time:
	cd src && python3 ./scripts/graph-runner.py all-time --path "../products/graphs/graph-all-time"

graph-per-decade:
	cd src && python3 ./scripts/graph-runner.py per-decade --path "../products/graphs/graph-all-time"

.PHONY: requirements pybliometrics-config notebook
