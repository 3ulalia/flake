{exec, ...}: {
  readSops = keyfile: name: exec ["env" "SOPS_AGE_KEY_FILE=${keyfile}" "sops" "-d" "${name}"];
}
