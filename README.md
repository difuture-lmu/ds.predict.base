
<!-- README.md is generated from README.Rmd. Please edit that file -->

    ## Loading ds.predict.base

[![Actions
Status](https://github.com/difuture/ds.predict.base/workflows/R-CMD-check/badge.svg)](https://github.com/difuture/ds.predict.base/actions)
[![License: LGPL
v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)
[![codecov](https://codecov.io/gh/difuture/ds.predict.base/branch/master/graph/badge.svg?token=OLIPLWDTN5)](https://codecov.io/gh/difuture/ds.predict.base)
<!--[![pipeline status](https://gitlab.lrz.de/difuture_analysegruppe/ds.predict.base/badges/master/pipeline.svg)](https://gitlab.lrz.de/difuture_analysegruppe/ds.predict.base/-/commits/master) [![coverage report](https://gitlab.lrz.de/difuture_analysegruppe/ds.predict.base/badges/master/coverage.svg)](https://gitlab.lrz.de/difuture_analysegruppe/ds.predict.base/-/commits/master)-->

# Base Predict Function for DataSHIELD

## Overview

The package is written

## Installation

At the moment, there is no CRAN version available. Install the
development version from GitHub:

``` r
remotes::install_github("difuture/ds.predict.base")
```

#### Register assign methods

It is necessary to register the assign methods in the OPAL
administration to use them. The assign methods are:

  - `decodeBinary`
  - `assignPredictModel`

These methods should be registered automatically when publishing the
package on OPAL (see `DESCRIPTION`).

## Usage

The following code shows the basic methods and how to use them. Note
that this package is intended for internal usage and base for the other
packages and does not really have any practical usage for the analyst.

``` r
library(DSI)
library(DSOpal)
library(DSLite)
library(dsBaseClient)

# library(ds.predict.base)

builder = DSI::newDSLoginBuilder()

builder$append(
  server   = "ibe",
  url      = "https://dsibe.ibe.med.uni-muenchen.de",
  user     = "ibe",
  password = "123456",
  table    = "ProVal.KUM"
)


logindata = builder$build()
connections = DSI::datashield.login(logins = logindata, assign = TRUE, symbol = "D", opts = list(ssl_verifyhost = 0, ssl_verifypeer=0))

### Get available tables:
DSI::datashield.symbols(connections)

### Test data with same structure as data on test server:
dat   = cbind(age = sample(20:100, 100L, TRUE), height = runif(100L, 150, 220))
probs = 1 / (1 + exp(-as.numeric(dat %*% c(-3, 1))))
dat   = data.frame(gender = rbinom(100L, 1L, probs), dat)

### Model we want to upload:
mod = glm(gender ~ age + height, family = "binomial", data = dat)

### Upload model to DataSHIELD server
pushObject(connections, mod)

# Check if model "mod" is now available:
DSI::datashield.symbols(connections)

# Check class of uploaded "mod"
ds.class("mod")

# Now predict on uploaded model and data set D:
predictModel(connections, mod, "pred", dat_name = "D")

# Check if prediction "pred" is now available:
DSI::datashield.symbols(connections)

# Summary of "pred":
ds.summary("pred")

# Now assign values with response type "response":
predictModel(connections, mod, "pred", "D", predict_fun = "predict(mod, newdata = D, type = 'response')")

ds.summary("pred")

DSI::datashield.logout(connections)
```
