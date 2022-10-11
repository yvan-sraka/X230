# This is the modest list of free/public Wi-Fi networks I used to join while
# working outside (mostly between Brussels and Paris), feel free to use it and
# to extend it :)

{ ... }: {
  networking.wireless.networks = {
    # Train
    "_SNCF_WIFI_INOUI" = {};
    "_SNCF_WIFI_INTERCITES" = {};
    "THALYSNET" = {};
  };
}

# I also try to scrap some data, e.g. to get ~800 SSIDs, mostly in Berlin:
#
# curl -X 'GET' \
# 'https://api.openwifimap.net/view_nodes_spatial?bbox=-180%2C-90%2C180%2C90' \
# -H 'accept: application/json' | jq '.rows[] | .value.hostname'
