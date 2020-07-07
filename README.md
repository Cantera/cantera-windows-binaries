# cantera-windows-binaries

This repository runs a GitHub Actions job to build the Windows binary
installer packages for Cantera.

To make a new release, change the `CT_VERSION` environment variable in
`.github/workflows/main.yaml` (line 9) to the correct version, and change
the `ref` key in the Cantera repository checkout to point to the correct
branch/tag (line 37).

The workflow uploads the MSI installers to an artifact associated with
each run.
