# cantera-windows-binaries

## 🚨 This repository is deprecated 🚨

This repository is in a holding state after the [removal of the legacy Matlab Toolbox](https://github.com/Cantera/cantera/pull/1670) from Cantera. There is a new [experimental Matlab interface](https://github.com/Cantera/enhancements/issues/177) in progress. When that interface is stable, this repository can be used again to build the Matlab interface for distribution.

---

This repository runs a GitHub Actions job to build the Windows binary
installer packages for Cantera.

To make a new release, change the `CT_VERSION` environment variable in
`.github/workflows/main.yaml` (line 9) to the correct version, and change
the `ref` key in the Cantera repository checkout to point to the correct
branch/tag (line 37).

The workflow uploads the MSI installers to an artifact associated with
each run.
