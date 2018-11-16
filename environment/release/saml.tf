resource "tls_private_key" "saml" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "saml" {
  key_algorithm   = "ECDSA"
  private_key_pem = "${tls_private_key.saml.private_key_pem}"

  validity_period_hours = 876600 # 100 years

  allowed_uses = [
    "data_encipherment",
    "encipher_only",
  ]

  subject {
    common_name = "gitlab.${local.gitlab_domain}"
  }
}

resource "kubernetes_secret" "saml_config" {
  metadata {
    name      = "saml-config"
    namespace = "${local.k8s_namespace}"
  }

  data {
    config = <<EOF
name: "saml"
args:
  assertion_consumer_service_url: "https://gitlab.${local.gitlab_domain}/users/auth/saml/callback"
  certificate: |
    ${indent(4, tls_self_signed_cert.saml.cert_pem)}
  private_key: |
    ${indent(4, tls_private_key.saml.private_key_pem)}
  idp_cert: |
    -----BEGIN CERTIFICATE-----
    MIIEmDCCA4CgAwIBAgIQfLHlbRUtdCp5KSC69ObH+DANBgkqhkiG9w0BAQUFADA2
    MQswCQYDVQQGEwJOTDEPMA0GA1UEChMGVEVSRU5BMRYwFAYDVQQDEw1URVJFTkEg
    U1NMIENBMB4XDTEyMTIwNDAwMDAwMFoXDTE1MTIwNDIzNTk1OVowbzELMAkGA1UE
    BhMCR0IxIDAeBgNVBAoTF1VuaXZlcnNpdHkgb2YgQ2FtYnJpZGdlMR8wHQYDVQQL
    ExZVQ1MgU2hpYmJvbGV0aCBTZXJ2aWNlMR0wGwYDVQQDExRzaGliLnJhdmVuLmNh
    bS5hYy51azCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMQTbdQmYTcE
    Hwkw+7E9FXLcALHRwKoTpgA4PiZKcNu0CsVSD5VADQGN3u5myrlhjWIy7/filK5M
    BoUl5zsFFAgtNcPvCaSCNo9VuvIgLyhrM36JVX5n4/L6rHEP1KpUimho67lpN/eL
    92+3nXWIexwgDrYDiQyCl/RdHmzJCHakIMNnubnp8LdUvU4MDr2IviH7mecoUL/W
    LsKO+kEvFJMTsr2XUWZezCHIcTtEx2k2G63GtBrEnPq/UiG/vqzOX0NMsUM4d+j6
    mxogNZ6Ev3YZEWW98sCzzaBc7qsFjr3Derm4TuWDipkz59TdLlYPeC1TAsTFpTvg
    42fGhZjK/esCAwEAAaOCAWcwggFjMB8GA1UdIwQYMBaAFAy9k2gM896ro0lrKzdX
    R+qQ47ntMB0GA1UdDgQWBBSW6ydPZrdKjKgjpVpJ6K3T8BZrLzAOBgNVHQ8BAf8E
    BAMCBaAwDAYDVR0TAQH/BAIwADAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUH
    AwIwGAYDVR0gBBEwDzANBgsrBgEEAbIxAQICHTA6BgNVHR8EMzAxMC+gLaArhilo
    dHRwOi8vY3JsLnRjcy50ZXJlbmEub3JnL1RFUkVOQVNTTENBLmNybDBtBggrBgEF
    BQcBAQRhMF8wNQYIKwYBBQUHMAKGKWh0dHA6Ly9jcnQudGNzLnRlcmVuYS5vcmcv
    VEVSRU5BU1NMQ0EuY3J0MCYGCCsGAQUFBzABhhpodHRwOi8vb2NzcC50Y3MudGVy
    ZW5hLm9yZzAfBgNVHREEGDAWghRzaGliLnJhdmVuLmNhbS5hYy51azANBgkqhkiG
    9w0BAQUFAAOCAQEAh5t+ortlUIp2CkhSF3KTeUm3O8vhM0EX0Kl6bid2qI69nxom
    vGYMqBMPKcc9foCbEgILSKa9kUwt3lcyF4HFK7X/BzU0c7YyR/Di734fxyvWqsgj
    H8WJJmZnS7md614HFlfoCMjeeC6iTuAT5LcsreBdl+VBerpL51/SCb0IKtd3J0dK
    4+EFLNpQgQKhMYR2zGYIeNX+3uH5ESHhFYL7bgG3RsBTzn2CZALHGm6+dVgnjw49
    fHaY+8yYGVTfXPZqJ08SfZxCidmlWejicoxE1uHFGuL6HSEDMm/uF3L0H4mUPoxO
    iDQ+4/pKRbtOiTokxLohAPABDm+GgCrcuwZjqg==
    -----END CERTIFICATE-----
  idp_sso_target_url: "https://shib.raven.cam.ac.uk/idp/profile/SAML2/Redirect/SSO"
  issuer: "gitlab.${local.gitlab_domain}"
  name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
label: "Raven"
EOF
  }
}
