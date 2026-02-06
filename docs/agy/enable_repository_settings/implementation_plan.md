# GitHub Repository Settings Update

## Goal Description

Enable `delete_branch_on_merge` and `allow_update_branch` for the GitHub repository managed by Terraform.
This requires converting the existing `data "github_repository"` block to a `resource "github_repository"` block to allow management of repository settings.

## User Review Required

> [!IMPORTANT]
> This change converts a Data Source to a Resource. This usually requires importing the existing resource into the Terraform state. If `terraform apply` fails claiming the resource already exists, you will need to import it:
> `terraform import github_repository.repo <owner>/<repo>`

## Proposed Changes

### Terraform

#### [MODIFY] [main.tf](../../../terraform/github/main.tf)

- Change `data "github_repository" "repo"` to `resource "github_repository" "repo"`.
- Add arguments:
  - `name`: Derived from `var.github_repository_full_name`.
  - `delete_branch_on_merge = true`
  - `allow_update_branch = true`
- Keep `full_name` extraction logic (indirectly via `name`).

## Verification Plan

### Automated Tests

- `terraform validate` (if environment permits).

### Manual Verification

- User runs `terraform plan` to confirm changes.
- Verify "Automatically delete head branches" is enabled in GitHub Settings.
- Verify "Always suggest updating pull request branches" is enabled in GitHub Settings.
