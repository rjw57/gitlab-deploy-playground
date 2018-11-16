resource "tls_private_key" "saml" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "saml" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.saml.private_key_pem}"

  validity_period_hours = 876600 # 100 years

  # This is ignored by our IdP but let's make a good show of things.
  allowed_uses = [
    "data_encipherment",
    "encipher_only",
  ]

  # This is ignored by our IdP but let's make a good show of things.
  subject {
    common_name = "${local.gitlab_external_host}"
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
label: "Raven"
args:
  issuer: "${local.gitlab_external_host}"
  assertion_consumer_service_url: "https://${local.gitlab_external_host}/users/auth/saml/callback"
  certificate: |
    ${indent(4, tls_self_signed_cert.saml.cert_pem)}
  private_key: |
    ${indent(4, tls_private_key.saml.private_key_pem)}

  # Only used to generate metadata
  name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"

  # List of attributes available is at
  # https://wiki.cam.ac.uk/raven/Attributes_released_by_the_Raven_IdP#University_SPs
  attribute_statements:
    # "mail" is the actual email address for the user as opposed to "eppn" which
    # is "<crsid>@cam.ac.uk". However "mail" is under the user's control and
    # should not be used for access control.
    email:
      - 'urn:oid:1.3.6.1.4.1.5923.1.1.1.6'
      - 'urn:mace:dir:attribute-def:eduPersonPrincipalName'
      - 'eppn'

    # Human-friendly name
    name:
      - 'urn:oid:2.16.840.1.113730.3.1.241'
      - 'urn:mace:dir:attribute-def:displayName'
      - 'displayName'

  idp_sso_target_url: "https://shib.raven.cam.ac.uk/idp/profile/SAML2/Redirect/SSO"

  # From: http://shib.raven.cam.ac.uk/shibboleth
  idp_cert: |
    -----BEGIN CERTIFICATE-----
    MIICujCCAaICCQDN9BMM2g2oWzANBgkqhkiG9w0BAQUFADAfMR0wGwYDVQQDExRz
    aGliLnJhdmVuLmNhbS5hYy51azAeFw0xNTExMjAxNDUwNTFaFw0yNTExMTcxNDUw
    NTFaMB8xHTAbBgNVBAMTFHNoaWIucmF2ZW4uY2FtLmFjLnVrMIIBIjANBgkqhkiG
    9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxBNt1CZhNwQfCTD7sT0VctwAsdHAqhOmADg+
    Jkpw27QKxVIPlUANAY3e7mbKuWGNYjLv9+KUrkwGhSXnOwUUCC01w+8JpII2j1W6
    8iAvKGszfolVfmfj8vqscQ/UqlSKaGjruWk394v3b7eddYh7HCAOtgOJDIKX9F0e
    bMkIdqQgw2e5uenwt1S9TgwOvYi+IfuZ5yhQv9Yuwo76QS8UkxOyvZdRZl7MIchx
    O0THaTYbrca0GsSc+r9SIb++rM5fQ0yxQzh36PqbGiA1noS/dhkRZb3ywLPNoFzu
    qwWOvcN6ubhO5YOKmTPn1N0uVg94LVMCxMWlO+DjZ8aFmMr96wIDAQABMA0GCSqG
    SIb3DQEBBQUAA4IBAQBimCfClavq2Wk1Zsq9AQ3TWeVFrm1kaCUi4J5j3uWNlMVK
    PsIGE0BHAALMixG+XWt5+QW70CXq6RnHXMS0TLfM5q6K8jIVURK599bTF2/d4fNq
    3QJNaVusuqCqym3Z7rt71QfGtPi0rVKVlQL+lL87a0TDLIyWLsbEe786NpYe0mEe
    BXPQwpPwSaJ1PnPNlsl5i/cUZou5zZQGHtqEY/PR7wAxS/28A6qWLVpMQEUYtb9M
    ZBb6lO15RJ5qwk6paQG87nhMPAFwSbK+OpCkt3hYd7l8LjXNG74eOZdPM5V6DmZz
    nMRF0t4QBDKsuZ64N/+u7R3Nj6uzsQsb7PJXGNTf
    -----END CERTIFICATE-----
EOF
  }
}
