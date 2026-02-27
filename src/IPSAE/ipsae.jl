module IPSAE

export predict_ipsae, get_ipsae

using PythonCall, PyBoltz
# Based on https://github.com/adaptyvbio/nipah_ipsae_pipeline
# Calculate IPSAE score of prediction

const _IPSAE_PY = joinpath(@__DIR__, "ipsae.py")

compile_calculate_ipsae() = @pyexec (ipsae_py=_IPSAE_PY) => """
    global os, pd
    import os
    import pandas as pd

    def calculate_ipsae(
        pae_file_path,
        structure_file_path,
        pae_cutoff=15.0,
        dist_cutoff=15.0,
        _ipsae_py=ipsae_py,
    ):

        #Calculate ipSAE and related scores for protein-protein interactions.

        #Parameters:
        #-----------
        #pae_file_path : str
        #    Path to the PAE file (JSON for AF2/AF3, NPZ for Boltz1)
        #structure_file_path : str
        #    Path to the structure file (PDB for AF2, mmCIF for AF3/Boltz1)
        #pae_cutoff : float
        #    Cutoff value for PAE in score calculations
        #dist_cutoff : float
        #    Cutoff value for distance in score calculations

        #Returns:
        #--------
        #dict
        #    Dictionary containing all calculated scores
        os.system(f"python {_ipsae_py} {pae_file_path} {structure_file_path} {pae_cutoff} {dist_cutoff}")

        print(f"Reading results from {structure_file_path.replace('.cif',  f'_{int(pae_cutoff)}_{int(dist_cutoff)}.txt')}")

        df = pd.read_csv(structure_file_path.replace('.cif', f'_{int(pae_cutoff)}_{int(dist_cutoff)}.txt'))
        results = {}


        for i, row in df[df.Type=="max"].iterrows():
            chainpair = f"{row['Chn1']}-{row['Chn2']}"

            results[chainpair] = {
                "max": {
                    **{col: row[col] for col in df.columns[5:-1]}
                }
            }
            mask = (df['Chn1'] == row['Chn1']) & (df['Chn2'] == row['Chn2']) & (df['Type'] != "max")
            min_vals = df[mask][df.columns[5:-1]].min()
            results[chainpair]["min"] = min_vals.to_dict()

        return results
    """ => calculate_ipsae

function get_ipsae(out_dir)
    full_out_dir = joinpath(out_dir, "boltz_results_inputs", "predictions", "pyboltz_structure_1")
    pae_file_path = joinpath(full_out_dir, "pae_pyboltz_structure_1_model_0.npz")
    structure_file_path = joinpath(full_out_dir, "pyboltz_structure_1_model_0.cif")
    # Calculate IPSAE
    calculate_ipsae = compile_calculate_ipsae()
    results = calculate_ipsae(pae_file_path, structure_file_path)
    return results["A-B"]["max"]["ipSAE"]
end

function predict_ipsae(input, out_dir; kwargs...)
    isdir(out_dir) && throw("out_dir already exists")
    # Boltz predict, with write_full_pae=true
    predict(input; out_dir, write_full_pae=true, kwargs...)
    results = get_ipsae(out_dir)
    return results
end
predict_ipsae(input; kwargs...) = mktempdir(tmp_dir -> predict_ipsae(input, joinpath(tmp_dir, "boltz_output"); kwargs...))

end