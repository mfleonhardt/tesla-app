resource "tls_private_key" "tesla_app" {
    algorithm = "ECDSA"
    ecdsa_curve = "P256"
}
