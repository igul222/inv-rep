
L_LIST=(0.0001)
B_LIST=(0.01)
B_BVFAE_LIST=(1)
#D_LIST=(30)
D_LIST=(30)
TF_CPP_MIN_LOG_LEVEL=3

mkdir -p data/raw/
mkdir -p out_params/adult/
mkdir -p out_evals/adult/

#if file does not exist
if [ ! -f "data/adult_proc.z" ]; then
  python src/uci_data.py
fi

TARGET_EPOCH=501

echo 
echo "RUNNING"
echo 

python src/adv.py \
  --num_epochs 251 \
  --n_hidden 64 \
  --batch_size 1024 \
  --experiment_name "grid_navib" \
  --latent_and_label_data_path "data/adult_proc.z" \
  --learn_rate 0.001 \
  --eval_output "out_evals/adult/baseline_adv_err.tsv" \
  --max_target_epoch 250 \
  --c_type "zero_one" \
  --baseline

echo 
echo 
echo 


python src/adv.py \
  --num_epochs 251 \
  --n_hidden 64 \
  --batch_size 1024 \
  --experiment_name "grid_navib" \
  --latent_and_label_data_path "data/adult_proc.z" \
  --learn_rate 0.001 \
  --eval_output "out_evals/adult/majority_class_baseline_adv_err.tsv" \
  --max_target_epoch 250 \
  --c_type "zero_one" \
  --baseline --majority_class_baseline

echo 
echo 
echo 

python src/adv.py \
  --num_epochs 251 \
  --n_hidden 512 \
  --batch_size 1024 \
  --experiment_name "grid_navib" \
  --latent_and_label_data_path "data/adult_proc.z" \
  --learn_rate 0.0002 \
  --eval_output "out_evals/adult/baseline_adv_err_strong.tsv" \
  --max_target_epoch 250 \
  --c_type "bce_train_acc_eval" \
  --keep_prob 1.0 \
  --baseline

echo 
echo 
echo 


python src/adv.py \
  --num_epochs 251 \
  --n_hidden 512 \
  --batch_size 1024 \
  --experiment_name "grid_navib" \
  --latent_and_label_data_path "data/adult_proc.z" \
  --learn_rate 0.0002 \
  --eval_output "out_evals/adult/majority_class_baseline_adv_err_strong.tsv" \
  --max_target_epoch 250 \
  --c_type "bce_train_acc_eval" \
  --keep_prob 1.0 \
  --baseline --majority_class_baseline

echo 
echo 
echo 

for D in ${D_LIST[@]}; do
for B in ${B_LIST[@]}; do
for L in ${L_LIST[@]}; do

echo
echo
echo "*************************************************"
echo "NA VIB L${L} B${B} D${D}"
echo "*************************************************"
echo 
echo 


  python src/run_navib.py \
    --save_freq 100 \
    --dim_z ${D} \
    --save_freq 25 \
    --num_epochs ${TARGET_EPOCH} \
    --batch_size 128 \
    --beta_param ${B} \
    --n_hidden_xz 64 \
    --n_hidden_zy 64 \
    --lambda_param ${L} \
    --param_save_path "out_params/adult/l${L}_b${B}_d${D}/" \
    --experiment_name "grid_navib" \
    --data_path "data/adult_proc.z" \
    --keep_prob 0.5 \
    --learn_rate 1e-4

echo 
echo 
echo 

  python src/eval.py\
    --save_freq 100 \
    --dim_z ${D} \
    --num_epochs ${TARGET_EPOCH} \
    --n_hidden 64 \
    --n_hidden_xz 64 \
    --n_hidden_zy 64 \
    --param_save_path "out_params/adult/l${L}_b${B}_d${D}/" \
    --experiment_name "grid_navib" \
    --augmented_data_path "data/adult_proc.z" \
    --outputs_path "out_evals/adult/l${L}_b${B}_d${D}/" \
    --output_latent_codes \
    --output_pred_error \
    --pred_error_file "out_evals/adult/l${L}_b${B}_d${D}/pred_err.tsv"

echo 
echo 
echo 

  python src/adv.py \
    --save_freq 100 \
    --save_freq_adv 50 \
    --dim_z ${D} \
    --n_hidden 64 \
    --num_epochs 251 \
    --batch_size 1024 \
    --experiment_name "grid_navib" \
    --latent_and_label_data_path "out_evals/adult/l${L}_b${B}_d${D}/" \
    --learn_rate 0.001 \
    --eval_output "out_evals/adult/l${L}_b${B}_d${D}/adv_err.tsv" \
    --max_target_epoch ${TARGET_EPOCH}\
    --c_type "zero_one"

echo 
echo 
echo 

  python src/adv.py \
    --save_freq 100 \
    --save_freq_adv 50 \
    --dim_z ${D} \
    --n_hidden 512 \
    --num_epochs 251 \
    --batch_size 1024 \
    --experiment_name "grid_navib" \
    --latent_and_label_data_path "out_evals/adult/l${L}_b${B}_d${D}/" \
    --learn_rate 0.0002 \
    --eval_output "out_evals/adult/l${L}_b${B}_d${D}/adv_err_strong.tsv" \
    --max_target_epoch ${TARGET_EPOCH} \
    --c_type "bce_train_acc_eval" \
    --keep_prob 1.0


done
done
done








