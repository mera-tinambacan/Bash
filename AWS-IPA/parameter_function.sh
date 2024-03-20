get_parameter() {
  local name="$1"
  aws ssm get-parameter --name "$name" --query "Parameter.Value" --output text
}
