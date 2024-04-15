#!/bin/bash

# Patch the petalinux installer file
# Florian Dupeyron
# March 2021.
# To launch: ./patch_petalinux.sh <petalinux-installer-file>

# This script patches the petalinux installer so that it can be used in a non-interactive way,
# making it great for docker installing. Currently only bypasses the license acceptance.

# See https://stackoverflow.com/questions/1030787/multiline-search-replace-with-perl

# Bypass the accept_license function by replacing it with a dummy function
perl -i -pe "BEGIN{undef $/;} s/function accept_license {.*?^}$/function accept_license {\n    echo \"Automatically accepting licenses !!!\"\n}\n/gms" "$1"
