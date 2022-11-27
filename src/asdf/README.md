
# ASDF-VM (asdf)

Adds the ASDF-VM and installs provided tools

## Example Usage

```json
"features": {
    "ghcr.io/moenzuel/devcontainer-features/asdf:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of ASDF-VM to install. | string | latest |
| plugins | Optional comma separated list of ASDF plugins to add. | string | - |
| toolVersions | Optional comma separated list of ASDF packages to install. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/moenzuel/devcontainer-features/blob/main/src/asdf/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
