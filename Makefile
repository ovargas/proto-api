$(VERBOSE).SILENT:
############################# Main targets #############################

# install deps and generate code
ci-build: install proto

# lint proto files
ci-lint: install buf-breaking buf-lint

# Install dependencies.
install: proto-install plugins-install buf-install

# Run all linters and compile proto files.
proto: buf-lint buf-gen
########################################################################

##### Variables ######
ifndef GOPATH
GOPATH := $(shell go env GOPATH)
endif

GOBIN := $(if $(shell go env GOBIN),$(shell go env GOBIN),$(GOPATH)/bin)
SHELL := PATH=$(GOBIN):$(PATH) /bin/sh

COLOR := "\e[1;36m%s\e[0m\n"

PROTO_ROOT := .
PROTO_FILES = $(shell find $(PROTO_ROOT) -name "*.proto")
PROTO_DIRS = $(sort $(dir $(PROTO_FILES)))
PROTO_OUT := gen

$(PROTO_OUT):
	mkdir $(PROTO_OUT)

##### Compile proto files #####
buf-gen: buf-gen-deps
	buf generate

# Generate code for go-specific dependencies that would otherwise break the code in java,js,etc.
buf-gen-deps:
	buf generate buf.build/googleapis/googleapis --path google/api/annotations.proto --path google/api/http.proto
	buf generate buf.build/googleapis/googleapis --path google/api/annotations.proto --path google/api/field_behavior.proto
	buf generate buf.build/grpc-ecosystem/grpc-gateway --path protoc-gen-openapiv2/options

publish-go:
	./scripts/publish.sh $(AKORDA_GITLAB_TOKEN) $(CI_COMMIT_TAG) "api-go" "api" ""

##### Plugins & tools #####
plugins-install:
	printf $(COLOR) "Install/update proto and gRPC plugins..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0 # generate grpc
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.6.0 # generate gateway
	GO111MODULE=on go  install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest # generate swagger
	go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.5.0 # generate json doc
	npm install grpc-tools@1.9.1 --global # js grpc
	npm install ts-protoc-gen --global # ts
	./scripts/install_swagger.sh

buf-install:
	printf $(COLOR) "Install/update buf..."
	go install github.com/bufbuild/buf/cmd/buf@v0.56.0

proto-install:
	./scripts/install_protoc.sh

##### Linters #####
buf-lint:
	printf $(COLOR) "Run buf linter..."
	(cd $(PROTO_ROOT) && buf lint)

buf-breaking:
	@printf $(COLOR) "Run buf breaking changes check against main branch..."
	@(cd $(PROTO_ROOT) && buf breaking --against 'https://github.com/ovargas/proto-api.git#branch=main')

##### Clean #####
clean:
	printf $(COLOR) "Deleting generated files..."
	rm -rf $(PROTO_OUT)

clean-all: clean
	rm -rf ./bin
