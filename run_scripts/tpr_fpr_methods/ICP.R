source("run_scripts/tpr_fpr_cli.R")

save_tpr_fpr_cli_args(one_minus(p_values_ICP), "ICP",
                      n_DAGs_to_process = 10)
