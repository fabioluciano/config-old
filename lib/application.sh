function func_architecture_string() {
  if [ $architecture = "64" ]; then
    echo 'amd64'
  elif [ $architecture = "32" ]; then
    echo 'i386'
  fi
}

export architecture=$(getconf LONG_BIT)
export distribution=$(lsb_release -cs)
export architecture_repository=$(func_architecture_string)
