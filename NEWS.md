# Updates

## Version 0.2.0.0

- Major update! Fixes broken functionality, introduces several new functions.

- Deprecates or removes most package functions from Version 0.1.9.1.

- Adds detailed project documentation, including two vignettes.

## Version 0.1.9.2

- Use GitHub actions build pipeline

## Version 0.1.9.1

- Resolves bug where data for one country with one frequency would not
parse. #27

## Version 0.1.9

- Resolves bug where `imf_data` would stop for iterations with small
numbers of countries with no data, stopping the entire download.
Thank you to @mitsuoxv for the contribution.

## Version 0.1.8

- Updated `imf_ids` to point to new URL following deprecation of old
SDMX service. See <http://sdmxws.imf.org/Default.htm>.

- Introduced "NA" ISO2C code for Namibia. Thank you to #msgoussi for reporting.
#22, #23

## Version 0.1.7

- Re-reinstated `imf_ids` functionality. Thank you to @mitsuoxv. #17

- `imf_data` throws a more intelligible error when `indicator` does not
inherit `character`. #16

## Version 0.1.6

- Reinstated `imf_ids` functionality. Thank you @cjyetman. #11

## Version 0.1.5

- Warning on `imf_ids` that as of 2017-11-17 the request is unsuccessful.

## Version 0.1.4

- Resolved bug where `imf_metadata` produced malformed API calls. #9

- Documentation improvements.

## Version 0.1.3

- Bug fix for IMF API call using default user agent to `GET`. Thanks to
@cjyetman for fixing.

## Version 0.1.2

- Fixed a bug preventing `imf_data` from successfully completing
`return_raw = TRUE`.

- Added new internal function `current_year` so that the current year is the
default `end` year. Thanks to Jay Ulfelder for inspiration.

- Minor documentation typo fix.

## Version 0.1.1

- Updated URL GET request schema to meet changes introduced by the IMF on
2016-07-27. These changes had broke `imf_data`, but the issue is now resolved.
For more details on the API changes see:
<http://data.imf.org/?sk=A329021F-1ED6-4D6E-B719-5BF5413923B6>.

- `imf_data` now has an optional argument (`print_url`) that will print to the
URL used in the API to the console. This can be useful for API debugging.