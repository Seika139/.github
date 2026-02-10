# Scribe Repository integration into Terraform

## Research

- [x] Check existing Terraform structure
- [x] Check scribe repository status (default branch, existing protection, etc.)
- [x] Check `repository` module capabilities (secrets, rulesets)

## Planning

- [x] Create implementation plan
- [x] Get user approval (including secret and build artifact protection)

## Secret and Build Artifact Protection

- [x] Update `repository` module to support `file_path_restriction` rules
- [x] Update `locals.tf` to add protection rulesets to repositories
- [x] Run `terraform plan` and verify
- [!] Apply changes (FAILED: GitHub API limitation for public repositories)
- [x] Revert `push` rules from configuration (as they are not supported)
- [x] Update walkthrough with this finding

## Execution

- [x] Update `terraform/github/locals.tf` to include `scribe` repository
- [x] Update `terraform/github/variables.tf` if new secrets are needed
- [x] Run `terraform plan` and verify
- [x] Import existing resources if necessary (branch protection rules, etc.)
- [x] Apply Terraform changes

## Secret Protection

- [ ] Update `repository` module to support `file_path_restriction` rules
- [ ] Update `locals.tf` to add "Do not push secrets" ruleset to repositories
- [ ] Run `terraform plan` and verify
- [ ] Apply changes
- [ ] Update walkthrough
