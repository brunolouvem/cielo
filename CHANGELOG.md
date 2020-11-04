# Changelog

## v0.1.4 (2020-11-04)

### Enhancements
* Telemetry events
* New module Recurrency, centralizing recurrent payment functions
* New functions
    - `update_payment_data/2`
    - `update_end_date/2`
    - `update_next_charge_date/2`
    - `update_interval/2`
    - `update_charge_day/2`
    - `update_amount/2`
    - `reactivate_recurrent/1`

## v0.1.3 (2020-10-28)

### Enhancements
* Cancel Recurrency
* Cancel Sale
* Cancel Partial Sale

### Fixes
* Remove accidental IO.inspect in Cielo.HTTP

## v0.1.2 (2020-10-20)

### Enhancements
* Capture Call

### Fixes
* Wrong string path concat
* Wrong Accep-Encoding header sent to Cielo

## v0.1.1 (2020-10-19)

### Enhancements
* ZeroAuth Consultation
* Improvements in documentation

## v0.1.0 (2020-10-18)

### Added

* First Commit with features:
    * Bin Consultation
    * Bin Consultation
    * Payment Consultation
    * Credit Card Transaction
    * Debit Card Transaction
    * BankSlip Transaction
    * Recurrent Payment Transaction