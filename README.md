# Causal discovery from interventional data

This repository contains code used for simulations for my BSc thesis. You can
read more about the thesis [on my
website](https://adamgorm.dk/posts/2021/09/08/bsc-thesis-causal-discovery-from-interventional-data/).

The sections below give detailed instruction on how to use the scripts to
simulate (and process results) from any alltargets or singletargets setting
using either truly separate data or permuted separate data.

The files in `thesis_parameters` contain the parameters for the data included in
plots in the thesis. Simulating using these parameters will take up over 4.5 TB
in total.

## Prerequisites

You must have `R` and `bash` installed. You must stand in the root of the
repository while running the scripts.

Run `Rscript run_scripts/install_packages.R` to install the necessary R packages.

I have only tested the code on GNU/Linux. I assume that it works on other
Unix-like systems as well (e.g., macOS or FreeBSD), but am unsure whether it works on
Windows.

## Quick start

This will simulate permuted separate data from two small alltargets settings and
two small singletargets settings, and process the data using all methods, as a
simple illustration of the scripts. See the section below for more detailed
instruction on usage, to understand what happens here, and how to simulate from
other settings.

1. Create directories `data` and `run_scripts/.output` (i.e., run `mkdir data`
   and `mkdir run_scripts/.output`).
2. Run `Rscript run_scripts/DAGs1000_nx30_nh30_probconnect04.R` to simulate 1000
   random DAGs.
3. Run `./run_scripts/run_sim_and_tpr_fpr_and_AUC.sh -p 4`. This will run all
   simulations and processing in parallel, but with a maximum of 4 processes
   running at the same time.
   
It will likely take about 30 minutes to run.

## Detailed explanation of use

### Preparing for simulations

Run `run_scripts/DAGs1000_nx30_nh30_probconnect04.R` respectively
`DAGs1000_nx5_nh5_probconnect04.R` to simulate DAGs with 30 X and 30 H
respectively 5 X and 5 H. Change the `saveRDS` in those files to save the DAGs
where you wish.

Create a subdirectory for the data and set the file `run_tools/data_dir.txt` to
contain its name (if you just call the subdirectory `data`, then
`run_tools/data_dir.txt` already contains the right name).

You must create a directory `run_scripts/.output`. This will contain messages
from the simulations, so you can track how far they have come.

If you want to simulate truly separate data, then set the content of
`run_tools/data_tools_file.txt` to be `tools/separate_data_tools.R` (i.e., run
`echo 'tools/separate_data_tools.R' > run_tools/data_tools_file.txt`), or if you
want to simulate permuted separate data, then set the content of
`data_tools_file.txt` to be `tools/data_tools.R` (i.e., run `echo
'tools/data_tools.R' > run_tools/data_tools_file.txt`).

Make sure that the directory `run_scripts/tpr_fpr_methods` contains exactly the
methods you want to run after simulating data.

Add simulation parameters to `run_scripts/alltargets_params.txt` and
`run_scripts/singletargets_params.txt` (they must contain at least one line
each). Each line in `alltargets_params.txt` must be of the form `a b c d`
where `a` is the number of observations per environment, `b` is the number of
environments, `c` is the standard deviation of the mean shifts, and `d` is the
standard deviation of the hiddens. Each line in `singletargets_params.txt` must
be of the form `e f g h i j` where `e` is the number of observations per
environment, `f` is the number of environments per X intervened on, `g` is the number of X's to
intervene on, `h` is the number of control observations, `i` is the standard
deviation of the mean shifts, and `j` is the standard deviation of the hidden variables.

Go to `run_scripts/alltargets_sim.txt` respectively
`run_scripts/singletargets_sim.txt` and set the `DAGs_to_sim` variable to
contain the indices of the DAGs you wish to simulate from, and set the
`DAGs_filename` variable to contain the file containing the list of DAGs.

### Running simulations and analyzing the data

Run `./run_scripts/run_sim_and_tpr_fpr_and_AUC.sh -p k` where `k` should be the
number of parallel processes you want to allow. This will simulate data, apply
the methods to the data, and process the results to calculate AUC. Nothing more
is needed! The script automatically keeps track of when the simulations are
done, and add the corresponding analysis of the data to the queue at the
appropriate time.

### Tips and tricks

If you have to stop the simulations again and want to continue at a later time,
then just use `Ctrl-C` to stop them, and run the command
`./run_scripts/run_sim_and_tpr_fpr_and_AUC.sh -p k` again when you are ready to
start them again. When simulating data, the simulated data sets are saved
in files of approximately 500 MB, and the simulation will automatically pick up
from where it left off when you restart the script.

While a simulation is running, you may wish to check which processes are
currently running to get an idea of how far it has come. To do this, just run
`./run_scripts/cont_list_running.sh` in another terminal.

Another way to monitor simulations is through the files in
`run_scripts/.output`. You can, e.g., run `tail -f
run_scripts/.output/singletargets_10_10_30_100_7_5.txt` to monitor the currently
running simulation in the singletargets setting with parameters (10, 10, 30,
100, 7, 5). You can read the source code of
`run_scripts/run_sim_and_tpr_fpr_and_AUC.sh` to see the naming conventions of
files in `run_scripts/.output`.

You can run `./run_scripts/add_AUC.sh` to process the tpr_fpr files if you stop
the simulation script before it finishes and would like to see the results so
far.

By default ICP and PICP is only run on 10 DAGs, no matter how many you have
simulated, since they are quite slow. Change this in
`run_scripts/tpr_fpr_methods/ICP.R` and `run_scripts/tpr_fpr_methods/PICP.R` if
you want to run them on more DAGs.

### Troubleshooting

Sometimes `run_scripts/run_sim_and_tpr_fpr_and_AUC.sh` fails to add the AUC
files after finishing the simulations and data processing. If this happens, then
run `./run_scripts/add_AUC.sh`. This will add all AUC files, and should run in
less than a minute.

## Other scripts

The script `run_scripts/random_AUC.R` calculates the mean and quartiles of the
random baseline methods. You must supply a list of DAGs; see the source code.

The script `run_scripts/generate_plots.R` was used to generate the plots. This
is not runnable as is, since it depends heavily on the way I split the simulations
into portions, and where I saved them, but the source code can easily be adapted
based on where you save your simulation results.

## Overview of folders

### `run_scripts`

`run_scripts` contains user interfaces for easily simulating large amounts of
data. The script `run_sim_and_tpr_fpr_and_AUC.sh` is particularly useful. It
parses the files `alltargets_params.txt` and `singletargets_params.txt` where
each line contains a set of parameters. It then simulates data from all of these
setups in parallel. After any of the data simulations are done (while the others
might still run) it starts processing the data to save true positive and false
positive rates. When all of the data is simulated an processed in this way it
does a last pass through the folder to collect all information and calculate
AUC.

### `tools`

`tools` contains the main tools for simulating random SCMs, data from them, and
running the methods. These files contain the functions called by the scripts in
`run_scripts`.

- `DAG_tools.R` for simulating random DAGs.
- `separate_data_tools.R` for simulating truly separate data.
- `data_tools.R` for simulating permuted separate data.
- `methods.R` for getting parameter estimates and p-values from the different methods.
- `AUC_tools.R` for calculating area under the curve for the methods on simulated data.

### `LICENSE.md`

Contains license terms.
