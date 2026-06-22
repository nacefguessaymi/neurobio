# neurobio

Code developed as a student at CMU, covering juxtacellular electrophysiology, optogenetic stimulation, and histology image analysis. Archived here; not actively maintained.

## Layout

| Folder | Contents |
| --- | --- |
| [`python/`](python/) | `.abf` spike analysis (`pyabf` + `quickspikes`), PyImageJ histology pipeline, and environment diagnostics. |
| [`matlab/`](matlab/) | ABF and Intan RHD2000 loaders, trace plotting, Rigol stimulation control, and assorted analysis utilities. |
| [`imagej/`](imagej/) | Fiji macro for batch histology image processing (channel split/merge, background subtraction, ROI crop, scale bars, measurements). |

Each folder has its own README describing the individual scripts.

## Environment

The Python environment is managed with [pixi](https://pixi.sh) (see `pixi.toml` / `pixi.lock`):

```
pixi shell -e python
```

MATLAB scripts run in MATLAB (or Octave via the `matlab` environment); the ImageJ macro runs in Fiji.

## Caveats

Several scripts have hardcoded data paths, assume specific hardware (Rigol signal generator, Clampex, Intan controller), or rely on a `{freq}hz_{pw}ms_{volt}v.abf` file-naming convention. See the per-folder READMEs for details.
