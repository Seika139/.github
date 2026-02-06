# GitHub Repository Settings Update Walkthrough

## Changes

### Terraform Configuration

#### [terraform/github/main.tf](../../../terraform/github/main.tf)

- Converted `data "github_repository" "repo"` to `resource "github_repository" "repo"`.
- Added settings to enable:
  - `delete_branch_on_merge = true` (Automatically delete head branches)
  - `allow_update_branch = true` (Always suggest updating pull request branches)
- Updated all references from `data.github_repository.repo.name` to `github_repository.repo.name`.

## Verification Results

### Automated Verification

- `terraform fmt` ran successfully.

### Manual Verification Steps

1. **Initialize/Validate**:
   Run `terraform init` and `terraform validate` to ensure the configuration is valid.

   ```bash
   terraform init
   terraform validate
   ```

2. **Plan & Apply**:
   Run `terraform plan`.

   > [!IMPORTANT]
   > Since we converted a `data` source to a `resource`, Terraform might try to create the repository if it doesn't know it exists in the state.
   > If you get an error saying the repository already exists, you need to import it:
   >
   > ```bash
   > terraform import github_repository.repo <owner>/<repo>
   > ```
   >
   > Replace `<owner>/<repo>` with your actual repository full name (e.g., `Seika139/.github`).

3. **Verify Settings**:
   After applying, check the repository settings on GitHub:
   - **Settings** > **General** > **Pull Requests**
   - Confirm "Automatically delete head branches" is checked.
   - Confirm "Always suggest updating pull request branches" is checked.
