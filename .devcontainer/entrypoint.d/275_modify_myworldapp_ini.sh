#!/bin/bash

# This script updates the myworldapp.ini file with the following changes:
# 1. Update the myw.search.options section to set the following values:
# 2. Update the myw.auth.engines section to include desired auth engines

myworldapp_ini_file=/opt/iqgeo/platform/WebApps/myworldapp.ini

min_term_length=3
min_term_length_digits=3
timeout=15

auth_engines='["myw_internal_auth_engine", "myw_saml_auth_engine"]'

# Define the start and end patterns for the myw.search.options section to be updated
myw_search_start_pattern='myw.search.options  = { "min_term_length":'
myw_search_end_pattern='timeout":'

# Use awk to find the line numbers for the start and end of the section
myw_search_start_line=$(awk "/$myw_search_start_pattern/{print NR}" ${myworldapp_ini_file})
myw_search_end_line=$(awk "/$myw_search_end_pattern/{print NR}" ${myworldapp_ini_file})

# Check if both start and end lines were found
if [ -n "$myw_search_start_line" ] && [ -n "$myw_search_end_line" ]; then
  # Use sed to update the specific fields within the section
  sed -i "${myw_search_start_line},${myw_search_end_line} {
    s/\"min_term_length\": *[0-9]*/\"min_term_length\": ${min_term_length}/
    s/\"min_term_length_digits\": *[0-9]*/\"min_term_length_digits\": ${min_term_length_digits}/
    s/\"timeout\": *\([0-9]*\|None\)/\"timeout\": ${timeout}/
  }" ${myworldapp_ini_file}
else
  echo "The specified section was not found in the file."
fi

# Update myw.auth.engines in myworld to include new auth engines
sed -i "s/myw.auth.engines = \[.*\]/myw.auth.engines = $auth_engines/" ${myworldapp_ini_file}

# Update myw.auth.saml.options "config_dir". Point config_dir to /opt/iqgeo/saml
sed -i 's|myw.auth.saml.options = { "config_dir"      : ""|myw.auth.saml.options = { "config_dir"      : "/opt/iqgeo/saml"|g' ${myworldapp_ini_file}