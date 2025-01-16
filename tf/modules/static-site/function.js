function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // see https://loganmarchione.com/2023/11/deploying-hugo-with-cloudfront-and-s3-for-real-this-time/
  var response_feed = {
    statusCode: 301,
    statusDescription: "Moved Permanently",
    headers: {
      "location": {
        "value": "/index.xml"
      }
    }
  }

  // see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/example_cloudfront_functions_url_rewrite_single_page_apps_section.html
  if (uri === "/feed" || uri === "/feed/") {
    return response_feed;
  }
  if (uri.endsWith("/")) {
    request.uri += "index.html";
  }
  else if (!uri.includes(".")) {
    request.uri += "/index.html";
  }
  return request;
}

