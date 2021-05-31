#!/bin/sh

main() {
  vasm_bin="../../vasm/vasmm68k_mot"
  command -v "${vasm_bin}" >/dev/null 2>&1 || exit 1
  for asm_file in def_*-*.asm ; do
    IFS='-.' read -r info_base info_path _ <<EOF
${asm_file}
EOF
    [ "${asm_file}" = "${info_base}-${info_path}.asm" ] || continue
    info_file="${info_path}/${info_base}.info"
    mkdir -p ${info_path}
    command -p "${vasm_bin}" \
      -quiet \
      -Fbin \
      -m68000 \
      -no-fpu \
      -showopt \
      -o "${info_file}" \
      "${asm_file}" \
      && echo "${info_file}" \
      || exit 1
  done
}

main "$@"

