<img src="https://lucenia.io/wp-content/uploads/2024/07/Asset_38Lucenia_H_LB_NS.png" height="84px">

- [Lucenia Helm-Charts](#lucenia-helm-charts)
- [Status](#status)
- [Version and Branching](#version-and-branching)
- [Installation](#installation)


# Lucenia Helm Charts

This repository contains the Helm charts for Lucenia's products.

## Lucenia

The [Lucenia Helm chart](./lucenia) defines resources for deploying Lucenia on Kubernetes. See the [Lucenia documentation](./lucenia/README.md) and [values](./lucenia/values.yaml) for more information on configuring and deploying Lucenia.

## Status

[![Lint and Test Charts](https://github.com/lucenia/helm-charts/actions/workflows/lint-test.yaml/badge.svg)](https://github.com/lucenia/helm-charts/actions/workflows/lint-test.yaml)
 [![Release Charts](https://github.com/lucenia/helm-charts/actions/workflows/release.yaml/badge.svg)](https://github.com/lucenia/helm-charts/actions/workflows/release.yaml)

## Version and Branching
As of now, this helm-charts repository maintains two branches:
* _main_ (Version is 0.x.x for both `version` and `appVersion` in `Chart.yaml`)
* _gh-pages_ (Reserved branch for publishing helm-charts through github pages)
<br>

Contributors should choose the corresponding branch(es) when commiting their change(s):
* If you have a change for a specific version, only open PR to specific branch
* If you have a change for all available versions, first open a PR on `main`, then open a backport PR with `[backport 1.x]` in the title, with label `backport 1.x`, etc.
* No changes should be commited to `gh-pages` by any contributor, as this branch should be only changed by github actions `chart-releaser` 

## Kubernetes Version Support
* This helm-chart repository is tested with kubernetes version 1.19 and above

## Installation

To install the Lucene Helm charts, execute the following commands:

```shell
helm repo add lucenia https://lucenia.github.io/helm-charts/
helm repo update
```

Once the charts repository reference is added, you can run the following command to see the charts.

```shell
helm search repo lucenia
```

You can now deploy charts with this command.

```shell
helm install my-deployment lucenia/<chart name>
```

Please see the `README.md` in the [Lucenia](charts/lucenia) directory for installation instructions.
