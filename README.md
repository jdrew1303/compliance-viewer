# compliance-viewer

A small application to access scan results stored in S3.

[![Build Status](https://travis-ci.org/18F/compliance-viewer.svg?branch=master)](https://travis-ci.org/18F/compliance-viewer)
[![Dependency Status](https://gemnasium.com/18F/compliance-viewer.svg)](https://gemnasium.com/18F/compliance-viewer)
[![Code Climate](https://codeclimate.com/github/18F/compliance-viewer/badges/gpa.svg)](https://codeclimate.com/github/18F/compliance-viewer)
[![Test Coverage](https://codeclimate.com/github/18F/compliance-viewer/badges/coverage.svg)](https://codeclimate.com/github/18F/compliance-viewer/coverage)

## Setup

### Cloudgov-style

Compliance Viewer uses the [cloudgov-style](https://github.com/18F/cg-style) compiled CSS, images, and fonts.

Run `npm intall` to install the cloudgov-style assets.

### ENV

#### Production

We provide environment variables via [User Provided Services](https://docs.cloudfoundry.org/devguide/services/user-provided.html). You can set them all interactively.

```bash
cf cups compliance-viewer-env -p "aws_region, results_folder"
```

The `cf env` command can be used to verify that ENV vars have been set. Use `cf uups` to update existing values.

#### Locally

User Provided Services expose values via CloudFoundry's `VCAP_SERVICES` environment variable, in JSON. In development we mimic this.

1. Run

    ```bash
    cp env/example.json env/development.json
    ```

1. Fill out the required fields. This JSON will be parsed the same way [`VCAP_SERVICES`](https://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html#VCAP-SERVICES) are parsed in production.
1. Run the application with

    ```bash
    bundle
    rackup
    ```

### On cloud.gov

The 18F instance of Compliance Viewer is deployed to cloud.gov in the `cf` organization and `toolkit` space. If you are an 18F staff member and don't have access, ask someone in #cloud-gov-support to run:

```bash
cf set-space-role <your email> cf toolkit SpaceDeveloper
```

Compliance Viewer uses an S3 bucket provided by cloud.gov. After pushing the application, you can create the S3 bucket with:

```bash
cf target -o cf -s toolkit
cf create-service s3 basic s3-compliance-toolkit
cf bind-service compliance-viewer s3-compliance-toolkit
```

Compliance Viewer relies on S3 bucket versioning. It can be enabled via the [AWS CLI](https://aws.amazon.com/cli/) using:

```bash
aws s3api put-bucket-versioning --bucket BUCKET_NAME --versioning-configuration Status=Enabled
```

or checked via:

```bash
aws s3api get-bucket-versioning --bucket BUCKET_NAME
```

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
