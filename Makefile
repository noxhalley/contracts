.PHONY: lint
lint:
	buf format -w
	buf lint
