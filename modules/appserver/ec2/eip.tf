resource "aws_eip" "app_server_eip" {
  for_each = aws_instance.app-server

  instance = each.value.id
  vpc      = true
  tags = {
    Name = "${each.key}-eip"
  }
}