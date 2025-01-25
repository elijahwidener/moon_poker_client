#!/bin/bash

echo "Starting proto generation..."

PLUGIN_PATH="C:/Users/elija/AppData/Local/Pub/Cache/bin/protoc-gen-dart.bat"  # Keep the full path to the plugin

echo "Processing proto files in lib/protos:"
ls lib/protos  # Relative path works since we're in the project folder

# Run protoc command with relative paths
protoc --dart_out=grpc:lib/generated \
       --proto_path=lib/protos \
       --plugin=protoc-gen-dart="$PLUGIN_PATH" \
       lib/protos/game_service.proto  # Relative path to the .proto file

echo "Generation complete. Generated files in lib/generated:"
ls lib/generated  # Relative path works here as well
