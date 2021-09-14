ifneq (,)
.error This Makefile requires GNU Make.
endif

# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help lint lint-files terraform-docs terraform-fmt _pull-tf _pull-tfdocs
CURRENT_DIR = $(PWD)


# -------------------------------------------------------------------------------------------------
# Docker image versions
# -------------------------------------------------------------------------------------------------
TF_VERSION     = 0.13.7
FL_VERSION     = 0.4

FL_IGNORE_PATHS = .git/,.github/,.idea/

# -------------------------------------------------------------------------------------------------
# Terraform-docs configuration
# -------------------------------------------------------------------------------------------------
TFDOCS_VERSION = 0.9.1-0.28

# Adjust your delimiter here or overwrite via make arguments
TFDOCS_DELIM_START = <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
TFDOCS_DELIM_CLOSE = <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# -------------------------------------------------------------------------------------------------
# Meta Targets
# -------------------------------------------------------------------------------------------------

help:
	@echo
	@echo "Meta targets"
	@echo "--------------------------------------------------------------------------------"
	@echo "  help                 Show this help screen"
	@echo
	@echo "Read-only targets"
	@echo "--------------------------------------------------------------------------------"
	@echo "  lint                 Lint basics as well as *.tf and *.tfvars files"
	@echo "  lint-files           Lint basics"
	@echo
	@echo "Writing targets"
	@echo "--------------------------------------------------------------------------------"
	@echo "  terraform-docs       Run terraform-docs against all README.md"
	@echo "  terraform-fmt        Run terraform-fmt against *.tf and *.tfvars files"


# -------------------------------------------------------------------------------------------------
# Read-only Targets
# -------------------------------------------------------------------------------------------------

lint:
	@$(MAKE) --no-print-directory terraform-fmt _WRITE=false
	@$(MAKE) --no-print-directory lint-files

lint-files:
	@echo "################################################################################"
	@echo "# file-lint"
	@echo "################################################################################"
	@docker run --rm -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '$(FL_IGNORE_PATHS)' --path .
	@docker run --rm -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '$(FL_IGNORE_PATHS)' --path .
	@docker run --rm -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '$(FL_IGNORE_PATHS)' --path .
	@docker run --rm -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '$(FL_IGNORE_PATHS)' --path .
	@docker run --rm -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '$(FL_IGNORE_PATHS)' --path .
	@docker run --rm -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '$(FL_IGNORE_PATHS)' --path .


# -------------------------------------------------------------------------------------------------
# Writing Targets
# -------------------------------------------------------------------------------------------------

terraform-docs: _pull-tfdocs
	@echo "################################################################################"
	@echo "# Terraform-docs generate"
	@echo "################################################################################"
	@echo
	@if docker run --rm $$(tty -s && echo "-it" || echo) \
    -v "$(CURRENT_DIR):/data" \
    -e TFDOCS_DELIM_START='$(TFDOCS_DELIM_START)' \
    -e TFDOCS_DELIM_CLOSE='$(TFDOCS_DELIM_CLOSE)' \
    cytopia/terraform-docs:$(TFDOCS_VERSION) \
    terraform-docs-replace --sort-inputs-by-required --with-aggregate-type-defaults md README.md; then \
    echo "OK"; \
  else \
    echo "Failed"; \
    exit 1; \
	fi;
	@echo

terraform-fmt: _WRITE=true
terraform-fmt: _pull-tf
	@# Lint all Terraform files
	@echo "################################################################################"
	@echo "# Terraform fmt"
	@echo "################################################################################"
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tf files"
	@echo "------------------------------------------------------------"
	@if docker run $$(tty -s && echo "-it" || echo) --rm \
		-v "$(PWD):/data" hashicorp/terraform:$(TF_VERSION) fmt \
			$$(test "$(_WRITE)" = "false" && echo "-check" || echo "-write=true") \
			-diff \
			-list=true \
			-recursive \
			/data; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tfvars files"
	@echo "------------------------------------------------------------"
	@if docker run $$(tty -s && echo "-it" || echo) --rm --entrypoint=/bin/sh \
		-v "$(PWD):/data" hashicorp/terraform:$(TF_VERSION) \
		-c "find . -not \( -path './*/.terragrunt-cache/*' -o -path './*/.terraform/*' \) \
			-name '*.tfvars' -type f -print0 \
			| xargs -0 -n1 terraform fmt \
				$$(test '$(_WRITE)' = 'false' && echo '-check' || echo '-write=true') \
				-diff \
				-list=true"; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo


# -------------------------------------------------------------------------------------------------
# Helper Targets
# -------------------------------------------------------------------------------------------------

# Ensure to always have the latest Terraform version
_pull-tf:
	docker pull hashicorp/terraform:$(TF_VERSION)

_pull-tfdocs:
	docker pull cytopia/terraform-docs:$(TFDOCS_VERSION)
