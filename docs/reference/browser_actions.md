# Define actions that run immediately in the browser

Captures supported shinyphaser method calls without evaluating them in
R. Browser actions are compiled when passed to an event registration
method. Arbitrary R code belongs in the corresponding `server_action`
function.

## Usage

``` r
browser_actions(...)
```

## Arguments

- ...:

  Supported shinyphaser browser action calls.

## Value

A browser action specification.
