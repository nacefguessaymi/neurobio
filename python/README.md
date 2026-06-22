# python

Python analysis scripts. Environment managed with `pixi` (see `../pixi.toml`); use the `python` environment.

| Script | Purpose |
| --- | --- |
| `ABF_Analysis_Script.py` | Loads juxtacellular `.abf` recordings (100 kHz) with `pyabf`, applies a Butterworth bandpass (100–8000 Hz), detects spikes with `quickspikes`, and plots raw/filtered traces against stimulation pulses. Aggregates spike counts and peak-to-peak amplitude as a function of optical power. File names encode frequency/pulse width/voltage (`{freq}hz_{pw}ms_{volt}v.abf`). |
| `processing_image_script.py` | PyImageJ port of the histology pipeline (see `../imagej/`): splits CZI channels, merges, subtracts background, adjusts brightness/contrast, crops to ROI, sets scale bars, and exports TIFF/JPEG plus intensity measurements. |
| `Running.py` | Entry point that initializes ImageJ2 with Fiji and runs the `.ijm` macro in `../imagej/`. |
| `doctor.py` | PyImageJ environment diagnostic (vendored from `imagej.doctor`); checks Python, Conda, Maven, and Java setup. |

## Notes
- `ABF_Analysis_Script.py` has a hardcoded data path and expects the file-naming convention above.
- `processing_image_script.py` is a partial port and contains placeholder sections; the `.ijm` macro is the reference implementation.
