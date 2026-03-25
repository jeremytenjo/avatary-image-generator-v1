# Compatibility Policy

This repo uses a heavy CUDA base image. To avoid broken releases, keep these
known-good compatibility pins aligned.

## Base Image

- `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404`

## Required Runtime Pins

- `jupyterlab==4.5.6`
- `notebook==7.5.3`
- `pyparsing==3.1.1`

## Release Guardrails

1. Update `requirements.txt` and `.compatibility.json` together for any change
   to the required runtime pins above.
2. The `Dependency Check` workflow must pass before publish.
3. The manual publish workflow is gated by dependency checks and will not build
   if checks fail.
