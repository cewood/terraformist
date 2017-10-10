.PHONY: apply
apply:
	if [ ! -e $(target)/terraform.tfplan ]; then echo "WARN: Nothing to apply, exiting!"; exit 1; fi
	_scripts/tf-run $(target) apply -backup=terraform.tfstate.backup ./terraform.tfplan; _scripts/tf-cleanup $(target)

.PHONY: collection
collection:
	for TARGET in $(shell find $(collection) -mindepth 1 -maxdepth 1 -type d ! -name '*_*'); \
	do \
		echo; \
		echo "TARGET is: $${TARGET}"; \
		make plan target=$${TARGET}; \
	done

.PHONY: init
init: setup
	_scripts/tf-run $(target) init

.PHONY: plan
plan: setup
	_scripts/tf-run $(target) plan -detailed-exitcode -out=terraform.tfplan -state=terraform.tfstate ./; if [ "$$?" -ne "2" ]; then _scripts/tf-cleanup $(target); fi

.PHONY: run
run: setup
	_scripts/tf-run $(target) $(args)

.PHONY: setup
setup:
	_scripts/tf-setup $(target)
