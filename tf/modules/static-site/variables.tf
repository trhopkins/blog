variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The project name that will be applied to tags"
  type        = string
}

variable "env" {
  description = "The environment the resources are deployed to"
  type        = string
  default     = "production"
}

variable "bucket_name" {
  description = "Name of S3 bucket for website"
  type        = string
}

variable "cf_dist_name" {
  description = "Name of Cloudfront distribution for website"
  type        = string
}

variable "cf_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "cf_ttl" {
  description = "Default TTL for CloudFront caching"
  type        = number
  default     = 60 * 60 * 24 // 1 day
}

variable "default_root_object" {
  description = "Default root object file name for Cloudfront Distribution - include extension"
  type        = string
  default     = "index.html"
}


variable "path_to_bundle" {
  description = "The file system path, relative to this module, to the frontend build files, which will be uploaded to S3 and served by CloudFront."
  type        = string
}

variable "root_domain_name" {
  description = "The root of your domain name (without the wwww.)"
  type        = string
  default     = ""
}

// TODO Improve this 
variable "content_types" {
  type = map(string)
  default = {
    ".css"  = "text/css",
    ".gif"  = "image/gif",
    ".html" = "text/html",
    ".jpg"  = "image/jpeg",
    ".js"   = "application/javascript",
    ".pdf"  = "application/pdf",
    ".png"  = "image/png",
    ".svg"  = "image/svg+xml",
    ".webp"  = "image/webp",
  }
}

variable "mime_types" {
  default = {
    css  = "text/css"
    htm  = "text/html"
    html = "text/html"
    xml  = "text/xml"
    gif  = "image/gif"
    ico  = "image/x-icon"
    jpeg = "image/jpeg"
    png  = "image/png"
    svg  = "image/svg"
    svg  = "image/svg+xml"
    ttf  = "font/ttf"
    js   = "application/javascript"
    json = "application/json"
    map  = "application/javascript"
    pdf  = "application/pdf"
  }
}

