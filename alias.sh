if [ -f "$HOME/.update-pull-request-train-descriptions/main.rb" ]; then
  alias pr-train='ruby "$HOME/.update-pull-request-train-descriptions/main.rb"'
else
  echo "$HOME/.update-pull-request-train-descriptions/main.rb not found"
fi
