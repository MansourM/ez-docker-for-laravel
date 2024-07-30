is_port_in_use() {
  local port=$1
  if lsof -i -P -n | grep -q ":$port"; then
    return 0
  else
    return 1
  fi
}
