variable "root_domain" {
    type = string
    description = "The root domain name for the Tesla App"
    default = "example.com"
}

variable "tesla_app_subdomain" {
    type = string
    description = "The domain name for the Tesla App"
    default = "www.example.com"
}

variable "tesla_callback_subdomain" {
    type = string
    description = "The domain name for the Tesla Callback"
    default = "api.example.com"
}
