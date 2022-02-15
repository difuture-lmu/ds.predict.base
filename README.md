
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Actions
Status](https://github.com/difuture-lmu/ds.predict.base/workflows/R-CMD-check/badge.svg)](https://github.com/difuture-lmu/ds.predict.base/actions)
[![License: LGPL
v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)
[![codecov](https://codecov.io/gh/difuture-lmu/ds.predict.base/branch/master/graph/badge.svg?token=OLIPLWDTN5)](https://codecov.io/gh/difuture-lmu/ds.predict.base)

# Base Predict Functions for DataSHIELD

The package provides base functionality to push `R` objects to servers
using the DataSHIELD\](<https://www.datashield.org/>) infrastructure for
distributed computing. Additionally, it is possible to calculate
predictions on the server for a specific model. Combining these allows
to push a model from the local machine to all servers running DataSHIELD
and predicting on that model with data exclusively hold by the server.
The predictions are stored at the server and can be further analysed
using the DataSHIELD functionality for non-disclosive analyses.

## Installation

At the moment, there is no CRAN version available. Install the
development version from GitHub:

``` r
remotes::install_github("difuture-lmu/ds.predict.base")
```

#### Register methods

It is necessary to register the assign and aggregate methods in the OPAL
administration. These methods are registered automatically when
publishing the package on OPAL (see
[`DESCRIPTION`](https://github.com/difuture/ds.predict.base/blob/master/DESCRIPTION)).

Note that the package needs to be installed at both locations, the
server and the analysts machine.

## Usage

``` r
library(DSI)
#> Loading required package: progress
#> Loading required package: R6
library(DSOpal)
#> Loading required package: opalr
#> Loading required package: httr
library(dsBaseClient)

library(ds.predict.base)
```

#### Log into DataSHIELD server

``` r
builder = newDSLoginBuilder()

surl     = "https://opal-demo.obiba.org/"
username = "administrator"
password = "password"

builder$append(
  server   = "ds1",
  url      = surl,
  user     = username,
  password = password,
  table    = "CNSIM.CNSIM1"
)
builder$append(
  server   = "ds2",
  url      = surl,
  user     = username,
  password = password,
  table    = "CNSIM.CNSIM2"
)

connections = datashield.login(logins = builder$build(), assign = TRUE)
#> 
#> Logging into the collaborating servers
#> 
#>   No variables have been specified. 
#>   All the variables in the table 
#>   (the whole dataset) will be assigned to R!
#> 
#> Assigning table data...

### Get available tables:
datashield.symbols(connections)
#> $ds1
#> [1] "D"
#> 
#> $ds2
#> [1] "D"
```

#### Load test model

``` r
# Model was fitted on the CNSIM data provided by DataSHIELD. The
# response variable is if a patient have had diabetes or not.

load("inst/extdata/mod.Rda")
summary(mod)
#> 
#> Call:
#> glm(formula = DIS_DIAB ~ LAB_TSC + LAB_TRIG + LAB_HDL + LAB_GLUC_ADJUSTED + 
#>     GENDER + DIS_CVA + MEDI_LPD + DIS_AMI, family = binomial(), 
#>     data = local_data)
#> 
#> Deviance Residuals: 
#>     Min       1Q   Median       3Q      Max  
#> -1.4261  -0.1585  -0.1203  -0.0902   3.6771  
#> 
#> Coefficients:
#>                     Estimate Std. Error z value Pr(>|z|)    
#> (Intercept)         -6.90668    1.23102  -5.611 2.02e-08 ***
#> LAB_TSC             -0.08805    0.12658  -0.696   0.4867    
#> LAB_TRIG             0.18967    0.10105   1.877   0.0605 .  
#> LAB_HDL             -0.24500    0.35656  -0.687   0.4920    
#> LAB_GLUC_ADJUSTED    0.45802    0.06535   7.009 2.41e-12 ***
#> GENDER1             -0.56792    0.32419  -1.752   0.0798 .  
#> DIS_CVA1            -9.81495 1455.39758  -0.007   0.9946    
#> MEDI_LPD1            2.12107    0.46595   4.552 5.31e-06 ***
#> DIS_AMI1           -12.73821  652.64901  -0.020   0.9844    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 566.14  on 4095  degrees of freedom
#> Residual deviance: 476.68  on 4087  degrees of freedom
#> AIC: 494.68
#> 
#> Number of Fisher Scoring iterations: 14
```

#### ds.predict.base functionality

Upload model to DataSHIELD server:

``` r
pushObject(connections, mod)
#> [2022-02-09 22:01:34] Your object is bigger than 1 MB (3.7 MB). Uploading larger objects may take some time.

# Check if model "mod" is now available:
DSI::datashield.symbols(connections)
#> $ds1
#> [1] "D"   "mod"
#> 
#> $ds2
#> [1] "D"   "mod"

# Check class of uploaded "mod":
ds.class("mod")
#> $ds1
#> [1] "glm" "lm" 
#> 
#> $ds2
#> [1] "glm" "lm"
```

Now predict on uploaded model and data set “D” and store as object
“pred”:

``` r
predictModel(connections, mod, "pred", "D")

# Check if prediction "pred" is now available:
datashield.symbols(connections)
#> $ds1
#> [1] "D"    "mod"  "pred"
#> 
#> $ds2
#> [1] "D"    "mod"  "pred"

# Summary of "pred":
ds.summary("pred")
#> $ds1
#> $ds1$class
#> [1] "numeric"
#> 
#> $ds1$length
#> [1] 2163
#> 
#> $ds1$`quantiles & mean`
#>        5%       10%       25%       50%       75%       90%       95%      Mean 
#> -6.219511 -5.933623 -5.451908 -4.892368 -4.330816 -3.828193 -3.484391 -4.871689 
#> 
#> 
#> $ds2
#> $ds2$class
#> [1] "numeric"
#> 
#> $ds2$length
#> [1] 3088
#> 
#> $ds2$`quantiles & mean`
#>        5%       10%       25%       50%       75%       90%       95%      Mean 
#> -6.241525 -5.940107 -5.476556 -4.904900 -4.336034 -3.839188 -3.426842 -4.879383
```

Now do the same but assign the values using response type “response”:

``` r
predictModel(connections, mod, "pred", "D", predict_fun = "predict(mod, newdata = D, type = 'response')")
ds.summary("pred")
#> $ds1
#> $ds1$class
#> [1] "numeric"
#> 
#> $ds1$length
#> [1] 2163
#> 
#> $ds1$`quantiles & mean`
#>          5%         10%         25%         50%         75%         90% 
#> 0.001986267 0.002641871 0.004269807 0.007447750 0.012985956 0.021285935 
#>         95%        Mean 
#> 0.029759964 0.012757105 
#> 
#> 
#> $ds2
#> $ds2$class
#> [1] "numeric"
#> 
#> $ds2$length
#> [1] 3088
#> 
#> $ds2$`quantiles & mean`
#>          5%         10%         25%         50%         75%         90% 
#> 0.001943102 0.002624839 0.004166283 0.007355694 0.012919244 0.021058086 
#>         95%        Mean 
#> 0.031467146 0.013243564
```

``` r
datashield.logout(connections)
```

## Deploy information:

**Build on 2022-02-09 22:02:35.**

This readme is built automatically after each push to the repository.
Hence, it also is a test if the functionality of the package works also
on the DataSHIELD servers. We also test these functionality in
`tests/testthat/test_on_active_server.R`. The system information of the
local and remote servers are as followed:

  - Local machine:
      - `R` version: R version 4.1.2 (2021-11-01)
      - Version of DataSHELD client packages:

| Package         | Version |
| :-------------- | :------ |
| DSI             | 1.3.0   |
| DSOpal          | 1.3.1   |
| dsBaseClient    | 6.1.1   |
| ds.predict.base | 0.0.1   |

  - Remote DataSHIELD machines:
      - `R` version of ds1: R version 4.1.1 (2021-08-10)
      - `R` version of ds2: R version 4.1.1 (2021-08-10)
      - Version of server packages:

| Package         | ds1: Version | ds2: Version |
| :-------------- | :----------- | :----------- |
| dsBase          | 6.1.1        | 6.1.1        |
| resourcer       | 1.1.1        | 1.1.1        |
| ds.predict.base | 0.0.1        | 0.0.1        |
