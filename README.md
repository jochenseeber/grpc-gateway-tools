Protoc and GRPC Gateway Tools
=============================

This library provides binaries and proto code from the [Protobuf][protobuf-project] and [GRPC
Gateway][grpc-gateway-project] projects for Java and Ruby.

[protobuf-project]: https://developers.google.com/protocol-buffers/
[grpc-gateway-project]: https://grpc-ecosystem.github.io/grpc-gateway/

## Java

The following Java projects are provided

* _protoc-grpc-gateway-options:_ Proto files and precompiled classes for the GRPC Gateway options

## Ruby

The following RubyGems projects are provided

* _protoc-tools:_ Protoc binary and proto files
* _protoc-grpc-gateway-options:_ Proto files and pregenerated source code for the GRPC Gateway proto options
* _protoc-grpc-gateway-plugins:_ Binaries for the Swagger and GRPC Gateway plugins

## Installing

Install all RubyGems locally and install all Java libraries into the Maven repository:

```bash
rake install
```

## Example

* [Ruby example project][ruby-example] showing how to generate Swagger docs and GRPC Gateway code

[ruby-example]: ruby/examples/foo_service/

## Licenses

* `protoc` is licensed under a [BSD-3-Clause][protoc-license] license
* `grpc-gateway` is licensed under a [BSD-3-Clause][grpc-gateway-license] license
* This project is licensed under a [BSD-3-Clause][protoc-tools-license] license

[protoc-license]: https://raw.githubusercontent.com/protocolbuffers/protobuf/master/LICENSE
[grpc-gateway-license]: https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/LICENSE.txt
[protoc-tools-license]: https://raw.githubusercontent.com/jochenseeber/protoc-tools/master/LICENSE.txt