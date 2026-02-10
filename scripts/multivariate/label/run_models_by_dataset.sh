#!/usr/bin/env bash
set -eu

CONFIG="unfixed_detect_label_multi_config.json"
CONFIG_SCORE="unfixed_detect_score_multi_config.json"
GPU=0
WORKERS=1
TIMEOUT=1000

declare -a MODELS=(
  "tods.lofski"
  "tods.cblofski"
  "tods.hbosski"
  "tods.ocsvmski"
  "tods.knnski"
  "self_impl.KMeans"
  "self_impl.ARIMA"
  "tods.lodaski"
  "self_impl.PCA"
  "self_impl.NLinear"
  "self_impl.DLinear"
)

get_hyper() {
  case "$1" in
    self_impl.KMeans)
      echo '{"window_size": 100}'
      ;;
    self_impl.ARIMA)
      echo '{}'
      ;;
    self_impl.PCA)
      echo '{}'
      ;;
    self_impl.NLinear)
      echo '{}'
      ;;
    self_impl.DLinear)
      echo '{}'
      ;;
    *)
      echo '{}'
      ;;
  esac
}

for csv in NYC.csv PUMP.csv SMD.csv CICIDS.csv Creditcard.csv GECCO.csv Genesis.csv SWAN.csv PSM.csv; do
  name="${csv%.csv}"
  for model in "${MODELS[@]}"; do
    hyper="$(get_hyper "$model")"
    base_out_label="label/${model}"
    base_out_score="score/${model}"
    out="${name}/${base_out_label}"
    out_score="${name}/${base_out_score}"

    mkdir -p "${out}" "${out_score}"

    python ./scripts/run_benchmark.py \
      --config-path "${CONFIG}" \
      --model-name "${model}" \
      --model-hyper-params "${hyper}" \
      --gpus "${GPU}" \
      --num-workers "${WORKERS}" \
      --timeout "${TIMEOUT}" \
      --save-path "${out}" \
      --data-name-list "${csv}"

    python ./scripts/run_benchmark.py \
      --config-path "${CONFIG_SCORE}" \
      --model-name "${model}" \
      --model-hyper-params "${hyper}" \
      --gpus "${GPU}" \
      --num-workers "${WORKERS}" \
      --timeout "${TIMEOUT}" \
      --save-path "${out_score}" \
      --data-name-list "${csv}"
  done
done
