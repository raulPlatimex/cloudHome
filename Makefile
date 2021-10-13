# Copyright 2020 Marco Nenciarini <mnencia@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

REVISION := $(shell git rev-parse --short HEAD || unknown)
REVISION_DATE := $(shell git log -1 --pretty=format:'%ad' --date short)
VERSION := $(shell git describe --tags --match 'v*' | sed -e 's/^v//; s/-g[0-9a-f]\+$$//; s/-\([0-9]\+\)$$/+dev\1/')
LDFLAGS = -s -w -X main.revision=$(REVISION) -X main.revisionDate=$(REVISION_DATE) -X main.version=$(VERSION)

.PHONY: all
all: mchfuse

mchfuse: main.go $(wildcard mch/*.go) $(wildcard fsnode/*.go)
	go fmt ./...
	go vet ./...
	go build -ldflags="$(LDFLAGS)" -o mchfuse main.go

.PHONY: test
test:
	go test ./...

.PHONY: lint
lint:
	golangci-lint run --fix

.PHONY: clean
clean:
	rm -f mchfuse

.PHONY: install
install: mchfuse
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 755 mchfuse $(DESTDIR)$(PREFIX)/bin/

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mchfuse
