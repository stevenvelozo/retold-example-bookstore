#! /bin/bash
echo "StrictureDatabase Build Script"
echo "Contact: Steven Velozo <steven@velozo.com>"
echo ""
echo "---"
echo ""

echo "--> Generating JSON model from DDL"
npx stricture -i ./model/ddl/Model.ddl -c Compile -f ./model/json_schema/ -o Model

echo "--> Generating MySQL Create Statements"
npx stricture -i ./model/json_schema/Model-Extended.json -c MySQL -f ./model/sql_create/ -o "Model-CreateDatabase"

echo "--> Generating Meadow Schemas"
npx stricture -i ./model/json_schema/Model-Extended.json -c Meadow -f ./model/meadow/ -o "MeadowSchema-"

echo "--> Generating Documentation"
npx stricture -i ./model/json_schema/Model-Extended.json -c Documentation -g -f ./model/doc/
npx stricture -i ./model/json_schema/Model-Extended.json -c Relationships -g -f ./model/doc/diagram
npx stricture -i ./model/json_schema/Model-Extended.json -c RelationshipsFull -g -f ./model/doc/diagram/full

echo "--> Database Code generation and compilation complete!"