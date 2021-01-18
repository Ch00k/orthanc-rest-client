#!/usr/bin/env bash

set -e

if ! hash jq 2>/dev/null; then
    echo "jq not found, cannot continue"
    exit 1
fi

cleanup() {
    curl_command="curl"
    if [ -n $ORC_ORTHANC_USERNAME ] && [ -n $ORC_ORTHANC_PASSWORD ]; then
        curl_command="$curl_command --user $ORC_ORTHANC_USERNAME:$ORC_ORTHANC_PASSWORD"
    fi

    patients_curl_command="$curl_command $ORC_ORTHANC_ADDRESS/patients"
    patients=($($patients_curl_command | jq -c '.[]' | tr -d '"'))

    for patient in "${patients[@]}"; do
        delete_curl_command="$patients_curl_command/$patient -X DELETE"
        echo $delete_curl_command
        $delete_curl_command
    done

    modalities_curl_command="$curl_command $ORC_ORTHANC_ADDRESS/modalities"
    modalities=($($modalities_curl_command | jq -c '.[]' | tr -d '"'))

    for modality in "${modalities[@]}"; do
        delete_curl_command="$modalities_curl_command/$modality -X DELETE"
        echo $delete_curl_command
        $delete_curl_command
    done

    peers_curl_command="$curl_command $ORC_ORTHANC_ADDRESS/peers"
    peers=($($peers_curl_command | jq -c '.[]' | tr -d '"'))

    for peer in "${peers[@]}"; do
        delete_curl_command="$peers_curl_command/$peer -X DELETE"
        echo $delete_curl_command
        $delete_curl_command
    done

    # Cleanup peer
    patients_curl_command="$curl_command http://localhost:8029/patients"
    patients=($($patients_curl_command | jq -c '.[]' | tr -d '"'))

    for patient in "${patients[@]}"; do
        delete_curl_command="$patients_curl_command/$patient -X DELETE"
        echo $delete_curl_command
        $delete_curl_command
    done

}

cleanup
