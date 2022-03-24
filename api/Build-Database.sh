#! /bin/bash
echo "Bookstore Example - Database Build Script"
echo "Contact: Steven Velozo <steven@velozo.com>"
echo ""
echo "---"
echo ""

echo "--> Generating JSON model from DDL (with the BookStore prefix)"
npx stricture -i ./model/ddl/BookStore.ddl -c Compile -f ./model/json_schema/ -o BookStore

echo "--> Generating MySQL Create Statements"
npx stricture -i ./model/json_schema/BookStore-Extended.json -c MySQL -f ./model/sql_create/ -o "BookStore-CreateDatabase"

echo "--> Generating Meadow Schemas"
npx stricture -i ./model/json_schema/BookStore-Extended.json -c Meadow -f ./model/meadow_schema/ -o "BookStore-MeadowSchema-"

echo "--> Generating Documentation"
npx stricture -i ./model/json_schema/BookStore-Extended.json -c RelationshipsFull -g -f ./model/generated_diagram/
npx stricture -i ./model/json_schema/BookStore-Extended.json -c Documentation -g -f ./model/generated_documentation/

echo "--> Database Code generation and compilation complete!"