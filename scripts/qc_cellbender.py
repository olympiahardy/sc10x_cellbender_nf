#!/usr/bin/env python

import os
import argparse

import numpy as np
import scanpy as sc
import matplotlib.pyplot as plt

from cellbender.remove_background.downstream import load_anndata_from_input_and_output


def parse_args():
    p = argparse.ArgumentParser(
        description="QC for raw 10x HDF5 and CellBender-corrected matrix, "
                    "saving CellBender counts as a layer in a single AnnData."
    )
    p.add_argument("--filtered_h5", required=True,
                   help="Filtered 10x HDF5 (e.g. filtered_feature_bc_matrix.h5)")
    p.add_argument("--cellbender_h5", required=True,
                   help="CellBender remove-background output .h5")
    p.add_argument("--sample_id", required=True,
                   help="Sample ID for output filenames")
    p.add_argument("--outdir", required=True,
                   help="Directory to write .h5ad and PDF")
    return p.parse_args()


def add_qc_metrics(adata):
    """Add basic QC metrics including mitochondrial percentage."""
    adata.var["mt"] = adata.var_names.str.upper().str.startswith("MT-")
    sc.pp.calculate_qc_metrics(
        adata,
        qc_vars=["mt"],
        percent_top=None,
        log1p=False,
        inplace=True
    )
    return adata


def make_qc_violin_plots(adata,sample_id, outdir):
    """Create a PDF with QC violins."""

    # Violin plots
    qc_features = ["n_genes_by_counts", "total_counts", "pct_counts_mt"]

    sc.pl.violin(
        adata,
        qc_features,
        groupby=None,
        multi_panel=True,
        jitter=0.4,
        show=False,
    )

    plt.tight_layout()
    pdf_path = os.path.join(outdir, f"{sample_id}_qc_violin_plots.pdf")
    plt.savefig(pdf_path, bbox_inches="tight")
    plt.close()
    print(f"Saved QC violin plots to: {pdf_path}")


def main():
    args = parse_args()
    os.makedirs(args.outdir, exist_ok=True)

    adata = load_anndata_from_input_and_output(
    input_file=args.filtered_h5,
    output_file=args.cellbender_h5,
    input_layer_key='raw',  # this will be the raw data layer
)
    # --- Load filtered 10x HDF5 ---
    print(f"Anndata with both raw and cellbender layers: {adata}")

    adata.obs_names_make_unique()
    adata.var_names_make_unique()
    # --- Create QC objects for plotting (filtered vs cellbender) ---
    add_qc_metrics(adata)

    # --- Make QC PDF ---
    make_qc_violin_plots(adata, args.sample_id, args.outdir)

    # --- Save combined AnnData ---
    out_path = os.path.join(args.outdir, f"{args.sample_id}.h5ad")
    adata.write(out_path)
    print(f"Saved combined AnnData (filtered X + 'cellbender' layer) to: {out_path}")


if __name__ == "__main__":
    main()