SHELL := /usr/bin/env bash

export ORC_ORTHANC_ADDRESS ?= http://localhost:8028
export ORC_ORTHANC_USERNAME ?= orthanc
export ORC_ORTHANC_PASSWORD ?= orthanc
export ORC_DATAFILES_PATH ?= ./tests/data/dicom
export
export DINO_SCP_HOST ?= 0.0.0.0
export DINO_SCP_PORT ?= 5252
export DINO_SCP_AET ?= DINO


.PHONY: test clean unit_test integration_test unit_test_coverage integration_test_coverage install_tarpaulin cleanup_orthanc populate_orthanc reset_orthanc start_orthanc stop_orthanc release

test: unit_test integration_test

clean: cleanup_orthanc stop_orthanc clean

unit_test:
	cargo test --lib

unit_test_coverage: install_tarpaulin
	cargo tarpaulin --lib --verbose --ignore-tests --all-features --workspace --timeout 120 --out Xml

integration_test: reset_orthanc
	cargo test --test integration -- --test-threads=1 --show-output

integration_test_coverage: install_tarpaulin reset_orthanc
	cargo tarpaulin --test integration --verbose --ignore-tests --all-features --workspace --timeout 120 --out Xml -- --test-threads=1

install_tarpaulin:
	cargo install --version 0.16.0 cargo-tarpaulin

cleanup_orthanc:
	./scripts/cleanup_orthanc.sh

populate_orthanc:
	./scripts/populate_orthanc.sh

reset_orthanc: cleanup_orthanc populate_orthanc

start_orthanc:
	docker-compose pull
	docker-compose up -d

stop_orthanc:
	docker-compose down

release:
	cargo-release
