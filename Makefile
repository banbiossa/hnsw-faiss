.PHONY: test lint build clean install push install-twine update lock env

## lock (not sure if we can parse this, but for visibility of dependencies)
lock:
	conda list > conda.lock

## test (run pytest)
test:
	python -m pytest tests

## lint (isort and black)
lint:
	python -m isort tests
	python -m black tests
	python -m isort oramal
	python -m black oramal
	python -m isort ./setup.py
	python -m black ./setup.py

## build python module (run build)
build:
	rm -rf build/ dist/ oramal.egg-info
	python setup.py sdist

## clean (clean rust build)
clean:
	rm -rf build/ dist/ oramal.egg-info
	rm -rf orama-rs/target
	rm -rf oramal/orama-rs

## update the env file and update
update:
	conda env update -f environment.yml --prune
	poetry install  # local package

## env
env:
	conda env create -f environment.yml
	# poetry install  # install the local package

## push to artifact registry
push:
	twine upload --repository-url https://asia-northeast1-python.pkg.dev/ai-lab-sandbox/ai-lab-pypi dist/*

## install twine dependency
install-twine:
	python -m pip install --upgrade pip
	pip install wheel twine
	pip install keyring
	pip install keyrings.google-artifactregistry-auth

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')

