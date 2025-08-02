.PHONY: lint
lint:
	buf format -w
	buf lint

.PHONY: gen
gen:
	buf generate
