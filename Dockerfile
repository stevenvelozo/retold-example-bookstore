# Use the codercom/code-server image
FROM codercom/code-server:latest
MAINTAINER steven velozo

VOLUME /home/coder/.config
VOLUME /home/coder/.vscode

RUN echo "...installing debian dependencies..."
RUN sudo apt update
RUN sudo apt install vim curl tmux -y
RUN sudo apt install default-mysql-server default-mysql-client -y

RUN echo "Building RETOLD development image..."

RUN echo "...configuring mariadb (mysql) server..."
RUN sudo sed -i "s|bind-address|#bind-address|g" /etc/mysql/mariadb.conf.d/50-server.cnf
ADD ./.config/MySQL-Security.sql /home/coder/MySQL-Configure-Security.sql
ADD ./.config/MySQL-Laden-Entry.sh /usr/bin/MySQL-Laden-Entry.sh
RUN ( sudo mysqld_safe --skip-grant-tables --skip-networking & ) && sleep 5 &&  mysql -u root < /home/coder/MySQL-Configure-Security.sql

# Import the initial database
COPY ./api/model/sql_create/BookStore-CreateDatabase.mysql.sql /home/coder/MySQL-Create-Databases.sql
RUN sudo service mariadb restart && sleep 5 && mysql -u root -p"123456789" -e "CREATE DATABASE bookstore;"
RUN sudo service mariadb restart && sleep 5 && mysql -u root -p"123456789" bookstore < /home/coder/MySQL-Create-Databases.sql

SHELL ["/bin/bash", "-c"]
USER coder

# Copy any default configs for the coding environment we want (e.g. dark theme)
# This broke the debug runners
# COPY ./.config/.default_home/ /home/coder/

RUN echo "...mapping development environment volumes..."
# Volume mappings for RETOLD:Bookstore example and subsequent libraries

RUN mkdir -p /home/coder/retold-dev
VOLUME /home/coder/retold-dev/retold-example_bookstore
# The library folder is for whatever module you want to work on
VOLUME /home/coder/retold-dev/library

RUN echo "...installing node version manager..."
# Because there is a .bashrc chicken/egg problem, we will create one here to simulate logging in.  This is not great.
RUN touch ~/.bashrc && chmod +x ~/.bashrc
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

RUN echo "...installing node version 14 as the default..."
RUN . ~/.nvm/nvm.sh && source ~/.bashrc && nvm install 14
RUN . ~/.nvm/nvm.sh && source ~/.bashrc && nvm alias default 14

RUN echo "...copying back the vscode file because of the metaenvironment..."
COPY ./.vscode /home/coder/retold-dev/.vscode

WORKDIR /home/coder/retold-dev

RUN echo "...build complete!"

ENTRYPOINT ["/usr/bin/MySQL-Laden-Entry.sh"]