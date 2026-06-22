# matlab

MATLAB scripts for electrophysiology acquisition, loading, and analysis.

| Script | Purpose |
| --- | --- |
| `Nacef_ABF_Analysis_Script.m` | Loads all `.abf` files in a chosen folder via `abfload`, parses frequency/pulse width/amplitude from file names, builds a data struct, and plots raw traces over a fixed time window. |
| `abfload.m` | Third-party loader for Axon Binary Format (`.abf`) files. Returns data, sample interval, and header. Supports gap-free, episodic, and event-driven modes. |
| `read_Intan_RHD2000_fileNMG.m` | Reads Intan RHD2000 (`.rhd`) recordings; returns amplifier channels/data and acquisition parameters. Modified version (v3.0) of the Intan-supplied reader. |
| `plotter.m` | Stacks multi-channel `amplifier_data` (from the Intan reader) in subplots, in a custom channel order. |
| `mapping_structs.m` | Joins a struct field to a reference table read from Excel (SQL-style join), applying a unit conversion. Used to map pulse amplitudes to optical power. |
| `euler_calculator.m` | Euler buckling-force calculation for layered probe dimensions (Parylene/Au/Pt). |
| `nacef_rigol_stimulation_script.m` | Sweeps amplitude/frequency/pulse-width and drives a Rigol signal generator over VISA for laser stimulation, triggering Clampex recording. **See note below.** |
| `Test.m` | Scratch script invoking `mapping_structs` against a specific Excel file. |

## Notes
- `Nacef_ABF_Analysis_Script.asv` is a MATLAB editor autosave backup, not a source file.
- `nacef_rigol_stimulation_script.m` is corrupted (operators and function calls are garbled, likely from a bad copy/paste or OCR). It will not run as-is and is kept for reference only.
- Several scripts assume specific hardware (Rigol generator, Clampex) or hardcoded data paths.
