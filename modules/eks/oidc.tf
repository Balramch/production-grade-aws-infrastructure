data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity.0.oidc.0.issuer
}
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates.0.sha1_fingerprint]
  url = aws_eks_cluster.this.identity.0.oidc.0.issuer
}

output "oidc_url" {
  value = aws_eks_cluster.this.identity.0.oidc.0.issuer
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  value = replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
}