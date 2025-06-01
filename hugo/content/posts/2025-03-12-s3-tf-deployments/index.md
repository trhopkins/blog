---
title: "Terraform site deployments to S3 and CloudFront"
date: 2025-03-12T12:00:00-05:00
draft: true
summary: My current site deployment strategy.
tags: [programming, cloud, devops]
---

I've been deploying Camp Hopkins via GitHub Actions and Terraform to an S3
bucket and distributing it with CloudFront. This strategy is more involved than
typical static blog hosting services, but it offers some satisfying advantages.
My understanding of AWS has already increased, and I've had plenty of "fun"
getting a feel for the underlying infrastructure.

# S3 web hosting

AWS has a simple and effective solution for static web hosting: just throw your
site content in an S3 bucket, enable [web hosting](TODO LINK TO DOCS HERE), and
you're done! Of course this doesn't give you the fine-grained control that a
typical deployment has: A dedicated URL, caching at edge locations, and DDoS
protection to name a few. I could see myself using this as a test bed for
future static pages, but I would come to find out that the behavior differs
enough to make this unappealing.

# CloudFront

CloudFront's documentation is pretty dense, so getting something working quickly was a priority so I could build my understanding from there. I ran into some problems

## OAI versus OAC

## CloudFront Functions and redirects

## Debugging DNS

## Debugging caching

# Deploying with GitHub Actions and Terraform

## Content types

## Modularization

## Credentials

