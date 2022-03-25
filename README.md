# Book Store Example

Example Book Store App for the RETOLD framework.

# How to use:

## Install MySQL or MariaDB on your computer

I recommend using docker!

## Create a Database in MySQL

I recommend calling this `bookstore` so everything works as-is.

## Update the `api/bookstore-configuration.json` MySQL section to match your user

You need to make sure the IP, port, user and password are all correct.

## Install the Node.js modules

From the `api/` folder, run `npm install`.  Make sure to user node version 8.

## Run the Stricture database description generation scripts.

You can run `Build-Database.sh` from the `api/` folder and everything will generate properly

## Create the Database Tables

From your favorite MySQL client, connect to the server you are already running on your computer.  Load up the file stricture generated in `api/model/sql_create/BookStore-CreateDatabase.mysql.sql` and execute it against your database.  This will create all the empty tables you need.

## Run the API server

If everything went well so far, you should be able to go to the `api` folder and run `npm start`.

## Import the books to the database

From a terminal, navigate to the `api/` folder and run `node import-books.js`

A bunch of spam will happen on the terminal as books, authors and their connections are loaded.

## Point a browser at http://127.0.0.1:8080/

What a well-stocked bookstore!


# Dockerized Development Environment


1. Run this command to build this image:
```
docker build ./ -t retold/retold-example_bookstore:local
```

alternatively you can use npm to run this


```
npm run docker-dev-build-image
```

2. Run this command to build the local container:
```
docker run -it --name retold-example_bookstore-dev -p 127.0.0.1:12346:8080 -p 12306:3306 -v "$PWD/.config:/home/coder/.config"  -v "$PWD:/home/coder/retold-example_bookstore" -u "$(id -u):$(id -g)" -e "DOCKER_USER=$USER" retold/retold-example_bookstore:local
```

alternatively you can use npm to run this

```
npm run docker-dev-run
```

3. Go to http://localhost:12346/ in a web browser

4. The password is "retold"

5. Right now you (may) need to delete the `node_modules` folders and regenerate it for Linux.