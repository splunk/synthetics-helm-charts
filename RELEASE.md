# Contributing to Synthetics Helm Charts

This guide will help you through the process of making PRs and releasing a new version of the Synthetics Helm Charts.

## Prerequisites

Before you begin, ensure you have the following tools installed:

- [Helm](https://helm.sh/docs/intro/install/)
- [Make](https://www.gnu.org/software/make/)
- [Helm-docs](https://github.com/norwoodj/helm-docs?tab=readme-ov-file#installation)
- [Helm unittest](https://github.com/helm-unittest/helm-unittest?tab=readme-ov-file#install)
- [Chart Testing](https://github.com/helm/chart-testing?tab=readme-ov-file#installation)

You can also install the above listed tools using the following command on macOS:

```sh
make install-tools
```

This repository also uses pre-commit hooks to ensure that the code is formatted correctly before changes are committed. Users are recommended to install pre-commit.

## Making Changes

### Pull Requests

Contributors should open a PR with their proposed changes. The PR title must include scope of the changes, for example, `feat: Add new feature`, `fix: Fix issue`, `chore: Update dependencies`, etc. The PR description should include a brief summary of the changes and any additional context that might be helpful for reviewers.

### Linting

After making changes to the Helm chart, you can lint the chart using the following command:

```sh
make lint
```

### README

The chart README is generated using the `helm-docs` tool. The tool generates a values table from comments in `values.yaml` file and uses the `README.md.gotmpl` to generates the chart's `README.md` file. After updates to the helm chart or `README.md.gotmpl` inside a chart directory, contributors must run below helm-docs script to generate the updated `README.md` file. Contributors should not edit the README.md file manually.

To update the README, run the following command which will start a docker container and run helm-docs on the chart:

```sh
make docker-docs
```

If you have helm-docs installed locally, you can run the following command:

```sh
make docs
```

### Unit Tests

This repository includes unit tests for helm charts that are written using the [helm unittest](https://github.com/helm-unittest/helm-unittest) plugin. The tests are located in the `tests/unittests` directory. Contributors should add tests for new features or bug fixes which involve using helm's templating engine. The test API documentation for the plugin can be found [here](https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md).

You can run the tests using the following command:
```sh
make unittest
```

### Versioning
The helm chart version should be updated in the `Chart.yaml` file. The version should follow the [Semantic Versioning](https://semver.org/) guidelines.

To bump the application version, update the `appVersion` field in the `Chart.yaml` file to match the new runner container image version.

### Releasing the Chart

To release a new version of the Helm chart, follow these steps:

1. **Update the Chart Version**:
   - Update the `version` field in the `Chart.yaml` file.

2. **Commit the Version Update**:
   - Commit the version update with a message like `chore: Bump chart version to x.y.z`.

   ```sh
   git add Chart.yaml
   git commit -m "chore: Bump chart version to x.y.z"
   ```

3. **Create a Pull Request**:
    - Push the changes to your branch and create a pull request.
    - Ensure that your pull request passes all checks.

4. **Merge PR and Automatic Release**:
    - Once the pull request is reviewed and approved, a maintainer will merge it into the main branch.
    - Upon merging the pull request, a GitHub Actions workflow will be triggered to automatically package and release the new version of the Helm chart. The new version will be available in the GitHub Releases section.
